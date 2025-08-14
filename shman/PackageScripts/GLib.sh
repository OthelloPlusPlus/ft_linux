#! /bin/bash

if [ ! -z "${PackageGLib[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh
PDIR=/usr/src

# =====================================||===================================== #
#									GLib									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGLib;
PackageGLib[Source]="https://download.gnome.org/sources/glib/2.82/glib-2.82.5.tar.xz";
PackageGLib[MD5]="87c7641e80b23a05b8ab506d52c970e3";
PackageGLib[Name]="glib";
PackageGLib[Version]="2.82.5";
PackageGLib[Package]="${PackageGLib[Name]}-${PackageGLib[Version]}";
PackageGLib[Extension]=".tar.xz";

PackageGLib[Programs]="gapplication gdbus gdbus-codegen gi-compile-repository gi-decompile-typelib gi-inspect-typelib gio gio-querymodules glib-compile-resources glib-compile-schemas glib-genmarshal glib-gettextize glib-mkenums gobject-query gresource gsettings gtester gtester-report";
PackageGLib[Libraries]="libgio-2.0.so libgirepository-2.0.so libglib-2.0.so libgmodule-2.0.so libgobject-2.0.so libgthread-2.0.so"
PackageGLib[Python]="";

InstallGLib()
{
	# Check Installation
	CheckGLib && return $?;

	# Check Dependencies
	source "${SHMAN_SDIR}/_PythonPip3.sh" && InstallPip docutils || return $?
	Dependencies=(LibXslt PCRE2)
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	# Install Package
	_BuildGLib;
	return $?
}

CheckGLib()
{
	CheckInstallation 	"${PackageGLib[Programs]}"\
						"${PackageGLib[Libraries]}"\
						"${PackageGLib[Python]}" 1> /dev/null || return $?;

	# GObject Introspection
	CheckInstallation 	"g-ir-annotation-tool g-ir-compiler g-ir-doc-tool g-ir-generate g-ir-inspect g-ir-scanner"\
						"libgirepository-1.0.so"\
						"_giscanner" 1> /dev/null;
	return $?;
}

CheckGLibVerbose()
{
	CheckInstallationVerbose	"${PackageGLib[Programs]}"\
								"${PackageGLib[Libraries]}"\
								"${PackageGLib[Python]}" || return $?;

	# GObject Introspection
	CheckInstallationVerbose 	"g-ir-annotation-tool g-ir-compiler g-ir-doc-tool g-ir-generate g-ir-inspect g-ir-scanner"\
								"libgirepository-1.0.so"\
								"_giscanner";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildGLib()
{
	EchoInfo	"Package ${PackageGLib[Name]}"

	DownloadPackage	"${PackageGLib[Source]}"	"${SHMAN_PDIR}"	"${PackageGLib[Package]}${PackageGLib[Extension]}"	"${PackageGLib[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGLib[Package]}"	"${PackageGLib[Extension]}";
	wget -P "${SHMAN_PDIR}" https://www.linuxfromscratch.org/patches/blfs/12.3/glib-skip_warnings-1.patch;

	if ! cd "${SHMAN_PDIR}${PackageGLib[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGLib[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageGLib[Name]}> Patching"
	patch -Np1 -i ../glib-skip_warnings-1.patch

	EchoInfo	"${PackageGLib[Name]}> Setting env PATHs"
	_ConfigureGLibEnvPaths;

	if [ -e /usr/include/glib-2.0 ]; then
		EchoInfo	"${PackageGLib[Name]}> Move old headers out of the way"
		rm -rf /usr/include/glib-2.0.old &&
		mv -vf /usr/include/glib-2.0{,.old}
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageGLib[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageGLib[Package]}/build";

	EchoInfo	"${PackageGLib[Name]}> meson setup"
	PKG_CONFIG_PATH=/usr/lib64/pkgconfig meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D introspection=disabled \
				-D glib_debug=disabled \
				-D man-pages=enabled \
				-D sysprof=disabled \
				1> /dev/null || { PackageGLib[Status]=$?; EchoTest KO ${PackageGLib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGLib[Name]}> ninja"
	ninja 1> /dev/null || { PackageGLib[Status]=$?; EchoTest KO ${PackageGLib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGLib[Name]}> ninja install (first time)"
	ninja install 1> /dev/null || { PackageGLib[Status]=$?; EchoTest KO ${PackageGLib[Name]} && PressAnyKeyToContinue; return 1; };

	# Pause GLib installation for Gobject Introspection installation
	_InstallGObjectInstrospection || return $?;

	EchoInfo	"${PackageGLib[Name]}> Generate instrospection data"
	PKG_CONFIG_PATH=/usr/lib64/pkgconfig meson configure -D introspection=enabled 1> /dev/null &&
	EchoInfo	"${PackageGLib[Name]}> ninja"
	ninja 1> /dev/null || { PackageGLib[Status]=$?; EchoTest KO ${PackageGLib[Name]} && env && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGLib[Name]}> ninja install (second time)"
	ninja install 1> /dev/null && PackageGLib[Status]=$? || { PackageGLib[Status]=$?; EchoTest KO ${PackageGLib[Name]} && PressAnyKeyToContinue; return 1; };
}

_ConfigureGLibEnvPaths()
{
	# Check if pkg-config searches /usr/lib64/pkgconfig
	if ! pkg-config --variable pc_path pkg-config | tr ':' '\n' | grep -q '^/usr/lib64/pkgconfig$'; then
		if ! echo "${PKG_CONFIG_PATH:-}" | tr ':' '\n' | grep -q '^/usr/lib64/pkgconfig$'; then
			echo 'export PKG_CONFIG_PATH="/usr/lib64/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"' >> /etc/profile;
			echo "Added /usr/lib64/pkgconfig to PKG_CONFIG_PATH"
		fi
	fi
	export PKG_CONFIG_PATH="/usr/lib64/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"

	# Check if /usr/lib64 is already searched by default by ld.so
	if ! ldconfig -v 2>/dev/null | grep -q '^/usr/lib64$'; then
		if ! echo "${LD_LIBRARY_PATH:-}" | tr ':' '\n' | grep -q '^/usr/lib64$'; then
			echo 'export LD_LIBRARY_PATH="/usr/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"' >> /etc/profile
			echo "Added /usr/lib64 to LD_LIBRARY_PATH"
		fi
	fi
	export LD_LIBRARY_PATH="/usr/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
}

_InstallGObjectInstrospection()
{
	EchoInfo	"${PackageGLib[Name]}|GObject> Build GObject Introspection"
	EchoInfo	"${PackageGLib[Name]}|GObject> Downloading..."
	wget -P "${SHMAN_PDIR}" https://download.gnome.org/sources/gobject-introspection/1.82/gobject-introspection-1.82.0.tar.xz;
	EchoInfo	"${PackageGLib[Name]}|GObject> Extracting..."
	tar -xf ../../gobject-introspection-1.82.0.tar.xz 1> /dev/null || { PackageGLib[Status]=$?; EchoTest KO ${PackageGLib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGLib[Name]}|GObject> meson setup..."
	PKG_CONFIG_PATH=/usr/lib64/pkgconfig meson setup gobject-introspection-1.82.0 gi-build \
				--prefix=/usr \
				--buildtype=release \
				1> /dev/null || { PackageGLib[Status]=$?; EchoTest KO ${PackageGLib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGLib[Name]}|GObject> ninja -C gi-build..."
	ninja -C gi-build 1> /dev/null || { PackageGLib[Status]=$?; EchoTest KO ${PackageGLib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGLib[Name]}|GObject> Test GObject Introspection"
	ninja -C gi-build test || { PackageGLib[Status]=$?; EchoTest KO ${PackageGLib[Name]} && EchoInfo "Check Errors manually..." && PressAnyKeyToContinue; };

	EchoInfo	"${PackageGLib[Name]}|GObject> Install GObject Introspection"
	ninja -C gi-build install 1> /dev/null || { PackageGLib[Status]=$?; EchoTest KO ${PackageGLib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGLib[Name]}|GObject> Symbolic link for _giscanner.cpython-312-x86_64-linux-gnu.so"
	ln /usr/lib64/gobject-introspection/giscanner/_giscanner.cpython-312-x86_64-linux-gnu.so /usr/lib/python3.12/site-packages/
}
