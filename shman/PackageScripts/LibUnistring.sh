#!/bin/bash

if [ ! -z "${PackageLibUnistring[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#								  LibUnistring								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibUnistring;
PackageLibUnistring[Source]="https://ftp.gnu.org/gnu/libunistring/libunistring-1.3.tar.xz";
PackageLibUnistring[MD5]="57dfd9e4eba93913a564aa14eab8052e";
PackageLibUnistring[Name]="libunistring";
PackageLibUnistring[Version]="1.3";
PackageLibUnistring[Package]="${PackageLibUnistring[Name]}-${PackageLibUnistring[Version]}";
PackageLibUnistring[Extension]=".tar.xz";

PackageLibUnistring[Programs]="";
PackageLibUnistring[Libraries]="libunistring.so";
PackageLibUnistring[Python]="";

InstallLibUnistring()
{
	# Check Installation
	CheckLibUnistring && return $?

	# Check Dependencies
	Dependencies=()
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done
	
	# Install Package
	_BuildLibUnistring;
	return $?
}

CheckLibUnistring()
{
	CheckInstallation	"${PackageLibUnistring[Programs]}"\
						"${PackageLibUnistring[Libraries]}"\
						"${PackageLibUnistring[Python]}" 1> /dev/null;
	return $?;
}

CheckLibUnistringVerbose()
{
	CheckInstallationVerbose	"${PackageLibUnistring[Programs]}"\
								"${PackageLibUnistring[Libraries]}"\
								"${PackageLibUnistring[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildLibUnistring()
{
	EchoInfo	"Package ${PackageLibUnistring[Name]}"

	DownloadPackage	"${PackageLibUnistring[Source]}"	"${SHMAN_PDIR}"	"${PackageLibUnistring[Package]}${PackageLibUnistring[Extension]}"	"${PackageLibUnistring[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibUnistring[Package]}"	"${PackageLibUnistring[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageLibUnistring[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibUnistring[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibUnistring[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--docdir=/usr/share/doc/libunistring-1.3 \
				1> /dev/null || { EchoTest KO ${PackageLibUnistring[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibUnistring[Name]}> make"
	make  1> /dev/null || { EchoTest KO ${PackageLibUnistring[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibUnistring[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibUnistring[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLibUnistring[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibUnistring[Name]} && PressAnyKeyToContinue; return 1; };
}
