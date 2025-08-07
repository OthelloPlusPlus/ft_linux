#!/bin/bash

if [ ! -z "${PackageLibNsl2[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibNsl2								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibNsl2;
# Manual
PackageLibNsl2[Source]="https://github.com/thkukuk/libnsl/releases/download/v2.0.1/libnsl-2.0.1.tar.xz";
PackageLibNsl2[MD5]="fb178645dfa85ebab0f1e42e219b42ae";
# Automated unless edgecase
PackageLibNsl2[Name]="";
PackageLibNsl2[Version]="";
PackageLibNsl2[Extension]="";
if [[ -n "${PackageLibNsl2[Source]}" ]]; then
	filename="${PackageLibNsl2[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibNsl2[Name]}" ]] && PackageLibNsl2[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibNsl2[Version]}" ]] && PackageLibNsl2[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibNsl2[Extension]}" ]] && PackageLibNsl2[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibNsl2[Package]="${PackageLibNsl2[Name]}-${PackageLibNsl2[Version]}";

PackageLibNsl2[Programs]="";
PackageLibNsl2[Libraries]="libnsl.so";
PackageLibNsl2[Python]="";

InstallLibNsl2()
{
	# Check Installation
	CheckLibNsl2 && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibNsl2[Name]}> Checking dependencies..."
	Required=(LibTirpc1)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageLibNsl2[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageLibNsl2[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageLibNsl2[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibNsl2[Name]}> Building package..."
	_ExtractPackageLibNsl2 || return $?;
	_BuildLibNsl2;
	return $?
}

CheckLibNsl2()
{
	CheckInstallation 	"${PackageLibNsl2[Programs]}"\
						"${PackageLibNsl2[Libraries]}"\
						"${PackageLibNsl2[Python]}" 1> /dev/null;
	return $?;
}

CheckLibNsl2Verbose()
{
	CheckInstallationVerbose	"${PackageLibNsl2[Programs]}"\
								"${PackageLibNsl2[Libraries]}"\
								"${PackageLibNsl2[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibNsl2()
{
	DownloadPackage	"${PackageLibNsl2[Source]}"	"${SHMAN_PDIR}"	"${PackageLibNsl2[Package]}${PackageLibNsl2[Extension]}"	"${PackageLibNsl2[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibNsl2[Package]}"	"${PackageLibNsl2[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibNsl2()
{
	if ! cd "${SHMAN_PDIR}${PackageLibNsl2[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibNsl2[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibNsl2[Package]}/build \
	# 				|| { EchoError "${PackageLibNsl2[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibNsl2[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibNsl2[Name]}> Configure"
	./configure --sysconfdir=/etc \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageLibNsl2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibNsl2[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibNsl2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibNsl2[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibNsl2[Name]} && PressAnyKeyToContinue; return 1; };
}
