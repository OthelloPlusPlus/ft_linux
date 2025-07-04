#!/bin/bash

if [ ! -z "${PackagePipewire[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Pipewire								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePipewire;
PackagePipewire[Source]="https://gitlab.freedesktop.org/pipewire/pipewire/-/archive/1.2.7/pipewire-1.2.7.tar.bz2";
PackagePipewire[MD5]="244a64d8873a868d102b2dd02c964906";
PackagePipewire[Name]="pipewire";
PackagePipewire[Version]="1.2.7";
PackagePipewire[Package]="${PackagePipewire[Name]}-${PackagePipewire[Version]}";
PackagePipewire[Extension]=".tar.bz2";

PackagePipewire[Programs]="pipewire pw-cat pw-cli pw-config pw-dot pw-dump pw-jack pw-link pw-loopback pw-metadata pw-mididump pw-mon pw-profiler pw-reserve pw-top pw-v4l2 spa-acp-tool spa-inspect spa-json-dump spa-monitor spa-resample and pipewire-aes67 pipewire-avb pipewire-pulse pw-dsdplay pw-encplay pw-midiplay pw-midirecord pw-play pw-record";
# too many...
PackagePipewire[Libraries]="libpipewire-0.3.so";
PackagePipewire[Python]="";

InstallPipewire()
{
	# Check Installation
	CheckPipewire && return $?;

	# Check Dependencies
	EchoInfo	"${PackagePipewire[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(BlueZ Dbus Gstreamer GstPluginsBase PulseAudio SBC V4lUtils)
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(AlsaLib Avahi FdkAac FFmpeg LibCanberra LibDrm LibXcb LibSndfile LibUsb Opus SDL2 Valgrind VulkanLoader XorgLibraries Doxygen Graphviz)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackagePipewire[Name]}> Building package..."
	_ExtractPackagePipewire || return $?;
	_BuildPipewire;
	return $?
}

CheckPipewire()
{
	CheckInstallation 	"${PackagePipewire[Programs]}"\
						"${PackagePipewire[Libraries]}"\
						"${PackagePipewire[Python]}" 1> /dev/null;
	return $?;
}

CheckPipewireVerbose()
{
	CheckInstallationVerbose	"${PackagePipewire[Programs]}"\
								"${PackagePipewire[Libraries]}"\
								"${PackagePipewire[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackagePipewire()
{
	DownloadPackage	"${PackagePipewire[Source]}"	"${SHMAN_PDIR}"	"${PackagePipewire[Package]}${PackagePipewire[Extension]}"	"${PackagePipewire[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackagePipewire[Package]}"	"${PackagePipewire[Extension]}" || return $?;

	for URL in \
	# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildPipewire()
{
	if ! cd "${SHMAN_PDIR}${PackagePipewire[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackagePipewire[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackagePipewire[Package]}/build \
					|| { EchoError "${PackagePipewire[Name]}> Failed to enter ${SHMAN_PDIR}${PackagePipewire[Package]}/build"; return 1; }

	EchoInfo	"${PackagePipewire[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D session-managers="[]" \
				1> /dev/null || { EchoTest KO ${PackagePipewire[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePipewire[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackagePipewire[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePipewire[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackagePipewire[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePipewire[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackagePipewire[Name]} && PressAnyKeyToContinue; return 1; };
}
