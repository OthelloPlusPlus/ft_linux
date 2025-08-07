#!/bin/bash

if [ ! -z "${PackageLibGweather[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibGweather								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibGweather;
# Manual
PackageLibGweather[Source]="https://download.gnome.org/sources/libgweather/4.4/libgweather-4.4.4.tar.xz";
PackageLibGweather[MD5]="42c548a6d45f79c2120b0a0df8a74e68";
# Automated unless edgecase
PackageLibGweather[Name]="";
PackageLibGweather[Version]="";
PackageLibGweather[Extension]="";
if [[ -n "${PackageLibGweather[Source]}" ]]; then
	filename="${PackageLibGweather[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibGweather[Name]}" ]] && PackageLibGweather[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibGweather[Version]}" ]] && PackageLibGweather[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibGweather[Extension]}" ]] && PackageLibGweather[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibGweather[Package]="${PackageLibGweather[Name]}-${PackageLibGweather[Version]}";

PackageLibGweather[Programs]="";
PackageLibGweather[Libraries]="libgweather-4.so";
PackageLibGweather[Python]="";

InstallLibGweather()
{
	# Check Installation
	CheckLibGweather && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibGweather[Name]}> Checking dependencies..."
	Required=(GeocodeGlib GTK3 LibSoup3)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GLib LibXml2 Vala)
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(GiDocGen LLVM MakeCa)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibGweather[Name]}> Building package..."
	_ExtractPackageLibGweather || return $?;
	_BuildLibGweather;
	return $?
}

CheckLibGweather()
{
	CheckInstallation 	"${PackageLibGweather[Programs]}"\
						"${PackageLibGweather[Libraries]}"\
						"${PackageLibGweather[Python]}" 1> /dev/null;
	return $?;
}

CheckLibGweatherVerbose()
{
	CheckInstallationVerbose	"${PackageLibGweather[Programs]}"\
								"${PackageLibGweather[Libraries]}"\
								"${PackageLibGweather[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibGweather()
{
	DownloadPackage	"${PackageLibGweather[Source]}"	"${SHMAN_PDIR}"	"${PackageLibGweather[Package]}${PackageLibGweather[Extension]}"	"${PackageLibGweather[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibGweather[Package]}"	"${PackageLibGweather[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibGweather()
{
	if ! cd "${SHMAN_PDIR}${PackageLibGweather[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibGweather[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibGweather[Package]}/build \
					|| { EchoError "${PackageLibGweather[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibGweather[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibGweather[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D gtk_doc=false \
				.. \
				1> /dev/null || { EchoTest KO ${PackageLibGweather[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibGweather[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibGweather[Name]} && PressAnyKeyToContinue; return 1; };

	#GIDOCGEN
	# sed "s/libgweather_full_version/'libgweather-4.4.4'/" \
	# 	-i ../doc/meson.build                             &&
	# meson configure -D gtk_doc=true                       &&
	# ninja

	EchoInfo	"${PackageLibGweather[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibGweather[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibGweather[Name]}> ninja test"
	LC_ALL=C ninja test 1> /dev/null || { EchoTest KO "${PackageLibGweather[Name]} contains known failure, continuing" && PressAnyKeyToContinue;  };
}
