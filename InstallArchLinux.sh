#! /bin/zsh

source colors.sh

DISK="/dev/sda"
LFS="/mnt/lfs"
USER="Othello"

# =====================================||===================================== #
#																			   #
#								Disk Partioning								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

DiskPartitionMenu()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE}Disk ${C_RESET}$DISK${C_ORANGE} partioning${C_RESET}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	DisplayPartioning;
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"p)\t(Re)configure $DISK disk partition table";
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	case $input in
		p|P)	CreateNewPartioning;
				PressAnyKeyToContinue;;
		q|Q)	MENU=0;;
		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";;
	esac
}

CreateNewPartioning()
{
	echo	"Creating fdisk partioning command...";


	HEREDOCCMD=""
	# New Partition Table
	AddToHereDocCmd	"o";
	# Primary Partitions
	AddToHereDocCmd	"n"	"p"	"1"	""	"+30GB"	"type"	"1"	"83";	# /
	AddToHereDocCmd	"n"	"p"	"2"	""	"+1GB"	"type"	"2"	"83";	# /boot
	AddToHereDocCmd	"n"	"p"	"3"	""	"+1GB"	"type"	"3"	"EF";	# /boot/efi
	# Extended Partitions
	AddToHereDocCmd	"n"	"e"	"4"	""	"+1500GB";
	# Logic Partitions
	AddToHereDocCmd	"n"	"l"	""	"+4GB"	"type"	"5"	"82";	# swap
	AddToHereDocCmd	"n"	"l"	""	"+50GB"	"type"	"6"	"83";	# /home
	AddToHereDocCmd	"n"	"l"	""	"+30GB"	"type"	"7"	"83";	# /usr
	AddToHereDocCmd	"n"	"l"	""	"+50GB"	"type"	"8"	"83";	# /usr/src
	AddToHereDocCmd	"n"	"l"	""	"+10GB"	"type"	"9"	"83";	# /opt
	AddToHereDocCmd	"n"	"l"	""	"+5GB"	"type"	"10"	"83";	# /tmp
	# Write table to disk
	AddToHereDocCmd	"w";

	echo	"Sending partion command to fdisk...";

fdisk $DISK &>/dev/null <<EOF
${HEREDOCCMD}
EOF
}

AddToHereDocCmd()
{
	for arg in "$@"; do
		HEREDOCCMD="$HEREDOCCMD$arg
";
	done
}

DisplayPartioning()
{
	fdisk -l $DISK;
}



# =====================================||===================================== #
#																			   #
#								  File Systems								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

FileSystemMenu()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE}File systems${C_RESET}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	DisplayFileSystems;
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"f)\tFormat File Systems (FSTYPE)";
	echo	"m)\tMount partitions (MOUNTPOINTS)";
	echo	"${C_WEAK}u)\tUnmount partitions${C_RESET}";
	echo	"${C_WEAK}U)\t Force unmount partitions (--lazy)${C_RESET}";
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	case $input in
		f|F)	FormatFileSystems;
				PressAnyKeyToContinue;;
		m|M)	MountPartitions;
				PressAnyKeyToContinue;;
		u)		UnmountPartitions "";
				PressAnyKeyToContinue;;
		U)		UnmountPartitions "-l";
				PressAnyKeyToContinue;;
		q|Q)	MENU=0;;
		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";;
	esac
}

DisplayFileSystems()
{
	lsblk "$DISK" -o NAME,LABEL,SIZE,TYPE,FSTYPE,MOUNTPOINTS;
}

FormatFileSystems()
{
	mkfs.ext4	"$DISK"1 -L "/" 1> /dev/null;
	mkfs.ext2	"$DISK"2 -L "/boot" 1> /dev/null;
	mkfs.vfat	"$DISK"3 -n "BOOTEFI" 1> /dev/null;
	mkswap		"$DISK"5 -L "swap" 1> /dev/null;
	mkfs.ext4	"$DISK"6 -L "/home" 1> /dev/null;
	mkfs.ext4	"$DISK"7 -L "/usr" 1> /dev/null;
	mkfs.ext4	"$DISK"8 -L "/usr/src" 1> /dev/null;
	mkfs.ext4	"$DISK"9 -L "/opt" 1> /dev/null;
	mkfs.ext4	"$DISK"10 -L "/tmp" 1> /dev/null;
}

MountPartitions()
{
	mkdir -p "$LFS";

	MountLabel "/"			"$LFS";
	MountLabel "/boot"		"$LFS/boot";
	MountLabel "BOOTEFI"	"$LFS/boot/efi";
	swapon "$DISK"5 1> /dev/null;
	MountLabel "/home"		"$LFS/home";
	MountLabel "/usr"		"$LFS/usr";
	MountLabel "/usr/src"	"$LFS/usr/src";
	MountLabel "/opt"		"$LFS/opt";
	MountLabel "/tmp"		"$LFS/tmp";
}

