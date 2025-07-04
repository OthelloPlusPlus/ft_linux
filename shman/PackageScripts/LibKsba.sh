#!/bin/bash

if [ ! -z "${PackageLibKsba[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibKsba									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibKsba;
PackageLibKsba[Source]="https://www.gnupg.org/ftp/gcrypt/libksba/libksba-1.6.7.tar.bz2";
PackageLibKsba[MD5]="7e736de467b67c7ea88de746c31ea12f";
PackageLibKsba[Name]="libksba";
PackageLibKsba[Version]="1.6.7";
PackageLibKsba[Package]="${PackageLibKsba[Name]}-${PackageLibKsba[Version]}";
PackageLibKsba[Extension]=".tar.bz2";

PackageLibKsba[Programs]="";
PackageLibKsba[Libraries]="libksba.so";
PackageLibKsba[Python]="";

InstallLibKsba()
{
	# Check Installation
	CheckLibKsba && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibKsba[Name]}> Checking dependencies..."
	Required=(LibGpgError)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Valgrind)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageLibKsba[Name]}> Building package..."
	_ExtractPackageLibKsba || return $?;
	_BuildLibKsba;
	return $?
}

CheckLibKsba()
{
	CheckInstallation 	"${PackageLibKsba[Programs]}"\
						"${PackageLibKsba[Libraries]}"\
						"${PackageLibKsba[Python]}" 1> /dev/null;
	return $?;
}

CheckLibKsbaVerbose()
{
	CheckInstallationVerbose	"${PackageLibKsba[Programs]}"\
								"${PackageLibKsba[Libraries]}"\
								"${PackageLibKsba[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibKsba()
{
	DownloadPackage	"${PackageLibKsba[Source]}"	"${SHMAN_PDIR}"	"${PackageLibKsba[Package]}${PackageLibKsba[Extension]}"	"${PackageLibKsba[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibKsba[Package]}"	"${PackageLibKsba[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildLibKsba()
{
	if ! cd "${SHMAN_PDIR}${PackageLibKsba[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibKsba[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibKsba[Package]}/build \
	# 				|| { EchoError "${PackageLibKsba[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibKsba[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibKsba[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageLibKsba[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibKsba[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibKsba[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibKsba[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibKsba[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLibKsba[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibKsba[Name]} && PressAnyKeyToContinue; return 1; };
}
