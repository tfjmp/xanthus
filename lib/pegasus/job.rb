require 'fileutils'

module Pegasus
  class Job
    attr_accessor :name
    attr_accessor :iterations
    attr_accessor :tasks

    def initialize
      @iterations = 0
      @tasks = Hash.new
    end

    def setup_env machine, scripts, config
      puts 'Setting up task on machine '+machine.to_s+'...'
      script = ''
      scripts.each do |t|
        v = eval(config.scripts[t])
        if v.kind_of?(Array)
          v.each do |w|
            script+=w+"\n"
          end
        else
          script+=v
        end
      end
      FileUtils.mkdir_p machine.to_s
      Dir.chdir machine.to_s do
        puts 'Creating provision files...'
        File.open('Vagrantfile', 'w+') do |f|
          f.write(config.vms[machine].to_vagrant)
        end
        File.open('provision.sh', 'w+') do |f|
          f.write(script)
        end
      end
    end

    def run machine
      Dir.chdir machine.to_s do
        system('vagrant', 'up')
      end
    end

    def halt machine
      Dir.chdir machine.to_s do
        system('vagrant', 'halt')
      end
    end

    def destroy machine
      Dir.chdir machine.to_s do
        system('vagrant', 'destroy', '-f')
      end
    end

    def execute config
      puts 'Running job '+name.to_s+'...'
      FileUtils.mkdir_p 'tmp'
      Dir.chdir 'tmp' do
        @tasks.each do |machine, templates|
          self.setup_env machine, templates, config
        end
        @tasks.each do |machine, templates|
          self.run machine
        end
        @tasks.each do |machine, templates|
          self.halt machine
        end
        @tasks.each do |machine, templates|
          self.destroy machine
        end
      end
      puts 'Job '+name.to_s+' done.'
    end
  end
end
