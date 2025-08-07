#!/bin/bash

if [ ! -z "${PackageLibJpegTurbo[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibJpegTurbo								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibJpegTurbo;
PackageLibJpegTurbo[Source]="https://downloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-3.0.1.tar.gz";
PackageLibJpegTurbo[MD5]="1fdc6494521a8724f5f7cf39b0f6aff3";
PackageLibJpegTurbo[Name]="libjpeg-turbo";
PackageLibJpegTurbo[Version]="3.0.1";
PackageLibJpegTurbo[Package]="${PackageLibJpegTurbo[Name]}-${PackageLibJpegTurbo[Version]}";
PackageLibJpegTurbo[Extension]=".tar.gz";

PackageLibJpegTurbo[Programs]="cjpeg djpeg jpegtran rdjpgcom tjbench wrjpgcom";
PackageLibJpegTurbo[Libraries]="libjpeg.so libturbojpeg.so";
PackageLibJpegTurbo[Python]="";

InstallLibJpegTurbo()
{
	# Check Installation
	CheckLibJpegTurbo && return $?;

	# Check Dependencies
	Required=(CMake)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=(NASM Yasm)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh"
		fi
	done

	# Install Package
	EchoInfo	"Package ${PackageLibJpegTurbo[Name]}"
	_ExtractPackageLibJpegTurbo || return $?;
	_BuildLibJpegTurbo;
	return $?
}

CheckLibJpegTurbo()
{
	CheckInstallation 	"${PackageLibJpegTurbo[Programs]}"\
						"${PackageLibJpegTurbo[Libraries]}"\
						"${PackageLibJpegTurbo[Python]}" 1> /dev/null;
	return $?;
}

CheckLibJpegTurboVerbose()
{
	CheckInstallationVerbose	"${PackageLibJpegTurbo[Programs]}"\
								"${PackageLibJpegTurbo[Libraries]}"\
								"${PackageLibJpegTurbo[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibJpegTurbo()
{
	DownloadPackage	"${PackageLibJpegTurbo[Source]}"	"${SHMAN_PDIR}"	"${PackageLibJpegTurbo[Package]}${PackageLibJpegTurbo[Extension]}"	"${PackageLibJpegTurbo[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibJpegTurbo[Package]}"	"${PackageLibJpegTurbo[Extension]}" || return $?;

	return $?;
}

_BuildLibJpegTurbo()
{
	if ! cd "${SHMAN_PDIR}${PackageLibJpegTurbo[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibJpegTurbo[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageLibJpegTurbo[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageLibJpegTurbo[Package]}/build";

	EchoInfo	"${PackageLibJpegTurbo[Name]}> Configure"
	cmake -D CMAKE_INSTALL_PREFIX=/usr \
			-D CMAKE_BUILD_TYPE=RELEASE \
			-D ENABLE_STATIC=FALSE \
			-D CMAKE_INSTALL_DEFAULT_LIBDIR=lib \
			-D CMAKE_SKIP_INSTALL_RPATH=ON \
			-D CMAKE_INSTALL_DOCDIR=/usr/share/doc/libjpeg-turbo-3.0.1 \
			.. \
			1> /dev/null || { EchoTest KO ${PackageLibJpegTurbo[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibJpegTurbo[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibJpegTurbo[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibJpegTurbo[Name]}> make test"
	make test 1> /dev/null || { EchoTest KO ${PackageLibJpegTurbo[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibJpegTurbo[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibJpegTurbo[Name]} && PressAnyKeyToContinue; return 1; };
}
