#!/bin/bash

if [ ! -z "${PackageCbindgen[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Cbindgen								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageCbindgen;
PackageCbindgen[Source]="https://github.com/mozilla/cbindgen/archive/v0.28.0/cbindgen-0.28.0.tar.gz";
PackageCbindgen[MD5]="0712d991fc8e65121924265d738db71d";
PackageCbindgen[Name]="cbindgen";
PackageCbindgen[Version]="0.28.0";
PackageCbindgen[Package]="${PackageCbindgen[Name]}-${PackageCbindgen[Version]}";
PackageCbindgen[Extension]=".tar.gz";

PackageCbindgen[Programs]="cbindgen";
PackageCbindgen[Libraries]="";
PackageCbindgen[Python]="";

InstallCbindgen()
{
	# Check Installation
	CheckCbindgen && return $?;

	# Check Dependencies
	EchoInfo	"${PackageCbindgen[Name]}> Checking dependencies..."
	Required=(Rustc)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(MakeCa)
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
	EchoInfo	"${PackageCbindgen[Name]}> Building package..."
	_ExtractPackageCbindgen || return $?;
	_BuildCbindgen;
	return $?
}

CheckCbindgen()
{
	CheckInstallation 	"${PackageCbindgen[Programs]}"\
						"${PackageCbindgen[Libraries]}"\
						"${PackageCbindgen[Python]}" 1> /dev/null;
	return $?;
}

CheckCbindgenVerbose()
{
	CheckInstallationVerbose	"${PackageCbindgen[Programs]}"\
								"${PackageCbindgen[Libraries]}"\
								"${PackageCbindgen[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageCbindgen()
{
	DownloadPackage	"${PackageCbindgen[Source]}"	"${SHMAN_PDIR}"	"${PackageCbindgen[Package]}${PackageCbindgen[Extension]}"	"${PackageCbindgen[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageCbindgen[Package]}"	"${PackageCbindgen[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildCbindgen()
{
	if ! cd "${SHMAN_PDIR}${PackageCbindgen[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageCbindgen[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageCbindgen[Package]}/build \
	# 				|| { EchoError "${PackageCbindgen[Name]}> Failed to enter ${SHMAN_PDIR}${PackageCbindgen[Package]}/build"; return 1; }

	# EchoInfo	"${PackageCbindgen[Name]}> Configure"
	# ./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageCbindgen[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCbindgen[Name]}> cargo build --release"
	cargo build --release 1> /dev/null || { EchoTest KO ${PackageCbindgen[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageCbindgen[Name]}> cargo test --release"
	# cargo test --release 1> /dev/null || { EchoTest KO ${PackageCbindgen[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageCbindgen[Name]}> install"
	install -Dm755 target/release/cbindgen /usr/bin/ 1> /dev/null || { EchoTest KO ${PackageCbindgen[Name]} && PressAnyKeyToContinue; return 1; };
}
