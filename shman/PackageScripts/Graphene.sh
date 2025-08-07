#!/bin/bash

if [ ! -z "${PackageGraphene[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Graphene								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGraphene;
PackageGraphene[Source]="https://download.gnome.org/sources/graphene/1.10/graphene-1.10.8.tar.xz";
PackageGraphene[MD5]="169e3c507b5a5c26e9af492412070b81";
PackageGraphene[Name]="graphene";
PackageGraphene[Version]="1.10.8";
PackageGraphene[Package]="${PackageGraphene[Name]}-${PackageGraphene[Version]}";
PackageGraphene[Extension]=".tar.xz";

PackageGraphene[Programs]="";
PackageGraphene[Libraries]="libgraphene-1.0.so";
PackageGraphene[Python]="";

InstallGraphene()
{
	# Check Installation
	CheckGraphene && return $?;

	# Check Dependencies
	Required=(GLib)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"Package ${PackageGraphene[Name]}"
	_ExtractPackageGraphene || return $?;
	_BuildGraphene;
	return $?
}

CheckGraphene()
{
	CheckInstallation 	"${PackageGraphene[Programs]}"\
						"${PackageGraphene[Libraries]}"\
						"${PackageGraphene[Python]}" 1> /dev/null;
	return $?;
}

CheckGrapheneVerbose()
{
	CheckInstallationVerbose	"${PackageGraphene[Programs]}"\
								"${PackageGraphene[Libraries]}"\
								"${PackageGraphene[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGraphene()
{
	DownloadPackage	"${PackageGraphene[Source]}"	"${SHMAN_PDIR}"	"${PackageGraphene[Package]}${PackageGraphene[Extension]}"	"${PackageGraphene[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGraphene[Package]}"	"${PackageGraphene[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildGraphene()
{
	if ! cd "${SHMAN_PDIR}${PackageGraphene[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGraphene[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageGraphene[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageGraphene[Package]}/build";

	EchoInfo	"${PackageGraphene[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageGraphene[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGraphene[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGraphene[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGraphene[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageGraphene[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageGraphene[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGraphene[Name]} && PressAnyKeyToContinue; return 1; };
}
