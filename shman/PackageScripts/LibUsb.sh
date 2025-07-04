#!/bin/bash

if [ ! -z "${PackageLibUsb[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibUsb								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibUsb;
# Manual
PackageLibUsb[Source]="https://github.com/libusb/libusb/releases/download/v1.0.27/libusb-1.0.27.tar.bz2";
PackageLibUsb[MD5]="1fb61afe370e94f902a67e03eb39c51f";
# Automated unless edgecase
PackageLibUsb[Name]="";
PackageLibUsb[Version]="";
PackageLibUsb[Extension]="";
if [[ -n "${PackageLibUsb[Source]}" ]]; then
	filename="${PackageLibUsb[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibUsb[Name]}" ]] && PackageLibUsb[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibUsb[Version]}" ]] && PackageLibUsb[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibUsb[Extension]}" ]] && PackageLibUsb[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibUsb[Package]="${PackageLibUsb[Name]}-${PackageLibUsb[Version]}";

PackageLibUsb[Programs]="";
PackageLibUsb[Libraries]="libusb-1.0.so";
PackageLibUsb[Python]="";

InstallLibUsb()
{
	# Check Installation
	CheckLibUsb && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibUsb[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Doxygen)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibUsb[Name]}> Building package..."
	_ExtractPackageLibUsb || return $?;
	_BuildLibUsb;
	return $?
}

CheckLibUsb()
{
	CheckInstallation 	"${PackageLibUsb[Programs]}"\
						"${PackageLibUsb[Libraries]}"\
						"${PackageLibUsb[Python]}" 1> /dev/null;
	return $?;
}

CheckLibUsbVerbose()
{
	CheckInstallationVerbose	"${PackageLibUsb[Programs]}"\
								"${PackageLibUsb[Libraries]}"\
								"${PackageLibUsb[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibUsb()
{
	DownloadPackage	"${PackageLibUsb[Source]}"	"${SHMAN_PDIR}"	"${PackageLibUsb[Package]}${PackageLibUsb[Extension]}"	"${PackageLibUsb[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibUsb[Package]}"	"${PackageLibUsb[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibUsb()
{
	if ! cd "${SHMAN_PDIR}${PackageLibUsb[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibUsb[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibUsb[Package]}/build \
	# 				|| { EchoError "${PackageLibUsb[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibUsb[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibUsb[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageLibUsb[Name]} && PressAnyKeyToContinue; return 1; };

	# pushd doc                &&
	# 	doxygen -u doxygen.cfg &&
	# 	make docs              &&
	# popd

	EchoInfo	"${PackageLibUsb[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibUsb[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibUsb[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibUsb[Name]} && PressAnyKeyToContinue; return 1; };

	install -v -d -m755 /usr/share/doc/libusb-1.0.27/apidocs &&
	install -v -m644    doc/api-1.0/* \
						/usr/share/doc/libusb-1.0.27/apidocs
}
