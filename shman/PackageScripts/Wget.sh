#!/bin/bash

if [ ! -z "${PackageWget[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Wget								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageWget;
PackageWget[Source]="https://ftp.gnu.org/gnu/wget/wget-1.25.0.tar.gz";
PackageWget[MD5]="c70ba58b36f944e8ba1d655ace552881";
PackageWget[Name]="wget";
PackageWget[Version]="1.25.0";
PackageWget[Package]="${PackageWget[Name]}-${PackageWget[Version]}";
PackageWget[Extension]=".tar.gz";

PackageWget[Programs]="wget";
PackageWget[Libraries]="";
PackageWget[Python]="";

InstallWget()
{
	# Check Installation
	CheckWget && return $?;

	# Check Dependencies
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(LibPsl)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(GnuTLS HTTPDaemon IOSocketSSL LibIdn2 LibProxy PCRE2 Valgrind)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"Package ${PackageWget[Name]}"
	# _ExtractPackageWget || return $?;
	# _BuildWget;
	return $?
}

CheckWget()
{
	CheckInstallation 	"${PackageWget[Programs]}"\
						"${PackageWget[Libraries]}"\
						"${PackageWget[Python]}" 1> /dev/null;
	return $?;
}

CheckWgetVerbose()
{
	CheckInstallationVerbose	"${PackageWget[Programs]}"\
								"${PackageWget[Libraries]}"\
								"${PackageWget[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageWget()
{
	DownloadPackage	"${PackageWget[Source]}"	"${SHMAN_PDIR}"	"${PackageWget[Package]}${PackageWget[Extension]}"	"${PackageWget[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageWget[Package]}"	"${PackageWget[Extension]}" || return $?;

	return $?;
}

_BuildWget()
{
	if ! cd "${SHMAN_PDIR}${PackageWget[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageWget[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageWget[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--with-ssl=openssl \
				1> /dev/null || { EchoTest KO ${PackageWget[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageWget[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageWget[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageWget[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageWget[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageWget[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageWget[Name]} && PressAnyKeyToContinue; return 1; };
}
