module Pegasus
  class Configuration
    attr_accessor :name
    attr_accessor :seed
    attr_accessor :benign
    attr_accessor :params

    def initialize
      @params = Hash.new
    end
  end

  def self.configure
    config = Configuration.new
    yield(config)
    puts "Running experiment #{config.name} with seed #{config.seed}."
    puts config.params
    puts config.benign
  end
end
