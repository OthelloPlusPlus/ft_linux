#!/bin/bash

if [ ! -z "${PackageSassc[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Sassc								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageSassc;
# Manual
PackageSassc[Source]="https://github.com/sass/sassc/archive/3.6.2/sassc-3.6.2.tar.gz";
PackageSassc[MD5]="4c3b06ce2979f2a9f0a35093e501d8bb";
# Automated unless edgecase
PackageSassc[Name]="";
PackageSassc[Version]="";
PackageSassc[Extension]="";
if [[ -n "${PackageSassc[Source]}" ]]; then
	filename="${PackageSassc[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageSassc[Name]}" ]] && PackageSassc[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageSassc[Version]}" ]] && PackageSassc[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageSassc[Extension]}" ]] && PackageSassc[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageSassc[Package]="${PackageSassc[Name]}-${PackageSassc[Version]}";

PackageSassc[Programs]="sassc";
PackageSassc[Libraries]="libsass.so";
PackageSassc[Python]="";

InstallSassc()
{
	# Check Installation
	CheckSassc && return $?;

	# Check Dependencies
	EchoInfo	"${PackageSassc[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageSassc[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageSassc[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageSassc[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageSassc[Name]}> Building package..."
	_ExtractPackageSassc || return $?;
	_BuildSassc || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageSassc[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckSassc()
{
	CheckInstallation 	"${PackageSassc[Programs]}"\
						"${PackageSassc[Libraries]}"\
						"${PackageSassc[Python]}" 1> /dev/null;
	return $?;
}

CheckSasscVerbose()
{
	CheckInstallationVerbose	"${PackageSassc[Programs]}"\
								"${PackageSassc[Libraries]}"\
								"${PackageSassc[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageSassc()
{
	DownloadPackage	"${PackageSassc[Source]}"	"${SHMAN_PDIR}"	"${PackageSassc[Package]}${PackageSassc[Extension]}"	"${PackageSassc[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageSassc[Package]}"	"${PackageSassc[Extension]}" || return $?;

	for URL in \
		"https://github.com/sass/libsass/archive/3.6.6/libsass-3.6.6.tar.gz"
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildSassc()
{
	if ! cd "${SHMAN_PDIR}${PackageSassc[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageSassc[Package]}";
		return 1;
	fi

	tar -xf ../libsass-3.6.6.tar.gz
	pushd libsass-3.6.6
		EchoInfo	"lib${PackageSassc[Name]}> Configure"
		autoreconf -fi
		./configure --prefix=/usr 1> /dev/null || { EchoTest KO lib${PackageSassc[Name]} && PressAnyKeyToContinue; return 1; };

		EchoInfo	"lib${PackageSassc[Name]}> make"
		make 1> /dev/null || { EchoTest KO lib${PackageSassc[Name]} && PressAnyKeyToContinue; return 1; };

		EchoInfo	"lib${PackageSassc[Name]}> make install"
		make install 1> /dev/null || { EchoTest KO lib${PackageSassc[Name]} && PressAnyKeyToContinue; return 1; };
	popd
	

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageSassc[Package]}/build \
	# 				|| { EchoError "${PackageSassc[Name]}> Failed to enter ${SHMAN_PDIR}${PackageSassc[Package]}/build"; return 1; }

	EchoInfo	"${PackageSassc[Name]}> Configure"
	autoreconf -fi
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageSassc[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSassc[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageSassc[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSassc[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageSassc[Name]} && PressAnyKeyToContinue; return 1; };
}
