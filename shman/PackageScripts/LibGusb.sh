#!/bin/bash

if [ ! -z "${PackageLibGusb[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibGusb								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibGusb;
# Manual
PackageLibGusb[Source]="https://github.com/hughsie/libgusb/releases/download/0.4.9/libgusb-0.4.9.tar.xz";
PackageLibGusb[MD5]="354a3227334991ea4e924843c144bd82";
# Automated unless edgecase
PackageLibGusb[Name]="";
PackageLibGusb[Version]="";
PackageLibGusb[Extension]="";
if [[ -n "${PackageLibGusb[Source]}" ]]; then
	filename="${PackageLibGusb[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibGusb[Name]}" ]] && PackageLibGusb[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibGusb[Version]}" ]] && PackageLibGusb[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibGusb[Extension]}" ]] && PackageLibGusb[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibGusb[Package]="${PackageLibGusb[Name]}-${PackageLibGusb[Version]}";

PackageLibGusb[Programs]="gusbcmd";
PackageLibGusb[Libraries]="libgusb.so";
PackageLibGusb[Python]="";

InstallLibGusb()
{
	# Check Installation
	CheckLibGusb && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibGusb[Name]}> Checking dependencies..."
	Required=(JSONGLib LibUsb)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageLibGusb[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GLib Hwdata Vala)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageLibGusb[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(GiDocGen Umockdev)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageLibGusb[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibGusb[Name]}> Building package..."
	_ExtractPackageLibGusb || return $?;
	_BuildLibGusb;
	return $?
}

CheckLibGusb()
{
	CheckInstallation 	"${PackageLibGusb[Programs]}"\
						"${PackageLibGusb[Libraries]}"\
						"${PackageLibGusb[Python]}" 1> /dev/null;
	return $?;
}

CheckLibGusbVerbose()
{
	CheckInstallationVerbose	"${PackageLibGusb[Programs]}"\
								"${PackageLibGusb[Libraries]}"\
								"${PackageLibGusb[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibGusb()
{
	DownloadPackage	"${PackageLibGusb[Source]}"	"${SHMAN_PDIR}"	"${PackageLibGusb[Package]}${PackageLibGusb[Extension]}"	"${PackageLibGusb[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibGusb[Package]}"	"${PackageLibGusb[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibGusb()
{
	if ! cd "${SHMAN_PDIR}${PackageLibGusb[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibGusb[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibGusb[Package]}/build \
					|| { EchoError "${PackageLibGusb[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibGusb[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibGusb[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D docs=false \
				1> /dev/null || { EchoTest KO ${PackageLibGusb[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibGusb[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibGusb[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibGusb[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageLibGusb[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibGusb[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibGusb[Name]} && PressAnyKeyToContinue; return 1; };
}
