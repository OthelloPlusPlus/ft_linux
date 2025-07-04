#!/bin/bash

if [ ! -z "${PackageLibOgg[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibOgg								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibOgg;
# Manual
PackageLibOgg[Source]="https://downloads.xiph.org/releases/ogg/libogg-1.3.5.tar.xz";
PackageLibOgg[MD5]="3178c98341559657a15b185bf5d700a5";
# Automated unless edgecase
PackageLibOgg[Name]="";
PackageLibOgg[Version]="";
PackageLibOgg[Extension]="";
if [[ -n "${PackageLibOgg[Source]}" ]]; then
	filename="${PackageLibOgg[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibOgg[Name]}" ]] && PackageLibOgg[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibOgg[Version]}" ]] && PackageLibOgg[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibOgg[Extension]}" ]] && PackageLibOgg[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibOgg[Package]="${PackageLibOgg[Name]}-${PackageLibOgg[Version]}";

PackageLibOgg[Programs]="";
PackageLibOgg[Libraries]="libogg.so";
PackageLibOgg[Python]="";

InstallLibOgg()
{
	# Check Installation
	CheckLibOgg && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibOgg[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibOgg[Name]}> Building package..."
	_ExtractPackageLibOgg || return $?;
	_BuildLibOgg;
	return $?
}

CheckLibOgg()
{
	CheckInstallation 	"${PackageLibOgg[Programs]}"\
						"${PackageLibOgg[Libraries]}"\
						"${PackageLibOgg[Python]}" 1> /dev/null;
	return $?;
}

CheckLibOggVerbose()
{
	CheckInstallationVerbose	"${PackageLibOgg[Programs]}"\
								"${PackageLibOgg[Libraries]}"\
								"${PackageLibOgg[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibOgg()
{
	DownloadPackage	"${PackageLibOgg[Source]}"	"${SHMAN_PDIR}"	"${PackageLibOgg[Package]}${PackageLibOgg[Extension]}"	"${PackageLibOgg[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibOgg[Package]}"	"${PackageLibOgg[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibOgg()
{
	if ! cd "${SHMAN_PDIR}${PackageLibOgg[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibOgg[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibOgg[Package]}/build \
	# 				|| { EchoError "${PackageLibOgg[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibOgg[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibOgg[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--docdir=/usr/share/doc/libogg-1.3.5 \
				1> /dev/null || { EchoTest KO ${PackageLibOgg[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibOgg[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibOgg[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibOgg[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibOgg[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibOgg[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibOgg[Name]} && PressAnyKeyToContinue; return 1; };
}