MountLabel()
{
	LABEL="$1";
	MNTPOINT="$2";

	mkdir -p "$MNTPOINT" 1> /dev/null;

	if ! mount | grep -q "on $MNTPOINT "; then
		echo	"Mounting $LABEL\t-> $MNTPOINT";
		mount -L "$LABEL" "$MNTPOINT";
	fi
}

UnmountPartitions()
{
	swapoff "$DISK"5;
	umount $1 "$LFS";
}

# # =====================================||===================================== #
# #																			   #
# #										Tools								   #
# #																			   #
# # ===============ft_linux==============||==============©Othello=============== #

TOOLSDISPLAY=0;

ArchLinuxToolsMenu()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE}Tools${C_RESET}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	case $TOOLSDISPLAY in
		0)	ToolsDisplayOverview;;
		1)	DisplayDevelopmentTools;;
		2)	DisplayAliasList;;
	esac
	# df / -h;
	# echo;
	# PrintTools;
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"i)\tInstall Tools";
	echo	"${C_STRIKE}a)\tSet Aliases (WIP)${C_RESET}";
	echo	"${C_WEAK}l)\tLFS guide script${C_RESET}";
	echo	"d)\tSwitch display";
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	GetInput;

	case $input in
		i|I)	InstallTools;;
		l|L)	LFSGuideScript;
				PressAnyKeyToContinue;;
		# a|A)	SetAlias;;
		d|D)	((TOOLSDISPLAY = (TOOLSDISPLAY + 1) % 3));;
		q|Q)	MENU=0;;
		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";;
	esac
}

ToolsDisplayOverview()
{
	size1=14;

	State=$(CheckKernelVersion 4.19 && \
			CheckKernelSupport && \
			echo "${C_GREEN}$(uname -r)${C_RESET}" || \
			echo "${C_RED}$(uname -r)${C_RESET}");
	printf "%-${size1}s %s\n"	"Kernel:"	"$State";
	printf "%-${size1}s %s\n"	"Cores:"	"$(type -p nproc >/dev/null && nproc || echo "${C_RED}KO nproc${C_RESET}")";
	if [ $(df --output=size / | tail -n 1) -gt 400000 ]; then
		State=$(echo "${C_GREEN}$(df --output=pcent / | tail -n 1)${C_RESET}");
	else
		State=$(echo "${C_RED}$(df --output=size / | tail -n 1) / 400000${C_RESET}");
	fi
	printf "%-${size1}s %-s\n"	"Space:"	"$State";
	# State=$(CheckDevelopmentTools && \
	# 		echo "${C_GREEN}OK${C_RESET}" || \
	# 		echo "${C_RED}KO${C_RESET}");
	df /run/archiso/cowspace /;

	echo;
	if [ $(df --output=size / | tail -n 1) -gt 400000 ]; then
		State=$(echo "${C_GREEN}OK${C_RESET}");
	else
		State=$(echo "${C_RED}KO${C_RESET}");
	fi
	printf "%-${size1}s %s\n"	"Space:"	"$State";
	State=$(CheckDevelopmentTools && \
			echo "${C_GREEN}OK${C_RESET}" || \
			echo "${C_RED}KO${C_RESET}");
	printf "%-${size1}s %s\n"	"Develop Tools:"	"$State";
	State=$(CheckAliasList && \
			echo "${C_GREEN}OK${C_RESET}" || \
			echo "${C_RED}KO${C_RESET}");
	printf "%-${size1}s %s\n"	"Alias:"	"$State";
}

CheckKernelVersion()
{
	KERNELVERSION=$(uname -r | grep -E -o '^[0-9\.]+');
	return $(printf '%s\n' $1 $KERNELVERSION | sort --version-sort --check &>/dev/null);
}

CheckKernelSupport()
{
	return $(mount | grep -q 'devpts on /dev/pts' && [ -e /dev/ptmx ]);
}

CheckDevelopmentTools()
{
	SetToolList;

	for TOOL in $TOOLLIST; do
		read -r TNAME TBIN TPACNAME TVER <<< "$TOOL"
		if ! CheckDevelopmentTool "$TBIN" "$TVER"; then
			return 1;
		fi
	done
}

DisplayDevelopmentTools()
{
	SetToolList;

	printf	"   %-9s %-8s %-12s\n"	"Name" "Version" "Size";
	for TOOL in $TOOLLIST; do
		read -r TNAME TBIN TPACNAME TVER <<< "$TOOL"
		if CheckDevelopmentTool "$TBIN" "$TVER"; then
			echo -n "${C_GREEN}OK${C_RESET}";
		else
			echo -n "${C_RED}KO${C_RESET}";
		fi
		TSIZE=$(pacman -Si "$TPACNAME" 2>/dev/null | grep "Installed Size" | awk '{print $4" "$5}');
		printf " %-9s %-8s %12s\n" "$TNAME" "$TVER" "$TSIZE";
	done
}

