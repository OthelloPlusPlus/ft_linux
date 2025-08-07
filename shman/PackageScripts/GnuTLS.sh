#!/bin/bash

if [ ! -z "${PackageGnuTLS[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									 GnuTLS									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGnuTLS;
PackageGnuTLS[Source]="https://www.gnupg.org/ftp/gcrypt/gnutls/v3.8/gnutls-3.8.9.tar.xz";
PackageGnuTLS[MD5]="33f4c800c20af2983c45223a803da865";
PackageGnuTLS[Name]="gnutls";
PackageGnuTLS[Version]="3.8.9";
PackageGnuTLS[Package]="${PackageGnuTLS[Name]}-${PackageGnuTLS[Version]}";
PackageGnuTLS[Extension]=".tar.xz";

# Removed srptool because it does not seem to install for unknown reasons...
PackageGnuTLS[Programs]="certtool danetool gnutls-cli gnutls-cli-debug gnutls-serv ocsptool p11tool psktool";
PackageGnuTLS[Libraries]="libgnutls.so libgnutls-dane.so libgnutlsxx.so libgnutls-openssl.so";
PackageGnuTLS[Python]="";

InstallGnuTLS()
{
	# Check Installation
	CheckGnuTLS && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGnuTLS[Name]}> Checking dependencies..."
	Dependencies=(Nettle)
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(MakeCa LibUnistring LibTasn1 P11Kit)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Brotli Doxygen GTKDoc LibIdn LibIdn2 LibSeccomp NetTools Texlive Unbound)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageGnuTLS[Name]}> Building packages..."
	_BuildGnuTLS;
	return $?
}

CheckGnuTLS()
{
	CheckInstallation 	"${PackageGnuTLS[Programs]}"\
						"${PackageGnuTLS[Libraries]}"\
						"${PackageGnuTLS[Python]}";
	return $?;
}

CheckGnuTLSVerbose()
{
	CheckInstallationVerbose	"${PackageGnuTLS[Programs]}"\
								"${PackageGnuTLS[Libraries]}"\
								"${PackageGnuTLS[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildGnuTLS()
{
	DownloadPackage	"${PackageGnuTLS[Source]}"	"${SHMAN_PDIR}"	"${PackageGnuTLS[Package]}${PackageGnuTLS[Extension]}"	"${PackageGnuTLS[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGnuTLS[Package]}"	"${PackageGnuTLS[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageGnuTLS[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGnuTLS[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageGnuTLS[Name]}> Configure"
	./configure --prefix=/usr \
				--docdir=/usr/share/doc/gnutls-3.8.9 \
				--with-default-trust-store-pkcs11="pkcs11:" \
				--enable-openssl-compatibility \
				1> /dev/null || \
				{ 
					EchoTest KO ${PackageGnuTLS[Name]};
					echo "$PKG_CONFIG_PATH";
					ls /usr/lib*/pkgconfig/nettle* || EchoError "Couldn't find nettle.pc";
					EchoInfo "Sometimes weirdly fails, try restarting shman...";
					PressAnyKeyToContinue;
					return 1; 
				};

	EchoInfo	"${PackageGnuTLS[Name]}> make"
	make  1> /dev/null || { EchoTest KO ${PackageGnuTLS[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnuTLS[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageGnuTLS[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageGnuTLS[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageGnuTLS[Name]} && PressAnyKeyToContinue; return 1; };
}
