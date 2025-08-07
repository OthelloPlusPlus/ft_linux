#!/bin/bash

if [ ! -z "${PackageLibAdwaita[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibAdwaita								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibAdwaita;
# Manual
PackageLibAdwaita[Source]="https://download.gnome.org/sources/libadwaita/1.6/libadwaita-1.6.4.tar.xz";
PackageLibAdwaita[MD5]="8c8fe1e64c361eb5a84d60f61147fbf9";
# Automated unless edgecase
PackageLibAdwaita[Name]="";
PackageLibAdwaita[Version]="";
PackageLibAdwaita[Extension]="";
if [[ -n "${PackageLibAdwaita[Source]}" ]]; then
	filename="${PackageLibAdwaita[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibAdwaita[Name]}" ]] && PackageLibAdwaita[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibAdwaita[Version]}" ]] && PackageLibAdwaita[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibAdwaita[Extension]}" ]] && PackageLibAdwaita[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibAdwaita[Package]="${PackageLibAdwaita[Name]}-${PackageLibAdwaita[Version]}";

PackageLibAdwaita[Programs]="adwaita-1-demo";
PackageLibAdwaita[Libraries]="libadwaita-1.so";
PackageLibAdwaita[Python]="";

InstallLibAdwaita()
{
	# Check Installation
	CheckLibAdwaita && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibAdwaita[Name]}> Checking dependencies..."
	Required=(AppStream GTK4 Sassc)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageLibAdwaita[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Vala)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageLibAdwaita[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(GiDocGen XdgDesktopPortal)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageLibAdwaita[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibAdwaita[Name]}> Building package..."
	_ExtractPackageLibAdwaita || return $?;
	_BuildLibAdwaita || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageLibAdwaita[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckLibAdwaita()
{
	CheckInstallation 	"${PackageLibAdwaita[Programs]}"\
						"${PackageLibAdwaita[Libraries]}"\
						"${PackageLibAdwaita[Python]}" 1> /dev/null;
	return $?;
}

CheckLibAdwaitaVerbose()
{
	CheckInstallationVerbose	"${PackageLibAdwaita[Programs]}"\
								"${PackageLibAdwaita[Libraries]}"\
								"${PackageLibAdwaita[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibAdwaita()
{
	DownloadPackage	"${PackageLibAdwaita[Source]}"	"${SHMAN_PDIR}"	"${PackageLibAdwaita[Package]}${PackageLibAdwaita[Extension]}"	"${PackageLibAdwaita[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibAdwaita[Package]}"	"${PackageLibAdwaita[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibAdwaita()
{
	if ! cd "${SHMAN_PDIR}${PackageLibAdwaita[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibAdwaita[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibAdwaita[Package]}/build \
					|| { EchoError "${PackageLibAdwaita[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibAdwaita[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibAdwaita[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageLibAdwaita[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibAdwaita[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibAdwaita[Name]} && PressAnyKeyToContinue; return 1; };

	# sed "s/apiversion/'1.6.4'/" -i ../doc/meson.build &&
	# meson configure -D gtk_doc=true                   &&
	# ninja

	# EchoInfo	"${PackageLibAdwaita[Name]}> ninja test"
	# ninja test 1> /dev/null || { EchoTest KO ${PackageLibAdwaita[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibAdwaita[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibAdwaita[Name]} && PressAnyKeyToContinue; return 1; };
}
