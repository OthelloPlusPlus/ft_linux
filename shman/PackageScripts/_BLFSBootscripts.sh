#!/bin/bash

if [ ! -z "${PackageBLFSBootscripts[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

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

BootScriptGDM()
{
	cd "${SHMAN_PDIR}${PackageBLFSBootscripts[Package]}";


	EchoInfo	"${PackageBLFSBootscripts[Name]}> Installing GDM"
	make install-gdm
	sed /initdefault/s/3/5/ -i /etc/inittab

	# EchoInfo	"${PackageBLFSBootscripts[Name]}> Disabling screen suspension"
	# su gdm -s /bin/bash \
	# 		-c "dbus-run-session \
	# 				gsettings set org.gnome.settings-daemon.plugins.power \
	# 							sleep-inactive-ac-type \
	# 							nothing"
}

BootScriptAt()
{
	cd "${SHMAN_PDIR}${PackageBLFSBootscripts[Package]}";

	make install-atd
}

BootScriptFcron()
{
	cd "${SHMAN_PDIR}${PackageBLFSBootscripts[Package]}";

	make install-fcron
}

BootScriptExim()
{
	cd "${SHMAN_PDIR}${PackageBLFSBootscripts[Package]}";

	make install-exim
}
