require 'fileutils'

module Pegasus
  class GitHub
    attr_accessor :repo
    attr_accessor :token
    attr_accessor :folder

    def initialize
      @repo = ''
      @token = ''
      @folder = Time.now.strftime("%Y-%m-%d_%H-%M")
    end

    def init
      FileUtils.mkdir_p 'repo'
      Dir.chdir 'repo' do
        system('git', 'init')
        system('git', 'pull', "https://#{@token}@github.com/#{@repo}", 'master')
        FileUtils.mkdir_p @folder
      end
    end

    def add content
      Dir.chdir 'repo' do
        FileUtils.mkdir_p @folder
        system('mv', "../#{content}", "#{@folder}/#{content}")
        system('git', 'add', "#{@folder}/#{content}")
        system('git', 'commit', '-m', "[Pegasus] :horse: pushed #{@folder}/#{content} :horse:")
      end
    end

    def push
      Dir.chdir 'repo' do
        system('git', 'push', "https://#{@token}@github.com/#{@repo}", 'master')
        system('rm', '-rf', @folder)
      end
    end

    def clean
      system('rm', '-rf', 'repo')
    end
  end
end
