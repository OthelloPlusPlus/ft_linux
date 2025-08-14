#!/bin/bash

if [ ! -z "${PackageLibPng[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibPng								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibPng;
PackageLibPng[Source]="https://downloads.sourceforge.net/libpng/libpng-1.6.46.tar.xz";
PackageLibPng[MD5]="2ba00adb5d5c76d512486559a3e77be7";
PackageLibPng[Name]="libpng";
PackageLibPng[Version]="1.6.46";
PackageLibPng[Package]="${PackageLibPng[Name]}-${PackageLibPng[Version]}";
PackageLibPng[Extension]=".tar.xz";

PackageLibPng[Programs]="libpng-config libpng16-config pngfix png-fix-itxt";
PackageLibPng[Libraries]="libpng.so";
PackageLibPng[Python]="";

InstallLibPng()
{
	# Check Installation
	CheckLibPng && return $?;

	EchoInfo	"${PackageLibPng[Name]}> Checking dependencies..."

	# Check Dependencies
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=()
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
	EchoInfo	"${PackageLibPng[Name]}> Building package..."
	_ExtractPackageLibPng || return $?;
	_BuildLibPng;
	return $?
}

CheckLibPng()
{
	CheckInstallation 	"${PackageLibPng[Programs]}"\
						"${PackageLibPng[Libraries]}"\
						"${PackageLibPng[Python]}" 1> /dev/null;
	return $?;
}

CheckLibPngVerbose()
{
	CheckInstallationVerbose	"${PackageLibPng[Programs]}"\
								"${PackageLibPng[Libraries]}"\
								"${PackageLibPng[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibPng()
{
	DownloadPackage	"${PackageLibPng[Source]}"	"${SHMAN_PDIR}"	"${PackageLibPng[Package]}${PackageLibPng[Extension]}"	"${PackageLibPng[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibPng[Package]}"	"${PackageLibPng[Extension]}" || return $?;

	wget -P "${SHMAN_PDIR}" "https://downloads.sourceforge.net/sourceforge/libpng-apng/libpng-1.6.46-apng.patch.gz";

	return $?;
}

_BuildLibPng()
{
	if ! cd "${SHMAN_PDIR}${PackageLibPng[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibPng[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibPng[Name]}> Patching"
	gzip -cd ../libpng-1.6.46-apng.patch.gz | patch -p1

	EchoInfo	"${PackageLibPng[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageLibPng[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibPng[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibPng[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibPng[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibPng[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibPng[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibPng[Name]} && PressAnyKeyToContinue; return 1; };

	mkdir -v /usr/share/doc/libpng-1.6.46
	cp -v README libpng-manual.txt /usr/share/doc/libpng-1.6.46
}
