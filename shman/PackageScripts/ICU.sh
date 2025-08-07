#!/bin/bash

if [ ! -z "${PackageICU[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									  ICU									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageICU;
PackageICU[Source]="https://github.com/unicode-org/icu/releases/download/release-76-1/icu4c-76_1-src.tgz";
PackageICU[MD5]="857fdafff8127139cc175a3ec9b43bd6";
PackageICU[Name]="icu";
PackageICU[Version]="76_1-src";
PackageICU[Package]="${PackageICU[Name]}4c-${PackageICU[Version]}";
PackageICU[Extension]=".tgz";

PackageICU[Programs]="derb escapesrc genbrk genccode gencfu gencmn gencnval gendict gennorm2 genrb gensprep icu-config icuexportdata icuinfo icupkg makeconv pkgdata uconv";
PackageICU[Libraries]="libicudata.so libicui18n.so libicuio.so libicutest.so libicutu.so libicuuc.so";
PackageICU[Python]="";

InstallICU()
{
	# Check Installation
	CheckICU && return $?;

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
	_BuildICU;
	return $?
}

CheckICU()
{
	CheckInstallation 	"${PackageICU[Programs]}"\
						"${PackageICU[Libraries]}"\
						"${PackageICU[Python]}" 1> /dev/null;
	return $?;
}

CheckICUVerbose()
{
	CheckInstallationVerbose	"${PackageICU[Programs]}"\
								"${PackageICU[Libraries]}"\
								"${PackageICU[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildICU()
{
	EchoInfo	"Package ${PackageICU[Name]}"

	DownloadPackage	"${PackageICU[Source]}"	"${SHMAN_PDIR}"	"${PackageICU[Package]}${PackageICU[Extension]}"	"${PackageICU[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageICU[Package]}"	"${PackageICU[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageICU[Name]}/source"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageICU[Name]}/source";
		return 1;
	fi

	EchoInfo	"${PackageICU[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageICU[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageICU[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageICU[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageICU[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageICU[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageICU[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageICU[Name]} && PressAnyKeyToContinue; return 1; };
}
