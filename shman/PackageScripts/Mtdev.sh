#!/bin/bash

if [ ! -z "${PackageMtdev[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Mtdev								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMtdev;
# Manual
PackageMtdev[Source]="https://bitmath.org/code/mtdev/mtdev-1.1.7.tar.bz2";
PackageMtdev[MD5]="483ed7fdf7c1e7b7375c05a62848cce7";
# Automated unless edgecase
PackageMtdev[Name]="";
PackageMtdev[Version]="";
PackageMtdev[Extension]="";
if [[ -n "${PackageMtdev[Source]}" ]]; then
	filename="${PackageMtdev[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageMtdev[Name]}" ]] && PackageMtdev[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageMtdev[Version]}" ]] && PackageMtdev[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageMtdev[Extension]}" ]] && PackageMtdev[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageMtdev[Package]="${PackageMtdev[Name]}-${PackageMtdev[Version]}";

PackageMtdev[Programs]="mtdev-test";
PackageMtdev[Libraries]="libmtdev.so";
PackageMtdev[Python]="";

InstallMtdev()
{
	# Check Installation
	CheckMtdev && return $?;

	# Check Dependencies
	EchoInfo	"${PackageMtdev[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageMtdev[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageMtdev[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageMtdev[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageMtdev[Name]}> Building package..."
	_ExtractPackageMtdev || return $?;
	_BuildMtdev;
	return $?
}

CheckMtdev()
{
	CheckInstallation 	"${PackageMtdev[Programs]}"\
						"${PackageMtdev[Libraries]}"\
						"${PackageMtdev[Python]}" 1> /dev/null;
	return $?;
}

CheckMtdevVerbose()
{
	CheckInstallationVerbose	"${PackageMtdev[Programs]}"\
								"${PackageMtdev[Libraries]}"\
								"${PackageMtdev[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageMtdev()
{
	DownloadPackage	"${PackageMtdev[Source]}"	"${SHMAN_PDIR}"	"${PackageMtdev[Package]}${PackageMtdev[Extension]}"	"${PackageMtdev[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageMtdev[Package]}"	"${PackageMtdev[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildMtdev()
{
	if ! cd "${SHMAN_PDIR}${PackageMtdev[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageMtdev[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageMtdev[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageMtdev[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMtdev[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageMtdev[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMtdev[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageMtdev[Name]} && PressAnyKeyToContinue; return 1; };
}
