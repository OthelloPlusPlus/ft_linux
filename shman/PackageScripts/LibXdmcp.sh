#!/bin/bash

if [ ! -z "${PackageLibXdmcp[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibXdmcp								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibXdmcp;
PackageLibXdmcp[Source]="https://xorg.freedesktop.org/archive/individual/lib/libxcb-1.17.0.tar.xz";
PackageLibXdmcp[MD5]="96565523e9f9b701fcb35d31f1d4086e";
PackageLibXdmcp[Name]="libxcb";
PackageLibXdmcp[Version]="1.17.0";
PackageLibXdmcp[Package]="${PackageLibXdmcp[Name]}-${PackageLibXdmcp[Version]}";
PackageLibXdmcp[Extension]=".tar.xz";

PackageLibXdmcp[Programs]="";
PackageLibXdmcp[Libraries]="libxcb.so libxcb-composite.so libxcb-damage.so libxcb-dbe.so libxcb-dpms.so libxcb-dri2.so libxcb-dri3.so libxcb-glx.so libxcb-present.so libxcb-randr.so libxcb-record.so libxcb-render.so libxcb-res.so libxcb-screensaver.so libxcb-shape.so libxcb-shm.so libxcb-sync.so libxcb-xf86dri.so libxcb-xfixes.so libxcb-xinerama.so libxcb-xinput.so libxcb-xkb.so libxcb-xtest.so libxcb-xvmc.so libxcb-xv.so";
PackageLibXdmcp[Python]="";

InstallLibXdmcp()
{
	# Check Installation
	CheckLibXdmcp && return $?;

	# Check Dependencies
	Dependencies=(Xorgproto)
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=()
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
	_BuildLibXdmcp;
	return $?
}

CheckLibXdmcp()
{
	CheckInstallation 	"${PackageLibXdmcp[Programs]}"\
						"${PackageLibXdmcp[Libraries]}"\
						"${PackageLibXdmcp[Python]}" 1> /dev/null;
	return $?;
}

CheckLibXdmcpVerbose()
{
	CheckInstallationVerbose	"${PackageLibXdmcp[Programs]}"\
								"${PackageLibXdmcp[Libraries]}"\
								"${PackageLibXdmcp[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildLibXdmcp()
{
	EchoInfo	"Package ${PackageLibXdmcp[Name]}"

	DownloadPackage	"${PackageLibXdmcp[Source]}"	"${SHMAN_PDIR}"	"${PackageLibXdmcp[Package]}${PackageLibXdmcp[Extension]}"	"${PackageLibXdmcp[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibXdmcp[Package]}"	"${PackageLibXdmcp[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageLibXdmcp[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibXdmcp[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibXdmcp[Name]}> Configure"
	./configure $XORG_CONFIG \
				--docdir=/usr/share/doc/libXdmcp-1.1.5 \
				1> /dev/null || { EchoTest KO ${PackageLibXdmcp[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXdmcp[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibXdmcp[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXdmcp[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibXdmcp[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLibXdmcp[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibXdmcp[Name]} && PressAnyKeyToContinue; return 1; };
}
