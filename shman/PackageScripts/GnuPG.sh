#!/bin/bash

if [ ! -z "${PackageGnuPG[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									 GnuPG								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGnuPG;
PackageGnuPG[Source]="https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-2.4.7.tar.bz2";
PackageGnuPG[MD5]="59ec68633deefcd38a5012f39a9d9311";
PackageGnuPG[Name]="gnupg";
PackageGnuPG[Version]="2.4.7";
PackageGnuPG[Package]="${PackageGnuPG[Name]}-${PackageGnuPG[Version]}";
PackageGnuPG[Extension]=".tar.bz2";

PackageGnuPG[Programs]="addgnupghome applygnupgdefaults dirmngr dirmngr-client gpg-agent gpg-card gpg-connect-agent gpg gpgconf gpgparsemail gpgscm gpgsm gpgsplit gpgtar gpgv gpg-wks-client gpg-wks-server kbxutil watchgnupg";
PackageGnuPG[Libraries]="";
PackageGnuPG[Python]="";

InstallGnuPG()
{
	# Check Installation
	CheckGnuPG && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGnuPG[Name]}> Checking dependencies..."
	Required=(LibAssuan LibGcrypt LibKsba Npth OpenLDAP)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GnuTLS Pinentry)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(cURL Fuse ImageMagick LibUsb SQLite Texlive)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageGnuPG[Name]}> Building package..."
	_ExtractPackageGnuPG || return $?;
	_BuildGnuPG;
	return $?
}

CheckGnuPG()
{
	CheckInstallation 	"${PackageGnuPG[Programs]}"\
						"${PackageGnuPG[Libraries]}"\
						"${PackageGnuPG[Python]}" 1> /dev/null;
	return $?;
}

CheckGnuPGVerbose()
{
	CheckInstallationVerbose	"${PackageGnuPG[Programs]}"\
								"${PackageGnuPG[Libraries]}"\
								"${PackageGnuPG[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGnuPG()
{
	DownloadPackage	"${PackageGnuPG[Source]}"	"${SHMAN_PDIR}"	"${PackageGnuPG[Package]}${PackageGnuPG[Extension]}"	"${PackageGnuPG[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGnuPG[Package]}"	"${PackageGnuPG[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildGnuPG()
{
	if ! cd "${SHMAN_PDIR}${PackageGnuPG[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGnuPG[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGnuPG[Package]}/build \
					|| { EchoError "${PackageGnuPG[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGnuPG[Package]}/build"; return 1; }

	EchoInfo	"${PackageGnuPG[Name]}> Configure"
	../configure --prefix=/usr \
				--localstatedir=/var \
				--sysconfdir=/etc \
				--docdir=/usr/share/doc/gnupg-2.4.7 \
				1> /dev/null || { EchoTest KO ${PackageGnuPG[Name]} && PressAnyKeyToContinue; return 1; };

	makeinfo --html --no-split -I doc -o doc/gnupg_nochunks.html ../doc/gnupg.texi && \
	makeinfo --plaintext       -I doc -o doc/gnupg.txt           ../doc/gnupg.texi && \
	make -C doc html

	EchoInfo	"${PackageGnuPG[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageGnuPG[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnuPG[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageGnuPG[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageGnuPG[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageGnuPG[Name]} && PressAnyKeyToContinue; return 1; };
	install -v -m755 -d /usr/share/doc/gnupg-2.4.7/html && \
	install -v -m644    doc/gnupg_nochunks.html \
						/usr/share/doc/gnupg-2.4.7/html/gnupg.html && \
	install -v -m644    ../doc/*.texi doc/gnupg.txt \
						/usr/share/doc/gnupg-2.4.7 && \
	install -v -m644    doc/gnupg.html/* \
						/usr/share/doc/gnupg-2.4.7/html
}
