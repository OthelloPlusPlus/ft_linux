#!/bin/bash

if [ ! -z "${PackageAlsaLib[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									AlsaLib								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageAlsaLib;
PackageAlsaLib[Source]="https://www.alsa-project.org/files/pub/lib/alsa-lib-1.2.13.tar.bz2";
PackageAlsaLib[MD5]="dd856a78e0702c3c4c1d8f56bc07bf61";
PackageAlsaLib[Name]="alsa-lib";
PackageAlsaLib[Version]="1.2.13";
PackageAlsaLib[Package]="${PackageAlsaLib[Name]}-${PackageAlsaLib[Version]}";
PackageAlsaLib[Extension]=".tar.bz2";

PackageAlsaLib[Programs]="aserver";
PackageAlsaLib[Libraries]="libasound.so libatopology.so";
PackageAlsaLib[Python]="";

InstallAlsaLib()
{
	# Check Installation
	CheckAlsaLib && return $?;

	# Check Dependencies
	EchoInfo	"${PackageAlsaLib[Name]}> Checking dependencies..."
	Required=(Linux)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Elogind)
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
	EchoInfo	"${PackageAlsaLib[Name]}> Building package..."
	_ExtractPackageAlsaLib || return $?;
	_BuildAlsaLib;
	return $?
}

CheckAlsaLib()
{
	CheckInstallation 	"${PackageAlsaLib[Programs]}"\
						"${PackageAlsaLib[Libraries]}"\
						"${PackageAlsaLib[Python]}" 1> /dev/null;
	return $?;
}

CheckAlsaLibVerbose()
{
	CheckInstallationVerbose	"${PackageAlsaLib[Programs]}"\
								"${PackageAlsaLib[Libraries]}"\
								"${PackageAlsaLib[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageAlsaLib()
{
	DownloadPackage	"${PackageAlsaLib[Source]}"	"${SHMAN_PDIR}"	"${PackageAlsaLib[Package]}${PackageAlsaLib[Extension]}"	"${PackageAlsaLib[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageAlsaLib[Package]}"	"${PackageAlsaLib[Extension]}" || return $?;

	for URL in \
		"https://www.alsa-project.org/files/pub/lib/alsa-ucm-conf-1.2.13.tar.bz2"
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildAlsaLib()
{
	if ! cd "${SHMAN_PDIR}${PackageAlsaLib[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageAlsaLib[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageAlsaLib[Package]}/build \
	# 				|| { EchoError "${PackageAlsaLib[Name]}> Failed to enter ${SHMAN_PDIR}${PackageAlsaLib[Package]}/build"; return 1; }

	EchoInfo	"${PackageAlsaLib[Name]}> Configure"
	./configure 1> /dev/null || { EchoTest KO ${PackageAlsaLib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAlsaLib[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageAlsaLib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAlsaLib[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageAlsaLib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAlsaLib[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageAlsaLib[Name]} && PressAnyKeyToContinue; return 1; };
	tar -C /usr/share/alsa --strip-components=1 -xf ../alsa-ucm-conf-1.2.13.tar.bz2

	install -v -d -m755 /usr/share/doc/alsa-lib-1.2.13/html/search &&
	install -v -m644 doc/doxygen/html/*.* \
					/usr/share/doc/alsa-lib-1.2.13/html &&
	install -v -m644 doc/doxygen/html/search/* \
					/usr/share/doc/alsa-lib-1.2.13/html/search
}
