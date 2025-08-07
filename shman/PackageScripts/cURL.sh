#!/bin/bash

# if [ ! -z "${PackageICU[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									  cURL									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagecURL;
PackagecURL[Source]="https://curl.se/download/curl-8.12.1.tar.xz";
PackagecURL[MD5]="7940975dd510399c4b27831165ab62e0";
PackagecURL[Name]="curl";
PackagecURL[Version]="8.12.1";
PackagecURL[Package]="${PackagecURL[Name]}-${PackagecURL[Version]}";
PackagecURL[Extension]=".tar.xz";

PackagecURL[Programs]="curl curl-config";
PackagecURL[Libraries]="libcurl.so";
PackagecURL[Python]="";

InstallcURL()
{
	# Check Installation
	CheckcURL && return $?;

	# Check Dependencies
	Dependencies=()
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=(LibPsl)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done
	
	# Install Package
	_BuildcURL;
	return $?
}

CheckcURL()
{
	CheckInstallation 	"${PackagecURL[Programs]}"\
						"${PackagecURL[Libraries]}"\
						"${PackagecURL[Python]}" 1> /dev/null;
	return $?;
}

CheckcURLVerbose()
{
	CheckInstallationVerbose	"${PackagecURL[Programs]}"\
								"${PackagecURL[Libraries]}"\
								"${PackagecURL[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildcURL()
{
	EchoInfo	"Package ${PackagecURL[Name]}"

	DownloadPackage	"${PackagecURL[Source]}"	"${SHMAN_PDIR}"	"${PackagecURL[Package]}${PackagecURL[Extension]}"	"${PackagecURL[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackagecURL[Package]}"	"${PackagecURL[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackagecURL[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackagecURL[Package]}";
		return 1;
	fi

	EchoInfo	"${PackagecURL[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--with-openssl \
				--with-ca-path=/etc/ssl/certs \
				1> /dev/null || { EchoTest KO ${PackagecURL[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagecURL[Name]}> make"
	make  1> /dev/null || { EchoTest KO ${PackagecURL[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackagecURL[Name]}> make test"
	# make test 1> /dev/null || { EchoTest KO ${PackagecURL[Name]} && EchoInfo "Some tests are flaky..." && PressAnyKeyToContinue; };
	
	EchoInfo	"${PackagecURL[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackagecURL[Name]} && PressAnyKeyToContinue; return 1; };

	
	rm -rf docs/examples/.deps &&
	find docs \(-name Makefile\* -o  \
				-name \*.1       -o  \
				-name \*.3       -o  \
				-name CMakeLists.txt \) -delete &&
	cp -v -R docs -T /usr/share/doc/curl-8.12.1
}