CheckDevelopmentTool()
{
	if ! type -p $1 &>/dev/null; then
		return 1;
	fi
	v=$($1 --version 2>&1 | grep -E -o '[0-9]+\.[0-9\.]+[a-z]*' | head -n1)
	if printf '%s\n' $2 $v | sort --version-sort --check &>/dev/null; then
		return 0;
	else
		return 1;
	fi
}

SetToolList()
{
	unset TOOLLIST;
	TOOLLIST+=("Coreutils	sort		coreutils	8.1");
	TOOLLIST+=("Bash		bash		bash		3.2");
	TOOLLIST+=("Binutils	ld			binutils	2.13.1");
	TOOLLIST+=("Bison		bison		bison		2.7");
	TOOLLIST+=("Diffutils	diff		diffutils	2.8.1");
	TOOLLIST+=("Findutils	find		findutils	4.2.31");
	TOOLLIST+=("Gawk		gawk		gawk		4.0.1");
	TOOLLIST+=("GCC			gcc			gcc			5.2");
	TOOLLIST+=("GCC(C++)	g++			gcc			5.2");
	TOOLLIST+=("Grep		grep		grep		2.5.1a");
	TOOLLIST+=("Gzip		gzip		gzip		1.3.12");
	TOOLLIST+=("M4			m4			m4			1.4.10");
	TOOLLIST+=("Make		make		make		4.0");
	TOOLLIST+=("Patch		patch		patch		2.5.4");
	TOOLLIST+=("Perl		perl		perl		5.8.8");
	TOOLLIST+=("Python		python3		python		3.4");
	TOOLLIST+=("Sed			sed			sed			4.1.5");
	TOOLLIST+=("Tar			tar			tar			1.22");
	TOOLLIST+=("Texinfo		texi2any	texinfo		5.0");
	TOOLLIST+=("Xz			xz			xz			5.0.0");
}

CheckAliasList()
{
	SetAliasList;

	for ALIAS in $ALIASLIST; do
		read -r ALIASNAME TRUENAME <<< "$ALIAS";
		if ! $ALIASNAME --version 2>/dev/null | grep -qi "$TRUENAME"; then
			return 1;
		fi
	done
}

DisplayAliasList()
{
	SetAliasList;
	
	printf "   %-5s %-8s %-s\n" "Alias" "Name" "Location";
	for ALIAS in $ALIASLIST; do
		read -r ALIASNAME TRUENAME <<< "$ALIAS";
		if ! $ALIASNAME --version 2>/dev/null | grep -qi "$TRUENAME"; then
			echo -n "${C_RED}KO${C_RESET}";
		else
			echo -n "${C_GREEN}OK${C_RESET}";
		fi
		printf " %-5s %-8s %-s\n" "$ALIASNAME" "$TRUENAME" "$(which $ALIASNAME)";	
	done
}

SetAliasList()
{
	unset ALIASLIST;
	ALIASLIST+=("awk	GNU");
	ALIASLIST+=("yacc	Bison");
	ALIASLIST+=("sh		Bash");
}

SetTools()
{
	unset TOOLS;
	TOOLS+=("bash");
	TOOLS+=("binutils");
	TOOLS+=("bison");
	TOOLS+=("coreutils");
	TOOLS+=("diffutils");
	TOOLS+=("findutils");
	TOOLS+=("gawk");
	TOOLS+=("gcc");
	TOOLS+=("grep");
	TOOLS+=("gzip");
	TOOLS+=("m4");
	TOOLS+=("make");
	TOOLS+=("patch");
	TOOLS+=("perl");
	TOOLS+=("python");
	TOOLS+=("sed");
	TOOLS+=("tar");
	TOOLS+=("texinfo");
	TOOLS+=("xz");
}

PrintTools()
{
	SetTools;

	for TOOL in "${TOOLS[@]}"; do
		PrintToolStatus	"$TOOL";
	done
}

PrintToolStatus()
{
	if pacman -Q "$1" &> /dev/null; then
		TEMP="${C_GREEN}OK${C_RESET}"
	else
		TEMP="${C_RED}KO${C_RESET}";
	fi
	TEMP+="\t$1";

	TEMP+="\t$(pacman -Si "$1" 2>/dev/null | grep "Installed Size" | awk '{print $4" "$5}')";
	TEMP+="\t$(pacman -Si "$1" 2>/dev/null | grep "Download Size" | awk '{print $4" "$5}')";

	# installed_size=$(pacman -Qi "$1" 2>/dev/null | grep "Installed Size" | awk '{print $4" "$5}')
	# repo_size=$(pacman -Qi "$1" 2>/dev/null | grep "Download Size" | awk '{print $4" "$5}')

	echo	"$TEMP";
}

