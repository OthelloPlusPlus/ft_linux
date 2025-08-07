#!/bin/bash

if [ ! -z "${PackageCrackLib[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									CrackLib								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageCrackLib;
# Manual
PackageCrackLib[Source]="https://github.com/cracklib/cracklib/releases/download/v2.10.3/cracklib-2.10.3.tar.xz";
PackageCrackLib[MD5]="e8ea2b86de774fc09fdd0f2829680b19";
# Automated unless edgecase
PackageCrackLib[Name]="";
PackageCrackLib[Version]="";
PackageCrackLib[Extension]="";
if [[ -n "${PackageCrackLib[Source]}" ]]; then
	filename="${PackageCrackLib[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageCrackLib[Name]}" ]] && PackageCrackLib[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageCrackLib[Version]}" ]] && PackageCrackLib[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageCrackLib[Extension]}" ]] && PackageCrackLib[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageCrackLib[Package]="${PackageCrackLib[Name]}-${PackageCrackLib[Version]}";

PackageCrackLib[Programs]="cracklib-check cracklib-format cracklib-packer cracklib-unpacker cracklib-update create-cracklib-dict";
PackageCrackLib[Libraries]="libcrack.so";
PackageCrackLib[Python]="_cracklib.so";

InstallCrackLib()
{
	# Check Installation
	CheckCrackLib && return $?;

	# Check Dependencies
	EchoInfo	"${PackageCrackLib[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageCrackLib[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageCrackLib[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageCrackLib[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageCrackLib[Name]}> Building package..."
	_ExtractPackageCrackLib || return $?;
	_BuildCrackLib || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageCrackLib[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckCrackLib()
{
	CheckInstallation 	"${PackageCrackLib[Programs]}"\
						"${PackageCrackLib[Libraries]}"\
						"${PackageCrackLib[Python]}" 1> /dev/null;
	return $?;
}

CheckCrackLibVerbose()
{
	CheckInstallationVerbose	"${PackageCrackLib[Programs]}"\
								"${PackageCrackLib[Libraries]}"\
								"${PackageCrackLib[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageCrackLib()
{
	DownloadPackage	"${PackageCrackLib[Source]}"	"${SHMAN_PDIR}"	"${PackageCrackLib[Package]}${PackageCrackLib[Extension]}"	"${PackageCrackLib[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageCrackLib[Package]}"	"${PackageCrackLib[Extension]}" || return $?;

	for URL in \
		"https://github.com/cracklib/cracklib/releases/download/v2.10.3/cracklib-words-2.10.3.xz"
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildCrackLib()
{
	if ! cd "${SHMAN_PDIR}${PackageCrackLib[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageCrackLib[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageCrackLib[Package]}/build \
	# 				|| { EchoError "${PackageCrackLib[Name]}> Failed to enter ${SHMAN_PDIR}${PackageCrackLib[Package]}/build"; return 1; }

	EchoInfo	"${PackageCrackLib[Name]}> Configure"
	CPPFLAGS+=' -I /usr/include/python3.13' \
	./configure --prefix=/usr \
				--disable-static \
				--with-default-dict=/usr/lib/cracklib/pw_dict \
				1> /dev/null || { EchoTest KO ${PackageCrackLib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCrackLib[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageCrackLib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCrackLib[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageCrackLib[Name]} && PressAnyKeyToContinue; return 1; };

	xzcat ../cracklib-words-2.10.3.xz \
						> /usr/share/dict/cracklib-words       &&
	ln -v -sf cracklib-words /usr/share/dict/words                &&
	echo $(hostname) >>      /usr/share/dict/cracklib-extra-words &&
	install -v -m755 -d      /usr/lib/cracklib                    &&

	create-cracklib-dict     /usr/share/dict/cracklib-words \
							/usr/share/dict/cracklib-extra-words
}
