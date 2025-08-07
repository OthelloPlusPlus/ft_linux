#!/bin/bash

if [ ! -z "${PackageModemManager[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									ModemManager								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageModemManager;
# Manual
PackageModemManager[Source]="https://www.freedesktop.org/software/ModemManager/ModemManager-1.18.12.tar.xz";
PackageModemManager[MD5]="9f014dfc59f1bd8bc230bb2c2974d104";
# Automated unless edgecase
PackageModemManager[Name]="";
PackageModemManager[Version]="";
PackageModemManager[Extension]="";
if [[ -n "${PackageModemManager[Source]}" ]]; then
	filename="${PackageModemManager[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageModemManager[Name]}" ]] && PackageModemManager[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageModemManager[Version]}" ]] && PackageModemManager[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageModemManager[Extension]}" ]] && PackageModemManager[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageModemManager[Package]="${PackageModemManager[Name]}-${PackageModemManager[Version]}";

PackageModemManager[Programs]="mmcli ModemManager";
PackageModemManager[Libraries]="libmm-glib.so";
PackageModemManager[Python]="";

InstallModemManager()
{
	# Check Installation
	CheckModemManager && return $?;

	# Check Dependencies
	EchoInfo	"${PackageModemManager[Name]}> Checking dependencies..."
	Required=(LibGudev)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Elogind GLib LibMbim LibQmi Polkit Vala)
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(GTKDoc)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageModemManager[Name]}> Building package..."
	_ExtractPackageModemManager || return $?;
	_BuildModemManager;
	return $?
}

CheckModemManager()
{
	CheckInstallation 	"${PackageModemManager[Programs]}"\
						"${PackageModemManager[Libraries]}"\
						"${PackageModemManager[Python]}" 1> /dev/null;
	return $?;
}

CheckModemManagerVerbose()
{
	CheckInstallationVerbose	"${PackageModemManager[Programs]}"\
								"${PackageModemManager[Libraries]}"\
								"${PackageModemManager[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageModemManager()
{
	DownloadPackage	"${PackageModemManager[Source]}"	"${SHMAN_PDIR}"	"${PackageModemManager[Package]}${PackageModemManager[Extension]}"	"${PackageModemManager[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageModemManager[Package]}"	"${PackageModemManager[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildModemManager()
{
	if ! cd "${SHMAN_PDIR}${PackageModemManager[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageModemManager[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageModemManager[Package]}/build \
	# 				|| { EchoError "${PackageModemManager[Name]}> Failed to enter ${SHMAN_PDIR}${PackageModemManager[Package]}/build"; return 1; }

	EchoInfo	"${PackageModemManager[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--localstatedir=/var \
				--disable-static \
				--disable-maintainer-mode \
				--with-systemd-journal=no \
				--with-systemd-suspend-resume \
				--without-mbim \
				--without-qmi \
				1> /dev/null || { EchoTest KO ${PackageModemManager[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageModemManager[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageModemManager[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageModemManager[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageModemManager[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageModemManager[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageModemManager[Name]} && PressAnyKeyToContinue; return 1; };
}
