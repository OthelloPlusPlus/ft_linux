#!/bin/bash

if [ ! -z "${PackageNettle[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									 Nettle									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageNettle;
PackageNettle[Source]="https://ftp.gnu.org/gnu/nettle/nettle-3.10.1.tar.gz";
PackageNettle[MD5]="c3dc1729cfa65fcabe2023dfbff60beb";
PackageNettle[Name]="nettle";
PackageNettle[Version]="3.10.1";
PackageNettle[Package]="${PackageNettle[Name]}-${PackageNettle[Version]}";
PackageNettle[Extension]=".tar.gz";

PackageNettle[Programs]="nettle-hash nettle-lfib-stream nettle-pbkdf2 pkcs1-conv sexp-conv";
PackageNettle[Libraries]="libhogweed.so libnettle.so";
PackageNettle[Python]="";

InstallNettle()
{
	# Check Installation
	CheckNettle && return $?;

	# Check Dependencies
	Dependencies=()
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
	_BuildNettle;
	return $?
}

CheckNettle()
{
	CheckInstallation	"${PackageNettle[Programs]}"\
						"${PackageNettle[Libraries]}"\
						"${PackageNettle[Python]}" 1> /dev/null;
	return $?;
}

CheckNettleVerbose()
{
	CheckInstallationVerbose	"${PackageNettle[Programs]}"\
								"${PackageNettle[Libraries]}"\
								"${PackageNettle[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildNettle()
{
	EchoInfo	"Package ${PackageNettle[Name]}"

	DownloadPackage	"${PackageNettle[Source]}"	"${SHMAN_PDIR}"	"${PackageNettle[Package]}${PackageNettle[Extension]}"	"${PackageNettle[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageNettle[Package]}"	"${PackageNettle[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageNettle[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageNettle[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageNettle[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageNettle[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNettle[Name]}> make"
	make  1> /dev/null || { EchoTest KO ${PackageNettle[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNettle[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageNettle[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageNettle[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageNettle[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageNettle[Name]}> Final Setup"
	chmod   -v   755 /usr/lib64/lib{hogweed,nettle}.so || { EchoTest KO ${PackageNettle[Name]} && PressAnyKeyToContinue; return 1; };
	install -v -m755 -d /usr/share/doc/nettle-3.10.1 || { EchoTest KO ${PackageNettle[Name]} && PressAnyKeyToContinue; return 1; };
	install -v -m644 nettle.{html,pdf} /usr/share/doc/nettle-3.10.1 || { EchoTest KO ${PackageNettle[Name]} && PressAnyKeyToContinue; return 1; };
}
