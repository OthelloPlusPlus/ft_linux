#!/bin/bash

if [ ! -z "${PackageLibWacom[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibWacom								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibWacom;
# Manual
PackageLibWacom[Source]="https://github.com/linuxwacom/libwacom/releases/download/libwacom-2.14.0/libwacom-2.14.0.tar.xz";
PackageLibWacom[MD5]="f3a3ba5144bb83c4ac71dae92e5512a9";
# Automated unless edgecase
PackageLibWacom[Name]="";
PackageLibWacom[Version]="";
PackageLibWacom[Extension]="";
if [[ -n "${PackageLibWacom[Source]}" ]]; then
	filename="${PackageLibWacom[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibWacom[Name]}" ]] && PackageLibWacom[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibWacom[Version]}" ]] && PackageLibWacom[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibWacom[Extension]}" ]] && PackageLibWacom[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibWacom[Package]="${PackageLibWacom[Name]}-${PackageLibWacom[Version]}";

PackageLibWacom[Programs]="libwacom-list-devices libwacom-list-local-devices libwacom-show-stylus libwacom-update-db";
PackageLibWacom[Libraries]="libwacom.so";
PackageLibWacom[Python]="";

InstallLibWacom()
{
	# Check Installation
	CheckLibWacom && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibWacom[Name]}> Checking dependencies..."
	Required=(LibEvdev LibGudev)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(LibXml2)
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Doxygen Git LibRsvg Valgrind)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibWacom[Name]}> Building package..."
	_ExtractPackageLibWacom || return $?;
	_BuildLibWacom;
	return $?
}

CheckLibWacom()
{
	CheckInstallation 	"${PackageLibWacom[Programs]}"\
						"${PackageLibWacom[Libraries]}"\
						"${PackageLibWacom[Python]}" 1> /dev/null;
	return $?;
}

CheckLibWacomVerbose()
{
	CheckInstallationVerbose	"${PackageLibWacom[Programs]}"\
								"${PackageLibWacom[Libraries]}"\
								"${PackageLibWacom[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibWacom()
{
	DownloadPackage	"${PackageLibWacom[Source]}"	"${SHMAN_PDIR}"	"${PackageLibWacom[Package]}${PackageLibWacom[Extension]}"	"${PackageLibWacom[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibWacom[Package]}"	"${PackageLibWacom[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibWacom()
{
	if ! cd "${SHMAN_PDIR}${PackageLibWacom[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibWacom[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibWacom[Package]}/build \
					|| { EchoError "${PackageLibWacom[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibWacom[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibWacom[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D tests=disabled \
				1> /dev/null || { EchoTest KO ${PackageLibWacom[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibWacom[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibWacom[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibWacom[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageLibWacom[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibWacom[Name]}> ninja install"
	rm -rf /usr/share/libwacom
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibWacom[Name]} && PressAnyKeyToContinue; return 1; };
}
