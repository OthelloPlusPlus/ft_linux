#!/bin/bash

if [ ! -z "${PackageLmdb[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Lmdb								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLmdb;
# Manual
PackageLmdb[Source]="https://github.com/LMDB/lmdb/archive/LMDB_0.9.31.tar.gz";
PackageLmdb[MD5]="9d7f059b1624d0a4d4b2f1781d08d600";
# Automated unless edgecase
PackageLmdb[Name]="lmdb";
PackageLmdb[Version]="0.9.31";
PackageLmdb[Extension]=".tar.gz";
if [[ -n "${PackageLmdb[Source]}" ]]; then
	filename="${PackageLmdb[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLmdb[Name]}" ]] && PackageLmdb[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLmdb[Version]}" ]] && PackageLmdb[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLmdb[Extension]}" ]] && PackageLmdb[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLmdb[Package]="${PackageLmdb[Name]}-${PackageLmdb[Version]}";

PackageLmdb[Programs]="mdb_copy mdb_dump mdb_load mdb_stat";
PackageLmdb[Libraries]="liblmdb.so";
PackageLmdb[Python]="";

InstallLmdb()
{
	# Check Installation
	CheckLmdb && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLmdb[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageLmdb[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { EchoError "${PackageLmdb[Name]}--->${Dependency}"; PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageLmdb[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { EchoError "${PackageLmdb[Name]}-->${Dependency}"; PressAnyKeyToContinue; }
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageLmdb[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"|| EchoWarning "${PackageLmdb[Name]}->${Dependency}";
		fi
	done

	# Install Package
	EchoInfo	"${PackageLmdb[Name]}> Building package..."
	_ExtractPackageLmdb || return $?;
	_BuildLmdb || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageLmdb[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { EchoError "${PackageLmdb[Name]}=>${Dependency}"; PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckLmdb()
{
	CheckInstallation 	"${PackageLmdb[Programs]}"\
						"${PackageLmdb[Libraries]}"\
						"${PackageLmdb[Python]}" 1> /dev/null;
	return $?;
}

CheckLmdbVerbose()
{
	CheckInstallationVerbose	"${PackageLmdb[Programs]}"\
								"${PackageLmdb[Libraries]}"\
								"${PackageLmdb[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLmdb()
{
	DownloadPackage	"${PackageLmdb[Source]}"	"${SHMAN_PDIR}"	"${PackageLmdb[Package]}${PackageLmdb[Extension]}"	"${PackageLmdb[MD5]}" || return $?;
	mv -f "${SHMAN_PDIR}/LMDB_0.9.31.tar.gz" "${SHMAN_PDIR}/lmdb-0.9.31.tar.gz"
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLmdb[Package]}"	"${PackageLmdb[Extension]}" || return $?;
	mv "${SHMAN_PDIR}/lmdb-LMDB_0.9.31" "${SHMAN_PDIR}/lmdb-0.9.31"

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLmdb()
{
	if ! cd "${SHMAN_PDIR}${PackageLmdb[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLmdb[Package]}";
		return 1;
	fi

	cd libraries/liblmdb

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLmdb[Package]}/build \
	# 				|| { EchoError "${PackageLmdb[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLmdb[Package]}/build"; return 1; }

	# EchoInfo	"${PackageLmdb[Name]}> Configure"
	# ./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageLmdb[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLmdb[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLmdb[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLmdb[Name]}> sed"
	sed -i 's| liblmdb.a||' Makefile

	EchoInfo	"${PackageLmdb[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLmdb[Name]} && PressAnyKeyToContinue; return 1; };
}
