#!/bin/bash

if [ ! -z "${PackageDuktape[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Duktape								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageDuktape;
# Manual
PackageDuktape[Source]="https://duktape.org/duktape-2.7.0.tar.xz";
PackageDuktape[MD5]="b3200b02ab80125b694bae887d7c1ca6";
# Automated unless edgecase
PackageDuktape[Name]="";
PackageDuktape[Version]="";
PackageDuktape[Extension]="";
if [[ -n "${PackageDuktape[Source]}" ]]; then
	filename="${PackageDuktape[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageDuktape[Name]}" ]] && PackageDuktape[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageDuktape[Version]}" ]] && PackageDuktape[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageDuktape[Extension]}" ]] && PackageDuktape[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageDuktape[Package]="${PackageDuktape[Name]}-${PackageDuktape[Version]}";

PackageDuktape[Programs]="";
PackageDuktape[Libraries]="libduktape.so libduktaped.so";
PackageDuktape[Python]="";

InstallDuktape()
{
	# Check Installation
	CheckDuktape && return $?;

	# Check Dependencies
	EchoInfo	"${PackageDuktape[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
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
	EchoInfo	"${PackageDuktape[Name]}> Building package..."
	_ExtractPackageDuktape || return $?;
	_BuildDuktape;
	return $?
}

CheckDuktape()
{
	ldd /usr/lib/libduktape.so /usr/lib/libduktaped.so >/dev/null
	return $?;
	# CheckInstallation 	"${PackageDuktape[Programs]}"\
	# 					"${PackageDuktape[Libraries]}"\
	# 					"${PackageDuktape[Python]}" 1> /dev/null;
}

CheckDuktapeVerbose()
{
	ldd /usr/lib/libduktape.so >/dev/null || { echo -en "${C_RED}libduktape.so${C_RESET} "; return 1; };
	ldd /usr/lib/libduktaped.so >/dev/null || echo -en "${C_RED}libduktaped.so${C_RESET} ";
	return $?;
	# CheckInstallationVerbose	"${PackageDuktape[Programs]}"\
	# 							"${PackageDuktape[Libraries]}"\
	# 							"${PackageDuktape[Python]}";
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageDuktape()
{
	DownloadPackage	"${PackageDuktape[Source]}"	"${SHMAN_PDIR}"	"${PackageDuktape[Package]}${PackageDuktape[Extension]}"	"${PackageDuktape[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageDuktape[Package]}"	"${PackageDuktape[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildDuktape()
{
	if ! cd "${SHMAN_PDIR}${PackageDuktape[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageDuktape[Package]}";
		return 1;
	fi

	sed -i 's/-Os/-O2/' Makefile.sharedlibrary

	EchoInfo	"${PackageDuktape[Name]}> make"
	make -f Makefile.sharedlibrary INSTALL_PREFIX=/usr 1> /dev/null || { EchoTest KO ${PackageDuktape[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDuktape[Name]}> make install"
	make -f Makefile.sharedlibrary INSTALL_PREFIX=/usr install 1> /dev/null || { EchoTest KO ${PackageDuktape[Name]} && PressAnyKeyToContinue; return 1; };
}
