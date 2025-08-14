#!/bin/bash

if [ ! -z "${PackageFontconfig[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Fontconfig								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageFontconfig;
PackageFontconfig[Source]="https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.16.0.tar.xz";
PackageFontconfig[MD5]="20d5466544aa62d18c94106faa169a09";
PackageFontconfig[Name]="fontconfig";
PackageFontconfig[Version]="2.16.0";
PackageFontconfig[Package]="${PackageFontconfig[Name]}-${PackageFontconfig[Version]}";
PackageFontconfig[Extension]=".tar.xz";

PackageFontconfig[Programs]="fc-cache fc-cat fc-conflist fc-list fc-match fc-pattern fc-query fc-scan fc-validate";
PackageFontconfig[Libraries]="libfontconfig.so";
PackageFontconfig[Python]="";

InstallFontconfig()
{
	# Check Installation
	CheckFontconfig && return $?;

	# Check Dependencies
	EchoInfo	"${PackageFontconfig[Name]}> Checking dependencies..."
	Dependencies=(FreeTypeChain)
	for Dependency in "${Dependencies[@]}"; do

		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	Optional=(Bubblewrap cURL LibArchive JSONC DocBookUtils LibXml2 Texlive)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	_BuildFontconfig;
	return $?
}

CheckFontconfig()
{
	CheckInstallation 	"${PackageFontconfig[Programs]}"\
						"${PackageFontconfig[Libraries]}"\
						"${PackageFontconfig[Python]}" 1> /dev/null;
	return $?;
}

CheckFontconfigVerbose()
{
	CheckInstallationVerbose	"${PackageFontconfig[Programs]}"\
								"${PackageFontconfig[Libraries]}"\
								"${PackageFontconfig[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageFontconfig()
{
	DownloadPackage	"${PackageFontconfig[Source]}"	"${SHMAN_PDIR}"	"${PackageFontconfig[Package]}${PackageFontconfig[Extension]}"	"${PackageFontconfig[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageFontconfig[Package]}"	"${PackageFontconfig[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildFontconfig()
{
	EchoInfo	"Package ${PackageFontconfig[Name]}"

	DownloadPackage	"${PackageFontconfig[Source]}"	"${SHMAN_PDIR}"	"${PackageFontconfig[Package]}${PackageFontconfig[Extension]}"	"${PackageFontconfig[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageFontconfig[Package]}"	"${PackageFontconfig[Extension]}";
	# wget -P "${SHMAN_PDIR}" "";

	if ! cd "${SHMAN_PDIR}${PackageFontconfig[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageFontconfig[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageFontconfig[Name]}> Configure"
	./configure --prefix=/usr \
				--libdir=/usr/lib64 \
				--sysconfdir=/etc \
				--localstatedir=/var \
				--disable-docs \
				--docdir=/usr/share/doc/fontconfig-2.16.0 \
				1> /dev/null || { EchoTest KO ${PackageFontconfig[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFontconfig[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageFontconfig[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFontconfig[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageFontconfig[Name]} && EchoInfo	"${PackageFontconfig[Name]}> One test is known to fail if the kernel does not support user namespaces" && PressAnyKeyToContinue; };

	EchoInfo	"${PackageFontconfig[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageFontconfig[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFontconfig[Name]}> Installing the pre-generated documentation"
	install -v -dm755 							/usr/share/{man/man{1,3,5},doc/fontconfig-2.16.0} 
	install -v -m644 fc-*/*.1					/usr/share/man/man1
	install -v -m644 doc/*.3					/usr/share/man/man3
	install -v -m644 doc/fonts-conf.5			/usr/share/man/man5
	install -v -m644 doc/*.{pdf,sgml,txt,html}	/usr/share/doc/fontconfig-2.16.0
}
