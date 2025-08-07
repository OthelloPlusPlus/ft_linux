#!/bin/bash

if [ ! -z "${PackageLibXmlb[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibXmlb								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibXmlb;
# Manual
PackageLibXmlb[Source]="https://github.com/hughsie/libxmlb/releases/download/0.3.21/libxmlb-0.3.21.tar.xz";
PackageLibXmlb[MD5]="6f83ad887ffacaa1f393650845eb8a1b";
# Automated unless edgecase
PackageLibXmlb[Name]="";
PackageLibXmlb[Version]="";
PackageLibXmlb[Extension]="";
if [[ -n "${PackageLibXmlb[Source]}" ]]; then
	filename="${PackageLibXmlb[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibXmlb[Name]}" ]] && PackageLibXmlb[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibXmlb[Version]}" ]] && PackageLibXmlb[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibXmlb[Extension]}" ]] && PackageLibXmlb[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibXmlb[Package]="${PackageLibXmlb[Name]}-${PackageLibXmlb[Version]}";

PackageLibXmlb[Programs]="xb-tool";
PackageLibXmlb[Libraries]="libxmlb.so";
PackageLibXmlb[Python]="";

InstallLibXmlb()
{
	# Check Installation
	CheckLibXmlb && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibXmlb[Name]}> Checking dependencies..."
	Required=(GLib)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageLibXmlb[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageLibXmlb[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(GTKDoc)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageLibXmlb[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibXmlb[Name]}> Building package..."
	_ExtractPackageLibXmlb || return $?;
	_BuildLibXmlb || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageLibXmlb[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckLibXmlb()
{
	CheckInstallation 	"${PackageLibXmlb[Programs]}"\
						"${PackageLibXmlb[Libraries]}"\
						"${PackageLibXmlb[Python]}" 1> /dev/null;
	return $?;
}

CheckLibXmlbVerbose()
{
	CheckInstallationVerbose	"${PackageLibXmlb[Programs]}"\
								"${PackageLibXmlb[Libraries]}"\
								"${PackageLibXmlb[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibXmlb()
{
	DownloadPackage	"${PackageLibXmlb[Source]}"	"${SHMAN_PDIR}"	"${PackageLibXmlb[Package]}${PackageLibXmlb[Extension]}"	"${PackageLibXmlb[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibXmlb[Package]}"	"${PackageLibXmlb[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibXmlb()
{
	if ! cd "${SHMAN_PDIR}${PackageLibXmlb[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibXmlb[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibXmlb[Package]}/build \
					|| { EchoError "${PackageLibXmlb[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibXmlb[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibXmlb[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D gtkdoc=false \
				.. \
				1> /dev/null || { EchoTest KO ${PackageLibXmlb[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXmlb[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibXmlb[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXmlb[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageLibXmlb[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXmlb[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibXmlb[Name]} && PressAnyKeyToContinue; return 1; };
}
