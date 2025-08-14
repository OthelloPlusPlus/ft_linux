#!/bin/bash

if [ ! -z "${PackageMutter[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Mutter								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMutter;
PackageMutter[Source]="https://download.gnome.org/sources/mutter/47/mutter-47.5.tar.xz";
PackageMutter[MD5]="c899a4fed30ce1a99f0e17567b59cfb9";
PackageMutter[Name]="mutter";
PackageMutter[Version]="47.5";
PackageMutter[Package]="${PackageMutter[Name]}-${PackageMutter[Version]}";
PackageMutter[Extension]=".tar.xz";

PackageMutter[Programs]="mutter";
PackageMutter[Libraries]="libmutter-15.so libmutter-test-15.so";
PackageMutter[Python]="";

InstallMutter()
{
	# Check Installation
	CheckMutter && return $?;

	# Check Dependencies
	EchoInfo	"${PackageMutter[Name]}> Checking dependencies..."
	# Added Elogind cause it needs libsystemd.so which elogind emulates
	Required=(GnomeSettingsDaemon Graphene LibEi LibXcvt LibXkbcommon Pipewire Elogind)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	# Added Colord because it seems to need it
	Recommended=(DesktopFileUtils GLib LibDisplayInfo StartupNotification LibInput Wayland WaylandProtocols Xwayland Colord)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Dbusmock XorgServer)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageMutter[Name]}> Building package..."
	_ExtractPackageMutter || return $?;
	_BuildMutter;
	return $?
}

CheckMutter()
{
	CheckInstallation 	"${PackageMutter[Programs]}"\
						"${PackageMutter[Libraries]}"\
						"${PackageMutter[Python]}" 1> /dev/null;
	return $?;
}

CheckMutterVerbose()
{
	CheckInstallationVerbose	"${PackageMutter[Programs]}"\
								"${PackageMutter[Libraries]}"\
								"${PackageMutter[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageMutter()
{
	DownloadPackage	"${PackageMutter[Source]}"	"${SHMAN_PDIR}"	"${PackageMutter[Package]}${PackageMutter[Extension]}"	"${PackageMutter[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageMutter[Package]}"	"${PackageMutter[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildMutter()
{
	if ! cd "${SHMAN_PDIR}${PackageMutter[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageMutter[Package]}";
		return 1;
	fi

	# EchoInfo	"${PackageMutter[Name]}> AI Patching"
	# if [ "$(grep -c "^option('colord'" meson_options.txt)" -eq 0 ]; then
	# 	echo "option('colord', type: 'boolean', value: false, description: 'Enable colord support')" >> meson_options.txt;
	# fi
	# sed -i "s|^colord_dep = dependency('colord', version: colord_req)|colord_dep = dependency('colord', version: colord_req, required: get_option('colord'))|" meson.build

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageMutter[Package]}/build \
					|| { EchoError "${PackageMutter[Name]}> Failed to enter ${SHMAN_PDIR}${PackageMutter[Package]}/build"; return 1; }

	EchoInfo	"${PackageMutter[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D clutter_tests=false \
				-D profiler=false \
				-D libdisplay_info=disabled \
				-D xwayland=false \
				.. 1> /dev/null || { EchoTest KO ${PackageMutter[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMutter[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageMutter[Name]} && PressAnyKeyToContinue; return 1; };

	if [ -f ${SHMAN_SDIR}/Dbusmock.sh ] &&	source "${SHMAN_SDIR}/Dbusmock.sh" && CheckDbusmock; then
		EchoInfo	"${PackageMutter[Name]}> ninja test"
		meson configure -D tests=enabled -D clutter_tests=false && \
		ninja test 1> /dev/null || { EchoTest KO ${PackageMutter[Name]} && PressAnyKeyToContinue; return 1; };
	fi

	EchoInfo	"${PackageMutter[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageMutter[Name]} && PressAnyKeyToContinue; return 1; };
}
