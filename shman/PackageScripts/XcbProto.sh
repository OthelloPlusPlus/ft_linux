#!/bin/bash

if [ ! -z "${PackageXcbProto[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									XcbProto								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXcbProto;
PackageXcbProto[Source]="https://xorg.freedesktop.org/archive/individual/proto/xcb-proto-1.17.0.tar.xz";
PackageXcbProto[MD5]="c415553d2ee1a8cea43c3234a079b53f";
PackageXcbProto[Name]="xcb-proto";
PackageXcbProto[Version]="1.17.0";
PackageXcbProto[Package]="${PackageXcbProto[Name]}-${PackageXcbProto[Version]}";
PackageXcbProto[Extension]=".tar.xz";

PackageXcbProto[Programs]="";
PackageXcbProto[Libraries]="";
PackageXcbProto[Python]="";

InstallXcbProto()
{
	# Check Installation
	CheckXcbProto && return $?;

	# Check Dependencies
	Dependencies=(XorgBuildEnv)
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	Optional=(LibXml2)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	_BuildXcbProto;
	return $?
}

CheckXcbProto()
{
	return 1;
	# CheckInstallation 	"${PackageXcbProto[Programs]}"\
	# 					"${PackageXcbProto[Libraries]}"\
	# 					"${PackageXcbProto[Python]}" 1> /dev/null;
	# return $?;
}

CheckXcbProtoVerbose()
{
	EchoInfo	"No valid check implemented" >&2;
	return 1;
	# CheckInstallationVerbose	"${PackageXcbProto[Programs]}"\
	# 							"${PackageXcbProto[Libraries]}"\
	# 							"${PackageXcbProto[Python]}";
	# return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildXcbProto()
{
	EchoInfo	"Package ${PackageXcbProto[Name]}"

	DownloadPackage	"${PackageXcbProto[Source]}"	"${SHMAN_PDIR}"	"${PackageXcbProto[Package]}${PackageXcbProto[Extension]}"	"${PackageXcbProto[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageXcbProto[Package]}"	"${PackageXcbProto[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageXcbProto[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageXcbProto[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageXcbProto[Name]}> Configure"
	PYTHON=python3 ./configure $XORG_CONFIG 1> /dev/null || { EchoTest KO ${PackageXcbProto[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXcbProto[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageXcbProto[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageXcbProto[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageXcbProto[Name]} && PressAnyKeyToContinue; return 1; };
}