InstallTools()
{
	SetTools;

	pacman -Scc --noconfirm;

	for TOOL in "${TOOLS[@]}"; do
		InstallTool	"$TOOL";
	done
	pacman -Scc --noconfirm;
}

InstallTool()
{
	if ! pacman -Q "$1" &> /dev/null; then
		echo	"${C_ORANGE}Installing ${C_RESET}$1${C_ORANGE}...${C_RESET}"
		pacman -Sy --needed --noconfirm "$1";
		if [ $? -ne 0 ]; then
			PressAnyKeyToContinue;
		fi
	fi
}

DisplayImage()
{
	echo "lorem";
	KERNELVERSION=$(uname -r | grep -E -o '^[0-9\.]+');
	if printf '%s\n' $1 $KERNELVERSION | sort --version-sort --check &>/dev/null; then
		return 23;
	else
		return 24;
	fi
}

LFSGuideScript()
{
	
	#!/bin/bash
# A script to list version numbers of critical development tools
# If you have tools installed in other directories, adjust PATH here AND
# in ~lfs/.bashrc (section 4.4) as well.
LC_ALL=C
PATH=/usr/bin:/bin
grep --version > /dev/null 2> /dev/null || bail "grep does not work"
sed		'' /dev/null || bail "sed does not work"
sort	/dev/null || bail "sort does not work"
# Coreutils first because --version-sort needs Coreutils >= 7.0
ver_check Coreutils		sort		8.1 || bail "Coreutils too old, stop"
ver_check Bash			bash		3.2
ver_check Binutils		ld			2.13.1
ver_check Bison			bison		2.7
ver_check Diffutils		diff		2.8.1
ver_check Findutils		find		4.2.31
ver_check Gawk			gawk		4.0.1
ver_check GCC			gcc			5.2
ver_check "GCC (C++)"	g++			5.2
ver_check Grep			grep		2.5.1a
ver_check Gzip			gzip		1.3.12
ver_check M4			m4			1.4.10
ver_check Make			make		4.0
ver_check Patch			patch		2.5.4
ver_check Perl			perl		5.8.8
ver_check Python		python3		3.4
ver_check Sed			sed			4.1.5
ver_check Tar			tar			1.22
ver_check Texinfo		texi2any	5.0
ver_check Xz			xz			5.0.0
ver_kernel 4.19
if mount | grep -q 'devpts on /dev/pts' && [ -e /dev/ptmx ]
then
	echo "${C_GREEN}OK${C_RESET}:	Linux Kernel supports UNIX 98 PTY";
else 
	echo "${C_RED}KO${C_RESET}:	Linux Kernel does NOT support UNIX 98 PTY";
fi
	echo "Aliases:"
	alias_check awk GNU
	alias_check yacc Bison
	alias_check sh Bash
	echo "Compiler check:"
	if printf "int main(){}" | g++ -x c++ -
	then
		echo "${C_GREEN}OK${C_RESET}:	g++ works";
	else
		echo "${C_RED}KO${C_RESET}: g++ does NOT work";
	fi
	rm -f a.out
	if [ "$(nproc)" = "" ]; then
		echo "${C_RED}KO${C_RESET}: nproc is not available or it produces empty output"
	else
		echo "${C_GREEN}OK${C_RESET}: nproc reports $(nproc) logical cores are available"
	fi
}

bail()
{
	echo "${C_RED}FATAL${C_RESET}: $1";
	exit 1;
}

ver_check()
{
	if ! type -p $2 &>/dev/null
	then
		echo "${C_RED}KO${C_RESET}: Cannot find $2 ($1)";
		return 1;
	fi
	v=$($2 --version 2>&1 | grep -E -o '[0-9]+\.[0-9\.]+[a-z]*' | head -n1)
	if printf '%s\n' $3 $v | sort --version-sort --check &>/dev/null
	then
		size=$(stat --format %s $(type -p $2 | cut -d' ' -f3));
		printf "${C_GREEN}OK${C_RESET}:	%-9s %-6s >= %-8s %s\n" "$1" "$v" "$3" "$size";
		return 0;
	else
		printf "${C_RED}KO${C_RESET}: %-9s is TOO OLD ($3 or later required)\n" "$1";
		return 1;
	fi
}

alias_check()
{
	if $1 --version 2>&1 | grep -qi $2
	then
		printf "${C_GREEN}OK${C_RESET}:	%-4s is $2\n" "$1";
	else
		printf "${C_RED}KO${C_RESET}: %-4s is NOT $2\n" "$1";
	fi
}

ver_kernel()
{
	kver=$(uname -r | grep -E -o '^[0-9\.]+')
	if printf '%s\n' $1 $kver | sort --version-sort --check &>/dev/null
	then
		printf "${C_GREEN}OK${C_RESET}:	Linux Kernel $kver >= $1\n";
		return 0;
	else
		printf "${C_RED}KO${C_RESET}: Linux Kernel ($kver) is TOO OLD ($1 or later required)\n" "$kver";
		return 1;
	fi
}

