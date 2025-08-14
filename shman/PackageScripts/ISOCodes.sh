#!/bin/bash

if [ ! -z "${PackageISOCodes[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									ISOCodes								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageISOCodes;
PackageISOCodes[Source]="https://salsa.debian.org/iso-codes-team/iso-codes/-/archive/v4.17.0/iso-codes-v4.17.0.tar.gz";
PackageISOCodes[MD5]="f4b460577728ba331e078ad8bd246c98";
PackageISOCodes[Name]="iso-codes";
PackageISOCodes[Version]="v4.17.0";
PackageISOCodes[Package]="${PackageISOCodes[Name]}-${PackageISOCodes[Version]}";
PackageISOCodes[Extension]=".tar.gz";

PackageISOCodes[Programs]="";
PackageISOCodes[Libraries]="";
PackageISOCodes[Python]="";

InstallISOCodes()
{
	# Check Installation
	CheckISOCodes && return $?;

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
	EchoInfo	"Package ${PackageISOCodes[Name]}"
	_ExtractPackageISOCodes || return $?;
	_BuildISOCodes;
	return $?
}

CheckISOCodes()
{
	[ -f /usr/share/xml/iso-codes/iso_639.xml ]
}

CheckISOCodesVerbose()
{
	if [ ! -f /usr/share/xml/iso-codes/iso_639.xml ]; then
		echo -en "${C_RED}iso_639.xml${C_RESET}"
	fi
	echo
	[ -f /usr/share/xml/iso-codes/iso_639.xml ]
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageISOCodes()
{
	DownloadPackage	"${PackageISOCodes[Source]}"	"${SHMAN_PDIR}"	"${PackageISOCodes[Package]}${PackageISOCodes[Extension]}"	"${PackageISOCodes[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageISOCodes[Package]}"	"${PackageISOCodes[Extension]}" || return $?;

	return $?;
}

_BuildISOCodes()
{
	if ! cd "${SHMAN_PDIR}${PackageISOCodes[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageISOCodes[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageISOCodes[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageISOCodes[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageISOCodes[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageISOCodes[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageISOCodes[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageISOCodes[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageISOCodes[Name]}> make install"
	make install LN_S='ln -sfn' 1> /dev/null || { EchoTest KO ${PackageISOCodes[Name]} && PressAnyKeyToContinue; return 1; };
}
