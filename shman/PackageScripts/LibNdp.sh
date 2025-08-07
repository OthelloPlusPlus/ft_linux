#!/bin/bash

if [ ! -z "${PackageLibNdp[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibNdp								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibNdp;
# Manual
PackageLibNdp[Source]="http://libndp.org/files/libndp-1.9.tar.gz";
PackageLibNdp[MD5]="9d486750569e7025e5d0afdcc509b93c";
# Automated unless edgecase
PackageLibNdp[Name]="";
PackageLibNdp[Version]="";
PackageLibNdp[Extension]="";
if [[ -n "${PackageLibNdp[Source]}" ]]; then
	filename="${PackageLibNdp[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibNdp[Name]}" ]] && PackageLibNdp[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibNdp[Version]}" ]] && PackageLibNdp[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibNdp[Extension]}" ]] && PackageLibNdp[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibNdp[Package]="${PackageLibNdp[Name]}-${PackageLibNdp[Version]}";

PackageLibNdp[Programs]="ndptool";
PackageLibNdp[Libraries]="libndp.so";
PackageLibNdp[Python]="";

InstallLibNdp()
{
	# Check Installation
	CheckLibNdp && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibNdp[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibNdp[Name]}> Building package..."
	_ExtractPackageLibNdp || return $?;
	_BuildLibNdp;
	return $?
}

CheckLibNdp()
{
	CheckInstallation 	"${PackageLibNdp[Programs]}"\
						"${PackageLibNdp[Libraries]}"\
						"${PackageLibNdp[Python]}" 1> /dev/null;
	return $?;
}

CheckLibNdpVerbose()
{
	CheckInstallationVerbose	"${PackageLibNdp[Programs]}"\
								"${PackageLibNdp[Libraries]}"\
								"${PackageLibNdp[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibNdp()
{
	DownloadPackage	"${PackageLibNdp[Source]}"	"${SHMAN_PDIR}"	"${PackageLibNdp[Package]}${PackageLibNdp[Extension]}"	"${PackageLibNdp[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibNdp[Package]}"	"${PackageLibNdp[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibNdp()
{
	if ! cd "${SHMAN_PDIR}${PackageLibNdp[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibNdp[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibNdp[Package]}/build \
	# 				|| { EchoError "${PackageLibNdp[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibNdp[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibNdp[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--localstatedir=/var \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageLibNdp[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibNdp[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibNdp[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibNdp[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibNdp[Name]} && PressAnyKeyToContinue; return 1; };
}
