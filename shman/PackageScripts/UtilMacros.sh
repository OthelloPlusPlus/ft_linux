#!/bin/bash

if [ ! -z "${PackageUtilMacros[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									UtilMacros								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageUtilMacros;
PackageUtilMacros[Source]="https://www.x.org/pub/individual/util/util-macros-1.20.2.tar.xz";
PackageUtilMacros[MD5]="5f683a1966834b0a6ae07b3680bcb863";
PackageUtilMacros[Name]="util-macros";
PackageUtilMacros[Version]="1.20.2";
PackageUtilMacros[Package]="${PackageUtilMacros[Name]}-${PackageUtilMacros[Version]}";
PackageUtilMacros[Extension]=".tar.xz";

# PackageUtilMacros[Programs]="";
# PackageUtilMacros[Libraries]="";
# PackageUtilMacros[Python]="";

InstallUtilMacros()
{
	# Check Installation
	CheckUtilMacros && return $?;

	# Check Dependencies
	Dependencies=(XorgBuildEnv)
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
	_BuildUtilMacros;
	return $?
}

CheckUtilMacros()
{
	return 1;
	# CheckInstallation 	"${PackageUtilMacros[Programs]}"\
	# 					"${PackageUtilMacros[Libraries]}"\
	# 					"${PackageUtilMacros[Python]}" 1> /dev/null;
	# return $?;
}

CheckUtilMacrosVerbose()
{
	EchoWarning	"No valid check implemented" >&2;
	return 1;
	# CheckInstallationVerbose	"${PackageUtilMacros[Programs]}"\
	# 							"${PackageUtilMacros[Libraries]}"\
	# 							"${PackageUtilMacros[Python]}";
	# return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildUtilMacros()
{
	EchoInfo	"Package ${PackageUtilMacros[Name]}"

	DownloadPackage	"${PackageUtilMacros[Source]}"	"${SHMAN_PDIR}"	"${PackageUtilMacros[Package]}${PackageUtilMacros[Extension]}"	"${PackageUtilMacros[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageUtilMacros[Package]}"	"${PackageUtilMacros[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageUtilMacros[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageUtilMacros[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageUtilMacros[Name]}> Configure"
	./configure $XORG_CONFIG 1> /dev/null || { EchoTest KO ${PackageUtilMacros[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageUtilMacros[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageUtilMacros[Name]} && PressAnyKeyToContinue; return 1; };
}
