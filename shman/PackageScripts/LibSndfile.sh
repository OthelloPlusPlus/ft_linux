#!/bin/bash

if [ ! -z "${PackageLibSndfile[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LibSndfile								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibSndfile;
# Manual
PackageLibSndfile[Source]="https://github.com/libsndfile/libsndfile/releases/download/1.2.2/libsndfile-1.2.2.tar.xz";
PackageLibSndfile[MD5]="04e2e6f726da7c5dc87f8cf72f250d04";
# Automated unless edgecase
PackageLibSndfile[Name]="";
PackageLibSndfile[Version]="";
PackageLibSndfile[Extension]="";
if [[ -n "${PackageLibSndfile[Source]}" ]]; then
	filename="${PackageLibSndfile[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibSndfile[Name]}" ]] && PackageLibSndfile[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibSndfile[Version]}" ]] && PackageLibSndfile[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibSndfile[Extension]}" ]] && PackageLibSndfile[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibSndfile[Package]="${PackageLibSndfile[Name]}-${PackageLibSndfile[Version]}";

PackageLibSndfile[Programs]="sndfile-cmp sndfile-concat sndfile-convert sndfile-deinterleave sndfile-info sndfile-interleave sndfile-metadata-get sndfile-metadata-set sndfile-play sndfile-salvage";
PackageLibSndfile[Libraries]="libsndfile.so";
PackageLibSndfile[Python]="";

InstallLibSndfile()
{
	# Check Installation
	CheckLibSndfile && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibSndfile[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(FAC Opus LibVorbis)
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(AlsaLib LAME Mpg123 Speex SQLite)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibSndfile[Name]}> Building package..."
	_ExtractPackageLibSndfile || return $?;
	_BuildLibSndfile;
	return $?
}

CheckLibSndfile()
{
	CheckInstallation 	"${PackageLibSndfile[Programs]}"\
						"${PackageLibSndfile[Libraries]}"\
						"${PackageLibSndfile[Python]}" 1> /dev/null;
	return $?;
}

CheckLibSndfileVerbose()
{
	CheckInstallationVerbose	"${PackageLibSndfile[Programs]}"\
								"${PackageLibSndfile[Libraries]}"\
								"${PackageLibSndfile[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibSndfile()
{
	DownloadPackage	"${PackageLibSndfile[Source]}"	"${SHMAN_PDIR}"	"${PackageLibSndfile[Package]}${PackageLibSndfile[Extension]}"	"${PackageLibSndfile[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibSndfile[Package]}"	"${PackageLibSndfile[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibSndfile()
{
	if ! cd "${SHMAN_PDIR}${PackageLibSndfile[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibSndfile[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibSndfile[Package]}/build \
	# 				|| { EchoError "${PackageLibSndfile[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibSndfile[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibSndfile[Name]}> Configure"
	./configure --prefix=/usr    \
				--docdir=/usr/share/doc/libsndfile-1.2.2 \
				1> /dev/null || { EchoTest KO ${PackageLibSndfile[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibSndfile[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibSndfile[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibSndfile[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageLibSndfile[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibSndfile[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibSndfile[Name]} && PressAnyKeyToContinue; return 1; };
}
