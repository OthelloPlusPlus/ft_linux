#!/bin/bash

if [ ! -z "${PackageUDisks[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									UDisks								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageUDisks;
# Manual
PackageUDisks[Source]="https://github.com/storaged-project/udisks/releases/download/udisks-2.10.1/udisks-2.10.1.tar.bz2";
PackageUDisks[MD5]="613af9bfea52cde74d2ac34d96de544d";
# Automated unless edgecase
PackageUDisks[Name]="";
PackageUDisks[Version]="";
PackageUDisks[Extension]="";
if [[ -n "${PackageUDisks[Source]}" ]]; then
	filename="${PackageUDisks[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageUDisks[Name]}" ]] && PackageUDisks[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageUDisks[Version]}" ]] && PackageUDisks[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageUDisks[Extension]}" ]] && PackageUDisks[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageUDisks[Package]="${PackageUDisks[Name]}-${PackageUDisks[Version]}";

PackageUDisks[Programs]="udisksctl umount.udisks2";
PackageUDisks[Libraries]="libudisks2.so";
PackageUDisks[Python]="";

InstallUDisks()
{
	# Check Installation
	CheckUDisks && return $?;

	# Check Dependencies
	EchoInfo	"${PackageUDisks[Name]}> Checking dependencies..."
	Required=(LibAtasmart LibBlockdev LibGudev Polkit GLib)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageUDisks[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Elogind)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageUDisks[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(GTKDoc LibXslt LVM2)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageUDisks[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageUDisks[Name]}> Building package..."
	_ExtractPackageUDisks || return $?;
	_BuildUDisks || return $?;

	RunTime=(BtrfsProgs Dbus Dosfstools Gptfdisk Mdadm Xfsprogs)
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageUDisks[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}")
	done

	return $?
}

CheckUDisks()
{
	CheckInstallation 	"${PackageUDisks[Programs]}"\
						"${PackageUDisks[Libraries]}"\
						"${PackageUDisks[Python]}" 1> /dev/null;
	return $?;
}

CheckUDisksVerbose()
{
	CheckInstallationVerbose	"${PackageUDisks[Programs]}"\
								"${PackageUDisks[Libraries]}"\
								"${PackageUDisks[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageUDisks()
{
	DownloadPackage	"${PackageUDisks[Source]}"	"${SHMAN_PDIR}"	"${PackageUDisks[Package]}${PackageUDisks[Extension]}"	"${PackageUDisks[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageUDisks[Package]}"	"${PackageUDisks[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildUDisks()
{
	if ! cd "${SHMAN_PDIR}${PackageUDisks[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageUDisks[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageUDisks[Package]}/build \
	# 				|| { EchoError "${PackageUDisks[Name]}> Failed to enter ${SHMAN_PDIR}${PackageUDisks[Package]}/build"; return 1; }

	EchoInfo	"${PackageUDisks[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--localstatedir=/var \
				--disable-static \
				--enable-available-modules \
				1> /dev/null || { EchoTest KO ${PackageUDisks[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageUDisks[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageUDisks[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageUDisks[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageUDisks[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageUDisks[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageUDisks[Name]} && PressAnyKeyToContinue; return 1; };
}
