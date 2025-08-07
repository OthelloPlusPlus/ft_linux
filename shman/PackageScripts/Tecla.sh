#!/bin/bash

if [ ! -z "${PackageTecla[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Tecla								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageTecla;
# Manual
PackageTecla[Source]="https://download.gnome.org/sources/tecla/47/tecla-47.0.tar.xz";
PackageTecla[MD5]="68233c486bfe8b86f759fdd9ae1be00a";
# Automated unless edgecase
PackageTecla[Name]="";
PackageTecla[Version]="";
PackageTecla[Extension]="";
if [[ -n "${PackageTecla[Source]}" ]]; then
	filename="${PackageTecla[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageTecla[Name]}" ]] && PackageTecla[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageTecla[Version]}" ]] && PackageTecla[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageTecla[Extension]}" ]] && PackageTecla[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageTecla[Package]="${PackageTecla[Name]}-${PackageTecla[Version]}";

PackageTecla[Programs]="tecla";
PackageTecla[Libraries]="";
PackageTecla[Python]="";

InstallTecla()
{
	# Check Installation
	CheckTecla && return $?;

	# Check Dependencies
	EchoInfo	"${PackageTecla[Name]}> Checking dependencies..."
	Required=(LibAdwaita LibXkbCommon)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageTecla[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageTecla[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageTecla[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageTecla[Name]}> Building package..."
	_ExtractPackageTecla || return $?;
	_BuildTecla || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageTecla[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckTecla()
{
	CheckInstallation 	"${PackageTecla[Programs]}"\
						"${PackageTecla[Libraries]}"\
						"${PackageTecla[Python]}" 1> /dev/null;
	return $?;
}

CheckTeclaVerbose()
{
	CheckInstallationVerbose	"${PackageTecla[Programs]}"\
								"${PackageTecla[Libraries]}"\
								"${PackageTecla[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageTecla()
{
	DownloadPackage	"${PackageTecla[Source]}"	"${SHMAN_PDIR}"	"${PackageTecla[Package]}${PackageTecla[Extension]}"	"${PackageTecla[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageTecla[Package]}"	"${PackageTecla[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildTecla()
{
	if ! cd "${SHMAN_PDIR}${PackageTecla[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageTecla[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageTecla[Package]}/build \
					|| { EchoError "${PackageTecla[Name]}> Failed to enter ${SHMAN_PDIR}${PackageTecla[Package]}/build"; return 1; }

	EchoInfo	"${PackageTecla[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageTecla[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTecla[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageTecla[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTecla[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageTecla[Name]} && PressAnyKeyToContinue; return 1; };
}
