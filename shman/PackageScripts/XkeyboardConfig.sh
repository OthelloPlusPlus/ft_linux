#!/bin/bash

if [ ! -z "${PackageXkeyboardConfig[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#								XkeyboardConfig								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXkeyboardConfig;
PackageXkeyboardConfig[Source]="https://www.x.org/pub/individual/data/xkeyboard-config/xkeyboard-config-2.44.tar.xz";
PackageXkeyboardConfig[MD5]="623a88fe63c6aefe3621bdfd5ba72764";
PackageXkeyboardConfig[Name]="xkeyboard-config";
PackageXkeyboardConfig[Version]="2.44";
PackageXkeyboardConfig[Package]="${PackageXkeyboardConfig[Name]}-${PackageXkeyboardConfig[Version]}";
PackageXkeyboardConfig[Extension]=".tar.xz";

PackageXkeyboardConfig[Programs]="";
PackageXkeyboardConfig[Libraries]="";
PackageXkeyboardConfig[Python]="";

InstallXkeyboardConfig()
{
	# Check Installation
	CheckXkeyboardConfig && return $?;

	# Check Dependencies
	EchoInfo	"${PackageXkeyboardConfig[Name]}> Checking dependencies..."
	Required=(XorgLibraries)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(LibXkbcommon XorgApplications)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
		fi
	done

	# Install Package
	EchoInfo	"${PackageXkeyboardConfig[Name]}> Building package..."
	_ExtractPackageXkeyboardConfig || return $?;
	_BuildXkeyboardConfig;
	return $?
}

CheckXkeyboardConfig()
{
	return 1;
	CheckInstallation 	"${PackageXkeyboardConfig[Programs]}"\
						"${PackageXkeyboardConfig[Libraries]}"\
						"${PackageXkeyboardConfig[Python]}" 1> /dev/null;
	return $?;
}

CheckXkeyboardConfigVerbose()
{
	EchoWarning	"No valid check implemented" >&2;
	return 1;
	CheckInstallationVerbose	"${PackageXkeyboardConfig[Programs]}"\
								"${PackageXkeyboardConfig[Libraries]}"\
								"${PackageXkeyboardConfig[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageXkeyboardConfig()
{
	DownloadPackage	"${PackageXkeyboardConfig[Source]}"	"${SHMAN_PDIR}"	"${PackageXkeyboardConfig[Package]}${PackageXkeyboardConfig[Extension]}"	"${PackageXkeyboardConfig[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageXkeyboardConfig[Package]}"	"${PackageXkeyboardConfig[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildXkeyboardConfig()
{
	if ! cd "${SHMAN_PDIR}${PackageXkeyboardConfig[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageXkeyboardConfig[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageXkeyboardConfig[Package]}/build \
					|| { EchoError "${PackageXkeyboardConfig[Name]}> Failed to enter ${SHMAN_PDIR}${PackageXkeyboardConfig[Package]}/build"; return 1; }

	EchoInfo	"${PackageXkeyboardConfig[Name]}> Configure"
	meson setup --prefix=$XORG_PREFIX \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageXkeyboardConfig[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXkeyboardConfig[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageXkeyboardConfig[Name]} && PressAnyKeyToContinue; return 1; };

	if which xkbcomp pytest &> /dev/null; then
		EchoInfo	"${PackageXkeyboardConfig[Name]}> ninja test"
		ninja test 1> /dev/null || { EchoTest KO ${PackageXkeyboardConfig[Name]} && PressAnyKeyToContinue; return 1; };
	fi

	EchoInfo	"${PackageXkeyboardConfig[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageXkeyboardConfig[Name]} && PressAnyKeyToContinue; return 1; };
}
