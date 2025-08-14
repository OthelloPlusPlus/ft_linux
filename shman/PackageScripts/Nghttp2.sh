#!/bin/bash

if [ ! -z "${PackageNghttp2[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Nghttp2									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageNghttp2;
PackageNghttp2[Source]="https://github.com/nghttp2/nghttp2/releases/download/v1.64.0/nghttp2-1.64.0.tar.xz";
PackageNghttp2[MD5]="0cf8f819f4b717de7dde9f8164d0b466";
PackageNghttp2[Name]="nghttp2";
PackageNghttp2[Version]="1.64.0";
PackageNghttp2[Package]="${PackageNghttp2[Name]}-${PackageNghttp2[Version]}";
PackageNghttp2[Extension]=".tar.xz";

PackageNghttp2[Programs]="";
PackageNghttp2[Libraries]="libnghttp2.so";
PackageNghttp2[Python]="";

InstallNghttp2()
{
	# Check Installation
	CheckNghttp2 && return $?;

	# Check Dependencies
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(LibXml2)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Boost CAres Cython Jansson LibEvent Sphinx)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"Package ${PackageNghttp2[Name]}"
	_ExtractPackageNghttp2 || return $?;
	_BuildNghttp2;
	return $?
}

CheckNghttp2()
{
	CheckInstallation 	"${PackageNghttp2[Programs]}"\
						"${PackageNghttp2[Libraries]}"\
						"${PackageNghttp2[Python]}" 1> /dev/null;
	return $?;
}

CheckNghttp2Verbose()
{
	CheckInstallationVerbose	"${PackageNghttp2[Programs]}"\
								"${PackageNghttp2[Libraries]}"\
								"${PackageNghttp2[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageNghttp2()
{
	DownloadPackage	"${PackageNghttp2[Source]}"	"${SHMAN_PDIR}"	"${PackageNghttp2[Package]}${PackageNghttp2[Extension]}"	"${PackageNghttp2[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageNghttp2[Package]}"	"${PackageNghttp2[Extension]}" || return $?;

	return $?;
}

_BuildNghttp2()
{
	if ! cd "${SHMAN_PDIR}${PackageNghttp2[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageNghttp2[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageNghttp2[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--enable-lib-only \
				--docdir=/usr/share/doc/nghttp2-1.64.0 \
				1> /dev/null || { EchoTest KO ${PackageNghttp2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNghttp2[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageNghttp2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNghttp2[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageNghttp2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNghttp2[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageNghttp2[Name]} && PressAnyKeyToContinue; return 1; };
}
