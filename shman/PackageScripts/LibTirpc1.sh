#!/bin/bash

if [ ! -z "${PackageLibTirpc1[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibTirpc1								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibTirpc1;
# Manual
PackageLibTirpc1[Source]="https://downloads.sourceforge.net/libtirpc/libtirpc-1.3.6.tar.bz2";
PackageLibTirpc1[MD5]="8de9e6af16c4bc65ba40d0924745f5b7";
# Automated unless edgecase
PackageLibTirpc1[Name]="";
PackageLibTirpc1[Version]="";
PackageLibTirpc1[Extension]="";
if [[ -n "${PackageLibTirpc1[Source]}" ]]; then
	filename="${PackageLibTirpc1[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibTirpc1[Name]}" ]] && PackageLibTirpc1[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibTirpc1[Version]}" ]] && PackageLibTirpc1[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibTirpc1[Extension]}" ]] && PackageLibTirpc1[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibTirpc1[Package]="${PackageLibTirpc1[Name]}-${PackageLibTirpc1[Version]}";

PackageLibTirpc1[Programs]="";
PackageLibTirpc1[Libraries]="libtirpc.so";
PackageLibTirpc1[Python]="";

InstallLibTirpc1()
{
	# Check Installation
	CheckLibTirpc1 && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibTirpc1[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageLibTirpc1[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageLibTirpc1[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(MITKerberos)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageLibTirpc1[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibTirpc1[Name]}> Building package..."
	_ExtractPackageLibTirpc1 || return $?;
	_BuildLibTirpc1;
	return $?
}

CheckLibTirpc1()
{
	CheckInstallation 	"${PackageLibTirpc1[Programs]}"\
						"${PackageLibTirpc1[Libraries]}"\
						"${PackageLibTirpc1[Python]}" 1> /dev/null;
	return $?;
}

CheckLibTirpc1Verbose()
{
	CheckInstallationVerbose	"${PackageLibTirpc1[Programs]}"\
								"${PackageLibTirpc1[Libraries]}"\
								"${PackageLibTirpc1[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibTirpc1()
{
	DownloadPackage	"${PackageLibTirpc1[Source]}"	"${SHMAN_PDIR}"	"${PackageLibTirpc1[Package]}${PackageLibTirpc1[Extension]}"	"${PackageLibTirpc1[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibTirpc1[Package]}"	"${PackageLibTirpc1[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibTirpc1()
{
	if ! cd "${SHMAN_PDIR}${PackageLibTirpc1[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibTirpc1[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibTirpc1[Package]}/build \
	# 				|| { EchoError "${PackageLibTirpc1[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibTirpc1[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibTirpc1[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--disable-static \
				--disable-gssapi \
				1> /dev/null || { EchoTest KO ${PackageLibTirpc1[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibTirpc1[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibTirpc1[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibTirpc1[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibTirpc1[Name]} && PressAnyKeyToContinue; return 1; };
}
