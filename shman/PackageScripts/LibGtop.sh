#!/bin/bash

if [ ! -z "${PackageLibGtop[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibGtop								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibGtop;
# Manual
PackageLibGtop[Source]="https://download.gnome.org/sources/libgtop/2.41/libgtop-2.41.3.tar.xz";
PackageLibGtop[MD5]="465db9f4f695c298d9c48dcf7f32a9c0";
# Automated unless edgecase
PackageLibGtop[Name]="";
PackageLibGtop[Version]="";
PackageLibGtop[Extension]="";
if [[ -n "${PackageLibGtop[Source]}" ]]; then
	filename="${PackageLibGtop[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibGtop[Name]}" ]] && PackageLibGtop[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibGtop[Version]}" ]] && PackageLibGtop[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibGtop[Extension]}" ]] && PackageLibGtop[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibGtop[Package]="${PackageLibGtop[Name]}-${PackageLibGtop[Version]}";

# /usr/libexec/libgtop_*2: libgtop_daemon2 libgtop_server2
PackageLibGtop[Programs]="";
PackageLibGtop[Libraries]="libgtop-2.0.so";
PackageLibGtop[Python]="";

InstallLibGtop()
{
	# Check Installation
	CheckLibGtop && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibGtop[Name]}> Checking dependencies..."
	Required=(GLib XorgLibraries)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(GTKDoc)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibGtop[Name]}> Building package..."
	_ExtractPackageLibGtop || return $?;
	_BuildLibGtop;
	return $?
}

CheckLibGtop()
{
	CheckInstallation 	"${PackageLibGtop[Programs]}"\
						"${PackageLibGtop[Libraries]}"\
						"${PackageLibGtop[Python]}" 1> /dev/null;
	return $?;
}

CheckLibGtopVerbose()
{
	CheckInstallationVerbose	"${PackageLibGtop[Programs]}"\
								"${PackageLibGtop[Libraries]}"\
								"${PackageLibGtop[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibGtop()
{
	DownloadPackage	"${PackageLibGtop[Source]}"	"${SHMAN_PDIR}"	"${PackageLibGtop[Package]}${PackageLibGtop[Extension]}"	"${PackageLibGtop[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibGtop[Package]}"	"${PackageLibGtop[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibGtop()
{
	if ! cd "${SHMAN_PDIR}${PackageLibGtop[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibGtop[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibGtop[Name]}> Configure"
	./configure --prefix=/usr --disable-static 1> /dev/null || { EchoTest KO ${PackageLibGtop[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibGtop[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibGtop[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibGtop[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibGtop[Name]} && PressAnyKeyToContinue; return 1; };
}
