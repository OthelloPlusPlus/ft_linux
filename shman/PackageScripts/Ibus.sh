#!/bin/bash

if [ ! -z "${PackageIbus[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Ibus								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageIbus;
PackageIbus[Source]="https://github.com/ibus/ibus/archive/1.5.31/ibus-1.5.31.tar.gz";
PackageIbus[MD5]="3d685af1010d871bb858dc8a8aabb5c4";
PackageIbus[Name]="ibus";
PackageIbus[Version]="1.5.31";
PackageIbus[Package]="${PackageIbus[Name]}-${PackageIbus[Version]}";
PackageIbus[Extension]=".tar.gz";

PackageIbus[Programs]="ibus ibus-daemon ibus-setup";
PackageIbus[Libraries]="libibus-1.0.so";
PackageIbus[Python]="";

InstallIbus()
{
	# Check Installation
	CheckIbus && return $?;

	# Check Dependencies
	EchoInfo	"${PackageIbus[Name]}> Checking dependencies..."
	Required=(ISOCodes Vala)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(DConf GLib GTK3 GTK4 LibNotify)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageIbus[Name]}> Checking recommended ${Dependency}..."
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(GTKDoc LibXkbcommon Wayland)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageIbus[Name]}> Building package..."
	_ExtractPackageIbus || return $?;
	_BuildIbus;
	return $?
}

CheckIbus()
{
	gtk-query-immodules-3.0 --update-cache &> /dev/null || return $?;
	gtk-query-immodules-3.0 | grep -q im-ibus.so || return $?;
	CheckInstallation 	"${PackageIbus[Programs]}"\
						"${PackageIbus[Libraries]}"\
						"${PackageIbus[Python]}" 1> /dev/null || return $?;
	if which gjs &> /dev/null; then
		gjs -c 'print(imports.gi.IBus);' &> /dev/null || return $?;
	fi
	return $?;
}

CheckIbusVerbose()
{
	gtk-query-immodules-3.0 --update-cache &> /dev/null || { echo -en "${C_RED}gtk-query-immodules${C_RESET} " >&2; return 1; }
	gtk-query-immodules-3.0 | grep -q im-ibus.so || echo -en "${C_RED}im-ibus.so${C_RESET} " >&2;
	CheckInstallationVerbose	"${PackageIbus[Programs]}"\
								"${PackageIbus[Libraries]}"\
								"${PackageIbus[Python]}";
	if which gjs &> /dev/null; then
		gjs -c 'print(imports.gi.IBus);' &> /dev/null || {
			echo -en "${C_RED}gjs${C_RESET} " >&2;
			return 1;
		}
	fi
	return 0;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageIbus()
{
	DownloadPackage	"${PackageIbus[Source]}"	"${SHMAN_PDIR}"	"${PackageIbus[Package]}${PackageIbus[Extension]}"	"${PackageIbus[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageIbus[Package]}"	"${PackageIbus[Extension]}" || return $?;

	for URL in \
		"https://www.unicode.org/Public/zipped/16.0.0/UCD.zip"
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildIbus()
{
	if ! cd "${SHMAN_PDIR}${PackageIbus[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageIbus[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageIbus[Name]}> Install Unicode Character Database"
	mkdir -p               /usr/share/unicode/ucd
	unzip -o ../UCD.zip -d /usr/share/unicode/ucd 1> /dev/null || { EchoTest KO ${PackageIbus[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageIbus[Name]}> Fix deprecated schema entries issue"
	sed -e 's@/desktop/ibus@/org/freedesktop/ibus@g' \
		-i data/dconf/org.freedesktop.ibus.gschema.xml

	if ! [ -e /usr/bin/gtkdocize ]; then
		EchoInfo	"${PackageIbus[Name]}> Remove GTK-Doc references"
		sed '/docs/d;/GTK_DOC/d' -i Makefile.am configure.ac
	fi

	EchoInfo	"${PackageIbus[Name]}> Configure autogen.sh"
	SAVE_DIST_FILES=1 NOCONFIGURE=1 ./autogen.sh 1> /dev/null || { EchoTest KO ${PackageIbus[Name]} && PressAnyKeyToContinue; return 1; };
	EchoInfo	"${PackageIbus[Name]}> Configure"
	PYTHON=python3 \
	./configure --prefix=/usr \
				--libdir=/usr/lib64 \
				--sysconfdir=/etc \
				--disable-python2 \
				--disable-appindicator \
				--disable-emoji-dict \
				--disable-gtk2 \
				--disable-systemd-services \
				--enable-introspection \
				1> /dev/null || { EchoTest KO ${PackageIbus[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageIbus[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageIbus[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageIbus[Name]}> make -k check"
	make -k check 1> /dev/null || { 
			EchoTest KO "${PackageIbus[Name]}> Expected Errors:";
			EchoWarning "${PackageIbus[Name]}> ibus-keypress if running Wayland";
			EchoWarning "${PackageIbus[Name]}> xkb-latin-layouts on some systems";
			find . -type f -name test-suite.log | while read -r logfile; do
				head -n 3 "$logfile"
				grep '^FAIL:' "$logfile"
			done
			EchoWarning "${PackageIbus[Name]}> Evaluate whether errors are critical.";
			EchoWarning "${PackageIbus[Name]}> Otherwise Ctrl + C";
			PressAnyKeyToContinue;
		};

	EchoInfo	"${PackageIbus[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageIbus[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageIbus[Name]}> Creating symbolic links from lib to lib64"
	ln -sn /usr/lib/gtk-3.0/3.0.0/immodules/* /usr/lib64/gtk-3.0/3.0.0/immodules/

	EchoInfo	"${PackageIbus[Name]}> Updating GTK# cache"
	gtk-query-immodules-3.0 --update-cache
}
