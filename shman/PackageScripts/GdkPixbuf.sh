#!/bin/bash

if [ ! -z "${PackageGdkPixbuf[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									GdkPixbuf								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGdkPixbuf;
PackageGdkPixbuf[Source]="https://download.gnome.org/sources/gdk-pixbuf/2.42/gdk-pixbuf-2.42.12.tar.xz";
PackageGdkPixbuf[MD5]="f986fdbba5ec6233c96f8b6535811780";
PackageGdkPixbuf[Name]="gdk-pixbuf";
PackageGdkPixbuf[Version]="2.42.12";
PackageGdkPixbuf[Package]="${PackageGdkPixbuf[Name]}-${PackageGdkPixbuf[Version]}";
PackageGdkPixbuf[Extension]=".tar.xz";

PackageGdkPixbuf[Programs]="gdk-pixbuf-csource gdk-pixbuf-pixdata gdk-pixbuf-query-loaders gdk-pixbuf-thumbnailer";
PackageGdkPixbuf[Libraries]="libgdk_pixbuf-2.0.so";
PackageGdkPixbuf[Python]="";

InstallGdkPixbuf()
{
	# Check Installation
	CheckGdkPixbuf && return $?;

	# Check Dependencies
	Required=(GLib LibJpegTurbo LibPng SharedMimeInfo)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(LibRsvg LibTiff)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(GiDocGen LibAvif LibJxl WebpPixbufLoader)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"Package ${PackageGdkPixbuf[Name]}"
	_ExtractPackageGdkPixbuf || return $?;
	_BuildGdkPixbuf;
	return $?
}

CheckGdkPixbuf()
{
	CheckInstallation 	"${PackageGdkPixbuf[Programs]}"\
						"${PackageGdkPixbuf[Libraries]}"\
						"${PackageGdkPixbuf[Python]}" 1> /dev/null;
	return $?;
}

CheckGdkPixbufVerbose()
{
	CheckInstallationVerbose	"${PackageGdkPixbuf[Programs]}"\
								"${PackageGdkPixbuf[Libraries]}"\
								"${PackageGdkPixbuf[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGdkPixbuf()
{
	DownloadPackage	"${PackageGdkPixbuf[Source]}"	"${SHMAN_PDIR}"	"${PackageGdkPixbuf[Package]}${PackageGdkPixbuf[Extension]}"	"${PackageGdkPixbuf[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGdkPixbuf[Package]}"	"${PackageGdkPixbuf[Extension]}" || return $?;

	return $?;
}

_BuildGdkPixbuf()
{
	if ! cd "${SHMAN_PDIR}${PackageGdkPixbuf[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGdkPixbuf[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageGdkPixbuf[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageGdkPixbuf[Package]}/build";

	EchoInfo	"${PackageGdkPixbuf[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D others=enabled \
				--wrap-mode=nofallback \
				1> /dev/null || { EchoTest KO ${PackageGdkPixbuf[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGdkPixbuf[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGdkPixbuf[Name]} && PressAnyKeyToContinue; return 1; };

	if CheckPip gi-docgen; then
		sed "/docs_dir =/s@\$@ / 'gdk-pixbuf-2.42.12'@" -i ../docs/meson.build &&
		meson configure -D gtk_doc=true                                        &&
		ninja
	fi

	EchoInfo	"${PackageGdkPixbuf[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO "${PackageGdkPixbuf[Name]} (Known space issue: gdk-pixbuf:format / pixbuf-jpeg)" && PressAnyKeyToContinue; };
	
	EchoInfo	"${PackageGdkPixbuf[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGdkPixbuf[Name]} && PressAnyKeyToContinue; return 1; };
}
