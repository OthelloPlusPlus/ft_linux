#!/bin/bash

if [ ! -z "${PackageLibXml2[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibXml2									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibXml2;
PackageLibXml2[Source]="https://download.gnome.org/sources/libxml2/2.13/libxml2-2.13.6.tar.xz";
PackageLibXml2[MD5]="85dffa2387ff756bdf8b3b247594914a";
PackageLibXml2[Name]="libxml2";
PackageLibXml2[Version]="2.13.6";
PackageLibXml2[Package]="${PackageLibXml2[Name]}-${PackageLibXml2[Version]}";
PackageLibXml2[Extension]=".tar.xz";

PackageLibXml2[Programs]="xml2-config xmlcatalog xmllint";
PackageLibXml2[Libraries]="libxml2.so";
PackageLibXml2[Python]="";

InstallLibXml2()
{
	# Check Installation
	CheckLibXml2 && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibXml2[Name]}> Checking dependencies..."
	Dependencies=()
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=(ICU)
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
	_BuildLibXml2;
	return $?
}

CheckLibXml2()
{
	CheckInstallation	"${PackageLibXml2[Programs]}"\
						"${PackageLibXml2[Libraries]}"\
						"${PackageLibXml2[Python]}" 1> /dev/null;
	return $?;
}

CheckLibXml2Verbose()
{
	CheckInstallationVerbose	"${PackageLibXml2[Programs]}"\
								"${PackageLibXml2[Libraries]}"\
								"${PackageLibXml2[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildLibXml2()
{
	EchoInfo	"Package ${PackageLibXml2[Name]}"

	DownloadPackage	"${PackageLibXml2[Source]}"	"${SHMAN_PDIR}"	"${PackageLibXml2[Package]}${PackageLibXml2[Extension]}"	"${PackageLibXml2[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibXml2[Package]}"	"${PackageLibXml2[Extension]}";
	# wget -P "${SHMAN_PDIR}" "https://www.w3.org/XML/Test/xmlts20130923.tar.gz";

	if ! cd "${SHMAN_PDIR}${PackageLibXml2[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibXml2[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibXml2[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--disable-static \
				--with-history \
				--with-icu \
				PYTHON=/usr/bin/python3 \
				--docdir=/usr/share/doc/libxml2-2.13.6 \
				&& 1> /dev/null || { EchoTest KO ${PackageLibXml2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXml2[Name]}> make"
	make  1> /dev/null || { EchoTest KO ${PackageLibXml2[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageLibXml2[Name]}> make check"
	# tar xf ../xmlts20130923.tar.gz;
	# make check 1> /dev/null || { EchoTest KO ${PackageLibXml2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXml2[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibXml2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibXml2[Name]}> Prevent some packages unnecessarily linking to ICU"
	rm -vf /usr/lib/libxml2.la &&
	sed '/libs=/s/xml2.*/xml2"/' -i /usr/bin/xml2-config
}
