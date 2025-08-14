#!/bin/bash

if [ ! -z "${PackageSpiderMonkey[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#								  SpiderMonkey								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageSpiderMonkey;
PackageSpiderMonkey[Source]="https://archive.mozilla.org/pub/firefox/releases/128.7.0esr/source/firefox-128.7.0esr.source.tar.xz";
PackageSpiderMonkey[MD5]="aab1f335242b809813d1d4b754d10c0b";
PackageSpiderMonkey[Name]="firefox";
PackageSpiderMonkey[Version]="128.7.0";
PackageSpiderMonkey[Package]="${PackageSpiderMonkey[Name]}-${PackageSpiderMonkey[Version]}";
PackageSpiderMonkey[Extension]=".tar.xz";

PackageSpiderMonkey[Programs]="js128 js128-config";
PackageSpiderMonkey[Libraries]="libmozjs-128.so";
PackageSpiderMonkey[Python]="";

InstallSpiderMonkey()
{
	# Check Installation
	CheckSpiderMonkey && return $?;

	# Check Dependencies
	EchoInfo	"${PackageSpiderMonkey[Name]}> Checking dependencies..."
	Required=(Cbindgen ICU Which)
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
	EchoInfo	"${PackageSpiderMonkey[Name]}> Building package..."
	_ExtractPackageSpiderMonkey || return $?;
	_BuildSpiderMonkey;
	return $?
}

CheckSpiderMonkey()
{
	CheckInstallation 	"${PackageSpiderMonkey[Programs]}"\
						"${PackageSpiderMonkey[Libraries]}"\
						"${PackageSpiderMonkey[Python]}" 1> /dev/null;
	return $?;
}

CheckSpiderMonkeyVerbose()
{
	CheckInstallationVerbose	"${PackageSpiderMonkey[Programs]}"\
								"${PackageSpiderMonkey[Libraries]}"\
								"${PackageSpiderMonkey[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageSpiderMonkey()
{
	DownloadPackage	"${PackageSpiderMonkey[Source]}"	"${SHMAN_PDIR}"	"${PackageSpiderMonkey[Package]}${PackageSpiderMonkey[Extension]}"	"${PackageSpiderMonkey[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageSpiderMonkey[Package]}esr.source"	"${PackageSpiderMonkey[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildSpiderMonkey()
{
	if ! cd "${SHMAN_PDIR}${PackageSpiderMonkey[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageSpiderMonkey[Package]}";
		return 1;
	fi

	# if ICU 76.1+
	sed -i 's/icu-i18n/icu-uc &/' js/moz.configure

	# If chroot
	# mountpoint -q /dev/shm || mount -t tmpfs devshm /dev/shm

	mkdir -p obj 	&& cd ${SHMAN_PDIR}${PackageSpiderMonkey[Package]}/obj \
					|| { EchoError "${PackageSpiderMonkey[Name]}> Failed to enter ${SHMAN_PDIR}${PackageSpiderMonkey[Package]}/build"; return 1; }

	EchoInfo	"${PackageSpiderMonkey[Name]}> Configure"
	../js/src/configure --prefix=/usr \
						--disable-debug-symbols \
						--disable-jemalloc \
						--enable-readline \
						--enable-rust-simd \
						--with-intl-api \
						--with-system-icu \
						--with-system-zlib \
						1> /dev/null || { EchoTest KO ${PackageSpiderMonkey[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSpiderMonkey[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageSpiderMonkey[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSpiderMonkey[Name]}> make check"
	sed 's/pipes/shlex/' -i ../js/src/tests/lib/results.py
	make -C js/src check-jstests JSTESTS_EXTRA_ARGS="--timeout 300 --wpt=disabled" | tee jstest.log || 
	if [ $(grep -c 'UNEXPECTED-FAIL' jstest.log) -gt 0 ]; then
		EchoTest KO ${PackageSpiderMonkey[Name]};
		PressAnyKeyToContinue; 
		return 1;
	fi

	EchoInfo	"${PackageSpiderMonkey[Name]}> make install"
	rm -fv /usr/lib/libmozjs-128.so
	make install 1> /dev/null || { EchoTest KO ${PackageSpiderMonkey[Name]} && PressAnyKeyToContinue; return 1; };
	rm -v /usr/lib/libjs_static.ajs &&
	sed -i '/@NSPR_CFLAGS@/d' /usr/bin/js128-config
}
