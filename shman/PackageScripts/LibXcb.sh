#!/bin/bash

if [ ! -z "${PackageLibXcb[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									 LibXcb									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibXcb;
PackageLibXcb[Source]="https://xorg.freedesktop.org/archive/individual/lib/libxcb-1.17.0.tar.xz";
PackageLibXcb[MD5]="96565523e9f9b701fcb35d31f1d4086e";
PackageLibXcb[Name]="libxcb";
PackageLibXcb[Version]="1.17.0";
PackageLibXcb[Package]="${PackageLibXcb[Name]}-${PackageLibXcb[Version]}";
PackageLibXcb[Extension]=".tar.xz";

PackageLibXcb[Programs]="";
PackageLibXcb[Libraries]="libxcb.so libxcb-composite.so libxcb-damage.so libxcb-dbe.so libxcb-dpms.so libxcb-dri2.so libxcb-dri3.so libxcb-glx.so libxcb-present.so libxcb-randr.so libxcb-record.so libxcb-render.so libxcb-res.so libxcb-screensaver.so libxcb-shape.so libxcb-shm.so libxcb-sync.so libxcb-xf86dri.so libxcb-xfixes.so libxcb-xinerama.so libxcb-xinput.so libxcb-xkb.so libxcb-xtest.so libxcb-xvmc.so libxcb-xv.so";
PackageLibXcb[Python]="";

InstallLibXcb()
{
	# Check Installation
	CheckLibXcb && return $?;

	# Check Dependencies
	Dependencies=(LibXau XcbProto)
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=(LibXdmcp)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	Optional=(LibXslt)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
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

_BuildLibXcb()
{
	EchoInfo	"Package ${PackageLibXcb[Name]}"

	DownloadPackage	"${PackageLibXcb[Source]}"	"${SHMAN_PDIR}"	"${PackageLibXcb[Package]}${PackageLibXcb[Extension]}"	"${PackageLibXcb[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibXcb[Package]}"	"${PackageLibXcb[Extension]}";
	# wget -P "${SHMAN_PDIR}" "";

	if ! cd "${SHMAN_PDIR}${PackageLibXcb[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibXcb[Package]}";
		return 1;
	fi

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

	EchoInfo	"${PackageLibXcb[Name]}> Ensure root ownership"
	chown -Rv root:root $XORG_PREFIX/share/doc/libxcb-1.17.0
}
