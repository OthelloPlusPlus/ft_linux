#!/bin/bash

if [ ! -z "${PackageGnomeSession[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									GnomeSession								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGnomeSession;
PackageGnomeSession[Source]="https://download.gnome.org/sources/gnome-session/47/gnome-session-47.0.1.tar.xz";
PackageGnomeSession[MD5]="b234428ca39e494db57fb88613c71f6f";
PackageGnomeSession[Name]="gnome-session";
PackageGnomeSession[Version]="47.0.1";
PackageGnomeSession[Package]="${PackageGnomeSession[Name]}-${PackageGnomeSession[Version]}";
PackageGnomeSession[Extension]=".tar.xz";

PackageGnomeSession[Programs]="gnome-session gnome-session-inhibit gnome-session-quit";
PackageGnomeSession[Libraries]="";
PackageGnomeSession[Python]="";

InstallGnomeSession()
{
	# Check Installation
	CheckGnomeSession && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGnomeSession[Name]}> Checking dependencies..."
	Required=(Elogind GnomeDesktop JSONGLib Mesa UPower)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Xmlto LibXslt DocbookXml DocbookXslNons)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageGnomeSession[Name]}> Building package..."
	_ExtractPackageGnomeSession || return $?;
	_BuildGnomeSession;
	return $?
}

CheckGnomeSession()
{
	CheckInstallation 	"${PackageGnomeSession[Programs]}"\
						"${PackageGnomeSession[Libraries]}"\
						"${PackageGnomeSession[Python]}" 1> /dev/null;
	return $?;
}

CheckGnomeSessionVerbose()
{
	CheckInstallationVerbose	"${PackageGnomeSession[Programs]}"\
								"${PackageGnomeSession[Libraries]}"\
								"${PackageGnomeSession[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGnomeSession()
{
	DownloadPackage	"${PackageGnomeSession[Source]}"	"${SHMAN_PDIR}"	"${PackageGnomeSession[Package]}${PackageGnomeSession[Extension]}"	"${PackageGnomeSession[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGnomeSession[Package]}"	"${PackageGnomeSession[Extension]}" || return $?;

	for URL in \
	# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildGnomeSession()
{
	if ! cd "${SHMAN_PDIR}${PackageGnomeSession[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGnomeSession[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageGnomeSession[Name]}> Make gnome-session a login shell"
	sed 's@/bin/sh@/bin/sh -l@' -i gnome-session/gnome-session.in

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGnomeSession[Package]}/build \
					|| { EchoError "${PackageGnomeSession[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGnomeSession[Package]}/build"; return 1; }

	EchoInfo	"${PackageGnomeSession[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D systemduserunitdir=/tmp \
				.. \
				1> /dev/null || { EchoTest KO ${PackageGnomeSession[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeSession[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGnomeSession[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeSession[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGnomeSession[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageGnomeSession[Name]}> Move documentation"
	mv -v /usr/share/doc/gnome-session{,-47.0.1}

	EchoInfo	"${PackageGnomeSession[Name]}> Remove extra files"
	rm -v /usr/share/xsessions/gnome.desktop
	rm -v /usr/share/wayland-sessions/gnome.desktop

	EchoInfo	"${PackageGnomeSession[Name]}> Remove useless systemd units"
	rm -rv /tmp/{*.d,*.target,*.service}

	EchoInfo	"${PackageGnomeSession[Name]}> Remove extra files"
	sed -e 's@^Exec=@&/usr/bin/dbus-run-session @' \
		-i /usr/share/wayland-sessions/gnome-wayland.desktop

	EchoInfo	"${PackageGnomeSession[Name]}> Still requires initialization"
	PressAnyKeyToContinue;
}
