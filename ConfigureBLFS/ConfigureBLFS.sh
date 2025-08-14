#! /bin/bash

source Utils.sh

export ScriptPath="/usr/src/shpkg"

# =====================================||===================================== #
#																			   #
#									Network									   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

ConfigureNetwork()
{
	cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf
domain codam.nl

# DNS resolution
# Local Caching Resolver
nameserver 127.0.0.53
# Quad9
nameserver 9.9.9.9
# Surfnet (NL)
nameserver 145.100.100.100
# Freenom World
nameserver 80.80.80.80
# Cloudflare
nameserver 1.1.1.1
# OpenDNS
nameserver 208.67.222.222
# Google DNS
nameserver 8.8.8.8

option edns0

# End /etc/resolv.conf
EOF
}

# =====================================||===================================== #
#																			   #
#									New Users								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

# skel files are copied by useradd to all new users
# - /etc/skel
# - cat /etc/default/useradd
PrepareSkel()
{
	# Ensuring /etc/skel
	if [ ! -d /etc/skel ]; then mkdir /etc/skel; fi

	# .zshrc
	cat > /etc/skel/.zshrc << EOF
# zsh-new-user-install
## History Configuration
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

## Common shell options
# unsetopt autocd
unsetopt autocd
# unsetopt extendedglob
unsetopt extendedglob
# setopt nomatch
setopt nomatch
# setopt beep
unsetopt nobeep
# unsetopt notify
unsetopt notify

# # compinstall
# zstyle :compinstall filename '$HOME/.zshrc'

autoload -Uz compinit
compinit
EOF
}

CreateNewUser()
{
	local NewUser="$1";

	useradd -m -G root -s /bin/zsh "$NewUser"
	passwd "$NewUser" << EOF
S
S
S
EOF
# 	cat > /home/$NewUser/.zshrc << EOF
# # zsh-new-user-install
# ## History Configuration
# HISTFILE=~/.histfile
# HISTSIZE=1000
# SAVEHIST=1000

# ## Common shell options
# # unsetopt autocd
# unsetopt autocd
# # unsetopt extendedglob
# unsetopt extendedglob
# # setopt nomatch
# setopt nomatch
# # setopt beep
# unsetopt nobeep
# # unsetopt notify
# unsetopt notify

# # compinstall
# zstyle :compinstall filename '/home/ohengelm/.zshrc'

# autoload -Uz compinit
# compinit

# EOF
}

# =====================================||===================================== #
#																			   #
#									  Bash									   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

