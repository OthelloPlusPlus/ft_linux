#!/bin/bash

if [ ! -z "${PackagePyGObject3[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									PyGObject3								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePyGObject3;
PackagePyGObject3[Source]="https://download.gnome.org/sources/pygobject/3.50/pygobject-3.50.0.tar.xz";
PackagePyGObject3[MD5]="8f34e4bc1d7d57faf558180b0051c9ef";
PackagePyGObject3[Name]="pygobject";
PackagePyGObject3[Version]="3.50.0";
PackagePyGObject3[Package]="${PackagePyGObject3[Name]}-${PackagePyGObject3[Version]}";
PackagePyGObject3[Extension]=".tar.xz";

PackagePyGObject3[Programs]="";
PackagePyGObject3[Libraries]="";
PackagePyGObject3[Python]="/usr/lib/python3.13/site-packages/gi/_gi{,_cairo}.cpython-313-<arch>-linux-gnu.so";

InstallPyGObject3()
{
	# Check Installation
	EchoInfo	"${PackagePyGObject3[Name]}> manually check PackagePyGObject3[Python]" && PressAnyKeyToContinue;
	CheckPyGObject3 && return $?;

	# Check Dependencies
	Required=(GLib)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(PyCairo)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Pep8 Pyflakes Pytest)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"Package ${PackagePyGObject3[Name]}"
	_ExtractPackagePyGObject3 || return $?;
	_BuildPyGObject3;
	return $?
}

CheckPyGObject3()
{
	CheckInstallation 	"${PackagePyGObject3[Programs]}"\
						"${PackagePyGObject3[Libraries]}"\
						"${PackagePyGObject3[Python]}" 1> /dev/null;
	return $?;
}

CheckPyGObject3Verbose()
{
	CheckInstallationVerbose	"${PackagePyGObject3[Programs]}"\
								"${PackagePyGObject3[Libraries]}"\
								"${PackagePyGObject3[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackagePyGObject3()
{
	DownloadPackage	"${PackagePyGObject3[Source]}"	"${SHMAN_PDIR}"	"${PackagePyGObject3[Package]}${PackagePyGObject3[Extension]}"	"${PackagePyGObject3[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackagePyGObject3[Package]}"	"${PackagePyGObject3[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildPyGObject3()
{
	if ! cd "${SHMAN_PDIR}${PackagePyGObject3[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackagePyGObject3[Package]}";
		return 1;
	fi

	EchoInfo	"${PackagePyGObject3[Name]}> Remove two faulty tests"
	mv -v tests/test_gdbus.py{,.nouse}         &&
	mv -v tests/test_overrides_gtk.py{,.nouse}

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackagePyGObject3[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackagePyGObject3[Package]}/build";

	EchoInfo	"${PackagePyGObject3[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackagePyGObject3[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePyGObject3[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackagePyGObject3[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePyGObject3[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackagePyGObject3[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackagePyGObject3[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackagePyGObject3[Name]} && PressAnyKeyToContinue; return 1; };
}
