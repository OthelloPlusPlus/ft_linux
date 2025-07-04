#!/bin/bash

if [ ! -z "${PackageLibSeccomp[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibSeccomp								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibSeccomp;
PackageLibSeccomp[Source]="https://github.com/seccomp/libseccomp/releases/download/v2.6.0/libseccomp-2.6.0.tar.gz";
PackageLibSeccomp[MD5]="2d42bcde31fd6e994fcf251a1f71d487";
PackageLibSeccomp[Name]="libseccomp";
PackageLibSeccomp[Version]="2.6.0";
PackageLibSeccomp[Package]="${PackageLibSeccomp[Name]}-${PackageLibSeccomp[Version]}";
PackageLibSeccomp[Extension]=".tar.gz";

PackageLibSeccomp[Programs]="scmp_sys_resolver";
PackageLibSeccomp[Libraries]="libseccomp.so";
PackageLibSeccomp[Python]="";

InstallLibSeccomp()
{
	# Check Installation
	CheckLibSeccomp && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibSeccomp[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Which Valgrind)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageLibSeccomp[Name]}> Building package..."
	_ExtractPackageLibSeccomp || return $?;
	_BuildLibSeccomp;
	return $?
}

CheckLibSeccomp()
{
	CheckInstallation 	"${PackageLibSeccomp[Programs]}"\
						"${PackageLibSeccomp[Libraries]}"\
						"${PackageLibSeccomp[Python]}" 1> /dev/null;
	return $?;
}

CheckLibSeccompVerbose()
{
	CheckInstallationVerbose	"${PackageLibSeccomp[Programs]}"\
								"${PackageLibSeccomp[Libraries]}"\
								"${PackageLibSeccomp[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibSeccomp()
{
	DownloadPackage	"${PackageLibSeccomp[Source]}"	"${SHMAN_PDIR}"	"${PackageLibSeccomp[Package]}${PackageLibSeccomp[Extension]}"	"${PackageLibSeccomp[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibSeccomp[Package]}"	"${PackageLibSeccomp[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildLibSeccomp()
{
	if ! cd "${SHMAN_PDIR}${PackageLibSeccomp[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibSeccomp[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibSeccomp[Package]}/build \
	# 				|| { EchoError "${PackageLibSeccomp[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibSeccomp[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibSeccomp[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageLibSeccomp[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibSeccomp[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibSeccomp[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibSeccomp[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibSeccomp[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLibSeccomp[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibSeccomp[Name]} && PressAnyKeyToContinue; return 1; };
}
