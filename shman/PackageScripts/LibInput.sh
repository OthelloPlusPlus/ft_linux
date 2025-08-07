#!/bin/bash

if [ ! -z "${PackageLibInput[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibInput								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibInput;
# Manual
PackageLibInput[Source]="https://gitlab.freedesktop.org/libinput/libinput/-/archive/1.27.1/libinput-1.27.1.tar.gz";
PackageLibInput[MD5]="3b311d8953f8717f711a78b60087997e";
# Automated unless edgecase
PackageLibInput[Name]="";
PackageLibInput[Version]="";
PackageLibInput[Extension]="";
if [[ -n "${PackageLibInput[Source]}" ]]; then
	filename="${PackageLibInput[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibInput[Name]}" ]] && PackageLibInput[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibInput[Version]}" ]] && PackageLibInput[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibInput[Extension]}" ]] && PackageLibInput[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibInput[Package]="${PackageLibInput[Name]}-${PackageLibInput[Version]}";

PackageLibInput[Programs]="libinput";
PackageLibInput[Libraries]="libinput.so";
PackageLibInput[Python]="";

InstallLibInput()
{
	# Check Installation
	CheckLibInput && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibInput[Name]}> Checking dependencies..."
	Required=(LibEvdev Mtdev)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageLibInput[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageLibInput[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Valgrind GTK3 LibUnwind LibWacom Doxygen Graphviz Recommonmark SphinxRtdTheme )
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageLibInput[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibInput[Name]}> Building package..."
	_ExtractPackageLibInput || return $?;
	_BuildLibInput;
	return $?
}

CheckLibInput()
{
	CheckInstallation 	"${PackageLibInput[Programs]}"\
						"${PackageLibInput[Libraries]}"\
						"${PackageLibInput[Python]}" 1> /dev/null;
	return $?;
}

CheckLibInputVerbose()
{
	CheckInstallationVerbose	"${PackageLibInput[Programs]}"\
								"${PackageLibInput[Libraries]}"\
								"${PackageLibInput[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibInput()
{
	DownloadPackage	"${PackageLibInput[Source]}"	"${SHMAN_PDIR}"	"${PackageLibInput[Package]}${PackageLibInput[Extension]}"	"${PackageLibInput[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibInput[Package]}"	"${PackageLibInput[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibInput()
{
	if ! cd "${SHMAN_PDIR}${PackageLibInput[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibInput[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibInput[Package]}/build \
					|| { EchoError "${PackageLibInput[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibInput[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibInput[Name]}> Configure"
	meson setup .. \
				--prefix=$XORG_PREFIX \
				--buildtype=release \
				-D debug-gui=false \
				-D tests=false \
				-D udev-dir=/usr/lib/udev \
				1> /dev/null || { EchoTest KO ${PackageLibInput[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibInput[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibInput[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibInput[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageLibInput[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibInput[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibInput[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageLibInput[Name]}> Documentation"
	# install -v -dm755      /usr/share/doc/libinput-1.27.1/html
	# cp -rv Documentation/* /usr/share/doc/libinput-1.27.1/html
}
