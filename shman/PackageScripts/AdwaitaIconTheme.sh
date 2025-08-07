#!/bin/bash

if [ ! -z "${PackageAdwaitaIconTheme[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									AdwaitaIconTheme								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageAdwaitaIconTheme;
# Manual
PackageAdwaitaIconTheme[Source]="https://download.gnome.org/sources/adwaita-icon-theme/47/adwaita-icon-theme-47.0.tar.xz";
PackageAdwaitaIconTheme[MD5]="b3863567f8019b056695cb51f4e0abc4";
# Automated unless edgecase
PackageAdwaitaIconTheme[Name]="";
PackageAdwaitaIconTheme[Version]="";
PackageAdwaitaIconTheme[Extension]="";
if [[ -n "${PackageAdwaitaIconTheme[Source]}" ]]; then
	filename="${PackageAdwaitaIconTheme[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageAdwaitaIconTheme[Name]}" ]] && PackageAdwaitaIconTheme[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageAdwaitaIconTheme[Version]}" ]] && PackageAdwaitaIconTheme[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageAdwaitaIconTheme[Extension]}" ]] && PackageAdwaitaIconTheme[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageAdwaitaIconTheme[Package]="${PackageAdwaitaIconTheme[Name]}-${PackageAdwaitaIconTheme[Version]}";

# PackageAdwaitaIconTheme[Programs]="";
# PackageAdwaitaIconTheme[Libraries]="";
# PackageAdwaitaIconTheme[Python]="";

InstallAdwaitaIconTheme()
{
	# Check Installation
	CheckAdwaitaIconTheme && return $?;

	# Check Dependencies
	EchoInfo	"${PackageAdwaitaIconTheme[Name]}> Checking dependencies..."
	Required=(GTK3 GTK4 LibRsvg)
	for Dependency in "${Required[@]}"; do
		EchoInfo	"${PackageAdwaitaIconTheme[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageAdwaitaIconTheme[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Git Inkscape)
	for Dependency in "${Optional[@]}"; do
		EchoInfo	"${PackageAdwaitaIconTheme[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageAdwaitaIconTheme[Name]}> Building package..."
	_ExtractPackageAdwaitaIconTheme || return $?;
	_BuildAdwaitaIconTheme;
	return $?
}

CheckAdwaitaIconTheme()
{
	return 1;
	# CheckInstallation 	"${PackageAdwaitaIconTheme[Programs]}"\
	# 					"${PackageAdwaitaIconTheme[Libraries]}"\
	# 					"${PackageAdwaitaIconTheme[Python]}" 1> /dev/null;
	return $?;
}

CheckAdwaitaIconThemeVerbose()
{
	EchoWarning	"No valid check implemented" >&2;
	return 1;
	# CheckInstallationVerbose	"${PackageAdwaitaIconTheme[Programs]}"\
	# 							"${PackageAdwaitaIconTheme[Libraries]}"\
	# 							"${PackageAdwaitaIconTheme[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageAdwaitaIconTheme()
{
	DownloadPackage	"${PackageAdwaitaIconTheme[Source]}"	"${SHMAN_PDIR}"	"${PackageAdwaitaIconTheme[Package]}${PackageAdwaitaIconTheme[Extension]}"	"${PackageAdwaitaIconTheme[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageAdwaitaIconTheme[Package]}"	"${PackageAdwaitaIconTheme[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildAdwaitaIconTheme()
{
	if ! cd "${SHMAN_PDIR}${PackageAdwaitaIconTheme[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageAdwaitaIconTheme[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageAdwaitaIconTheme[Package]}/build \
					|| { EchoError "${PackageAdwaitaIconTheme[Name]}> Failed to enter ${SHMAN_PDIR}${PackageAdwaitaIconTheme[Package]}/build"; return 1; }

	EchoInfo	"${PackageAdwaitaIconTheme[Name]}> Configure"
	meson setup --prefix=/usr .. 1> /dev/null || { EchoTest KO ${PackageAdwaitaIconTheme[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAdwaitaIconTheme[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageAdwaitaIconTheme[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAdwaitaIconTheme[Name]}> Removing old icons"
	rm -rf /usr/share/icons/Adwaita/

	EchoInfo	"${PackageAdwaitaIconTheme[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageAdwaitaIconTheme[Name]} && PressAnyKeyToContinue; return 1; };
}
