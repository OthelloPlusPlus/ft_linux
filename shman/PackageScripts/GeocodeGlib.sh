#!/bin/bash

if [ ! -z "${PackageGeocodeGlib[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									GeocodeGlib								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGeocodeGlib;
PackageGeocodeGlib[Source]="https://download.gnome.org/sources/geocode-glib/3.26/geocode-glib-3.26.4.tar.xz";
PackageGeocodeGlib[MD5]="4c0dcdb7ee1222435b20acd3d7b68cd1";
PackageGeocodeGlib[Name]="geocode-glib";
PackageGeocodeGlib[Version]="3.26.4";
PackageGeocodeGlib[Package]="${PackageGeocodeGlib[Name]}-${PackageGeocodeGlib[Version]}";
PackageGeocodeGlib[Extension]=".tar.xz";

PackageGeocodeGlib[Programs]="";
PackageGeocodeGlib[Libraries]="libgeocode-glib-2.so";
PackageGeocodeGlib[Python]="";

InstallGeocodeGlib()
{
	# Check Installation
	CheckGeocodeGlib && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGeocodeGlib[Name]}> Checking dependencies..."
	Required=(JSONGLib LibSoup3)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GLib)
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
	EchoInfo	"${PackageGeocodeGlib[Name]}> Building package..."
	_ExtractPackageGeocodeGlib || return $?;
	_BuildGeocodeGlib;
	return $?
}

CheckGeocodeGlib()
{
	CheckInstallation 	"${PackageGeocodeGlib[Programs]}"\
						"${PackageGeocodeGlib[Libraries]}"\
						"${PackageGeocodeGlib[Python]}" 1> /dev/null;
	return $?;
}

CheckGeocodeGlibVerbose()
{
	CheckInstallationVerbose	"${PackageGeocodeGlib[Programs]}"\
								"${PackageGeocodeGlib[Libraries]}"\
								"${PackageGeocodeGlib[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGeocodeGlib()
{
	DownloadPackage	"${PackageGeocodeGlib[Source]}"	"${SHMAN_PDIR}"	"${PackageGeocodeGlib[Package]}${PackageGeocodeGlib[Extension]}"	"${PackageGeocodeGlib[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGeocodeGlib[Package]}"	"${PackageGeocodeGlib[Extension]}" || return $?;

	for URL in \
	# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildGeocodeGlib()
{
	if ! cd "${SHMAN_PDIR}${PackageGeocodeGlib[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGeocodeGlib[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGeocodeGlib[Package]}/build \
					|| { EchoError "${PackageGeocodeGlib[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGeocodeGlib[Package]}/build"; return 1; }

	EchoInfo	"${PackageGeocodeGlib[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D enable-gtk-doc=false \
				-D soup2=false \
				.. \
				1> /dev/null || { EchoTest KO ${PackageGeocodeGlib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGeocodeGlib[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGeocodeGlib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGeocodeGlib[Name]}> ninja test"
	LANG=C ninja test 1> /dev/null || { EchoTest KO "${PackageGeocodeGlib[Name]}> 1 test is known to fail without sv_SE.utf8" && PressAnyKeyToContinue; };

	EchoInfo	"${PackageGeocodeGlib[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGeocodeGlib[Name]} && PressAnyKeyToContinue; return 1; };
}
