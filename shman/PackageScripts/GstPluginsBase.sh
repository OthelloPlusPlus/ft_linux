#!/bin/bash

if [ ! -z "${PackageGstPluginsBase[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									GstPluginsBase								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGstPluginsBase;
PackageGstPluginsBase[Source]="https://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-1.24.12.tar.xz";
PackageGstPluginsBase[MD5]="af0d85f4dda9f750086516d834a17a8c";
PackageGstPluginsBase[Name]="gst-plugins-base";
PackageGstPluginsBase[Version]="1.24.12";
PackageGstPluginsBase[Package]="${PackageGstPluginsBase[Name]}-${PackageGstPluginsBase[Version]}";
PackageGstPluginsBase[Extension]=".tar.xz";

PackageGstPluginsBase[Programs]="gst-device-monitor-1.0 gst-discoverer-1.0 gst-play-1.0";
PackageGstPluginsBase[Libraries]="libgstallocators-1.0.so libgstapp-1.0.so libgstaudio-1.0.so libgstfft-1.0.so libgstgl-1.0.so libgstpbutils-1.0.so libgstriff-1.0.so libgstrtp-1.0.so libgstrtsp-1.0.so libgstsdp-1.0.so libgsttag-1.0.so libgstvideo-1.0.so";
PackageGstPluginsBase[Python]="";

InstallGstPluginsBase()
{
	# Check Installation
	CheckGstPluginsBase && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGstPluginsBase[Name]}> Checking dependencies..."
	Required=(Gstreamer)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(AlsaLib CDParanoia GLib ISOCodes LibGudev LibJpegTurbo LibOgg LibPng LibVorbis Mesa Pango WaylandProtocols XorgLibraries)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Graphene GTK3 Opus SDL2 Valgrind)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageGstPluginsBase[Name]}> Building package..."
	_ExtractPackageGstPluginsBase || return $?;
	_BuildGstPluginsBase;
	return $?
}

CheckGstPluginsBase()
{
	CheckInstallation 	"${PackageGstPluginsBase[Programs]}"\
						"${PackageGstPluginsBase[Libraries]}"\
						"${PackageGstPluginsBase[Python]}" 1> /dev/null;
	return $?;
}

CheckGstPluginsBaseVerbose()
{
	CheckInstallationVerbose	"${PackageGstPluginsBase[Programs]}"\
								"${PackageGstPluginsBase[Libraries]}"\
								"${PackageGstPluginsBase[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGstPluginsBase()
{
	DownloadPackage	"${PackageGstPluginsBase[Source]}"	"${SHMAN_PDIR}"	"${PackageGstPluginsBase[Package]}${PackageGstPluginsBase[Extension]}"	"${PackageGstPluginsBase[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGstPluginsBase[Package]}"	"${PackageGstPluginsBase[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildGstPluginsBase()
{
	if ! cd "${SHMAN_PDIR}${PackageGstPluginsBase[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGstPluginsBase[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGstPluginsBase[Package]}/build \
					|| { EchoError "${PackageGstPluginsBase[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGstPluginsBase[Package]}/build"; return 1; }

	EchoInfo	"${PackageGstPluginsBase[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				--wrap-mode=nodownload \
				1> /dev/null || { EchoTest KO ${PackageGstPluginsBase[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGstPluginsBase[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGstPluginsBase[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageGstPluginsBase[Name]}> ninja test"
	# ninja test 1> /dev/null || { EchoTest KO ${PackageGstPluginsBase[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageGstPluginsBase[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGstPluginsBase[Name]} && PressAnyKeyToContinue; return 1; };
}
