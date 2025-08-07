#!/bin/bash

if [ ! -z "${PackageDocbookXslNons[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									DocbookXslNons								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageDocbookXslNons;
PackageDocbookXslNons[Source]="https://github.com/docbook/xslt10-stylesheets/releases/download/release/1.79.2/docbook-xsl-nons-1.79.2.tar.bz2";
PackageDocbookXslNons[MD5]="2666d1488d6ced1551d15f31d7ed8c38";
PackageDocbookXslNons[Name]="docbook-xsl-nons";
PackageDocbookXslNons[Version]="1.79.2";
PackageDocbookXslNons[Package]="${PackageDocbookXslNons[Name]}-${PackageDocbookXslNons[Version]}";
PackageDocbookXslNons[Extension]=".tar.bz2";

PackageDocbookXslNons[Programs]="";
PackageDocbookXslNons[Libraries]="";
PackageDocbookXslNons[Python]="";

InstallDocbookXslNons()
{
	# Check Installation
	CheckDocbookXslNons && return $?;

	# Check Dependencies
	EchoInfo	"${PackageDocbookXslNons[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(LibXml2)
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(ApacheAnt LibXslt Ruby Zip)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageDocbookXslNons[Name]}> Building package..."
	_ExtractPackageDocbookXslNons || return $?;
	_BuildDocbookXslNons;
	return $?
}

CheckDocbookXslNons()
{
	if [ ! -f /usr/share/doc/docbook-xsl-nons-1.79.2/README ] || \
		[ $(ls /usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2/*/*.xsl 2> /dev/null | wc -l) -lt 334 ]; then
		return 1;
	fi
	return 0;
}

CheckDocbookXslNonsVerbose()
{
	if [ ! -f /usr/share/doc/docbook-xsl-nons-1.79.2/README ]; then
		echo "${C_RED}doc/docbook-xsl-nons-1.79.2${C_RESET} " >&2;
		return 1;
	fi
	if [ $(ls /usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2/*/*.xsl 2> /dev/null | wc -l) -lt 334 ]; then
		echo "${C_RED}*.xsl${C_RESET} " >&2;
		return 2;
	fi
	return 0;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageDocbookXslNons()
{
	DownloadPackage	"${PackageDocbookXslNons[Source]}"	"${SHMAN_PDIR}"	"${PackageDocbookXslNons[Package]}${PackageDocbookXslNons[Extension]}"	"${PackageDocbookXslNons[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageDocbookXslNons[Package]}"	"${PackageDocbookXslNons[Extension]}" || return $?;

	for URL in \
		"https://www.linuxfromscratch.org/patches/blfs/12.3/docbook-xsl-nons-1.79.2-stack_fix-1.patch"\
		"https://github.com/docbook/xslt10-stylesheets/releases/download/release/1.79.2/docbook-xsl-doc-1.79.2.tar.bz2"
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildDocbookXslNons()
{
	if ! cd "${SHMAN_PDIR}${PackageDocbookXslNons[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageDocbookXslNons[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageDocbookXslNons[Name]}> Patching"
	patch -Np1 -i ../docbook-xsl-nons-1.79.2-stack_fix-1.patch

	EchoInfo	"${PackageDocbookXslNons[Name]}> Unpacking Documentation tarball"
	tar -xf ../docbook-xsl-doc-1.79.2.tar.bz2 --strip-components=1

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageDocbookXslNons[Package]}/build \
	# 				|| { EchoError "${PackageDocbookXslNons[Name]}> Failed to enter ${SHMAN_PDIR}${PackageDocbookXslNons[Package]}/build"; return 1; }

	EchoInfo	"${PackageDocbookXslNons[Name]}> Installation"
	install -v -m755 -d /usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2 &&

	cp -v -R VERSION assembly common eclipse epub epub3 extensions fo        \
			highlighting html htmlhelp images javahelp lib manpages params  \
			profiling roundtrip slides template tests tools webhelp website \
			xhtml xhtml-1_1 xhtml5                                          \
		/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2 &&

	ln -sf VERSION /usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2/VERSION.xsl &&

	install -v -m644 -D README \
						/usr/share/doc/docbook-xsl-nons-1.79.2/README.txt &&
	install -v -m644    RELEASE-NOTES* NEWS* \
						/usr/share/doc/docbook-xsl-nons-1.79.2 \
		1> /dev/null || { EchoTest KO ${PackageDocbookXslNons[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDocbookXslNons[Name]}> Documentation"
	cp -v -R doc/* /usr/share/doc/docbook-xsl-nons-1.79.2 1> /dev/null || { EchoTest KO ${PackageDocbookXslNons[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDocbookXslNons[Name]}> Configuration"
if [ ! -d /etc/xml ]; then install -v -m755 -d /etc/xml; fi &&
if [ ! -f /etc/xml/catalog ]; then
    xmlcatalog --noout --create /etc/xml/catalog
fi &&

xmlcatalog --noout --add "rewriteSystem" \
           "http://cdn.docbook.org/release/xsl-nons/1.79.2" \
           "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
    /etc/xml/catalog &&

xmlcatalog --noout --add "rewriteSystem" \
           "https://cdn.docbook.org/release/xsl-nons/1.79.2" \
           "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
    /etc/xml/catalog &&

xmlcatalog --noout --add "rewriteURI" \
           "http://cdn.docbook.org/release/xsl-nons/1.79.2" \
           "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
    /etc/xml/catalog &&

xmlcatalog --noout --add "rewriteURI" \
           "https://cdn.docbook.org/release/xsl-nons/1.79.2" \
           "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
    /etc/xml/catalog &&

xmlcatalog --noout --add "rewriteSystem" \
           "http://cdn.docbook.org/release/xsl-nons/current" \
           "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
    /etc/xml/catalog &&

xmlcatalog --noout --add "rewriteSystem" \
           "https://cdn.docbook.org/release/xsl-nons/current" \
           "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
    /etc/xml/catalog &&

xmlcatalog --noout --add "rewriteURI" \
           "http://cdn.docbook.org/release/xsl-nons/current" \
           "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
    /etc/xml/catalog &&

xmlcatalog --noout --add "rewriteURI" \
           "https://cdn.docbook.org/release/xsl-nons/current" \
           "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
    /etc/xml/catalog &&

xmlcatalog --noout --add "rewriteSystem" \
           "http://docbook.sourceforge.net/release/xsl/current" \
           "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
    /etc/xml/catalog &&

xmlcatalog --noout --add "rewriteURI" \
           "http://docbook.sourceforge.net/release/xsl/current" \
           "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
    /etc/xml/catalog
}
