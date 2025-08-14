#! /bin/bash

source Utils.sh
source UtilInstallPackages.sh

# =====================================||===================================== #
#																			   #
#								   Chapter 7								   #
#			Entering Chroot and Building Additional Temporary Tools			   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

Install7()
{
	Install7CreateDirectories;
	Install7CreatingEssentialFilesAndSymlinks;

	InstallGettext_TT;
	InstallBison_TT;
	InstallPerl_TT;
	InstallPython_TT;
	InstallTexinfo_TT;
	InstallUtilLinux_TT;

	Install7Cleanup;
}

Install7CreateDirectories()
{
	# Create some root-level directories {boot,home,mnt,opt,srv}
	mkdir -pv /{boot,home,mnt,opt,srv};

	# Create the required set of subdirectories below the root-level
	mkdir -pv /etc/{opt,sysconfig}
	mkdir -pv /lib/firmware
	mkdir -pv /media/{floppy,cdrom}
	mkdir -pv /usr/{,local/}{include,src}
	mkdir -pv /usr/lib/locale
	mkdir -pv /usr/local/{bin,lib,sbin}
	mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
	mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
	mkdir -pv /usr/{,local/}share/man/man{1..8}
	mkdir -pv /var/{cache,local,log,mail,opt,spool}
	mkdir -pv /var/lib/{color,misc,locate}

	ln -sfv /run /var/run
	ln -sfv /run/lock /var/lock

	install -dv -m 0750 /root
	install -dv -m 1777 /tmp /var/tmp
}

Install7CreatingEssentialFilesAndSymlinks()
{
	# Create a symbolic link for mounts
	echo "Create a symbolic link for mounts"
	ln -sv /proc/self/mounts /etc/mtab

	# Create a basic /etc/hosts file
	EchoInfo "# Create a basic /etc/hosts file"
	cat > /etc/hosts << EOF
127.0.0.1 localhost $(hostname)
::1       localhost
EOF

	# Create the /etc/passwd file
	EchoInfo "# Create the /etc/passwd file"
	cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF

	# Create the /etc/group file
	EchoInfo "# Create the /etc/group file"
	cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
uuidd:x:80:
wheel:x:97:
users:x:999:
nogroup:x:65534:
EOF

	# Defining locale
	EchoInfo "# Defining locale"
	localedef -i C -f UTF-8 C.UTF-8

	# Creating temporary 'tester' user
	EchoInfo "# Creating temporary 'tester' user"
	echo "tester:x:101:101::/home/tester:/bin/bash" >> /etc/passwd
	echo "tester:x:101:" >> /etc/group
	install -o tester -d /home/tester

	# Create log files
	EchoInfo "# Create log files"
	touch /var/log/{btmp,lastlog,faillog,wtmp}
	chgrp -v utmp /var/log/lastlog
	chmod -v 664 /var/log/lastlog
	chmod -v 600 /var/log/btmp

	# group name resolution
	EchoInfo "# group name resolution"
	echo -e	"Please ${C_ORANGE}exit and re-enter${C_RESET} chroot to fix ${CB_BLACK}(lfs chroot) I have no name!:/# ${C_RESET}"
}

