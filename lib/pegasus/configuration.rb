module Pegasus
  class Configuration
    attr_accessor :name
    attr_accessor :seed
    attr_accessor :params
    attr_accessor :benign_script
    attr_accessor :attack_script
    attr_accessor :benign_sets
    attr_accessor :attack_sets

    def initialize
      @params = Hash.new
    end

    def benign
      @benign_script = yield
    end

    def attack
      @attack_script = yield
    end
  end

  def self.generate_script name, template, sets, config
    FileUtils.mkdir_p name
    Dir.chdir name do
      for i in 0..sets do
        File.open(name+'_'+i.to_s+'.sh', 'w+') do |f|
            v = eval(template)
            v.each do |s|
              f.write(s+"\n")
            end
            f.write("\n")
        end
      end
    end
  end

  def self.configure
    config = Configuration.new
    yield(config)
    puts "Running experiment #{config.name} with seed #{config.seed}."
    self.generate_script 'benign', config.benign_script, config.benign_sets, config
    self.generate_script 'attack', config.attack_script, config.attack_sets, config
  end
end
