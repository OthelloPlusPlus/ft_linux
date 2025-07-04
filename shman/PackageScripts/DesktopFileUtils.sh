#!/bin/bash

if [ ! -z "${PackageDesktopFileUtils[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									DesktopFileUtils								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageDesktopFileUtils;
PackageDesktopFileUtils[Source]="https://www.freedesktop.org/software/desktop-file-utils/releases/desktop-file-utils-0.28.tar.xz";
PackageDesktopFileUtils[MD5]="dec5d7265c802db1fde3980356931b7b";
PackageDesktopFileUtils[Name]="desktop-file-utils";
PackageDesktopFileUtils[Version]="0.28";
PackageDesktopFileUtils[Package]="${PackageDesktopFileUtils[Name]}-${PackageDesktopFileUtils[Version]}";
PackageDesktopFileUtils[Extension]=".tar.xz";

PackageDesktopFileUtils[Programs]="desktop-file-edit desktop-file-install desktop-file-validate update-desktop-database";
PackageDesktopFileUtils[Libraries]="";
PackageDesktopFileUtils[Python]="";

InstallDesktopFileUtils()
{
	# Check Installation
	CheckDesktopFileUtils && return $?;

	# Check Dependencies
	EchoInfo	"${PackageDesktopFileUtils[Name]}> Checking dependencies..."
	Required=(GLib)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Emacs)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageDesktopFileUtils[Name]}> Building package..."
	_ExtractPackageDesktopFileUtils || return $?;
	_BuildDesktopFileUtils;
	return $?
}

CheckDesktopFileUtils()
{
	CheckInstallation 	"${PackageDesktopFileUtils[Programs]}"\
						"${PackageDesktopFileUtils[Libraries]}"\
						"${PackageDesktopFileUtils[Python]}" 1> /dev/null;
	return $?;
}

CheckDesktopFileUtilsVerbose()
{
	CheckInstallationVerbose	"${PackageDesktopFileUtils[Programs]}"\
								"${PackageDesktopFileUtils[Libraries]}"\
								"${PackageDesktopFileUtils[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageDesktopFileUtils()
{
	DownloadPackage	"${PackageDesktopFileUtils[Source]}"	"${SHMAN_PDIR}"	"${PackageDesktopFileUtils[Package]}${PackageDesktopFileUtils[Extension]}"	"${PackageDesktopFileUtils[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageDesktopFileUtils[Package]}"	"${PackageDesktopFileUtils[Extension]}" || return $?;

	for URL in \
	# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildDesktopFileUtils()
{
	if ! cd "${SHMAN_PDIR}${PackageDesktopFileUtils[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageDesktopFileUtils[Package]}";
		return 1;
	fi

	rm -fv /usr/bin/desktop-file-edit

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageDesktopFileUtils[Package]}/build \
					|| { EchoError "${PackageDesktopFileUtils[Name]}> Failed to enter ${SHMAN_PDIR}${PackageDesktopFileUtils[Package]}/build"; return 1; }

	EchoInfo	"${PackageDesktopFileUtils[Name]}> Configure"
	meson setup --prefix=/usr\
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageDesktopFileUtils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDesktopFileUtils[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageDesktopFileUtils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDesktopFileUtils[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageDesktopFileUtils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDesktopFileUtils[Name]}> Configuration"
	install -vdm755 /usr/share/applications &&
update-desktop-database /usr/share/applications
}
