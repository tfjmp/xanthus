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

    def generate_box config
      return unless !boxing.nil?
      puts 'Generating box...'

      FileUtils.mkdir_p 'boxing'
      Dir.chdir 'boxing' do
        File.open('Vagrantfile', 'w+') do |f|
          f.write(self.to_vagrant)
        end

        script = ''
        boxing.each do |t|
          v = eval(config.scripts[t])
          if v.kind_of?(Array)
            v.each do |w|
              script+=w+"\n"
            end
          else
            script+=v
          end
        end

        script_to_clean = script
        script = ''
        script_to_clean.each_line do |s|
          script += s.strip + "\n" unless s=="\n"
        end
        script = script.gsub "\n\n", "\n"

        File.open('provision.sh', 'w+') do |f|
          f.write(script)
        end

        system('vagrant', 'up')
        system('vagrant', 'halt')
        system('vagrant', 'package', '--output', "#{name}.box")
        puts "#{name}.box created."
      end
    end
  end
end
