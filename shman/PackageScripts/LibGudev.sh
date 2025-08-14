#!/bin/bash

if [ ! -z "${PackageLibGudev[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibGudev								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibGudev;
PackageLibGudev[Source]="https://download.gnome.org/sources/libgudev/238/libgudev-238.tar.xz";
PackageLibGudev[MD5]="46da30a1c69101c3a13fa660d9ab7b73";
PackageLibGudev[Name]="libgudev";
PackageLibGudev[Version]="238";
PackageLibGudev[Package]="${PackageLibGudev[Name]}-${PackageLibGudev[Version]}";
PackageLibGudev[Extension]=".tar.xz";

PackageLibGudev[Programs]="";
PackageLibGudev[Libraries]="libgudev-1.0.so";
PackageLibGudev[Python]="";

InstallLibGudev()
{
	# Check Installation
	CheckLibGudev && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibGudev[Name]}> Checking dependencies..."
	Required=(GLib)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(GTKDoc Umockdev)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibGudev[Name]}> Building package..."
	_ExtractPackageLibGudev || return $?;
	_BuildLibGudev;
	return $?
}

CheckLibGudev()
{
	CheckInstallation 	"${PackageLibGudev[Programs]}"\
						"${PackageLibGudev[Libraries]}"\
						"${PackageLibGudev[Python]}" 1> /dev/null;
	return $?;
}

CheckLibGudevVerbose()
{
	CheckInstallationVerbose	"${PackageLibGudev[Programs]}"\
								"${PackageLibGudev[Libraries]}"\
								"${PackageLibGudev[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibGudev()
{
	DownloadPackage	"${PackageLibGudev[Source]}"	"${SHMAN_PDIR}"	"${PackageLibGudev[Package]}${PackageLibGudev[Extension]}"	"${PackageLibGudev[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibGudev[Package]}"	"${PackageLibGudev[Extension]}" || return $?;

	for URL in \
	# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibGudev()
{
	if ! cd "${SHMAN_PDIR}${PackageLibGudev[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibGudev[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibGudev[Package]}/build \
					|| { EchoError "${PackageLibGudev[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibGudev[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibGudev[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageLibGudev[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibGudev[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibGudev[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibGudev[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageLibGudev[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibGudev[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibGudev[Name]} && PressAnyKeyToContinue; return 1; };
}
