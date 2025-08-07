#!/bin/bash

if [ ! -z "${PackageLibSecret[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibSecret								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibSecret;
PackageLibSecret[Source]="https://download.gnome.org/sources/libsecret/0.21/libsecret-0.21.6.tar.xz";
PackageLibSecret[MD5]="e7139fca939c50309eba74280e7048ac";
PackageLibSecret[Name]="libsecret";
PackageLibSecret[Version]="0.21.6";
PackageLibSecret[Package]="${PackageLibSecret[Name]}-${PackageLibSecret[Version]}";
PackageLibSecret[Extension]=".tar.xz";

PackageLibSecret[Programs]="secret-tool";
PackageLibSecret[Libraries]="libsecret-1.so";
PackageLibSecret[Python]="";

InstallLibSecret()
{
	# Check Installation
	CheckLibSecret && return $?;

	# Check Dependencies
	Required=(GLib)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(LibGcrypt Vala)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(GiDocGen DocbookXml DocbookXslNons LibXslt Valgrind Gjs PyGObject Tpm2)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"Package ${PackageLibSecret[Name]}"
	_ExtractPackageLibSecret || return $?;
	_BuildLibSecret;
	return $?
}

CheckLibSecret()
{
	CheckInstallation 	"${PackageLibSecret[Programs]}"\
						"${PackageLibSecret[Libraries]}"\
						"${PackageLibSecret[Python]}" 1> /dev/null;
	return $?;
}

CheckLibSecretVerbose()
{
	CheckInstallationVerbose	"${PackageLibSecret[Programs]}"\
								"${PackageLibSecret[Libraries]}"\
								"${PackageLibSecret[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibSecret()
{
	DownloadPackage	"${PackageLibSecret[Source]}"	"${SHMAN_PDIR}"	"${PackageLibSecret[Package]}${PackageLibSecret[Extension]}"	"${PackageLibSecret[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibSecret[Package]}"	"${PackageLibSecret[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildLibSecret()
{
	if ! cd "${SHMAN_PDIR}${PackageLibSecret[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibSecret[Package]}";
		return 1;
	fi

	if ! mkdir -p bld; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageLibSecret[Name]}/bld";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageLibSecret[Package]}/bld";

	EchoInfo	"${PackageLibSecret[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D gtk_doc=false \
				-D manpage=false \
				.. \
				1> /dev/null || { EchoTest KO ${PackageLibSecret[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibSecret[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibSecret[Name]} && PressAnyKeyToContinue; return 1; };

	if source "${SHMAN_SDIR}/GiDocGen.sh" && CheckGiDocGen; then
		sed "s/api_version_major/'0.21.6'/"            \
			-i ../docs/reference/libsecret/meson.build &&
		meson configure -D gtk_doc=true                &&
		ninja
	fi

	EchoInfo	"${PackageLibSecret[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibSecret[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageLibSecret[Name]}> ninja test"
	# dbus-run-session ninja test. 1> /dev/null || { EchoTest KO ${PackageLibSecret[Name]} && PressAnyKeyToContinue; return 1; };
}
