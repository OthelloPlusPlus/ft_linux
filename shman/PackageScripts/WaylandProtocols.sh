#!/bin/bash

if [ ! -z "${PackageWaylandProtocols[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									WaylandProtocols								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageWaylandProtocols;
PackageWaylandProtocols[Source]="https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/1.40/downloads/wayland-protocols-1.40.tar.xz";
PackageWaylandProtocols[MD5]="5ec06b6ab9c451bb0edf8530c315ed10";
PackageWaylandProtocols[Name]="wayland-protocols";
PackageWaylandProtocols[Version]="1.40";
PackageWaylandProtocols[Package]="${PackageWaylandProtocols[Name]}-${PackageWaylandProtocols[Version]}";
PackageWaylandProtocols[Extension]=".tar.xz";

PackageWaylandProtocols[Programs]="";
PackageWaylandProtocols[Libraries]="";
PackageWaylandProtocols[Python]="";

InstallWaylandProtocols()
{
	# Check Installation
	CheckWaylandProtocols && return $?;

	# Check Dependencies
	Required=(Wayland)
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
	EchoInfo	"Package ${PackageWaylandProtocols[Name]}"
	_ExtractPackageWaylandProtocols || return $?;
	_BuildWaylandProtocols;
	return $?
}

CheckWaylandProtocols()
{
	[ -d /usr/share/wayland-protocols ] && [ -f /usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml ]
}

CheckWaylandProtocolsVerbose()
{
	if [ ! -d /usr/share/wayland-protocols ] || [ ! -f /usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml ]; then
		echo -en "${C_RED}xdg-shell.xml${C_RESET}"
	fi
	echo
	[ -d /usr/share/wayland-protocols ] && [ -f /usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml ]
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageWaylandProtocols()
{
	DownloadPackage	"${PackageWaylandProtocols[Source]}"	"${SHMAN_PDIR}"	"${PackageWaylandProtocols[Package]}${PackageWaylandProtocols[Extension]}"	"${PackageWaylandProtocols[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageWaylandProtocols[Package]}"	"${PackageWaylandProtocols[Extension]}" || return $?;

	return $?;
}

_BuildWaylandProtocols()
{
	if ! cd "${SHMAN_PDIR}${PackageWaylandProtocols[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageWaylandProtocols[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageWaylandProtocols[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageWaylandProtocols[Package]}/build";

	EchoInfo	"${PackageWaylandProtocols[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				1> /dev/null || { EchoTest KO ${PackageWaylandProtocols[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageWaylandProtocols[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageWaylandProtocols[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageWaylandProtocols[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageWaylandProtocols[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageWaylandProtocols[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageWaylandProtocols[Name]} && PressAnyKeyToContinue; return 1; };
}
