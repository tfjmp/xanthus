require 'fileutils'

module Pegasus
  class Init
    @@r = Random.new

    def self.header file
      file.write("# -*- mode: ruby -*-\n")
      file.write("# vi: set ft=ruby\n\n")
      file.write("SEED=#{@@r.rand 1_000_000}\n\n")
    end

    def self.init name
      puts 'Creating new script ...'
      File.open('.pegasus', 'w+') do |f|
        puts 'Creating file '+name+'.peg ...'
        self.header f
      end
    end
  end
end
