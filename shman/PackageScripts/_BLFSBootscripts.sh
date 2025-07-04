#!/bin/bash

if [ ! -z "${PackageBLFSBootscripts[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									BLFSBootscripts								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageBLFSBootscripts;
PackageBLFSBootscripts[Source]="https://anduin.linuxfromscratch.org/BLFS/blfs-bootscripts/blfs-bootscripts-20250225.tar.xz";
# PackageBLFSBootscripts[MD5]="";
PackageBLFSBootscripts[Name]="blfs-bootscripts";
PackageBLFSBootscripts[Version]="20250225";
PackageBLFSBootscripts[Package]="${PackageBLFSBootscripts[Name]}-${PackageBLFSBootscripts[Version]}";
PackageBLFSBootscripts[Extension]=".tar.xz";

if [ ! -d "${SHMAN_PDIR}${PackageBLFSBootscripts[Package]}" ]; then
	if [ ! -f "${SHMAN_PDIR}${PackageBLFSBootscripts[Package]}${PackageBLFSBootscripts[Extension]}" ]; then
		DownloadPackage	"${PackageBLFSBootscripts[Source]}"	"${SHMAN_PDIR}"	"${PackageBLFSBootscripts[Package]}${PackageBLFSBootscripts[Extension]}"	"${PackageBLFSBootscripts[MD5]}";
	fi
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageBLFSBootscripts[Package]}"	"${PackageBLFSBootscripts[Extension]}";
fi

BootScriptDbus()
{
	cd "${SHMAN_PDIR}${PackageBLFSBootscripts[Package]}";

	make install-dbus

	/etc/init.d/dbus start
}

BootScriptUnbound()
{
	cd "${SHMAN_PDIR}${PackageBLFSBootscripts[Package]}";

	make install-unbound
}