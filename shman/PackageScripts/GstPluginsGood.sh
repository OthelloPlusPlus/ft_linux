#!/bin/bash

if [ ! -z "${PackageGstPluginsGood[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#								GstPluginsGood								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGstPluginsGood;
PackageGstPluginsGood[Source]="https://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-1.24.12.tar.xz";
PackageGstPluginsGood[MD5]="99f259e6aca8b499ece578948cb91bbc";
PackageGstPluginsGood[Name]="gst-plugins-good";
PackageGstPluginsGood[Version]="1.24.12";
PackageGstPluginsGood[Package]="${PackageGstPluginsGood[Name]}-${PackageGstPluginsGood[Version]}";
PackageGstPluginsGood[Extension]=".tar.xz";

PackageGstPluginsGood[Programs]="";
PackageGstPluginsGood[Libraries]="";
PackageGstPluginsGood[Python]="";

InstallGstPluginsGood()
{
	# Check Installation
	CheckGstPluginsGood && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGstPluginsGood[Name]}> Checking dependencies..."
	Required=(GstPluginsBase)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Cairo FLAC GdkPixbuf LAME LibSoup2 LibSoup3 LibVpx Mpg123 NASM PulseAudio)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	# Too many...
	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageGstPluginsGood[Name]}> Building package..."
	_ExtractPackageGstPluginsGood || return $?;
	_BuildGstPluginsGood;
	return $?
}

CheckGstPluginsGood()
{
	return 1;
	CheckInstallation 	"${PackageGstPluginsGood[Programs]}"\
						"${PackageGstPluginsGood[Libraries]}"\
						"${PackageGstPluginsGood[Python]}" 1> /dev/null;
	return $?;
}

CheckGstPluginsGoodVerbose()
{
	EchoWarning	"No valid check implemented" >&2;
	return 1;
	CheckInstallationVerbose	"${PackageGstPluginsGood[Programs]}"\
								"${PackageGstPluginsGood[Libraries]}"\
								"${PackageGstPluginsGood[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGstPluginsGood()
{
	DownloadPackage	"${PackageGstPluginsGood[Source]}"	"${SHMAN_PDIR}"	"${PackageGstPluginsGood[Package]}${PackageGstPluginsGood[Extension]}"	"${PackageGstPluginsGood[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGstPluginsGood[Package]}"	"${PackageGstPluginsGood[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildGstPluginsGood()
{
	if ! cd "${SHMAN_PDIR}${PackageGstPluginsGood[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGstPluginsGood[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGstPluginsGood[Package]}/build \
					|| { EchoError "${PackageGstPluginsGood[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGstPluginsGood[Package]}/build"; return 1; }

	EchoInfo	"${PackageGstPluginsGood[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				1> /dev/null || { EchoTest KO ${PackageGstPluginsGood[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGstPluginsGood[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGstPluginsGood[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageGstPluginsGood[Name]}> ninja test"
	# ninja test 1> /dev/null || { EchoTest KO ${PackageGstPluginsGood[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageGstPluginsGood[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGstPluginsGood[Name]} && PressAnyKeyToContinue; return 1; };
}
