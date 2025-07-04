#!/bin/bash

if [ ! -z "${PackageLibEpoxy[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibEpoxy								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibEpoxy;
PackageLibEpoxy[Source]="https://download.gnome.org/sources/libepoxy/1.5/libepoxy-1.5.10.tar.xz";
PackageLibEpoxy[MD5]="10c635557904aed5239a4885a7c4efb7";
PackageLibEpoxy[Name]="libepoxy";
PackageLibEpoxy[Version]="1.5.10";
PackageLibEpoxy[Package]="${PackageLibEpoxy[Name]}-${PackageLibEpoxy[Version]}";
PackageLibEpoxy[Extension]=".tar.xz";

PackageLibEpoxy[Programs]="";
PackageLibEpoxy[Libraries]="libepoxy.so";
PackageLibEpoxy[Python]="";

InstallLibEpoxy()
{
	# Check Installation
	CheckLibEpoxy && return $?;

	# Check Dependencies
	Required=(Mesa)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	Optional=(Doxygen)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"Package ${PackageLibEpoxy[Name]}"
	_ExtractPackageLibEpoxy || return $?;
	_BuildLibEpoxy;
	return $?
}

CheckLibEpoxy()
{
	CheckInstallation 	"${PackageLibEpoxy[Programs]}"\
						"${PackageLibEpoxy[Libraries]}"\
						"${PackageLibEpoxy[Python]}" 1> /dev/null;
	return $?;
}

CheckLibEpoxyVerbose()
{
	CheckInstallationVerbose	"${PackageLibEpoxy[Programs]}"\
								"${PackageLibEpoxy[Libraries]}"\
								"${PackageLibEpoxy[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibEpoxy()
{
	DownloadPackage	"${PackageLibEpoxy[Source]}"	"${SHMAN_PDIR}"	"${PackageLibEpoxy[Package]}${PackageLibEpoxy[Extension]}"	"${PackageLibEpoxy[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibEpoxy[Package]}"	"${PackageLibEpoxy[Extension]}" || return $?;

	return $?;
}

_BuildLibEpoxy()
{
	if ! cd "${SHMAN_PDIR}${PackageLibEpoxy[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibEpoxy[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageLibEpoxy[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageLibEpoxy[Package]}/build";

	EchoInfo	"${PackageLibEpoxy[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageLibEpoxy[Name]} && PressAnyKeyToContinue; return 1; };
	if source "${SHMAN_SDIR}/${Dependency}.sh" && CheckDoxygen; then
		meson configure -D docs=true  1> /dev/null || { EchoTest KO ${PackageLibEpoxy[Name]} && PressAnyKeyToContinue; return 1; };
	fi

	EchoInfo	"${PackageLibEpoxy[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibEpoxy[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibEpoxy[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageLibEpoxy[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLibEpoxy[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibEpoxy[Name]} && PressAnyKeyToContinue; return 1; };
}
