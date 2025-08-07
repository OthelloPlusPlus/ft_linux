#!/bin/bash

if [ ! -z "${PackageLibEvdev[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibEvdev								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibEvdev;
# Manual
PackageLibEvdev[Source]="https://www.freedesktop.org/software/libevdev/libevdev-1.13.3.tar.xz";
PackageLibEvdev[MD5]="57ee77b7d4c480747e693779bb92fb84";
# Automated unless edgecase
PackageLibEvdev[Name]="";
PackageLibEvdev[Version]="";
PackageLibEvdev[Extension]="";
if [[ -n "${PackageLibEvdev[Source]}" ]]; then
	filename="${PackageLibEvdev[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibEvdev[Name]}" ]] && PackageLibEvdev[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibEvdev[Version]}" ]] && PackageLibEvdev[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibEvdev[Extension]}" ]] && PackageLibEvdev[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibEvdev[Package]="${PackageLibEvdev[Name]}-${PackageLibEvdev[Version]}";

PackageLibEvdev[Programs]="libevdev-tweak-device mouse-dpi-tool touchpad-edge-detector";
PackageLibEvdev[Libraries]="libevdev.so";
PackageLibEvdev[Python]="";

InstallLibEvdev()
{
	# Check Installation
	CheckLibEvdev && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibEvdev[Name]}> Checking dependencies..."
	Required=(Linux)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Doxygen Valgrind)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibEvdev[Name]}> Building package..."
	_ExtractPackageLibEvdev || return $?;
	_BuildLibEvdev;
	return $?
}

CheckLibEvdev()
{
	CheckInstallation 	"${PackageLibEvdev[Programs]}"\
						"${PackageLibEvdev[Libraries]}"\
						"${PackageLibEvdev[Python]}" 1> /dev/null;
	return $?;
}

CheckLibEvdevVerbose()
{
	CheckInstallationVerbose	"${PackageLibEvdev[Programs]}"\
								"${PackageLibEvdev[Libraries]}"\
								"${PackageLibEvdev[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibEvdev()
{
	DownloadPackage	"${PackageLibEvdev[Source]}"	"${SHMAN_PDIR}"	"${PackageLibEvdev[Package]}${PackageLibEvdev[Extension]}"	"${PackageLibEvdev[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibEvdev[Package]}"	"${PackageLibEvdev[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibEvdev()
{
	if ! cd "${SHMAN_PDIR}${PackageLibEvdev[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibEvdev[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibEvdev[Package]}/build \
					|| { EchoError "${PackageLibEvdev[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibEvdev[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibEvdev[Name]}> Configure"
	meson setup .. \
				--prefix=$XORG_PREFIX \
				--buildtype=release \
				-D documentation=disabled \
				1> /dev/null || { EchoTest KO ${PackageLibEvdev[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibEvdev[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibEvdev[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageLibEvdev[Name]}> ninja check"
	# ninja check 1> /dev/null || { EchoTest KO ${PackageLibEvdev[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibEvdev[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibEvdev[Name]} && PressAnyKeyToContinue; return 1; };
}
