#!/bin/bash

if [ ! -z "${PackageGSettingsDesktopSchemas[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									GSettingsDesktopSchemas								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGSettingsDesktopSchemas;
PackageGSettingsDesktopSchemas[Source]="https://download.gnome.org/sources/gsettings-desktop-schemas/47/gsettings-desktop-schemas-47.1.tar.xz";
PackageGSettingsDesktopSchemas[MD5]="cf4431e4d8ada7a6e73a46f80f553f06";
PackageGSettingsDesktopSchemas[Name]="gsettings-desktop-schemas";
PackageGSettingsDesktopSchemas[Version]="47.1";
PackageGSettingsDesktopSchemas[Package]="${PackageGSettingsDesktopSchemas[Name]}-${PackageGSettingsDesktopSchemas[Version]}";
PackageGSettingsDesktopSchemas[Extension]=".tar.xz";

InstallGSettingsDesktopSchemas()
{
	# Check Installation
	CheckGSettingsDesktopSchemas && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGSettingsDesktopSchemas[Name]}> Checking dependencies..."
	Required=(GLib)
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
	EchoInfo	"${PackageGSettingsDesktopSchemas[Name]}> Building package..."
	_ExtractPackageGSettingsDesktopSchemas || return $?;
	_BuildGSettingsDesktopSchemas;
	return $?
}

CheckGSettingsDesktopSchemas()
{
	local compiled="/usr/share/glib-2.0/schemas/gschemas.compiled"
	local schema_dir="/usr/share/glib-2.0/schemas"

	if [ ! -r "$compiled" ]; then return 1; fi

	if ! ls "$schema_dir"/*.gschema.xml >/dev/null 2>&1; then return 1; fi

	if command -v gsettings >/dev/null 2>&1; then
		if ! gsettings list-schemas >/dev/null 2>&1; then return 1; fi
	fi

	return 0
}

CheckGSettingsDesktopSchemasVerbose()
{
	local compiled="/usr/share/glib-2.0/schemas/gschemas.compiled"
	local schema_dir="/usr/share/glib-2.0/schemas"

	if [ ! -r "$compiled" ]; then
		echo -e "${C_RED}gschemas.compiled${C_RESET}" >&2
		return 1
	fi

	if ! ls "$schema_dir"/*.gschema.xml >/dev/null 2>&1; then
		echo -e "${C_RED}/*.gschema.xml${C_RESET}" >&2
		return 1
	fi

	if command -v gsettings >/dev/null 2>&1; then
		if ! gsettings list-schemas >/dev/null 2>&1; then
			echo -e "${C_RED}gsettings${C_RESET}" >&2
			return 1
		fi
	fi

	return 0
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGSettingsDesktopSchemas()
{
	DownloadPackage	"${PackageGSettingsDesktopSchemas[Source]}"	"${SHMAN_PDIR}"	"${PackageGSettingsDesktopSchemas[Package]}${PackageGSettingsDesktopSchemas[Extension]}"	"${PackageGSettingsDesktopSchemas[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGSettingsDesktopSchemas[Package]}"	"${PackageGSettingsDesktopSchemas[Extension]}" || return $?;

	return $?;
}

_BuildGSettingsDesktopSchemas()
{
	if ! cd "${SHMAN_PDIR}${PackageGSettingsDesktopSchemas[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGSettingsDesktopSchemas[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageGSettingsDesktopSchemas[Name]}> Fixing deprecated entries"
	sed -i -r 's:"(/system):"/org/gnome\1:g' schemas/*.in

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGSettingsDesktopSchemas[Package]}/build \
					|| { EchoError "${PackageGSettingsDesktopSchemas[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGSettingsDesktopSchemas[Package]}/build"; return 1; }

	EchoInfo	"${PackageGSettingsDesktopSchemas[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageGSettingsDesktopSchemas[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGSettingsDesktopSchemas[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGSettingsDesktopSchemas[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGSettingsDesktopSchemas[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGSettingsDesktopSchemas[Name]} && PressAnyKeyToContinue; return 1; };
}
