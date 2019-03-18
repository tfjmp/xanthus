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
    attr_accessor :boxing
    attr_accessor :ssh_username
    attr_accessor :ssh_key_path

    def initialize
      @name = :default
      @box = 'jhcook/fedora27'
      @version = '4.13.12.300'
      @ip = '192.168.33.8'
      @memory = 4096
      @cpus = 2
      @cpu_cap = 70
      @gui = false
      @boxing = nil
      @ssh_username = nil
      @ssh_key_path = nil
    end

    def to_vagrant
script = %Q{
Vagrant.configure(2) do |config|
  config.vm.box = "#{@box}"
  config.vm.box_version = "#{@version}"
  config.vm.network "private_network", ip: "#{@ip}"
}
script += %Q{
  config.ssh.username = "#{@ssh_username}"
} unless ssh_username.nil?
script += %Q{
  config.ssh.private_key_path = "#{@ssh_key_path}"
} unless ssh_key_path.nil?
script += %Q{
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
      return script
    end

    def generate_box config
      return unless !boxing.nil?
      puts 'Generating box...'

      FileUtils.mkdir_p 'boxing'
      Dir.chdir 'boxing' do
        File.open('Vagrantfile', 'w+') do |f|
          f.write(self.to_vagrant)
        end

        script =  Script.new(boxing, config).to_s
        File.open('provision.sh', 'w+') do |f|
          f.write(script)
        end

        system('vagrant', 'up')
        system('vagrant', 'halt')
        system('vagrant', 'package', '--output', "#{name}.box")
        puts "#{name}.box created."
        system('vagrant', 'box', 'add', '--force', "local/#{name}", "#{name}.box")
        system('vagrant', 'destroy', '-f')
        @box = "local/#{name}"
        @version = '0'
      end
    end
  end
end
