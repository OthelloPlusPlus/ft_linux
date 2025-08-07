#!/bin/bash

if [ ! -z "${PackagePulseAudio[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									PulseAudio								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePulseAudio;
# Manual
PackagePulseAudio[Source]="https://www.freedesktop.org/software/pulseaudio/releases/pulseaudio-17.0.tar.xz";
PackagePulseAudio[MD5]="c4a3596a26ff4b9dcd0c394dd1d4f8ee";
# Automated unless edgecase
PackagePulseAudio[Name]="";
PackagePulseAudio[Version]="";
PackagePulseAudio[Extension]="";
if [[ -n "${PackagePulseAudio[Source]}" ]]; then
	filename="${PackagePulseAudio[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackagePulseAudio[Name]}" ]] && PackagePulseAudio[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackagePulseAudio[Version]}" ]] && PackagePulseAudio[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackagePulseAudio[Extension]}" ]] && PackagePulseAudio[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackagePulseAudio[Package]="${PackagePulseAudio[Name]}-${PackagePulseAudio[Version]}";
# requires fftw: qpaeq
PackagePulseAudio[Programs]="pacat pacmd pactl padsp pamon paplay parec parecord pasuspender pax11publish pulseaudio start-pulseaudio-x11";
#libpulsecommon-17.0.so libpulsecore-17.0.so libpulsedsp.so
PackagePulseAudio[Libraries]="libpulse.so libpulse-mainloop-glib.so libpulse-simple.so";
PackagePulseAudio[Python]="";

InstallPulseAudio()
{
	# Check Installation
	CheckPulseAudio && return $?;

	# Check Dependencies
	EchoInfo	"${PackagePulseAudio[Name]}> Checking dependencies..."
	Required=(LibSndfile)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	# kept recompiling for some reason... GLib
	Recommended=(AlsaLib Dbus Elogind Speex XorgLibraries)
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Avahi BlueZ Doxygen Fftw GstPulginsBase GTK3 LibSamplerate SBC Valgrind)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackagePulseAudio[Name]}> Building package..."
	_ExtractPackagePulseAudio || return $?;
	_BuildPulseAudio;
	return $?
}

CheckPulseAudio()
{
	CheckInstallation 	"${PackagePulseAudio[Programs]}"\
						"${PackagePulseAudio[Libraries]}"\
						"${PackagePulseAudio[Python]}" 1> /dev/null;
	return $?;
}

CheckPulseAudioVerbose()
{
	CheckInstallationVerbose	"${PackagePulseAudio[Programs]}"\
								"${PackagePulseAudio[Libraries]}"\
								"${PackagePulseAudio[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackagePulseAudio()
{
	DownloadPackage	"${PackagePulseAudio[Source]}"	"${SHMAN_PDIR}"	"${PackagePulseAudio[Package]}${PackagePulseAudio[Extension]}"	"${PackagePulseAudio[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackagePulseAudio[Package]}"	"${PackagePulseAudio[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildPulseAudio()
{
	if ! cd "${SHMAN_PDIR}${PackagePulseAudio[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackagePulseAudio[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackagePulseAudio[Package]}/build \
					|| { EchoError "${PackagePulseAudio[Name]}> Failed to enter ${SHMAN_PDIR}${PackagePulseAudio[Package]}/build"; return 1; }

	EchoInfo	"${PackagePulseAudio[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D database=gdbm \
				-D doxygen=false \
				-D bluez5=disabled \
				.. \
				1> /dev/null || { EchoTest KO ${PackagePulseAudio[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePulseAudio[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackagePulseAudio[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePulseAudio[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackagePulseAudio[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePulseAudio[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackagePulseAudio[Name]} && PressAnyKeyToContinue; return 1; };
	rm /usr/share/dbus-1/system.d/pulseaudio-system.conf
}
