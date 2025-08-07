#!/bin/bash

if [ ! -z "${PackageLibGpgError[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibGpgError								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibGpgError;
PackageLibGpgError[Source]="https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.51.tar.bz2";
PackageLibGpgError[MD5]="74b73ea044685ce9fd6043a8cc885eac";
PackageLibGpgError[Name]="libgpg-error";
PackageLibGpgError[Version]="1.51";
PackageLibGpgError[Package]="${PackageLibGpgError[Name]}-${PackageLibGpgError[Version]}";
PackageLibGpgError[Extension]=".tar.bz2";

PackageLibGpgError[Programs]="gpg-error gpgrt-config yat2m";
PackageLibGpgError[Libraries]="libgpg-error.so";
PackageLibGpgError[Python]="";

InstallLibGpgError()
{
	# Check Installation
	CheckLibGpgError && return $?;

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
	_BuildLibGpgError;
	return $?
}

CheckLibGpgError()
{
	CheckInstallation 	"${PackageLibGpgError[Programs]}"\
						"${PackageLibGpgError[Libraries]}"\
						"${PackageLibGpgError[Python]}" 1> /dev/null;
	return $?;
}

CheckLibGpgErrorVerbose()
{
	CheckInstallationVerbose	"${PackageLibGpgError[Programs]}"\
								"${PackageLibGpgError[Libraries]}"\
								"${PackageLibGpgError[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildLibGpgError()
{
	EchoInfo	"Package ${PackageLibGpgError[Name]}"

	DownloadPackage	"${PackageLibGpgError[Source]}"	"${SHMAN_PDIR}"	"${PackageLibGpgError[Package]}${PackageLibGpgError[Extension]}"	"${PackageLibGpgError[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibGpgError[Package]}"	"${PackageLibGpgError[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageLibGpgError[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibGpgError[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibGpgError[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageLibGpgError[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibGpgError[Name]}> make"
	make  1> /dev/null || { EchoTest KO ${PackageLibGpgError[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibGpgError[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibGpgError[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLibGpgError[Name]}> make install"
	make install 1> /dev/null && \
	install -v -m644 -D README /usr/share/doc/libgpg-error-1.51/README \
		1> /dev/null || { EchoTest KO ${PackageLibGpgError[Name]} && PressAnyKeyToContinue; return 1; };
}
