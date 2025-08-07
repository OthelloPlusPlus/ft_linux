#!/bin/bash

if [ ! -z "${PackageXbitmaps[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Xbitmaps								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXbitmaps;
# Manual
PackageXbitmaps[Source]="https://www.x.org/pub/individual/data/xbitmaps-1.1.3.tar.xz";
PackageXbitmaps[MD5]="2b03f89d78fb91671370e77d7ad46907";
# Automated unless edgecase
PackageXbitmaps[Name]="";
PackageXbitmaps[Version]="";
PackageXbitmaps[Extension]="";
if [[ -n "${PackageXbitmaps[Source]}" ]]; then
	filename="${PackageXbitmaps[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageXbitmaps[Name]}" ]] && PackageXbitmaps[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageXbitmaps[Version]}" ]] && PackageXbitmaps[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageXbitmaps[Extension]}" ]] && PackageXbitmaps[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageXbitmaps[Package]="${PackageXbitmaps[Name]}-${PackageXbitmaps[Version]}";

PackageXbitmaps[Programs]="";
PackageXbitmaps[Libraries]="";
PackageXbitmaps[Python]="";

InstallXbitmaps()
{
	# Check Installation
	CheckXbitmaps && return $?;

	# Check Dependencies
	EchoInfo	"${PackageXbitmaps[Name]}> Checking dependencies..."
	Required=(UtilMacros)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageXbitmaps[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageXbitmaps[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageXbitmaps[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageXbitmaps[Name]}> Building package..."
	_ExtractPackageXbitmaps || return $?;
	_BuildXbitmaps;
	return $?
}

CheckXbitmaps()
{
	EchoWarning	"No valid check implemented" >&2;
	return 1;
	# CheckInstallation 	"${PackageXbitmaps[Programs]}"\
	# 					"${PackageXbitmaps[Libraries]}"\
	# 					"${PackageXbitmaps[Python]}" 1> /dev/null;
	# return $?;
}

CheckXbitmapsVerbose()
{
	return 1;
	# CheckInstallationVerbose	"${PackageXbitmaps[Programs]}"\
	# 							"${PackageXbitmaps[Libraries]}"\
	# 							"${PackageXbitmaps[Python]}";
	# return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageXbitmaps()
{
	DownloadPackage	"${PackageXbitmaps[Source]}"	"${SHMAN_PDIR}"	"${PackageXbitmaps[Package]}${PackageXbitmaps[Extension]}"	"${PackageXbitmaps[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageXbitmaps[Package]}"	"${PackageXbitmaps[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildXbitmaps()
{
	if ! cd "${SHMAN_PDIR}${PackageXbitmaps[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageXbitmaps[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageXbitmaps[Name]}> Configure"
	./configure $XORG_CONFIG 1> /dev/null || { EchoTest KO ${PackageXbitmaps[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXbitmaps[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageXbitmaps[Name]} && PressAnyKeyToContinue; return 1; };
}
