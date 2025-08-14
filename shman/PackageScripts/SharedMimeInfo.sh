#!/bin/bash

if [ ! -z "${PackageSharedMimeInfo[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									SharedMimeInfo								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageSharedMimeInfo;
PackageSharedMimeInfo[Source]="https://gitlab.freedesktop.org/xdg/shared-mime-info/-/archive/2.4/shared-mime-info-2.4.tar.gz";
PackageSharedMimeInfo[MD5]="aac56db912b7b12a04fb0018e28f2f36";
PackageSharedMimeInfo[Name]="shared-mime-info";
PackageSharedMimeInfo[Version]="2.4";
PackageSharedMimeInfo[Package]="${PackageSharedMimeInfo[Name]}-${PackageSharedMimeInfo[Version]}";
PackageSharedMimeInfo[Extension]=".tar.gz";

PackageSharedMimeInfo[Programs]="update-mime-database";
PackageSharedMimeInfo[Libraries]="";
PackageSharedMimeInfo[Python]="";

InstallSharedMimeInfo()
{
	# Check Installation
	CheckSharedMimeInfo && return $?;

	# Check Dependencies
	Required=(GLib LibXml2)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	Optional=(Xmlto)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh"
		fi
	done

	# Install Package
	EchoInfo	"Package ${PackageSharedMimeInfo[Name]}"
	_ExtractPackageSharedMimeInfo || return $?;
	_BuildSharedMimeInfo;
	return $?
}

CheckSharedMimeInfo()
{
	CheckInstallation 	"${PackageSharedMimeInfo[Programs]}"\
						"${PackageSharedMimeInfo[Libraries]}"\
						"${PackageSharedMimeInfo[Python]}" 1> /dev/null;
	return $?;
}

CheckSharedMimeInfoVerbose()
{
	CheckInstallationVerbose	"${PackageSharedMimeInfo[Programs]}"\
								"${PackageSharedMimeInfo[Libraries]}"\
								"${PackageSharedMimeInfo[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageSharedMimeInfo()
{
	DownloadPackage	"${PackageSharedMimeInfo[Source]}"	"${SHMAN_PDIR}"	"${PackageSharedMimeInfo[Package]}${PackageSharedMimeInfo[Extension]}"	"${PackageSharedMimeInfo[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageSharedMimeInfo[Package]}"	"${PackageSharedMimeInfo[Extension]}" || return $?;

	wget -P "${SHMAN_PDIR}" "https://anduin.linuxfromscratch.org/BLFS/xdgmime/xdgmime.tar.xz";

	return $?;
}

_BuildSharedMimeInfo()
{
	if ! cd "${SHMAN_PDIR}${PackageSharedMimeInfo[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageSharedMimeInfo[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageSharedMimeInfo[Name]}> Prepare Test suite"
	tar -xf ../xdgmime.tar.xz && make -C xdgmime

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageSharedMimeInfo[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageSharedMimeInfo[Package]}/build";

	EchoInfo	"${PackageSharedMimeInfo[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D update-mimedb=true \
				.. 1> /dev/null || { EchoTest KO ${PackageSharedMimeInfo[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSharedMimeInfo[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageSharedMimeInfo[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSharedMimeInfo[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageSharedMimeInfo[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSharedMimeInfo[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageSharedMimeInfo[Name]} && PressAnyKeyToContinue; return 1; };
}
