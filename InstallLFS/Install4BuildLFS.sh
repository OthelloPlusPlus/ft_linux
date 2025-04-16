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
	if ! CheckMountpoints; then
		return ;
	fi

	for (( i=29; i<=82; i++ )); do
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
			LocalCommand="echo \"Failed to create for Chapter 8.$i. Stopped\"";
			return 1;
		fi
	done
}

CheckMountpoints()
{
	for CheckMount in "/dev" "/dev/pts" "/proc" "/sys" "/run" "/dev/shm"; do
		mountpoint -q "$CheckMount" || { LocalCommand="echo \"CRUCIAL: ($? $CheckMount): Mountpoints are not set! Did you reboot?\""; return $?; };
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
	InstallLFSBootscript;
	ManageDevices;
}

ManageDevices()
{
	bash /usr/lib/udev/init-net-rules.sh

	EchoInfo "--- Custom Udev Rules ---"
	EchoInfo '/etc/udev/rules.d/70-persistent-net.rules'
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
	echo -e	"B)\t Making the LFS System Bootable";
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
		r)	RemovePackageDirectories || PressAnyKeyToContinue;;
		q)	exit;;
	esac
done
