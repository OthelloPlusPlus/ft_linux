#!/bin/bash

if [ ! -z "${PackageGnomeDesktop[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#								  GnomeDesktop								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGnomeDesktop;
PackageGnomeDesktop[Source]="https://download.gnome.org/sources/gnome-desktop/44/gnome-desktop-44.1.tar.xz";
PackageGnomeDesktop[MD5]="eda77690fcb351558ea0d1716a55e90b";
PackageGnomeDesktop[Name]="gnome-desktop";
PackageGnomeDesktop[Version]="44.1";
PackageGnomeDesktop[Package]="${PackageGnomeDesktop[Name]}-${PackageGnomeDesktop[Version]}";
PackageGnomeDesktop[Extension]=".tar.xz";

PackageGnomeDesktop[Programs]="";
PackageGnomeDesktop[Libraries]="libgnome-bg-4.so libgnome-desktop-3.so libgnome-desktop-4.so libgnome-rr-4.so";
PackageGnomeDesktop[Python]="";

InstallGnomeDesktop()
{
	# Check Installation
	CheckGnomeDesktop && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGnomeDesktop[Name]}> Checking dependencies..."
	Required=(GSettingsDesktopSchemas GTK3 GTK4 ISOCodes Itstool LibSeccomp LibXml2 XkeyboardConfig)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageGnomeDesktop[Name]}> Checking required ${Dependency}..."
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Bubblewrap GLib)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(GTKDoc)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageGnomeDesktop[Name]}> Building package..."
	_ExtractPackageGnomeDesktop || return $?;
	_BuildGnomeDesktop;
	return $?
}

CheckGnomeDesktop()
{
	CheckInstallation 	"${PackageGnomeDesktop[Programs]}"\
						"${PackageGnomeDesktop[Libraries]}"\
						"${PackageGnomeDesktop[Python]}" 1> /dev/null;
	return $?;
}

CheckGnomeDesktopVerbose()
{
	CheckInstallationVerbose	"${PackageGnomeDesktop[Programs]}"\
								"${PackageGnomeDesktop[Libraries]}"\
								"${PackageGnomeDesktop[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGnomeDesktop()
{
	DownloadPackage	"${PackageGnomeDesktop[Source]}"	"${SHMAN_PDIR}"	"${PackageGnomeDesktop[Package]}${PackageGnomeDesktop[Extension]}"	"${PackageGnomeDesktop[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGnomeDesktop[Package]}"	"${PackageGnomeDesktop[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildGnomeDesktop()
{
	if ! cd "${SHMAN_PDIR}${PackageGnomeDesktop[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGnomeDesktop[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGnomeDesktop[Package]}/build \
					|| { EchoError "${PackageGnomeDesktop[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGnomeDesktop[Package]}/build"; return 1; }

	EchoInfo	"${PackageGnomeDesktop[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageGnomeDesktop[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeDesktop[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGnomeDesktop[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeDesktop[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGnomeDesktop[Name]} && PressAnyKeyToContinue; return 1; };
}
