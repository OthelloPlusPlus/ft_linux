#!/bin/bash

if [ ! -z "${PackageNetworkManager[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									NetworkManager								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageNetworkManager;
# Manual
PackageNetworkManager[Source]="https://download.gnome.org/sources/NetworkManager/1.50/NetworkManager-1.50.0.tar.xz";
PackageNetworkManager[MD5]="3a95e6ddade18d9a1abb0b86d2b14a36";
# Automated unless edgecase
PackageNetworkManager[Name]="";
PackageNetworkManager[Version]="";
PackageNetworkManager[Extension]="";
if [[ -n "${PackageNetworkManager[Source]}" ]]; then
	filename="${PackageNetworkManager[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageNetworkManager[Name]}" ]] && PackageNetworkManager[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageNetworkManager[Version]}" ]] && PackageNetworkManager[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageNetworkManager[Extension]}" ]] && PackageNetworkManager[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageNetworkManager[Package]="${PackageNetworkManager[Name]}-${PackageNetworkManager[Version]}";

PackageNetworkManager[Programs]="NetworkManager nmcli nm-online";
PackageNetworkManager[Libraries]="libnm.so";
PackageNetworkManager[Python]="";

InstallNetworkManager()
{
	# Check Installation
	CheckNetworkManager && return $?;

	# Check Dependencies
	EchoInfo	"${PackageNetworkManager[Name]}> Checking dependencies..."
	Required=(LibNdp)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	# cURL Dhcpcd GLib Iptables LibPsl Newt Nss Polkit Elogind Vala WpaSupliccant
	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	# BlueZ GnuTLS GTKDoc Jansson  UPower Valgrind
	Optional=(ModemManager)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageNetworkManager[Name]}> Building package..."
	_ExtractPackageNetworkManager || return $?;
	_BuildNetworkManager;
	return $?
}

CheckNetworkManager()
{
	CheckInstallation 	"${PackageNetworkManager[Programs]}"\
						"${PackageNetworkManager[Libraries]}"\
						"${PackageNetworkManager[Python]}" 1> /dev/null;
	return $?;
}

CheckNetworkManagerVerbose()
{
	CheckInstallationVerbose	"${PackageNetworkManager[Programs]}"\
								"${PackageNetworkManager[Libraries]}"\
								"${PackageNetworkManager[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageNetworkManager()
{
	DownloadPackage	"${PackageNetworkManager[Source]}"	"${SHMAN_PDIR}"	"${PackageNetworkManager[Package]}${PackageNetworkManager[Extension]}"	"${PackageNetworkManager[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageNetworkManager[Package]}"	"${PackageNetworkManager[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildNetworkManager()
{
	if ! cd "${SHMAN_PDIR}${PackageNetworkManager[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageNetworkManager[Package]}";
		return 1;
	fi

	grep -rl '^#!.*python$' | xargs sed -i '1s/python/&3/'

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageNetworkManager[Package]}/build \
					|| { EchoError "${PackageNetworkManager[Name]}> Failed to enter ${SHMAN_PDIR}${PackageNetworkManager[Package]}/build"; return 1; }

	EchoInfo	"${PackageNetworkManager[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D libaudit=no \
				-D ovs=false \
				-D ppp=false \
				-D selinux=false \
				-D session_tracking=elogind \
				-D modem_manager=false \
				-D systemdsystemunitdir=no \
				-D systemd_journal=false \
				-D qt=false \
				-D nmtui=false \
				1> /dev/null || { EchoTest KO ${PackageNetworkManager[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNetworkManager[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageNetworkManager[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageNetworkManager[Name]}> ninja test"
	# ninja test 1> /dev/null || { EchoTest KO ${PackageNetworkManager[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNetworkManager[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageNetworkManager[Name]} && PressAnyKeyToContinue; return 1; };
	mv -v /usr/share/doc/NetworkManager{,-1.50.0}
}
