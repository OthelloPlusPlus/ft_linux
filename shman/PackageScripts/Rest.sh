#!/bin/bash

if [ ! -z "${PackageRest[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									  Rest									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageRest;
PackageRest[Source]="https://download.gnome.org/sources/rest/0.9/rest-0.9.1.tar.xz";
PackageRest[MD5]="b997b83232be3814a1b78530c5700df9";
PackageRest[Name]="rest";
PackageRest[Version]="0.9.1";
PackageRest[Package]="${PackageRest[Name]}-${PackageRest[Version]}";
PackageRest[Extension]=".tar.xz";

PackageRest[Programs]="";
PackageRest[Libraries]="librest-1.0.so librest-extras-1.0.so";
PackageRest[Python]="";

InstallRest()
{
	# Check Installation
	CheckRest && return $?;

	# Check Dependencies
	Required=(JSONGLib LibSoup MakeCa)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GLib)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(GiDocGen LibAdwaita Gtksourceview Vala)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"Package ${PackageRest[Name]}"
	_ExtractPackageRest || return $?;
	_BuildRest;
	return $?
}

CheckRest()
{
	CheckInstallation 	"${PackageRest[Programs]}"\
						"${PackageRest[Libraries]}"\
						"${PackageRest[Python]}" 1> /dev/null;
	return $?;
}

CheckRestVerbose()
{
	CheckInstallationVerbose	"${PackageRest[Programs]}"\
								"${PackageRest[Libraries]}"\
								"${PackageRest[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageRest()
{
	DownloadPackage	"${PackageRest[Source]}"	"${SHMAN_PDIR}"	"${PackageRest[Package]}${PackageRest[Extension]}"	"${PackageRest[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageRest[Package]}"	"${PackageRest[Extension]}" || return $?;

	return $?;
}

_BuildRest()
{
	if ! cd "${SHMAN_PDIR}${PackageRest[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageRest[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageRest[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageRest[Package]}/build";

	EchoInfo	"${PackageRest[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D examples=false \
				-D gtk_doc=false \
				.. \
				1> /dev/null || { EchoTest KO ${PackageRest[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageRest[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageRest[Name]} && PressAnyKeyToContinue; return 1; };

	if source "${SHMAN_SDIR}/GiDocGen.sh" && CheckGiDocGen; then
		sed "/output/s/librest-1.0/rest-0.9.1/" \
			-i ../docs/meson.build &&
		meson configure -D gtk_doc=true &&
		ninja
	fi

	EchoInfo	"${PackageRest[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageRest[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageRest[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageRest[Name]} && PressAnyKeyToContinue; return 1; };
}
