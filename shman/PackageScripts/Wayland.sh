#!/bin/bash

if [ ! -z "${PackageWayland[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Wayland									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageWayland;
PackageWayland[Source]="https://gitlab.freedesktop.org/wayland/wayland/-/releases/1.23.0/downloads/wayland-1.23.0.tar.xz";
PackageWayland[MD5]="23ad991e776ec8cf7e58b34cbd2efa75";
PackageWayland[Name]="wayland";
PackageWayland[Version]="1.23.0";
PackageWayland[Package]="${PackageWayland[Name]}-${PackageWayland[Version]}";
PackageWayland[Extension]=".tar.xz";

PackageWayland[Programs]="wayland-scanner";
PackageWayland[Libraries]="libwayland-client.so libwayland-cursor.so libwayland-egl.so libwayland-server.so";
PackageWayland[Python]="";

InstallWayland()
{
	# Check Installation
	CheckWayland && return $?;

	# Check Dependencies
	Required=(LibXml2)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Doxygen Graphviz Xmlto  DocbookXml DocbookXslNons LibXslt)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"Package ${PackageWayland[Name]}"
	_ExtractPackageWayland || return $?;
	_BuildWayland;
	return $?
}

CheckWayland()
{
	CheckInstallation 	"${PackageWayland[Programs]}"\
						"${PackageWayland[Libraries]}"\
						"${PackageWayland[Python]}" 1> /dev/null;
	return $?;
}

CheckWaylandVerbose()
{
	CheckInstallationVerbose	"${PackageWayland[Programs]}"\
								"${PackageWayland[Libraries]}"\
								"${PackageWayland[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageWayland()
{
	DownloadPackage	"${PackageWayland[Source]}"	"${SHMAN_PDIR}"	"${PackageWayland[Package]}${PackageWayland[Extension]}"	"${PackageWayland[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageWayland[Package]}"	"${PackageWayland[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildWayland()
{
	if ! cd "${SHMAN_PDIR}${PackageWayland[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageWayland[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageWayland[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageWayland[Package]}/build";

	EchoInfo	"${PackageWayland[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D documentation=false \
				1> /dev/null || { EchoTest KO ${PackageWayland[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageWayland[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageWayland[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageWayland[Name]}> ninja test"
	env -u XDG_RUNTIME_DIR ninja test 1> /dev/null || { EchoTest KO ${PackageWayland[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageWayland[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageWayland[Name]} && PressAnyKeyToContinue; return 1; };
}
