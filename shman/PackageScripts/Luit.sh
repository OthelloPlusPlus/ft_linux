#!/bin/bash

if [ ! -z "${PackageLuit[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Luit								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLuit;
# Manual
PackageLuit[Source]="https://invisible-mirror.net/archives/luit/luit-20240910.tgz";
PackageLuit[MD5]="c9db8c12a3ad697a075179f07b099eaf";
# Automated unless edgecase
PackageLuit[Name]="luit";
PackageLuit[Version]="20240910";
PackageLuit[Extension]=".tgz";
if [[ -n "${PackageLuit[Source]}" ]]; then
	filename="${PackageLuit[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLuit[Name]}" ]] && PackageLuit[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLuit[Version]}" ]] && PackageLuit[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLuit[Extension]}" ]] && PackageLuit[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLuit[Package]="${PackageLuit[Name]}-${PackageLuit[Version]}";

PackageLuit[Programs]="luit";
PackageLuit[Libraries]="";
PackageLuit[Python]="";

InstallLuit()
{
	# Check Installation
	CheckLuit && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLuit[Name]}> Checking dependencies..."
	Required=(XorgApplications)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageLuit[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageLuit[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageLuit[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLuit[Name]}> Building package..."
	_ExtractPackageLuit || return $?;
	_BuildLuit;
	return $?
}

CheckLuit()
{
	CheckInstallation 	"${PackageLuit[Programs]}"\
						"${PackageLuit[Libraries]}"\
						"${PackageLuit[Python]}" 1> /dev/null;
	return $?;
}

CheckLuitVerbose()
{
	CheckInstallationVerbose	"${PackageLuit[Programs]}"\
								"${PackageLuit[Libraries]}"\
								"${PackageLuit[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLuit()
{
	DownloadPackage	"${PackageLuit[Source]}"	"${SHMAN_PDIR}"	"${PackageLuit[Package]}${PackageLuit[Extension]}"	"${PackageLuit[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLuit[Package]}"	"${PackageLuit[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLuit()
{
	if ! cd "${SHMAN_PDIR}${PackageLuit[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLuit[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLuit[Package]}/build \
	# 				|| { EchoError "${PackageLuit[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLuit[Package]}/build"; return 1; }

	EchoInfo	"${PackageLuit[Name]}> Configure"
	./configure $XORG_CONFIG 1> /dev/null || { EchoTest KO ${PackageLuit[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLuit[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLuit[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLuit[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLuit[Name]} && PressAnyKeyToContinue; return 1; };
}
