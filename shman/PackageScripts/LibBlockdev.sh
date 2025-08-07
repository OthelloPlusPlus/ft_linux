#!/bin/bash

if [ ! -z "${PackageLibBlockdev[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibBlockdev								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibBlockdev;
# Manual
PackageLibBlockdev[Source]="https://github.com/storaged-project/libblockdev/releases/download/3.3.0/libblockdev-3.3.0.tar.gz";
PackageLibBlockdev[MD5]="06a80f510fcea4412afe9e0bd4ac2187";
# Automated unless edgecase
PackageLibBlockdev[Name]="";
PackageLibBlockdev[Version]="";
PackageLibBlockdev[Extension]="";
if [[ -n "${PackageLibBlockdev[Source]}" ]]; then
	filename="${PackageLibBlockdev[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibBlockdev[Name]}" ]] && PackageLibBlockdev[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibBlockdev[Version]}" ]] && PackageLibBlockdev[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibBlockdev[Extension]}" ]] && PackageLibBlockdev[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibBlockdev[Package]="${PackageLibBlockdev[Name]}-${PackageLibBlockdev[Version]}";

PackageLibBlockdev[Programs]="";
PackageLibBlockdev[Libraries]="libbd_btrfs.so libbd_crypto.so libbd_dm.so libbd_fs.so libbd_loop.so libbd_mdraid.so libbd_mpath.so libbd_nvme.so libbd_part.so libbd_swap.so libbd_utils.so libblockdev.so";
PackageLibBlockdev[Python]="";

InstallLibBlockdev()
{
	# Check Installation
	CheckLibBlockdev && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibBlockdev[Name]}> Checking dependencies..."
	Required=(GLib)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageLibBlockdev[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Cryptsetup Keyutils LibAtasmart LibBytesize LibNvme LVM2)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageLibBlockdev[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(BtrfsProgs GTKDoc JSONGLib Mdadm Parted SmartMontools)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageLibBlockdev[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibBlockdev[Name]}> Building package..."
	_ExtractPackageLibBlockdev || return $?;
	_BuildLibBlockdev || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageLibBlockdev[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckLibBlockdev()
{
	CheckInstallation 	"${PackageLibBlockdev[Programs]}"\
						"${PackageLibBlockdev[Libraries]}"\
						"${PackageLibBlockdev[Python]}" 1> /dev/null;
	return $?;
}

CheckLibBlockdevVerbose()
{
	CheckInstallationVerbose	"${PackageLibBlockdev[Programs]}"\
								"${PackageLibBlockdev[Libraries]}"\
								"${PackageLibBlockdev[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibBlockdev()
{
	DownloadPackage	"${PackageLibBlockdev[Source]}"	"${SHMAN_PDIR}"	"${PackageLibBlockdev[Package]}${PackageLibBlockdev[Extension]}"	"${PackageLibBlockdev[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibBlockdev[Package]}"	"${PackageLibBlockdev[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibBlockdev()
{
	if ! cd "${SHMAN_PDIR}${PackageLibBlockdev[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibBlockdev[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibBlockdev[Package]}/build \
	# 				|| { EchoError "${PackageLibBlockdev[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibBlockdev[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibBlockdev[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageLibBlockdev[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibBlockdev[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibBlockdev[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibBlockdev[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibBlockdev[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibBlockdev[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibBlockdev[Name]} && PressAnyKeyToContinue; return 1; };
}
