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

    def lfs
      system('git', 'lfs', 'install')
      system('git', 'lfs', 'track', '*.tar.gz')
      system('git', 'add', '.gitattributes')
      system('git', 'push', "https://#{@token}@github.com/#{@repo}", 'master')
    end

    def pegasus_file
      script = ''
      File.readlines('../../.pegasus').each do |line|
        script += line unless line.include? 'github.token'
        script += "\t\tgithub.token = 'REMOVED'\n" unless !line.include? 'github.token'
      end
      File.open('.pegasus', 'w+') do |f|
        f.write(script)
      end
      system('git', 'add', '.pegasus')
      system('git', 'commit', '-m', "[Pegasus] :horse: pushed #{@folder}/.pegasus :horse:")
      system('git', 'push', "https://#{@token}@github.com/#{@repo}", 'master')
    end

    def readme_file config
      File.open('README.md', 'w+') do |f|
        f.write(config.to_readme_md)
      end
      system('git', 'add', 'README.md')
      system('git', 'commit', '-m', "[Pegasus] :horse: pushed #{@folder}/README.md :horse:")
      system('git', 'push', "https://#{@token}@github.com/#{@repo}", 'master')
    end

    def init config
      system('git', 'clone', "https://#{@token}@github.com/#{@repo}", 'repo')
      Dir.chdir 'repo' do
        self.lfs
        FileUtils.mkdir_p @folder
        Dir.chdir @folder do
          self.pegasus_file
          self.readme_file config
        end
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

    def tag
      Dir.chdir 'repo' do
        system('git', 'tag', '-a', "pegasus-#{@folder}", '-m', '"Pegasus automated dataset generation."')
        system('git', 'push', '--tags', "https://#{@token}@github.com/#{@repo}")
      end
    end

    def clean
      system('rm', '-rf', 'repo')
    end
  end
end
