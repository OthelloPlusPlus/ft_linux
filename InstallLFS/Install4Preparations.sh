#! /bin/zsh

source Utils.sh

UserName=ArchUser;
UserShell=/bin/bash

# =====================================||===================================== #
#																			   #
#									Functions								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

CreateDirectoryLayout()
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

AddUserToLFS()
{
	groupadd "${UserName}";
	useradd -s "${UserShell}" -g "${UserName}" -m -k /dev/null "${UserName}";
	# passwd ${Username}
	cp "/root/default.zshrc" "/home/$UserName/.zshrc";

	chown -v ${UserName} $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
	case $(uname -m) in
		x86_64) chown -v lfs $LFS/lib64 ;;
	esac
	# chown -R ${UserName} $LFS;
}

CreateLFSEnvironment()
{
	su - ${UserName} << EOSU
echo "Creating ~/.bash_profile"
cat > ~/.bash_profile << "EOF"
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
}

DisplayDirectoryLayout()
{
	ls -l $LFS;
	printf '%*s\n' "$Width" '' | tr ' ' '-';
}

DisplayEnvironment()
{
	su - ${UserName} << EOF
env
EOF
	printf '%*s\n' "$Width" '' | tr ' ' '-';
}

DisplayBashConfigFiles()
{
	EchoInfo	"~/.bash_profile";
	su - ${UserName} << EOF
	cat ~/.bash_profile
EOF

	EchoInfo	"~/.bashrc";
	su - ${UserName} << EOF
	cat ~/.bashrc
EOF
	printf '%*s\n' "$Width" '' | tr ' ' '-';
}

# =====================================||===================================== #
#																			   #
#									Execution								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

if [ $# -gt 0 ]; then
	case "$1" in
		RunAll)	CreateDirectoryLayout;
				AddUserToLFS
				CreateLFSEnvironment;;
		*)		echo "Bad flag: '$1'";;
	esac
	exit;
fi

while true; do
	Width=$(tput cols);
	clear;

	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"${C_ORANGE}${C_BOLD}Final Preparations${C_RESET}";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	printf "%-7s %-16s %-s\n" "UID" "NAME" "Home Directory";
	awk -F: '$3 >= 1000 && $3 <= 60000 {printf " %-6s  %-15s  %-s\n", $3, $1, $6}' /etc/passwd;
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"0)\t Configure all";
	echo	"1)\t Create a Limited Directory Layout";
	echo	"2)\t Add the LFS User";
	echo	"3)\t Set Up the Environment";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"d)\t Display directory layout";
	echo	"e)\t Display environment";
	echo	"b)\t Display bash config files";
	echo	"q)\t Return to main menu";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	$LocalCommand;
	unset LocalCommand;
	echo -n	"Input> ";

	GetKeyPress;
	case $input in
		0)	CreateDirectoryLayout;
			AddUserToLFS;
			CreateLFSEnvironment;;
		1)	CreateDirectoryLayout;;
		2)	AddUserToLFS;;
		3)	CreateLFSEnvironment;;
		d)	local LocalCommand=DisplayDirectoryLayout;;
		e)	local LocalCommand=DisplayEnvironment;;
		b)	local LocalCommand=DisplayBashConfigFiles;;
		q)	exit;;
	esac
done
