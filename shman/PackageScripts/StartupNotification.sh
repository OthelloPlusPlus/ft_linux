#!/bin/bash

if [ ! -z "${PackageStartupNotification[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									StartupNotification								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageStartupNotification;
# Manual
PackageStartupNotification[Source]="https://www.freedesktop.org/software/startup-notification/releases/startup-notification-0.12.tar.gz";
PackageStartupNotification[MD5]="2cd77326d4dcaed9a5a23a1232fb38e9";
# Automated unless edgecase
PackageStartupNotification[Name]="";
PackageStartupNotification[Version]="";
PackageStartupNotification[Extension]="";
if [[ -n "${PackageStartupNotification[Source]}" ]]; then
	filename="${PackageStartupNotification[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageStartupNotification[Name]}" ]] && PackageStartupNotification[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageStartupNotification[Version]}" ]] && PackageStartupNotification[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageStartupNotification[Extension]}" ]] && PackageStartupNotification[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageStartupNotification[Package]="${PackageStartupNotification[Name]}-${PackageStartupNotification[Version]}";

PackageStartupNotification[Programs]="";
PackageStartupNotification[Libraries]="libstartup-notification-1.so";
PackageStartupNotification[Python]="";

InstallStartupNotification()
{
	# Check Installation
	CheckStartupNotification && return $?;

	# Check Dependencies
	EchoInfo	"${PackageStartupNotification[Name]}> Checking dependencies..."
	Required=(XorgLibraries XcbUtil)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageStartupNotification[Name]}> Building package..."
	_ExtractPackageStartupNotification || return $?;
	_BuildStartupNotification;
	return $?
}

CheckStartupNotification()
{
	CheckInstallation 	"${PackageStartupNotification[Programs]}"\
						"${PackageStartupNotification[Libraries]}"\
						"${PackageStartupNotification[Python]}" 1> /dev/null;
	return $?;
}

CheckStartupNotificationVerbose()
{
	CheckInstallationVerbose	"${PackageStartupNotification[Programs]}"\
								"${PackageStartupNotification[Libraries]}"\
								"${PackageStartupNotification[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageStartupNotification()
{
	DownloadPackage	"${PackageStartupNotification[Source]}"	"${SHMAN_PDIR}"	"${PackageStartupNotification[Package]}${PackageStartupNotification[Extension]}"	"${PackageStartupNotification[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageStartupNotification[Package]}"	"${PackageStartupNotification[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildStartupNotification()
{
	if ! cd "${SHMAN_PDIR}${PackageStartupNotification[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageStartupNotification[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageStartupNotification[Package]}/build \
	# 				|| { EchoError "${PackageStartupNotification[Name]}> Failed to enter ${SHMAN_PDIR}${PackageStartupNotification[Package]}/build"; return 1; }

	EchoInfo	"${PackageStartupNotification[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageStartupNotification[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageStartupNotification[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageStartupNotification[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageStartupNotification[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageStartupNotification[Name]} && PressAnyKeyToContinue; return 1; };
	install -v -m644 -D doc/startup-notification.txt \
			/usr/share/doc/startup-notification-0.12/startup-notification.txt
}
