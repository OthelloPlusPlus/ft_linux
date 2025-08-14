#!/bin/bash

if [ ! -z "${PackageLibUnwind[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibUnwind								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibUnwind;
PackageLibUnwind[Source]="https://github.com/libunwind/libunwind/releases/download/v1.8.1/libunwind-1.8.1.tar.gz";
PackageLibUnwind[MD5]="10c96118ff30b88c9eeb6eac8e75599d";
PackageLibUnwind[Name]="libunwind";
PackageLibUnwind[Version]="1.8.1";
PackageLibUnwind[Package]="${PackageLibUnwind[Name]}-${PackageLibUnwind[Version]}";
PackageLibUnwind[Extension]=".tar.gz";

PackageLibUnwind[Programs]="";
PackageLibUnwind[Libraries]="libunwind.so libunwind-coredump.so libunwind-generic.so libunwind-ptrace.so libunwind-setjmp.so libunwind-x86_64.so";
PackageLibUnwind[Python]="";

InstallLibUnwind()
{
	# Check Installation
	CheckLibUnwind && return $?;

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
	_BuildLibUnwind;
	return $?
}

CheckLibUnwind()
{
	CheckInstallation	"${PackageLibUnwind[Programs]}"\
						"${PackageLibUnwind[Libraries]}"\
						"${PackageLibUnwind[Python]}" 1> /dev/null;
	return $?;
}

CheckLibUnwindVerbose()
{
	CheckInstallationVerbose	"${PackageLibUnwind[Programs]}"\
								"${PackageLibUnwind[Libraries]}"\
								"${PackageLibUnwind[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildLibUnwind()
{
	EchoInfo	"Package ${PackageLibUnwind[Name]}"

	DownloadPackage	"${PackageLibUnwind[Source]}"	"${SHMAN_PDIR}"	"${PackageLibUnwind[Package]}${PackageLibUnwind[Extension]}"	"${PackageLibUnwind[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibUnwind[Package]}"	"${PackageLibUnwind[Extension]}";
	# wget -P "${SHMAN_PDIR}" "";

	if ! cd "${SHMAN_PDIR}${PackageLibUnwind[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibUnwind[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibUnwind[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageLibUnwind[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibUnwind[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibUnwind[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibUnwind[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibUnwind[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibUnwind[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibUnwind[Name]} && PressAnyKeyToContinue; return 1; };
}
