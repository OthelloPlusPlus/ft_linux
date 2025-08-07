#!/bin/bash

if [ ! -z "${PackageOpenVmTools[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									OpenVmTools								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageOpenVmTools;
# Manual
PackageOpenVmTools[Source]="https://github.com/vmware/open-vm-tools/releases/download/stable-13.0.0/open-vm-tools-13.0.0-24696409.tar.gz";
PackageOpenVmTools[MD5]="";
# Automated unless edgecase
PackageOpenVmTools[Name]="";
PackageOpenVmTools[Version]="";
PackageOpenVmTools[Extension]="";
if [[ -n "${PackageOpenVmTools[Source]}" ]]; then
	filename="${PackageOpenVmTools[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageOpenVmTools[Name]}" ]] && PackageOpenVmTools[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageOpenVmTools[Version]}" ]] && PackageOpenVmTools[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageOpenVmTools[Extension]}" ]] && PackageOpenVmTools[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageOpenVmTools[Package]="${PackageOpenVmTools[Name]}-${PackageOpenVmTools[Version]}";

PackageOpenVmTools[Programs]="";
PackageOpenVmTools[Libraries]="";
PackageOpenVmTools[Python]="";

InstallOpenVmTools()
{
	# Check Installation
	CheckOpenVmTools && return $?;

	# Check Dependencies
	EchoInfo	"${PackageOpenVmTools[Name]}> Checking dependencies..."
	# https://github.com/vmware/open-vm-tools/releases
	Required=(LibMspack)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageOpenVmTools[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageOpenVmTools[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageOpenVmTools[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageOpenVmTools[Name]}> Building package..."
	_ExtractPackageOpenVmTools || return $?;
	_BuildOpenVmTools || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageOpenVmTools[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckOpenVmTools()
{
	CheckInstallation 	"${PackageOpenVmTools[Programs]}"\
						"${PackageOpenVmTools[Libraries]}"\
						"${PackageOpenVmTools[Python]}" 1> /dev/null;
	return $?;
}

CheckOpenVmToolsVerbose()
{
	CheckInstallationVerbose	"${PackageOpenVmTools[Programs]}"\
								"${PackageOpenVmTools[Libraries]}"\
								"${PackageOpenVmTools[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageOpenVmTools()
{
	DownloadPackage	"${PackageOpenVmTools[Source]}"	"${SHMAN_PDIR}"	"${PackageOpenVmTools[Package]}${PackageOpenVmTools[Extension]}"	"${PackageOpenVmTools[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageOpenVmTools[Package]}"	"${PackageOpenVmTools[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildOpenVmTools()
{
	if ! cd "${SHMAN_PDIR}${PackageOpenVmTools[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageOpenVmTools[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageOpenVmTools[Package]}/build \
	# 				|| { EchoError "${PackageOpenVmTools[Name]}> Failed to enter ${SHMAN_PDIR}${PackageOpenVmTools[Package]}/build"; return 1; }

	EchoInfo	"${PackageOpenVmTools[Name]}> Configure"
	autoreconf -i
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageOpenVmTools[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageOpenVmTools[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageOpenVmTools[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageOpenVmTools[Name]}> make check"
	# make check 1> /dev/null || { EchoTest KO ${PackageOpenVmTools[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageOpenVmTools[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageOpenVmTools[Name]} && PressAnyKeyToContinue; return 1; };

	ldconfig
}
