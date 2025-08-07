#!/bin/bash

if [ ! -z "${PackageXorgFonts[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									XorgFonts								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXorgFonts;
# Manual
PackageXorgFonts[Source]="https://www.x.org/pub/individual/font/";
PackageXorgFonts[MD5]="";
# Automated unless edgecase
PackageXorgFonts[Name]="xorgfonts";
PackageXorgFonts[Version]="";
PackageXorgFonts[Extension]="";
if [[ -n "${PackageXorgFonts[Source]}" ]]; then
	filename="${PackageXorgFonts[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageXorgFonts[Name]}" ]] && PackageXorgFonts[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageXorgFonts[Version]}" ]] && PackageXorgFonts[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageXorgFonts[Extension]}" ]] && PackageXorgFonts[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageXorgFonts[Package]="${PackageXorgFonts[Name]}-${PackageXorgFonts[Version]}";

PackageXorgFonts[Programs]="bdftruncate ucs2any";
PackageXorgFonts[Libraries]="";
PackageXorgFonts[Python]="";

InstallXorgFonts()
{
	# Check Installation
	CheckXorgFonts && return $?;

	# Check Dependencies
	EchoInfo	"${PackageXorgFonts[Name]}> Checking dependencies..."
	Required=(XcursorThemes)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageXorgFonts[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageXorgFonts[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageXorgFonts[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageXorgFonts[Name]}> Building package..."
	if [ $(whoami) != "root" ]; then return 1; fi
	_ExtractPackageXorgFonts || return $?;
	_BuildXorgFonts;
	return $?
}

CheckXorgFonts()
{
	CheckInstallation 	"${PackageXorgFonts[Programs]}"\
						"${PackageXorgFonts[Libraries]}"\
						"${PackageXorgFonts[Python]}" 1> /dev/null;
	return $?;
}

CheckXorgFontsVerbose()
{
	CheckInstallationVerbose	"${PackageXorgFonts[Programs]}"\
								"${PackageXorgFonts[Libraries]}"\
								"${PackageXorgFonts[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageXorgFonts()
{
	mkdir -p ${SHMAN_PDIR}${PackageXorgFonts[Package]} 	&& cd ${SHMAN_PDIR}${PackageXorgFonts[Package]} \
	 				|| { EchoError "${PackageXorgFonts[Name]}> Failed to enter ${SHMAN_PDIR}${PackageXorgFonts[Package]}"; return 1; }

	cat > font-7.md5 << "EOF"
a6541d12ceba004c0c1e3df900324642  font-util-1.4.1.tar.xz
a56b1a7f2c14173f71f010225fa131f1  encodings-1.1.0.tar.xz
79f4c023e27d1db1dfd90d041ce89835  font-alias-1.0.5.tar.xz
546d17feab30d4e3abcf332b454f58ed  font-adobe-utopia-type1-1.0.5.tar.xz
063bfa1456c8a68208bf96a33f472bb1  font-bh-ttf-1.0.4.tar.xz
51a17c981275439b85e15430a3d711ee  font-bh-type1-1.0.4.tar.xz
00f64a84b6c9886040241e081347a853  font-ibm-type1-1.0.4.tar.xz
fe972eaf13176fa9aa7e74a12ecc801a  font-misc-ethiopic-1.0.5.tar.xz
3b47fed2c032af3a32aad9acc1d25150  font-xfree86-type1-1.0.5.tar.xz
EOF

	mkdir -p font 	&& cd ${SHMAN_PDIR}${PackageXorgFonts[Package]}/font \
					|| { EchoError "${PackageXorgFonts[Name]}> Failed to enter ${SHMAN_PDIR}${PackageXorgFonts[Package]}/font"; return 1; }

	grep -v '^#' ../font-7.md5 | \
		awk '{print $2}' | \
		wget -i- -c \
			-B https://www.x.org/pub/individual/font/
	md5sum -c ../font-7.md5

	return $?;
}

_BuildXorgFonts()
{
	if ! cd "${SHMAN_PDIR}${PackageXorgFonts[Package]}/font"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageXorgFonts[Package]}/font";
		return 1;
	fi

	for package in $(grep -v '^#' ../font-7.md5 | awk '{print $2}'); do
		EchoInfo	"${PackageXorgFonts[Name]}> $package"
		packagedir=${package%.tar.?z*}
		tar -xf $package
		pushd $packagedir
			./configure $XORG_CONFIG 1> /dev/null && \
			make 1> /dev/null && \
			make install|| { 
				EchoTest KO "${PackageXorgFonts[Name]} $package";
				PressAnyKeyToContinue;
				return 1;
			};
		popd
		rm -rf $packagedir
	done

	EchoInfo	"${PackageXorgFonts[Name]}> install"
	install -v -d -m755 /usr/share/fonts 1> /dev/null || { EchoTest KO ${PackageXorgFonts[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXorgFonts[Name]}> Symbolic links"
	ln -svfn $XORG_PREFIX/share/fonts/X11/OTF /usr/share/fonts/X11-OTF
	ln -svfn $XORG_PREFIX/share/fonts/X11/TTF /usr/share/fonts/X11-TTF
}
