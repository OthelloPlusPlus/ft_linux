#!/bin/bash

if [ ! -z "${PackageXorgBuildEnv[Name]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									XorgBuildEnv								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXorgBuildEnv;
# PackageXorgBuildEnv[Source]="";
# PackageXorgBuildEnv[MD5]="";
PackageXorgBuildEnv[Name]="XorgBuildEnv";
# PackageXorgBuildEnv[Version]="";
# PackageXorgBuildEnv[Package]="${PackageXorgBuildEnv[Name]}-${PackageXorgBuildEnv[Version]}";
# PackageXorgBuildEnv[Extension]=".tar.xz";

# PackageXorgBuildEnv[Programs]="";
# PackageXorgBuildEnv[Libraries]="";
# PackageXorgBuildEnv[Python]="";

InstallXorgBuildEnv()
{
	# Check Installation
	CheckXorgBuildEnv && return $?;

	# Check Dependencies
	Dependencies=()
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh";
		fi
	done
	
	# Install Package
	_BuildXorgBuildEnv;
	return $?
}

CheckXorgBuildEnv()
{
	if [ -z "$XORG_PREFIX" ] || [ -z "$XORG_CONFIG" ]; then
		return 1;
	fi
	return 0;
}

CheckXorgBuildEnvVerbose()
{
	local ReturnValue=0;
	if [ -z "$XORG_PREFIX" ]; then echo -en "${C_RED}XORG_PREFIX[$XORG_PREFIX]${C_RESET} " >&2; ReturnValue=1; fi
	if [ -z "$XORG_CONFIG" ]; then echo -en "${C_RED}XORG_CONFIG[$XORG_CONFIG]${C_RESET} " >&2; ReturnValue=1; fi
	return $ReturnValue;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildXorgBuildEnv()
{
	EchoInfo	"Package ${PackageXorgBuildEnv[Name]}"

	EchoInfo	"${PackageXorgBuildEnv[Name]}> Exporting XORG_ variables"
	export XORG_PREFIX="/usr"
	export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var --disable-static"

	# if Zsh issues
	# set -o shwordsplit

	mkdir -p /etc/profile.d/

	EchoInfo	"${PackageXorgBuildEnv[Name]}> Setting variables to /etc/profile.d/xorg.sh"
	cat > /etc/profile.d/xorg.sh << EOF
XORG_PREFIX="$XORG_PREFIX"
XORG_CONFIG="--prefix=\$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var --disable-static"
export XORG_PREFIX XORG_CONFIG
EOF
chmod 644 /etc/profile.d/xorg.sh

	if [ -x /usr/bin/sudo ]; then
	EchoInfo	"${PackageXorgBuildEnv[Name]}> Setting variable instructions to /etc/sudoers.d/xorg"
	cat > /etc/sudoers.d/xorg << EOF
Defaults env_keep += XORG_PREFIX
Defaults env_keep += XORG_CONFIG
EOF
fi

	echo "${PackageXorgBuildEnv[Name]}> [$XORG_PREFIX][$XORG_CONFIG]" && PressAnyKeyToContinue;
}
