require 'fileutils'

module Pegasus
  class Init
    @@r = Random.new
    @@name

    def self.header file
      file.write("# -*- mode: ruby -*-\n")
      file.write("# vi: set ft=ruby\n\n")
      file.write("NAME = '#{@@name}'\n")
      file.write("SEED = #{@@r.rand 1_000_000}\n")
    end

    def self.init name
      @@name = name
      abort("Error: #{@@name} already exists.") unless !File.exists? name
      FileUtils.mkdir_p @@name
      Dir.chdir @@name do
        puts "Creating experiment #{@@name}..."
        File.open('.pegasus', 'w+') do |f|
          self.header f
        end
      end
    end
  end
end