# =====================================||===================================== #
#																			   #
#									Packages								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

MIRRORSITE=https://mirror.koddos.net/lfs/lfs-packages/12.2/
DEST="$LFS/sources/lfs-packages12.2/"

PackagesMenu()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE}Packages${C_RESET}";
	echo;
	echo	"Mirror:    $MIRRORSITE";
	echo	"Directory: $DEST";

	printf	"%-13s"	"md5sums:"
	if [ ! -f "$DEST/md5sums" ]; then
		echo "${C_ORANGE}N/A${C_RESET}"
	else
		cd "$DEST";
		MD5=$(md5sum -c "md5sums" 2> /dev/null);
		if [[ $(md5sum -c "md5sums" --quiet 2> /dev/null | wc -l) -eq 0 ]]; then
			echo "${C_GREEN}OK${C_RESET}"
		else
			echo "${C_RED}KO${C_RESET}"
		fi
		cd -;
	fi

	DisplayPackageCount	".tar.xz";
	DisplayPackageCount	".tar.gz";
	DisplayPackageCount	".tar.bz2";
	DisplayPackageCount	".patch";
	echo	"Directories: $(find "$DEST" -mindepth 1 -maxdepth 1 -type d | wc -l)";

	if ! CheckDevelopmentTools; then
		echo "ArchLinux Tools: ${C_RED}KO${C_RESET}"
	fi
	printf '%*s\n' "$width" '' | tr ' ' '-';
	# echo	"t)\tInstall Required Tools";
	echo	"p)\tDownload Packages";
	echo	"d)\tDisplay Packages";
	echo	"i)\tInstall Packages (WIP)";
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	case $input in
		p|P)	DownloadPackages;
				PressAnyKeyToContinue;;
		d|D)	DisplayPackages;
				PressAnyKeyToContinue;;
		i|I)	InstallPackages;
				PressAnyKeyToContinue;;
		q|Q)	MENU=0;;
		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";;
	esac
}

DisplayPackageCount()
{
	local GROUP="$1";
	local TABSIZE=13;

	if [ -e "${DEST}/md5sums" ]; then
		local FOUND=$(grep "$GROUP" <<< "$MD5" | grep "OK" | wc -l);
		local TOTAL=$(grep "$GROUP" <<< "$MD5" | wc -l);
		if [ "$FOUND" -eq "$TOTAL" ]; then
			FOUND="${C_GREEN}$FOUND${C_RESET}"
		else
			FOUND="${C_RED}$FOUND${C_RESET}"
		fi
	else
		local FOUND=$(ls "${DEST}" | grep "${GROUP}" | wc -l);
		local TOTAL="${C_ORANGE}N/A${C_RESET}";
	fi
	printf	"%-${TABSIZE}s$FOUND/$TOTAL\n"	"*$GROUP:";
}

DownloadPackages()
{
	mkdir -p -m 777 "$LFS/sources";
	command -v wget >/dev/null 2>&1 || pacman -Sy wget

	wget -r -np -m --wait=0.1 --timeout=8 -nH --cut-dirs=4 -P "$DEST" "$MIRRORSITE" \
		-A "md5sums,*.tar.xz,*.tar.gz,*.tar.bz2,*.patch" -nv;
}

DisplayPackages()
{
	if [ ! -e "$DEST/md5sums" ]; then
		ls "$DEST"
	else
		local CONTENT=();
		local PREV=0;
		for FILE in $(awk '{print $2}' $DEST/md5sums); do
			if [ -f $DEST/$FILE ] && [ $PREV -ne 2 ]; then
				PREV=2;
				CONTENT+="$(tput setaf 2)$FILE";
			elif [ ! -e $DEST/$FILE ] && [ $PREV -ne 1 ]; then
				PREV=1;
				CONTENT+="$(tput setaf 1)$FILE";
			else
				CONTENT+="$FILE";
			fi
		done
		printf "%s\n" "${CONTENT[@]}" | column -x
		echo -n "$C_RESET";
	fi
}

InstallPackages()
{
	
	# cd ~;
	# source InstallPackages.sh

	# InstallPackageBinutils;
	echo $USER;
	echo $-;
	su $USER -c "echo $-";
	# su - $USER -c "echo $-";
	su - $USER -c "bash -i -c 'echo \$-'"

	# su - $USER -c "bash -i -c \"echo lorem\""
	# cp InstallPackages.sh colors.sh /home/$USER/
	# chmod +x /home/$USER/InstallPackages.sh

	# su - $USER -c "env | grep LFS";
	# su Othello -c "set -m; cd ~; if [[ $- == *i* ]]; then
	# 	echo "(interactive)"
	# else
	# 	echo "(not interactive)"
	# fi"
	# su - Othello -c "set -m; cd ~; env"
	# su - $USER -c "bash -c '/home/$USER/InstallPackages.sh'";
	# binutils-2.43.1
	# PACKAGE="binutils-2.43.1";
	# EXT=".tar.xz"
	# ExtractPackage;
	# if ! mkdir -pv $DEST$PACKAGE/build; then
	# 	echo	"${C_RED}Error${C_RESET}"; 
	# 	return ;
	# fi

	# cd $DEST/$PACKAGE/build;
	# ../configure	--prefix=$LFS/tools	\
	# 				--with-sysroot=$LFS	\
	# 				--target=$LFS_TGT	\
	# 				--disable-nls		\
	# 				--enable-gprofng=no	\
	# 				--disable-werror	\
	# 				--enable-new-dtags	\
	# 				--enable-default-hash-style=gnu;
	# make;
	
}

