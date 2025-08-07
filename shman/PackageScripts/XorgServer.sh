#!/bin/bash

if [ ! -z "${PackageXorgServer[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									XorgServer								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXorgServer;
# Manual
PackageXorgServer[Source]="https://www.x.org/pub/individual/xserver/xorg-server-21.1.16.tar.xz";
PackageXorgServer[MD5]="f1a5ec0939c0efd7fde1418989b579db";
# Automated unless edgecase
PackageXorgServer[Name]="";
PackageXorgServer[Version]="";
PackageXorgServer[Extension]="";
if [[ -n "${PackageXorgServer[Source]}" ]]; then
	filename="${PackageXorgServer[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageXorgServer[Name]}" ]] && PackageXorgServer[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageXorgServer[Version]}" ]] && PackageXorgServer[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageXorgServer[Extension]}" ]] && PackageXorgServer[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageXorgServer[Package]="${PackageXorgServer[Name]}-${PackageXorgServer[Version]}";

PackageXorgServer[Programs]="gtf X Xnest Xorg Xvfb";
PackageXorgServer[Libraries]="";
PackageXorgServer[Python]="";

InstallXorgServer()
{
	# Check Installation
	CheckXorgServer && return $?;

	# Check Dependencies
	EchoInfo	"${PackageXorgServer[Name]}> Checking dependencies..."
	# Added LibXdmcp XkeyboardConfig
	Required=(LibXcvt Pixman XorgFonts LibXdmcp XkeyboardConfig)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageXorgServer[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Dbus Elogind LibEpoxy LibTirpc1)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageXorgServer[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Doxygen Fop LibUnwind Nettle LibGcrypt XCBUtilities Xmlto)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageXorgServer[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageXorgServer[Name]}> Building package..."
	_ExtractPackageXorgServer || return $?;
	_BuildXorgServer;
	return $?
}

CheckXorgServer()
{
	CheckInstallation 	"${PackageXorgServer[Programs]}"\
						"${PackageXorgServer[Libraries]}"\
						"${PackageXorgServer[Python]}" 1> /dev/null;
	return $?;
}

CheckXorgServerVerbose()
{
	CheckInstallationVerbose	"${PackageXorgServer[Programs]}"\
								"${PackageXorgServer[Libraries]}"\
								"${PackageXorgServer[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageXorgServer()
{
	DownloadPackage	"${PackageXorgServer[Source]}"	"${SHMAN_PDIR}"	"${PackageXorgServer[Package]}${PackageXorgServer[Extension]}"	"${PackageXorgServer[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageXorgServer[Package]}"	"${PackageXorgServer[Extension]}" || return $?;

	for URL in \
		"https://www.linuxfromscratch.org/patches/blfs/12.3/xorg-server-21.1.16-tearfree_backport-1.patch"
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildXorgServer()
{
	if ! cd "${SHMAN_PDIR}${PackageXorgServer[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageXorgServer[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageXorgServer[Name]}> Patching"
	patch -Np1 -i ../xorg-server-21.1.16-tearfree_backport-1.patch

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageXorgServer[Package]}/build \
					|| { EchoError "${PackageXorgServer[Name]}> Failed to enter ${SHMAN_PDIR}${PackageXorgServer[Package]}/build"; return 1; }

	EchoInfo	"${PackageXorgServer[Name]}> Configure"
	meson setup .. \
				--prefix=$XORG_PREFIX \
				--localstatedir=/var \
				-D glamor=true \
				-D systemd_logind=true \
				-D xkb_output_dir=/var/lib/xkb \
				1> /dev/null || { EchoTest KO ${PackageXorgServer[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXorgServer[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageXorgServer[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXorgServer[Name]}> ninja test"
	ldconfig
	ninja test 1> /dev/null || { EchoTest KO ${PackageXorgServer[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXorgServer[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageXorgServer[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXorgServer[Name]}> /etc/X11/xorg.conf.d"
	mkdir -pv /etc/X11/xorg.conf.d || return $?

	EchoInfo	"${PackageXorgServer[Name]}> install -v -d -m"
	install -v -d -m1777 /tmp/.{ICE,X11}-unix || return $?

	EchoInfo	"${PackageXorgServer[Name]}> /etc/sysconfig/createfiles"
	cat >> /etc/sysconfig/createfiles << "EOF"
/tmp/.ICE-unix dir 1777 root root
/tmp/.X11-unix dir 1777 root root
EOF

	EchoInfo	"${PackageXorgServer[Name]}> /etc/X11/xorg.conf.d/10-modulepath.conf"
	cat > /etc/X11/xorg.conf.d/10-modulepath.conf << "EOF"
Section "Files"
    ModulePath "/usr/lib64/xorg/modules"
    ModulePath "/usr/lib/xorg/modules"
EndSection
EOF

	EchoInfo	"${PackageXorgServer[Name]}> /etc/X11/xorg.conf.d/99-screensize.conf"
	echo 'Section "Screen"
    Identifier     "Screen0"
    Device         "VMware SVGA"
    Monitor        "Virtual Monitor"
    DefaultDepth    24
    SubSection     "Display"
        Depth       24
        Modes       "1920x1080"
        Virtual     3840 2160
    EndSubSection
EndSection
' > /etc/X11/xorg.conf.d/99-screensize.conf
	return $?
}

# grep -E "(EE|WW)" /var/log/Xorg.0.log
# grep -E "(EE|WW)" /var/log/Xorg.1.log


# grep -E "(Mouse)" /proc/bus/input/devices -B1 -A8
# grep Mouse0 /root/xorg.conf.new  -B1 -A5
# # Section "InputDevice"
# #         Identifier  "Mouse0"
# #         Driver      "mouse"
# #         Option      "Protocol" "auto"
# #         Option      "Device" "/dev/input/mice"
# #         Option      "ZAxisMapping" "4 5 6 7"
# # EndSection
# grep Mouse0 /root/xorg.conf.new  -B1 -A5
# Section "InputDevice"
#     Identifier "Mouse0"
#     Driver "libinput"
#     Option "Device" "/dev/input/event4"
#     Option "Name" "ImExPS/2 Generic Explorer Mouse"
# EndSection
