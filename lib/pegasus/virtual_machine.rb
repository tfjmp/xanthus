module Pegasus
  class VirtualMachine
    attr_accessor :name
    attr_accessor :box
    attr_accessor :version
    attr_accessor :ip
    attr_accessor :start_script
    attr_accessor :stop_script

    def initialize
      @name = :default
      @box = 'jhcook/fedora27'
      @version = '4.13.12.300'
      @ip = '192.168.33.8'
      @start_script = ''
      @stop_script = ''
    end

    def to_vagrant
%Q{
Vagrant.configure(2) do |config|
  config.vm.box = "#{@box}"
  config.vm.box_version = "#{@version}"
  config.vm.network "private_network", ip: "#{@ip}"

  config.vm.provider "virtualbox" do |vb|
   vb.gui = false
   vb.memory = 4096
   vb.customize ["modifyvm", :id, "--cpuexecutioncap", "70"]
   vb.cpus = 2
   vb.name = "#{@name}"
  end
end
}
    end
  end
end
