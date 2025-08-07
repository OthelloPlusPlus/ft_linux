#!/bin/bash

if [ ! -z "${PackageCargoC[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									CargoC								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageCargoC;
# Manual
PackageCargoC[Source]="https://github.com/lu-zero/cargo-c/archive/v0.10.11/cargo-c-0.10.11.tar.gz";
PackageCargoC[MD5]="727bcba75cf4e65313bb3a1b084bb57e";
# Automated unless edgecase
PackageCargoC[Name]="";
PackageCargoC[Version]="";
PackageCargoC[Extension]="";
if [[ -n "${PackageCargoC[Source]}" ]]; then
	filename="${PackageCargoC[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageCargoC[Name]}" ]] && PackageCargoC[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageCargoC[Version]}" ]] && PackageCargoC[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageCargoC[Extension]}" ]] && PackageCargoC[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageCargoC[Package]="${PackageCargoC[Name]}-${PackageCargoC[Version]}";

PackageCargoC[Programs]="cargo-capi cargo-cbuild cargo-cinstall cargo-ctest";
PackageCargoC[Libraries]="";
PackageCargoC[Python]="";

InstallCargoC()
{
	# Check Installation
	CheckCargoC && return $?;

	# Check Dependencies
	EchoInfo	"${PackageCargoC[Name]}> Checking dependencies..."
	Required=(Rustc MakeCa cURL) #added MakeCa and cURL, because the installatoin needs it
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(LibSsh2 SQLite)
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageCargoC[Name]}> Building package..."
	_ExtractPackageCargoC || return $?;
	_BuildCargoC;
	return $?
}

CheckCargoC()
{
	CheckInstallation 	"${PackageCargoC[Programs]}"\
						"${PackageCargoC[Libraries]}"\
						"${PackageCargoC[Python]}" 1> /dev/null;
	return $?;
}

CheckCargoCVerbose()
{
	CheckInstallationVerbose	"${PackageCargoC[Programs]}"\
								"${PackageCargoC[Libraries]}"\
								"${PackageCargoC[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageCargoC()
{
	DownloadPackage	"${PackageCargoC[Source]}"	"${SHMAN_PDIR}"	"${PackageCargoC[Package]}${PackageCargoC[Extension]}"	"${PackageCargoC[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageCargoC[Package]}"	"${PackageCargoC[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildCargoC()
{
	if ! cd "${SHMAN_PDIR}${PackageCargoC[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageCargoC[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageCargoC[Name]}> Download appropriate version"
	curl -LO https://github.com/lu-zero/cargo-c/releases/download/v0.10.11/Cargo.lock

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageCargoC[Package]}/build \
	# 				|| { EchoError "${PackageCargoC[Name]}> Failed to enter ${SHMAN_PDIR}${PackageCargoC[Package]}/build"; return 1; }

	EchoInfo	"${PackageCargoC[Name]}> Add env variables if needed"
	[ ! -e /usr/include/libssh2.h ] || export LIBSSH2_SYS_USE_PKG_CONFIG=1
	[ ! -e /usr/include/sqlite3.h ] || export LIBSQLITE3_SYS_USE_PKG_CONFIG=1

	EchoInfo	"${PackageCargoC[Name]}> cargo build"
	cargo build --release 1> /dev/null || { EchoTest KO ${PackageCargoC[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCargoC[Name]}> cargo test"
	cargo test --release 1> /dev/null || { EchoTest KO ${PackageCargoC[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCargoC[Name]}> install"
	install -vm755 target/release/cargo-{capi,cbuild,cinstall,ctest} /usr/bin/ 1> /dev/null || { EchoTest KO ${PackageCargoC[Name]} && PressAnyKeyToContinue; return 1; };
}
