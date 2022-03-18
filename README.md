# Xanthus: Automated Reproducible Data Generation for Evaluating Intrusion Detection Systems

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xanthus'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install xanthus

## Usage

```
xanthus version | return Xanthus version number.
xanthus dependencies | installation instructions for system dependencies.
xanthus init <project name> | initialize a new project.
xanthus run | run .xanthus file in the current folder.
```

## Development

To add more features in `Xanthus`,
clone this repository
```
git clone https://github.com/tfjmp/xanthus
cd xanthus
```
and build the gem by running 
```
gem build xanthus
```
To install this gem locally on your machine, you can also run
```
gem install xanthus
```
After you add a new feature (and test it yourself), you can release a new version of `Xanthus`.
First, please update the version number in `lib/xanthus/version.rb`, tag the repository `git tag -a x.x.x -m 'x.x.x'`, and push the tag `git push --tags`.
Then you can run 
```
gem push xanthus-x.x.x.gem
```
This last step publishes the gem at [https://rubygems.org/gems/xanthus](https://rubygems.org/gems/xanthus).

### Contribution

We welcome bug reports and pull requests on [GitHub](https://github.com/tfjmp/xanthus).

### License

This gem is available as an open source project under the [MIT License](https://opensource.org/licenses/MIT).

### Issues and Solutions with VirtualBox
VirtualBox Guest Additions is not as well designed as we may hope. If you encountered the following error:
```
Vagrant was unable to mount VirtualBox shared folders. This is usually
because the filesystem "vboxsf" is not available. This filesystem is
made available via the VirtualBox Guest Additions and kernel module.
Please verify that these guest additions are properly installed in the
guest. This is not a bug in Vagrant and is usually caused by a faulty
Vagrant box. For context, the command attempted was:

mount -t vboxsf -o uid=900,gid=900 vagrant /vagrant

The error output from the command was:

/sbin/mount.vboxsf: mounting failed with the error: No such device
```
It is most likely the fault of incompatible GA between the VM and the host. Even though the script might have stop, the VM is still booted. You can `vagrant ssh` into the VM and manually input the following two commands:
```
sudo apt-get -y install dkms build-essential linux-headers-$(uname -r) virtualbox-guest-additions-iso
sudo /opt/VBoxGuestAdditions*/init/vboxadd setup
```
After this, you may encounter this error:
```
...
==> default: Machine booted and ready!
[default] GuestAdditions seems to be installed (6.0.20) correctly, but not running.
bash: line 4: setup: command not found
==> default: Checking for guest additions in VM...
The following SSH command responded with a non-zero exit status.
Vagrant assumes that this means the command failed!

 setup

Stdout from the command:



Stderr from the command:

bash: line 4: setup: command not found
```
Please add the following into the Vagrant script:
```
if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false  
end
```
