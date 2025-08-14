#!/bin/bash

if [ ! -z "${PackageUPower[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									UPower								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageUPower;
PackageUPower[Source]="https://gitlab.freedesktop.org/upower/upower/-/archive/v1.90.7/upower-v1.90.7.tar.bz2";
PackageUPower[MD5]="d5eeb9af086f696bb55bb979a7fb06ca";
PackageUPower[Name]="upower";
PackageUPower[Version]="v1.90.7";
PackageUPower[Package]="${PackageUPower[Name]}-${PackageUPower[Version]}";
PackageUPower[Extension]=".tar.bz2";

PackageUPower[Programs]="upower";
PackageUPower[Libraries]="libupower-glib.so";
PackageUPower[Python]="";

InstallUPower()
{
	# Check Installation
	CheckUPower && return $?;

	# Check Dependencies
	EchoInfo	"${PackageUPower[Name]}> Checking dependencies..."
	Required=(LibGudev LibUsb GLib)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(GTKDoc LibXslt DocbookXslNons Umockdev)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageUPower[Name]}> Building package..."
	_ExtractPackageUPower || return $?;
	_BuildUPower;
	return $?
}

CheckUPower()
{
	CheckInstallation 	"${PackageUPower[Programs]}"\
						"${PackageUPower[Libraries]}"\
						"${PackageUPower[Python]}" 1> /dev/null;
	return $?;
}

CheckUPowerVerbose()
{
	CheckInstallationVerbose	"${PackageUPower[Programs]}"\
								"${PackageUPower[Libraries]}"\
								"${PackageUPower[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageUPower()
{
	DownloadPackage	"${PackageUPower[Source]}"	"${SHMAN_PDIR}"	"${PackageUPower[Package]}${PackageUPower[Extension]}"	"${PackageUPower[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageUPower[Package]}"	"${PackageUPower[Extension]}" || return $?;

	for URL in \
	# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildUPower()
{
	if ! cd "${SHMAN_PDIR}${PackageUPower[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageUPower[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageUPower[Package]}/build \
					|| { EchoError "${PackageUPower[Name]}> Failed to enter ${SHMAN_PDIR}${PackageUPower[Package]}/build"; return 1; }

	EchoInfo	"${PackageUPower[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D gtk-doc=false \
				-D man=false \
				-D systemdsystemunitdir=no \
				-D udevrulesdir=/usr/lib/udev/rules.d \
				1> /dev/null || { EchoTest KO ${PackageUPower[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageUPower[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageUPower[Name]} && PressAnyKeyToContinue; return 1; };



	EchoInfo	"${PackageUPower[Name]}> ninja test"
	if [ -z "$DISPLAY" ]; then
		echo "No X graphical environment detected. Tests requiring X will fail."
		LC_ALL=C ninja test || { EchoWarning "${PackageUPower[Name]}> expected" && PressAnyKeyToContinue; };
	else
		LC_ALL=C ninja test 1> /dev/null || { EchoTest KO ${PackageUPower[Name]}4 && PressAnyKeyToContinue; return 1; };
	fi

	EchoInfo	"${PackageUPower[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageUPower[Name]} && PressAnyKeyToContinue; return 1; };
}
