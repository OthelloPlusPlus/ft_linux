#!/bin/bash

if [ ! -z "${PackagePango[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Pango								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePango;
PackagePango[Source]="https://download.gnome.org/sources/pango/1.56/pango-1.56.1.tar.xz";
PackagePango[MD5]="57656aefa189a5b24f3b1e67df7216b6";
PackagePango[Name]="pango";
PackagePango[Version]="1.56.1";
PackagePango[Package]="${PackagePango[Name]}-${PackagePango[Version]}";
PackagePango[Extension]=".tar.xz";

PackagePango[Programs]="pango-list pango-segmentation pango-view";
PackagePango[Libraries]="libpango-1.0.so libpangocairo-1.0.so libpangoft2-1.0.so libpangoxft-1.0.so";
PackagePango[Python]="";

InstallPango()
{
	# Check Installation
	CheckPango && return $?;

	# Check Dependencies
	EchoInfo	"${PackagePango[Name]}> Checking dependencies..."
	Required=(FriBidi GLib FreeTypeChain)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(GiDocGen)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackagePango[Name]}> Building package..."
	_ExtractPackagePango || return $?;
	_BuildPango;
	return $?
}

CheckPango()
{
	CheckInstallation 	"${PackagePango[Programs]}"\
						"${PackagePango[Libraries]}"\
						"${PackagePango[Python]}" 1> /dev/null;
	return $?;
}

CheckPangoVerbose()
{
	CheckInstallationVerbose	"${PackagePango[Programs]}"\
								"${PackagePango[Libraries]}"\
								"${PackagePango[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackagePango()
{
	DownloadPackage	"${PackagePango[Source]}"	"${SHMAN_PDIR}"	"${PackagePango[Package]}${PackagePango[Extension]}"	"${PackagePango[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackagePango[Package]}"	"${PackagePango[Extension]}" || return $?;

	return $?;
}

_BuildPango()
{
	if ! cd "${SHMAN_PDIR}${PackagePango[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackagePango[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackagePango[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackagePango[Package]}/build";

	EchoInfo	"${PackagePango[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				--wrap-mode=nofallback \
				-D introspection=enabled \
				.. \
				1> /dev/null || { EchoTest KO ${PackagePango[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePango[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackagePango[Name]} && PressAnyKeyToContinue; return 1; };

	if "${SHMAN_SDIR}/GiDocGen.sh" && CheckGiDocGen; then
		sed "/docs_dir =/s@\$@ / 'pango-1.56.1'@" -i ../docs/meson.build && \
		meson configure -D documentation=true && \
		ninja
	fi

	# EchoInfo	"${PackagePango[Name]}> ninja test"
	# ninja test 1> /dev/null || { EchoTest KO ${PackagePango[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackagePango[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackagePango[Name]} && PressAnyKeyToContinue; return 1; };
}
