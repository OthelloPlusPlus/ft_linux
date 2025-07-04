#!/bin/bash

if [ ! -z "${PackageLibGcrypt[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibGcrypt								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibGcrypt;
PackageLibGcrypt[Source]="https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.11.0.tar.bz2";
PackageLibGcrypt[MD5]="321c4975cfd6a496f0530b65a673f9a4";
PackageLibGcrypt[Name]="libgcrypt";
PackageLibGcrypt[Version]="1.11.0";
PackageLibGcrypt[Package]="${PackageLibGcrypt[Name]}-${PackageLibGcrypt[Version]}";
PackageLibGcrypt[Extension]=".tar.bz2";

PackageLibGcrypt[Programs]="dumpsexp hmac256 mpicalc";
PackageLibGcrypt[Libraries]="libgcrypt.so";
PackageLibGcrypt[Python]="";

InstallLibGcrypt()
{
	# Check Installation
	CheckLibGcrypt && return $?;

	# Check Dependencies
	Dependencies=(LibGpgError)
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Texlive)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	_BuildLibGcrypt;
	return $?
}

CheckLibGcrypt()
{
	CheckInstallation 	"${PackageLibGcrypt[Programs]}"\
						"${PackageLibGcrypt[Libraries]}"\
						"${PackageLibGcrypt[Python]}" 1> /dev/null;
	return $?;
}

CheckLibGcryptVerbose()
{
	CheckInstallationVerbose	"${PackageLibGcrypt[Programs]}"\
								"${PackageLibGcrypt[Libraries]}"\
								"${PackageLibGcrypt[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildLibGcrypt()
{
	EchoInfo	"Package ${PackageLibGcrypt[Name]}"

	DownloadPackage	"${PackageLibGcrypt[Source]}"	"${SHMAN_PDIR}"	"${PackageLibGcrypt[Package]}${PackageLibGcrypt[Extension]}"	"${PackageLibGcrypt[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibGcrypt[Package]}"	"${PackageLibGcrypt[Extension]}";
	# wget -P "${SHMAN_PDIR}" "";

	if ! cd "${SHMAN_PDIR}${PackageLibGcrypt[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibGcrypt[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibGcrypt[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageLibGcrypt[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibGcrypt[Name]}> make"
	make 		-C doc html \
				1> /dev/null && \
	makeinfo 	--html --no-split \
				-o doc/gcrypt_nochunks.html doc/gcrypt.texi \
				1> /dev/null && \
	makeinfo 	--plaintext \
				-o doc/gcrypt.txt           doc/gcrypt.texi \
				1> /dev/null || { EchoTest KO ${PackageLibGcrypt[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibGcrypt[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibGcrypt[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLibGcrypt[Name]}> make install"
	make install 		1> /dev/null && \
	install -v -dm755   													/usr/share/doc/libgcrypt-1.11.0 		1> /dev/null && \
	install -v -m644    README doc/{README.apichanges,fips*,libgcrypt*} 	/usr/share/doc/libgcrypt-1.11.0 		1> /dev/null && \
	install -v -dm755   													/usr/share/doc/libgcrypt-1.11.0/html 	1> /dev/null && \
	install -v -m644 	doc/gcrypt.html/* 									/usr/share/doc/libgcrypt-1.11.0/html 	1> /dev/null && \
	install -v -m644 	doc/gcrypt_nochunks.html 							/usr/share/doc/libgcrypt-1.11.0 		1> /dev/null && \
	install -v -m644 	doc/gcrypt.{txt,texi} 								/usr/share/doc/libgcrypt-1.11.0 \
						1> /dev/null || { EchoTest KO ${PackageLibGcrypt[Name]} && PressAnyKeyToContinue; return 1; };
}
