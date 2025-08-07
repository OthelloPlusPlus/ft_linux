#!/bin/bash

if [ ! -z "${PackageRpcsvcProto[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									RpcsvcProto								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageRpcsvcProto;
# Manual
PackageRpcsvcProto[Source]="https://github.com/thkukuk/rpcsvc-proto/releases/download/v1.4.4/rpcsvc-proto-1.4.4.tar.xz";
PackageRpcsvcProto[MD5]="bf908de360308d909e9cc469402ff2ef";
# Automated unless edgecase
PackageRpcsvcProto[Name]="";
PackageRpcsvcProto[Version]="";
PackageRpcsvcProto[Extension]="";
if [[ -n "${PackageRpcsvcProto[Source]}" ]]; then
	filename="${PackageRpcsvcProto[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageRpcsvcProto[Name]}" ]] && PackageRpcsvcProto[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageRpcsvcProto[Version]}" ]] && PackageRpcsvcProto[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageRpcsvcProto[Extension]}" ]] && PackageRpcsvcProto[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageRpcsvcProto[Package]="${PackageRpcsvcProto[Name]}-${PackageRpcsvcProto[Version]}";

PackageRpcsvcProto[Programs]="rpcgen";
PackageRpcsvcProto[Libraries]="";
PackageRpcsvcProto[Python]="";

InstallRpcsvcProto()
{
	# Check Installation
	CheckRpcsvcProto && return $?;

	# Check Dependencies
	EchoInfo	"${PackageRpcsvcProto[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageRpcsvcProto[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageRpcsvcProto[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageRpcsvcProto[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageRpcsvcProto[Name]}> Building package..."
	_ExtractPackageRpcsvcProto || return $?;
	_BuildRpcsvcProto || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageRpcsvcProto[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckRpcsvcProto()
{
	CheckInstallation 	"${PackageRpcsvcProto[Programs]}"\
						"${PackageRpcsvcProto[Libraries]}"\
						"${PackageRpcsvcProto[Python]}" 1> /dev/null;
	return $?;
}

CheckRpcsvcProtoVerbose()
{
	CheckInstallationVerbose	"${PackageRpcsvcProto[Programs]}"\
								"${PackageRpcsvcProto[Libraries]}"\
								"${PackageRpcsvcProto[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageRpcsvcProto()
{
	DownloadPackage	"${PackageRpcsvcProto[Source]}"	"${SHMAN_PDIR}"	"${PackageRpcsvcProto[Package]}${PackageRpcsvcProto[Extension]}"	"${PackageRpcsvcProto[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageRpcsvcProto[Package]}"	"${PackageRpcsvcProto[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildRpcsvcProto()
{
	if ! cd "${SHMAN_PDIR}${PackageRpcsvcProto[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageRpcsvcProto[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageRpcsvcProto[Package]}/build \
	# 				|| { EchoError "${PackageRpcsvcProto[Name]}> Failed to enter ${SHMAN_PDIR}${PackageRpcsvcProto[Package]}/build"; return 1; }

	EchoInfo	"${PackageRpcsvcProto[Name]}> Configure"
	./configure --sysconfdir=/etc 1> /dev/null || { EchoTest KO ${PackageRpcsvcProto[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageRpcsvcProto[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageRpcsvcProto[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageRpcsvcProto[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageRpcsvcProto[Name]} && PressAnyKeyToContinue; return 1; };
}
