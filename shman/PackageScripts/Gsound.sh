#!/bin/bash

if [ ! -z "${PackageGsound[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Gsound								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGsound;
# Manual
PackageGsound[Source]="https://download.gnome.org/sources/gsound/1.0/gsound-1.0.3.tar.xz";
PackageGsound[MD5]="7338c295034432a6e782fd20b3d04b68";
# Automated unless edgecase
PackageGsound[Name]="";
PackageGsound[Version]="";
PackageGsound[Extension]="";
if [[ -n "${PackageGsound[Source]}" ]]; then
	filename="${PackageGsound[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageGsound[Name]}" ]] && PackageGsound[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageGsound[Version]}" ]] && PackageGsound[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageGsound[Extension]}" ]] && PackageGsound[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageGsound[Package]="${PackageGsound[Name]}-${PackageGsound[Version]}";

PackageGsound[Programs]="gsound-play";
PackageGsound[Libraries]="libgsound.so";
PackageGsound[Python]="";

InstallGsound()
{
	# Check Installation
	CheckGsound && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGsound[Name]}> Checking dependencies..."
	Required=(LibCanberra)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageGsound[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GLib Vala)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageGsound[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(GTKDoc)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageGsound[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageGsound[Name]}> Building package..."
	_ExtractPackageGsound || return $?;
	_BuildGsound || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageGsound[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckGsound()
{
	CheckInstallation 	"${PackageGsound[Programs]}"\
						"${PackageGsound[Libraries]}"\
						"${PackageGsound[Python]}" 1> /dev/null;
	return $?;
}

CheckGsoundVerbose()
{
	CheckInstallationVerbose	"${PackageGsound[Programs]}"\
								"${PackageGsound[Libraries]}"\
								"${PackageGsound[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGsound()
{
	DownloadPackage	"${PackageGsound[Source]}"	"${SHMAN_PDIR}"	"${PackageGsound[Package]}${PackageGsound[Extension]}"	"${PackageGsound[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGsound[Package]}"	"${PackageGsound[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildGsound()
{
	if ! cd "${SHMAN_PDIR}${PackageGsound[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGsound[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGsound[Package]}/build \
					|| { EchoError "${PackageGsound[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGsound[Package]}/build"; return 1; }

	EchoInfo	"${PackageGsound[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageGsound[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGsound[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGsound[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGsound[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGsound[Name]} && PressAnyKeyToContinue; return 1; };
}
