#!/bin/bash

if [ ! -z "${PackageGnomeShellExtensions[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#							GnomeShellExtensions							   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGnomeShellExtensions;
# Manual
PackageGnomeShellExtensions[Source]="https://download.gnome.org/sources/gnome-shell-extensions/47/gnome-shell-extensions-47.4.tar.xz";
PackageGnomeShellExtensions[MD5]="20f555270c63bd91546289f2811ff85a";
# Automated unless edgecase
PackageGnomeShellExtensions[Name]="";
PackageGnomeShellExtensions[Version]="";
PackageGnomeShellExtensions[Extension]="";
if [[ -n "${PackageGnomeShellExtensions[Source]}" ]]; then
	filename="${PackageGnomeShellExtensions[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageGnomeShellExtensions[Name]}" ]] && PackageGnomeShellExtensions[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageGnomeShellExtensions[Version]}" ]] && PackageGnomeShellExtensions[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageGnomeShellExtensions[Extension]}" ]] && PackageGnomeShellExtensions[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageGnomeShellExtensions[Package]="${PackageGnomeShellExtensions[Name]}-${PackageGnomeShellExtensions[Version]}";

PackageGnomeShellExtensions[Programs]="gnome-extensions gnome-shell-extension-prefs gnome-shell-extension-tool";
# PackageGnomeShellExtensions[Libraries]="";
# PackageGnomeShellExtensions[Python]="";

InstallGnomeShellExtensions()
{
	# Check Installation
	CheckGnomeShellExtensions && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGnomeShellExtensions[Name]}> Checking dependencies..."
	Required=(LibGtop)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GnomeShell) # added Gnome Shell because logic
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageGnomeShellExtensions[Name]}> Building package..."
	_ExtractPackageGnomeShellExtensions || return $?;
	_BuildGnomeShellExtensions;
	return $?
}

CheckGnomeShellExtensions()
{
	return 1;
	# CheckInstallation 	"${PackageGnomeShellExtensions[Programs]}"\
	# 					"${PackageGnomeShellExtensions[Libraries]}"\
	# 					"${PackageGnomeShellExtensions[Python]}" 1> /dev/null;
	# return $?;
}

CheckGnomeShellExtensionsVerbose()
{
	EchoWarning	"No valid check implemented" >&2;
	return 1;
	# CheckInstallationVerbose	"${PackageGnomeShellExtensions[Programs]}"\
	# 							"${PackageGnomeShellExtensions[Libraries]}"\
	# 							"${PackageGnomeShellExtensions[Python]}";
	# return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGnomeShellExtensions()
{
	DownloadPackage	"${PackageGnomeShellExtensions[Source]}"	"${SHMAN_PDIR}"	"${PackageGnomeShellExtensions[Package]}${PackageGnomeShellExtensions[Extension]}"	"${PackageGnomeShellExtensions[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGnomeShellExtensions[Package]}"	"${PackageGnomeShellExtensions[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildGnomeShellExtensions()
{
	if ! cd "${SHMAN_PDIR}${PackageGnomeShellExtensions[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGnomeShellExtensions[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGnomeShellExtensions[Package]}/build \
					|| { EchoError "${PackageGnomeShellExtensions[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGnomeShellExtensions[Package]}/build"; return 1; }

	EchoInfo	"${PackageGnomeShellExtensions[Name]}> Configure"
	meson setup --prefix=/usr ..  1> /dev/null || { EchoTest KO ${PackageGnomeShellExtensions[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeShellExtensions[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGnomeShellExtensions[Name]} && PressAnyKeyToContinue; return 1; };
}
