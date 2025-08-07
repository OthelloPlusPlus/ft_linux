#!/bin/bash

if [ ! -z "${PackageEvolutionDataServer[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#								EvolutionDataServer							   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageEvolutionDataServer;
PackageEvolutionDataServer[Source]="https://download.gnome.org/sources/evolution-data-server/3.54/evolution-data-server-3.54.3.tar.xz";
PackageEvolutionDataServer[MD5]="1803a1127df96258a6c8b1d8d27edd25";
PackageEvolutionDataServer[Name]="evolution-data-server";
PackageEvolutionDataServer[Version]="3.54.3";
PackageEvolutionDataServer[Package]="${PackageEvolutionDataServer[Name]}-${PackageEvolutionDataServer[Version]}";
PackageEvolutionDataServer[Extension]=".tar.xz";

PackageEvolutionDataServer[Programs]="";
PackageEvolutionDataServer[Libraries]="libcamel-1.2.so libebackend-1.2.so libebook-1.2.so libebook-contacts-1.2.so libecal-2.0.so libedata-book-1.2.so libedata-cal-2.0.so libedataserver-1.2.so libedataserverui-1.2.so libedataserverui4-1.0.so libetestserverutils.so";
PackageEvolutionDataServer[Python]="";

InstallEvolutionDataServer()
{
	# Check Installation
	CheckEvolutionDataServer && return $?;

	# Check Dependencies
	EchoInfo	"${PackageEvolutionDataServer[Name]}> Checking dependencies..."
	#Added LibSoup3 JSONGLib
	Required=(LibIcal LibSecret Nss SQLite LibSoup3 JSONGLib)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GnomeOnlineAccounts GLib GTK3 GTK4 ICU LibCanberra LibGweather Vala WebKitGTK)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageEvolutionDataServer[Name]}> Checking recommended ${Dependency}..."
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(GTKDoc MITKerberos OpenLDAP)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageEvolutionDataServer[Name]}> Building package..."
	_ExtractPackageEvolutionDataServer || return $?;
	_BuildEvolutionDataServer;
	return $?
}

CheckEvolutionDataServer()
{
	CheckInstallation 	"${PackageEvolutionDataServer[Programs]}"\
						"${PackageEvolutionDataServer[Libraries]}"\
						"${PackageEvolutionDataServer[Python]}" 1> /dev/null;
	return $?;
}

CheckEvolutionDataServerVerbose()
{
	CheckInstallationVerbose	"${PackageEvolutionDataServer[Programs]}"\
								"${PackageEvolutionDataServer[Libraries]}"\
								"${PackageEvolutionDataServer[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageEvolutionDataServer()
{
	DownloadPackage	"${PackageEvolutionDataServer[Source]}"	"${SHMAN_PDIR}"	"${PackageEvolutionDataServer[Package]}${PackageEvolutionDataServer[Extension]}"	"${PackageEvolutionDataServer[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageEvolutionDataServer[Package]}"	"${PackageEvolutionDataServer[Extension]}" || return $?;

	return $?;
}

_BuildEvolutionDataServer()
{
	if ! cd "${SHMAN_PDIR}${PackageEvolutionDataServer[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageEvolutionDataServer[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageEvolutionDataServer[Package]}/build \
					|| { EchoError "${PackageEvolutionDataServer[Name]}> Failed to enter ${SHMAN_PDIR}${PackageEvolutionDataServer[Package]}/build"; return 1; }

	EchoInfo	"${PackageEvolutionDataServer[Name]}> Configure"
	local CMakeFlags="-D CMAKE_INSTALL_PREFIX=/usr"
	CMakeFlags+=" -D SYSCONF_INSTALL_DIR=/etc"
	if command -v valac &> /dev/null ; then CMakeFlags+=" -D ENABLE_VALA_BINDINGS=ON"; fi
	CMakeFlags+=" -D ENABLE_INSTALLED_TESTS=ON"
	CMakeFlags+=" -D WITH_OPENLDAP=OFF"
	CMakeFlags+=" -D WITH_KRB5=OFF"
	CMakeFlags+=" -D ENABLE_INTROSPECTION=ON"
	CMakeFlags+=" -D ENABLE_GTK_DOC=OFF"
	CMakeFlags+=" -D WITH_LIBDB=OFF"
	if ! pkg-config --atleast-version=2.34.0 webkit2gtk-4.1 ; then CMakeFlags+=" -D ENABLE_OAUTH2_WEBKITGTK4=OFF -D ENABLE_OAUTH2_WEBKITGTK=OFF"; fi
	CMakeFlags+=" -D WITH_SYSTEMDUSERUNITDIR=no"
	if ! ls /usr/lib*/libgoa-1.0.so &> /dev/null; then CMakeFlags+=" -D ENABLE_GOA=OFF"; fi
	if ! ls /usr/lib*/libgweather-4.so &> /dev/null; then CMakeFlags+=" -D ENABLE_WEATHER=OFF"; fi
	if ! command -v canberra-boot &> /dev/null; then CMakeFlags+=" -D ENABLE_CANBERRA=OFF"; fi
	cmake $CMakeFlags -W no-dev -G Ninja .. 1> /dev/null || { EchoTest KO ${PackageEvolutionDataServer[Name]} && cmake -L CMakeLists.txt && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageEvolutionDataServer[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageEvolutionDataServer[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageEvolutionDataServer[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageEvolutionDataServer[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageEvolutionDataServer[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageEvolutionDataServer[Name]} && PressAnyKeyToContinue; return 1; };
}
