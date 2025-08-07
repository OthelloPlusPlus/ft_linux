#!/bin/bash

if [ ! -z "${PackageCpio2[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									 Cpio2									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageCpio2;
# Manual
PackageCpio2[Source]="https://ftp.gnu.org/gnu/cpio/cpio-2.15.tar.bz2";
PackageCpio2[MD5]="3394d444ca1905ea56c94b628b706a0b";
# Automated unless edgecase
PackageCpio2[Name]="";
PackageCpio2[Version]="";
PackageCpio2[Extension]="";
if [[ -n "${PackageCpio2[Source]}" ]]; then
	filename="${PackageCpio2[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageCpio2[Name]}" ]] && PackageCpio2[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageCpio2[Version]}" ]] && PackageCpio2[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageCpio2[Extension]}" ]] && PackageCpio2[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageCpio2[Package]="${PackageCpio2[Name]}-${PackageCpio2[Version]}";

PackageCpio2[Programs]="cpio mt";
PackageCpio2[Libraries]="";
PackageCpio2[Python]="";

InstallCpio2()
{
	# Check Installation
	CheckCpio2 && return $?;

	# Check Dependencies
	EchoInfo	"${PackageCpio2[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageCpio2[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageCpio2[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Texlive)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageCpio2[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageCpio2[Name]}> Building package..."
	_ExtractPackageCpio2 || return $?;
	_BuildCpio2;
	return $?
}

CheckCpio2()
{
	CheckInstallation 	"${PackageCpio2[Programs]}"\
						"${PackageCpio2[Libraries]}"\
						"${PackageCpio2[Python]}" 1> /dev/null;
	return $?;
}

CheckCpio2Verbose()
{
	CheckInstallationVerbose	"${PackageCpio2[Programs]}"\
								"${PackageCpio2[Libraries]}"\
								"${PackageCpio2[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageCpio2()
{
	DownloadPackage	"${PackageCpio2[Source]}"	"${SHMAN_PDIR}"	"${PackageCpio2[Package]}${PackageCpio2[Extension]}"	"${PackageCpio2[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageCpio2[Package]}"	"${PackageCpio2[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildCpio2()
{
	if ! cd "${SHMAN_PDIR}${PackageCpio2[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageCpio2[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageCpio2[Package]}/build \
	# 				|| { EchoError "${PackageCpio2[Name]}> Failed to enter ${SHMAN_PDIR}${PackageCpio2[Package]}/build"; return 1; }

	EchoInfo	"${PackageCpio2[Name]}> Configure"
	./configure --prefix=/usr \
				--enable-mt \
				--with-rmt=/usr/libexec/rmt \
				1> /dev/null || { EchoTest KO ${PackageCpio2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCpio2[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageCpio2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCpio2[Name]}> makeinfo"
	makeinfo --html            -o doc/html      doc/cpio.texi 1> /dev/null
	makeinfo --html --no-split -o doc/cpio.html doc/cpio.texi 1> /dev/null
	makeinfo --plaintext       -o doc/cpio.txt  doc/cpio.texi 1> /dev/null

	EchoInfo	"${PackageCpio2[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageCpio2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCpio2[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageCpio2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCpio2[Name]}> install -v -m..."
	install -v -m755 -d /usr/share/doc/cpio-2.15/html \
						|| { EchoTest KO ${PackageCpio2[Name]} && PressAnyKeyToContinue; return 1; };
	install -v -m644    doc/html/* \
						/usr/share/doc/cpio-2.15/html \
						|| { EchoTest KO ${PackageCpio2[Name]} && PressAnyKeyToContinue; return 1; };
	install -v -m644    doc/cpio.{html,txt} \
						/usr/share/doc/cpio-2.15 \
						|| { EchoTest KO ${PackageCpio2[Name]} && PressAnyKeyToContinue; return 1; };
}
