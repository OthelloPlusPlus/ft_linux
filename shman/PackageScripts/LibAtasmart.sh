#!/bin/bash

if [ ! -z "${PackageLibAtasmart[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibAtasmart								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibAtasmart;
# Manual
PackageLibAtasmart[Source]="https://0pointer.de/public/libatasmart-0.19.tar.xz";
PackageLibAtasmart[MD5]="53afe2b155c36f658e121fe6def33e77";
# Automated unless edgecase
PackageLibAtasmart[Name]="";
PackageLibAtasmart[Version]="0.19";
PackageLibAtasmart[Extension]="";
if [[ -n "${PackageLibAtasmart[Source]}" ]]; then
	filename="${PackageLibAtasmart[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibAtasmart[Name]}" ]] && PackageLibAtasmart[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibAtasmart[Version]}" ]] && PackageLibAtasmart[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibAtasmart[Extension]}" ]] && PackageLibAtasmart[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibAtasmart[Package]="${PackageLibAtasmart[Name]}-${PackageLibAtasmart[Version]}";

PackageLibAtasmart[Programs]="skdump sktest";
PackageLibAtasmart[Libraries]="libatasmart.so";
PackageLibAtasmart[Python]="";

InstallLibAtasmart()
{
	# Check Installation
	CheckLibAtasmart && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibAtasmart[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageLibAtasmart[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageLibAtasmart[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageLibAtasmart[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibAtasmart[Name]}> Building package..."
	_ExtractPackageLibAtasmart || return $?;
	_BuildLibAtasmart || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageLibAtasmart[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckLibAtasmart()
{
	CheckInstallation 	"${PackageLibAtasmart[Programs]}"\
						"${PackageLibAtasmart[Libraries]}"\
						"${PackageLibAtasmart[Python]}" 1> /dev/null;
	return $?;
}

CheckLibAtasmartVerbose()
{
	CheckInstallationVerbose	"${PackageLibAtasmart[Programs]}"\
								"${PackageLibAtasmart[Libraries]}"\
								"${PackageLibAtasmart[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibAtasmart()
{
	DownloadPackage	"${PackageLibAtasmart[Source]}"	"${SHMAN_PDIR}"	"${PackageLibAtasmart[Package]}${PackageLibAtasmart[Extension]}"	"${PackageLibAtasmart[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibAtasmart[Package]}"	"${PackageLibAtasmart[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibAtasmart()
{
	if ! cd "${SHMAN_PDIR}${PackageLibAtasmart[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibAtasmart[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibAtasmart[Package]}/build \
	# 				|| { EchoError "${PackageLibAtasmart[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibAtasmart[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibAtasmart[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageLibAtasmart[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibAtasmart[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibAtasmart[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibAtasmart[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibAtasmart[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibAtasmart[Name]}> make install"
	make docdir=/usr/share/doc/libatasmart-0.19 install 1> /dev/null || { EchoTest KO ${PackageLibAtasmart[Name]} && PressAnyKeyToContinue; return 1; };
}
