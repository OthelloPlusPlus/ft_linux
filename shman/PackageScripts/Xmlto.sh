#!/bin/bash

if [ ! -z "${PackageXmlto[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Xmlto								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXmlto;
# Manual
PackageXmlto[Source]="https://pagure.io/xmlto/archive/0.0.29/xmlto-0.0.29.tar.gz";
PackageXmlto[MD5]="556f2642cdcd005749bd4c08bc621c37";
# Automated unless edgecase
PackageXmlto[Name]="";
PackageXmlto[Version]="";
PackageXmlto[Extension]="";
if [[ -n "${PackageXmlto[Source]}" ]]; then
	filename="${PackageXmlto[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageXmlto[Name]}" ]] && PackageXmlto[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageXmlto[Version]}" ]] && PackageXmlto[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageXmlto[Extension]}" ]] && PackageXmlto[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageXmlto[Package]="${PackageXmlto[Name]}-${PackageXmlto[Version]}";

PackageXmlto[Programs]="xmlif xmlto";
PackageXmlto[Libraries]="";
PackageXmlto[Python]="";

InstallXmlto()
{
	# Check Installation
	CheckXmlto && return $?;

	# Check Dependencies
	EchoInfo	"${PackageXmlto[Name]}> Checking dependencies..."
	Required=(DocbookXml DocbookXslNons LibXslt)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageXmlto[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageXmlto[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Fop Links Lynx)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageXmlto[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageXmlto[Name]}> Building package..."
	_ExtractPackageXmlto || return $?;
	_BuildXmlto;
	return $?
}

CheckXmlto()
{
	CheckInstallation 	"${PackageXmlto[Programs]}"\
						"${PackageXmlto[Libraries]}"\
						"${PackageXmlto[Python]}" 1> /dev/null;
	return $?;
}

CheckXmltoVerbose()
{
	CheckInstallationVerbose	"${PackageXmlto[Programs]}"\
								"${PackageXmlto[Libraries]}"\
								"${PackageXmlto[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageXmlto()
{
	DownloadPackage	"${PackageXmlto[Source]}"	"${SHMAN_PDIR}"	"${PackageXmlto[Package]}${PackageXmlto[Extension]}"	"${PackageXmlto[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageXmlto[Package]}"	"${PackageXmlto[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildXmlto()
{
	if ! cd "${SHMAN_PDIR}${PackageXmlto[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageXmlto[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageXmlto[Name]}> Configure"
	autoreconf -fiv
	LINKS="/usr/bin/links" ./configure --prefix=/usr \
		1> /dev/null || { EchoTest KO ${PackageXmlto[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXmlto[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageXmlto[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXmlto[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageXmlto[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXmlto[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageXmlto[Name]} && PressAnyKeyToContinue; return 1; };
}
