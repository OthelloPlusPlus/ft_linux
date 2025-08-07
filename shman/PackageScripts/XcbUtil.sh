#!/bin/bash

if [ ! -z "${PackageXcbUtil[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									XcbUtil								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXcbUtil;
# Manual
PackageXcbUtil[Source]="https://xcb.freedesktop.org/dist/xcb-util-0.4.1.tar.xz";
PackageXcbUtil[MD5]="34d749eab0fd0ffd519ac64798d79847";
# Automated unless edgecase
PackageXcbUtil[Name]="";
PackageXcbUtil[Version]="";
PackageXcbUtil[Extension]="";
if [[ -n "${PackageXcbUtil[Source]}" ]]; then
	filename="${PackageXcbUtil[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageXcbUtil[Name]}" ]] && PackageXcbUtil[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageXcbUtil[Version]}" ]] && PackageXcbUtil[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageXcbUtil[Extension]}" ]] && PackageXcbUtil[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageXcbUtil[Package]="${PackageXcbUtil[Name]}-${PackageXcbUtil[Version]}";

PackageXcbUtil[Programs]="";
PackageXcbUtil[Libraries]="libxcb-util.so";
PackageXcbUtil[Python]="";

InstallXcbUtil()
{
	# Check Installation
	CheckXcbUtil && return $?;

	# Check Dependencies
	EchoInfo	"${PackageXcbUtil[Name]}> Checking dependencies..."
	Required=(LibXcb)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Doxygen)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageXcbUtil[Name]}> Building package..."
	_ExtractPackageXcbUtil || return $?;
	_BuildXcbUtil;
	return $?
}

CheckXcbUtil()
{
	CheckInstallation 	"${PackageXcbUtil[Programs]}"\
						"${PackageXcbUtil[Libraries]}"\
						"${PackageXcbUtil[Python]}" 1> /dev/null;
	return $?;
}

CheckXcbUtilVerbose()
{
	CheckInstallationVerbose	"${PackageXcbUtil[Programs]}"\
								"${PackageXcbUtil[Libraries]}"\
								"${PackageXcbUtil[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageXcbUtil()
{
	DownloadPackage	"${PackageXcbUtil[Source]}"	"${SHMAN_PDIR}"	"${PackageXcbUtil[Package]}${PackageXcbUtil[Extension]}"	"${PackageXcbUtil[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageXcbUtil[Package]}"	"${PackageXcbUtil[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildXcbUtil()
{
	if ! cd "${SHMAN_PDIR}${PackageXcbUtil[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageXcbUtil[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageXcbUtil[Package]}/build \
	# 				|| { EchoError "${PackageXcbUtil[Name]}> Failed to enter ${SHMAN_PDIR}${PackageXcbUtil[Package]}/build"; return 1; }

	EchoInfo	"${PackageXcbUtil[Name]}> Configure"
	./configure $XORG_CONFIG 1> /dev/null || { EchoTest KO ${PackageXcbUtil[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXcbUtil[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageXcbUtil[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXcbUtil[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageXcbUtil[Name]} && PressAnyKeyToContinue; return 1; };
}
