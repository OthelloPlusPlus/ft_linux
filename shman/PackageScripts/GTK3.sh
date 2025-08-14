#!/bin/bash

if [ ! -z "${PackageGTK3[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									  GTK3									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGTK3;
PackageGTK3[Source]="https://download.gnome.org/sources/gtk/3.24/gtk-3.24.48.tar.xz";
PackageGTK3[MD5]="61b8af1ffb255cdabd44629cd2a05793";
PackageGTK3[Name]="gtk";
PackageGTK3[Version]="3.24.48";
PackageGTK3[Package]="${PackageGTK3[Name]}-${PackageGTK3[Version]}";
PackageGTK3[Extension]=".tar.xz";

PackageGTK3[Programs]="broadwayd gtk3-demo gtk3-demo-application gtk3-icon-browser gtk3-widget-factory gtk-builder-tool gtk-encode-symbolic-svg gtk-launch gtk-query-immodules-3.0 gtk-query-settings gtk-update-icon-cache";
PackageGTK3[Libraries]="libgailutil-3.so libgdk-3.so libgtk-3.so";
PackageGTK3[Python]="";

InstallGTK3()
{
	# Check Installation
	CheckGTK3 && return $?;

	EchoInfo	"${PackageGTK3[Name]}3> Checking dependencies..."

	# Check Dependencies
	Dependencies=(AtSpi2Core GdkPixbuf LibEpoxy Pango)
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=(LibXkbcommon LibXslt Wayland WaylandProtocols GLib)
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
	EchoInfo	"${PackageGTK3[Name]}3> Building package..."
	_BuildGTK3;
	return $?
}

CheckGTK3()
{
	CheckInstallation 	"${PackageGTK3[Programs]}"\
						"${PackageGTK3[Libraries]}"\
						"${PackageGTK3[Python]}" 1> /dev/null;
	return $?;
}

CheckGTK3Verbose()
{
	CheckInstallationVerbose	"${PackageGTK3[Programs]}"\
								"${PackageGTK3[Libraries]}"\
								"${PackageGTK3[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildGTK3()
{
	EchoInfo	"Package ${PackageGTK3[Name]}"

	DownloadPackage	"${PackageGTK3[Source]}"	"${SHMAN_PDIR}"	"${PackageGTK3[Package]}${PackageGTK3[Extension]}"	"${PackageGTK3[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGTK3[Package]}"	"${PackageGTK3[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageGTK3[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGTK3[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageGTK3[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageGTK3[Package]}/build";

	EchoInfo	"${PackageGTK3[Name]}3> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D man=false \
				-D broadway_backend=true \
				1> /dev/null || { EchoTest KO ${PackageGTK3[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGTK3[Name]}3> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGTK3[Name]} && PressAnyKeyToContinue; return 1; };

# Requires graphical session, whatever that means
	# EchoInfo	"${PackageGTK3[Name]}3> dbus-run-session ninja test"
	# dbus-run-session ninja test 1> /dev/null || { EchoTest KO ${PackageGTK3[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGTK3[Name]}3> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGTK3[Name]} && PressAnyKeyToContinue; return 1; };
}
