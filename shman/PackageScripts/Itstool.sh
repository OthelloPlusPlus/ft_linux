#!/bin/bash

if [ ! -z "${PackageItstool[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Itstool									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageItstool;
PackageItstool[Source]="https://files.itstool.org/itstool/itstool-2.0.7.tar.bz2";
PackageItstool[MD5]="267a3bdc72a2d8abb1b824f2ea32ee9b";
PackageItstool[Name]="itstool";
PackageItstool[Version]="2.0.7";
PackageItstool[Package]="${PackageItstool[Name]}-${PackageItstool[Version]}";
PackageItstool[Extension]=".tar.bz2";

PackageItstool[Programs]="itstool";
PackageItstool[Libraries]="";
PackageItstool[Python]="";

InstallItstool()
{
	# Check Installation
	CheckItstool && return $?;

	# Check Dependencies
	EchoInfo	"${PackageItstool[Name]}> Checking dependencies..."
	Required=(DocbookXml)
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
	EchoInfo	"${PackageItstool[Name]}> Building package..."
	_ExtractPackageItstool || return $?;
	_BuildItstool;
	return $?
}

CheckItstool()
{
	CheckInstallation 	"${PackageItstool[Programs]}"\
						"${PackageItstool[Libraries]}"\
						"${PackageItstool[Python]}" 1> /dev/null;
	return $?;
}

CheckItstoolVerbose()
{
	CheckInstallationVerbose	"${PackageItstool[Programs]}"\
								"${PackageItstool[Libraries]}"\
								"${PackageItstool[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageItstool()
{
	DownloadPackage	"${PackageItstool[Source]}"	"${SHMAN_PDIR}"	"${PackageItstool[Package]}${PackageItstool[Extension]}"	"${PackageItstool[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageItstool[Package]}"	"${PackageItstool[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildItstool()
{
	if ! cd "${SHMAN_PDIR}${PackageItstool[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageItstool[Package]}";
		return 1;
	fi

	sed -i 's/re.sub(/re.sub(r/'         itstool.in
	sed -i 's/re.compile(/re.compile(r/' itstool.in

	EchoInfo	"${PackageItstool[Name]}> Configure"
	PYTHON=/usr/bin/python3 ./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageItstool[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageItstool[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageItstool[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageItstool[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageItstool[Name]} && PressAnyKeyToContinue; return 1; };
}
