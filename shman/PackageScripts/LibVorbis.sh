#!/bin/bash

if [ ! -z "${PackageLibVorbis[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibVorbis								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibVorbis;
# Manual
PackageLibVorbis[Source]="https://downloads.xiph.org/releases/vorbis/libvorbis-1.3.7.tar.xz";
PackageLibVorbis[MD5]="50902641d358135f06a8392e61c9ac77";
# Automated unless edgecase
PackageLibVorbis[Name]="";
PackageLibVorbis[Version]="";
PackageLibVorbis[Extension]="";
if [[ -n "${PackageLibVorbis[Source]}" ]]; then
	filename="${PackageLibVorbis[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibVorbis[Name]}" ]] && PackageLibVorbis[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibVorbis[Version]}" ]] && PackageLibVorbis[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibVorbis[Extension]}" ]] && PackageLibVorbis[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibVorbis[Package]="${PackageLibVorbis[Name]}-${PackageLibVorbis[Version]}";

PackageLibVorbis[Programs]="";
PackageLibVorbis[Libraries]="libvorbis.so libvorbisenc.so libvorbisfile.so";
PackageLibVorbis[Python]="";

InstallLibVorbis()
{
	# Check Installation
	CheckLibVorbis && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibVorbis[Name]}> Checking dependencies..."
	Required=(LibOgg)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Doxygen Texlive)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibVorbis[Name]}> Building package..."
	_ExtractPackageLibVorbis || return $?;
	_BuildLibVorbis;
	return $?
}

CheckLibVorbis()
{
	CheckInstallation 	"${PackageLibVorbis[Programs]}"\
						"${PackageLibVorbis[Libraries]}"\
						"${PackageLibVorbis[Python]}" 1> /dev/null;
	return $?;
}

CheckLibVorbisVerbose()
{
	CheckInstallationVerbose	"${PackageLibVorbis[Programs]}"\
								"${PackageLibVorbis[Libraries]}"\
								"${PackageLibVorbis[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibVorbis()
{
	DownloadPackage	"${PackageLibVorbis[Source]}"	"${SHMAN_PDIR}"	"${PackageLibVorbis[Package]}${PackageLibVorbis[Extension]}"	"${PackageLibVorbis[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibVorbis[Package]}"	"${PackageLibVorbis[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibVorbis()
{
	if ! cd "${SHMAN_PDIR}${PackageLibVorbis[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibVorbis[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibVorbis[Package]}/build \
	# 				|| { EchoError "${PackageLibVorbis[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibVorbis[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibVorbis[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageLibVorbis[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibVorbis[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibVorbis[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibVorbis[Name]}> make -j1 check"
	make -j1 check 1> /dev/null || { EchoTest KO ${PackageLibVorbis[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibVorbis[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibVorbis[Name]} && PressAnyKeyToContinue; return 1; };
	install -v -m644 doc/Vorbis* /usr/share/doc/libvorbis-1.3.7
}
