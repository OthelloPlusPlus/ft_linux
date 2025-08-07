#!/bin/bash

if [ ! -z "${PackageTwm[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Twm								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageTwm;
# Manual
PackageTwm[Source]="https://www.x.org/pub/individual/app/twm-1.0.12.tar.xz";
PackageTwm[MD5]="805ee08b5a87e1103dfe2eb925b613b4";
# Automated unless edgecase
PackageTwm[Name]="";
PackageTwm[Version]="";
PackageTwm[Extension]="";
if [[ -n "${PackageTwm[Source]}" ]]; then
	filename="${PackageTwm[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageTwm[Name]}" ]] && PackageTwm[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageTwm[Version]}" ]] && PackageTwm[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageTwm[Extension]}" ]] && PackageTwm[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageTwm[Package]="${PackageTwm[Name]}-${PackageTwm[Version]}";

PackageTwm[Programs]="twm";
PackageTwm[Libraries]="";
PackageTwm[Python]="";

InstallTwm()
{
	# Check Installation
	CheckTwm && return $?;

	# Check Dependencies
	EchoInfo	"${PackageTwm[Name]}> Checking dependencies..."
	# Required=(XorgServer)
	# for Dependency in "${Required[@]}"; do
	# 	# EchoInfo	"${PackageTwm[Name]}> Checking required ${Dependency}..."
	# 	(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	# done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageTwm[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageTwm[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageTwm[Name]}> Building package..."
	_ExtractPackageTwm || return $?;
	_BuildTwm;
	return $?
}

CheckTwm()
{
	CheckInstallation 	"${PackageTwm[Programs]}"\
						"${PackageTwm[Libraries]}"\
						"${PackageTwm[Python]}" 1> /dev/null;
	return $?;
}

CheckTwmVerbose()
{
	CheckInstallationVerbose	"${PackageTwm[Programs]}"\
								"${PackageTwm[Libraries]}"\
								"${PackageTwm[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageTwm()
{
	DownloadPackage	"${PackageTwm[Source]}"	"${SHMAN_PDIR}"	"${PackageTwm[Package]}${PackageTwm[Extension]}"	"${PackageTwm[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageTwm[Package]}"	"${PackageTwm[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildTwm()
{
	if ! cd "${SHMAN_PDIR}${PackageTwm[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageTwm[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageTwm[Package]}/build \
	# 				|| { EchoError "${PackageTwm[Name]}> Failed to enter ${SHMAN_PDIR}${PackageTwm[Package]}/build"; return 1; }


	EchoInfo	"${PackageTwm[Name]}> sed src/Makefile.in"
	sed -i -e '/^rcdir =/s,^\(rcdir = \).*,\1/etc/X11/app-defaults,' src/Makefile.in

	EchoInfo	"${PackageTwm[Name]}> Configure"
	./configure $XORG_CONFIG 1> /dev/null || { EchoTest KO ${PackageTwm[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTwm[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageTwm[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTwm[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageTwm[Name]} && PressAnyKeyToContinue; return 1; };
}