ExtractPackage()
{
	echo	"unpacking ${DEST}${PACKAGE}${EXT}";
	tar -xf ${DEST}${PACKAGE}${EXT} -C ${DEST};
}

# =====================================||===================================== #
#																			   #
#								Configurations								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

ConfigurationsMenu()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE}Configurations${C_RESET}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	ls -ld $LFS/usr | awk '{printf "Owner: %s\n", $3}';
	printf "%-7s %-16s %-s\n" "UID" "NAME" "Home Directory";
	awk -F: '$3 >= 1000 && $3 <= 60000 {printf " %-6s  %-15s  %-s\n", $3, $1, $6}' /etc/passwd;
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"d)\tCreate Directory Layout";
	echo	"u)\tCreate new user";
	# echo	"e)\tEnvironment setup";
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	case $input in
		d|D)	CreateAndLinkDirectories;
				PressAnyKeyToContinue;;
		u|U)	CreateNewUser "$USER";
				PressAnyKeyToContinue;;
		q|Q)	MENU=0;;
		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";;
	esac
}

CreateNewUser()
{
	if [ ! -z "$1" ]; then
		NAME="$1"
		ADMIN=true
		USERSHELL=/bin/bash
	else
		ReadNewUserInput;
		if [ $? -ne 0 ]; then
			echo "Bad input. try again:";
			ReadNewUserInput;
			if [ $? -ne 0 ]; then
				echo "I give up...";
				return 1;
			fi
		fi
	fi

	AddUserToLFS;
	if [ "$ADMIN" = true ]; then
		MakeUserAdmin "$NAME";
	fi
	ConfigureUsersShell;
}

ReadNewUserInput()
{
	echo "Creating New User";
	echo -n	"Name: "
	read	NAME;
	if [ -z "$NAME" ]; then
		echo "Empty name";
		return 1;
	elif ! [[ "$NAME" =~ ^[a-zA-Z0-9]+$ ]]; then
		echo "Incorrect name '$NAME'. Only alphanumericals.";
		return 1;
	fi

	echo -n	"Owner (y/n): ";
	read	ADMIN;
	ADMIN=$(echo "$ADMIN" | tr '[:upper:]' '[:lower:]');
	case $ADMIN in
		y|yes)	ADMIN=true;;
		n|no)	ADMIN=false;;
		*)	echo "Unknown input '$ADMIN";	
			return 1;;
	esac

	echo -n	"Shell (/bin/bash): ";
	read	USERSHELL;
	USERSHELL=$(basename "$USERSHELL" | tr '[:upper:]' '[:lower:]');
	case $USERSHELL in
		bash)	USERSHELL=/bin/bash;;
		zsh)	echo "Converting to bash cause lazy coder";
				USERSHELL="/bin/bash";;
		sh)	echo "Converting to bash cause lazy coder";
			USERSHELL="/bin/bash";;
		*)	echo "Unknown shell '$USERSHELL'";
			return 1;;
	esac
	return 0;
}

AddUserToLFS()
{
	groupadd "$NAME";
	useradd -s "$USERSHELL" -g "$NAME" -m -k /dev/null "$NAME";
}

MakeUserAdmin()
{
	if [ -z "$1" ]; then
		return ;
	else
		NAME="$1";
	fi

	chown -v "$NAME" $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools};
	case $(uname -m) in
		x86_64) chown -v "$NAME" $LFS/lib64 ;;
	esac
	chown -R $NAME $LFS;
}

