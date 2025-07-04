#!/bin/bash

if [ ! -z "${PackageGeoClue[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									GeoClue								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGeoClue;
PackageGeoClue[Source]="https://gitlab.freedesktop.org/geoclue/geoclue/-/archive/2.7.2/geoclue-2.7.2.tar.bz2";
PackageGeoClue[MD5]="d58d6f3286a6b3ace395fc36468aace2";
PackageGeoClue[Name]="geoclue";
PackageGeoClue[Version]="2.7.2";
PackageGeoClue[Package]="${PackageGeoClue[Name]}-${PackageGeoClue[Version]}";
PackageGeoClue[Extension]=".tar.bz2";

PackageGeoClue[Programs]="";
PackageGeoClue[Libraries]="libgeoclue-2.so";
PackageGeoClue[Python]="";

InstallGeoClue()
{
	# Check Installation
	CheckGeoClue && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGeoClue[Name]}> Checking dependencies..."
	Required=(JSONGLib LibSoup3)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Avahi LibNotify ModemManager Vala)
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(GTKDoc)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageGeoClue[Name]}> Building package..."
	_ExtractPackageGeoClue || return $?;
	_BuildGeoClue;
	return $?
}

CheckGeoClue()
{
	CheckInstallation 	"${PackageGeoClue[Programs]}"\
						"${PackageGeoClue[Libraries]}"\
						"${PackageGeoClue[Python]}" 1> /dev/null;
	return $?;
}

CheckGeoClueVerbose()
{
	CheckInstallationVerbose	"${PackageGeoClue[Programs]}"\
								"${PackageGeoClue[Libraries]}"\
								"${PackageGeoClue[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGeoClue()
{
	DownloadPackage	"${PackageGeoClue[Source]}"	"${SHMAN_PDIR}"	"${PackageGeoClue[Package]}${PackageGeoClue[Extension]}"	"${PackageGeoClue[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGeoClue[Package]}"	"${PackageGeoClue[Extension]}" || return $?;

	for URL in \
	# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildGeoClue()
{
	if ! cd "${SHMAN_PDIR}${PackageGeoClue[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGeoClue[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGeoClue[Package]}/build \
					|| { EchoError "${PackageGeoClue[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGeoClue[Package]}/build"; return 1; }

	EchoInfo	"${PackageGeoClue[Name]}> Configure"
	local DFLAGS="-D gtk-doc=false "
	which ModemManager &> /dev/null || DFLAGS+=" -D 3g-source=false -D modem-gps-source=false -D cdma-source=false"
	which avahi-browse &> /dev/null || DFLAGS+=" -D nmea-source=false"
	which gtkdocize &> /dev/null || DFLAGS+=" -D demo-agent=false"
	meson setup --prefix=/usr \
				--buildtype=release \
				$DFLAGS \
				.. \
				1> /dev/null || { EchoTest KO ${PackageGeoClue[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGeoClue[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGeoClue[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGeoClue[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGeoClue[Name]} && PressAnyKeyToContinue; return 1; };
}