Install7Cleanup()
{
	# Remove installed documentation files
	EchoInfo "# Remove installed documentation files"
	rm -rf /usr/share/{info,man,doc}/*;

	# Remove libtool .la files
	EchoInfo "# Remove libtool .la files"
	find /usr/{lib,libexec} -name \*.la -delete

	# Remove /tools
	EchoInfo "# Remove /tools"
	rm -rf /tools
}

# =====================================||===================================== #
#																			   #
#								   Chapter 8								   #
#						Installing Basic System Software					   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

Install8AllBinaries()
{
	CheckMountpoints || return $?;

	for (( i=3; i<=82; i++ )); do
		case $i in 
			3) InstallMan;; 		# 8.3
			4) InstallIanaEtc;; 	# 8.4
			5) InstallGlibc;; 		# 8.5
			6) InstallZlib;; 		# 8.6
			7) InstallBzip2;; 		# 8.7
			8) InstallXz;; 			# 8.8
			9) InstallLz4;; 		# 8.9
			10) InstallZstd;; 	# 8.10
			11) InstallFile;; 		# 8.11
			12) InstallReadline;; 	# 8.12
			13) InstallM4;; 			# 8.13
			14) InstallBc;; 			# 8.14
			15) InstallFlex;; 		# 8.15
			16) InstallTcl;; 		# 8.16
			17) InstallExpect;; 		# 8.17
			18) InstallDejaGNU;; 	# 8.18
			19) InstallPkgconf;; 	# 8.19
			20) InstallBinutils;; # 8.20
			21) InstallGMP;; 		# 8.21
			22) InstallMPFR;; 		# 8.22
			23) InstallMPC;; 		# 8.23
			24) InstallAttr;; 		# 8.24
			25) InstallAcl;; 		# 8.25
			26) InstallLibcap;; 		# 8.26
			27) InstallLibxcrypt;; 	# 8.27
			28) InstallShadow;; 		# 8.28
			29) InstallGcc;; 		# 8.29
			30) InstallNcurses;; # 8.30
			31) InstallSed;; 		# 8.31
			32) InstallPsmisc;; 		# 8.32
			33) InstallGettext;; 	# 8.33
			34) InstallBison;; 		# 8.34
			35) InstallGrep;; 		# 8.35
			36) InstallBash;; 		# 8.36
			37) InstallLibtool;; 	# 8.37
			38) InstallGDBM;; 		# 8.38
			39) InstallGperf;; 		# 8.39
			40) InstallExpat;; 	# 8.40
			41) InstallInetutils;; 	# 8.41
			42) InstallLess;; 		# 8.42
			43) InstallPerl;; 		# 8.43
			44) InstallXMLParser;; 	# 8.44
			45) InstallIntltool;; 	# 8.45
			46) InstallAutoconf;; 	# 8.46
			47) InstallAutomake;; 	# 8.47
			48) InstallOpenSSL;; 	# 8.48
			49) InstallKmod;; 		# 8.49
			50) InstallElfutils;; # 8.50
			51) InstallLibffi;; 		# 8.51
			52) InstallPython;; 		# 8.52
			53) InstallFlitCore;; 	# 8.53
			54) InstallWheel;; 		# 8.54
			55) InstallSetuptools;; 	# 8.55
			56) InstallNinja;; 		# 8.56
			57) InstallMeson;; 		# 8.57
			58) InstallCoreutils;; 	# 8.58
			59) InstallCheck;; 		# 8.59
			60) InstallDiffutils;; # 8.60
			61) InstallGawk;; 		# 8.61
			62) InstallFindutils;; 	# 8.62
			63) InstallGroff;; 		# 8.63
			64) InstallGRUB;; 		# 8.64
			65) InstallGzip;; 		# 8.65
			66) InstallIPRoute2;; 	# 8.66
			67) InstallKbd;; 		# 8.67
			68) InstallLibpipeline;; # 8.68
			69) InstallMake;; 		# 8.69
			70) InstallPatch;; 	# 8.70
			71) InstallTar;; 		# 8.71
			72) InstallTexinfo;; 	# 8.72
			73) InstallVim;; 		# 8.73
			74) InstallMarkupSafe;; 	# 8.74
			75) InstallJinja2;; 		# 8.75
			76) InstallUdev;; 		# 8.76
			77) InstallManDB;; 		# 8.77
			78) InstallProcpsNg;; 	# 8.78
			79) InstallUtilLinux;; 	# 8.79
			80) InstallE2fsprogs;; # 8.80
			81) InstallSysklogd;; 	# 8.81
			82) InstallSysVinit;; 	# 8.82
		esac
		if [ $? -gt 0 ]; then
			PressAnyKeyToContinue;
			LocalCommand="echo \"Failed to create for Chapter 8.$i. Stopped\"";
			return 1;
		fi
	done

	CleanupAfter8;
}

CheckMountpoints()
{
	for CheckMount in "/dev" "/dev/pts" "/proc" "/sys" "/run" "/dev/shm"; do
		mountpoint -q "$CheckMount" || { 
			local ReturnValue=$?
			LocalCommand="echo \"CRUCIAL: ($ReturnValue $CheckMount): Mountpoints are not set! Did you reboot?\""; 
			return $ReturnValue; 
		};
	done
	return 0;
}

CleanUpAfter8()
{
	RemovePackageDirectories;

	local TempAttempt=0;
	while true; do
		clear;
		echo -n	"Cleanup [y/n]? ";
		GetKeyPress;
		case $input in
			y)	rm -rf /tmp/{*,.*};
				find /usr/lib /usr/libexec -name \*.la -delete;
				find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf;
				userdel -r tester;;
			n)	return ;;
			*)	(( TempAttempt = TempAttempt +1 ));
				if [ $TempAttempt -gt 3 ]; then
					EchoError	"Too many incorrect Keypresses. Not cleaning";
					return ;
				fi ;;
		esac
	done
}

# =====================================||===================================== #
#																			   #
#								   Chapter 9								   #
#							  System Configuration							   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

Configure9System()
{
	CheckMountpoints || return $?;

	for (( i=0; i<=6; i++ )); do
		case $i in 
			0)	InstallLFSBootscript;;
			1)	ManageDevices;;
			2)	GeneralNetworkConfiguration;;
			3)	SystemVBootscript;;
			4)	ConfigureSystemLocale;;
			5)	ReadlineLibraryConfigurationFile;;
			6)	ShellValidationFile;;
		esac
		if [ $? -gt 0 ]; then
			EchoError "Chapter 9 failed ($?) on step $i";
			PressAnyKeyToContinue;
			return ;
		fi
	done
}

# 9.4
ManageDevices()
{
	bash /usr/lib/udev/init-net-rules.sh

	EchoInfo "--- Custom Udev Rules ---"
	EchoInfo '/etc/udev/rules.d/70-persistent-net.rules'
	if [ -z "$NameLength" ]; then
		NameLength=13;
	fi

	for pair in $(grep "^SUBSYSTEM" "/etc/udev/rules.d/70-persistent-net.rules"); do
		local LocalKey="$(echo \"$pair\" | cut -d= -f1 | tr -d '"')";
		local LocalValue="$(echo \"$pair\" | cut -d= -f2- | tr -d '"=,')";
		case $LocalKey in
			SUBSYSTEM) 		if [ "$LocalValue" == "net" ]; 	then printf "$C_LGREEN"; else printf "$C_LRED"; fi ;;
			ACTION) 		if [ "$LocalValue" == "add" ]; 	then printf "$C_LGREEN"; else printf "$C_LRED"; fi ;;
			DRIVERS) 		if [ "$LocalValue == ""?*" ]; 	then printf "$C_LGREEN"; else printf "$C_LRED"; fi ;;
			ATTR{type}) 	if [ "$LocalValue" == "1" ]; 	then printf "$C_LGREEN"; else printf "$C_LRED"; fi ;;
			NAME)			IFaceName=$LocalValue; printf "$C_UNDL";;
		esac
		printf	"${C_BOLD}%-${NameLength}s${C_RESET} %-s\n" "$LocalKey" "$LocalValue";
	done
	PressAnyKeyToContinue;
}

# 9.5
GeneralNetworkConfiguration()
{
	IFaceName=enp0s3;
	# ifConfigIP="$(ip addr show enp0s3 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)"
	# ifConfigPREFIX="$(ip addr show enp0s3 | grep 'inet ' | awk '{print $2}' | cut -d/ -f2)"
	# ifConfigBORADCAST="$(ip addr show enp0s3 | grep 'inet ' | awk '{print $4}')"
	# IfConfigGATEWAY="$(ip route | grep default | awk '{ print $3}')"
	EchoInfo	"/etc/sysconfig/ifconfig.enp0s3"
	cd /etc/sysconfig/
cat > ifconfig.${IFaceName:-enp0s3} << EOF
ONBOOT=yes
IFACE=${IFaceName:-enp0s3}
SERVICE=ipv4-static
IP=10.0.2.15
GATEWAY=10.0.2.2
PREFIX=24
BROADCAST=10.0.2.255
EOF

	EchoInfo	"/etc/resolv.conf"
	cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf
domain codam.nl

# DNS resolution
# Local Caching Resolver
nameserver 127.0.0.53
# Quad9
nameserver 9.9.9.9
# Surfnet (NL)
nameserver 145.100.100.100
# Freenom World
nameserver 80.80.80.80
# Cloudflare
nameserver 1.1.1.1
# OpenDNS
nameserver 208.67.222.222
# Google DNS
nameserver 8.8.8.8

option edns0

# End /etc/resolv.conf
EOF

	EchoInfo	"/etc/hostname"
	StoredHostName="ohengelm";
	EchoInfo	"hostname: $StoredHostName";
	echo "$StoredHostName" > /etc/hostname;

	EchoInfo	"/etc/hosts"
	StoredFQDN="$StoredHostName.local";
	cat > /etc/hosts << EOF
# Begin /etc/hosts
# IP_address    myhost.example.org        aliases
127.0.0.1       localhost.localdomain     localhost
127.0.1.1       $StoredFQDN            $StoredHostName
# 192.168.1.1   $StoredFQDN            $StoredHostName
::1             localhost                 ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
# End /etc/hosts
EOF
}

# 9.6
SystemVBootscript()
{
	# 9.6.2. Configuring SysVinit
	EchoInfo	"/etc/inittab";
	cat > /etc/inittab << "EOF"
# Begin /etc/inittab

id:3:initdefault:

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

# End /etc/inittab
EOF

	# 9.6.4. Configuring the System Clock
	EchoInfo	"/etc/sysconfig/clock";
	cat > /etc/sysconfig/clock << "EOF"
# Begin /etc/sysconfig/clock

UTC=1

# Set this to any options you might need to give to hwclock,
# such as machine hardware clock type for Alphas.
CLOCKPARAMS=

# End /etc/sysconfig/clock
EOF

	# 9.6.5. Configuring the Linux Console
	EchoInfo	"/etc/sysconfig/console";
	cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

UNICODE="1"
FONT="Lat2-Terminus16"

# End /etc/sysconfig/console
EOF
}

ConfigureSystemLocale()
{
	EchoInfo	"System Locale";
	LocaleName=$(locale -a | grep "^en_US" | grep "utf");
	printf	"%-17s %s\n" "Name:" "$LocaleName";
	printf	"%-17s " "Language:";	LC_ALL="$LocaleName" locale language || PressAnyKeyToContinue;
	printf	"%-17s " "Character Map:";	LC_ALL="$LocaleName" locale charmap || PressAnyKeyToContinue;
	printf	"%-17s " "Currency:";	LC_ALL="$LocaleName" locale int_curr_symbol || PressAnyKeyToContinue;
	printf	"%-17s " "Telephone Prefix:";	LC_ALL="$LocaleName" locale int_prefix || PressAnyKeyToContinue;
	
	EchoInfo	"/etc/profile";
	local LocaleLanguage="en";
	local LocaleCountry="US";
	local LocaleCharmap=$(LC_ALL="$LocaleName" locale charmap);
	# local LocaleModifers="@euro"
	cat > /etc/profile << EOF
# Begin /etc/profile

# System wide environment variables and startup programs.

# System wide aliases and functions should go in /etc/bashrc.
# Personal environment variables and startup programs should
# go into ~/.bash_profile.
# Personal aliases and functions should go into ~/.bashrc.

## Begin Language settings

for i in \$(locale); do
    unset \${i%=*}
done

if [[ "\$TERM" = linux ]]; then
    export LANG=C.UTF-8
else
    export LANG=${LocaleLanguage}_${LocaleCountry}.${LocaleCharmap}${LocaleModifers}
fi

## End Language Settings

## Begin Environment values

export PATH=/usr/bin
if [ ! -L /bin ]; then export PATH="\$PATH:/bin"; fi
if [ \$EUID -eq 0 ]; then
    export PATH="\$PATH:/usr/sbin"
	if [ ! -L /sbin ]; then export PATH="\$PATH:/sbin"; fi
	unset HISTFILE
fi

export HISTSIZE=1000
export HISTIGNORE="&:[bf]g:exit"

export XDG_DATA_DIRS=\${XDG_DATA_DIRS:-/usr/share}
export XDG_CONFIG_DIRS=\${XDG_CONFIG_DIRS:-/etc/xdg}
export XDG_RUNTIME_DIR=\${XDG_RUNTIME_DIR:-/tmp/xdg-\$USER}

## End Environment values

## Begin Subscript inclusion

for script in /etc/profile.d/*.sh; do
    if [ -r \$script ]; then
        . \$script
    fi
done

unset script

## End Subscript Inclusion

# End /etc/profile
EOF
}

# 9.8
ReadlineLibraryConfigurationFile()
{
	EchoInfo	"/etc/inputrc";
	cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8-bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# End /etc/inputrc
EOF
}

# 9.9
ShellValidationFile()
{
	EchoInfo	"/etc/shells";
	cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash
/bin/zsh

# End /etc/shells
EOF
}

# =====================================||===================================== #
#																			   #
#								   Chapter 10								   #
#						 Making the LFS System Bootable						   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

Make10LFSBootable()
{
	CreateMountpointReferenceFile;
	InstallLinux;
	SetupBootWithGRUB;
}

ReadMountPoints()
{
	EchoInfo	"Storing Mountpoint variables";
	RootPoint=$(lsblk -lno NAME,MOUNTPOINTS | awk '$2 == "/" { print $1 }');
	RootType=$(blkid -s TYPE -o value "/dev/${RootPoint}");
	# echo $RootPoint $RootType

	mountpoint /boot || mount /dev/sda1 /boot;
	BootPoint=$(lsblk -lno NAME,MOUNTPOINTS | awk '$2 == "/boot" { print $1 }');
	BootType=$(blkid -s TYPE -o value "/dev/${BootPoint}");
	# echo $BootPoint $BootType

	SwapPoint=$(lsblk -lno NAME,MOUNTPOINTS | awk '$2 == "[SWAP]" { print $1 }');
	SwapType=$(blkid -s TYPE -o value "/dev/${SwapPoint}");
	# echo $SwapPoint $SwapType

	HomePoint=$(lsblk -lno NAME,MOUNTPOINTS | awk '$2 == "/home" { print $1 }');
	HomeType=$(blkid -s TYPE -o value "/dev/${HomePoint}");
	# echo $HomePoint $HomeType

	USrcPoint=$(lsblk -lno NAME,MOUNTPOINTS | awk '$2 == "/usr/src" { print $1 }');
	USrcType=$(blkid -s TYPE -o value "/dev/${USrcPoint}");
	# echo $USrcPoint $USrcType

	OptPoint=$(lsblk -lno NAME,MOUNTPOINTS | awk '$2 == "/opt" { print $1 }');
	OptType=$(blkid -s TYPE -o value "/dev/${OptPoint}");
	# echo $OptPoint $OptType
}

CreateMountpointReferenceFile()
{
	ReadMountPoints;

	EchoInfo	"/etc/fstab";
	cat > /etc/fstab << EOF
# Begin /etc/fstab

# file system   mount-point     type        options             dump    fsck order
/dev/${RootPoint:-sda5}       /               ${RootType:-ext4}        defaults            1       1
/dev/${BootPoint:-sda1}       /boot           ${BootType:-ext2}        defaults            1       2
/dev/${SwapPoint:-sda2}       swap            swap        pri=1               0       0
/dev/${HomePoint:-sda6}       /home           ${HomeType:-ext4}        defaults            0       0
/dev/${USrcPoint:-sda7}       /usr/src        ${USrcType:-ext4}        defaults            0       0
/dev/${OptPoint:-sda8}       /opt            ${OptType:-ext4}        defaults            0       0
proc            /proc           proc        nosuid,noexec,nodev 0       0
sysfs           /sys            sysfs       nosuid,noexec,nodev 0       0
devpts          /dev/pts        devpts      gid=5,mode=620      0       0
tmpfs           /run            tmpfs       defaults            0       0
devtmpfs        /dev            devtmpfs    mode=0755,nosuid    0       0
tmpfs           /dev/shm        tmpfs       nosuid,nodev        0       0
cgroup2         /sys/fs/cgroup  cgroup2     nosuid,noexec,nodev 0       0

# End /etc/fstab
EOF
}

SetupBootWithGRUB()
{
	ReadMountPoints;

	EchoInfo	"Installing GRUB!!!"
	grub-install /dev/sda

	EchoInfo	"/boot/grub/grub.cfg";
	cat > /boot/grub/grub.cfg << EOF
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod part_gpt
insmod ext2
# insmod gfxterm
# insmod all_video

set root=(hd${BootDrive:-0},${BootPart:-1})

# set gfxmode=auto
# terminal_output gfxterm

menuentry "GNU/Linux, Linux 6.10.5-lfs-12.2" {
        # set gfxpayload=keep
        linux   /vmlinuz-6.10.5-lfs-12.2   root=/dev/${RootPoint:-sda5}  ro
}
EOF
}

# =====================================||===================================== #
#																			   #
#								   Chapter 11								   #
#									The End									   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

FinalTouches()
{
	DocumentRelease;
}

DocumentRelease()
{
	EchoInfo	"/etc/lfs-release"
	echo 12.2 > /etc/lfs-release

	EchoInfo	"/etc/lsb-release"
	cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="12.2"
DISTRIB_CODENAME="ohengelm"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

	EchoInfo	"/etc/os-release"
	cat > /etc/os-release << "EOF"
NAME="Linux From Scratch"
VERSION="12.2"
ID=lfs
PRETTY_NAME="Linux From Scratch 12.2"
VERSION_CODENAME="ohengelm"
HOME_URL="https://www.linuxfromscratch.org/lfs/"
EOF
}

# =====================================||===================================== #
#																			   #
#									 Bonus									   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

BonusBinaries()
{
	ExtractPackage	"blfs-bootscripts-20250225.tar.xz"
	InstallWget;
	InstallCaCert;
	InstallOpenSSH;
}

ExtractPackage()
{
	tar -xf "/usr/src/${1}" -C "/usr/src/" || EchoError "($?)Failed to extract ${1}";
}

declare -A PackageWget;
PackageWget[Name]="wget";
PackageWget[Version]="1.25.0";
PackageWget[Extension]=".tar.gz";
PackageWget[Package]="${PackageWget[Name]}-${PackageWget[Version]}";

InstallWget()
{
	EchoInfo	"${PackageWget[Name]}";
	ExtractPackage	"${PackageWget[Package]}${PackageWget[Extension]}";

	cd "/usr/src/${PackageWget[Package]}" || { EchoError "${PackageWget[Name]}> ($?)cd"; return; };

	EchoInfo	"${PackageWget[Name]}> configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--with-ssl=openssl \
				1> /dev/null || { EchoError "${PackageWget[Name]}> ($?)configure"; return; }

	EchoInfo	"${PackageWget[Name]}> make"
	make 1> /dev/null || { EchoError "${PackageWget[Name]}> ($?)make"; return; }

	EchoInfo	"${PackageWget[Name]}> make install"
	make install 1> /dev/null || { EchoError "${PackageWget[Name]}> ($?)make install"; return; }
}

declare -A PackageCaCert;
PackageCaCert[Name]="make-ca.sh";
PackageCaCert[Version]="20170514";
PackageCaCert[Extension]="";
PackageCaCert[Package]="${PackageCaCert[Name]}-${PackageCaCert[Version]}";

InstallCaCert()
{
	EchoInfo	"${PackageCaCert[Name]}";

	cd "/usr/src/make-ca" || { EchoError "${PackageCaCert[Name]}> ($?)cd"; return; };

	EchoInfo	"${PackageCaCert[Name]}> configure"
	install -vdm755 /etc/ssl/local
	wget http://www.cacert.org/certs/root.crt
	openssl x509 \
			-in root.crt \
			-text \
			-fingerprint \
			-setalias "CAcert Class 1 root" \
			-addtrust serverAuth \
			-addtrust emailProtection \
			-addtrust codeSigning \
			> /etc/ssl/local/CAcert_Class_1_root.pem

	EchoInfo	"${PackageCaCert[Name]}> install"
	install -vm755 make-ca.sh-20170514 /usr/sbin/make-ca.sh 1> /dev/null || { EchoError "${PackageCaCert[Name]}> ($?)make"; return; }

	EchoInfo	"${PackageCaCert[Name]}> /usr/sbin/make-ca.sh"
	/usr/sbin/make-ca.sh 1> /dev/null || { EchoError "${PackageCaCert[Name]}> ($?)make install"; return; }
}

declare -A PackageOpenSSH;
PackageOpenSSH[Name]="openssh";
PackageOpenSSH[Version]="9.9p2";
PackageOpenSSH[Extension]=".tar.gz";
PackageOpenSSH[Package]="${PackageOpenSSH[Name]}-${PackageOpenSSH[Version]}";

InstallOpenSSH()
{
	EchoInfo	"${PackageOpenSSH[Name]}";
	ExtractPackage	"${PackageOpenSSH[Package]}${PackageOpenSSH[Extension]}";

	cd "/usr/src/${PackageOpenSSH[Package]}" || { EchoError "${PackageOpenSSH[Name]}> ($?)cd"; return; };

	EchoInfo	"${PackageOpenSSH[Name]}> Setup Environment"
	install -v -g sys -m700 -d /var/lib/sshd 1> /dev/null || { EchoError "${PackageOpenSSH[Name]}> ($?)make"; return; }

	EchoInfo	"${PackageOpenSSH[Name]}> Add usergroup sshd"
	groupadd -g 50 sshd
	useradd  -c 'sshd PrivSep' \
			-d /var/lib/sshd  \
			-g sshd           \
			-s /bin/false     \
			-u 50 sshd

	EchoInfo	"${PackageOpenSSH[Name]}> configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc/ssh \
				--with-privsep-path=/var/lib/sshd \
				--with-default-path=/usr/bin \
				--with-superuser-path=/usr/sbin:/usr/bin \
				--with-pid-dir=/run \
				1> /dev/null || { EchoError "${PackageOpenSSH[Name]}> ($?)make"; return; }

	EchoInfo	"${PackageOpenSSH[Name]}> make"
	make 1> /dev/null || { EchoError "${PackageOpenSSH[Name]}> ($?)make"; return; }

	EchoInfo	"${PackageOpenSSH[Name]}> make -j1 tests"
	make -j1 tests 1> /dev/null || { EchoError "${PackageOpenSSH[Name]}> ($?)make"; return; }

	EchoInfo	"${PackageOpenSSH[Name]}> make install"
	make install 1> /dev/null || { EchoError "${PackageOpenSSH[Name]}> ($?)make"; return; }

	EchoInfo	"${PackageOpenSSH[Name]}> install -mXXX"
	install -v -m755    contrib/ssh-copy-id /usr/bin \
						 1> /dev/null || { EchoError "${PackageOpenSSH[Name]}> ($?)make"; return; }
	install -v -m644    contrib/ssh-copy-id.1 \
						/usr/share/man/man1 \
						 1> /dev/null || { EchoError "${PackageOpenSSH[Name]}> ($?)make"; return; }
	install -v -m755 -d /usr/share/doc/openssh-9.9p2 \
						 1> /dev/null || { EchoError "${PackageOpenSSH[Name]}> ($?)make"; return; }
	install -v -m644    INSTALL LICENCE OVERVIEW README* \
						/usr/share/doc/openssh-9.9p2 \
						 1> /dev/null || { EchoError "${PackageOpenSSH[Name]}> ($?)make"; return; }

	AddSSHConfFile;
	# echo "PermitRootLogin no" >> /etc/ssh/sshd_config
	# ssh-keygen
	# ssh-copy-id -i ~/.ssh/id_ed25519.pub REMOTE_USERNAME@REMOTE_HOSTNAME
	# echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
	# echo "KbdInteractiveAuthentication no" >> /etc/ssh/sshd_config
	# sed 's@d/login@d/sshd@g' /etc/pam.d/login > /etc/pam.d/sshd
	# chmod 644 /etc/pam.d/sshd
	# echo "UsePAM yes" >> /etc/ssh/sshd_config

	EchoInfo	"${PackageOpenSSH[Name]}> make install-sshd (@blfs-bootscripts-20250225)";
	cd /usr/src/blfs-bootscripts-20250225;
	make install-sshd 1> /dev/null || { EchoError "${PackageOpenSSH[Name]}> ($?)make"; return; }
}

AddSSHConfFile()
{
	# Create file
	mkdir -p /etc/ssh/sshd_config.d;
	cat > /etc/ssh/sshd_config.d/10-custom-lfs.conf << EOF
# 10-archiso.conf
PasswordAuthentication yes
PermitRootLogin yes

# 20-systemd-userdb.conf
AuthorizedKeysCommand /usr/bin/userdbctl ssh-authorized-keys %u
AuthorizedKeysCommandUser root

# 99-archlinux.conf
KbdInteractiveAuthentication no
UsePAM yes
PrintMotd no	
EOF

	# Ensure include
	grep -q '^Include /etc/ssh/sshd_config.d/\*\.conf$' /etc/ssh/sshd_config || sed -i '1iInclude /etc/ssh/sshd_config.d/*.conf' /etc/ssh/sshd_config
}

# =====================================||===================================== #
#																			   #
#									Execution								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

if [ $# -gt 0 ]; then
	case "$1" in
		RunAll)	;;
		*)		echo "Bad flag: '$1'";;
	esac
	exit;
fi

while true; do
	Width=$(tput cols);
	clear;

	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo -e	"${C_ORANGE}${C_BOLD}Build LFS${C_RESET}";
	echo -e	"Option:\t${-}";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo -e	"0)\t ";
	echo -e	"7)\t Configure environment and build last Temporary Tools";
	echo -e	"8)\t Install Basic System Software";
	echo -e	"9)\t System Configuration";
	echo -e "B)\t Bonus Binaries";
	echo -e	"G)\t Making the LFS System Bootable (GRUB)";
	echo -e "F)\t Final Touches";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	printf	"r)\t Remove Directories (%s)\n" "$(find $PDIR -mindepth 1 -maxdepth 1 -type d | wc -l)";
	echo -e	"q)\t Return to main menu";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	$LocalCommand;
	unset LocalCommand;
	echo -en	"Input> ";

	GetKeyPress;
	case $input in
		0)	;;
		7)	Install7;;
		8)	Install8AllBinaries;;
		9)	Configure9System;;
		B)	BonusBinaries;;
		G)	Make10LFSBootable;;
		F)	FinalTouches;;
		r)	RemovePackageDirectories;;
		q)	exit;;
	esac
	PressAnyKeyToContinue;
done
