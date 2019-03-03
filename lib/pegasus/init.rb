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
# -*- mode: ruby -*-
# vi: set ft=ruby
  
Pegasus.configure do |config|
  config.name = '#{@@name}'
  config.seed = #{@@r.rand 1_000_000}

  config.benign_sets = 5
  config.attack_sets = 5

  config.pre do
    %q{%{
      mkdir wgets
      cd wgets
    }}
  end

  config.benign do
    %q{
    2.times.collect do
      'wget http://www.google.com'
    end
    }
  end

  config.attack do
    %q{
    2.times.collect do
      'wget http://www.google.com'
    end
    }
  end

  config.post do
    %q{%{
      cd ..
      rm -rf wgets
    }}
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
