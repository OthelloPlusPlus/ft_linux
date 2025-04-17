#! /bin/bash

# =====================================||===================================== #
#																			   #
#									Functions								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

GetKeyPress()
{
    read -rsn 1 input
	if [[ "$input" == $'\e' ]]; then
		read -rsn 2 -t 0.1 input
		input=$'\e'"$input"
	fi
}

ClearKeygen()
{
	ssh-keygen -f "/home/ohengelm/.ssh/known_hosts" -R "[$ADDRESS]:$PORT";
}

CopyFile()
{
	SRC="$1"
	DEST="$2"

	scp -P $PORT $SRC $USER@$ADDRESS:$DEST
	if [ $? -eq 1 ]; then
		ClearKeygen;
		# ssh-keygen -f "/home/ohengelm/.ssh/known_hosts" -R "[127.0.0.1]:2222";
		scp -P $PORT $SRC $USER@$ADDRESS:$DEST
	fi
}

# RunFile()
# {
# 	FILE="$1"
# 	ssh -p $PORT $USER@$ADDRESS "chmod +x $FILE; $FILE;"
# }

RunCmd()
{
	Command="$1";
	# Dest="$2"
	ssh -p $PORT $USER@$ADDRESS -t "$Command"
}

# CopyAndRun()
# {
# 	FILE="$1"
# 	DEST="$2"

# 	CopyFile "$FILE" "$DEST"
# 	RunFile "$DEST/$FILE"
# }


# InstallPackage()
# {
# 	echo "Installing $1";
# }

CopyForArchLinux()
{
	CopyFile 	"Utils/*.sh InstallArchLinux/*.sh" \
				"/root";
}

CopyForLFS()
{
	CopyFile 	"Utils/*.sh InstallLFS/*.sh eval/*.sh" \
				"/root";
}

PORT=2222
USER=root
ADDRESS=127.0.0.1
PASSWD=xxxx

ClearKeygen;

while true; do
	Width=$(tput cols);
	clear;

	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"Install LFS through SSH";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	printf	"0)\t Copy ArchLinux\n"
	printf	"1)\t Install ArchLinux\n"
	printf	"2)\t Copy LFS\n"
	printf	"3)\t Install LFS\n"
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	printf	"4)\t Enter as Root\n"
	printf	"5)\t Enter as arch-chroot (ArchLinux Install)\n"
	printf	"6)\t Enter as ArchUser\n"
	printf	"7)\t Enter as Chroot\n"
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	printf	"q)\t exit\n"
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	if [ ! -z "$ErrorMsg" ]; then
		printf	"$ErrorMsg\n"
		printf '%*s\n' "$Width" '' | tr ' ' '-';
	fi
	printf	"Input: ";

	GetKeyPress;
	case "$input" in
		0)	CopyForArchLinux;;
		1)	CopyForArchLinux;
			RunCmd	"./InstallArchLinuxRoot.sh";;
		2)	CopyForLFS;;
		3)	CopyForLFS;
			RunCmd	"chmod +x Install*.sh; ./Install.sh";;
		4)	ssh -p $PORT $USER@$ADDRESS || ErrorMsg="Failed to enter as Root";;
		5)	ssh -p $PORT $USER@$ADDRESS -t "arch-chroot - ArchUser" || ErrorMsg="Failed to arch-chroot";;
		6)	ssh -p $PORT $USER@$ADDRESS -t "su - ArchUser" || ErrorMsg="Failed to enter as ArchUser";;
		7)	ssh -p $PORT $USER@$ADDRESS -t "chroot	\"/lfs\" /usr/bin/env -i	\
															HOME=/root	\
															TERM=\"$TERM\"	\
															PS1='(lfs chroot) \u:\w\$ '	\
															PATH=/usr/bin:/usr/sbin	\
															MAKEFLAGS=\"-j$(nproc)\"	\
															TESTSUITEFLAGS=\"-j$(nproc)\"	\
															/bin/bash --login" 	|| ErrorMsg="Failed to enter as Chroot";;
		q)	exit;;
	esac
done

exit

# PORT=2222
# USER=root
# ADDRESS=127.0.0.1
# PASSWD=xxxx

# COPYFILES="colors.sh default.zshrc BuildLFS.sh ConfigCrossToolchain.sh Util*.sh ConfigChroot.sh ConfigChrootPackages.sh eval/CheckBinaries.sh"
# RUNFILES="InstallArchLinux.sh"

# scp -P $PORT $COPYFILES $RUNFILES $USER@$ADDRESS:/root;
# if [ $? -eq 1 ]; then
# 	ssh-keygen -f "/home/ohengelm/.ssh/known_hosts" -R "[127.0.0.1]:2222";
# 	scp -P $PORT $COPYFILES $RUNFILES $USER@$ADDRESS:/root;
# fi
# # if [[ $- == *i* ]]; then
# #     echo "Shell is interactive"
# # else
# #     echo "Shell is not interactive"
# # fi
# ssh -p $PORT $USER@$ADDRESS -t "
# 	chmod +x $RUNFILES;
# 	zsh -i /root/InstallArchLinux.sh
# "
# # ssh -p $PORT $USER@$ADDRESS "
# # chmod +x $RUNFILES;
# # for file in $RUNFILES; do
# # 	/root/\$file;
# # done"

