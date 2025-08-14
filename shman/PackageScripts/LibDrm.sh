#!/bin/bash

if [ ! -z "${PackageLibDrm[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibDrm								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibDrm;
PackageLibDrm[Source]="https://dri.freedesktop.org/libdrm/libdrm-2.4.124.tar.xz";
PackageLibDrm[MD5]="78f7f7ee6aff711696d4b34465b40728";
PackageLibDrm[Name]="libdrm";
PackageLibDrm[Version]="2.4.124";
PackageLibDrm[Package]="${PackageLibDrm[Name]}-${PackageLibDrm[Version]}";
PackageLibDrm[Extension]=".tar.xz";

PackageLibDrm[Programs]="";
# libdrm_intel.so doesnt seem to be relevant
PackageLibDrm[Libraries]="libdrm_amdgpu.so libdrm_nouveau.so libdrm_radeon.so libdrm.so";
PackageLibDrm[Python]="";

InstallLibDrm()
{
	# Check Installation
	CheckLibDrm && return $?;

	# Check Dependencies
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	# Removed XorgLibraries because circulare dependency...
	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(CMake Libxslt)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"Package ${PackageLibDrm[Name]}"
	_ExtractPackageLibDrm || return $?;
	_BuildLibDrm;
	return $?
}

CheckLibDrm()
{
	CheckInstallation 	"${PackageLibDrm[Programs]}"\
						"${PackageLibDrm[Libraries]}"\
						"${PackageLibDrm[Python]}" 1> /dev/null;
	return $?;
}

CheckLibDrmVerbose()
{
	CheckInstallationVerbose	"${PackageLibDrm[Programs]}"\
								"${PackageLibDrm[Libraries]}"\
								"${PackageLibDrm[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibDrm()
{
	DownloadPackage	"${PackageLibDrm[Source]}"	"${SHMAN_PDIR}"	"${PackageLibDrm[Package]}${PackageLibDrm[Extension]}"	"${PackageLibDrm[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibDrm[Package]}"	"${PackageLibDrm[Extension]}" || return $?;

	return $?;
}

_BuildLibDrm()
{
	if ! cd "${SHMAN_PDIR}${PackageLibDrm[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibDrm[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageLibDrm[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageLibDrm[Package]}/build";

	EchoInfo	"${PackageLibDrm[Name]}> Configure"
	meson setup --prefix=$XORG_PREFIX \
				--buildtype=release \
				-D udev=true \
				-D valgrind=disabled \
				.. \
				1> /dev/null || { EchoTest KO ${PackageLibDrm[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibDrm[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibDrm[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibDrm[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageLibDrm[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibDrm[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibDrm[Name]} && PressAnyKeyToContinue; return 1; };
}
