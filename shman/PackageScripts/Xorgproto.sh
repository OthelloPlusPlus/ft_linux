#!/bin/bash

if [ ! -z "${PackageXorgproto[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Xorgproto								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXorgproto;
PackageXorgproto[Source]="https://xorg.freedesktop.org/archive/individual/proto/xorgproto-2024.1.tar.xz";
PackageXorgproto[MD5]="12374d29fb5ae642cfa872035e401640";
PackageXorgproto[Name]="xorgproto";
PackageXorgproto[Version]="2024.1";
PackageXorgproto[Package]="${PackageXorgproto[Name]}-${PackageXorgproto[Version]}";
PackageXorgproto[Extension]=".tar.xz";

# PackageXorgproto[Programs]="";
# PackageXorgproto[Libraries]="";
# PackageXorgproto[Python]="";

InstallXorgproto()
{
	# Check Installation
	CheckXorgproto && return $?;

	# Check Dependencies
	Dependencies=(UtilMacros)
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	Optional=(LibXslt)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	_BuildXorgproto;
	return $?
}

CheckXorgproto()
{
	return 1;
	# CheckInstallation 	"${PackageXorgproto[Programs]}"\
	# 					"${PackageXorgproto[Libraries]}"\
	# 					"${PackageXorgproto[Python]}" 1> /dev/null;
	# return $?;
}

CheckXorgprotoVerbose()
{
	EchoWarning	"No valid check implemented" >&2;
	return 1;
	# CheckInstallationVerbose	"${PackageXorgproto[Programs]}"\
	# 							"${PackageXorgproto[Libraries]}"\
	# 							"${PackageXorgproto[Python]}";
	# return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildXorgproto()
{
	EchoInfo	"Package ${PackageXorgproto[Name]}"

	DownloadPackage	"${PackageXorgproto[Source]}"	"${SHMAN_PDIR}"	"${PackageXorgproto[Package]}${PackageXorgproto[Extension]}"	"${PackageXorgproto[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageXorgproto[Package]}"	"${PackageXorgproto[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageXorgproto[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageXorgproto[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageXorgproto[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageXorgproto[Package]}/build";

	EchoInfo	"${PackageXorgproto[Name]}> Configure"
	EchoInfo	"${PackageXorgproto[Name]}> meson setup --prefix=$XORG_PREFIX .."
	meson setup --prefix=$XORG_PREFIX ..  || { EchoTest KO ${PackageXorgproto[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXorgproto[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageXorgproto[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXorgproto[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageXorgproto[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXorgproto[Name]}> mv -v $XORG_PREFIX/share/doc/xorgproto{,-2024.1}"
	if [ -d "$XORG_PREFIX/share/doc/xorgproto-2024.1" ]; then
		EchoWarning "${PackageXorgproto[Name]}> rm -rf $XORG_PREFIX/share/doc/xorgproto-2024.1"
		rm -rf "$XORG_PREFIX/share/doc/xorgproto-2024.1"
	fi
	mv -v $XORG_PREFIX/share/doc/xorgproto{,-2024.1}
}
