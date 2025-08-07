#!/bin/bash

if [ ! -z "${PackageXcursorThemes[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#								XcursorThemes								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXcursorThemes;
# Manual
PackageXcursorThemes[Source]="https://www.x.org/pub/individual/data/xcursor-themes-1.0.7.tar.xz";
PackageXcursorThemes[MD5]="070993be1f010b09447ea24bab2c9846";
# Automated unless edgecase
PackageXcursorThemes[Name]="";
PackageXcursorThemes[Version]="";
PackageXcursorThemes[Extension]="";
if [[ -n "${PackageXcursorThemes[Source]}" ]]; then
	filename="${PackageXcursorThemes[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageXcursorThemes[Name]}" ]] && PackageXcursorThemes[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageXcursorThemes[Version]}" ]] && PackageXcursorThemes[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageXcursorThemes[Extension]}" ]] && PackageXcursorThemes[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageXcursorThemes[Package]="${PackageXcursorThemes[Name]}-${PackageXcursorThemes[Version]}";

PackageXcursorThemes[Programs]="";
PackageXcursorThemes[Libraries]="";
PackageXcursorThemes[Python]="";

InstallXcursorThemes()
{
	# Check Installation
	CheckXcursorThemes && return $?;

	# Check Dependencies
	EchoInfo	"${PackageXcursorThemes[Name]}> Checking dependencies..."
	Required=(XorgApplications)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageXcursorThemes[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageXcursorThemes[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageXcursorThemes[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageXcursorThemes[Name]}> Building package..."
	_ExtractPackageXcursorThemes || return $?;
	_BuildXcursorThemes;
	return $?
}

CheckXcursorThemes()
{
	return 1;
	CheckInstallation 	"${PackageXcursorThemes[Programs]}"\
						"${PackageXcursorThemes[Libraries]}"\
						"${PackageXcursorThemes[Python]}" 1> /dev/null;
	return $?;
}

CheckXcursorThemesVerbose()
{
	EchoWarning	"No valid check implemented" >&2;
	return 1;
	CheckInstallationVerbose	"${PackageXcursorThemes[Programs]}"\
								"${PackageXcursorThemes[Libraries]}"\
								"${PackageXcursorThemes[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageXcursorThemes()
{
	DownloadPackage	"${PackageXcursorThemes[Source]}"	"${SHMAN_PDIR}"	"${PackageXcursorThemes[Package]}${PackageXcursorThemes[Extension]}"	"${PackageXcursorThemes[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageXcursorThemes[Package]}"	"${PackageXcursorThemes[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildXcursorThemes()
{
	if ! cd "${SHMAN_PDIR}${PackageXcursorThemes[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageXcursorThemes[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageXcursorThemes[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageXcursorThemes[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXcursorThemes[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageXcursorThemes[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXcursorThemes[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageXcursorThemes[Name]} && PressAnyKeyToContinue; return 1; };
}
