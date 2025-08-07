#!/bin/bash

if [ ! -z "${PackageXorgLibinput[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									XorgLibinput								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXorgLibinput;
# Manual
PackageXorgLibinput[Source]="https://www.x.org/pub/individual/driver/xf86-input-libinput-1.5.0.tar.xz";
PackageXorgLibinput[MD5]="f8d0fb6987d843e688d597c2b66ec824";
# Automated unless edgecase
PackageXorgLibinput[Name]="";
PackageXorgLibinput[Version]="";
PackageXorgLibinput[Extension]="";
if [[ -n "${PackageXorgLibinput[Source]}" ]]; then
	filename="${PackageXorgLibinput[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageXorgLibinput[Name]}" ]] && PackageXorgLibinput[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageXorgLibinput[Version]}" ]] && PackageXorgLibinput[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageXorgLibinput[Extension]}" ]] && PackageXorgLibinput[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageXorgLibinput[Package]="${PackageXorgLibinput[Name]}-${PackageXorgLibinput[Version]}";

PackageXorgLibinput[Programs]="";
PackageXorgLibinput[Libraries]="libinput_drv.so";
PackageXorgLibinput[Python]="";

InstallXorgLibinput()
{
	# Check Installation
	CheckXorgLibinput && return $?;

	# Check Dependencies
	EchoInfo	"${PackageXorgLibinput[Name]}> Checking dependencies..."
	Required=(LibInput XorgServer)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageXorgLibinput[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageXorgLibinput[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageXorgLibinput[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageXorgLibinput[Name]}> Building package..."
	_ExtractPackageXorgLibinput || return $?;
	_BuildXorgLibinput;
	return $?
}

CheckXorgLibinput()
{
	[ -f /usr/lib/xorg/modules/input/libinput_drv.so ] && \
	ldd /usr/lib/xorg/modules/input/libinput_drv.so &> /dev/null;
	return $?
}

CheckXorgLibinputVerbose()
{
	if [ ! -f /usr/lib/xorg/modules/input/libinput_drv.so ] || \
		! ldd /usr/lib/xorg/modules/input/libinput_drv.so &> /dev/null; then
		echo -en "${C_RED}libinput_drv.so${C_RESET} " >&2;
		return 1;
	fi
	return 0;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageXorgLibinput()
{
	DownloadPackage	"${PackageXorgLibinput[Source]}"	"${SHMAN_PDIR}"	"${PackageXorgLibinput[Package]}${PackageXorgLibinput[Extension]}"	"${PackageXorgLibinput[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageXorgLibinput[Package]}"	"${PackageXorgLibinput[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildXorgLibinput()
{
	if ! cd "${SHMAN_PDIR}${PackageXorgLibinput[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageXorgLibinput[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageXorgLibinput[Package]}/build \
	# 				|| { EchoError "${PackageXorgLibinput[Name]}> Failed to enter ${SHMAN_PDIR}${PackageXorgLibinput[Package]}/build"; return 1; }

	EchoInfo	"${PackageXorgLibinput[Name]}> Configure"
	./configure $XORG_CONFIG 1> /dev/null || { EchoTest KO ${PackageXorgLibinput[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXorgLibinput[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageXorgLibinput[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXorgLibinput[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageXorgLibinput[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXorgLibinput[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageXorgLibinput[Name]} && PressAnyKeyToContinue; return 1; };
}
