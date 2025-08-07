#!/bin/bash

if [ ! -z "${PackageLittleCMS2[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LittleCMS2								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLittleCMS2;
# Manual
PackageLittleCMS2[Source]="https://github.com/mm2/Little-CMS/releases/download/lcms2.17/lcms2-2.17.tar.gz";
PackageLittleCMS2[MD5]="9f44275ee8ac122817e94fdc50ecce13";
# Automated unless edgecase
PackageLittleCMS2[Name]="";
PackageLittleCMS2[Version]="";
PackageLittleCMS2[Extension]="";
if [[ -n "${PackageLittleCMS2[Source]}" ]]; then
	filename="${PackageLittleCMS2[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLittleCMS2[Name]}" ]] && PackageLittleCMS2[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLittleCMS2[Version]}" ]] && PackageLittleCMS2[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLittleCMS2[Extension]}" ]] && PackageLittleCMS2[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLittleCMS2[Package]="${PackageLittleCMS2[Name]}-${PackageLittleCMS2[Version]}";

PackageLittleCMS2[Programs]="jpgicc linkicc psicc tificc transicc";
PackageLittleCMS2[Libraries]="liblcms2.so";
PackageLittleCMS2[Python]="";

InstallLittleCMS2()
{
	# Check Installation
	CheckLittleCMS2 && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLittleCMS2[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageLittleCMS2[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageLittleCMS2[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(LibJpegTurbo LibTiff4)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageLittleCMS2[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLittleCMS2[Name]}> Building package..."
	_ExtractPackageLittleCMS2 || return $?;
	_BuildLittleCMS2;
	return $?
}

CheckLittleCMS2()
{
	CheckInstallation 	"${PackageLittleCMS2[Programs]}"\
						"${PackageLittleCMS2[Libraries]}"\
						"${PackageLittleCMS2[Python]}" 1> /dev/null;
	return $?;
}

CheckLittleCMS2Verbose()
{
	CheckInstallationVerbose	"${PackageLittleCMS2[Programs]}"\
								"${PackageLittleCMS2[Libraries]}"\
								"${PackageLittleCMS2[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLittleCMS2()
{
	DownloadPackage	"${PackageLittleCMS2[Source]}"	"${SHMAN_PDIR}"	"${PackageLittleCMS2[Package]}${PackageLittleCMS2[Extension]}"	"${PackageLittleCMS2[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLittleCMS2[Package]}"	"${PackageLittleCMS2[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLittleCMS2()
{
	if ! cd "${SHMAN_PDIR}${PackageLittleCMS2[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLittleCMS2[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLittleCMS2[Package]}/build \
	# 				|| { EchoError "${PackageLittleCMS2[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLittleCMS2[Package]}/build"; return 1; }

	EchoInfo	"${PackageLittleCMS2[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageLittleCMS2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLittleCMS2[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLittleCMS2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLittleCMS2[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLittleCMS2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLittleCMS2[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLittleCMS2[Name]} && PressAnyKeyToContinue; return 1; };
}
