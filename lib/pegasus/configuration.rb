module Pegasus
  class Configuration
    attr_accessor :name
    attr_accessor :description
    attr_accessor :seed
    attr_accessor :params
    attr_accessor :vms
    attr_accessor :scripts
    attr_accessor :jobs
    attr_accessor :github_conf

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

    def github
      github = GitHub.new
      yield(github)
      @github_conf = github
    end
  end

  def self.configure
    config = Configuration.new
    yield(config)
    puts "Running experiment #{config.name} with seed #{config.seed}."
    config.github_conf.init
    config.jobs.each do |name,job|
      for i in 0..(job.iterations-1) do
        job.execute config, i
      end
    end
    config.github_conf.clean
  end
end
