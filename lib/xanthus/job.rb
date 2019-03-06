require 'fileutils'

module Xanthus
  class Job
    attr_accessor :name
    attr_accessor :iterations
    attr_accessor :tasks
    attr_accessor :outputs
    attr_accessor :inputs

    def initialize
      @iterations = 0
      @tasks = Hash.new
      @outputs = Hash.new
      @inputs = Hash.new
    end

    def output_script outputs
      script = ''
      outputs.each do |name, path|
        script += "cp -f #{path} /vagrant/output/#{name}.data\n"
      end
      return script
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
      script += self.output_script(@outputs[machine]) unless  @outputs[machine].nil?

      script_to_clean = script
      script = ''
      script_to_clean.each_line do |s|
        script += s.strip + "\n" unless s=="\n"
      end
      script = script.gsub "\n\n", "\n"

      FileUtils.mkdir_p machine.to_s
      Dir.chdir machine.to_s do
        if !@inputs[machine].nil?
          @inputs[machine].each do |name|
            system('cp', '-f', "../../#{name}", "#{name}")
          end
        end
        FileUtils.mkdir_p 'output'
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
        system('rm', '-rf', '.vagrant')
      end
    end

    def execute config, iteration
      puts "Running job #{name.to_s}-#{iteration.to_s}..."
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
      system('mv', 'tmp', "#{name.to_s}-#{iteration.to_s}")
      system('tar', '-czvf', "#{name.to_s}-#{iteration.to_s}.tar.gz", "#{name.to_s}-#{iteration.to_s}")
      system('rm', '-rf', "#{name.to_s}-#{iteration.to_s}")
      config.github_conf.add("#{name.to_s}-#{iteration.to_s}.tar.gz") unless config.github_conf.nil?
      config.github_conf.push unless config.github_conf.nil?
      puts "Job #{name.to_s}-#{iteration.to_s} done."
    end
  end
end
