#!/bin/bash

if [ ! -z "${PackageGstPluginsBad[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#								GstPluginsBad								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGstPluginsBad;
PackageGstPluginsBad[Source]="https://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-1.24.12.tar.xz";
PackageGstPluginsBad[MD5]="f2e4b24dca97397158e496059ec65ce6";
PackageGstPluginsBad[Name]="gst-plugins-bad";
PackageGstPluginsBad[Version]="1.24.12";
PackageGstPluginsBad[Package]="${PackageGstPluginsBad[Name]}-${PackageGstPluginsBad[Version]}";
PackageGstPluginsBad[Extension]=".tar.xz";

PackageGstPluginsBad[Programs]="gst-transcoder-1.0 playout";
# removed libgstva-1.0.so
PackageGstPluginsBad[Libraries]="libgstadaptivedemux-1.0.so libgstanalytics-1.0.so libgstbadaudio-1.0.so libgstbasecamerabinsrc-1.0.so libgstcuda-1.0.so libgstcodecparsers-1.0.so libgstcodecs-1.0.so libgstdxva-1.0.so libgstinsertbin-1.0.so libgstisoff-1.0.so libgstmpegts-1.0.so libgstmse-1.0.so libgstphotography-1.0.so libgstplay-1.0.so libgstplayer-1.0.so libgstsctp-1.0.so libgsttranscoder-1.0.so libgsturidownloader-1.0.so libgstwayland-1.0.so libgstwebrtc-1.0.so";
PackageGstPluginsBad[Python]="";

InstallGstPluginsBad()
{
	# Check Installation
	CheckGstPluginsBad && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGstPluginsBad[Name]}> Checking dependencies..."
	Required=(GstPluginsBase)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(LibDvdread LibDvdnav LibVa SoundTouch)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	# too fucking many...
	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageGstPluginsBad[Name]}> Building package..."
	_ExtractPackageGstPluginsBad || return $?;
	_BuildGstPluginsBad;
	return $?
}

CheckGstPluginsBad()
{
	CheckInstallation 	"${PackageGstPluginsBad[Programs]}"\
						"${PackageGstPluginsBad[Libraries]}"\
						"${PackageGstPluginsBad[Python]}" 1> /dev/null;
	return $?;
}

CheckGstPluginsBadVerbose()
{
	CheckInstallationVerbose	"${PackageGstPluginsBad[Programs]}"\
								"${PackageGstPluginsBad[Libraries]}"\
								"${PackageGstPluginsBad[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGstPluginsBad()
{
	DownloadPackage	"${PackageGstPluginsBad[Source]}"	"${SHMAN_PDIR}"	"${PackageGstPluginsBad[Package]}${PackageGstPluginsBad[Extension]}"	"${PackageGstPluginsBad[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGstPluginsBad[Package]}"	"${PackageGstPluginsBad[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildGstPluginsBad()
{
	if ! cd "${SHMAN_PDIR}${PackageGstPluginsBad[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGstPluginsBad[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGstPluginsBad[Package]}/build \
					|| { EchoError "${PackageGstPluginsBad[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGstPluginsBad[Package]}/build"; return 1; }

	EchoInfo	"${PackageGstPluginsBad[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D gpl=enabled 1> /dev/null || { EchoTest KO ${PackageGstPluginsBad[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGstPluginsBad[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGstPluginsBad[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageGstPluginsBad[Name]}> ninja test"
	# ninja test 1> /dev/null || { EchoTest KO ${PackageGstPluginsBad[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGstPluginsBad[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGstPluginsBad[Name]} && PressAnyKeyToContinue; return 1; };
}
