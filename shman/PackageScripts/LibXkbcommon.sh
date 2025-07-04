#!/bin/bash

if [ ! -z "${PackageLibXkbcommon[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#								  LibXkbcommon								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibXkbcommon;
PackageLibXkbcommon[Source]="https://github.com/lfs-book/libxkbcommon/archive/v1.8.0/libxkbcommon-1.8.0.tar.gz";
PackageLibXkbcommon[MD5]="e63cb7f5a395a1575246717882b96664";
PackageLibXkbcommon[Name]="libxkbcommon";
PackageLibXkbcommon[Version]="1.8.0";
PackageLibXkbcommon[Package]="${PackageLibXkbcommon[Name]}-${PackageLibXkbcommon[Version]}";
PackageLibXkbcommon[Extension]=".tar.gz";

PackageLibXkbcommon[Programs]="xkbcli";
PackageLibXkbcommon[Libraries]="libxkbcommon.so libxkbcommon-x11.so libxkbregistry.so";
PackageLibXkbcommon[Python]="";

InstallLibXkbcommon()
{
	# Check Installation
	CheckLibXkbcommon && return $?;

	# Check Dependencies
	Required=() # removed runtime XkeyboardConfig
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(LibXcb Wayland WaylandProtocols)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Doxygen)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"Package ${PackageLibXkbcommon[Name]}"
	_ExtractPackageLibXkbcommon || return $?;
	_BuildLibXkbcommon;
	return $?
}

CheckLibXkbcommon()
{
	CheckInstallation 	"${PackageLibXkbcommon[Programs]}"\
						"${PackageLibXkbcommon[Libraries]}"\
						"${PackageLibXkbcommon[Python]}" 1> /dev/null;
	return $?;
}

CheckLibXkbcommonVerbose()
{
	CheckInstallationVerbose	"${PackageLibXkbcommon[Programs]}"\
								"${PackageLibXkbcommon[Libraries]}"\
								"${PackageLibXkbcommon[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibXkbcommon()
{
	DownloadPackage	"${PackageLibXkbcommon[Source]}"	"${SHMAN_PDIR}"	"${PackageLibXkbcommon[Package]}${PackageLibXkbcommon[Extension]}"	"${PackageLibXkbcommon[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibXkbcommon[Package]}"	"${PackageLibXkbcommon[Extension]}" || return $?;

	return $?;
}

_BuildLibXkbcommon()
{
	if ! cd "${SHMAN_PDIR}${PackageLibXkbcommon[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibXkbcommon[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageLibXkbcommon[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageLibXkbcommon[Package]}/build";

	EchoInfo	"${PackageLibXkbcommon[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D enable-docs=false \
				1> /dev/null || { EchoTest KO ${PackageLibXkbcommon[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXkbcommon[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibXkbcommon[Name]} && PressAnyKeyToContinue; return 1; };

	# To test the results, ensure Xvfb and xkeyboard-config-2.44 are available, then issue: ninja test.
	# EchoInfo	"${PackageLibXkbcommon[Name]}> ninja test"
	# ninja test 1> /dev/null || { EchoTest KO ${PackageLibXkbcommon[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLibXkbcommon[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibXkbcommon[Name]} && PressAnyKeyToContinue; return 1; };
}
