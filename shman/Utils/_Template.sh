#!/bin/bash

if [ ! -z "${PackageTemplate[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Template								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageTemplate;
# Manual
PackageTemplate[Source]="";
PackageTemplate[MD5]="";
# Automated unless edgecase
PackageTemplate[Name]="";
PackageTemplate[Version]="";
PackageTemplate[Extension]="";
if [[ -n "${PackageTemplate[Source]}" ]]; then
	filename="${PackageTemplate[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageTemplate[Name]}" ]] && PackageTemplate[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageTemplate[Version]}" ]] && PackageTemplate[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageTemplate[Extension]}" ]] && PackageTemplate[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageTemplate[Package]="${PackageTemplate[Name]}-${PackageTemplate[Version]}";

PackageTemplate[Programs]="";
PackageTemplate[Libraries]="";
PackageTemplate[Python]="";

InstallTemplate()
{
	# Check Installation
	CheckTemplate && return $?;

	# Check Dependencies
	EchoInfo	"${PackageTemplate[Name]}> Checking dependencies..."
	local Required=()
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageTemplate[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { EchoError "${PackageTemplate[Name]}--->${Dependency}"; PressAnyKeyToContinue; return $?; }
	done

	local Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageTemplate[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { EchoError "${PackageTemplate[Name]}-->${Dependency}"; PressAnyKeyToContinue; }
	done

	local Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageTemplate[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"|| EchoWarning "${PackageTemplate[Name]}->${Dependency}";
		fi
	done

	# Install Package
	EchoInfo	"${PackageTemplate[Name]}> Building package..."
	_ExtractPackageTemplate || return $?;
	_BuildTemplate || return $?;

	local RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageTemplate[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { EchoError "${PackageTemplate[Name]}=>${Dependency}"; PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckTemplate()
{
	CheckInstallation 	"${PackageTemplate[Programs]}"\
						"${PackageTemplate[Libraries]}"\
						"${PackageTemplate[Python]}" 1> /dev/null;
	return $?;
}

CheckTemplateVerbose()
{
	CheckInstallationVerbose	"${PackageTemplate[Programs]}"\
								"${PackageTemplate[Libraries]}"\
								"${PackageTemplate[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageTemplate()
{
	DownloadPackage	"${PackageTemplate[Source]}"	"${SHMAN_PDIR}"	"${PackageTemplate[Package]}${PackageTemplate[Extension]}"	"${PackageTemplate[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageTemplate[Package]}"	"${PackageTemplate[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildTemplate()
{
	if ! cd "${SHMAN_PDIR}${PackageTemplate[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageTemplate[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageTemplate[Package]}/build \
	# 				|| { EchoError "${PackageTemplate[Name]}> Failed to enter ${SHMAN_PDIR}${PackageTemplate[Package]}/build"; return 1; }

	EchoInfo	"${PackageTemplate[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageTemplate[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTemplate[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageTemplate[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTemplate[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageTemplate[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTemplate[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageTemplate[Name]} && PressAnyKeyToContinue; return 1; };
}
