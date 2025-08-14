#!/bin/bash

if [ ! -z "${PackageLibNotify[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibNotify								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibNotify;
PackageLibNotify[Source]="https://download.gnome.org/sources/libnotify/0.8/libnotify-0.8.4.tar.xz";
PackageLibNotify[MD5]="00e2b66b100ea57106dee8988c40fe77";
PackageLibNotify[Name]="libnotify";
PackageLibNotify[Version]="0.8.4";
PackageLibNotify[Package]="${PackageLibNotify[Name]}-${PackageLibNotify[Version]}";
PackageLibNotify[Extension]=".tar.xz";

PackageLibNotify[Programs]="notify-send";
PackageLibNotify[Libraries]="libnotify.so";
PackageLibNotify[Python]="";

InstallLibNotify()
{
	# Check Installation
	CheckLibNotify && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibNotify[Name]}> Checking dependencies..."
	Required=(GTK3 GLib)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(GiDocGen Xmlto)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibNotify[Name]}> Building package..."
	_ExtractPackageLibNotify || return $?;
	_BuildLibNotify;
	return $?
}

CheckLibNotify()
{
	CheckInstallation 	"${PackageLibNotify[Programs]}"\
						"${PackageLibNotify[Libraries]}"\
						"${PackageLibNotify[Python]}" 1> /dev/null;
	return $?;
}

CheckLibNotifyVerbose()
{
	CheckInstallationVerbose	"${PackageLibNotify[Programs]}"\
								"${PackageLibNotify[Libraries]}"\
								"${PackageLibNotify[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibNotify()
{
	DownloadPackage	"${PackageLibNotify[Source]}"	"${SHMAN_PDIR}"	"${PackageLibNotify[Package]}${PackageLibNotify[Extension]}"	"${PackageLibNotify[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibNotify[Package]}"	"${PackageLibNotify[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildLibNotify()
{
	if ! cd "${SHMAN_PDIR}${PackageLibNotify[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibNotify[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibNotify[Package]}/build \
					|| { EchoError "${PackageLibNotify[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibNotify[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibNotify[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D gtk_doc=false \
				-D man=false \
				.. \
				1> /dev/null || { EchoTest KO ${PackageLibNotify[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibNotify[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibNotify[Name]} && PressAnyKeyToContinue; return 1; };

	# sed "/docs_dir =/s@\$@ / 'libnotify'@" \
	# 	-i ../docs/reference/meson.build   &&
	# meson configure -D gtk_doc=true        &&
	# ninja

	EchoInfo	"${PackageLibNotify[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibNotify[Name]} && PressAnyKeyToContinue; return 1; };
	if [ -e /usr/share/doc/libnotify ]; then
		rm -rf /usr/share/doc/libnotify-0.8.4
		mv -v  /usr/share/doc/libnotify{,-0.8.4}
	fi
}
