#!/bin/bash

if [ ! -z "${PackageLibCanberra[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibCanberra								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibCanberra;
# Manual
PackageLibCanberra[Source]="https://0pointer.de/lennart/projects/libcanberra/libcanberra-0.30.tar.xz";
PackageLibCanberra[MD5]="34cb7e4430afaf6f447c4ebdb9b42072";
# Automated unless edgecase
PackageLibCanberra[Name]="";
PackageLibCanberra[Version]="";
PackageLibCanberra[Extension]="";
if [[ -n "${PackageLibCanberra[Source]}" ]]; then
	filename="${PackageLibCanberra[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibCanberra[Name]}" ]] && PackageLibCanberra[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibCanberra[Version]}" ]] && PackageLibCanberra[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibCanberra[Extension]}" ]] && PackageLibCanberra[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibCanberra[Package]="${PackageLibCanberra[Name]}-${PackageLibCanberra[Version]}";

PackageLibCanberra[Programs]="canberra-boot canberra-gtk-play";
PackageLibCanberra[Libraries]="libcanberra-gtk3.so libcanberra.so";
PackageLibCanberra[Python]="";

InstallLibCanberra()
{
	# Check Installation
	CheckLibCanberra && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibCanberra[Name]}> Checking dependencies..."
	Required=(LibVorbis)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(AlsaLib Gstreamer GTK3)
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(PulseAudio)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibCanberra[Name]}> Building package..."
	_ExtractPackageLibCanberra || return $?;
	_BuildLibCanberra;
	return $?
}

CheckLibCanberra()
{
	CheckInstallation 	"${PackageLibCanberra[Programs]}"\
						"${PackageLibCanberra[Libraries]}"\
						"${PackageLibCanberra[Python]}" 1> /dev/null;
	return $?;
}

CheckLibCanberraVerbose()
{
	CheckInstallationVerbose	"${PackageLibCanberra[Programs]}"\
								"${PackageLibCanberra[Libraries]}"\
								"${PackageLibCanberra[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibCanberra()
{
	DownloadPackage	"${PackageLibCanberra[Source]}"	"${SHMAN_PDIR}"	"${PackageLibCanberra[Package]}${PackageLibCanberra[Extension]}"	"${PackageLibCanberra[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibCanberra[Package]}"	"${PackageLibCanberra[Extension]}" || return $?;

	for URL in \
		"https://www.linuxfromscratch.org/patches/blfs/12.3/libcanberra-0.30-wayland-1.patch"
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibCanberra()
{
	if ! cd "${SHMAN_PDIR}${PackageLibCanberra[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibCanberra[Package]}";
		return 1;
	fi

	patch -Np1 -i ../libcanberra-0.30-wayland-1.patch

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibCanberra[Package]}/build \
	# 				|| { EchoError "${PackageLibCanberra[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibCanberra[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibCanberra[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-oss \
				1> /dev/null || { EchoTest KO ${PackageLibCanberra[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibCanberra[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibCanberra[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibCanberra[Name]}> make install"
	make docdir=/usr/share/doc/libcanberra-0.30 install 1> /dev/null || { EchoTest KO ${PackageLibCanberra[Name]} && PressAnyKeyToContinue; return 1; };
}
