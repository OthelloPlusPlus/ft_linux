#!/bin/bash

if [ ! -z "${PackageLibXcb[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibXcb								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibXcb;
# Manual
PackageLibXcb[Source]="https://xorg.freedesktop.org/archive/individual/lib/libxcb-1.17.0.tar.xz";
PackageLibXcb[MD5]="96565523e9f9b701fcb35d31f1d4086e";
# Automated unless edgecase
PackageLibXcb[Name]="";
PackageLibXcb[Version]="";
PackageLibXcb[Extension]="";
if [[ -n "${PackageLibXcb[Source]}" ]]; then
	filename="${PackageLibXcb[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibXcb[Name]}" ]] && PackageLibXcb[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibXcb[Version]}" ]] && PackageLibXcb[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibXcb[Extension]}" ]] && PackageLibXcb[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibXcb[Package]="${PackageLibXcb[Name]}-${PackageLibXcb[Version]}";

PackageLibXcb[Programs]="";
PackageLibXcb[Libraries]="libxcb.so libxcb-composite.so libxcb-damage.so libxcb-dbe.so libxcb-dpms.so libxcb-dri2.so libxcb-dri3.so libxcb-glx.so libxcb-present.so libxcb-randr.so libxcb-record.so libxcb-render.so libxcb-res.so libxcb-screensaver.so libxcb-shape.so libxcb-shm.so libxcb-sync.so libxcb-xf86dri.so libxcb-xfixes.so libxcb-xinerama.so libxcb-xinput.so libxcb-xkb.so libxcb-xtest.so libxcb-xvmc.so libxcb-xv.so";
PackageLibXcb[Python]="";

InstallLibXcb()
{
	# Check Installation
	CheckLibXcb && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibXcb[Name]}> Checking dependencies..."
	Required=(LibXau XcbProto)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageLibXcb[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(LibXdmcp)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageLibXcb[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Doxygen LibXslt)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageLibXcb[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibXcb[Name]}> Building package..."
	_ExtractPackageLibXcb || return $?;
	_BuildLibXcb;
	return $?
}

CheckLibXcb()
{
	CheckInstallation 	"${PackageLibXcb[Programs]}"\
						"${PackageLibXcb[Libraries]}"\
						"${PackageLibXcb[Python]}" 1> /dev/null;
	return $?;
}

CheckLibXcbVerbose()
{
	CheckInstallationVerbose	"${PackageLibXcb[Programs]}"\
								"${PackageLibXcb[Libraries]}"\
								"${PackageLibXcb[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibXcb()
{
	DownloadPackage	"${PackageLibXcb[Source]}"	"${SHMAN_PDIR}"	"${PackageLibXcb[Package]}${PackageLibXcb[Extension]}"	"${PackageLibXcb[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibXcb[Package]}"	"${PackageLibXcb[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibXcb()
{
	if ! cd "${SHMAN_PDIR}${PackageLibXcb[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibXcb[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibXcb[Package]}/build \
	# 				|| { EchoError "${PackageLibXcb[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibXcb[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibXcb[Name]}> Configure"
	./configure $XORG_CONFIG \
				--without-doxygen \
				--docdir='${datadir}'/doc/libxcb-1.17.0 \
				1> /dev/null || { EchoTest KO ${PackageLibXcb[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXcb[Name]}> LC_ALL=en_US.UTF-8 make"
	LC_ALL=en_US.UTF-8 make 1> /dev/null || { EchoTest KO ${PackageLibXcb[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXcb[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibXcb[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXcb[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibXcb[Name]} && PressAnyKeyToContinue; return 1; };
}
