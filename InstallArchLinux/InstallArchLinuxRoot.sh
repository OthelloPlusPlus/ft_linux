#! /bin/bash

source Utils.sh

Disk="/dev/sda"
LFS="/mnt/lfs"

# =====================================||===================================== #
#																			   #
#								Disk Partioning								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

CreateNewPartioning()
{
	# Quick clear to ensure script functions as expected
	FdiskCmd="";
	AddToFdiskCmd "o" "n" "p" "" "" "y" "w";
	fdisk ${Disk} &> /dev/null <<EOF
${FdiskCmd}
EOF

	FdiskCmd="";
	# Create a new empty MBR (DOS) partition table
	AddToFdiskCmd "o";
	# Add new Primary Partitions (max 3)
	AddToFdiskCmd "n" "p" "1" "" "+1GB"; 	# 1 /boot
	AddToFdiskCmd "n" "p" "2" "" "+4GB"; 	# 2 swap
	AddToFdiskCmd "n" "p" "3" "" "+30GB"; 	# 3 ArchLinux /mnt
	# Add Extended Partition (max 1, allows for logical partitions)
	AddToFdiskCmd "n" "e" "" "";
	# Add Logical Partitions
	AddToFdiskCmd "n" "" "-250GB"; 	# 5 /mnt/lfs
	AddToFdiskCmd "n" "" "+50GB"; 	# 6 /mnt/lfs/home
	AddToFdiskCmd "n" "" "+50GB"; 	# 7 /mnt/lfs/usr/src
	AddToFdiskCmd "n" "" "+10GB"; 	# 8 /mnt/lfs/opt
	# Make Bootable
	AddToFdiskCmd "a" "1"; # 1
	# Set Types
	AddToFdiskCmd "type" "1" "83"; 	# 1 Linux
	AddToFdiskCmd "type" "2" "82"; 	# 2 Linux swap / Solaris
	AddToFdiskCmd "type" "3" "83"; 	# 3 Linux
	AddToFdiskCmd "type" "5" "83"; 	# 5 Linux
	AddToFdiskCmd "type" "6" "83"; 	# 6 Linux
	AddToFdiskCmd "type" "7" "83"; 	# 7 Linux
	AddToFdiskCmd "type" "8" "83"; 	# 8 Linux
	# Write partitions to disk
	AddToFdiskCmd "w";

	# Actually execute commands using fdisk
	fdisk ${Disk} &> /dev/null <<EOF
${FdiskCmd}
EOF
}

AddToFdiskCmd()
{
	for arg in "$@"; do
	FdiskCmd="$FdiskCmd$arg
";
	done
}

FormatPartitions()
{
	mkfs.ext2 	"${Disk}1" -L "/boot" 1> /dev/null;
	mkswap 		"${Disk}2" -L "swap" 1> /dev/null;
	mkfs.ext4 	"${Disk}3" -L "/ [ArchLinux]" 1> /dev/null;

	mkfs.ext4 	"${Disk}5" -L "/" 1> /dev/null;
	mkfs.ext4 	"${Disk}6" -L "/home" 1> /dev/null;
	mkfs.ext4 	"${Disk}7" -L "/usr/src" 1> /dev/null;
	mkfs.ext4 	"${Disk}8" -L "/opt" 1> /dev/null;
}

MountPartitions()
{
	echo "makedir here"
	mkdir -p "${LFS}";
	echo "makedir done";

	MountPartitionTo	"/boot"		"/boot";
	# MountPartitionTo	"/boot"		"${LFS}/boot";
	swapon				"${Disk}2"	1> /dev/null;
	MountPartitionTo	"/ [ArchLinux]"		"/mnt";

	MountPartitionTo	"/"			"${LFS}";
	MountPartitionTo	"/home"		"${LFS}/home";
	MountPartitionTo	"/usr/src"	"${LFS}/usr/src";
	MountPartitionTo	"/opt"		"${LFS}/opt";
}

MountPartitionTo()
{
	local Label="$1";
	local MountPoint="$2";

	mkdir -p "${MountPoint}" 1> /dev/null;
	if ! mount | grep -q "on ${MountPoint} "; then
		mount -L "${Label}" "${MountPoint}";
	fi
}

# =====================================||===================================== #
#																			   #
#									Binaries								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

InstallArchLinuxBinaries()
{
	pacman -Sy --noconfirm archlinux-keyring

	pacstrap /mnt 	base linux linux-firmware \
					bash \
					binutils \
					bison \
					coreutils \
					diffutils \
					findutils \
					gawk \
					gcc \
					grep \
					gzip \
					m4 \
					make \
					patch \
					perl \
					python \
					sed \
					tar \
					texinfo \
					xz \
					zsh \
					grub \
					dhcpcd \
					openssh
}

# =====================================||===================================== #
#																			   #
#									Execution								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

# Update System Clock
timedatectl set-ntp true

# Configure Partitions
EchoInfo "Create Partitions";
CreateNewPartioning;
EchoInfo "Format Partitions";
FormatPartitions;
EchoInfo "Mount Partitions";
MountPartitions;
EchoInfo "Partions:";
lsblk -o NAME,MAJ:MIN,FSUSED,SIZE,FSUSE%,TYPE,FSTYPE,LABEL,MOUNTPOINTS;

# Setup ArchLinux
EchoInfo "Installing Binaries for ArchLinux";
InstallArchLinuxBinaries;
# Generate an fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Setup ArchLinux as arch-chroot
mv InstallArchLinuxChroot.sh /mnt
cp colors.sh Utils.sh /mnt
EchoInfo	"Logging in as arch-chroot. Next command needs to be run manually:"
echo "> ./InstallArchLinuxChroot.sh"
arch-chroot /mnt
