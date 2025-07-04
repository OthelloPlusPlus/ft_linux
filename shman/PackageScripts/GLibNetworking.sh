#!/bin/bash

if [ ! -z "${PackageGLibNetworking[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#								GLibNetworking								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGLibNetworking;
PackageGLibNetworking[Source]="https://download.gnome.org/sources/glib-networking/2.80/glib-networking-2.80.1.tar.xz";
PackageGLibNetworking[MD5]="405e6c058723217a1307ba8415615f9d";
PackageGLibNetworking[Name]="glib-networking";
PackageGLibNetworking[Version]="2.80.1";
PackageGLibNetworking[Package]="${PackageGLibNetworking[Name]}-${PackageGLibNetworking[Version]}";
PackageGLibNetworking[Extension]=".tar.xz";

PackageGLibNetworking[Programs]="";
PackageGLibNetworking[Libraries]="libgiognomeproxy.so libgiognutls.so";
PackageGLibNetworking[Python]="";

InstallGLibNetworking()
{
	# Check Installation
	CheckGLibNetworking && return $?;

	# Check Dependencies
	Required=(GLib GnuTLS)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GSettingsDesktopSchemas MakeCa)
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
		echo "Checking $Dependency $?"
	done

	Optional=(LibProxy)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"Package ${PackageGLibNetworking[Name]}"
	_ExtractPackageGLibNetworking || return $?;
	_BuildGLibNetworking;
	return $?
}

CheckGLibNetworking()
{
	CheckInstallation 	"${PackageGLibNetworking[Programs]}"\
						"${PackageGLibNetworking[Libraries]}"\
						"${PackageGLibNetworking[Python]}" 1> /dev/null;
	return $?;
}

CheckGLibNetworkingVerbose()
{
	CheckInstallationVerbose	"${PackageGLibNetworking[Programs]}"\
								"${PackageGLibNetworking[Libraries]}"\
								"${PackageGLibNetworking[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGLibNetworking()
{
	DownloadPackage	"${PackageGLibNetworking[Source]}"	"${SHMAN_PDIR}"	"${PackageGLibNetworking[Package]}${PackageGLibNetworking[Extension]}"	"${PackageGLibNetworking[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGLibNetworking[Package]}"	"${PackageGLibNetworking[Extension]}" || return $?;

	return $?;
}

_BuildGLibNetworking()
{
	if ! cd "${SHMAN_PDIR}${PackageGLibNetworking[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGLibNetworking[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageGLibNetworking[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageGLibNetworking[Package]}/build";

	EchoInfo	"${PackageGLibNetworking[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D libproxy=disabled \
				.. \
				1> /dev/null || { EchoTest KO ${PackageGLibNetworking[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGLibNetworking[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGLibNetworking[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGLibNetworking[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageGLibNetworking[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageGLibNetworking[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGLibNetworking[Name]} && PressAnyKeyToContinue; return 1; };
}
