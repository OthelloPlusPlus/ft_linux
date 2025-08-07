#!/bin/bash

if [ ! -z "${PackageLibIdn2[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibIdn2								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibIdn2;
PackageLibIdn2[Source]="https://ftp.gnu.org/gnu/libidn/libidn2-2.3.7.tar.gz";
PackageLibIdn2[MD5]="de2818c7dea718a4f264f463f595596b";
PackageLibIdn2[Name]="libidn2";
PackageLibIdn2[Version]="2.3.7";
PackageLibIdn2[Package]="${PackageLibIdn2[Name]}-${PackageLibIdn2[Version]}";
PackageLibIdn2[Extension]=".tar.gz";

PackageLibIdn2[Programs]="idn2";
PackageLibIdn2[Libraries]="libidn2.so";
PackageLibIdn2[Python]="";

InstallLibIdn2()
{
	# Check Installation
	CheckLibIdn2 && return $?;

	# Check Dependencies
	Dependencies=()
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=(LibUnistring)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done
	
	# Install Package
	_BuildLibIdn2;
	return $?
}

CheckLibIdn2()
{
	CheckInstallation	"${PackageLibIdn2[Programs]}"\
						"${PackageLibIdn2[Libraries]}"\
						"${PackageLibIdn2[Python]}" 1> /dev/null;
	return $?;
}

CheckLibIdn2Verbose()
{
	CheckInstallationVerbose	"${PackageLibIdn2[Programs]}"\
								"${PackageLibIdn2[Libraries]}"\
								"${PackageLibIdn2[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildLibIdn2()
{
	EchoInfo	"Package ${PackageLibIdn2[Name]}"

	DownloadPackage	"${PackageLibIdn2[Source]}"	"${SHMAN_PDIR}"	"${PackageLibIdn2[Package]}${PackageLibIdn2[Extension]}"	"${PackageLibIdn2[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibIdn2[Package]}"	"${PackageLibIdn2[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageLibIdn2[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibIdn2[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibIdn2[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageLibIdn2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibIdn2[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibIdn2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibIdn2[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibIdn2[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLibIdn2[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibIdn2[Name]} && PressAnyKeyToContinue; return 1; };
}
