#!/bin/bash

if [ ! -z "${PackageGnomeControlCenter[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									GnomeControlCenter								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGnomeControlCenter;
# Manual
PackageGnomeControlCenter[Source]="https://download.gnome.org/sources/gnome-control-center/47/gnome-control-center-47.4.tar.xz";
PackageGnomeControlCenter[MD5]="1997a8871725d72a322820189378ea9a";
# Automated unless edgecase
PackageGnomeControlCenter[Name]="";
PackageGnomeControlCenter[Version]="";
PackageGnomeControlCenter[Extension]="";
if [[ -n "${PackageGnomeControlCenter[Source]}" ]]; then
	filename="${PackageGnomeControlCenter[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageGnomeControlCenter[Name]}" ]] && PackageGnomeControlCenter[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageGnomeControlCenter[Version]}" ]] && PackageGnomeControlCenter[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageGnomeControlCenter[Extension]}" ]] && PackageGnomeControlCenter[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageGnomeControlCenter[Package]="${PackageGnomeControlCenter[Name]}-${PackageGnomeControlCenter[Version]}";

PackageGnomeControlCenter[Programs]="gnome-control-center";
PackageGnomeControlCenter[Libraries]="";
PackageGnomeControlCenter[Python]="";

InstallGnomeControlCenter()
{
	# Check Installation
	CheckGnomeControlCenter && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGnomeControlCenter[Name]}> Checking dependencies..."
	# Cups
	Required=(AccountService ColordGTK  GnomeBluetooth GnomeOnlineAccounts GnomeSettingsDaemon Gsound LibAdwaita LibGtop LibNma LibPwquality MITKerberos ModemManager Samba SharedMimeInfo Tecla UDisks)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageGnomeControlCenter[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Ibus)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageGnomeControlCenter[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(XorgServer Xwayland)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageGnomeControlCenter[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageGnomeControlCenter[Name]}> Building package..."
	_ExtractPackageGnomeControlCenter || return $?;
	_BuildGnomeControlCenter || return $?;

	RunTime=(Blocaled)
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageGnomeControlCenter[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckGnomeControlCenter()
{
	CheckInstallation 	"${PackageGnomeControlCenter[Programs]}"\
						"${PackageGnomeControlCenter[Libraries]}"\
						"${PackageGnomeControlCenter[Python]}" 1> /dev/null;
	return $?;
}

CheckGnomeControlCenterVerbose()
{
	CheckInstallationVerbose	"${PackageGnomeControlCenter[Programs]}"\
								"${PackageGnomeControlCenter[Libraries]}"\
								"${PackageGnomeControlCenter[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGnomeControlCenter()
{
	DownloadPackage	"${PackageGnomeControlCenter[Source]}"	"${SHMAN_PDIR}"	"${PackageGnomeControlCenter[Package]}${PackageGnomeControlCenter[Extension]}"	"${PackageGnomeControlCenter[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGnomeControlCenter[Package]}"	"${PackageGnomeControlCenter[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildGnomeControlCenter()
{
	if ! cd "${SHMAN_PDIR}${PackageGnomeControlCenter[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGnomeControlCenter[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGnomeControlCenter[Package]}/build \
	# 				|| { EchoError "${PackageGnomeControlCenter[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGnomeControlCenter[Package]}/build"; return 1; }

	EchoInfo	"${PackageGnomeControlCenter[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageGnomeControlCenter[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeControlCenter[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageGnomeControlCenter[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeControlCenter[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageGnomeControlCenter[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeControlCenter[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageGnomeControlCenter[Name]} && PressAnyKeyToContinue; return 1; };
}
