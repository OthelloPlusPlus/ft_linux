#!/bin/bash

if [ ! -z "${PackageLibTasn1[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibTasn1								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibTasn1;
PackageLibTasn1[Source]="https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.20.0.tar.gz";
PackageLibTasn1[MD5]="930f71d788cf37505a0327c1b84741be";
PackageLibTasn1[Name]="libtasn1";
PackageLibTasn1[Version]="4.20.0";
PackageLibTasn1[Package]="${PackageLibTasn1[Name]}-${PackageLibTasn1[Version]}";
PackageLibTasn1[Extension]=".tar.gz";

PackageLibTasn1[Programs]="asn1Coding asn1Decoding asn1Parser";
PackageLibTasn1[Libraries]="libtasn1.so";
PackageLibTasn1[Python]="";

InstallLibTasn1()
{
	# Check Installation
	CheckLibTasn1 && return $?;

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
	_BuildLibTasn1;
	return $?
}

CheckLibTasn1()
{
	CheckInstallation 	"${PackageLibTasn1[Programs]}"\
						"${PackageLibTasn1[Libraries]}"\
						"${PackageLibTasn1[Python]}" 1> /dev/null;
	return $?;
}

CheckLibTasn1Verbose()
{
	CheckInstallationVerbose	"${PackageLibTasn1[Programs]}"\
								"${PackageLibTasn1[Libraries]}"\
								"${PackageLibTasn1[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildLibTasn1()
{
	EchoInfo	"Package ${PackageLibTasn1[Name]}"

	DownloadPackage	"${PackageLibTasn1[Source]}"	"${SHMAN_PDIR}"	"${PackageLibTasn1[Package]}${PackageLibTasn1[Extension]}"	"${PackageLibTasn1[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibTasn1[Package]}"	"${PackageLibTasn1[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageLibTasn1[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibTasn1[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibTasn1[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageLibTasn1[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibTasn1[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibTasn1[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibTasn1[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibTasn1[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLibTasn1[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibTasn1[Name]} && PressAnyKeyToContinue; return 1; };
}
