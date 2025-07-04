#!/bin/bash

if [ ! -z "${PackageIbus[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

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
	gtk-query-immodules-3.0 --update-cache
	gtk-query-immodules-3.0 | grep -q im-ibus.so || return $?;
	CheckInstallation 	"${PackageIbus[Programs]}"\
						"${PackageIbus[Libraries]}"\
						"${PackageIbus[Python]}" 1> /dev/null;
	return $?;
}

CheckIbusVerbose()
{
	gtk-query-immodules-3.0 --update-cache
	gtk-query-immodules-3.0 | grep -q im-ibus.so || echo "${C_RED}im-ibus.so${C_RESET} " >&2;
	CheckInstallationVerbose	"${PackageIbus[Programs]}"\
								"${PackageIbus[Libraries]}"\
								"${PackageIbus[Python]}";
	return $?;
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

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageIbus[Package]}/build \
	# 				|| { EchoError "${PackageIbus[Name]}> Failed to enter ${SHMAN_PDIR}${PackageIbus[Package]}/build"; return 1; }

	EchoInfo	"${PackageIbus[Name]}> Configure"
	SAVE_DIST_FILES=1 NOCONFIGURE=1 ./autogen.sh
	PYTHON=python3 \
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--disable-python2 \
				--disable-appindicator \
				--disable-emoji-dict \
				--disable-gtk2 \
				--disable-systemd-services \
				1> /dev/null || { EchoTest KO ${PackageIbus[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageIbus[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageIbus[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageIbus[Name]}> make -k check"
	# make check 1> /dev/null || { EchoTest KO ${PackageIbus[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageIbus[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageIbus[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageIbus[Name]}> Creating symbolic links from lib to lib64"
	ln -sn /usr/lib/gtk-3.0/3.0.0/immodules/* /usr/lib64/gtk-3.0/3.0.0/immodules/

	EchoInfo	"${PackageIbus[Name]}> Updating GTK# cache"
	gtk-query-immodules-3.0 --update-cache
}
