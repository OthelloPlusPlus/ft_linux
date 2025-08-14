#!/bin/bash

if [ ! -z "${PackageLibEi[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibEi								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibEi;
PackageLibEi[Source]="https://gitlab.freedesktop.org/libinput/libei/-/archive/1.3.0/libei-1.3.0.tar.gz";
PackageLibEi[MD5]="aeaffcb5afb5ad0bb9981eb93c4cd610";
PackageLibEi[Name]="libei";
PackageLibEi[Version]="1.3.0";
PackageLibEi[Package]="${PackageLibEi[Name]}-${PackageLibEi[Version]}";
PackageLibEi[Extension]=".tar.gz";

PackageLibEi[Programs]="";
PackageLibEi[Libraries]="libei.so libeis.so liboeffis.so";
PackageLibEi[Python]="";

InstallLibEi()
{
	# Check Installation
	CheckLibEi && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibEi[Name]}> Checking dependencies..."
	Required=(Elogind)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(LibEvdev LibXbcommon LiXml2)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibEi[Name]}> Building package..."
	_ExtractPackageLibEi || return $?;
	_BuildLibEi;
	return $?
}

CheckLibEi()
{
	CheckInstallation 	"${PackageLibEi[Programs]}"\
						"${PackageLibEi[Libraries]}"\
						"${PackageLibEi[Python]}" 1> /dev/null;
	return $?;
}

CheckLibEiVerbose()
{
	CheckInstallationVerbose	"${PackageLibEi[Programs]}"\
								"${PackageLibEi[Libraries]}"\
								"${PackageLibEi[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibEi()
{
	DownloadPackage	"${PackageLibEi[Source]}"	"${SHMAN_PDIR}"	"${PackageLibEi[Package]}${PackageLibEi[Extension]}"	"${PackageLibEi[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibEi[Package]}"	"${PackageLibEi[Extension]}" || return $?;

	for URL in \
	# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibEi()
{
	if ! cd "${SHMAN_PDIR}${PackageLibEi[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibEi[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibEi[Package]}/build \
					|| { EchoError "${PackageLibEi[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibEi[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibEi[Name]}> Configure"
	# EchoInfo "might require .. \\ for meson setup" && PressAnyKeyToContinue;
	meson setup --prefix=/usr \
				--buildtype=release \
				-D tests=disabled \
				1> /dev/null || { EchoTest KO ${PackageLibEi[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibEi[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibEi[Name]} && PressAnyKeyToContinue; return 1; };

	# # Requires external depency Munit and structlog
	# EchoInfo	"${PackageLibEi[Name]}> ninja test"
	# meson configure -D tests=enabled .. && \
	# ninja test 1> /dev/null || { EchoTest KO ${PackageLibEi[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibEi[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibEi[Name]} && PressAnyKeyToContinue; return 1; };
}
