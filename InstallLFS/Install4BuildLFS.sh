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
	echo -e	"7)\t Configure environment and build last Tmeporary Tools";
	echo -e	"8)\t Install Basic System Software";
	echo -e	"9)\t System Configuration";
	echo -e	"B)\t Making the LFS System Bootable";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo -e	"r)\t Remove Package directories";
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
		r)	RemovePackageDirectories;;
		q)	exit;;
	esac
done
