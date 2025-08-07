#!/bin/bash

if [ ! -z "${PackageLibNma[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibNma								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibNma;
# Manual
PackageLibNma[Source]="https://download.gnome.org/sources/libnma/1.10/libnma-1.10.6.tar.xz";
PackageLibNma[MD5]="71c7ce674fea1fae8f1368a7fcb6ff43";
# Automated unless edgecase
PackageLibNma[Name]="";
PackageLibNma[Version]="";
PackageLibNma[Extension]="";
if [[ -n "${PackageLibNma[Source]}" ]]; then
	filename="${PackageLibNma[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibNma[Name]}" ]] && PackageLibNma[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibNma[Version]}" ]] && PackageLibNma[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibNma[Extension]}" ]] && PackageLibNma[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibNma[Package]="${PackageLibNma[Name]}-${PackageLibNma[Version]}";

PackageLibNma[Programs]="";
PackageLibNma[Libraries]="libnma.so libnma-gtk4.so";
PackageLibNma[Python]="";

InstallLibNma()
{
	# Check Installation
	CheckLibNma && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibNma[Name]}> Checking dependencies..."
	Required=(Gcr3 GTK3 ISOCodes NetworkManager)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageLibNma[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GTK4 Vala)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageLibNma[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageLibNma[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibNma[Name]}> Building package..."
	_ExtractPackageLibNma || return $?;
	_BuildLibNma;
	return $?
}

CheckLibNma()
{
	CheckInstallation 	"${PackageLibNma[Programs]}"\
						"${PackageLibNma[Libraries]}"\
						"${PackageLibNma[Python]}" 1> /dev/null;
	return $?;
}

CheckLibNmaVerbose()
{
	CheckInstallationVerbose	"${PackageLibNma[Programs]}"\
								"${PackageLibNma[Libraries]}"\
								"${PackageLibNma[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibNma()
{
	DownloadPackage	"${PackageLibNma[Source]}"	"${SHMAN_PDIR}"	"${PackageLibNma[Package]}${PackageLibNma[Extension]}"	"${PackageLibNma[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibNma[Package]}"	"${PackageLibNma[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibNma()
{
	if ! cd "${SHMAN_PDIR}${PackageLibNma[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibNma[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibNma[Package]}/build \
					|| { EchoError "${PackageLibNma[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibNma[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibNma[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D gtk_doc=false \
				-D libnma_gtk4=true \
				-D mobile_broadband_provider_info=false \
				1> /dev/null || { EchoTest KO ${PackageLibNma[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibNma[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibNma[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibNma[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageLibNma[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibNma[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibNma[Name]} && PressAnyKeyToContinue; return 1; };
}
