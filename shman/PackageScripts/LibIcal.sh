#!/bin/bash

if [ ! -z "${PackageLibIcal[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibIcal								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibIcal;
PackageLibIcal[Source]="https://github.com/libical/libical/releases/download/v3.0.19/libical-3.0.19.tar.gz";
PackageLibIcal[MD5]="f671e38e804bf467347807d8c8d057f7";
PackageLibIcal[Name]="libical";
PackageLibIcal[Version]="3.0.19";
PackageLibIcal[Package]="${PackageLibIcal[Name]}-${PackageLibIcal[Version]}";
PackageLibIcal[Extension]=".tar.gz";

PackageLibIcal[Programs]="";
PackageLibIcal[Libraries]="libical_cxx.so libical.so libical-glib.so libicalss_cxx.so libicalss.so libicalvcal.so";
PackageLibIcal[Python]="";

InstallLibIcal()
{
	# Check Installation
	CheckLibIcal && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibIcal[Name]}> Checking dependencies..."
	Required=(CMake GLib Vala)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Doxygen Graphviz GTKDoc ICU)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageLibIcal[Name]}> Building package..."
	_ExtractPackageLibIcal || return $?;
	_BuildLibIcal;
	return $?
}

CheckLibIcal()
{
	CheckInstallation 	"${PackageLibIcal[Programs]}"\
						"${PackageLibIcal[Libraries]}"\
						"${PackageLibIcal[Python]}" 1> /dev/null;
	return $?;
}

CheckLibIcalVerbose()
{
	CheckInstallationVerbose	"${PackageLibIcal[Programs]}"\
								"${PackageLibIcal[Libraries]}"\
								"${PackageLibIcal[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibIcal()
{
	DownloadPackage	"${PackageLibIcal[Source]}"	"${SHMAN_PDIR}"	"${PackageLibIcal[Package]}${PackageLibIcal[Extension]}"	"${PackageLibIcal[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibIcal[Package]}"	"${PackageLibIcal[Extension]}" || return $?;

	return $?;
}

_BuildLibIcal()
{
	if ! cd "${SHMAN_PDIR}${PackageLibIcal[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibIcal[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibIcal[Package]}/build \
					|| { EchoError "${PackageLibIcal[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibIcal[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibIcal[Name]}> Configure"
	cmake -D CMAKE_INSTALL_PREFIX=/usr \
			-D CMAKE_BUILD_TYPE=Release \
			-D SHARED_ONLY=yes \
			-D ICAL_BUILD_DOCS=false \
			-D ICAL_BUILD_EXAMPLES=false \
			-D GOBJECT_INTROSPECTION=true \
			-D ICAL_GLIB_VAPI=true \
			.. \
			1> /dev/null || { EchoTest KO ${PackageLibIcal[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibIcal[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibIcal[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibIcal[Name]}> make test"
	make test 1> /dev/null || { EchoTest KO ${PackageLibIcal[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLibIcal[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibIcal[Name]} && PressAnyKeyToContinue; return 1; };
}
