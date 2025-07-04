#!/bin/bash

if [ ! -z "${PackageVala[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Vala								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageVala;
PackageVala[Source]="https://download.gnome.org/sources/vala/0.56/vala-0.56.17.tar.xz";
PackageVala[MD5]="134075855867fdd9c51ca7555c4951bb";
PackageVala[Name]="vala";
PackageVala[Version]="0.56.17";
PackageVala[Package]="${PackageVala[Name]}-${PackageVala[Version]}";
PackageVala[Extension]=".tar.xz";

PackageVala[Programs]="vala vala-0.56 valac vala-gen-introspect vapigen valac-0.56 vala-gen-introspect-0.56 vapigen-0.56";
PackageVala[Libraries]="libvala-0.56.so";
PackageVala[Python]="";

InstallVala()
{
	# Check Installation
	CheckVala && return $?;

	# Check Dependencies
	EchoInfo	"${PackageVala[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageVala[Name]}> Building package..."
	_ExtractPackageVala || return $?;
	_BuildVala;
	return $?
}

CheckVala()
{
	CheckInstallation 	"${PackageVala[Programs]}"\
						"${PackageVala[Libraries]}"\
						"${PackageVala[Python]}" 1> /dev/null;
	return $?;
}

CheckValaVerbose()
{
	CheckInstallationVerbose	"${PackageVala[Programs]}"\
								"${PackageVala[Libraries]}"\
								"${PackageVala[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageVala()
{
	DownloadPackage	"${PackageVala[Source]}"	"${SHMAN_PDIR}"	"${PackageVala[Package]}${PackageVala[Extension]}"	"${PackageVala[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageVala[Package]}"	"${PackageVala[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildVala()
{
	if ! cd "${SHMAN_PDIR}${PackageVala[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageVala[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageVala[Package]}/build \
	# 				|| { EchoError "${PackageVala[Name]}> Failed to enter ${SHMAN_PDIR}${PackageVala[Package]}/build"; return 1; }

	EchoInfo	"${PackageVala[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-valadoc \
				1> /dev/null || { EchoTest KO ${PackageVala[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageVala[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageVala[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageVala[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageVala[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageVala[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageVala[Name]} && PressAnyKeyToContinue; return 1; };
}
