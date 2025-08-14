#!/bin/bash

if [ ! -z "${PackageGjs[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									  Gjs									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGjs;
PackageGjs[Source]="https://download.gnome.org/sources/gjs/1.82/gjs-1.82.1.tar.xz";
PackageGjs[MD5]="3ebc85da56719932d4d8f713ffbcf786";
PackageGjs[Name]="gjs";
PackageGjs[Version]="1.82.1";
PackageGjs[Package]="${PackageGjs[Name]}-${PackageGjs[Version]}";
PackageGjs[Extension]=".tar.xz";

PackageGjs[Programs]="gjs gjs-console";
PackageGjs[Libraries]="libgjs.so";
PackageGjs[Python]="";

InstallGjs()
{
	# Check Installation
	CheckGjs && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGjs[Name]}> Checking dependencies..."
	Required=(Cairo Dbus GLib SpiderMonkey GTK3 GTK4)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageGjs[Name]}> Checking required ${Dependency}..."
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Valgrind)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageGjs[Name]}> Building package..."
	_ExtractPackageGjs || return $?;
	_BuildGjs;
	return $?
}

CheckGjs()
{
	CheckInstallation 	"${PackageGjs[Programs]}"\
						"${PackageGjs[Libraries]}"\
						"${PackageGjs[Python]}" 1> /dev/null;
	return $?;
}

CheckGjsVerbose()
{
	CheckInstallationVerbose	"${PackageGjs[Programs]}"\
								"${PackageGjs[Libraries]}"\
								"${PackageGjs[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGjs()
{
	DownloadPackage	"${PackageGjs[Source]}"	"${SHMAN_PDIR}"	"${PackageGjs[Package]}${PackageGjs[Extension]}"	"${PackageGjs[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGjs[Package]}"	"${PackageGjs[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildGjs()
{
	if ! cd "${SHMAN_PDIR}${PackageGjs[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGjs[Package]}";
		return 1;
	fi

	mkdir -p gjs-build 	&& cd ${SHMAN_PDIR}${PackageGjs[Package]}/gjs-build \
					|| { EchoError "${PackageGjs[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGjs[Package]}/build"; return 1; }

	EchoInfo	"${PackageGjs[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				--wrap-mode=nofallback \
				.. \
				1> /dev/null || { EchoTest KO ${PackageGjs[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGjs[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGjs[Name]} && PressAnyKeyToContinue; return 1; };

	if [[ -n "$DISPLAY" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
		EchoInfo	"${PackageGjs[Name]}> ninja test (graphical)"
		ninja test 1> /dev/null || { EchoTest KO ${PackageGjs[Name]} && PressAnyKeyToContinue; return 1; };
	else
		EchoInfo	"${PackageGjs[Name]}> ninja test (non-graphical)"
		ninja test || { EchoTest KO "${PackageGjs[Name]}> Errors could be due to non-graphical testing" && PressAnyKeyToContinue; };
	fi

	EchoInfo	"${PackageGjs[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGjs[Name]} && PressAnyKeyToContinue; return 1; };
}
