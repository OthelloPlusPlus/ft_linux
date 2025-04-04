
source Utils.sh

PDIR=/sources/lfs-packages12.2/

ReExtractPackage()
{
	local SRC="${1}${2}${3}";
	local DST="${1}";
	local RSLT="${1}${2}";

	if [ ! -f "$SRC" ] || [ ! -d "$DST" ]; then
		EchoError	"ReExtractPackage SRC[$SRC] DST[$DST]";
		# return false;
		return 1;
	fi

	if [ -d "$RSLT" ]; then
		rm -rf "$RSLT";
	fi

	tar -xf "$SRC" -C "$DST";
}

# =====================================||===================================== #
#						9.2. LFS-Bootscripts-20240825						   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLFSBootscript;
PackageLFSBootscript[Name]="lfs-bootscript";
PackageLFSBootscript[Version]="20240825";
PackageLFSBootscript[Extension]=".tar.xz";
PackageLFSBootscript[Package]="${PackageLFSBootscript[Name]}-${PackageLFSBootscript[Version]}${PackageLFSBootscript[Extension]}";

InstallLFSBootscript()
{
	EchoInfo	"Package ${PackageLFSBootscript[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLFSBootscript[Name]}-${PackageLFSBootscript[Version]}"	"${PackageLFSBootscript[Extension]}";

	if ! cd "${PDIR}${PackageLFSBootscript[Name]}-${PackageLFSBootscript[Version]}"; then
		EchoError	"cd ${PDIR}${PackageLFSBootscript[Name]}-${PackageLFSBootscript[Version]}";
		return;
	fi

	EchoInfo	"${PackageLFSBootscript[Name]}> make install"
	make install 1> /dev/null && PackageLFSBootscript[Status]=$? || { PackageLFSBootscript[Status]=$?; EchoTest KO ${PackageLFSBootscript[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#							9.4. Managing Devices							   #
# ===============ft_linux==============||==============©Othello=============== #

bash /usr/lib/udev/init-net-rules.sh

echo "--- Custom Udev Rules ---"
echo '/etc/udev/rules.d/70-persistent-net.rules'
for pair in $(grep "^SUBSYSTEM" "etc/udev/rules.d/70-persistent-net.rules"); do
	printf "${C_BOLD}%-${NameLength}s${C_RESET} %-s\n"	"$(echo \"$pair\" | cut -d= -f1 | tr -d '"')" \
														"$(echo \"$pair\" | cut -d= -f2- | tr -d '"=,')"
done
PressAnyKeyToContinue;

sed -e '/^AlternativeNamesPolicy/s/=.*$/=/' \
/usr/lib/udev/network/99-default.link \
> /etc/udev/network/99-default.link

# udevadm test /sys/block/hdd

# sed -e 's/"write_cd_rules"/"write_cd_rules mode"/' \
# 	-i /etc/udev/rules.d/83-cdrom-symlinks.rules

# =====================================||===================================== #
#					9.5. General Network Configuration						   #
# ===============ft_linux==============||==============©Othello=============== #

# 9.5.1. Creating Network Interface Configuration Files
cd /etc/sysconfig/
cat > ifconfig.eth0 << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=192.168.1.2
GATEWAY=192.168.1.1
PREFIX=24
BROADCAST=192.168.1.255
EOF

# 9.5.2. Creating the /etc/resolv.conf File
cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf
domain <Your Domain Name>
nameserver <IP address of your primary nameserver>
nameserver <IP address of your secondary nameserver>
# End /etc/resolv.conf
EOF

# 9.5.3. Configuring the System Hostname
echo "$StoredHostName" > /etc/hostname

# 9.5.4. Customizing the /etc/hosts File
# IP_address myhost.example.org aliases

StoredHostName="ohengelm"
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

# =====================================||===================================== #
#			9.6. System V Bootscript Usage and Configuration				   #
# ===============ft_linux==============||==============©Othello=============== #

# 9.6.2. Configuring SysVinit
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

cat > /etc/sysconfig/clock << "EOF"
# Begin /etc/sysconfig/clock

UTC=1

# Set this to any options you might need to give to hwclock,
# such as machine hardware clock type for Alphas.
CLOCKPARAMS=

# End /etc/sysconfig/clock
EOF

# 9.6.5. Configuring the Linux Console
cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

UNICODE="1"
FONT="Lat2-Terminus16"

# End /etc/sysconfig/console
EOF

9.6.6. Creating Files at Boot
9.6.7. Configuring the Sysklogd Script
9.6.8. The rc.site File

# =====================================||===================================== #
#					9.7. Configuring the System Locale						   #
# ===============ft_linux==============||==============©Othello=============== #

LocaleName=$(locale -a | grep "^en_US" | grep "utf")

LC_ALL=$LocaleName locale language
LC_ALL=$LocaleName locale charmap
LC_ALL=$LocaleName locale int_curr_symbol
LC_ALL=$LocaleName locale int_prefix

# /etc/profile
cat > /etc/profile << "EOF"
# Begin /etc/profile

for i in $(locale); do
    unset ${i%=*}
done

if [[ "$TERM" = linux ]]; then
    export LANG=C.UTF-8
# else
#     export LANG=<ll>_<CC>.<charmap><@modifiers>
fi

# End /etc/profile
EOF

# =====================================||===================================== #
#					9.8. Creating the /etc/inputrc File						   #
# ===============ft_linux==============||==============©Othello=============== #

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

# =====================================||===================================== #
#					9.9. Creating the /etc/shells File						   #
# ===============ft_linux==============||==============©Othello=============== #

cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash
/bin/zsh

# End /etc/shells
EOF

# =====================================||===================================== #
#						10.2. Creating the /etc/fstab File					   #
# ===============ft_linux==============||==============©Othello=============== #

cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system   mount-point     type        options             dump    fsck order
/dev/sda1       /               ext4        defaults            1       1
/dev/sda5       swap            swap        pri=1               0       0
proc            /proc           proc        nosuid,noexec,nodev 0       0
sysfs           /sys            sysfs       nosuid,noexec,nodev 0       0
devpts          /dev/pts        devpts      gid=5,mode=620      0       0
tmpfs           /run            tmpfs       defaults            0       0
devtmpfs        /dev            devtmpfs    mode=0755,nosuid    0       0
tmpfs           /dev/shm        tmpfs       nosuid,nodev        0       0
cgroup2/        /sys/fs/cgroup  cgroup2     nosuid,noexec,nodev 0       0

# End /etc/fstab
EOF

# =====================================||===================================== #
#								10.3. Linux-6.10.5							   #
# ===============ft_linux==============||==============©Othello=============== #

tar -xf /sources/lfs-packages12.2/linux-6.10.5.tar.xz -C /sources/lfs-packages12.2/
cd /sources/lfs-packages12.2/linux-6.10.5

# 10.3.1. Installation of the kernel

make mrproper

make menuconfig
# opens menu where settigs have to be adjusted

# General setup --->
# 	[ ] Compile the kernel with warnings as errors										[WERROR]
# 	CPU/Task time and stats accounting --->
# 		[*] Pressure stall information tracking											[PSI]
# 		[ ] 	Require boot parameter to enable pressure stall information tracking	[PSI_DEFAULT_DISABLED]

# 	< > Enable kernel headers through /sys/kernel/kheaders.tar.xz						[IKHEADERS]
# 	[*] Control Group support --->														[CGROUPS]
# 		[*] Memory controller															[MEMCG]
# 	[ ] Configure standard kernel features (expert users) --->							[EXPERT]

# Processor type and features --->
# 	[*] Build a relocatable kernel														[RELOCATABLE]
# 	[*] 	Randomize the address of the kernel image (KASLR)							[RANDOMIZE_BASE]
#64	[*] Support x2apic																	[X86_X2APIC]

# General architecture-dependent options --->
# 	[*] Stack Protector buffer overflow detection										[STACKPROTECTOR]
# 	[*] 	Strong Stack Protector														[STACKPROTECTOR_STRONG]
# 
# Device Drivers --->
# 	Generic Driver Options --->
# 		[ ] Support for uevent helper													[UEVENT_HELPER]
# 		[*] Maintain a devtmpfs filesystem to mount at /dev								[DEVTMPFS]
# 		[*] Automount devtmpfs at /dev, after the kernel mounted the rootfs				[DEVTMPFS_MOUNT]

# 	Graphics support --->
# 		< /*/M> Direct Rendering Manager (XFree86 4.1.0 and higher DRI support) --->	[DRM]

# 			# If [DRM] is selected as * or M, this must be selected:
# 				[ /*] Enable legacy fbdev support for your modesetting driver			[DRM_FBDEV_EMULATION]

# 		Console display driver support --->
# 			# If [DRM] is selected as * or M, this must be selected:
# 				[ /*] Framebuffer Console support										[FRAMEBUFFER_CONSOLE]

#64	[*] PCI support --->																[PCI]
#64		[*] Message Signaled Interrupts (MSI and MSI-X)									[PCI_MSI]
#64	[*] IOMMU Hardware Support --->														[IOMMU_SUPPORT]
#64		[*] Support for Interrupt Remapping												[IRQ_REMAP]

make

make modules_install

EchoInfo "This is where things go wrong"
EchoInfo	"Boot complained about not finding /boot/vmlinuz-6.10.5-lfs-12.2"
cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.10.5-lfs-12.2
cp -iv System.map /boot/System.map-6.10.5
cp -iv .config /boot/config-6.10.5
cp -r Documentation -T /usr/share/doc/linux-6.10.5

# 10.3.2. Configuring Linux Module Load Order
install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF

# =====================================||===================================== #
#					10.4. Using GRUB to Set Up the Boot Process				   #
# ===============ft_linux==============||==============©Othello=============== #

grub-install /dev/sda

cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod part_gpt
insmod ext2
set root=(hd0,1)

menuentry "GNU/Linux, Linux 6.10.5-lfs-12.2" {
        linux   /boot/vmlinuz-6.10.5-lfs-12.2   root=/dev/sda2  ro
}
EOF

# =====================================||===================================== #
#								11.1. The End								   #
# ===============ft_linux==============||==============©Othello=============== #

echo 12.2 > /etc/lfs-release

cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="12.2"
DISTRIB_CODENAME="ohengelm"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

cat > /etc/os-release << "EOF"
NAME="Linux From Scratch"
VERSION="12.2"
ID=lfs
PRETTY_NAME="Linux From Scratch 12.2"
VERSION_CODENAME="ohengelm"
HOME_URL="https://www.linuxfromscratch.org/lfs/"
EOF

# =====================================||===================================== #
#							11.3. Rebooting the System						   #
# ===============ft_linux==============||==============©Othello=============== #

logout

umount -v $LFS/dev/pts
mountpoint -q $LFS/dev/shm && umount -v $LFS/dev/shm
umount -v $LFS/dev
umount -v $LFS/run
umount -v $LFS/proc
umount -v $LFS/sys

umount -v "$LFS/tmp";
umount -v "$LFS/opt";
umount -v "$LFS/usr/src";
umount -v "$LFS/usr";
umount -v "$LFS/home";
umount -v "$LFS/boot/efi";
umount -v "$LFS/boot";
umount -v "$LFS";