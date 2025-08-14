#!/bin/bash

if [ ! -z "${PackageWhich[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Which								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageWhich;
PackageWhich[Source]="https://ftp.gnu.org/gnu/which/which-2.23.tar.gz";
PackageWhich[MD5]="1963b85914132d78373f02a84cdb3c86";
PackageWhich[Name]="which";
PackageWhich[Version]="2.23";
PackageWhich[Package]="${PackageWhich[Name]}-${PackageWhich[Version]}";
PackageWhich[Extension]=".tar.gz";

PackageWhich[Programs]="which";
PackageWhich[Libraries]="";
PackageWhich[Python]="";

InstallWhich()
{
	# Check Installation
	CheckWhich && return $?;

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
	_BuildWhich;
	return $?
}

CheckWhich()
{
	CheckInstallation	"${PackageWhich[Programs]}"\
						"${PackageWhich[Libraries]}"\
						"${PackageWhich[Python]}" 1> /dev/null;
	return $?;
}

CheckWhichVerbose()
{
	CheckInstallationVerbose	"${PackageWhich[Programs]}"\
								"${PackageWhich[Libraries]}"\
								"${PackageWhich[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildWhich()
{
	EchoInfo	"Package ${PackageWhich[Name]}"

	DownloadPackage	"${PackageWhich[Source]}"	"${SHMAN_PDIR}"	"${PackageWhich[Package]}${PackageWhich[Extension]}"	"${PackageWhich[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageWhich[Package]}"	"${PackageWhich[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageWhich[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageWhich[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageWhich[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageWhich[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageWhich[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageWhich[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageWhich[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageWhich[Name]} && PressAnyKeyToContinue; return 1; };
}
