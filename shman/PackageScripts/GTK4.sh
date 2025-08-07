#!/bin/bash

if [ ! -z "${PackageGTK4[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									GTK4								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGTK4;
PackageGTK4[Source]="https://download.gnome.org/sources/gtk/4.16/gtk-4.16.12.tar.xz";
PackageGTK4[MD5]="0f2b154a0b05e4ca94a05aaeb7e1f3fb";
PackageGTK4[Name]="gtk";
PackageGTK4[Version]="4.16.12";
PackageGTK4[Package]="${PackageGTK4[Name]}-${PackageGTK4[Version]}";
PackageGTK4[Extension]=".tar.xz";

PackageGTK4[Programs]="gtk4-broadwayd gtk4-builder-tool gtk4-demo gtk4-demo-application gtk4-encode-symbolic-svg gtk4-icon-browser gtk4-launch gtk4-node-editor gtk4-print-editor gtk4-query-settings gtk4-update-icon-cache gtk4-widget-factory";
PackageGTK4[Libraries]="libgtk-4.so";
PackageGTK4[Python]="";

InstallGTK4()
{
	# Check Installation
	CheckGTK4 && return $?;

	# Check Dependencies
	Required=(FriBidi GdkPixbuf Graphene ISOCodes LibEpoxy LibXkbcommon Pango WaylandProtocols GLib)
	for Dependency in "${Required[@]}"; do
		EchoInfo	"${PackageGTK4[Name]}4> Checking required ${Dependency}..."
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	# removed AdwaitaIconTheme for circular dependency
	Recommended=(GstPluginsGood GstPluginsBad GlslcFromShaderc HicolorIconTheme LibRsvg VulkanLoader)
	for Dependency in "${Recommended[@]}"; do
		EchoInfo	"${PackageGTK4[Name]}4> Checking recommended ${Dependency}..."
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Avahi Colord Cups GiDocGen Highlight Libcloudproviders Sassc Tinysparql)
	for Dependency in "${Optional[@]}"; do
		EchoInfo	"${PackageGTK4[Name]}4> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"Package ${PackageGTK4[Name]}"
	_ExtractPackageGTK4 || return $?;
	_BuildGTK4 || return $?;
	_ConfigureGTK4
	return $?
}

CheckGTK4()
{
	CheckInstallation 	"${PackageGTK4[Programs]}"\
						"${PackageGTK4[Libraries]}"\
						"${PackageGTK4[Python]}" 1> /dev/null;
	return $?;
}

CheckGTK4Verbose()
{
	CheckInstallationVerbose	"${PackageGTK4[Programs]}"\
								"${PackageGTK4[Libraries]}"\
								"${PackageGTK4[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGTK4()
{
	DownloadPackage	"${PackageGTK4[Source]}"	"${SHMAN_PDIR}"	"${PackageGTK4[Package]}${PackageGTK4[Extension]}"	"${PackageGTK4[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGTK4[Package]}"	"${PackageGTK4[Extension]}" || return $?;
	wget -P "${SHMAN_PDIR}" "https://www.linuxfromscratch.org/patches/blfs/12.3/gtk-4.16.12-libpng_1_6_45-1.patch";

	return $?;
}

_BuildGTK4()
{
	if ! cd "${SHMAN_PDIR}${PackageGTK4[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGTK4[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageGTK4[Name]}4> Patching"
	patch -Np1 -i ../gtk-4.16.12-libpng_1_6_45-1.patch

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageGTK4[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageGTK4[Package]}/build";

	EchoInfo	"${PackageGTK4[Name]}4> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D broadway-backend=true \
				-D introspection=enabled \
				-D vulkan=disabled \
				.. \
				1> /dev/null || { EchoTest KO ${PackageGTK4[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGTK4[Name]}4> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGTK4[Name]} && PressAnyKeyToContinue; return 1; };

	if "${SHMAN_SDIR}/GiDocGen.sh" && CheckGiDocGen; then
		sed "s@'doc'@& / 'gtk-4.16.12'@" \
			-i ../docs/reference/meson.build && \
		meson configure -D documentation=true && \
		ninja
	fi

	# EchoInfo	"${PackageGTK4[Name]}4> meson test"
	# env -u{GALLIUM_DRIVER,MESA_LOADER_DRIVER_OVERRIDE} \
	# 	LIBGL_ALWAYS_SOFTWARE=1 VK_LOADER_DRIVERS_SELECT='lvp*' \
	# 	dbus-run-session meson test --setup x11 \
	# 								--no-suite={headless,needs-udmabuf} \
	# 	1> /dev/null || { EchoTest KO ${PackageGTK4[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageGTK4[Name]}4> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGTK4[Name]} && PressAnyKeyToContinue; return 1; };
}

_ConfigureGTK4()
{
	mkdir -pv ~/.config/gtk-4.0
cat > ~/.config/gtk-4.0/settings.ini << "EOF"
[Settings]
gtk-theme-name = Adwaita
gtk-icon-theme-name = oxygen
gtk-font-name = DejaVu Sans 12
gtk-cursor-theme-size = 18
gtk-xft-antialias = 1
gtk-xft-hinting = 1
gtk-xft-hintstyle = hintslight
gtk-xft-rgba = rgb
gtk-cursor-theme-name = Adwaita
EOF
}
