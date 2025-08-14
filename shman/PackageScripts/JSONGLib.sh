#!/bin/bash

if [ ! -z "${PackageJSONGLib[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									JSONGLib								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageJSONGLib;
PackageJSONGLib[Source]="https://download.gnome.org/sources/json-glib/1.10/json-glib-1.10.6.tar.xz";
PackageJSONGLib[MD5]="d4bf13ddd1e6d607d039d39286f9e3d0";
PackageJSONGLib[Name]="json-glib";
PackageJSONGLib[Version]="1.10.6";
PackageJSONGLib[Package]="${PackageJSONGLib[Name]}-${PackageJSONGLib[Version]}";
PackageJSONGLib[Extension]=".tar.xz";

PackageJSONGLib[Programs]="json-glib-format json-glib-validate";
PackageJSONGLib[Libraries]="libjson-glib-1.0.so";
PackageJSONGLib[Python]="";

InstallJSONGLib()
{
	# Check Installation
	CheckJSONGLib && return $?;

	# Check Dependencies
	Required=(GLib)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(GTKDoc)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"Package ${PackageJSONGLib[Name]}"
	_ExtractPackageJSONGLib || return $?;
	_BuildJSONGLib;
	return $?
}

CheckJSONGLib()
{
	CheckInstallation 	"${PackageJSONGLib[Programs]}"\
						"${PackageJSONGLib[Libraries]}"\
						"${PackageJSONGLib[Python]}" 1> /dev/null;
	return $?;
}

CheckJSONGLibVerbose()
{
	CheckInstallationVerbose	"${PackageJSONGLib[Programs]}"\
								"${PackageJSONGLib[Libraries]}"\
								"${PackageJSONGLib[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageJSONGLib()
{
	DownloadPackage	"${PackageJSONGLib[Source]}"	"${SHMAN_PDIR}"	"${PackageJSONGLib[Package]}${PackageJSONGLib[Extension]}"	"${PackageJSONGLib[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageJSONGLib[Package]}"	"${PackageJSONGLib[Extension]}" || return $?;

	return $?;
}

_BuildJSONGLib()
{
	if ! cd "${SHMAN_PDIR}${PackageJSONGLib[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageJSONGLib[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageJSONGLib[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageJSONGLib[Package]}/build";

	EchoInfo	"${PackageJSONGLib[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageJSONGLib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageJSONGLib[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageJSONGLib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageJSONGLib[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageJSONGLib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageJSONGLib[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageJSONGLib[Name]} && PressAnyKeyToContinue; return 1; };
}