# # CopyAndRun	"InstallArchLinux.sh"	"/root"

# # scp -P $PORT ./InstallArchLinux.sh $USER@$ADDRESS:/root
# # ssh -p $PORT $USER@$ADDRESS <<EOF
# # chmod +x /root/InstallArchLinux.sh;
# # /root/InstallArchLinux.sh;
# # EOF
# exit 0

# InstallPackage	"lorem"
# ssh -p 2222 root@127.0.0.1
# exit 0;
# echo -e "o\n n\n p\n 1\n \n \n w\n" | fdisk /dev/sda;
# mkfs.ext4 /dev/sda1;
# mount /dev/sda1 /mnt;

# mount /dev/sda1 /mnt
# mkdir -p /mnt/{dev,proc,sys,run}
# mount --bind /dev /mnt/dev
# mount --bind /run /mnt/run
# mount -t proc /proc /mnt/proc
# mount -t sysfs /sys /mnt/sys

# pacstrap /mnt base-devel zsh

# chroot /mnt /bin/zsh
# ln -sf /proc/self/mounts /etc/mtab

# # cat /etc/mtab

# # pacman -Sy inetutils
# # # pacman -Sy base-devel

# curl -O https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.63.tar.xz

# tar -xvf linux-6.6.63.tar.xz


# # # Arch Linux Installation
# # #	https://wiki.archlinux.org/title/Installation_guide

# # echo "Information:";
# # env | grep SHELL;

# # # 1.5 Set the console keyboard layout and font

# # # 1.6 Verify the boot mode

# # # 1.7 Connect to the internet
# # ip link

# # # 1.8 Update the system clock
# # timedatectl;

# # # 1.9 Partition the disks
# # DISK="/dev/sda"
# # PART="/dev/sda1"

# # echo Partitioning ${DISK};

# # # fdisk - manipulate disk partition table
# # #	https://man7.org/linux/man-pages/man8/fdisk.8.html

# # if [ ! command -v fdisk > /dev/null ]; then
# # 	echo "Error: fdisk is not installed";
# # 	exit 1;
# # fi

# # if [ ! -b ${DISK} ]; then
# # 	echo "Error: Could not find '${DISK}'";
# # 	exit 1;
# # fi

# # if [ ! command -v fdisk ${PART} ]; then
# # 	echo "Creating ${PART}";
# # 	echo -e "o\n n\n p\n 1\n \n \n w\n" | fdisk ${DISK};
# # else
# # 	echo "${PART} already exists";
# # fi

# # # mkfs - build a Linux filesystem
# # #	https://man7.org/linux/man-pages/man8/mkfs.8.html

# # if ! mount | grep ${PART}; then

# # 	echo "Formatting ${PART} with ext4 filesystem";
# # 	if ! mkfs.ext4 ${PART} > /dev/null; then
# # 		echo "Error: Failed to format ${PART}";
# # 		exit 1;
# # 	fi

# # 	# mount - mount a filesystem
# # 	#	https://man7.org/linux/man-pages/man8/mount.8.html

# # 	echo "Mounting ${PART} to /mnt";
# # 	if ! mount ${PART} /mnt > /dev/null; then
# # 		echo "Error: Failed to mount ${PART}";
# # 		exit 1;
# # 	fi
# # fi





# # # Mount the partition
# # echo "Mounting /dev/sda1 to /mnt"
# # if ! mount /dev/sda1 /mnt; then
# #     echo "Error: Failed to mount /dev/sda1"
# #     exit 1
# # fi

# # # Prepare chroot environment
# # echo "Preparing chroot environment"
# # pacman -Sy --noconfirm arch-install-scripts

# # # Mount necessary filesystems for chroot
# # mount -t proc /proc /mnt/proc
# # mount --rbind /sys /mnt/sys
# # mount --rbind /dev /mnt/dev
# # mount --rbind /run /mnt/run

# # # Enter the chroot environment
# # echo "Entering chroot environment"
# # arch-chroot /mnt

# # # Update the system and install necessary packages
# # echo "Installing required packages"
# # pacman -S --noconfirm base-devel linux-headers

# # # Extract and install the Linux kernel (assuming you have the tarball)
# # cd /usr/src
# # tar -xvf /path/to/linux-6.6.63.tar.xz
# # cd linux-6.6.63

# # # Configure the kernel (this step is manual and might need modifications based on your requirements)
# # make menuconfig

# # # Compile the kernel
# # echo "Compiling the Linux kernel"
# # make -j$(nproc)

# # # Install the kernel
# # make modules_install
# # make install

# # # Exit chroot and unmount
# # exit
# # umount -R /mnt
# # echo "Linux kernel installation complete"