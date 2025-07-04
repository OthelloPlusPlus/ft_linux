#!/bin/bash

if [ ! -z "${PackageLibXslt[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibXslt									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibXslt;
PackageLibXslt[Source]="https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.42.tar.xz";
PackageLibXslt[MD5]="56bc5d89aa39d62002961c150fec08a0";
PackageLibXslt[Name]="libxslt";
PackageLibXslt[Version]="1.1.42";
PackageLibXslt[Package]="${PackageLibXslt[Name]}-${PackageLibXslt[Version]}";
PackageLibXslt[Extension]=".tar.xz";

PackageLibXslt[Programs]="xslt-config xsltproc";
PackageLibXslt[Libraries]="libexslt.so libxslt.so";
PackageLibXslt[Python]="libxsltmod";

InstallLibXslt()
{
	# Check Installation
	CheckLibXslt && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibXslt[Name]}> Checking dependencies..."
	Dependencies=(LibXml2)
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh";
		fi
	done
	
	# Install Package
	_BuildLibXslt;
	return $?
}

CheckLibXslt()
{
	CheckInstallation	"${PackageLibXslt[Programs]}"\
						"${PackageLibXslt[Libraries]}"\
						"${PackageLibXslt[Python]}" 1> /dev/null;
	return $?;
}

CheckLibXsltVerbose()
{
	CheckInstallationVerbose	"${PackageLibXslt[Programs]}"\
								"${PackageLibXslt[Libraries]}"\
								"${PackageLibXslt[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildLibXslt()
{
	EchoInfo	"Package ${PackageLibXslt[Name]}"

	DownloadPackage	"${PackageLibXslt[Source]}"	"${SHMAN_PDIR}"	"${PackageLibXslt[Package]}${PackageLibXslt[Extension]}"	"${PackageLibXslt[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibXslt[Package]}"	"${PackageLibXslt[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageLibXslt[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibXslt[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibXslt[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--docdir=/usr/share/doc/libxslt-1.1.42 \
				1> /dev/null || { EchoTest KO ${PackageLibXslt[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXslt[Name]}> make"
	make  1> /dev/null || { EchoTest KO ${PackageLibXslt[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXslt[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibXslt[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLibXslt[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibXslt[Name]} && PressAnyKeyToContinue; return 1; };
}
