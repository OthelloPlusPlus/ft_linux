#!/bin/bash

if [ ! -z "${PackageNpth[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									  Npth									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageNpth;
PackageNpth[Source]="https://www.gnupg.org/ftp/gcrypt/npth/npth-1.8.tar.bz2";
PackageNpth[MD5]="cb4fc0402be5ba67544e499cb2c1a74d";
PackageNpth[Name]="npth";
PackageNpth[Version]="1.8";
PackageNpth[Package]="${PackageNpth[Name]}-${PackageNpth[Version]}";
PackageNpth[Extension]=".tar.bz2";

PackageNpth[Programs]="npth-config";
PackageNpth[Libraries]="libnpth.so";
PackageNpth[Python]="";

InstallNpth()
{
	# Check Installation
	CheckNpth && return $?;

	# Check Dependencies
	EchoInfo	"${PackageNpth[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageNpth[Name]}> Building package..."
	_ExtractPackageNpth || return $?;
	_BuildNpth;
	return $?
}

CheckNpth()
{
	CheckInstallation 	"${PackageNpth[Programs]}"\
						"${PackageNpth[Libraries]}"\
						"${PackageNpth[Python]}" 1> /dev/null;
	return $?;
}

CheckNpthVerbose()
{
	CheckInstallationVerbose	"${PackageNpth[Programs]}"\
								"${PackageNpth[Libraries]}"\
								"${PackageNpth[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageNpth()
{
	DownloadPackage	"${PackageNpth[Source]}"	"${SHMAN_PDIR}"	"${PackageNpth[Package]}${PackageNpth[Extension]}"	"${PackageNpth[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageNpth[Package]}"	"${PackageNpth[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildNpth()
{
	if ! cd "${SHMAN_PDIR}${PackageNpth[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageNpth[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageNpth[Package]}/build \
	# 				|| { EchoError "${PackageNpth[Name]}> Failed to enter ${SHMAN_PDIR}${PackageNpth[Package]}/build"; return 1; }

	EchoInfo	"${PackageNpth[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageNpth[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNpth[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageNpth[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNpth[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageNpth[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageNpth[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageNpth[Name]} && PressAnyKeyToContinue; return 1; };
}
