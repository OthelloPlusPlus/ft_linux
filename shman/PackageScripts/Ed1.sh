#!/bin/bash

if [ ! -z "${PackageEd1[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Ed1								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageEd1;
# Manual
PackageEd1[Source]="https://ftp.gnu.org/gnu/ed/ed-1.21.tar.lz";
PackageEd1[MD5]="a68c643733b7123ddad15f7395cb8c61";
# Automated unless edgecase
PackageEd1[Name]="ed";
PackageEd1[Version]="1.21";
PackageEd1[Extension]=".tar.lz";
if [[ -n "${PackageEd1[Source]}" ]]; then
	filename="${PackageEd1[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageEd1[Name]}" ]] && PackageEd1[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageEd1[Version]}" ]] && PackageEd1[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageEd1[Extension]}" ]] && PackageEd1[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageEd1[Package]="${PackageEd1[Name]}-${PackageEd1[Version]}";

PackageEd1[Programs]="ed red";
PackageEd1[Libraries]="";
PackageEd1[Python]="";

InstallEd1()
{
	# Check Installation
	CheckEd1 && return $?;

	# Check Dependencies
	EchoInfo	"${PackageEd1[Name]}> Checking dependencies..."
	Required=(LibArchive)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageEd1[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageEd1[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageEd1[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageEd1[Name]}> Building package..."
	_ExtractPackageEd1 || return $?;
	_BuildEd1;
	return $?
}

CheckEd1()
{
	CheckInstallation 	"${PackageEd1[Programs]}"\
						"${PackageEd1[Libraries]}"\
						"${PackageEd1[Python]}" 1> /dev/null;
	return $?;
}

CheckEd1Verbose()
{
	CheckInstallationVerbose	"${PackageEd1[Programs]}"\
								"${PackageEd1[Libraries]}"\
								"${PackageEd1[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageEd1()
{
	# DownloadPackage	"${PackageEd1[Source]}"	"${SHMAN_PDIR}"	"${PackageEd1[Package]}${PackageEd1[Extension]}"	"${PackageEd1[MD5]}" || return $?;
	# ReExtractPackage	"${SHMAN_PDIR}"	"${PackageEd1[Package]}"	"${PackageEd1[Extension]}" || return $?;
	pushd "${SHMAN_PDIR}";
	wget ${PackageEd1[Source]}
	bsdtar -xf ed-1.21.tar.lz
	popd

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildEd1()
{
	if ! cd "${SHMAN_PDIR}${PackageEd1[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageEd1[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageEd1[Package]}/build \
	# 				|| { EchoError "${PackageEd1[Name]}> Failed to enter ${SHMAN_PDIR}${PackageEd1[Package]}/build"; return 1; }

	EchoInfo	"${PackageEd1[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageEd1[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageEd1[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageEd1[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageEd1[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageEd1[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageEd1[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageEd1[Name]} && PressAnyKeyToContinue; return 1; };
}
