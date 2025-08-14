#!/bin/bash

if [ ! -z "${PackageGcr3[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									  Gcr3									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGcr3;
PackageGcr3[Source]="https://download.gnome.org/sources/gcr/3.41/gcr-3.41.2.tar.xz";
PackageGcr3[MD5]="40a754ba44d5e95e4d07656d6302900c";
PackageGcr3[Name]="gcr";
PackageGcr3[Version]="3.41.2";
PackageGcr3[Package]="${PackageGcr3[Name]}-${PackageGcr3[Version]}";
PackageGcr3[Extension]=".tar.xz";

PackageGcr3[Programs]="gcr-viewer";
PackageGcr3[Libraries]="libgck-1.so libgcr-base-3.so libgcr-ui-3.so";
PackageGcr3[Python]="";

InstallGcr3()
{
	# Check Installation
	CheckGcr3 && return $?;

	# Check Dependencies
	Required=(GLib LibGcrypt P11Kit)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GnuPG GTK3 LibSecret LibXslt Vala)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(GiDocGen Valgrind)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"Package ${PackageGcr3[Name]}"
	_ExtractPackageGcr3 || return $?;
	_BuildGcr3;
	return $?
}

CheckGcr3()
{
	CheckInstallation 	"${PackageGcr3[Programs]}"\
						"${PackageGcr3[Libraries]}"\
						"${PackageGcr3[Python]}" 1> /dev/null;
	return $?;
}

CheckGcr3Verbose()
{
	CheckInstallationVerbose	"${PackageGcr3[Programs]}"\
								"${PackageGcr3[Libraries]}"\
								"${PackageGcr3[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGcr3()
{
	DownloadPackage	"${PackageGcr3[Source]}"	"${SHMAN_PDIR}"	"${PackageGcr3[Package]}${PackageGcr3[Extension]}"	"${PackageGcr3[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGcr3[Package]}"	"${PackageGcr3[Extension]}" || return $?;
\
	return $?;
}

_BuildGcr3()
{
	if ! cd "${SHMAN_PDIR}${PackageGcr3[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGcr3[Package]}";
		return 1;
	fi

	sed -i 's:"/desktop:"/org:' schema/*.xml &&

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageGcr3[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageGcr3[Package]}/build";

	EchoInfo	"${PackageGcr3[Name]}3> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D gtk_doc=false \
				-D ssh_agent=false \
				.. \
				1> /dev/null || { EchoTest KO "${PackageGcr3[Name]}3" && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGcr3[Name]}3> ninja"
	ninja 1> /dev/null || { EchoTest KO "${PackageGcr3[Name]}3" && PressAnyKeyToContinue; return 1; };

	if "${SHMAN_SDIR}/GiDocGen.sh" && CheckGiDocGen; then
		sed -e "/install_dir/s@,\$@ / 'gcr-3.41.2'&@" \
			-i ../docs/*/meson.build && \
		meson configure -D gtk_doc=true && \
		ninja
	fi

	EchoInfo	"${PackageGcr3[Name]}3> ninja test"
	if [ -z "$DISPLAY" ]; then
		EchoWarning "No X graphical environment detected."
		ninja test || { EchoWarning "${PackageGcr3[Name]}3> 1 Failure expected due to no X graphical environment." && PressAnyKeyToContinue; };
	else
		ninja test 1> /dev/null || { EchoTest KO "${PackageGcr3[Name]}3" && PressAnyKeyToContinue; return 1; };
	fi

	EchoInfo	"${PackageGcr3[Name]}3> ninja install"
	ninja install 1> /dev/null || { EchoTest KO "${PackageGcr3[Name]}3" && PressAnyKeyToContinue; return 1; };
}
