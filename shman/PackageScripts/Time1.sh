#!/bin/bash

if [ ! -z "${PackageTime1[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Time1								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageTime1;
# Manual
PackageTime1[Source]="https://ftp.gnu.org/gnu/time/time-1.9.tar.gz";
PackageTime1[MD5]="d2356e0fe1c0b85285d83c6b2ad51b5f";
# Automated unless edgecase
PackageTime1[Name]="";
PackageTime1[Version]="";
PackageTime1[Extension]="";
if [[ -n "${PackageTime1[Source]}" ]]; then
	filename="${PackageTime1[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageTime1[Name]}" ]] && PackageTime1[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageTime1[Version]}" ]] && PackageTime1[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageTime1[Extension]}" ]] && PackageTime1[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageTime1[Package]="${PackageTime1[Name]}-${PackageTime1[Version]}";

PackageTime1[Programs]="time";
PackageTime1[Libraries]="";
PackageTime1[Python]="";

InstallTime1()
{
	# Check Installation
	CheckTime1 && return $?;

	# Check Dependencies
	EchoInfo	"${PackageTime1[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageTime1[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageTime1[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageTime1[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageTime1[Name]}> Building package..."
	_ExtractPackageTime1 || return $?;
	_BuildTime1;
	return $?
}

CheckTime1()
{
	CheckInstallation 	"${PackageTime1[Programs]}"\
						"${PackageTime1[Libraries]}"\
						"${PackageTime1[Python]}" 1> /dev/null;
	return $?;
}

CheckTime1Verbose()
{
	CheckInstallationVerbose	"${PackageTime1[Programs]}"\
								"${PackageTime1[Libraries]}"\
								"${PackageTime1[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageTime1()
{
	DownloadPackage	"${PackageTime1[Source]}"	"${SHMAN_PDIR}"	"${PackageTime1[Package]}${PackageTime1[Extension]}"	"${PackageTime1[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageTime1[Package]}"	"${PackageTime1[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildTime1()
{
	if ! cd "${SHMAN_PDIR}${PackageTime1[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageTime1[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageTime1[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageTime1[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTime1[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageTime1[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTime1[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageTime1[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTime1[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageTime1[Name]} && PressAnyKeyToContinue; return 1; };
}
