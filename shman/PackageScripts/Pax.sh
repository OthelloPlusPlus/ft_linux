#!/bin/bash

if [ ! -z "${PackagePax[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Pax								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePax;
# Manual
PackagePax[Source]="http://www.mirbsd.org/MirOS/dist/mir/cpio/paxmirabilis-20240817.tgz";
PackagePax[MD5]="9a723154a4201a0892b7ff815b6753b5";
# Automated unless edgecase
PackagePax[Name]="paxmirabilis";
PackagePax[Version]="20240817";
PackagePax[Extension]=".tgz";
if [[ -n "${PackagePax[Source]}" ]]; then
	filename="${PackagePax[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackagePax[Name]}" ]] && PackagePax[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackagePax[Version]}" ]] && PackagePax[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackagePax[Extension]}" ]] && PackagePax[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackagePax[Package]="${PackagePax[Name]}-${PackagePax[Version]}";

PackagePax[Programs]="pax";
PackagePax[Libraries]="";
PackagePax[Python]="";

InstallPax()
{
	# Check Installation
	CheckPax && return $?;

	# Check Dependencies
	EchoInfo	"${PackagePax[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackagePax[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackagePax[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackagePax[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackagePax[Name]}> Building package..."
	_ExtractPackagePax || return $?;
	_BuildPax;
	return $?
}

CheckPax()
{
	CheckInstallation 	"${PackagePax[Programs]}"\
						"${PackagePax[Libraries]}"\
						"${PackagePax[Python]}" 1> /dev/null;
	return $?;
}

CheckPaxVerbose()
{
	CheckInstallationVerbose	"${PackagePax[Programs]}"\
								"${PackagePax[Libraries]}"\
								"${PackagePax[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackagePax()
{
	DownloadPackage	"${PackagePax[Source]}"	"${SHMAN_PDIR}"	"${PackagePax[Package]}${PackagePax[Extension]}"	"${PackagePax[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackagePax[Package]}"	"${PackagePax[Extension]}" || return $?;
	PackagePax[Package]="pax";

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildPax()
{
	if ! cd "${SHMAN_PDIR}${PackagePax[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackagePax[Package]}";
		return 1;
	fi

	EchoInfo	"${PackagePax[Name]}> bash Build.sh"
	bash Build.sh 1> /dev/null || { EchoTest KO ${PackagePax[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePax[Name]}> make install"
	install -v pax /usr/bin 1> /dev/null && \
	install -v -m644 pax.1 /usr/share/man/man1 1> /dev/null || \
		{ EchoTest KO ${PackagePax[Name]} && PressAnyKeyToContinue; return 1; };
}
