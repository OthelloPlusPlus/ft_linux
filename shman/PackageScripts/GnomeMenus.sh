#!/bin/bash

if [ ! -z "${PackageGnomeMenus[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									GnomeMenus								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGnomeMenus;
# Manual
PackageGnomeMenus[Source]="https://download.gnome.org/sources/gnome-menus/3.36/gnome-menus-3.36.0.tar.xz";
PackageGnomeMenus[MD5]="a8fd71fcf31a87fc799d80396a526829";
# Automated unless edgecase
PackageGnomeMenus[Name]="";
PackageGnomeMenus[Version]="";
PackageGnomeMenus[Extension]="";
if [[ -n "${PackageGnomeMenus[Source]}" ]]; then
	filename="${PackageGnomeMenus[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageGnomeMenus[Name]}" ]] && PackageGnomeMenus[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageGnomeMenus[Version]}" ]] && PackageGnomeMenus[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageGnomeMenus[Extension]}" ]] && PackageGnomeMenus[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageGnomeMenus[Package]="${PackageGnomeMenus[Name]}-${PackageGnomeMenus[Version]}";

PackageGnomeMenus[Programs]="";
PackageGnomeMenus[Libraries]="libgnome-menu-3.so";
PackageGnomeMenus[Python]="";

InstallGnomeMenus()
{
	# Check Installation
	CheckGnomeMenus && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGnomeMenus[Name]}> Checking dependencies..."
	Required=(GLib)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
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
	EchoInfo	"${PackageGnomeMenus[Name]}> Building package..."
	_ExtractPackageGnomeMenus || return $?;
	_BuildGnomeMenus;
	return $?
}

CheckGnomeMenus()
{
	CheckInstallation 	"${PackageGnomeMenus[Programs]}"\
						"${PackageGnomeMenus[Libraries]}"\
						"${PackageGnomeMenus[Python]}" 1> /dev/null;
	return $?;
}

CheckGnomeMenusVerbose()
{
	CheckInstallationVerbose	"${PackageGnomeMenus[Programs]}"\
								"${PackageGnomeMenus[Libraries]}"\
								"${PackageGnomeMenus[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGnomeMenus()
{
	DownloadPackage	"${PackageGnomeMenus[Source]}"	"${SHMAN_PDIR}"	"${PackageGnomeMenus[Package]}${PackageGnomeMenus[Extension]}"	"${PackageGnomeMenus[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGnomeMenus[Package]}"	"${PackageGnomeMenus[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildGnomeMenus()
{
	if ! cd "${SHMAN_PDIR}${PackageGnomeMenus[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGnomeMenus[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGnomeMenus[Package]}/build \
	# 				|| { EchoError "${PackageGnomeMenus[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGnomeMenus[Package]}/build"; return 1; }

	EchoInfo	"${PackageGnomeMenus[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageGnomeMenus[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeMenus[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageGnomeMenus[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeMenus[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageGnomeMenus[Name]} && PressAnyKeyToContinue; return 1; };
}
