#!/bin/bash

if [ ! -z "${PackageGnomeSettingsDaemon[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									GnomeSettingsDaemon								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGnomeSettingsDaemon;
PackageGnomeSettingsDaemon[Source]="https://download.gnome.org/sources/gnome-settings-daemon/47/gnome-settings-daemon-47.2.tar.xz";
PackageGnomeSettingsDaemon[MD5]="39babcea9c9eb5fd7809cbc685cd282c";
PackageGnomeSettingsDaemon[Name]="gnome-settings-daemon";
PackageGnomeSettingsDaemon[Version]="47.2";
PackageGnomeSettingsDaemon[Package]="${PackageGnomeSettingsDaemon[Name]}-${PackageGnomeSettingsDaemon[Version]}";
PackageGnomeSettingsDaemon[Extension]=".tar.xz";

PackageGnomeSettingsDaemon[Programs]="";
PackageGnomeSettingsDaemon[Libraries]="libgsd.so";
PackageGnomeSettingsDaemon[Python]="";

InstallGnomeSettingsDaemon()
{
	# Check Installation
	CheckGnomeSettingsDaemon && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGnomeSettingsDaemon[Name]}> Checking dependencies..."
	Required=(AlsaLib Fontconfig Gcr4 GeoClue GeocodeGlib GnomeDesktop LibCanberra LibGweather LibNotify LibWacom PulseAudio UPower)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Colord Cups NetworkManager Nss Wayland Blocaled)
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	# Removed Mutter because circular dependency...
	Optional=(GnomeSession Umockdev)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageGnomeSettingsDaemon[Name]}> Building package..."
	_ExtractPackageGnomeSettingsDaemon || return $?;
	_BuildGnomeSettingsDaemon;
	return $?
}

CheckGnomeSettingsDaemon()
{
	CheckInstallation 	"${PackageGnomeSettingsDaemon[Programs]}"\
						"${PackageGnomeSettingsDaemon[Libraries]}"\
						"${PackageGnomeSettingsDaemon[Python]}" 1> /dev/null;
	return $?;
}

CheckGnomeSettingsDaemonVerbose()
{
	CheckInstallationVerbose	"${PackageGnomeSettingsDaemon[Programs]}"\
								"${PackageGnomeSettingsDaemon[Libraries]}"\
								"${PackageGnomeSettingsDaemon[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGnomeSettingsDaemon()
{
	DownloadPackage	"${PackageGnomeSettingsDaemon[Source]}"	"${SHMAN_PDIR}"	"${PackageGnomeSettingsDaemon[Package]}${PackageGnomeSettingsDaemon[Extension]}"	"${PackageGnomeSettingsDaemon[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGnomeSettingsDaemon[Package]}"	"${PackageGnomeSettingsDaemon[Extension]}" || return $?;

	for URL in \
	# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildGnomeSettingsDaemon()
{
	if ! cd "${SHMAN_PDIR}${PackageGnomeSettingsDaemon[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGnomeSettingsDaemon[Package]}";
		return 1;
	fi

	sed -e 's/libsystemd/libelogind/' \
		-i plugins/power/test.py

	sed -e 's/(backlight->logind_proxy)/(0)/' \
		-i plugins/power/gsd-backlight.c

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGnomeSettingsDaemon[Package]}/build \
					|| { EchoError "${PackageGnomeSettingsDaemon[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGnomeSettingsDaemon[Package]}/build"; return 1; }

	EchoInfo	"${PackageGnomeSettingsDaemon[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D systemd=false \
				.. \
				1> /dev/null || { EchoTest KO ${PackageGnomeSettingsDaemon[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeSettingsDaemon[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGnomeSettingsDaemon[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeSettingsDaemon[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageGnomeSettingsDaemon[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeSettingsDaemon[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGnomeSettingsDaemon[Name]} && PressAnyKeyToContinue; return 1; };
}