ConfigureUsersShell()
{
	case $USERSHELL in
		/bin/bash)	echo "Relocating /etc/bash.bashrc";
					[ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE;
					# echo	"There are issues passing commands to an interactive login shell:";
					# printf	"${CB_LRED}> %-42s${C_RESET}\r\n"	"su - $USER -c \"[command]\"";
					# echo	"Fix: Run the following commands manualy:"
					# printf	"${CB_LORANGE}> %-42s${C_RESET}\r\n"	"su - $NAME";
					# printf	"${CB_LORANGE}> %-42s${C_RESET}\r\n"	"~/ConfigureArchLinux.sh";
su - $NAME << EOSU
echo "Creating ~/.bash_profile"
cat > /home/Othello/.bash_profile << "EOF"
exec env -i HOME=\$HOME TERM=\$TERM PS1='\u:\w\\$ ' /bin/bash
EOF

echo "Creating ~/.bashrc"
cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export MAKEFLAGS=-j$(nproc)
EOF

if [ -e /etc/bash.bashrc ]; then 
	echo "Relocating /etc/bash.bashrc"
	mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE
elif [ ! -e /etc/bash.bashrc.NOUSE ]; then
	echo "Error: /etc/bash.bashrc is missing!"
fi

echo "Setting source ~/.bash_profile"
source ~/.bash_profile

EOSU
;;
		/bin/zsh)	cp "/root/default.zshrc" "/home/$NAME/.zshrc";;
		/bin/sh);;
	esac
}

CreateAndLinkDirectories()
{
	mkdir -vp $LFS/{etc,var} $LFS/usr/{bin,lib,sbin};
	for i in bin lib sbin; do
		ln -sv usr/$i $LFS/$i;
	done

	case $(uname -m) in
		x86_64) mkdir -pv $LFS/lib64 ;;
	esac

	mkdir -pv $LFS/tools;
}

AddUser()
{
	if [ -n "$1" ]; then
		NAME="$1";
	else
		echo -n	"Please input username: ";
		read	NAME;
	fi
	if [ ! -n "$NAME" ]; then
		return ;
	fi

	groupadd "$NAME";
	useradd -s /bin/zsh -g "$NAME" -m -k /dev/null "$NAME";
	# passwd

	cp "/root/default.zshrc" "/home/$NAME/.zshrc";
}

MakeOwner()
{
	chown -v "$NAME" $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools};
	case $(uname -m) in
		x86_64) chown -v "$NAME" $LFS/lib64 ;;
	esac
}

LoginAsUser()
{
	echo -n	"Username: ";
	read	NAME;

	clear;
	echo "VM Shell (no prompts):"
	su - $NAME;
}

DisplayEnv()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE}Environment${C_RESET}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	env
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	case $input in
		q|Q)	MENU=0;;
	esac
}

# =====================================||===================================== #
#																			   #
#									Resources								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

CrossCompilationMenu()
{
	local OWNER=$(ls -ld $LFS/usr | awk '{printf "%s", $3}');
	
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE}Cross Compilation${C_RESET}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"Owner:\t$OWNER";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"c)\tConfigure ${C_ORANGE}$OWNER${C_RESET}";
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	case $input in
		c|C)	LoginAs	"$OWNER";;
		q|Q)	MENU=0;;
		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";;
	esac
}

LoginAs()
{
	if [ -z "$1" ]; then
		return ;
	fi
	clear;
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE}User $1${C_RESET}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"To continue enter the following command:";
	echo	"${CB_BLACK}> zsh ./ConfigureArchLinux.sh ${C_RESET}";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	cp /root/{ConfigureArchLinux.sh,colors.sh} "/home/$1/"
	chmod +x "/home/$1/ConfigureArchLinux.sh"
	su - "$1";
}

# =====================================||===================================== #
#																			   #
#									Resources								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

ResourceMenu()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE}Resources${C_RESET}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"l)\tLinux From Scratch";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	case $input in
		l|L)	OpenWebsite "https://www.linuxfromscratch.org/lfs/";;
		q|Q)	MENU=0;;
		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";;
	esac
}

OpenWebsite()
{
	# echo	"Opening '$1'";
	# # nohup xdg-open "$1"  >/dev/null 2>&1;
	# # xdg-open "$1";
	# google-chrome "$1";
	# echo "done";
	# GetInput;
	MSG="$1";
}

# =====================================||===================================== #
#																			   #
#									  Loop									   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

export TERM=xterm;
unset MSG;
CLEARING=true;
MENU=0;

MainMenu()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE}${C_BOLD}Arch linux setup for LFS${C_RESET}";
	echo	"Menu:\t${MENU}";
	echo	"Option:\t${-}";
	# if [[ $- == *i* ]]; then
	# 	echo "(interactive)"
	# else
	# 	echo "(not interactive)"
	# fi
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"0)\tFull Install";
	echo	"1)\t${C_ALT}ArchLinux Tools";
	echo	"2)\tDisk Partitioning";
	echo	"3)\tFile Systems";
	echo	"4)\tConfigurations";
	echo	"5)\tPackages";
	echo	"6)\tCross Compilation";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"vm)\tAccess VM shell";
	echo	"env)\tDisplay env";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	echo	"r)\tResources";
	echo	"d)\tDisk Space Available";
	echo	"s)\tSettings";
	echo	"q)\tQuit";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	case $input in
		0)	FullInstall;;
		1)	MENU=1;;
		2)	MENU=2;;
		3)	MENU=3;;
		4)	MENU=4;;
		5)	MENU=5;;
		6)	MENU=6;;
		vm|VM)	LoginAsUser;;
		env|ENV)	MENU=50;;
		m|M)	;;
		r|R)	MENU=97;;
		d|D)	MENU=98;;
		s|S)	MENU=99;;
		q|Q)	MENU=-1;;
		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";;
	esac
}

