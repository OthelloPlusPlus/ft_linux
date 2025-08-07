#!/bin/bash

if [ ! -z "${PackageHwdata[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									 Hwdata									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageHwdata;
PackageHwdata[Source]="https://github.com/vcrhonek/hwdata/archive/v0.392/hwdata-0.392.tar.gz";
PackageHwdata[MD5]="14cee546bfc1f6cb83c4339df1cbe4b9";
PackageHwdata[Name]="hwdata";
PackageHwdata[Version]="0.392";
PackageHwdata[Package]="${PackageHwdata[Name]}-${PackageHwdata[Version]}";
PackageHwdata[Extension]=".tar.gz";

PackageHwdata[Programs]="";
PackageHwdata[Libraries]="";
PackageHwdata[Python]="";

InstallHwdata()
{
	# Check Installation
	CheckHwdata && return $?;

	# Check Dependencies
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
	EchoInfo	"Package ${PackageHwdata[Name]}"
	_ExtractPackageHwdata || return $?;
	_BuildHwdata;
	return $?
}

CheckHwdata()
{
	return 1;
	# CheckInstallation 	"${PackageHwdata[Programs]}"\
	# 					"${PackageHwdata[Libraries]}"\
	# 					"${PackageHwdata[Python]}" 1> /dev/null;
	# return $?;
}

CheckHwdataVerbose()
{
	EchoWarning	"No valid check implemented" >&2;
	return 1;
	# CheckInstallationVerbose	"${PackageHwdata[Programs]}"\
	# 							"${PackageHwdata[Libraries]}"\
	# 							"${PackageHwdata[Python]}";
	# return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageHwdata()
{
	DownloadPackage	"${PackageHwdata[Source]}"	"${SHMAN_PDIR}"	"${PackageHwdata[Package]}${PackageHwdata[Extension]}"	"${PackageHwdata[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageHwdata[Package]}"	"${PackageHwdata[Extension]}" || return $?;

	return $?;
}

_BuildHwdata()
{
	if ! cd "${SHMAN_PDIR}${PackageHwdata[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageHwdata[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageHwdata[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-blacklist \
				1> /dev/null || { EchoTest KO ${PackageHwdata[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageHwdata[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageHwdata[Name]} && PressAnyKeyToContinue; return 1; };
}
