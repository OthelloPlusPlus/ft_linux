#!/bin/bash

if [ ! -z "${PackageDConfEditor[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									DConfEditor								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageDConfEditor;
PackageDConfEditor[Source]="https://download.gnome.org/sources/dconf-editor/45/dconf-editor-45.0.1.tar.xz";
PackageDConfEditor[MD5]="82b2f5d396e95757ad7eaf89c82decd6";
PackageDConfEditor[Name]="dconf-editor";
PackageDConfEditor[Version]="45.0.1";
PackageDConfEditor[Package]="${PackageDConfEditor[Name]}-${PackageDConfEditor[Version]}";
PackageDConfEditor[Extension]=".tar.xz";

PackageDConfEditor[Programs]="dconf-editor";
PackageDConfEditor[Libraries]="libdconfsettings.so";
PackageDConfEditor[Python]="";

InstallDConfEditor()
{
	# Check Installation
	CheckDConfEditor && return $?;

	# Check Dependencies
	EchoInfo	"${PackageDConfEditor[Name]}> Checking dependencies..."
	# Added DesktopFileUtils, which it wont build without
	Required=(GTK3 LibHandy LibXml2 DesktopFileUtils DConf)
	for Dependency in "${Required[@]}"; do
		echo "careful for DConf circular dependency..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageDConfEditor[Name]}> Building package..."
	_ExtractPackageDConfEditor || return $?;
	_BuildDConfEditor;
	return $?
}

CheckDConfEditor()
{
	CheckInstallation 	"${PackageDConfEditor[Programs]}"\
						"${PackageDConfEditor[Libraries]}"\
						"${PackageDConfEditor[Python]}" 1> /dev/null;
	return $?;
}

CheckDConfEditorVerbose()
{
	CheckInstallationVerbose	"${PackageDConfEditor[Programs]}"\
								"${PackageDConfEditor[Libraries]}"\
								"${PackageDConfEditor[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageDConfEditor()
{
	DownloadPackage	"${PackageDConfEditor[Source]}"	"${SHMAN_PDIR}"	"${PackageDConfEditor[Package]}${PackageDConfEditor[Extension]}"	"${PackageDConfEditor[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageDConfEditor[Package]}"	"${PackageDConfEditor[Extension]}" || return $?;

	for URL in \
	# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildDConfEditor()
{
	if ! cd "${SHMAN_PDIR}${PackageDConfEditor[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageDConfEditor[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageDConfEditor[Package]}/build \
					|| { EchoError "${PackageDConfEditor[Name]}> Failed to enter ${SHMAN_PDIR}${PackageDConfEditor[Package]}/build"; return 1; }

	EchoInfo	"${PackageDConfEditor[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageDConfEditor[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDConfEditor[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageDConfEditor[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDConfEditor[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageDConfEditor[Name]} && PressAnyKeyToContinue; return 1; };
}
