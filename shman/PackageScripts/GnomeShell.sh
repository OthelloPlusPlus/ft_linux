#!/bin/bash

if [ ! -z "${PackageGnomeShell[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									GnomeShell								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGnomeShell;
PackageGnomeShell[Source]="https://download.gnome.org/sources/gnome-shell/47/gnome-shell-47.4.tar.xz";
PackageGnomeShell[MD5]="d6d7e371c2eef21ffc55f1259fbaecba";
PackageGnomeShell[Name]="gnome-shell";
PackageGnomeShell[Version]="47.4";
PackageGnomeShell[Package]="${PackageGnomeShell[Name]}-${PackageGnomeShell[Version]}";
PackageGnomeShell[Extension]=".tar.xz";

# Removed gnome-extensions gnome-shell-extension-prefs gnome-shell-extension-tool as they appear to belong to GnomeShellExtensions
PackageGnomeShell[Programs]="gnome-extensions-app gnome-shell gnome-shell-test-tool";
PackageGnomeShell[Libraries]="";
PackageGnomeShell[Python]="";

InstallGnomeShell()
{
	# Check Installation
	CheckGnomeShell && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGnomeShell[Name]}> Checking dependencies..."
	Required=(EvolutionDataServer Gcr4 Gjs GnomeDesktop Ibus Mutter Polkit StartupNotification)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(DesktopFileUtils GnomeAutoar GnomeBluetooth GstPluginsBase NetworkManager PowerProfilesDaemon)
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
	EchoInfo	"${PackageGnomeShell[Name]}> Building package..."
	_ExtractPackageGnomeShell || return $?;
	_BuildGnomeShell;
	return $?
}

CheckGnomeShell()
{
	CheckInstallation 	"${PackageGnomeShell[Programs]}"\
						"${PackageGnomeShell[Libraries]}"\
						"${PackageGnomeShell[Python]}" 1> /dev/null;
	return $?;
}

CheckGnomeShellVerbose()
{
	CheckInstallationVerbose	"${PackageGnomeShell[Programs]}"\
								"${PackageGnomeShell[Libraries]}"\
								"${PackageGnomeShell[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGnomeShell()
{
	DownloadPackage	"${PackageGnomeShell[Source]}"	"${SHMAN_PDIR}"	"${PackageGnomeShell[Package]}${PackageGnomeShell[Extension]}"	"${PackageGnomeShell[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGnomeShell[Package]}"	"${PackageGnomeShell[Extension]}" || return $?;

	return $?;
}

_BuildGnomeShell()
{
	if ! cd "${SHMAN_PDIR}${PackageGnomeShell[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGnomeShell[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGnomeShell[Package]}/build \
					|| { EchoError "${PackageGnomeShell[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGnomeShell[Package]}/build"; return 1; }

	EchoInfo	"${PackageGnomeShell[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D systemd=false \
				-D tests=false \
				-D extensions_tool=false \
				.. \
				1> /dev/null || { EchoTest KO ${PackageGnomeShell[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeShell[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGnomeShell[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeShell[Name]}> ninja test"
	meson configure -D tests=true 1> /dev/null || { EchoTest KO ${PackageGnomeShell[Name]} && PressAnyKeyToContinue; return 1; };
	if [ -z "$DISPLAY" ]; then
		EchoWarning "No X graphical environment detected. Tests requiring X will fail."
		ninja test || { EchoWarning "${PackageGnomeShell[Name]}> Failures expected due to no X graphical environment." && PressAnyKeyToContinue; };
	else
		ninja test 1> /dev/null || { EchoTest KO ${PackageGnomeShell[Name]} && PressAnyKeyToContinue; return 1; };
	fi

	EchoInfo	"${PackageGnomeShell[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGnomeShell[Name]} && PressAnyKeyToContinue; return 1; };
}
