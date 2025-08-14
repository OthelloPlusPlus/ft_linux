#!/bin/bash

if [ ! -z "${PackageVTE[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									  VTE								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageVTE;
PackageVTE[Source]="https://gitlab.gnome.org/GNOME/vte/-/archive/0.78.4/vte-0.78.4.tar.gz";
PackageVTE[MD5]="cdfc61b7021a43841845b8fb1593d28c";
PackageVTE[Name]="vte";
PackageVTE[Version]="0.78.4";
PackageVTE[Package]="${PackageVTE[Name]}-${PackageVTE[Version]}";
PackageVTE[Extension]=".tar.gz";

PackageVTE[Programs]="vte-2.91 vte-2.91-gtk4";
PackageVTE[Libraries]="libvte-2.91.so libvte-2.91-gtk4.so";
PackageVTE[Python]="";

InstallVTE()
{
	# Check Installation
	CheckVTE && return $?;

	# Check Dependencies
	Required=(GTK3 LibXml2 PCRE2)
	EchoInfo	"${PackageVTE[Name]}> Checking dependencies..."
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(ICU GnuTLS GLib GTK4 Vala)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageVTE[Name]}> Checking recommended ${Dependency}..."
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"Package ${PackageVTE[Name]}"
	_ExtractPackageVTE || return $?;
	_BuildVTE;
	return $?
}

CheckVTE()
{
	CheckInstallation 	"${PackageVTE[Programs]}"\
						"${PackageVTE[Libraries]}"\
						"${PackageVTE[Python]}" 1> /dev/null;
	return $?;
}

CheckVTEVerbose()
{
	CheckInstallationVerbose	"${PackageVTE[Programs]}"\
								"${PackageVTE[Libraries]}"\
								"${PackageVTE[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageVTE()
{
	DownloadPackage	"${PackageVTE[Source]}"	"${SHMAN_PDIR}"	"${PackageVTE[Package]}${PackageVTE[Extension]}"	"${PackageVTE[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageVTE[Package]}"	"${PackageVTE[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildVTE()
{
	if ! cd "${SHMAN_PDIR}${PackageVTE[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageVTE[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageVTE[Package]}/build \
	# 				|| { EchoError "${PackageVTE[Name]}> Failed to enter ${SHMAN_PDIR}${PackageVTE[Package]}/build"; return 1; }

	EchoInfo	"${PackageVTE[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageVTE[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageVTE[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageVTE[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageVTE[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageVTE[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageVTE[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageVTE[Name]} && PressAnyKeyToContinue; return 1; };
}
