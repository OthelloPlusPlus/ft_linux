#! /bin/zsh

source Utils.sh

UserName=ArchUser;

# =====================================||===================================== #
#																			   #
#									Functions								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

ChangeOwnershipForChroot()
{
	# Chaning ownership
	EchoInfo	"Changing ownership from $UserName to root"
	chown --from $UserName -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
	case $(uname -m) in
		x86_64) chown --from $UserName -R root:root $LFS/lib64 ;;
	esac

}

MountFileSystems()
{
	# Preparing Virtual Kernel File Systems
	EchoInfo	"Creating $LFS directories"
	mkdir -pv $LFS/{dev,proc,sys,run}

	EchoInfo	"Mounting $LFS directories"
	! mountpoint -q $LFS/dev 		&& mount -v --bind /dev $LFS/dev

	! mountpoint -q $LFS/dev/pts 	&& mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
	! mountpoint -q $LFS/proc 		&& mount -vt proc proc $LFS/proc
	! mountpoint -q $LFS/sys 		&& mount -vt sysfs sysfs $LFS/sys
	! mountpoint -q $LFS/run 		&& mount -vt tmpfs tmpfs $LFS/run

	EchoInfo	"Populating $LFS/dev"
	if [ -h $LFS/dev/shm ]; then
		install -v -d -m 1777 $LFS$(realpath /dev/shm)
	else
		mountpoint -q $LFS/dev/shm || mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm;
	fi
}

DisplayDirectoryList()
{
	ls -l $LFS;
	printf '%*s\n' "$Width" '' | tr ' ' '-';
}

DisplayMountStructure()
{
	findmnt --target $LFS --submounts;
	printf '%*s\n' "$Width" '' | tr ' ' '-';
}

# =====================================||===================================== #
#																			   #
#									Execution								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

if [ $# -gt 0 ]; then
	case "$1" in
		RunAll)	PrepareChrootForTemporaryTools;;
		*)		echo "Bad flag: '$1'";;
	esac
	exit;
fi

while true; do
	Width=$(tput cols);
	clear;

	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"${C_ORANGE}${C_BOLD}5. Compiling a Cross-Toolchain${C_RESET}";
	echo	"Option:\t${-}";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"0)\t Prepare Chroot";
	echo	"7)\t Change Ownership for Chroot";
	echo	"8)\t Mount Virtual Kernel File Systems";
	echo	"  \t   - This needs to repeated if rebooting (!)";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"l)\t Display $LFS directory list";
	echo	"m)\t Display $LFS mount structure";
	echo	"q)\t Return to main menu";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	$LocalCommand;
	unset LocalCommand;
	echo -n	"Input> ";

	GetKeyPress;
	case $input in
		0)	ChangeOwnershipForChroot;
			MountFileSystems;;
		7)	ChangeOwnershipForChroot || PressAnyKeyToContinue;;
		8)	MountFileSystems || { echo $?; PressAnyKeyToContinue; } ;;
		l)	local LocalCommand="DisplayDirectoryList";;
		m)	local LocalCommand="DisplayMountStructure";;
		q)	exit;;
	esac
done
