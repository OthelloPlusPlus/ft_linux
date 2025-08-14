#!/bin/bash

if [ ! -z "${PackageGcr4[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Gcr4								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGcr4;
PackageGcr4[Source]="https://download.gnome.org/sources/gcr/4.3/gcr-4.3.1.tar.xz";
PackageGcr4[MD5]="d8a71f8cb0390bc353f52ded3f9a6733";
PackageGcr4[Name]="gcr";
PackageGcr4[Version]="4.3.1";
PackageGcr4[Package]="${PackageGcr4[Name]}-${PackageGcr4[Version]}";
PackageGcr4[Extension]=".tar.xz";

PackageGcr4[Programs]="gcr-viewer-gtk4";
PackageGcr4[Libraries]="libgck-2.so libgcr-4.so";
PackageGcr4[Python]="";

InstallGcr4()
{
	# Check Installation
	CheckGcr4 && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGcr4[Name]}4> Checking dependencies..."
	Required=(GLib LibGcrypt P11Kit)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GnuPG GTK4 LibSecret LibXslt OpenSSH Vala)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageGcr4[Name]}4> Checking recommended ${Dependency}..."
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(GiDocGen GnuTLS Valgrind)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"Package ${PackageGcr4[Name]}4"
	_ExtractPackageGcr4 || return $?;
	_BuildGcr4;
	return $?
}

CheckGcr4()
{
	CheckInstallation 	"${PackageGcr4[Programs]}"\
						"${PackageGcr4[Libraries]}"\
						"${PackageGcr4[Python]}" 1> /dev/null;
	return $?;
}

CheckGcr4Verbose()
{
	CheckInstallationVerbose	"${PackageGcr4[Programs]}"\
								"${PackageGcr4[Libraries]}"\
								"${PackageGcr4[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGcr4()
{
	DownloadPackage	"${PackageGcr4[Source]}"	"${SHMAN_PDIR}"	"${PackageGcr4[Package]}${PackageGcr4[Extension]}"	"${PackageGcr4[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGcr4[Package]}"	"${PackageGcr4[Extension]}" || return $?;

	return $?;
}

_BuildGcr4()
{
	if ! cd "${SHMAN_PDIR}${PackageGcr4[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGcr4[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageGcr4[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageGcr4[Package]}/build";

	EchoInfo	"${PackageGcr4[Name]}4> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D gtk_doc=false \
				.. \
				1> /dev/null || { EchoTest KO ${PackageGcr4[Name]}4 && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGcr4[Name]}4> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGcr4[Name]}4 && PressAnyKeyToContinue; return 1; };

	if "${SHMAN_SDIR}/GiDocGen.sh" && CheckGiDocGen; then
		sed -e "/install_dir/s@,\$@ / 'gcr-4.3.1'&@" \
			-i ../docs/*/meson.build && \
		meson configure -D gtk_doc=true && \
		ninja
	fi

	EchoInfo	"${PackageGcr4[Name]}4> ninja test"
	if [ -z "$DISPLAY" ]; then
		echo "No X graphical environment detected. Tests requiring X will fail."
		ninja test || { EchoWarning "${PackageGcr4[Name]}4> Failures expected due to no X graphical environment." && PressAnyKeyToContinue; };
	else
		ninja test 1> /dev/null || { EchoTest KO ${PackageGcr4[Name]}4 && PressAnyKeyToContinue; return 1; };
	fi

	EchoInfo	"${PackageGcr4[Name]}4> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGcr4[Name]}4 && PressAnyKeyToContinue; return 1; };
}
