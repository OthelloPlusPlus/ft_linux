#!/bin/bash

if [ ! -z "${PackageLSBTools0[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LSBTools0								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLSBTools0;
# Manual
PackageLSBTools0[Source]="https://github.com/lfs-book/LSB-Tools/releases/download/v0.12/LSB-Tools-0.12.tar.gz";
PackageLSBTools0[MD5]="1e6ef8cdfddb55035a6c36757e6313f9";
# Automated unless edgecase
PackageLSBTools0[Name]="";
PackageLSBTools0[Version]="";
PackageLSBTools0[Extension]="";
if [[ -n "${PackageLSBTools0[Source]}" ]]; then
	filename="${PackageLSBTools0[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLSBTools0[Name]}" ]] && PackageLSBTools0[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLSBTools0[Version]}" ]] && PackageLSBTools0[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLSBTools0[Extension]}" ]] && PackageLSBTools0[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLSBTools0[Package]="${PackageLSBTools0[Name]}-${PackageLSBTools0[Version]}";

PackageLSBTools0[Programs]="lsb_release install_initd remove_initd";
PackageLSBTools0[Libraries]="";
PackageLSBTools0[Python]="";

InstallLSBTools0()
{
	# Check Installation
	CheckLSBTools0 && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLSBTools0[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageLSBTools0[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageLSBTools0[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageLSBTools0[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLSBTools0[Name]}> Building package..."
	_ExtractPackageLSBTools0 || return $?;
	_BuildLSBTools0;
	return $?
}

CheckLSBTools0()
{
	CheckInstallation 	"${PackageLSBTools0[Programs]}"\
						"${PackageLSBTools0[Libraries]}"\
						"${PackageLSBTools0[Python]}" 1> /dev/null;
	return $?;
}

CheckLSBTools0Verbose()
{
	CheckInstallationVerbose	"${PackageLSBTools0[Programs]}"\
								"${PackageLSBTools0[Libraries]}"\
								"${PackageLSBTools0[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLSBTools0()
{
	DownloadPackage	"${PackageLSBTools0[Source]}"	"${SHMAN_PDIR}"	"${PackageLSBTools0[Package]}${PackageLSBTools0[Extension]}"	"${PackageLSBTools0[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLSBTools0[Package]}"	"${PackageLSBTools0[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLSBTools0()
{
	if ! cd "${SHMAN_PDIR}${PackageLSBTools0[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLSBTools0[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLSBTools0[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLSBTools0[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLSBTools0[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLSBTools0[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLSBTools0[Name]}> rm /usr/sbin/lsbinstall"
	rm /usr/sbin/lsbinstall
}
