#!/bin/bash

if [ ! -z "${PackagePixman[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Pixman								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePixman;
PackagePixman[Source]="https://www.cairographics.org/releases/pixman-0.44.2.tar.gz";
PackagePixman[MD5]="0825cd6bfc488d5177f2f013a06ef240";
PackagePixman[Name]="pixman";
PackagePixman[Version]="0.44.2";
PackagePixman[Package]="${PackagePixman[Name]}-${PackagePixman[Version]}";
PackagePixman[Extension]=".tar.gz";

PackagePixman[Programs]="";
PackagePixman[Libraries]="libpixman-1.so";
PackagePixman[Python]="";

InstallPixman()
{
	# Check Installation
	CheckPixman && return $?;

	EchoInfo	"${PackagePixman[Name]}> Checking dependencies..."

	# Check Dependencies
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(LibPng) #GTK3 removed for circular dependency...
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackagePixman[Name]}> Building package..."
	_ExtractPackagePixman || return $?;
	_BuildPixman;
	return $?
}

CheckPixman()
{
	CheckInstallation 	"${PackagePixman[Programs]}"\
						"${PackagePixman[Libraries]}"\
						"${PackagePixman[Python]}" 1> /dev/null;
	return $?;
}

CheckPixmanVerbose()
{
	CheckInstallationVerbose	"${PackagePixman[Programs]}"\
								"${PackagePixman[Libraries]}"\
								"${PackagePixman[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackagePixman()
{
	DownloadPackage	"${PackagePixman[Source]}"	"${SHMAN_PDIR}"	"${PackagePixman[Package]}${PackagePixman[Extension]}"	"${PackagePixman[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackagePixman[Package]}"	"${PackagePixman[Extension]}" || return $?;

	return $?;
}

_BuildPixman()
{
	if ! cd "${SHMAN_PDIR}${PackagePixman[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackagePixman[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackagePixman[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackagePixman[Package]}/build";

	EchoInfo	"${PackagePixman[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackagePixman[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePixman[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackagePixman[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePixman[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackagePixman[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackagePixman[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackagePixman[Name]} && PressAnyKeyToContinue; return 1; };
}
