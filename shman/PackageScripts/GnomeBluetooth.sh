#!/bin/bash

if [ ! -z "${PackageGnomeBluetooth[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									GnomeBluetooth								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGnomeBluetooth;
# Manual
PackageGnomeBluetooth[Source]="https://download.gnome.org/sources/gnome-bluetooth/47/gnome-bluetooth-47.1.tar.xz";
PackageGnomeBluetooth[MD5]="715b4767b46b4c4b24a231358d0de83e";
# Automated unless edgecase
PackageGnomeBluetooth[Name]="";
PackageGnomeBluetooth[Version]="";
PackageGnomeBluetooth[Extension]="";
if [[ -n "${PackageGnomeBluetooth[Source]}" ]]; then
	filename="${PackageGnomeBluetooth[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageGnomeBluetooth[Name]}" ]] && PackageGnomeBluetooth[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageGnomeBluetooth[Version]}" ]] && PackageGnomeBluetooth[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageGnomeBluetooth[Extension]}" ]] && PackageGnomeBluetooth[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageGnomeBluetooth[Package]="${PackageGnomeBluetooth[Name]}-${PackageGnomeBluetooth[Version]}";

PackageGnomeBluetooth[Programs]="bluetooth-sendto";
PackageGnomeBluetooth[Libraries]="libgnome-bluetooth-3.0.so libgnome-bluetooth-ui-3.0.so";
PackageGnomeBluetooth[Python]="";

InstallGnomeBluetooth()
{
	# Check Installation
	CheckGnomeBluetooth && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGnomeBluetooth[Name]}> Checking dependencies..."
	# Had to add PyGObject3 seperately
	Required=(GTK4 Gsound LibNotify UPower PyGObject3)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageGnomeBluetooth[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GLib LibAdwaita)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageGnomeBluetooth[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(GTKDoc)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageGnomeBluetooth[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageGnomeBluetooth[Name]}> Building package..."
	_ExtractPackageGnomeBluetooth || return $?;
	_BuildGnomeBluetooth || return $?;

	RunTime=(BlueZ)
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageGnomeBluetooth[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckGnomeBluetooth()
{
	CheckInstallation 	"${PackageGnomeBluetooth[Programs]}"\
						"${PackageGnomeBluetooth[Libraries]}"\
						"${PackageGnomeBluetooth[Python]}" 1> /dev/null;
	return $?;
}

CheckGnomeBluetoothVerbose()
{
	CheckInstallationVerbose	"${PackageGnomeBluetooth[Programs]}"\
								"${PackageGnomeBluetooth[Libraries]}"\
								"${PackageGnomeBluetooth[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGnomeBluetooth()
{
	DownloadPackage	"${PackageGnomeBluetooth[Source]}"	"${SHMAN_PDIR}"	"${PackageGnomeBluetooth[Package]}${PackageGnomeBluetooth[Extension]}"	"${PackageGnomeBluetooth[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGnomeBluetooth[Package]}"	"${PackageGnomeBluetooth[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildGnomeBluetooth()
{
	if ! cd "${SHMAN_PDIR}${PackageGnomeBluetooth[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGnomeBluetooth[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGnomeBluetooth[Package]}/build \
					|| { EchoError "${PackageGnomeBluetooth[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGnomeBluetooth[Package]}/build"; return 1; }

	EchoInfo	"${PackageGnomeBluetooth[Name]}> Configure"
	# GI_TYPELIB_PATH=/usr/lib64/girepository-1.0/ \
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageGnomeBluetooth[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeBluetooth[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGnomeBluetooth[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeBluetooth[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageGnomeBluetooth[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeBluetooth[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGnomeBluetooth[Name]} && PressAnyKeyToContinue; return 1; };
}
