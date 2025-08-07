#!/bin/bash

if [ ! -z "${PackageLibXdmcp[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibXdmcp								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibXdmcp;
# Manual
PackageLibXdmcp[Source]="https://www.x.org/pub/individual/lib/libXdmcp-1.1.5.tar.xz";
PackageLibXdmcp[MD5]="ce0af51de211e4c99a111e64ae1df290";
# Automated unless edgecase
PackageLibXdmcp[Name]="";
PackageLibXdmcp[Version]="";
PackageLibXdmcp[Extension]="";
if [[ -n "${PackageLibXdmcp[Source]}" ]]; then
	filename="${PackageLibXdmcp[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibXdmcp[Name]}" ]] && PackageLibXdmcp[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibXdmcp[Version]}" ]] && PackageLibXdmcp[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibXdmcp[Extension]}" ]] && PackageLibXdmcp[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibXdmcp[Package]="${PackageLibXdmcp[Name]}-${PackageLibXdmcp[Version]}";

PackageLibXdmcp[Programs]="";
PackageLibXdmcp[Libraries]="libXdmcp.so";
PackageLibXdmcp[Python]="";

InstallLibXdmcp()
{
	# Check Installation
	CheckLibXdmcp && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibXdmcp[Name]}> Checking dependencies..."
	Required=(Xorgproto)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageLibXdmcp[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageLibXdmcp[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Xmlto Fop LibXslt)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageLibXdmcp[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibXdmcp[Name]}> Building package..."
	_ExtractPackageLibXdmcp || return $?;
	_BuildLibXdmcp;
	return $?
}

CheckLibXdmcp()
{
	CheckInstallation 	"${PackageLibXdmcp[Programs]}"\
						"${PackageLibXdmcp[Libraries]}"\
						"${PackageLibXdmcp[Python]}" 1> /dev/null;
	return $?;
}

CheckLibXdmcpVerbose()
{
	CheckInstallationVerbose	"${PackageLibXdmcp[Programs]}"\
								"${PackageLibXdmcp[Libraries]}"\
								"${PackageLibXdmcp[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibXdmcp()
{
	DownloadPackage	"${PackageLibXdmcp[Source]}"	"${SHMAN_PDIR}"	"${PackageLibXdmcp[Package]}${PackageLibXdmcp[Extension]}"	"${PackageLibXdmcp[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibXdmcp[Package]}"	"${PackageLibXdmcp[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibXdmcp()
{
	if ! cd "${SHMAN_PDIR}${PackageLibXdmcp[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibXdmcp[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibXdmcp[Package]}/build \
	# 				|| { EchoError "${PackageLibXdmcp[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibXdmcp[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibXdmcp[Name]}> Configure"
	./configure $XORG_CONFIG \
				--docdir=/usr/share/doc/libXdmcp-1.1.5 \
				1> /dev/null || { EchoTest KO ${PackageLibXdmcp[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXdmcp[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibXdmcp[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXdmcp[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibXdmcp[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXdmcp[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibXdmcp[Name]} && PressAnyKeyToContinue; return 1; };
}
