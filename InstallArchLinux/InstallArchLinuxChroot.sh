#! /bin/bash

source Utils.sh

ArchLinuxName="ArchLinux";
SuperSecretPassword="S";
Region="Europe";
City="Amsterdam";

# =====================================||===================================== #
#																			   #
#									Functions								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

EnableService()
{
	local Service="$1";

	systemctl enable ${Service};
	systemctl start ${Service};
}

EnableInternetAndSSH()
{
	# Enable Internet
	EnableService dhcpcd;
	EnableService sshd;

	# Allow SSH configuration
	local SSH_File="/etc/ssh/sshd_config.d/10-archiso.conf"
	if [ ! -f ${SSH_File} ]; then
		touch ${SSH_File};
	fi

	if [ $(grep "^PasswordAuthentication" ${SSH_File} -c) -eq 0 ]; then
		echo "PasswordAuthentication yes" >> ${SSH_File};
	fi
	if [ $(grep "^PermitRootLogin" ${SSH_File} -c) -eq 0 ]; then
		echo "PermitRootLogin yes" >> ${SSH_File};
	fi
	# grep -Ev "^#|^$" /etc/ssh/sshd_config
}

# =====================================||===================================== #
#																			   #
#									Execution								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

# Configure time
ln -sf /usr/share/zoneinfo/${Region}/${City} /etc/localtime
hwclock --systohc

# Localization
sed -i 's/^#\(en_US\.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Network
echo "${AchLinuxName}" > /etc/hostname

# Passwd
passwd << EOF
${SuperSecretPassword}
${SuperSecretPassword}
EOF

EnableInternetAndSSH;

# Setting boot
EchoInfo	"Grub Install - Install GRUB to a device";
grub-install --target=i386-pc /dev/sda
EchoInfo	"Grub Mkconfig - Generate a GRUB configuration file";
grub-mkconfig -o /boot/grub/grub.cfg

EchoInfo	"Grub Installed and configured";
EchoInfo	"Now shutdown VM and reboot from ${C_ORANGE}Hard Disk${C_RESET} (.vdi)";
EchoInfo	"VM > Settings > System > Motherboard > Boot Order";
