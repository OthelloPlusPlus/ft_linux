#!/bin/bash

if [ ! -z "${PackageLibXcvt[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibXcvt								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibXcvt;
PackageLibXcvt[Source]="https://www.x.org/pub/individual/lib/libxcvt-0.1.3.tar.xz";
PackageLibXcvt[MD5]="7fb9c51d33a680f724f34da41768b1d0";
PackageLibXcvt[Name]="libxcvt";
PackageLibXcvt[Version]="0.1.3";
PackageLibXcvt[Package]="${PackageLibXcvt[Name]}-${PackageLibXcvt[Version]}";
PackageLibXcvt[Extension]=".tar.xz";

PackageLibXcvt[Programs]="cvt";
PackageLibXcvt[Libraries]="libxcvt.so";
PackageLibXcvt[Python]="";

InstallLibXcvt()
{
	# Check Installation
	CheckLibXcvt && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibXcvt[Name]}> Checking dependencies..."
	Required=(XorgBuildEnv)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageLibXcvt[Name]}> Building package..."
	_ExtractPackageLibXcvt || return $?;
	_BuildLibXcvt;
	return $?
}

CheckLibXcvt()
{
	CheckInstallation 	"${PackageLibXcvt[Programs]}"\
						"${PackageLibXcvt[Libraries]}"\
						"${PackageLibXcvt[Python]}" 1> /dev/null;
	return $?;
}

CheckLibXcvtVerbose()
{
	CheckInstallationVerbose	"${PackageLibXcvt[Programs]}"\
								"${PackageLibXcvt[Libraries]}"\
								"${PackageLibXcvt[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibXcvt()
{
	DownloadPackage	"${PackageLibXcvt[Source]}"	"${SHMAN_PDIR}"	"${PackageLibXcvt[Package]}${PackageLibXcvt[Extension]}"	"${PackageLibXcvt[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibXcvt[Package]}"	"${PackageLibXcvt[Extension]}" || return $?;

	for URL in \
	# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibXcvt()
{
	if ! cd "${SHMAN_PDIR}${PackageLibXcvt[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibXcvt[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibXcvt[Package]}/build \
					|| { EchoError "${PackageLibXcvt[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibXcvt[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibXcvt[Name]}> Configure"
	meson setup --prefix=$XORG_PREFIX \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageLibXcvt[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXcvt[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibXcvt[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXcvt[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibXcvt[Name]} && PressAnyKeyToContinue; return 1; };
}
