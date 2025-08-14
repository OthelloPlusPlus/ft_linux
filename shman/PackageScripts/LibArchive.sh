#!/bin/bash

if [ ! -z "${PackageLibArchive[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibArchive								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibArchive;
PackageLibArchive[Source]="https://github.com/libarchive/libarchive/releases/download/v3.7.7/libarchive-3.7.7.tar.xz";
PackageLibArchive[MD5]="50c4dea9eba9a0add25ac1cfc9ba2cdb";
PackageLibArchive[Name]="libarchive";
PackageLibArchive[Version]="3.7.7";
PackageLibArchive[Package]="${PackageLibArchive[Name]}-${PackageLibArchive[Version]}";
PackageLibArchive[Extension]=".tar.xz";

PackageLibArchive[Programs]="bsdcat bsdcpio bsdtar bsdunzip";
PackageLibArchive[Libraries]="libarchive.so";
PackageLibArchive[Python]="";

InstallLibArchive()
{
	# Check Installation
	CheckLibArchive && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibArchive[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(LibXml2 LZO Nettle PCRE2)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"Package ${PackageLibArchive[Name]}"
	_ExtractPackageLibArchive || return $?;
	_BuildLibArchive;
	return $?
}

CheckLibArchive()
{
	CheckInstallation 	"${PackageLibArchive[Programs]}"\
						"${PackageLibArchive[Libraries]}"\
						"${PackageLibArchive[Python]}" 1> /dev/null;
	return $?;
}

CheckLibArchiveVerbose()
{
	CheckInstallationVerbose	"${PackageLibArchive[Programs]}"\
								"${PackageLibArchive[Libraries]}"\
								"${PackageLibArchive[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibArchive()
{
	DownloadPackage	"${PackageLibArchive[Source]}"	"${SHMAN_PDIR}"	"${PackageLibArchive[Package]}${PackageLibArchive[Extension]}"	"${PackageLibArchive[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibArchive[Package]}"	"${PackageLibArchive[Extension]}" || return $?;

	return $?;
}

_BuildLibArchive()
{
	if ! cd "${SHMAN_PDIR}${PackageLibArchive[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibArchive[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibArchive[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageLibArchive[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibArchive[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibArchive[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibArchive[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibArchive[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibArchive[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibArchive[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibArchive[Name]}> Creating symlink for bsdunzip"
	ln -sfv bsdunzip /usr/bin/unzip
}
