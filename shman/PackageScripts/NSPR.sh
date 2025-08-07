#!/bin/bash

if [ ! -z "${PackageNSPR[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									  NSPR									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageNSPR;
PackageNSPR[Source]="https://archive.mozilla.org/pub/nspr/releases/v4.36/src/nspr-4.36.tar.gz";
PackageNSPR[MD5]="87a41a0773ab2a5f5c8f01aec16df24c";
PackageNSPR[Name]="nspr";
PackageNSPR[Version]="4.36";
PackageNSPR[Package]="${PackageNSPR[Name]}-${PackageNSPR[Version]}";
PackageNSPR[Extension]=".tar.gz";

PackageNSPR[Programs]="nspr-config";
PackageNSPR[Libraries]="libnspr4.so libplc4.so libplds4.so";
PackageNSPR[Python]="";

InstallNSPR()
{
	# Check Installation
	CheckNSPR && return $?;

	# Check Dependencies
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"Package ${PackageNSPR[Name]}"
	_ExtractPackageNSPR || return $?;
	_BuildNSPR;
	return $?
}

CheckNSPR()
{
	CheckInstallation 	"${PackageNSPR[Programs]}"\
						"${PackageNSPR[Libraries]}"\
						"${PackageNSPR[Python]}" 1> /dev/null;
	return $?;
}

CheckNSPRVerbose()
{
	CheckInstallationVerbose	"${PackageNSPR[Programs]}"\
								"${PackageNSPR[Libraries]}"\
								"${PackageNSPR[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageNSPR()
{
	DownloadPackage	"${PackageNSPR[Source]}"	"${SHMAN_PDIR}"	"${PackageNSPR[Package]}${PackageNSPR[Extension]}"	"${PackageNSPR[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageNSPR[Package]}"	"${PackageNSPR[Extension]}" || return $?;

	return $?;
}

_BuildNSPR()
{
	if ! cd "${SHMAN_PDIR}${PackageNSPR[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageNSPR[Package]}";
		return 1;
	fi

	cd "${SHMAN_PDIR}${PackageNSPR[Package]}/nspr" || return $?;

	sed -i '/^RELEASE/s|^|#|' pr/src/misc/Makefile.in &&
	sed -i 's|$(LIBRARY) ||'  config/rules.mk

	EchoInfo	"${PackageNSPR[Name]}> Configure"
	./configure --prefix=/usr \
				--with-mozilla \
				--with-pthreads \
				$([ $(uname -m) = x86_64 ] && echo --enable-64bit) \
				1> /dev/null || { EchoTest KO ${PackageNSPR[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNSPR[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageNSPR[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNSPR[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageNSPR[Name]} && PressAnyKeyToContinue; return 1; };
}
