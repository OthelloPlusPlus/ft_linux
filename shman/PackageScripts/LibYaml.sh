#!/bin/bash

if [ ! -z "${PackageLibYaml[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibYaml									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibYaml;
PackageLibYaml[Source]="https://github.com/yaml/libyaml/releases/download/0.2.5/yaml-0.2.5.tar.gz";
PackageLibYaml[MD5]="bb15429d8fb787e7d3f1c83ae129a999";
PackageLibYaml[Name]="yaml";
PackageLibYaml[Version]="0.2.5";
PackageLibYaml[Package]="${PackageLibYaml[Name]}-${PackageLibYaml[Version]}";
PackageLibYaml[Extension]=".tar.gz";

PackageLibYaml[Programs]="";
PackageLibYaml[Libraries]="libyaml.so";
PackageLibYaml[Python]="";

InstallLibYaml()
{
	# Check Installation
	CheckLibYaml && return $?;

	# Check Dependencies
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"Package ${PackageLibYaml[Name]}"
	_ExtractPackageLibYaml || return $?;
	_BuildLibYaml;
	return $?
}

CheckLibYaml()
{
	CheckInstallation 	"${PackageLibYaml[Programs]}"\
						"${PackageLibYaml[Libraries]}"\
						"${PackageLibYaml[Python]}" 1> /dev/null;
	return $?;
}

CheckLibYamlVerbose()
{
	CheckInstallationVerbose	"${PackageLibYaml[Programs]}"\
								"${PackageLibYaml[Libraries]}"\
								"${PackageLibYaml[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibYaml()
{
	DownloadPackage	"${PackageLibYaml[Source]}"	"${SHMAN_PDIR}"	"${PackageLibYaml[Package]}${PackageLibYaml[Extension]}"	"${PackageLibYaml[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibYaml[Package]}"	"${PackageLibYaml[Extension]}" || return $?;

	return $?;
}

_BuildLibYaml()
{
	if ! cd "${SHMAN_PDIR}${PackageLibYaml[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibYaml[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibYaml[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageLibYaml[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibYaml[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibYaml[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibYaml[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibYaml[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibYaml[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibYaml[Name]} && PressAnyKeyToContinue; return 1; };
}
