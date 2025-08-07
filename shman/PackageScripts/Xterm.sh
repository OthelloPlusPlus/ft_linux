#!/bin/bash

if [ ! -z "${PackageXterm[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Xterm								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXterm;
# Manual
PackageXterm[Source]="https://invisible-mirror.net/archives/xterm/xterm-397.tgz";
PackageXterm[MD5]="f8bffb37b6dcbb9757c2a8f7484e5085";
# Automated unless edgecase
PackageXterm[Name]="xterm";
PackageXterm[Version]="397";
PackageXterm[Extension]=".tgz";
if [[ -n "${PackageXterm[Source]}" ]]; then
	filename="${PackageXterm[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageXterm[Name]}" ]] && PackageXterm[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageXterm[Version]}" ]] && PackageXterm[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageXterm[Extension]}" ]] && PackageXterm[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageXterm[Package]="${PackageXterm[Name]}-${PackageXterm[Version]}";

PackageXterm[Programs]="koi8rxterm resize uxterm xterm";
PackageXterm[Libraries]="";
PackageXterm[Python]="";

InstallXterm()
{
	# Check Installation
	CheckXterm && return $?;

	# Check Dependencies
	EchoInfo	"${PackageXterm[Name]}> Checking dependencies..."
	Required=(Luit)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageXterm[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageXterm[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Emacs Pcre2 Valgrind)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageXterm[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageXterm[Name]}> Building package..."
	_ExtractPackageXterm || return $?;
	_BuildXterm;
	return $?
}

CheckXterm()
{
	CheckInstallation 	"${PackageXterm[Programs]}"\
						"${PackageXterm[Libraries]}"\
						"${PackageXterm[Python]}" 1> /dev/null;
	return $?;
}

CheckXtermVerbose()
{
	CheckInstallationVerbose	"${PackageXterm[Programs]}"\
								"${PackageXterm[Libraries]}"\
								"${PackageXterm[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageXterm()
{
	DownloadPackage	"${PackageXterm[Source]}"	"${SHMAN_PDIR}"	"${PackageXterm[Package]}${PackageXterm[Extension]}"	"${PackageXterm[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageXterm[Package]}"	"${PackageXterm[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildXterm()
{
	if ! cd "${SHMAN_PDIR}${PackageXterm[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageXterm[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageXterm[Name]}> termcap"
	sed -i '/v0/{n;s/new:/new:kb=^?:/}' termcap  1> /dev/null || { EchoTest KO ${PackageXterm[Name]} && PressAnyKeyToContinue; return 1; };
	if ! grep -qP '\tkbs=\\177,' terminfo; then
		printf '\tkbs=\\177,\n' >> terminfo 1> /dev/null || { EchoTest KO ${PackageXterm[Name]} && PressAnyKeyToContinue; return 1; };
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageXterm[Package]}/build \
	# 				|| { EchoError "${PackageXterm[Name]}> Failed to enter ${SHMAN_PDIR}${PackageXterm[Package]}/build"; return 1; }

	EchoInfo	"${PackageXterm[Name]}> Configure"
	TERMINFO=/usr/share/terminfo \
	./configure $XORG_CONFIG \
				--with-app-defaults=/etc/X11/app-defaults \
				1> /dev/null || { EchoTest KO ${PackageXterm[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXterm[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageXterm[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXterm[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageXterm[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXterm[Name]}> Copy *.desktop"
	mkdir -pv /usr/share/applications
	cp -v *.desktop /usr/share/applications/

	EchoInfo	"${PackageXterm[Name]}> /etc/X11/app-defaults/XTerm"
	if ! grep -qF '*VT100*locale: true' /etc/X11/app-defaults/XTerm; then
		cat >> /etc/X11/app-defaults/XTerm << "EOF"
*VT100*locale: true
*VT100*faceName: Monospace
*VT100*faceSize: 10
*backarrowKeyIsErase: true
*ptyInitialErase: true

*background: #232323
*foreground: #cccccc

EOF
	fi
}
