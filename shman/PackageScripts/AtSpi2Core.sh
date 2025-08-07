#!/bin/bash

if [ ! -z "${PackageAtSpi2Core[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									AtSpi2Core								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageAtSpi2Core;
PackageAtSpi2Core[Source]="https://download.gnome.org/sources/at-spi2-core/2.54/at-spi2-core-2.54.1.tar.xz";
PackageAtSpi2Core[MD5]="a05ad6cf4a49b19964cc5eec363d2310";
PackageAtSpi2Core[Name]="at-spi2-core";
PackageAtSpi2Core[Version]="2.54.1";
PackageAtSpi2Core[Package]="${PackageAtSpi2Core[Name]}-${PackageAtSpi2Core[Version]}";
PackageAtSpi2Core[Extension]=".tar.xz";

PackageAtSpi2Core[Programs]="";
# adjusted for lib64
PackageAtSpi2Core[Libraries]="libatk-1.0.so libatk-bridge-2.0.so libatspi.so /usr/lib64/gtk-2.0/modules/libatk-bridge.so";
PackageAtSpi2Core[Python]="";

InstallAtSpi2Core()
{
	# Check Installation
	CheckAtSpi2Core && return $?;

	# Check Dependencies
	Dependencies=(Dbus GLib XorgLibraries)
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh";
		fi
	done
	
	# Install Package
	_BuildAtSpi2Core;
	return $?
}

CheckAtSpi2Core()
{
	CheckInstallation 	"${PackageAtSpi2Core[Programs]}"\
						"${PackageAtSpi2Core[Libraries]}"\
						"${PackageAtSpi2Core[Python]}" 1> /dev/null;
	return $?;
}

CheckAtSpi2CoreVerbose()
{
	CheckInstallationVerbose	"${PackageAtSpi2Core[Programs]}"\
								"${PackageAtSpi2Core[Libraries]}"\
								"${PackageAtSpi2Core[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildAtSpi2Core()
{
	EchoInfo	"Package ${PackageAtSpi2Core[Name]}"

	DownloadPackage	"${PackageAtSpi2Core[Source]}"	"${SHMAN_PDIR}"	"${PackageAtSpi2Core[Package]}${PackageAtSpi2Core[Extension]}"	"${PackageAtSpi2Core[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageAtSpi2Core[Package]}"	"${PackageAtSpi2Core[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageAtSpi2Core[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageAtSpi2Core[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageAtSpi2Core[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageAtSpi2Core[Package]}/build";

	EchoInfo	"${PackageAtSpi2Core[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D systemd_user_dir=/tmp \
				1> /dev/null || { EchoTest KO ${PackageAtSpi2Core[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAtSpi2Core[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageAtSpi2Core[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageAtSpi2Core[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageAtSpi2Core[Name]} && PressAnyKeyToContinue; return 1; };

	rm /tmp/at-spi-dbus-bus.service

	# EchoInfo	"${PackageAtSpi2Core[Name]}> dbus-run-session ninja test"
	# dbus-run-session ninja test 1> /dev/null || { EchoTest KO ${PackageAtSpi2Core[Name]} && PressAnyKeyToContinue; return 1; };
}
