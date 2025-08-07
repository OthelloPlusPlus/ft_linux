#!/bin/bash

if [ ! -z "${PackageXclock[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Xclock								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXclock;
# Manual
PackageXclock[Source]="https://www.x.org/pub/individual/app/xclock-1.1.1.tar.xz";
PackageXclock[MD5]="1273e3f4c85f1801be11a5247c382d07";
# Automated unless edgecase
PackageXclock[Name]="";
PackageXclock[Version]="";
PackageXclock[Extension]="";
if [[ -n "${PackageXclock[Source]}" ]]; then
	filename="${PackageXclock[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageXclock[Name]}" ]] && PackageXclock[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageXclock[Version]}" ]] && PackageXclock[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageXclock[Extension]}" ]] && PackageXclock[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageXclock[Package]="${PackageXclock[Name]}-${PackageXclock[Version]}";

PackageXclock[Programs]="xclock";
PackageXclock[Libraries]="";
PackageXclock[Python]="";

InstallXclock()
{
	# Check Installation
	CheckXclock && return $?;

	# Check Dependencies
	EchoInfo	"${PackageXclock[Name]}> Checking dependencies..."
	Required=(XorgLibraries)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageXclock[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageXclock[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageXclock[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageXclock[Name]}> Building package..."
	_ExtractPackageXclock || return $?;
	_BuildXclock;
	return $?
}

CheckXclock()
{
	CheckInstallation 	"${PackageXclock[Programs]}"\
						"${PackageXclock[Libraries]}"\
						"${PackageXclock[Python]}" 1> /dev/null;
	return $?;
}

CheckXclockVerbose()
{
	CheckInstallationVerbose	"${PackageXclock[Programs]}"\
								"${PackageXclock[Libraries]}"\
								"${PackageXclock[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageXclock()
{
	DownloadPackage	"${PackageXclock[Source]}"	"${SHMAN_PDIR}"	"${PackageXclock[Package]}${PackageXclock[Extension]}"	"${PackageXclock[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageXclock[Package]}"	"${PackageXclock[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildXclock()
{
	if ! cd "${SHMAN_PDIR}${PackageXclock[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageXclock[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageXclock[Package]}/build \
	# 				|| { EchoError "${PackageXclock[Name]}> Failed to enter ${SHMAN_PDIR}${PackageXclock[Package]}/build"; return 1; }

	EchoInfo	"${PackageXclock[Name]}> Configure"
	./configure $XORG_CONFIG 1> /dev/null || { EchoTest KO ${PackageXclock[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXclock[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageXclock[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXclock[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageXclock[Name]} && PressAnyKeyToContinue; return 1; };
}