# https://www.linuxfromscratch.org/blfs/view/stable/postlfs/profile.html
ConfigureBash()
{
	#/etc/profile
	# ConfigureBashProfile; now done in LFS, not BLFS as this shouldve been

	# /etc/profile.d
	EchoInfo "bash> Creating /etc/profile.d"
	install --directory --mode=0755 --owner=root --group=root /etc/profile.d

	# /etc/profile.d/PATH.sh
	ConfigureBashProfilePATH;
	# /etc/profile.d/lib64.sh
	ConfigureBashProfileLib64;
	# /etc/profile.d/pkgconf.sh
	ConfigureBashProfilePkgconf;
	# /etc/profile.d/ldlibs.sh
	ConfigureBashProfileLdLibs;
	# # /etc/profile.d/pkgsrc.sh
	# ConfigureBashProfilePkgsrc;
	# /etc/profile.d/rustc.sh
	ConfigureBashProfileRustc;

	# Ensuring permissions
	EchoInfo "bash> Setting permissions"
	chmod +x /etc/profile.d/*.sh
}

# ConfigureBashProfile()
# {
# 	EchoInfo "bash> Creating /etc/profile"
# 	cat > /etc/profile << "EOF"
# # Begin /etc/profile
# # System wide environment variables and startup programs.

# # System wide aliases and functions should go in /etc/bashrc.  Personal
# # environment variables and startup programs should go into
# # ~/.bash_profile.  Personal aliases and functions should go into
# # ~/.bashrc.

# # Functions to help us manage paths.  Second argument is the name of the
# # path variable to be modified (default: PATH)
# pathremove () {
#         local IFS=':'
#         local NEWPATH
#         local DIR
#         local PATHVARIABLE=${2:-PATH}
#         for DIR in ${!PATHVARIABLE} ; do
#                 if [ "$DIR" != "$1" ] ; then
#                   NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
#                 fi
#         done
#         export $PATHVARIABLE="$NEWPATH"
# }

# pathprepend () {
#         pathremove $1 $2
#         local PATHVARIABLE=${2:-PATH}
#         export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
# }

# pathappend () {
#         pathremove $1 $2
#         local PATHVARIABLE=${2:-PATH}
#         export $PATHVARIABLE="${!PATHVARIABLE:+${!PATHVARIABLE}:}$1"
# }

# export -f pathremove pathprepend pathappend

# # Set the initial path
# export PATH=/usr/bin

# # Attempt to provide backward compatibility with LFS earlier than 11
# if [ ! -L /bin ]; then
#         pathappend /bin
# fi

# if [ $EUID -eq 0 ] ; then
#         pathappend /usr/sbin
#         if [ ! -L /sbin ]; then
#                 pathappend /sbin
#         fi
#         unset HISTFILE
# fi

# # Set up some environment variables.
# export HISTSIZE=1000
# export HISTIGNORE="&:[bf]g:exit"

# # Set some defaults for graphical systems
# export XDG_DATA_DIRS=${XDG_DATA_DIRS:-/usr/share}
# export XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:-/etc/xdg}
# export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/tmp/xdg-$USER}

# for script in /etc/profile.d/*.sh ; do
#         if [ -r $script ] ; then
#                 . $script
#         fi
# done

# unset script

# # End /etc/profile
# EOF
# }

ConfigureBashProfilePATH()
{
	EchoInfo "bash> Creating /etc/profile.d/PATH.sh"

	cat > /etc/profile.d/PATH.sh << 'EOF'
for Directory in /usr/local/sbin /usr/local/bin /usr/bin /bin /usr/sbin /sbin; do
	case ":$PATH:" in
		*:"$Directory":*)	;;
		*)					[ -d "$Directory" ] && [ ! -L "$Directory" ] && PATH="${PATH:+$PATH:}$Directory";;
	esac
done
export PATH
EOF
}

ConfigureBashProfilePkgconf()
{
	EchoInfo "bash> Creating /etc/profile.d/pkgconf.sh"

	cat > /etc/profile.d/pkgconf.sh << 'EOF'
for Directory in /usr/lib64/pkgconfig /usr/lib/pkgconfig /usr/share/pkgconfig /usr/local/lib/pkgconfig; do
	case ":$PKG_CONFIG_PATH:" in
		*:"$Directory":*)	;;
		*)					[ -d "$Directory" ] && [ ! -L "$Directory" ] && PKG_CONFIG_PATH="${PKG_CONFIG_PATH:+$PKG_CONFIG_PATH:}$Directory";;
	esac
done
export PKG_CONFIG_PATH
EOF
}

ConfigureBashProfileLdLibs()
{
	EchoInfo "bash> Creating /etc/profile.d/ldlibs.sh"

	cat > /etc/profile.d/ldlibs.sh << 'EOF'
for Directory in /usr/lib64 /usr/local/lib64 /usr/local/lib; do
	case ":$LD_LIBRARY_PATH:" in
		*:"$Directory":*)	;;
		*)					[ -d "$Directory" ] && [ ! -L "$Directory" ] && LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$Directory";;
	esac
done
export LD_LIBRARY_PATH
EOF
}

ConfigureBashProfilePkgsrc()
{
	EchoInfo "bash> Creating /etc/profile.d/pkgsrc.sh"

	cat > /etc/profile.d/pkgsrc.sh << 'EOF'
export PATH=$PATH:/usr/pkg/sbin:/usr/pkg/bin
EOF
}

ConfigureBashProfileRustc()
{
	EchoInfo "bash> Creating /etc/profile.d/rustc.sh"

	cat > /etc/profile.d/rustc.sh << 'EOF'
export PATH=$PATH:/opt/rustc/bin
EOF
}

# =====================================||===================================== #
#																			   #
#									Execution								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

if which which &> /dev/null; then
	CheckBinary()
	{
		which "$1" &> /dev/null;
		return $?;
	}
else
	CheckBinary()
	{
		if test "$(whereis $1)" != "$1:"; then
			return 0;
		else
			return 1;
		fi
	}
fi

# Ensuring /usr/local/shell/colors.sh
if [ ! -d /usr/local/shell ]; then
	mkdir -p /usr/local/shell;
fi
if [ ! -f /usr/local/shell/colors.sh ]; then
	cp colors.sh /usr/local/shell/
fi

# Ensuring shman
if [ ! -d /usr/src/shman ]; then
	mkdir -p /usr/src/shman;
fi

# # Ensuring user
# if ! getent passwd ohengelm &> /dev/null; then
# 	EchoInfo	"Creating user ${C_ORANGE}ohengelm${C_RESET}..."
# 	CreateNewUser ohengelm;
# fi

# Ensuring DNS resolution
EchoInfo	"Testing Network and DNS...";
if ping -c 1 8.8.8.8 &>/dev/null; then
	EchoInfo	"Testing DNS...";
	if ping -c 1 -W 1 google.com &>/dev/null; then
		EchoInfo "✅ Network and DNS are working.";
	else
		EchoInfo "❌ DNS resolution failed. Configuring DNS...";
		ConfigureNetwork;
	fi
else
	EchoInfo "❌ Network is down. Configuring network...";
	ConfigureNetwork;
fi


while true; do
	Width=$(tput cols);

	clear;
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo -e	"${C_ORANGE}${C_BOLD}BLFS configuration${C_RESET}";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo -en "DNS:\t " && ping -c 1 -W 1 google.com &>/dev/null && echo -e "${C_GREEN}OK${C_RESET}" || echo -e "${C_RED}KO${C_RESET}";
	echo -en "useradd: " && [ -d /etc/skel ] && echo -e "${C_GREEN}/etc/skel${C_RESET}" || echo -e "${C_RED}KO${C_RESET}";
	echo -en "bash:\t " && [ -f /etc/profile ] && [ -d /etc/profile.d ] && echo -e "${C_GREEN}/etc/profile${C_RESET}" || echo -e "${C_RED}KO${C_RESET}";
	echo -en "User:\t " && getent passwd ohengelm &> /dev/null && echo -e "${C_GREEN}ohengelm${C_RESET}" || echo -e "${C_RED}KO${C_RESET}";
	echo -en "shman:\t " && [ -d /usr/src/shman ] && [ -e /usr/src/shman/shman.sh ] && echo -e "${C_GREEN}/usr/src/shman/shman.sh${C_RESET}" || echo -e "${C_RED}KO${C_RESET}";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo -e "d)\t configures DNS"
	echo -e "u)\t prepare useradd"
	echo -e "b)\t configure bash"
	echo -e "o)\t Add user ohengelm"
	echo -e "s)\t shman package manager"
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo -e	"q)\t Quit";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	if [ ! -z "$ErrorMsg" ]; then
		printf	"$ErrorMsg\n"
		unset ErrorMsg;
		printf '%*s\n' "$Width" '' | tr ' ' '-';
	fi

	printf	"Input> ";
	GetKeyPress

	case "$input" in
		d) ConfigureNetwork;;
		u) PrepareSkel;;
		b) ConfigureBash;;
		o) if ! getent passwd ohengelm &> /dev/null; then
				EchoInfo	"Creating user ${C_ORANGE}ohengelm${C_RESET}..."
				CreateNewUser ohengelm;
			fi ;;
		s) /usr/src/shman/shman.sh || PressAnyKeyToContinue;;
		# P)	source UtilInstallpkgsrc.sh;
		# 	InstallPkgsrc;;
		q|Q)	break;;
		*)	ErrorMsg="Bad input: $input";;
	esac
done
