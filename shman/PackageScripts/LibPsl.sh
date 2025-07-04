#!/bin/bash

if [ ! -z "${PackageLibPsl[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibPsl								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibPsl;
PackageLibPsl[Source]="https://github.com/rockdaboot/libpsl/releases/download/0.21.5/libpsl-0.21.5.tar.gz";
PackageLibPsl[MD5]="870a798ee9860b6e77896548428dba7b";
PackageLibPsl[Name]="libpsl";
PackageLibPsl[Version]="0.21.5";
PackageLibPsl[Package]="${PackageLibPsl[Name]}-${PackageLibPsl[Version]}";
PackageLibPsl[Extension]=".tar.gz";

PackageLibPsl[Programs]="psl";
PackageLibPsl[Libraries]="libpsl.so";
PackageLibPsl[Python]="";

InstallLibPsl()
{
	# Check Installation
	CheckLibPsl && return $?;

	# Check Dependencies
	Dependencies=()
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=(LibIdn2 LibUnistring)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done
	
	# Install Package
	_BuildLibPsl;
	return $?
}

CheckLibPsl()
{
	CheckInstallation	"${PackageLibPsl[Programs]}"\
						"${PackageLibPsl[Libraries]}"\
						"${PackageLibPsl[Python]}" 1> /dev/null;
	return $?;
}

CheckLibPslVerbose()
{
	CheckInstallationVerbose	"${PackageLibPsl[Programs]}"\
								"${PackageLibPsl[Libraries]}"\
								"${PackageLibPsl[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildLibPsl()
{
	EchoInfo	"Package ${PackageLibPsl[Name]}"

	DownloadPackage	"${PackageLibPsl[Source]}"	"${SHMAN_PDIR}"	"${PackageLibPsl[Package]}${PackageLibPsl[Extension]}"	"${PackageLibPsl[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibPsl[Package]}"	"${PackageLibPsl[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageLibPsl[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibPsl[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageLibPsl[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageLibPsl[Package]}/build";

	EchoInfo	"${PackageLibPsl[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				1> /dev/null || { EchoTest KO ${PackageLibPsl[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibPsl[Name]}> ninja"
	ninja  1> /dev/null || { EchoTest KO ${PackageLibPsl[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibPsl[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageLibPsl[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLibPsl[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibPsl[Name]} && PressAnyKeyToContinue; return 1; };

	if [ $(ldconfig -p | grep libpsl -c) -eq 0 ]; then
		EchoInfo	"${PackageLibPsl[Name]}> Ensuring libpsl.so can be found in lib64"
		echo "/usr/lib64" > /etc/ld.so.conf.d/lib64.conf
		ldconfig
	fi
}