FullInstall()
{
	InstallTools;
	CreateNewPartioning;
	FormatFileSystems;
	MountPartitions;
	CreateAndLinkDirectories;
	CreateNewUser "$USER";
	DownloadPackages;
	MakeUserAdmin "$USER";
}

SpaceMenu()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"File System Space Usage";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	df -h | grep -v "/dev/sd";
	echo;
	df -h /dev/sd* | grep "/dev/sd"
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	case $input in
		q|Q) MENU=0;;
		*) MSG="${C_RED}Invalid input${C_RESET}: $input";;
	esac
}

SettingsMenu()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"Settings";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"c)\tToggle screen clearing ($CLEARING)";
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	case $input in
		c|C) CLEARING=$( [ "$CLEARING" = true ] && echo false || echo true );;
		q|Q) MENU=0;;
		*) MSG="${C_RED}Invalid input${C_RESET}: $input";;
	esac
}

GetInput()
{
	echo	"$MSG";
	echo -n	"Choose an option: ";
	unset MSG;
	read	input;
	printf '%*s\n' "$width" '' | tr ' ' '-';
}

PressAnyKeyToContinue()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	if [ -t 0 ]; then
		echo	"Press any key to continue...";
		stty -echo -icanon
		input=$(dd bs=1 count=1 2>/dev/null)
		stty sane
	else
		echo	"Press Enter/Return to continue...";
		read -n 1 input;
	fi
	printf '%*s\n' "$width" '' | tr ' ' '-';
}

while true; do
	width=$(tput cols);
	if ([ $CLEARING = true ]); then
		clear;
	fi

	case $MENU in
		-1)	break ;;
		0)	MainMenu;;
		1)	ArchLinuxToolsMenu;;
		2)	DiskPartitionMenu;;
		3)	FileSystemMenu;;
		4)	ConfigurationsMenu;;
		5)	PackagesMenu;;
		6)	CrossCompilationMenu;;
		50) DisplayEnv;;
		97)	ResourceMenu;;
		98) SpaceMenu;;
		99)	SettingsMenu;;
		*)	echo	"${C_RED}Error${C_RESET}: Invalid menu '$MENU;";
			exit $MENU;;
	esac
done

exit 0;

# while true; do
# 	width=$(tput cols)
# 	if ([ $CLEARING = true ]); then
# 		clear;
# 	fi
# 	printf '%*s\n' "$width" '' | tr ' ' '-'

# 	echo	"Arch linux setup for LFS";
# 	printf '%*s\n' "$width" '' | tr ' ' '-'
# 	echo	"d)\tDisk Partitioning";
# 	echo	"f)\tFormatting of File System";
# 	echo	"m)\tMounting";
# 	echo	"p)\tPackages";
# 	printf '%*s\n' "$width" '' | tr ' ' '-'
# 	echo	"s[x])\tShow relevant type (i.e. sd for disk list)";
# 	echo	"c)\tToggle screen clearing ($CLEARING)";
# 	echo	"q)\tQuit";
# 	printf '%*s\n' "$width" '' | tr ' ' '-';
# 	echo	"$MSG";
# 	unset MSG;
# 	echo -n	"Choose an option: ";
# 	read	input;

# 	if ([ $CLEARING = true ]); then
# 		clear;
# 	fi
# 	case "$input" in
# 		d|D)
# 			CreateNewPartioning;
# 			echo;
# 			DisplayPartioning;
# 			;;
# 		sd|SD)
# 			DisplayPartioning;
# 			;;
# 		f|F)
# 			FormatFileSystems;
# 			echo;
# 			DisplayFileSystems;
# 			;;
# 		sf|SF)
# 			DisplayFileSystems;
# 			;;
# 		m|M)
# 			MountPartitions;
# 			echo;
# 			DisplayMounts;
# 			;;
# 		sm|SM)
# 			DisplayMounts;;
# 		p|P)
# 			DownloadPackages;
# 			echo;
# 			DisplayPackages;
# 			;;
# 		sp|SP)
# 			DisplayPackages;
# 			;;
# 		c|C)
# 			CLEARING=$( [ "$CLEARING" = true ] && echo false || echo true )
# 			continue;;
# 		q|Q)
# 			echo "Exiting...";
# 			break;;
# 		*)
# 			MSG="Invalid input '$input'";
# 			continue;;
# 	esac

# 	PressAnyKeyToContinue;
# 	case "$input" in
# 		q|Q)
# 			echo "Exiting...";
# 			break;;
# 	esac
# done

# exit 0;

