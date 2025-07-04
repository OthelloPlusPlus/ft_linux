#!/bin/bash

if [ ! -z "${PackageLynx[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Lynx								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLynx;
PackageLynx[Source]="https://invisible-mirror.net/archives/lynx/tarballs/lynx2.9.2.tar.bz2";
PackageLynx[MD5]="3ce01505e82626ca4d7291d7e649c4c9";
PackageLynx[Name]="lynx";
PackageLynx[Version]="2.9.2";
PackageLynx[Package]="${PackageLynx[Name]}${PackageLynx[Version]}";
PackageLynx[Extension]=".tar.bz2";

PackageLynx[Programs]="lynx";
PackageLynx[Libraries]="";
PackageLynx[Python]="";

InstallLynx()
{
	# Check Installation
	CheckLynx && return $?;

	# Check Dependencies
	Dependencies=()
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh";
		fi
	done
	
	# Install Package
	_BuildLynx;
	return $?
}

CheckLynx()
{
	CheckInstallation	"${PackageLynx[Programs]}"\
						"${PackageLynx[Libraries]}"\
						"${PackageLynx[Python]}" 1> /dev/null;
	return $?;
}

CheckLynxVerbose()
{
	CheckInstallationVerbose	"${PackageLynx[Programs]}"\
								"${PackageLynx[Libraries]}"\
								"${PackageLynx[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildLynx()
{
	EchoInfo	"Package ${PackageLynx[Name]}"

	DownloadPackage	"${PackageLynx[Source]}"	"${SHMAN_PDIR}"	"${PackageLynx[Package]}${PackageLynx[Extension]}"	"${PackageLynx[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLynx[Package]}"	"${PackageLynx[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageLynx[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLynx[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLynx[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc/lynx \
				--with-zlib \
				--with-bzlib \
				--with-ssl \
				--with-screen=ncursesw \
				--enable-locale-charset \
				--datadir=/usr/share/doc/lynx-2.9.2 \
				1> /dev/null || { EchoTest KO ${PackageLynx[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLynx[Name]}> make"
	make  1> /dev/null || { EchoTest KO ${PackageLynx[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLynx[Name]}> make install-full"
	make install-full 1> /dev/null || { EchoTest KO ${PackageLynx[Name]} && PressAnyKeyToContinue; return 1; };
	
	chgrp -v -R root /usr/share/doc/lynx-2.9.2/lynx_doc

	EchoInfo	"${PackageLynx[Name]}> Configuring"
	# Display character set
	sed -e '/#LOCALE/     a LOCALE_CHARSET:TRUE' \
		-i /etc/lynx/lynx.cfg
	# Prevent breaking of multibyte characters
	sed -e '/#DEFAULT_ED/ a DEFAULT_EDITOR:vi' \
		-i /etc/lynx/lynx.cfg
	# Save cookies between sessions
	# sed -e '/#PERSIST/    a PERSISTENT_COOKIES:TRUE' \
	# 	-i /etc/lynx/lynx.cfg
}
