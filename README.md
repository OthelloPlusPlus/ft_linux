# ft_linux - Linux From Scratch
ft_linux is a project following the [instructions](LFS-12.2-SYSV-BOOK.pdf) from the [Linux From Scratch (LFS) project](https://www.linuxfromscratch.org/lfs/). It builds a custom Linux system by installing and configuring all packages required for a fully operational Linux environment

Unlike standard Linux installations, this is done without the use of a package manager. All packages are downloaded, unpacked, configured, compiled, and installed as part of the project.

This entire project has been automated via [SSH and shell scripts](Install.sh#L80), allowing scripts to be created and run from a Host Machine. The use of shell scripts enforces rigorous handling of installations. This includes return values, error logs and validation steps, which human operator would skip. While this workflow increased the effort required, it also greatly improved the reliability of the installations and the resulting system. 

ft_linux extends into [Beyond Linux From Scratch](https://www.linuxfromscratch.org/blfs/view/stable/), for which a custom package manager has been created: [shman](/shman/shman.sh#L482) (Shell Package Manager). It is written in shell script for its compatibility with a near empty system. It handles package installation in a similar manner as the installation script for the LFS aspect. However, it also checks for previous installations and resolves dependencies automatically.

The final system includes the packages for LFS, LSB ([Linux Standard Base](https://wiki.linuxfoundation.org/lsb/start)), git, zsh, which, lynx, rust and a basic GNOME graphical environment. And, of course, a generous supply of tears from its developer, which seems to power the entire system.

## Table of Contents

- [Specs](#specs)
- [Host Distribution](#host-distribution)
  - [ArchLinux](#archlinux)
- [Virtual Machine Configuration](#virtual-machine-configuration)
  - [Machine Configuration](#machine-configuration)
- [System Configuration](#system-configuration)
  - [Host System Software](#host-system-software)
- [Linux From Scratch](#linux-from-scratch)
  - [User and Environment](#user-and-environment)
  - [Cross-Toolchain Compilation](#cross-toolchain-compilation)
  - [Preparing Chroot](#preparing-chroot)
  - [Building the System](#building-the-system)
    - [Notable packages](#notable-packages)
  - [System Configuration](#system-configuration-1)
  - [Making LFS Bootable](#making-lfs-bootable)
- [Beyond Linux From Scratch](#beyond-linux-from-scratch)
  - [shman - Shell Package Manager](#shman---shell-package-manager)
- [Evaluation](#evaluation)
- [Sources](#sources)
- [Creator](#creator)

## Specs
<table>
  <thead>
    <tr><th colspan=3>Host System</th></tr>
  </thead>
  <tbody>
    <tr>
      <td colspan=2>Virtual Machine</td>
      <td>VirtualBox 7.0</td>
    </tr>
    <tr>
      <td rowspan=2>Build Environment</td>
      <td>Operating System</td>
      <td>Arch Linux</td>
    </tr>
    <tr>
      <td>Optical Image</td>
      <td>archlinux-2024.11.01-x86_64.iso</td>
    </tr>
  </tbody>
  <thead>
    <tr><th colspan=3>Target System</th></tr>
  </thead>
  <tbody>
    <tr>
      <td colspan=2>Kernel</td>
      <td>6.10.14</td>
    </tr>
    <tr>
      <td colspan=2>Distribution</td>
      <td>Linux From Scratch (custom)</td>
    </tr>
    <tr>
      <td colspan=2>Architecture</td>
      <td>x86_64</td>
    </tr>
    <tr>
      <td colspan=2>Shells</td>
      <td>bash, zsh</td>
    </tr>
    <tr>
      <td colspan=2>Graphical Environment</td>
      <td>GNOME</td>
    </tr>
  </tbody>
</table>

## Host Distribution
In order to create a functioning kernel, certain software requires to be installed. However, in a blank state a proto-OS does not provide the software required to install the software it needs. For example, in order to install a compiler such as GCC, one requires a compiler such as GCC.

Short from installing software manually bit by bit, one can solve this logical paradox by cross-compiling. The approach of cross-compiling means that one functional OS is used to install software onto a different system. In simple terms: Computer A is used to install the basic needs on Computer B.

### ArchLinux
For this project the Host Distribution, which functioned as the source of cross compilation, was ArchLinux. While this Linux Version is more challenging to the user. It is extremely lightweight and customizable. Lacking unnecessary resources for its purposes such as a GUI.

| Resource	| Link / File	|
| :--	| :--	|
| Home	| https://archlinux.org/	|
| Download page	| https://archlinux.org/download/	|
| Wiki	| https://wiki.archlinux.org/title/Main_page	|
| ISO Source	| https://mirror.bouwhuis.network/archlinux/iso/2024.11.01/	|
| ISO Image	| archlinux-2024.11.01-x86_64.iso	|
| Signature	| archlinux-2024.11.01-x86_64.iso.sig	|

The Optical Disk Image (.iso) functions as an unalterable source for the ArchLinux distrubution.

The Signature (.sig) serves as a cryptographic key. When downloaded to the same location as the image, it can be used to verify the image:<br>
```sh
gpg --keyserver-options auto-key-retrieve --verify archlinux-2024.11.01-x86_64.iso.sig
```

## Virtual Machine Configuration
For this project, the entire system was built and configured within a Virtual Machine (VM). The use of a VM is crucial for several reasons. 

Primarily, it creates a completely isolated environment for the new operating system, protecting the host machine from any potential issues or instability during the build process.

Furthermore, this enviroment allows the project owner full root access. Providing access to core systems required for future kernel related projects. And the use of snapshots allows for safe experimentation during these projects.

For purposes of replication, the following VM configuration was used:

<table>
  <thead>
    <tr><th colspan=3>Virtual Machine</th></tr>
  </thead>
  <tbody>
    <tr><td colspan=3>VirtualBox 7.0</td></tr>
    <tr>
      <td rowspan=3>Operating System</td>
      <td>ISO Image</td>
      <td>archlinux-2024.11.01-x86_64.iso</td>
    </tr>
    <tr>
      <td>Type</td>
      <td>Linux</td>
    </tr>
    <tr>
      <td>Version</td>
      <td>Linux 2.6 / 3.x / 4.x / 5.x (64-bit)</td>
    </tr>
    <tr>
      <td rowspan=3>Hardware</td>
      <td>Base Memory</td>
      <td>10244 MB</td>
    </tr>
    <tr>
      <td>Processor(s)</td>
      <td>12</td>
    </tr>
    <tr>
      <td>EFI Enable</td>
      <td>false</td>
    </tr>
    <tr>
      <td rowspan=3>Hard Disk</td>
      <td>Size</td>
      <td>2 TB</td>
    </tr>
    <tr>
      <td>File Type</td>
      <td>.vdi</td>
    </tr>
    <tr>
      <td>Pre-allocate Full Size</td>
      <td>false</td>
    </tr>
  </tbody>
</table>

### Machine Configuration
Once the Virtual Machine is created is requires further configuration to replicate the project structure.

First the Images must be properly configured. `Hard Disk` must be prioritized before the `Optical` in the Boot order. The optical image loads a premade distribution, which is unalterable. Any actual work is stored in the Hard Disk, which must be checked for availability first. Should problems with the Hard Disk arise, the boot order can be changed to access the Optical Disk in order to rebuild the Hard Disk's content.

The project's storage devices were configured to optimize both performance and compatibility within the virtual machine.

The Hard Disk, which contains the entire custom operating system and is critical for the project's performance, was connected to the SATA (Serial Advanced Technology Attachment) controller.  This modern interface was chosen for its superior speed and reliability, which significantly enhances the build and boot times of the operating system.

The Optical Drive, which was only needed during the initial cross-compilation stage to boot the Arch Linux ISO, was connected to the older IDE (Integrated Drive Electronics) controller.  This choice was made for compatibility, as the IDE interface is widely supported by older optical drive images, ensuring a smooth and straightforward initial boot process.

Lastly, a lot of the system configuration was designed on the Host Machine and implemented using ssh and scp on the Virtual Machine. This required network configuration to allow for an ssh connection.

```sh
scp -P [HostPort] [SrcFiles] [Username]@127.0.0.1:[DestDir]
ssh -p [HostPort] [Username]@127.0.0.1 -t "[Command]"
```

<table>
  <thead>
    <tr><th colspan=5>Virtual Machine Configuration</th></tr>
  </thead>
  <tbody>
    <tr>
      <td>System</td>
      <td>Motherboard</td>
      <td>Boot Order</td>
      <td>`Hard Disk` before `Optical`</td>
    </tr>
    <tr>
      <td rowspan=4>Storage</td>
      <td colspan=2 rowspan=2>Contoller: IDE</td>
      <td colspan=2>archlinux-2024.11.01-x86_64.iso</td>
    </tr>
    <tr><td colspan=2>IDE Secondary Device 0</td></tr>
    <tr>
      <td colspan=2 rowspan=2>Controller: SATA</td>
      <td colspan=2>ft_linux.vdi</td>
    </tr>
    <tr><td colspan=2>SATA Port 0</td></tr>
    <tr>
      <td rowspan=7>Network</td>
      <td rowspan=7>Adapter 1</td>
      <td colspan=3>Enable Network Adapter</td>
    </tr>
    <tr>
      <td colspan=3>Attached to: NAT</td>
    </tr>
    <tr>
      <td rowspan=5>Port Forwarding</td>
      <td>Protocol</td>
      <td>TCP</td>
    </tr>
    <tr>
      <td>Host IP</td>
      <td></td>
    </tr>
    <tr>
      <td>Host Port</td>
      <td>2222</td>
    </tr>
    <tr>
      <td>Guest IP</td>
      <td></td>
    </tr>
    <tr>
      <td>Guest Port</td>
      <td>22</td>
    </tr>
  </tbody>
</table>

## System Configuration
In the early stages there is no usable Hard Disk and the system boots using the Optical Image. This image provides a static framework for installing a dynamic system.

At this point the system will be partitioned. These partitions will be formatted and mounted. A basic file structure will be created, and required programs to meet cross-compilation requirements will be installed.

Partitioning is done using [fdisk](InstallArchLinux/InstallArchLinuxRoot.sh#L51). There are 3 [primary partitions](InstallArchLinux/InstallArchLinuxRoot.sh#L26) for `/boot`, `[SWAP]` and `/mnt`. Since the [MBR partition table](https://en.wikipedia.org/wiki/Master_boot_record#Sector_layout) will only allow for 4 primary partitions, the 4th partition is an [extended partition](InstallArchLinux/InstallArchLinuxRoot.sh#L30), which allows for [logical partitions](InstallArchLinux/InstallArchLinuxRoot.sh#L32) to be added for `/mnt/lfs`, `/mnt/lfs/home`, `/mnt/lfs/usr/src`, `/mnt/lfs/opt`.

```sh
> lsblk
NAME   MAJ:MIN FSUSED  SIZE FSUSE% TYPE FSTYPE  LABEL         MOUNTPOINTS
sda      8:0             2T        disk                       
|-sda1   8:1      40M  954M     4% part ext2    /boot         /boot
|-sda2   8:2           3.7G        part swap    swap          [SWAP]
|-sda3   8:3          27.9G        part ext4    / [ArchLinux] 
|-sda4   8:4             1K        part                       
|-sda5   8:5       8G  1.7T     0% part ext4    /             /
|-sda6   8:6     5.5M 46.6G     0% part ext4    /home         /home
|-sda7   8:7   651.1M 46.6G     1% part ext4    /usr/src      /usr/src
`-sda8   8:8   253.3M  9.3G     3% part ext4    /opt          /opt
sr0     11:0           1.1G        rom  iso9660 ARCH_202411   
```
* Please note this configuration displays the final result of the BLFS system. The third primary partition is a relic from the ArchLinux cross-compilation stage. It can be freed using the `fdisk` command, allowing its resources to be allocated elsewhere.

The partitions are then formatted to a suitable file system. `SWAP` is formatted to its dedicated [swap](InstallArchLinux/InstallArchLinuxRoot.sh#L67) file system. `/boot` is formatted to a lighter [ext2](InstallArchLinux/InstallArchLinuxRoot.sh#L66) system and the remaining partitions are formatted to the faster and more modern [ext4](InstallArchLinux/InstallArchLinuxRoot.sh#L68) system.

### Host System Software
As explained earlier, early installations stages of an LFS build requires cross-compilation. The Host system, Arch Linux in this case, will provide the required dependencies for these installations. First however, those need to be ensured to exist. At this stage a simple package manager can be used, however it is required to install its packages on the newly created partitions instead of the live environment provided by the optical image.

This is achieved on Arch Linux using pacman's [pacstrap](InstallArchLinux/InstallArchLinuxRoot.sh#L114), directing it to the `/mnt` on the `sda3` partition, which intended for Arch Linux and not the finalized installation.

```> pacstrap /mnt ...```

## Linux From Scratch
Once our system is configured and our host system meets all its requirements, we can start the Linux From Scratch system. The partitions that the LFS system will be installed on are currently completely empty. Any final installed programs here must be without any link to its original host system.

### User and Environment
Before building any LFS packages, the future environment must be configured. First a [directory structure](InstalLFS/Install2HostSystem.sh#L108) must be created for programs and libraries to be installed in their proper locations. Then a dedicated [user](InstalLFS/Install2HostSystem.sh#L122) must be created which will be used for the building steps. Finally [environment variables](InstalLFS/Install2HostSystem.sh#L136) must be set for this user, so the builds in these stages can be done without variables from the Host System affecting the compilation.

```sh
> whoami
lfs
> env
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/mnt/lfs/tools/bin:/usr/bin
CONFIG_SITE=/mnt/lfs/usr/share/config.site
MAKEFLAGS=-j12
```

### Cross-Toolchain Compilation
While technically not a true form of cross-compilation, since its programs are built using the same architecture. It is often referred to as such in the context of LFS.

A more accurate term would be a **toolchain**. Which refers to the creation of a chain of tools from the Host to the Target, allowing the Host to meet dependency requirements for the Target. Once the Target System can meet its own dependencies, packages are rebuilt to ensure their independency from the Host System.

[As the dedicated user](InstallLFS/Install.sh#L23), using the Host System, [packages are built](InstallLFS/Install3CrossToolchain.sh#L12) to create a Cross-Toolchain. It then uses these packages to [build temporary tools](InstallLFS/Install3CrossToolchain.sh#100). These temporary tools which can be used to build the LFS packages without any resources from the Host System. It should be noted that Binutils and GCC are built [twice](InstallLFS/Install3CrossToolchain.sh#117) in these stages, so their extensive dependency requirements can be met. None of these temporary tools 'survive' up to the end of the LFS project.

### Preparing Chroot
With the temporary tools setup the system needs to be prepared to build the LFS packages. First directory ownership must be [changed to root](InstallLFS/Install3_2PrepareChroot.sh#L13). Then mountpoints must be [set up](InstallLFS/Install3_2PrepareChroot.sh#L24) to provide the chrooted environment with access to devices, processes, and system information.

Using chroot one can adjust what directory is used as the root directory. This allows packages to be built and installed in a simulated LFS environment, completely independent from the Host System.

```sh
> chroot	"$LFS" /usr/bin/env -i	\
			HOME=/root	\
			TERM="$TERM"	\
			PS1='(lfs chroot) \u:\w\$ '	\
			PATH=/usr/bin:/usr/sbin	\
			MAKEFLAGS="-j$(nproc)"	\
			TESTSUITEFLAGS="-j$(nproc)"	\
			/bin/bash --login
```

### Building the System
Using chroot the LFS system can finally be configured and built. The [directory layout](InstallLFS/Install4BuildLFS.sh#L28) can be formed. [Important files](InstallLFS/Install4BuildLFS.sh#L53) and [symbolic links](InstallLFS/Install4BuildLFS.sh#L57) can be created. And a few final [Temporary Tools](InstallLFS/Install4BuildLFS.sh#L18) can be built.

Then finally [dozens of packages](InstallLFS/Install4BuildLFS.sh#L154) can be built and configured together forming the core LFS packages. These are built in a carefully curated order to meet all their dependencies, and eventually overwrite the temporary toolchain entirely.

#### Notable packages
While many packages are crucial or essential to meet dependency requirements. A few deserve special note:

**Linux**<br>
This package contains the actual kernel, which runs the OS by providing process management, memory management, device drivers, and system calls. Kernel modules can be added either automatically by **udev** or manually using `modprobe` to extend the kernel’s functionality.

**Udev**<br>
Part of the **SystemD** package, udev manages device nodes and hotplug events. When devices are detected, it triggers the kernel module loader `modprobe` to load the appropriate modules so the kernel can interact with hardware.

**GRUB**<br>
This bootloader runs during the bootup process and orchestrates the bootup procedures for different kernels. It allows the selection of different kernels and passing kernel parameters at boot. Doing so, for example, it can provide graphical and non-graphical menu options during boot selection.

### System Configuration
Once all the required packages are installed the system requires several steps to be configured properly.

**Device Manager**<br>
A device manager monitors hardware devices and dynamically creates device nodes in /dev, In this scope, **Udev** performs this role. It does require a set of rules to be set so it knows how to set permissions, names or trigger scripts when devices are added or removed. It does provide its [own script](InstallLFS/Install4BuildLFS.sh#L315) to generate a default ruleset.

```sh
> grep -vE "^(#|$)" /etc/udev/rules.d/*.rules  

/etc/udev/rules.d/55-lfs.rules:SUBSYSTEM=="rtc", ACTION=="add", MODE="0644", RUN+="/etc/rc.d/init.d/setclock start"
/etc/udev/rules.d/55-lfs.rules:KERNEL=="rtc", ACTION=="add", MODE="0644", RUN+="/etc/rc.d/init.d/setclock start"
/etc/udev/rules.d/70-persistent-net.rules:SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="08:00:27:05:4a:b7", ATTR{dev_id}=="0x0", ATTR{type}=="1", NAME="enp0s3"
```

**Network Configuration**<br>
To establish a functional and stable network connection several files have to be configured.

The network must be [configured](InstallLFS/Install4BuildLFS.sh#L348) so can connect to other devices.
The interface name is set to a predicable naming structure, `en` for Ethernet. `p0` for the PCI bus number and `s3` for its slot number.
The `IP` address is set to define the address on the local network, the `GATEWAY` is set to the address of the router so other networks can be reached.

```sh
> grep -vE "^(#|$)" /etc/sysconfig/ifconfig.enp0s3

ONBOOT=yes
IFACE=enp0s3
SERVICE=ipv4-static
IP=10.0.2.15
GATEWAY=10.0.2.2
PREFIX=24
BROADCAST=10.0.2.255
```

When navigating the internet, domain names in URLs must be translated into their associated IP addresses. This process is handled by DNS (Domain Name System) resolvers, which are provided by various organizations and maintain registries of registered domains and their corresponding IP addresses.  

The system must be [configured](InstallLFS/Install4BuildLFS.sh#L359) to know which DNS resolvers to query. Multiple resolvers can be listed, and they are queried in order until one responds. In this configuration, the first address points to a local resolver (127.0.0.53), which is not currently implemented but left in place for future use. The remaining addresses are chosen primarily for physical proximity (low ping) and secondarily for their reliability.

```sh
> grep -vE "^(#|$)" /etc/resolv.conf

nameserver 127.0.0.53
nameserver 9.9.9.9
nameserver 145.100.100.100
nameserver 80.80.80.80
nameserver 1.1.1.1
nameserver 208.67.222.222
nameserver 8.8.8.8
option edns0
```

Lastly, a [hostname](InstallLFS/Install4BuildLFS.sh#L387) must be set in `/etc/hostname` so the system can be identified on the network. And the [hosts](InstallLFS/Install4BuildLFS.sh#L391) are mapped in the `/etc/hosts` file for local name resolution, allowing the system to resolve certain addresses without querying a DNS server.

**Initializtion Configuration**<br>
During kernel initialization the first run program is **init**. This reads the `/etc/inittab` file for the systems most basic configuration. It is [configured](InstallLFS/Install4BuildLFS.sh#L409) to default to allow for a Multi User mode (5). To call the bootscript `/etc/rc.d/init.d/rc` for single user (S) initialization. And again for the appropriate runlevel (0-6). It also ensures a terminal interface exists (tty) and restarts should it crash. Finally it has an extra identifier (dm:5:) which runs the X Display Manager (xdm), allowing runlevel 5 to become provide a Graphical User Interface.

```sh
> grep -vE "^(#)" /etc/inittab

id:5:initdefault:

si::sysinit:/etc/rc.d/init.d/rc S

l0:0:wait:/etc/rc.d/init.d/rc 0
l1:S1:wait:/etc/rc.d/init.d/rc 1
l2:2:wait:/etc/rc.d/init.d/rc 2
l3:3:wait:/etc/rc.d/init.d/rc 3
l4:4:wait:/etc/rc.d/init.d/rc 4
l5:5:wait:/etc/rc.d/init.d/rc 5
l6:6:wait:/etc/rc.d/init.d/rc 6

ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now

su:S06:once:/sbin/sulogin
s1:1:respawn:/sbin/sulogin

1:2345:respawn:/sbin/agetty --noclear tty1 9600
2:2345:respawn:/sbin/agetty tty2 9600
3:2345:respawn:/sbin/agetty tty3 9600
4:2345:respawn:/sbin/agetty tty4 9600
5:2345:respawn:/sbin/agetty tty5 9600
6:2345:respawn:/sbin/agetty tty6 9600

dm:5:respawn:/etc/rc.d/init.d/xdm
```

**System Clock**<br>
The system clock is [configured](InstallLFS/Install4BuildLFS.sh#L442) to the appropriate timezone.

**Console**<br>
The console is [configured](InstallLFS/Install4BuildLFS.sh#L454) to allow Unicode characters and use a commonly used and legible font.

**System Locale**<br>
A basic global shell initialization profile is [created](InstallLFS/Install4BuildLFS.sh#L480) in `/etc/profile`. It sets essential environment variables such as `LANG` and `PATH` and ensures that additional configuration scripts in `/etc/profile.d/` are sourced automatically for all users.

**Input**<br>
The terminal is [configured](InstallLFS/Install4BuildLFS.sh#L501) to certain behavior given certain inputs. For example `home` sets the cursor to the beginning of the line.  

**Shells**<br>
The available shells are [listed](InstallLFS/Install4BuildLFS.sh#L550) for programs to query.

### Making LFS Bootable
With all system requirements met it is time for the final steps.

First, the `/etc/fstab` has to be [created](/InstallLFS/Install4BuildLFS.sh#L651) which specifies the mountpoints during bootup.

Then the actual Kernel Package can finally be [configured](/InstallLFS/UtilInstallPackages.sh#L4926) to meet the users requirements. Please take care to carefully consider these options when installing. While it is possible to change them later, they are essential to the Kernels functionality, future packages might rely on proper settings, and it takes substantial time to reinstall the Kernel.

Finally, **GRUB** can be [configured](/InstallLFS/Install4BuildLFS.sh#L681) to use the newly created kernel to during the boot process. It is possible to create multiple `menuentry`'s, allowing for variations on the same kernel or even different kernels within the same system.

```sh
> grep -Ev "^(#|$)" /boot/grub/grub.cfg 
set default=0
set timeout=5
insmod part_gpt
insmod ext2
set root=(hd0,1)
menuentry "GNU/Linux, Linux 6.10.14-ohengelm (GNOME)" {
        linux   /vmlinuz-6.10.14-ohengelm   root=/dev/sda5  ro 5
}
menuentry "GNU/Linux, Linux 6.10.14-ohengelm (Shell)" {
        linux   /vmlinuz-6.10.14-ohengelm   root=/dev/sda5  ro 3
}
```

## Beyond Linux From Scratch
Once a Linux Kernel has been installed and is running, it can be extensively expanded upon, depending on the user's needs.

One such addition would be installing packages to conform to the [Linux Standard Base](https://wiki.linuxfoundation.org/lsb/start). The LSB specifies system requirements a Linux distribution must meet to qualify for certification. It aims to increase compatibility between distributions and, by extension, the compatibility for Linux software. Many commonly used distributions have largely ignored it. Consequently, the LSB has not been updated in years and could be considered deprecated. However, it remains a useful reference for essential packages.

Other user-defined additions in this project include **OpenSSH**, **Wget**, **cURL**, **Git**, **Zsh**, **Which**. As well as expansions to the **Python modules** and **C Libraries**. The greatest addition however was a Graphical User Interface (GUI) in the form of **GNOME** (along with nearly __200__ essential dependencies).

### shman - Shell Package Manager
To streamline the installation process and automate the dependency "rabbit hole" **shman** (Shell Package Manager) was created specifically for this BLFS project. This package manager consists of a network of shell scripts which can locate and execute each other as required.

shman is started by the command `/usr/src/shamn/shamn.sh` and runs using a [terminal based user interface](/shman/shman.sh#L482). Main packages have been implemented directly by the developer, but different starting points can be added by any user by altering or adding the following line in the shman.sh file:
```sh
source "$SHMAN_SDIR/<package>.sh" && Install<package>;
```
While it is possible to directly call the script files for the desired installations. this is **strongly discouraged**. The shman.sh file also handles variables the package manager requires to safely operate.

Each package installation script contains information on its [download source](/shman/Utils/_Template.sh#L13), the expected [programs and binaries](/shman/Utils/_Template.sh#29) to be installed and the [dependencies](/shman/Utils/_Template.sh) the package has, tiered into Required, Recommended, and Optional. Each with different levels of error handling: 
* **Required**: Stops the stage of installation.
* **Recommended**: Halts the installation. Allowing the user to decide whether to make adjustments, interrupt the process, or continue regardless.
* **Optional**: Ignores the error and continues.

Should a user desire to add a package installation, for example to address a missing dependency, the [Creation Script](/shman/Utils/CreatePackageScript.sh) can be used with the following command:
```sh
/usr/src/shman/Utils/CreatePackageScript.sh "<NewPackage>"
```
This will generate a new package script. While it provides a generic installation layout, this requires further user modification, for each package has its own source and its own [installation sequence](/shman/Utils/_Template.sh#L108).

## Evaluation

**Score:** 108%
> "very well done on this project, you clrearly took the time to thuroughly understand the intricacies of the linux kernel. well explained. functional and extensively tested. and of course VERY FANCY. the installation of the screen package had some issues, but based on my assessment it was clear that this was not an issue with your approach to package installation, but instead an issue with the packege configuration of screen it self. "
> 		- [Alexander Von Benckendorff](https://github.com/alexbenkey/)

**Score:** 108%
> "As always,, you made an amazing, comprehensive, over-the-top project! Your explanations are great and show that you really understand what you're doing. The UI choices you've made and the convenience (for both yourself and the spectator) of the extra tools you have created make for a really great experience. Good Work & Good Luck!"
> 		- Fellow student

**Score:** 108%
> "This is the kind of project that makes people stop and say, "Okay, this person knows what they’re doing". The enormous amount of work you put into scripting is crystal clear perfectly executed, with automation and customized features that make it a joy to use.The double(sometimes  triple )checks, paired with user-friendly logs and beautifully displayed interaction info, show just how much care went into every detail. Extra kudos for going beyond expectations,you’ve made something truly outstanding. Bravo!"
> 		- [Emanuela Licameli](https://github.com/MagicEmy)

## Sources
[Linux From Scratch](https://www.linuxfromscratch.org/lfs/)<br>
[Beyond Linux From Scratch](https://www.linuxfromscratch.org/blfs/view/stable/)

[Arch Linux](https://wiki.archlinux.org/title/Main_page)

[Linux Standard Base](https://wiki.linuxfoundation.org/lsb/start) ([wikipedia](https://en.wikipedia.org/wiki/Linux_Standard_Base))<br>
[POSIX](https://pubs.opengroup.org/onlinepubs/9699919799/) - Portable Operating System Interface ([wikipedia](https://en.wikipedia.org/wiki/POSIX))<br>
[Autotools](https://www.gnu.org/software/automake/manual/html_node/index.html#SEC_Contents)<br>
[Master Boot Record](https://en.wikipedia.org/wiki/Master_boot_record#Sector_layout)

<details style="border: 1px solid black; padding: 0.5em;">
<summary>
Shell<br>
A generated overview of shell flags and options. (Not part of the final project, but too valuable to remove)
</summary>

```console
echo $-
569XZims
```

https://tldp.org/LDP/abs/html/options.html

<table>
  <thead>
    <tr>
      <th>Option</th>
      <th>Description</th>
      <th>shell</th>
      <th>ssh</th>
      <th>su</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>#</td>
      <td><b>Bash Compatibility</b><br>
          Indicates which Bash version's features are active.</td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>i</td>
      <td><b>Interactive Shell</b><br>
          Allows input and output directly from the user.</td>
      <td>set -i</td>
      <td></td>
      <td>su -</td>
    </tr>
    <tr>
      <td>m</td>
      <td><b>Job Control</b><br>
          Allows background jobs and job suspension.</td>
      <td>set -m</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>B</td>
      <td><b>Brace Expansion</b><br>
          Allows the use of brace expansion (e.g., <code>{a,b}</code>).</td>
      <td>set -B</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>H</td>
      <td><b>Command History Expansion</b><br>
          Allows expansion of <code>!</code> to previous commands.</td>
      <td>set -H</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>p</td>
      <td><b>Privileged Mode</b><br>Disables user-specific shell settings.</td>
      <td>set -p</td>
      <td>-p</td>
      <td>-p</td>
    </tr>
  </tbody>
</table>

<table>
  <thead>
    <tr>
      <th>Option</th>
      <th>Description</th>
      <th>shell</th>
      <th>ssh</th>
      <th>su</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td><b>Posix Mode</b><br>Enables POSIX compliance.</td>
      <td>set -o posix</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>5</td>
      <td><b>Debugger Support</b><br>Specific to shell debugging; not commonly used.</td>
      <td>set -o debug</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>6</td>
      <td><b>Extended Glob</b><br>Allows extended pattern matching.</td>
      <td>shopt -s extglob</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>9</td>
      <td><b>Pipefail</b><br>Returns status of the last command in a pipeline that failed.</td>
      <td>set -o pipefail</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>B</td>
      <td><b>Brace Expansion</b><br>Enables brace expansion like <code>{a,b}</code>.</td>
      <td>set -B</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>J</td>
      <td><b>Multi-Line Comments</b><br>Allows multi-line comments in scripts.</td>
      <td>set -J</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N</td>
      <td><b>Nullglob</b><br>Expands patterns to nothing if no matches are found.</td>
      <td>shopt -s nullglob</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>R</td>
      <td><b>Restricted Shell</b><br>Limits functionality to enhance security.</td>
      <td>set -r</td>
      <td>-r</td>
      <td>-r</td>
    </tr>
    <tr>
      <td>X</td>
      <td><b>Debug Mode</b><br>Prints commands before executing them.</td>
      <td>set -x</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>Z</td>
      <td><b>Custom Option</b><br>Shell-specific behavior; varies.</td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>g</td>
      <td><b>Global Alias</b><br>Allows creation of global aliases.</td>
      <td>set -g</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>i</td>
      <td><b>Interactive Shell</b><br>Enables direct input/output interaction.</td>
      <td>set -i</td>
      <td></td>
      <td>su -</td>
    </tr>
    <tr>
      <td>k</td>
      <td><b>Export Options</b><br>Exports all function arguments.</td>
      <td>set -k</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>l</td>
      <td><b>Login Shell</b><br>Configures shell as a login session.</td>
      <td>bash -l</td>
      <td>-l</td>
      <td>-l</td>
    </tr>
    <tr>
      <td>m</td>
      <td><b>Job Control</b><br>Enables job control features.</td>
      <td>set -m</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>s</td>
      <td><b>Read Commands from stdin</b><br>Reads commands directly from input.</td>
      <td>set -s</td>
      <td></td>
      <td></td>
    </tr>
  </tbody>
</table>
</details>

## Creator
Othello<br>
[<img alt="LinkedIn" height="32px" src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" target="_blank" />](https://github.com/OthelloPlusPlus)
[<img alt="LinkedIn" height="32px" src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/LinkedIn_logo_initials.png/600px-LinkedIn_logo_initials.png" target="_blank" />](https://nl.linkedin.com/in/orlando-hengelmolen)
