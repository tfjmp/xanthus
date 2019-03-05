module Xanthus
  class VirtualMachine
    attr_accessor :name
    attr_accessor :box
    attr_accessor :version
    attr_accessor :cpus
    attr_accessor :cpu_cap
    attr_accessor :memory
    attr_accessor :ip
    attr_accessor :gui

    def initialize
      @name = :default
      @box = 'jhcook/fedora27'
      @version = '4.13.12.300'
      @ip = '192.168.33.8'
      @memory = 4096
      @cpus = 2
      @cpu_cap = 70
      @gui = false
    end

    def to_vagrant
%Q{
Vagrant.configure(2) do |config|
  config.vm.box = "#{@box}"
  config.vm.box_version = "#{@version}"
  config.vm.network "private_network", ip: "#{@ip}"

  config.vm.provider "virtualbox" do |vb|
   vb.gui = #{@gui}
   vb.memory = #{@memory}
   vb.customize ["modifyvm", :id, "--cpuexecutioncap", "#{@cpu_cap}"]
   vb.cpus = #{@cpus}
   vb.name = "#{@name}"
  end
  config.vm.provision "shell", path: "provision.sh"
end
}
    end
  end
end
