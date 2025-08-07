#!/bin/bash

if [ ! -z "${PackageXorgXf86VideoVmware[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									XorgXf86VideoVmware								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXorgXf86VideoVmware;
# Manual
PackageXorgXf86VideoVmware[Source]="https://www.x.org/releases/individual/driver/xf86-video-vmware-13.4.0.tar.xz";
PackageXorgXf86VideoVmware[MD5]="";
# Automated unless edgecase
PackageXorgXf86VideoVmware[Name]="";
PackageXorgXf86VideoVmware[Version]="";
PackageXorgXf86VideoVmware[Extension]="";
if [[ -n "${PackageXorgXf86VideoVmware[Source]}" ]]; then
	filename="${PackageXorgXf86VideoVmware[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageXorgXf86VideoVmware[Name]}" ]] && PackageXorgXf86VideoVmware[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageXorgXf86VideoVmware[Version]}" ]] && PackageXorgXf86VideoVmware[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageXorgXf86VideoVmware[Extension]}" ]] && PackageXorgXf86VideoVmware[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageXorgXf86VideoVmware[Package]="${PackageXorgXf86VideoVmware[Name]}-${PackageXorgXf86VideoVmware[Version]}";

PackageXorgXf86VideoVmware[Programs]="";
# /usr/lib/xorg/modules/drivers/vmware_drv.so
PackageXorgXf86VideoVmware[Libraries]="vmware_drv.so";
PackageXorgXf86VideoVmware[Python]="";

InstallXorgXf86VideoVmware()
{
	# Check Installation
	CheckXorgXf86VideoVmware && return $?;

	# Check Dependencies
	EchoInfo	"${PackageXorgXf86VideoVmware[Name]}> Checking dependencies..."
	Required=(XorgLibraries XorgServer LibDrm LibSystemd Mesa)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageXorgXf86VideoVmware[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageXorgXf86VideoVmware[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageXorgXf86VideoVmware[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageXorgXf86VideoVmware[Name]}> Building package..."
	_ExtractPackageXorgXf86VideoVmware || return $?;
	_BuildXorgXf86VideoVmware || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageXorgXf86VideoVmware[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckXorgXf86VideoVmware()
{
	CheckInstallation 	"${PackageXorgXf86VideoVmware[Programs]}"\
						"${PackageXorgXf86VideoVmware[Libraries]}"\
						"${PackageXorgXf86VideoVmware[Python]}" 1> /dev/null;
	return $?;
}

CheckXorgXf86VideoVmwareVerbose()
{
	CheckInstallationVerbose	"${PackageXorgXf86VideoVmware[Programs]}"\
								"${PackageXorgXf86VideoVmware[Libraries]}"\
								"${PackageXorgXf86VideoVmware[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageXorgXf86VideoVmware()
{
	DownloadPackage	"${PackageXorgXf86VideoVmware[Source]}"	"${SHMAN_PDIR}"	"${PackageXorgXf86VideoVmware[Package]}${PackageXorgXf86VideoVmware[Extension]}"	"${PackageXorgXf86VideoVmware[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageXorgXf86VideoVmware[Package]}"	"${PackageXorgXf86VideoVmware[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildXorgXf86VideoVmware()
{
	if ! cd "${SHMAN_PDIR}${PackageXorgXf86VideoVmware[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageXorgXf86VideoVmware[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageXorgXf86VideoVmware[Name]}> Configure"
	./configure $XORG_CONFIG 1> /dev/null || { EchoTest KO ${PackageXorgXf86VideoVmware[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXorgXf86VideoVmware[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageXorgXf86VideoVmware[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXorgXf86VideoVmware[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageXorgXf86VideoVmware[Name]} && PressAnyKeyToContinue; return 1; };

	# echo 'xrandr --output Virtual1 --mode 1920x1080' > ~/.xinitrc
	# echo 'xrandr --output Virtual1 --mode 1920x1080' > ~/.xprofile
	# chmod +x ~/.x{initrc,profile}
# 	echo 'xrandr --output Virtual1 --mode 1920x1080' > /etc/X11/xorg.conf.d/99-screensize.conf
# 	echo 'Section "Screen"
#     Identifier     "Screen0"
#     Device         "VMware SVGA"
#     Monitor        "Virtual Monitor"
#     DefaultDepth    24
#     SubSection     "Display"
#         Depth       24
#         Modes       "1920x1080"
#         Virtual     3840 2160
#     EndSubSection
# EndSection
# ' > /etc/X11/xorg.conf.d/99-screensize.conf

}

# Libraries have been installed in:
#    /usr/lib/xorg/modules/drivers

# If you ever happen to want to link against installed libraries
# in a given directory, LIBDIR, you must either use libtool, and
# specify the full pathname of the library, or use the '-LLIBDIR'
# flag during linking and do at least one of the following:
#    - add LIBDIR to the 'LD_LIBRARY_PATH' environment variable
#      during execution
#    - add LIBDIR to the 'LD_RUN_PATH' environment variable
#      during linking
#    - use the '-Wl,-rpath -Wl,LIBDIR' linker flag
#    - have your system administrator add LIBDIR to '/etc/ld.so.conf'

# See any operating system documentation about shared libraries for
# more information, such as the ld(1) and ld.so(8) manual pages.