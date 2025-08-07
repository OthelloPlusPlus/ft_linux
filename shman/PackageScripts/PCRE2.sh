#!/bin/bash

if [ ! -z "${PackagePCRE2[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									 PCRE2									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePCRE2;
PackagePCRE2[Source]="https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.45/pcre2-10.45.tar.bz2";
PackagePCRE2[MD5]="f71abbe1b5adf25cd9af5d26ef223b66";
PackagePCRE2[Name]="pcre2";
PackagePCRE2[Version]="10.45";
PackagePCRE2[Package]="${PackagePCRE2[Name]}-${PackagePCRE2[Version]}";
PackagePCRE2[Extension]=".tar.bz2";

PackagePCRE2[Programs]="pcre2-config pcre2grep pcre2test";
PackagePCRE2[Libraries]="libpcre2-8.so libpcre2-16.so libpcre2-32.so libpcre2-posix.so";
PackagePCRE2[Python]="";

InstallPCRE2()
{
	# Check Installation
	CheckPCRE2 && return $?;

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
	_BuildPCRE2;
	return $?
}

CheckPCRE2()
{
	CheckInstallation 	"${PackagePCRE2[Programs]}"\
						"${PackagePCRE2[Libraries]}"\
						"${PackagePCRE2[Python]}" 1> /dev/null;
	return $?;
}

CheckPCRE2Verbose()
{
	CheckInstallationVerbose	"${PackagePCRE2[Programs]}"\
								"${PackagePCRE2[Libraries]}"\
								"${PackagePCRE2[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildPCRE2()
{
	EchoInfo	"Package ${PackagePCRE2[Name]}"

	DownloadPackage	"${PackagePCRE2[Source]}"	"${SHMAN_PDIR}"	"${PackagePCRE2[Package]}${PackagePCRE2[Extension]}"	"${PackagePCRE2[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackagePCRE2[Package]}"	"${PackagePCRE2[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackagePCRE2[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackagePCRE2[Package]}";
		return 1;
	fi

	EchoInfo	"${PackagePCRE2[Name]}> Configure"
	./configure --prefix=/usr \
				--docdir=/usr/share/doc/pcre2-10.45 \
				--enable-unicode \
				--enable-jit \
				--enable-pcre2-16 \
				--enable-pcre2-32 \
				--enable-pcre2grep-libz \
				--enable-pcre2grep-libbz2 \
				--enable-pcre2test-libreadline \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackagePCRE2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePCRE2[Name]}> make"
	make  1> /dev/null || { EchoTest KO ${PackagePCRE2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePCRE2[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackagePCRE2[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackagePCRE2[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackagePCRE2[Name]} && PressAnyKeyToContinue; return 1; };
}
