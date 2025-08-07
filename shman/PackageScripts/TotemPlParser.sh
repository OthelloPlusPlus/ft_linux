#!/bin/bash

if [ ! -z "${PackageTotemPlParser[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#								 TotemPlParser								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageTotemPlParser;
PackageTotemPlParser[Source]="https://download.gnome.org/sources/totem-pl-parser/3.26/totem-pl-parser-3.26.6.tar.xz";
PackageTotemPlParser[MD5]="69dc2cf0e61e6df71ed45156b24b14da";
PackageTotemPlParser[Name]="totem-pl-parser";
PackageTotemPlParser[Version]="3.26.6";
PackageTotemPlParser[Package]="${PackageTotemPlParser[Name]}-${PackageTotemPlParser[Version]}";
PackageTotemPlParser[Extension]=".tar.xz";

PackageTotemPlParser[Programs]="";
PackageTotemPlParser[Libraries]="libtotem-plparser-mini.so libtotem-plparser.so";
PackageTotemPlParser[Python]="";

InstallTotemPlParser()
{
	# Check Installation
	CheckTotemPlParser && return $?;

	# Check Dependencies
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GLib LibArchive LibGcrypt)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(CMake GTKDoc Gvfs)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"Package ${PackageTotemPlParser[Name]}"
	_ExtractPackageTotemPlParser || return $?;
	_BuildTotemPlParser;
	return $?
}

CheckTotemPlParser()
{
	CheckInstallation 	"${PackageTotemPlParser[Programs]}"\
						"${PackageTotemPlParser[Libraries]}"\
						"${PackageTotemPlParser[Python]}" 1> /dev/null;
	return $?;
}

CheckTotemPlParserVerbose()
{
	CheckInstallationVerbose	"${PackageTotemPlParser[Programs]}"\
								"${PackageTotemPlParser[Libraries]}"\
								"${PackageTotemPlParser[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageTotemPlParser()
{
	DownloadPackage	"${PackageTotemPlParser[Source]}"	"${SHMAN_PDIR}"	"${PackageTotemPlParser[Package]}${PackageTotemPlParser[Extension]}"	"${PackageTotemPlParser[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageTotemPlParser[Package]}"	"${PackageTotemPlParser[Extension]}" || return $?;

	return $?;
}

_BuildTotemPlParser()
{
	if ! cd "${SHMAN_PDIR}${PackageTotemPlParser[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageTotemPlParser[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageTotemPlParser[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageTotemPlParser[Package]}/build";

	EchoInfo	"${PackageTotemPlParser[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageTotemPlParser[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTotemPlParser[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageTotemPlParser[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTotemPlParser[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO "${PackageTotemPlParser[Name]} (parser is known to fail)" && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTotemPlParser[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageTotemPlParser[Name]} && PressAnyKeyToContinue; return 1; };
}
