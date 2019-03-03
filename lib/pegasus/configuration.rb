module Pegasus
  class Configuration
    attr_accessor :name
    attr_accessor :seed
    attr_accessor :params
    attr_accessor :vms
    attr_accessor :scripts
    attr_accessor :jobs

    def initialize
      @params = Hash.new
      @vms = Hash.new
      @scripts = Hash.new
      @jobs = Hash.new
    end

    def vm name
      vm = VirtualMachine.new
      yield(vm)
      vm.name = name
      @vms[name] = vm
    end

    def script name
      @scripts[name] = yield
    end

    def job name
      v = Job.new
      yield(v)
      v.name = name
      @jobs[name] = v
    end
  end

  def self.write_template file, template, config
    v = eval(template)
    if v.is_a? Enumerable
      v.each do |s|
        file.write(s+"\n")
      end
    else
      file.write(v+"\n")
    end
  end

  def self.generate_script name, template, sets, config
    FileUtils.mkdir_p name
    Dir.chdir name do
      for i in 0..sets do
        File.open(name+'_'+i.to_s+'.sh', 'w+') do |f|
            f.write("# pre-script\n")
            self.write_template f, config.pre_script, config
            f.write("\n")
            f.write("# script\n")
            self.write_template f, template, config
            f.write("\n")
            f.write("# post-script\n")
            self.write_template f, config.post_script, config
            f.write("\n")
        end
      end
    end
  end

  def self.configure
    config = Configuration.new
    yield(config)
    puts "Running experiment #{config.name} with seed #{config.seed}."
    config.jobs.each do |name,job|
      job.execute config, 0
    end
  end
end
