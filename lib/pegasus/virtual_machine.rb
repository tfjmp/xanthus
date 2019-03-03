module Pegasus
  class VirtualMachine
    attr_accessor :name
    attr_accessor :box
    attr_accessor :version
    attr_accessor :ip
    attr_accessor :start_script
    attr_accessor :stop_script
  end

  def initialize
    @name = :default
    @box = 'jhcook/fedora27'
    @version = '4.13.12.300'
    @version = '192.168.33.8'
    @start_script = ''
    @stop_script = ''
  end
end
