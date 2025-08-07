#!/bin/bash

if [ ! -z "${PackageFriBidi[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									FriBidi									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageFriBidi;
PackageFriBidi[Source]="https://github.com/fribidi/fribidi/releases/download/v1.0.16/fribidi-1.0.16.tar.xz";
PackageFriBidi[MD5]="333ad150991097a627755b752b87f9ff";
PackageFriBidi[Name]="fribidi";
PackageFriBidi[Version]="1.0.16";
PackageFriBidi[Package]="${PackageFriBidi[Name]}-${PackageFriBidi[Version]}";
PackageFriBidi[Extension]=".tar.xz";

PackageFriBidi[Programs]="fribidi";
PackageFriBidi[Libraries]="libfribidi.so";
PackageFriBidi[Python]="";

InstallFriBidi()
{
	# Check Installation
	CheckFriBidi && return $?;

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
	EchoInfo	"Package ${PackageFriBidi[Name]}"
	_ExtractPackageFriBidi || return $?;
	_BuildFriBidi;
	return $?
}

CheckFriBidi()
{
	CheckInstallation 	"${PackageFriBidi[Programs]}"\
						"${PackageFriBidi[Libraries]}"\
						"${PackageFriBidi[Python]}" 1> /dev/null;
	return $?;
}

CheckFriBidiVerbose()
{
	CheckInstallationVerbose	"${PackageFriBidi[Programs]}"\
								"${PackageFriBidi[Libraries]}"\
								"${PackageFriBidi[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageFriBidi()
{
	DownloadPackage	"${PackageFriBidi[Source]}"	"${SHMAN_PDIR}"	"${PackageFriBidi[Package]}${PackageFriBidi[Extension]}"	"${PackageFriBidi[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageFriBidi[Package]}"	"${PackageFriBidi[Extension]}" || return $?;

	return $?;
}

_BuildFriBidi()
{
	if ! cd "${SHMAN_PDIR}${PackageFriBidi[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageFriBidi[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageFriBidi[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageFriBidi[Package]}/build";

	EchoInfo	"${PackageFriBidi[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageFriBidi[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFriBidi[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageFriBidi[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFriBidi[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageFriBidi[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageFriBidi[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageFriBidi[Name]} && PressAnyKeyToContinue; return 1; };
}
