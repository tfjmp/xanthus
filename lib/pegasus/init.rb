require 'fileutils'

module Pegasus
  class Init
    @@r = Random.new
    @@name

    def self.header file
      file.write("# -*- mode: ruby -*-\n")
      file.write("# vi: set ft=ruby\n\n")
    end

    def self.config file
      script = %Q{
Pegasus.configure do |config|\n
  config.name = '#{@@name}'
  config.seed = #{@@r.rand 1_000_000}

  config.benign_sets = 100
  config.attack_sets = 20

  config.benign do
    %q{
    20.times.collect do
      'wget '+config.params['url'].sample
    end
    }
  end

  config.attack do
    %q{
    20.times.collect do
      'wget '+config.params['url'].sample
    end
    }
  end
end
}
      file.write(script)
    end

    def self.init name
      @@name = name
      abort("Error: #{@@name} already exists.") unless !File.exists? name
      FileUtils.mkdir_p @@name
      Dir.chdir @@name do
        puts "Creating experiment #{@@name}..."
        File.open('.pegasus', 'w+') do |f|
          self.header f
          self.config f
        end
      end
    end
  end
end
