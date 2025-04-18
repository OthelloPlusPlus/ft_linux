#! /bin/zsh

source Utils.sh

MirrorSite=mirror.koddos.net
MirrorURL=https://${MirrorSite}/lfs/lfs-packages/12.2/
DEST="$LFS/sources/lfs-packages12.2/"

UserName=ArchUser;
UserShell=/bin/bash

# =====================================||===================================== #
#																			   #
#						Chapter 3. Packages and Patches						   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

DownloadPackages()
{
	mkdir -p -m 777 "$LFS/sources";
	command -v wget >/dev/null 2>&1 || pacman -Sy wget

	wget -r -np -m --wait=0.1 --timeout=8 -nH --cut-dirs=4 -P "$DEST" "$MirrorURL" \
		-A "md5sums,*.tar.xz,*.tar.gz,*.tar.bz2,*.patch" -nv;
}

DownloadBonusPackages()
{
	# wget
	wget -P "$LFS/usr/src" "https://ftp.gnu.org/gnu/wget/wget-1.25.0.tar.gz"
	# certificates
	mkdir "$LFS/usr/src/make-ca"
	wget -P "$LFS/usr/src/make-ca" "http://anduin.linuxfromscratch.org/BLFS/other/make-ca.sh-20170514"
	wget -P "$LFS/usr/src/make-ca" "http://anduin.linuxfromscratch.org/BLFS/other/certdata.txt"
	# BLFS bootscrpit
	wget -P "$LFS/usr/src" "https://anduin.linuxfromscratch.org/BLFS/blfs-bootscripts/blfs-bootscripts-20250225.tar.xz"
	# openssh
	wget -P "$LFS/usr/src" "https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.9p2.tar.gz"
	# lynx
	wget -P "$LFS/usr/src" "https://invisible-mirror.net/archives/lynx/tarballs/lynx2.9.2.tar.bz2"
	# zsh
	wget -P "$LFS/usr/src" "https://www.zsh.org/pub/zsh-5.9.tar.xz"
	# curl
	wget -P "$LFS/usr/src" "https://curl.se/download/curl-8.13.0.tar.xz"
}

RemoveSubDirectories()
{
	while read -r checksum filename; do
	    dirname=$(echo "$filename" | sed -E 's/\.(tar\.(gz|xz|bz2)|patch)$//')
		if [ -d $DEST/$dirname ]; then
			rm -r $DEST/$dirname;
		fi
	done < $DEST/md5sums
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
	printf '%*s\n' "$Width" '' | tr ' ' '-';

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

# =====================================||===================================== #
#																			   #
#						 Chapter 4. Final Preparations						   #
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
	chown -R ${UserName} $LFS;
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
LFS=${LFS}
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
		RunAll)	DownloadPackages;
				CreateDirectoryLayout;
				AddUserToLFS;
				CreateLFSEnvironment;
				RemoveSubDirectories;;
		*)		echo "Bad flag: '$1'";;
	esac
	exit;
fi

while true; do
	Width=$(tput cols);
	clear;

	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"${C_ORANGE}${C_BOLD}Packages${C_RESET}";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo -n	"Mirror:      "; ping -c 1 $MirrorSite 1> /dev/null && echo -n "${C_GREEN}" || echo -n "${C_RED}" && echo "$MirrorURL${C_RESET}";
	echo -n	"Directory:   "; [ -d $DEST ] 1> /dev/null && echo -n "${C_GREEN}" || echo -n "${C_RED}" && echo "$DEST${C_RESET}";
	
	if [ -d $DEST ]; then
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
	fi

	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"0)\t Download Packages and Setup Host System";
	echo	"3)\t Download Packages";
	echo	"4)\t Create a Limited Directory Layout";
	echo	"5)\t Add the LFS User";
	echo	"6)\t Set Up the Environment";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"p)\t Display Packages";
	echo	"d)\t Display Directory Layout";
	echo	"e)\t Display Environment";
	echo	"b)\t Display Bash Config Files";
	[ -d $DEST ] 1> /dev/null && printf	"r)\t Remove Directories (%s)\n" "$(find $DEST -mindepth 1 -maxdepth 1 -type d | wc -l)";
	echo	"q)\t Return to main menu";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	$LocalCommand;
	unset LocalCommand;
	echo -n	"Input> ";

	GetKeyPress;
	case $input in
		0)	DownloadPackages;
			CreateDirectoryLayout;
			AddUserToLFS;
			CreateLFSEnvironment;;
		3)	DownloadPackages;
			DownloadBonusPackages;;
		4)	CreateDirectoryLayout;;
		5)	AddUserToLFS;;
		6)	CreateLFSEnvironment;;
		r)	RemoveSubDirectories;;
		p)	local LocalCommand=DisplayPackages;;
		d)	local LocalCommand=DisplayDirectoryLayout;;
		e)	local LocalCommand=DisplayEnvironment;;
		b)	local LocalCommand=DisplayBashConfigFiles;;
		q)	exit;;
	esac
done
