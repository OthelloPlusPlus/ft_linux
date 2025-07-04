#!/bin/bash

if [ ! -z "${PackageDbus[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Dbus								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageDbus;
PackageDbus[Source]="https://dbus.freedesktop.org/releases/dbus/dbus-1.16.0.tar.xz";
PackageDbus[MD5]="66bfcf1f42d4ebc634ca558d14335e92";
PackageDbus[Name]="dbus";
PackageDbus[Version]="1.16.0";
PackageDbus[Package]="${PackageDbus[Name]}-${PackageDbus[Version]}";
PackageDbus[Extension]=".tar.xz";

PackageDbus[Programs]="dbus-cleanup-sockets dbus-daemon dbus-launch dbus-monitor dbus-run-session dbus-send dbus-test-tool dbus-update-activation-environment dbus-uuidgen";
PackageDbus[Libraries]="libdbus-1.so";
PackageDbus[Python]="";

InstallDbus()
{
	# Check Installation
	CheckDbus && return $?;

	# Check Dependencies
	EchoInfo	"${PackageDbus[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(XorgLibraries)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Valgrind Doxygen Xmlto)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageDbus[Name]}> Building package..."
	_ExtractPackageDbus || return $?;
	_BuildDbus || return $?;
	_ConfigureDbus;
	return $?
}

CheckDbus()
{
	CheckInstallation 	"${PackageDbus[Programs]}"\
						"${PackageDbus[Libraries]}"\
						"${PackageDbus[Python]}" 1> /dev/null;
	return $?;
}

CheckDbusVerbose()
{
	CheckInstallationVerbose	"${PackageDbus[Programs]}"\
								"${PackageDbus[Libraries]}"\
								"${PackageDbus[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageDbus()
{
	DownloadPackage	"${PackageDbus[Source]}"	"${SHMAN_PDIR}"	"${PackageDbus[Package]}${PackageDbus[Extension]}"	"${PackageDbus[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageDbus[Package]}"	"${PackageDbus[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildDbus()
{
	if ! cd "${SHMAN_PDIR}${PackageDbus[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageDbus[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageDbus[Package]}/build \
					|| { EchoError "${PackageDbus[Name]}> Failed to enter ${SHMAN_PDIR}${PackageDbus[Package]}/build"; return 1; }

	EchoInfo	"${PackageDbus[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				--wrap-mode=nofallback \
				-D systemd=disabled \
				.. \
				1> /dev/null || { EchoTest KO ${PackageDbus[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDbus[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageDbus[Name]} && PressAnyKeyToContinue; return 1; };

	
	EchoInfo	"${PackageDbus[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageDbus[Name]} && PressAnyKeyToContinue; return 1; };

	ldconfig

	# For DESTDIR installation
	# chown -v root:messagebus /usr/libexec/dbus-daemon-launch-helper &&
	# chmod -v      4750       /usr/libexec/dbus-daemon-launch-helper

	# For when building as Chroot or did not start the daemon
	dbus-uuidgen --ensure

	# If using elogind-255.17
	# ln -sfv /var/lib/dbus/machine-id /etc

	# Rename the documentation directory if exists
	if [ -e /usr/share/doc/dbus ]; then
		rm -rf /usr/share/doc/dbus-1.16.0 &&
		mv -v  /usr/share/doc/dbus{,-1.16.0}
	fi

	# EchoInfo	"${PackageDbus[Name]}> ninja test"
	# meson configure -D asserts=true -D intrusive_tests=true && \
	# ninja test 1> /dev/null || { EchoTest KO ${PackageDbus[Name]} && PressAnyKeyToContinue; return 1; };

}

_ConfigureDbus()
{
	EchoInfo	"${PackageDbus[Name]}> Configuring /etc/dbus-1/session-local.conf"
	cat > /etc/dbus-1/session-local.conf << "EOF"
<!DOCTYPE busconfig PUBLIC
 "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>

  <!-- Search for .service files in /usr/local -->
  <servicedir>/usr/local/share/dbus-1/services</servicedir>

</busconfig>
EOF

	EchoInfo	"${PackageDbus[Name]}> Adding to Boot (BLFS Bootscripts)"
	source "${SHMAN_SDIR}/_BLFSBootscripts.sh" || { EchoTest KO "${PackageDbus[Name]}> Could not find blfs-bootscripts"; return 1; };
	BootScriptDbus || return
}
