require 'fileutils'

module Xanthus
  class Job
    attr_accessor :name
    attr_accessor :iterations
    attr_accessor :tasks
    attr_accessor :outputs
    attr_accessor :inputs
    attr_accessor :pre_instructions
    attr_accessor :post_instructions

    def initialize
      @iterations = 0
      @tasks = Hash.new
      @outputs = Hash.new
      @inputs = Hash.new
      @pre_instructions = nil
      @post_instructions = nil
    end

    def output_script machine, outputs
      script = ''
      outputs.each do |name, path|
        script += "cp -f #{path} /vagrant/data/#{name}.data\n"
      end
      return script
    end

    def setup_env machine, scripts, config
      puts 'Setting up task on machine '+machine.to_s+'...'
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
        script = Script.new(scripts, config).to_s
        script += self.output_script(machine, @outputs[machine]) unless  @outputs[machine].nil?
        File.open('provision.sh', 'w+') do |f|
          f.write(script)
        end
        script = 'echo "nothing to do"'
        File.open('before_halt.sh', 'w+') do |f|
          f.write(script)
        end
        system('chmod', '+x', 'before_halt.sh')
      end
    end

    def host_scripts config
      puts 'Setting up host scripts...'
      if !@pre_instructions.nil?
        script = Script.new(@pre_instructions, config).to_s
        File.open('pre.sh', 'w+') do |f|
          f.write(script)
        end
      end

      if !@post_instructions.nil?
        script = Script.new(@post_instructions, config).to_s
        File.open('post.sh', 'w+') do |f|
          f.write(script)
        end
      end
    end

    def execute_pre_instructions
      puts 'Running pre instructions...'
      system('sh', './pre.sh')
    end

    def run machine
      Dir.chdir machine.to_s do
        system('vagrant', 'up')
      end
    end

    def execute_post_instructions
      puts 'Running post instructions...'
      system('sh', './post.sh')
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
        self.host_scripts config
        @tasks.each do |machine, templates|
          self.setup_env machine, templates, config
        end
        self.execute_pre_instructions unless @pre_instructions.nil?
        @tasks.each do |machine, templates|
          self.run machine
        end
        self.execute_post_instructions unless @post_instructions.nil?
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
      config.dataverse_conf.add("#{name.to_s}-#{iteration.to_s}.tar.gz") unless config.dataverse_conf.nil?
      puts "Job #{name.to_s}-#{iteration.to_s} done."
    end
  end
end
