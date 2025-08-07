#!/bin/bash

if [ ! -z "${PackageLibDaemon[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibDaemon								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibDaemon;
# Manual
PackageLibDaemon[Source]="https://0pointer.de/lennart/projects/libdaemon/libdaemon-0.14.tar.gz";
PackageLibDaemon[MD5]="509dc27107c21bcd9fbf2f95f5669563";
# Automated unless edgecase
PackageLibDaemon[Name]="";
PackageLibDaemon[Version]="";
PackageLibDaemon[Extension]="";
if [[ -n "${PackageLibDaemon[Source]}" ]]; then
	filename="${PackageLibDaemon[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibDaemon[Name]}" ]] && PackageLibDaemon[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibDaemon[Version]}" ]] && PackageLibDaemon[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibDaemon[Extension]}" ]] && PackageLibDaemon[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibDaemon[Package]="${PackageLibDaemon[Name]}-${PackageLibDaemon[Version]}";

PackageLibDaemon[Programs]="";
PackageLibDaemon[Libraries]="libdaemon.so";
PackageLibDaemon[Python]="";

InstallLibDaemon()
{
	# Check Installation
	CheckLibDaemon && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibDaemon[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Doxygen Lynx)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibDaemon[Name]}> Building package..."
	_ExtractPackageLibDaemon || return $?;
	_BuildLibDaemon;
	return $?
}

CheckLibDaemon()
{
	CheckInstallation 	"${PackageLibDaemon[Programs]}"\
						"${PackageLibDaemon[Libraries]}"\
						"${PackageLibDaemon[Python]}" 1> /dev/null;
	return $?;
}

CheckLibDaemonVerbose()
{
	CheckInstallationVerbose	"${PackageLibDaemon[Programs]}"\
								"${PackageLibDaemon[Libraries]}"\
								"${PackageLibDaemon[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibDaemon()
{
	DownloadPackage	"${PackageLibDaemon[Source]}"	"${SHMAN_PDIR}"	"${PackageLibDaemon[Package]}${PackageLibDaemon[Extension]}"	"${PackageLibDaemon[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibDaemon[Package]}"	"${PackageLibDaemon[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibDaemon()
{
	if ! cd "${SHMAN_PDIR}${PackageLibDaemon[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibDaemon[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibDaemon[Package]}/build \
	# 				|| { EchoError "${PackageLibDaemon[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibDaemon[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibDaemon[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageLibDaemon[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibDaemon[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibDaemon[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibDaemon[Name]}> make install"
	make docdir=/usr/share/doc/libdaemon-0.14 install 1> /dev/null || { EchoTest KO ${PackageLibDaemon[Name]} && PressAnyKeyToContinue; return 1; };
}
