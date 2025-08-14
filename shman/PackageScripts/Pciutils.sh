#!/bin/bash

if [ ! -z "${PackagePciutils[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Pciutils								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePciutils;
PackagePciutils[Source]="https://mj.ucw.cz/download/linux/pci/pciutils-3.13.0.tar.gz";
PackagePciutils[MD5]="1edb865de7a2de84e67508911010091b";
PackagePciutils[Name]="pciutils";
PackagePciutils[Version]="3.13.0";
PackagePciutils[Package]="${PackagePciutils[Name]}-${PackagePciutils[Version]}";
PackagePciutils[Extension]=".tar.gz";

PackagePciutils[Programs]="lspci pcilmr setpci";
PackagePciutils[Libraries]="libpci.so";
PackagePciutils[Python]="";

InstallPciutils()
{
	# Check Installation
	CheckPciutils && return $?;

	# Check Dependencies
	Required=(Hwdata)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"Package ${PackagePciutils[Name]}"
	_ExtractPackagePciutils || return $?;
	_BuildPciutils || return $?;
	source "${SHMAN_SDIR}/Hwdata.sh" && InstallHwdata
	return $?
}

CheckPciutils()
{
	CheckInstallation 	"${PackagePciutils[Programs]}"\
						"${PackagePciutils[Libraries]}"\
						"${PackagePciutils[Python]}" 1> /dev/null;
	return $?;
}

CheckPciutilsVerbose()
{
	CheckInstallationVerbose	"${PackagePciutils[Programs]}"\
								"${PackagePciutils[Libraries]}"\
								"${PackagePciutils[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackagePciutils()
{
	DownloadPackage	"${PackagePciutils[Source]}"	"${SHMAN_PDIR}"	"${PackagePciutils[Package]}${PackagePciutils[Extension]}"	"${PackagePciutils[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackagePciutils[Package]}"	"${PackagePciutils[Extension]}" || return $?;

	return $?;
}

_BuildPciutils()
{
	if ! cd "${SHMAN_PDIR}${PackagePciutils[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackagePciutils[Package]}";
		return 1;
	fi

	EchoInfo	"${PackagePciutils[Name]}> Prevent installation of pci.ids"
	sed -r '/INSTALL/{/PCI_IDS|update-pciids /d; s/update-pciids.8//}' \
		-i Makefile

	EchoInfo	"${PackagePciutils[Name]}> make"
	make PREFIX=/usr \
			SHAREDIR=/usr/share/hwdata \
			SHARED=yes \
			1> /dev/null || { EchoTest KO ${PackagePciutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePciutils[Name]}> make install install-lib"
	make PREFIX=/usr \
			SHAREDIR=/usr/share/hwdata \
			SHARED=yes \
			install install-lib \
			1> /dev/null || { EchoTest KO ${PackagePciutils[Name]} && PressAnyKeyToContinue; return 1; };
	chmod -v 755 /usr/lib/libpci.so
}
