#!/bin/bash

if [ ! -z "${PackageLibRsvg[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibRsvg								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibRsvg;
# Manual
PackageLibRsvg[Source]="https://download.gnome.org/sources/librsvg/2.59/librsvg-2.59.2.tar.xz";
PackageLibRsvg[MD5]="6d495c8bb2ee0cb0a62856c790a67298";
# Automated unless edgecase
PackageLibRsvg[Name]="";
PackageLibRsvg[Version]="";
PackageLibRsvg[Extension]="";
if [[ -n "${PackageLibRsvg[Source]}" ]]; then
	filename="${PackageLibRsvg[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibRsvg[Name]}" ]] && PackageLibRsvg[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibRsvg[Version]}" ]] && PackageLibRsvg[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibRsvg[Extension]}" ]] && PackageLibRsvg[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibRsvg[Package]="${PackageLibRsvg[Name]}-${PackageLibRsvg[Version]}";

PackageLibRsvg[Programs]="rsvg-convert";
# moved libpixbufloader-svg.so to seperate check
PackageLibRsvg[Libraries]="librsvg-2.so";
PackageLibRsvg[Python]="";

InstallLibRsvg()
{
	# Check Installation
	CheckLibRsvg && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibRsvg[Name]}> Checking dependencies..."
	Required=(CargoC GdkPixbuf Pango Rustc FreeTypeChain)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GLib Vala)
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Docutils GiDocGen XorgFonts)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibRsvg[Name]}> Building package..."
	_ExtractPackageLibRsvg || return $?;
	_BuildLibRsvg;
	return $?
}

CheckLibRsvg()
{
	CheckInstallation 	"${PackageLibRsvg[Programs]}"\
						"${PackageLibRsvg[Libraries]}"\
						"${PackageLibRsvg[Python]}" 1> /dev/null || return $?;

	ls /usr/lib*/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader*svg.so;
	return 0;
}

CheckLibRsvgVerbose()
{
	CheckInstallationVerbose	"${PackageLibRsvg[Programs]}"\
								"${PackageLibRsvg[Libraries]}"\
								"${PackageLibRsvg[Python]}" || return $?;

	ls /usr/lib*/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader*svg.so || { echo -ec "${C_RED}libpixbufloader*svg.so${C_RESET} "; return 1; };
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibRsvg()
{
	DownloadPackage	"${PackageLibRsvg[Source]}"	"${SHMAN_PDIR}"	"${PackageLibRsvg[Package]}${PackageLibRsvg[Extension]}"	"${PackageLibRsvg[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibRsvg[Package]}"	"${PackageLibRsvg[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibRsvg()
{
	if ! cd "${SHMAN_PDIR}${PackageLibRsvg[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibRsvg[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibRsvg[Name]}> Fix installation path"
	sed -e "/OUTDIR/s|,| / 'librsvg-2.59.2', '--no-namespace-dir',|" \
		-e '/output/s|Rsvg-2.0|librsvg-2.59.2|'                      \
		-i doc/meson.build

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibRsvg[Package]}/build \
					|| { EchoError "${PackageLibRsvg[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibRsvg[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibRsvg[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageLibRsvg[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibRsvg[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibRsvg[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageLibRsvg[Name]}> ninja test"
	# ninja test 1> /dev/null || { EchoTest KO ${PackageLibRsvg[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibRsvg[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibRsvg[Name]} && PressAnyKeyToContinue; return 1; };
}
