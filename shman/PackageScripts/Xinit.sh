#!/bin/bash

if [ ! -z "${PackageXinit[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Xinit								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXinit;
# Manual
PackageXinit[Source]="https://www.x.org/pub/individual/app/xinit-1.4.3.tar.xz";
PackageXinit[MD5]="2f82c02a9408cbb5a6191c4b62763438";
# Automated unless edgecase
PackageXinit[Name]="";
PackageXinit[Version]="";
PackageXinit[Extension]="";
if [[ -n "${PackageXinit[Source]}" ]]; then
	filename="${PackageXinit[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageXinit[Name]}" ]] && PackageXinit[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageXinit[Version]}" ]] && PackageXinit[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageXinit[Extension]}" ]] && PackageXinit[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageXinit[Package]="${PackageXinit[Name]}-${PackageXinit[Version]}";

PackageXinit[Programs]="xinit startx";
PackageXinit[Libraries]="";
PackageXinit[Python]="";

InstallXinit()
{
	# Check Installation
	CheckXinit && return $?;

	# Check Dependencies
	EchoInfo	"${PackageXinit[Name]}> Checking dependencies..."
	Required=(XorgLibraries)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageXinit[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Twm Xclock Xterm)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageXinit[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageXinit[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageXinit[Name]}> Building package..."
	_ExtractPackageXinit || return $?;
	_BuildXinit;
	return $?
}

CheckXinit()
{
	CheckInstallation 	"${PackageXinit[Programs]}"\
						"${PackageXinit[Libraries]}"\
						"${PackageXinit[Python]}" 1> /dev/null;
	return $?;
}

CheckXinitVerbose()
{
	CheckInstallationVerbose	"${PackageXinit[Programs]}"\
								"${PackageXinit[Libraries]}"\
								"${PackageXinit[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageXinit()
{
	DownloadPackage	"${PackageXinit[Source]}"	"${SHMAN_PDIR}"	"${PackageXinit[Package]}${PackageXinit[Extension]}"	"${PackageXinit[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageXinit[Package]}"	"${PackageXinit[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildXinit()
{
	if ! cd "${SHMAN_PDIR}${PackageXinit[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageXinit[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageXinit[Package]}/build \
	# 				|| { EchoError "${PackageXinit[Name]}> Failed to enter ${SHMAN_PDIR}${PackageXinit[Package]}/build"; return 1; }

	EchoInfo	"${PackageXinit[Name]}> Configure"
	./configure $XORG_CONFIG \
				--with-xinitdir=/etc/X11/app-defaults \
				1> /dev/null || { EchoTest KO ${PackageXinit[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXinit[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageXinit[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXinit[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageXinit[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXinit[Name]}> ldconfig"
	ldconfig 1> /dev/null || { EchoTest KO ${PackageXinit[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXinit[Name]}> Automatically start Xorg on the first available virtual terminal"
	chmod u+s $XORG_PREFIX/bin/Xorg
	sed -i '/$serverargs $vtarg/ s/serverargs/: #&/' $XORG_PREFIX/bin/startx
}
