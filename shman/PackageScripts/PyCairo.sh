#!/bin/bash

if [ ! -z "${PackagePyCairo[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									PyCairo									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePyCairo;
PackagePyCairo[Source]="https://github.com/pygobject/pycairo/releases/download/v1.26.1/pycairo-1.26.1.tar.gz";
PackagePyCairo[MD5]="36504ac01533ae14f0d2337516bbae2e";
PackagePyCairo[Name]="pycairo";
PackagePyCairo[Version]="1.26.1";
PackagePyCairo[Package]="${PackagePyCairo[Name]}-${PackagePyCairo[Version]}";
PackagePyCairo[Extension]=".tar.gz";

PackagePyCairo[Programs]="";
PackagePyCairo[Libraries]="";
PackagePyCairo[Python]="";

InstallPyCairo()
{
	# Check Installation
	CheckPyCairo && return $?;

	# Check Dependencies
	Required=(Cairo)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Hypothesis Pytest)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"Package ${PackagePyCairo[Name]}"
	_ExtractPackagePyCairo || return $?;
	_BuildPyCairo;
	return $?
}

CheckPyCairo()
{
	return 1;
	# CheckInstallation 	"${PackagePyCairo[Programs]}"\
	# 					"${PackagePyCairo[Libraries]}"\
	# 					"${PackagePyCairo[Python]}" 1> /dev/null;
	return $?;
}

CheckPyCairoVerbose()
{
	EchoWarning	"No valid check implemented" >&2;
	return 1;
	# CheckInstallationVerbose	"${PackagePyCairo[Programs]}"\
	# 							"${PackagePyCairo[Libraries]}"\
	# 							"${PackagePyCairo[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackagePyCairo()
{
	DownloadPackage	"${PackagePyCairo[Source]}"	"${SHMAN_PDIR}"	"${PackagePyCairo[Package]}${PackagePyCairo[Extension]}"	"${PackagePyCairo[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackagePyCairo[Package]}"	"${PackagePyCairo[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildPyCairo()
{
	if ! cd "${SHMAN_PDIR}${PackagePyCairo[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackagePyCairo[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackagePyCairo[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackagePyCairo[Package]}/build";

	EchoInfo	"${PackagePyCairo[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackagePyCairo[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePyCairo[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackagePyCairo[Name]} && PressAnyKeyToContinue; return 1; };

	if source "${SHMAN_SDIR}/Pytest.sh" && CheckPytest; then
		EchoInfo	"${PackagePyCairo[Name]}> ninja test"
		ninja test 1> /dev/null || { EchoTest KO ${PackagePyCairo[Name]} && PressAnyKeyToContinue; return 1; };
	fi

	EchoInfo	"${PackagePyCairo[Name]}> ninja install"
	make install 1> /dev/null || { EchoTest KO ${PackagePyCairo[Name]} && PressAnyKeyToContinue; return 1; };
}
