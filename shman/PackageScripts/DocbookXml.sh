#!/bin/bash

if [ ! -z "${PackageDocbookXml[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									DocbookXml								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageDocbookXml;
PackageDocbookXml[Source]="https://www.docbook.org/xml/4.5/docbook-xml-4.5.zip";
PackageDocbookXml[MD5]="03083e288e87a7e829e437358da7ef9e";
PackageDocbookXml[Name]="docbook-xml";
PackageDocbookXml[Version]="4.5";
PackageDocbookXml[Package]="${PackageDocbookXml[Name]}-${PackageDocbookXml[Version]}";
PackageDocbookXml[Extension]=".zip";

PackageDocbookXml[Programs]="";
PackageDocbookXml[Libraries]="";
PackageDocbookXml[Python]="";

InstallDocbookXml()
{
	# Check Installation
	CheckDocbookXml && return $?;

	# Check Dependencies
	EchoInfo	"${PackageDocbookXml[Name]}> Checking dependencies..."
	Required=(LibArchive LibXml2)
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
	EchoInfo	"${PackageDocbookXml[Name]}> Building package..."
	_ExtractPackageDocbookXml || return $?;
	_BuildDocbookXml;
	return $?
}

CheckDocbookXml()
{
	if [ ! -f /etc/xml/docbook ] || \
		[ $(ls /usr/share/xml/docbook/xml-dtd-4.5/*.dtd 2>/dev/null | wc -l) -lt 3 ] || \
		[ $(ls /usr/share/xml/docbook/xml-dtd-4.5/*.mod 2>/dev/null | wc -l) -lt 6 ]; then
		return 1
	fi
	return 0;
}

CheckDocbookXmlVerbose()
{
	if [ ! -f /etc/xml/docbook ]; then
		echo "${C_RED}docbook${C_RESET} " >&2;
		return 1;
	fi
	if [ $(ls /usr/share/xml/docbook/xml-dtd-4.5/*.dtd 2>/dev/null | wc -l) -lt 3 ]; then
		echo "${C_RED}*.dtd${C_RESET} " >&2;
		return 2;
	fi
	if [ $(ls /usr/share/xml/docbook/xml-dtd-4.5/*.mod 2>/dev/null | wc -l) -lt 3 ]; then
		echo "${C_RED}*.mod${C_RESET} " >&2;
		return 3;
	fi
	return 0;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageDocbookXml()
{
	DownloadPackage	"${PackageDocbookXml[Source]}"	"${SHMAN_PDIR}"	"${PackageDocbookXml[Package]}${PackageDocbookXml[Extension]}"	"${PackageDocbookXml[MD5]}";
	unzip -o -q "${SHMAN_PDIR}${PackageDocbookXml[Package]}${PackageDocbookXml[Extension]}" -d "${SHMAN_PDIR}/${PackageDocbookXml[Package]}"

	return $?;
}

_BuildDocbookXml()
{
	if ! cd "${SHMAN_PDIR}${PackageDocbookXml[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageDocbookXml[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageDocbookXml[Name]}> install xml-dtd-4.5"
	install -v -d -m755 /usr/share/xml/docbook/xml-dtd-4.5 1> /dev/null || { EchoTest KO ${PackageDocbookXml[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDocbookXml[Name]}> install xml"
	install -v -d -m755 /etc/xml 1> /dev/null || { EchoTest KO ${PackageDocbookXml[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDocbookXml[Name]}> Copy files"
	cp -v -af --no-preserve=ownership docbook.cat *.dtd ent/ *.mod /usr/share/xml/docbook/xml-dtd-4.5


	EchoInfo	"${PackageDocbookXml[Name]}> /etc/xml/docbook"
	if [ ! -e /etc/xml/docbook ]; then
    xmlcatalog --noout --create /etc/xml/docbook
fi &&
xmlcatalog --noout --add "public" \
    "-//OASIS//DTD DocBook XML V4.5//EN" \
    "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//DTD DocBook XML CALS Table Model V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/calstblx.dtd" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//DTD XML Exchange Table Model 19990315//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/soextblx.dtd" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML Information Pool V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbpoolx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML Document Hierarchy V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbhierx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML HTML Tables V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/htmltblx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Notations V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbnotnx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Character Entities V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbcentx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Additional General Entities V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbgenent.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "rewriteSystem" \
    "http://www.oasis-open.org/docbook/xml/4.5" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "rewriteURI" \
    "http://www.oasis-open.org/docbook/xml/4.5" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    /etc/xml/docbook

	EchoInfo	"${PackageDocbookXml[Name]}> /etc/xml/catalog"
	if [ ! -e /etc/xml/catalog ]; then
    xmlcatalog --noout --create /etc/xml/catalog
fi &&
xmlcatalog --noout --add "delegatePublic" \
    "-//OASIS//ENTITIES DocBook XML" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog &&
xmlcatalog --noout --add "delegatePublic" \
    "-//OASIS//DTD DocBook XML" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog &&
xmlcatalog --noout --add "delegateSystem" \
    "http://www.oasis-open.org/docbook/" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog &&
xmlcatalog --noout --add "delegateURI" \
    "http://www.oasis-open.org/docbook/" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog

	for DTDVERSION in 4.1.2 4.2 4.3 4.4
do
	EchoInfo	"${PackageDocbookXml[Name]}> catalog $DTDVERSION"
  xmlcatalog --noout --add "public" \
    "-//OASIS//DTD DocBook XML V$DTDVERSION//EN" \
    "http://www.oasis-open.org/docbook/xml/$DTDVERSION/docbookx.dtd" \
    /etc/xml/docbook
  xmlcatalog --noout --add "rewriteSystem" \
    "http://www.oasis-open.org/docbook/xml/$DTDVERSION" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    /etc/xml/docbook
  xmlcatalog --noout --add "rewriteURI" \
    "http://www.oasis-open.org/docbook/xml/$DTDVERSION" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    /etc/xml/docbook
  xmlcatalog --noout --add "delegateSystem" \
    "http://www.oasis-open.org/docbook/xml/$DTDVERSION/" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog
  xmlcatalog --noout --add "delegateURI" \
    "http://www.oasis-open.org/docbook/xml/$DTDVERSION/" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog
done
}
