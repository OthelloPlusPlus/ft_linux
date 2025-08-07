#!/bin/bash

if [ ! -z "${PackageLibAssuan[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibAssuan								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibAssuan;
PackageLibAssuan[Source]="https://www.gnupg.org/ftp/gcrypt/libassuan/libassuan-3.0.2.tar.bz2";
PackageLibAssuan[MD5]="c6f1bf4bd2aaa79cd1635dcc070ba51a";
PackageLibAssuan[Name]="libassuan";
PackageLibAssuan[Version]="3.0.2";
PackageLibAssuan[Package]="${PackageLibAssuan[Name]}-${PackageLibAssuan[Version]}";
PackageLibAssuan[Extension]=".tar.bz2";

PackageLibAssuan[Programs]="";
PackageLibAssuan[Libraries]="libassuan.so";
PackageLibAssuan[Python]="";

InstallLibAssuan()
{
	# Check Installation
	CheckLibAssuan && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibAssuan[Name]}> Checking dependencies..."
	Required=(LibGpgError)
	for Dependency in "${Required[@]}"; do
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
	EchoInfo	"${PackageLibAssuan[Name]}> Building package..."
	_ExtractPackageLibAssuan || return $?;
	_BuildLibAssuan;
	return $?
}

CheckLibAssuan()
{
	CheckInstallation 	"${PackageLibAssuan[Programs]}"\
						"${PackageLibAssuan[Libraries]}"\
						"${PackageLibAssuan[Python]}" 1> /dev/null;
	return $?;
}

CheckLibAssuanVerbose()
{
	CheckInstallationVerbose	"${PackageLibAssuan[Programs]}"\
								"${PackageLibAssuan[Libraries]}"\
								"${PackageLibAssuan[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibAssuan()
{
	DownloadPackage	"${PackageLibAssuan[Source]}"	"${SHMAN_PDIR}"	"${PackageLibAssuan[Package]}${PackageLibAssuan[Extension]}"	"${PackageLibAssuan[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibAssuan[Package]}"	"${PackageLibAssuan[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildLibAssuan()
{
	if ! cd "${SHMAN_PDIR}${PackageLibAssuan[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibAssuan[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibAssuan[Package]}/build \
	# 				|| { EchoError "${PackageLibAssuan[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibAssuan[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibAssuan[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageLibAssuan[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibAssuan[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibAssuan[Name]} && PressAnyKeyToContinue; return 1; };

	make -C doc html && \
	makeinfo --html --no-split -o doc/assuan_nochunks.html doc/assuan.texi && \
	makeinfo --plaintext       -o doc/assuan.txt           doc/assuan.texi

	EchoInfo	"${PackageLibAssuan[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibAssuan[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLibAssuan[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibAssuan[Name]} && PressAnyKeyToContinue; return 1; };

	install -v -dm755   /usr/share/doc/libassuan-3.0.2/html && \
	install -v -m644 doc/assuan.html/* \
						/usr/share/doc/libassuan-3.0.2/html && \
	install -v -m644 doc/assuan_nochunks.html \
						/usr/share/doc/libassuan-3.0.2 && \
	install -v -m644 doc/assuan.{txt,texi} \
						/usr/share/doc/libassuan-3.0.2
}
