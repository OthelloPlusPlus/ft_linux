#!/bin/bash

if [ ! -z "${PackageGstreamer[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Gstreamer								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGstreamer;
PackageGstreamer[Source]="https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-1.24.12.tar.xz";
PackageGstreamer[MD5]="8bfc0b9b4e2467170a66e256d4846f9c";
PackageGstreamer[Name]="gstreamer";
PackageGstreamer[Version]="1.24.12";
PackageGstreamer[Package]="${PackageGstreamer[Name]}-${PackageGstreamer[Version]}";
PackageGstreamer[Extension]=".tar.xz";

PackageGstreamer[Programs]="gst-inspect-1.0 gst-launch-1.0 gst-stats-1.0 gst-tester-1.0 gst-typefind-1.0";
PackageGstreamer[Libraries]="libgstbase-1.0.so libgstcheck-1.0.so libgstcontroller-1.0.so libgstnet-1.0.so libgstreamer-1.0.so";
PackageGstreamer[Python]="";

InstallGstreamer()
{
	# Check Installation
	CheckGstreamer && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGstreamer[Name]}> Checking dependencies..."
	Required=(GLib)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(GTK3 Gsl LibUnwind Rustc Valgrind)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageGstreamer[Name]}> Building package..."
	_ExtractPackageGstreamer || return $?;
	_BuildGstreamer;
	return $?
}

CheckGstreamer()
{
	CheckInstallation 	"${PackageGstreamer[Programs]}"\
						"${PackageGstreamer[Libraries]}"\
						"${PackageGstreamer[Python]}" 1> /dev/null;
	return $?;
}

CheckGstreamerVerbose()
{
	CheckInstallationVerbose	"${PackageGstreamer[Programs]}"\
								"${PackageGstreamer[Libraries]}"\
								"${PackageGstreamer[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGstreamer()
{
	DownloadPackage	"${PackageGstreamer[Source]}"	"${SHMAN_PDIR}"	"${PackageGstreamer[Package]}${PackageGstreamer[Extension]}"	"${PackageGstreamer[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGstreamer[Package]}"	"${PackageGstreamer[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildGstreamer()
{
	if ! cd "${SHMAN_PDIR}${PackageGstreamer[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGstreamer[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGstreamer[Package]}/build \
					|| { EchoError "${PackageGstreamer[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGstreamer[Package]}/build"; return 1; }

	EchoInfo	"${PackageGstreamer[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D gst_debug=false \
				1> /dev/null || { EchoTest KO ${PackageGstreamer[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGstreamer[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGstreamer[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGstreamer[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageGstreamer[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageGstreamer[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGstreamer[Name]} && PressAnyKeyToContinue; return 1; };
}
