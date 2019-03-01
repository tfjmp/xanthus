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

  def self.configure
    config = Configuration.new
    yield(config)
    puts "Running experiment #{config.name} with seed #{config.seed}."
    puts config.benign_script
    puts config.attack_script
  end
end
