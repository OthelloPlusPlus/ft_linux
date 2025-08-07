#!/bin/bash

if [ ! -z "${PackageHarfBuzz[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									HarfBuzz								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageHarfBuzz;
PackageHarfBuzz[Source]="https://github.com/harfbuzz/harfbuzz/releases/download/10.4.0/harfbuzz-10.4.0.tar.xz";
PackageHarfBuzz[MD5]="9ff3796c1b8ae03540e466168c6a5bd1";
PackageHarfBuzz[Name]="harfbuzz";
PackageHarfBuzz[Version]="10.4.0";
PackageHarfBuzz[Package]="${PackageHarfBuzz[Name]}-${PackageHarfBuzz[Version]}";
PackageHarfBuzz[Extension]=".tar.xz";

PackageHarfBuzz[Programs]="hb-info hb-ot-shape-closure hb-shape hb-subset";
PackageHarfBuzz[Libraries]="libharfbuzz.so libharfbuzz-gobject.so libharfbuzz-icu.so libharfbuzz-subset.so";
PackageHarfBuzz[Python]="";

InstallHarfBuzz()
{
	# Check Installation
	CheckHarfBuzz && return $?;

	EchoInfo	"${PackageHarfBuzz[Name]}> Checking dependencies..."

	# Check Dependencies
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	# removed FreeType because of circular dependency, because why create clean stuff people...
	Recommended=(GLib Graphite2 Texlive LibreOffice ICU FreeTypeChain)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	# removed Cairo because of circular dependency, because why create clean stuff people...
	Optional=(Git GTKDoc)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageHarfBuzz[Name]}> Building package..."
	_ExtractPackageHarfBuzz || return $?;
	_BuildHarfBuzz;
	return $?
}

CheckHarfBuzz()
{
	CheckInstallation 	"${PackageHarfBuzz[Programs]}"\
						"${PackageHarfBuzz[Libraries]}"\
						"${PackageHarfBuzz[Python]}" 1> /dev/null;
	return $?;
}

CheckHarfBuzzVerbose()
{
	CheckInstallationVerbose	"${PackageHarfBuzz[Programs]}"\
								"${PackageHarfBuzz[Libraries]}"\
								"${PackageHarfBuzz[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageHarfBuzz()
{
	DownloadPackage	"${PackageHarfBuzz[Source]}"	"${SHMAN_PDIR}"	"${PackageHarfBuzz[Package]}${PackageHarfBuzz[Extension]}"	"${PackageHarfBuzz[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageHarfBuzz[Package]}"	"${PackageHarfBuzz[Extension]}" || return $?;

	return $?;
}

_BuildHarfBuzz()
{
	if ! cd "${SHMAN_PDIR}${PackageHarfBuzz[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageHarfBuzz[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageHarfBuzz[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageHarfBuzz[Package]}/build";

	EchoInfo	"${PackageHarfBuzz[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				1> /dev/null || { EchoTest KO ${PackageHarfBuzz[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageHarfBuzz[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageHarfBuzz[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageHarfBuzz[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageHarfBuzz[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageHarfBuzz[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageHarfBuzz[Name]} && PressAnyKeyToContinue; return 1; };
}
