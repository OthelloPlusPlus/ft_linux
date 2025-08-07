#!/bin/bash

if [ ! -z "${PackageGnomeOnlineAccounts[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									GnomeOnlineAccounts								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGnomeOnlineAccounts;
# Manual
PackageGnomeOnlineAccounts[Source]="https://download.gnome.org/sources/gnome-online-accounts/3.52/gnome-online-accounts-3.52.3.1.tar.xz";
PackageGnomeOnlineAccounts[MD5]="f14d6d5be4b0af4458bba52f6ffb95d7";
# Automated unless edgecase
PackageGnomeOnlineAccounts[Name]="";
PackageGnomeOnlineAccounts[Version]="3.52.3.1";
PackageGnomeOnlineAccounts[Extension]=".tar.xz";
if [[ -n "${PackageGnomeOnlineAccounts[Source]}" ]]; then
	filename="${PackageGnomeOnlineAccounts[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageGnomeOnlineAccounts[Name]}" ]] && PackageGnomeOnlineAccounts[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageGnomeOnlineAccounts[Version]}" ]] && PackageGnomeOnlineAccounts[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageGnomeOnlineAccounts[Extension]}" ]] && PackageGnomeOnlineAccounts[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageGnomeOnlineAccounts[Package]="${PackageGnomeOnlineAccounts[Name]}-${PackageGnomeOnlineAccounts[Version]}";

PackageGnomeOnlineAccounts[Programs]="";
PackageGnomeOnlineAccounts[Libraries]="libgoa-1.0.so libgoa-backend-1.0.so";
PackageGnomeOnlineAccounts[Python]="";

InstallGnomeOnlineAccounts()
{
	# Check Installation
	CheckGnomeOnlineAccounts && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGnomeOnlineAccounts[Name]}> Checking dependencies..."
	Required=(Gcr4 JSONGLib LibAdwaita Rest Vala)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageGnomeOnlineAccounts[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GLib)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageGnomeOnlineAccounts[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(GiDocGen MITKerberos Valgrind)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageGnomeOnlineAccounts[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageGnomeOnlineAccounts[Name]}> Building package..."
	_ExtractPackageGnomeOnlineAccounts || return $?;
	_BuildGnomeOnlineAccounts || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageGnomeOnlineAccounts[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckGnomeOnlineAccounts()
{
	CheckInstallation 	"${PackageGnomeOnlineAccounts[Programs]}"\
						"${PackageGnomeOnlineAccounts[Libraries]}"\
						"${PackageGnomeOnlineAccounts[Python]}" 1> /dev/null;
	return $?;
}

CheckGnomeOnlineAccountsVerbose()
{
	CheckInstallationVerbose	"${PackageGnomeOnlineAccounts[Programs]}"\
								"${PackageGnomeOnlineAccounts[Libraries]}"\
								"${PackageGnomeOnlineAccounts[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGnomeOnlineAccounts()
{
	DownloadPackage	"${PackageGnomeOnlineAccounts[Source]}"	"${SHMAN_PDIR}"	"${PackageGnomeOnlineAccounts[Package]}${PackageGnomeOnlineAccounts[Extension]}"	"${PackageGnomeOnlineAccounts[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGnomeOnlineAccounts[Package]}"	"${PackageGnomeOnlineAccounts[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildGnomeOnlineAccounts()
{
	if ! cd "${SHMAN_PDIR}${PackageGnomeOnlineAccounts[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGnomeOnlineAccounts[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGnomeOnlineAccounts[Package]}/build \
					|| { EchoError "${PackageGnomeOnlineAccounts[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGnomeOnlineAccounts[Package]}/build"; return 1; }

	EchoInfo	"${PackageGnomeOnlineAccounts[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D documentation=false \
				-D kerberos=false \
				-D google_client_secret=5ntt6GbbkjnTVXx-MSxbmx5e \
				-D google_client_id=595013732528-llk8trb03f0ldpqq6nprjp1s79596646.apps.googleusercontent.com \
				.. \
				1> /dev/null || { EchoTest KO ${PackageGnomeOnlineAccounts[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGnomeOnlineAccounts[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGnomeOnlineAccounts[Name]} && PressAnyKeyToContinue; return 1; };

	# meson configure -D documentation=true &&
	# sed "s/project_name()/& + '-' + meson.project_version()/" \
	# 	-i ../doc/meson.build &&
	# ninja

	EchoInfo	"${PackageGnomeOnlineAccounts[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGnomeOnlineAccounts[Name]} && PressAnyKeyToContinue; return 1; };
}
