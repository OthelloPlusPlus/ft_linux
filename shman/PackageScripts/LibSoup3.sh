#!/bin/bash

if [ ! -z "${PackageLibSoup3[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibSoup3								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibSoup3;
PackageLibSoup3[Source]="https://download.gnome.org/sources/libsoup/3.6/libsoup-3.6.4.tar.xz";
PackageLibSoup3[MD5]="b42bfcd87a78b82272d2004976e10766";
PackageLibSoup3[Name]="libsoup";
PackageLibSoup3[Version]="3.6.4";
PackageLibSoup3[Package]="${PackageLibSoup3[Name]}-${PackageLibSoup3[Version]}";
PackageLibSoup3[Extension]=".tar.xz";

PackageLibSoup3[Programs]="";
PackageLibSoup3[Libraries]="libsoup-3.0.so";
PackageLibSoup3[Python]="";

InstallLibSoup3()
{
	# Check Installation
	CheckLibSoup3 && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibSoup3[Name]}3> Checking dependencies..."
	Required=(GLibNetworking LibPsl LibXml2 Nghttp2 SQLite)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GLib Vala)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Apache Brotli cUrl GiDocGen MITKerberos PHP Samba)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibSoup3[Name]}3> Building package..."
	_ExtractPackageLibSoup3 || return $?;
	_BuildLibSoup3;
	return $?
}

CheckLibSoup3()
{
	CheckInstallation 	"${PackageLibSoup3[Programs]}"\
						"${PackageLibSoup3[Libraries]}"\
						"${PackageLibSoup3[Python]}" 1> /dev/null;
	return $?;
}

CheckLibSoup3Verbose()
{
	CheckInstallationVerbose	"${PackageLibSoup3[Programs]}"\
								"${PackageLibSoup3[Libraries]}"\
								"${PackageLibSoup3[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibSoup3()
{
	DownloadPackage	"${PackageLibSoup3[Source]}"	"${SHMAN_PDIR}"	"${PackageLibSoup3[Package]}${PackageLibSoup3[Extension]}"	"${PackageLibSoup3[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibSoup3[Package]}"	"${PackageLibSoup3[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildLibSoup3()
{
	if ! cd "${SHMAN_PDIR}${PackageLibSoup3[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibSoup3[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibSoup3[Name]}3> Fix documentation"
	sed 's/apiversion/soup_version/' -i docs/reference/meson.build

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibSoup3[Package]}/build \
					|| { EchoError "${PackageLibSoup3[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibSoup3[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibSoup3[Name]}3> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				--wrap-mode=nofallback \
				.. \
				1> /dev/null || { EchoTest KO ${PackageLibSoup3[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibSoup3[Name]}3> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibSoup3[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibSoup3[Name]}3> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageLibSoup3[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibSoup3[Name]}3> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibSoup3[Name]} && PressAnyKeyToContinue; return 1; };
}
