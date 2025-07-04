#!/bin/bash

if [ ! -z "${PackageLibXau[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									 LibXau									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibXau;
PackageLibXau[Source]="https://www.x.org/pub/individual/lib/libXau-1.0.12.tar.xz";
PackageLibXau[MD5]="4c9f81acf00b62e5de56a912691bd737";
PackageLibXau[Name]="libXau";
PackageLibXau[Version]="1.0.12";
PackageLibXau[Package]="${PackageLibXau[Name]}-${PackageLibXau[Version]}";
PackageLibXau[Extension]=".tar.xz";

PackageLibXau[Programs]="";
PackageLibXau[Libraries]="libXau.so";
PackageLibXau[Python]="";

InstallLibXau()
{
	# Check Installation
	CheckLibXau && return $?;

	# Check Dependencies
	Dependencies=(Xorgproto)
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
	_BuildLibXau;
	return $?
}

CheckLibXau()
{
	CheckInstallation 	"${PackageLibXau[Programs]}"\
						"${PackageLibXau[Libraries]}"\
						"${PackageLibXau[Python]}" 1> /dev/null;
	return $?;
}

CheckLibXauVerbose()
{
	CheckInstallationVerbose	"${PackageLibXau[Programs]}"\
								"${PackageLibXau[Libraries]}"\
								"${PackageLibXau[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildLibXau()
{
	EchoInfo	"Package ${PackageLibXau[Name]}"

	DownloadPackage	"${PackageLibXau[Source]}"	"${SHMAN_PDIR}"	"${PackageLibXau[Package]}${PackageLibXau[Extension]}"	"${PackageLibXau[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibXau[Package]}"	"${PackageLibXau[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageLibXau[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibXau[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibXau[Name]}> Configure"
	./configure $XORG_CONFIG 1> /dev/null || { EchoTest KO ${PackageLibXau[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXau[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibXau[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXau[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibXau[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLibXau[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibXau[Name]} && PressAnyKeyToContinue; return 1; };
}
