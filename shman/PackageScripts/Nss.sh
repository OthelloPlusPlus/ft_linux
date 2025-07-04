#!/bin/bash

if [ ! -z "${PackageNss[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									  Nss									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageNss;
PackageNss[Source]="https://archive.mozilla.org/pub/security/nss/releases/NSS_3_108_RTM/src/nss-3.108.tar.gz";
PackageNss[MD5]="9208c05e756a06be19ce0e683777466e";
PackageNss[Name]="nss";
PackageNss[Version]="3.108";
PackageNss[Package]="${PackageNss[Name]}-${PackageNss[Version]}";
PackageNss[Extension]=".tar.gz";

PackageNss[Programs]="certutil nss-config pk12util";
# removed libcrmf.a because tester doesnt work with it
PackageNss[Libraries]="libfreebl3.so libfreeblpriv3.so libnss3.so libnssckbi.so libnssckbi-testlib.so libnssdbm3.so libnsssysinit.so libnssutil3.so libpkcs11testmodule.so libsmime3.so libsoftokn3.so libssl3.so";
PackageNss[Python]="";

InstallNss()
{
	# Check Installation
	CheckNss && return $?;

	# Check Dependencies
	Required=(NSPR)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(SQLite P11Kit)
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
	EchoInfo	"Package ${PackageNss[Name]}"
	_ExtractPackageNss || return $?;
	_BuildNss;
	return $?
}

CheckNss()
{
	CheckInstallation 	"${PackageNss[Programs]}"\
						"${PackageNss[Libraries]}"\
						"${PackageNss[Python]}" 1> /dev/null;
	return $?;
}

CheckNssVerbose()
{
	CheckInstallationVerbose	"${PackageNss[Programs]}"\
								"${PackageNss[Libraries]}"\
								"${PackageNss[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageNss()
{
	DownloadPackage	"${PackageNss[Source]}"	"${SHMAN_PDIR}"	"${PackageNss[Package]}${PackageNss[Extension]}"	"${PackageNss[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageNss[Package]}"	"${PackageNss[Extension]}" || return $?;
	wget -P "${SHMAN_PDIR}" "https://www.linuxfromscratch.org/patches/blfs/12.3/nss-standalone-1.patch";

	return $?;
}

_BuildNss()
{
	if ! cd "${SHMAN_PDIR}${PackageNss[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageNss[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageNss[Name]}> Patching"
	patch -Np1 -i ../nss-standalone-1.patch

	EchoInfo	"${PackageNss[Name]}> make"
	cd "${SHMAN_PDIR}${PackageNss[Package]}/nss" || return $?;
	make BUILD_OPT=1 \
		NSPR_INCLUDE_DIR=/usr/include/nspr \
		USE_SYSTEM_ZLIB=1 \
		ZLIB_LIBS=-lz \
		NSS_ENABLE_WERROR=0 \
		$([ $(uname -m) = x86_64 ] && echo USE_64=1) \
		$([ -f /usr/include/sqlite3.h ] && echo NSS_USE_SYSTEM_SQLITE=1) \
		1> /dev/null || { EchoTest KO ${PackageNss[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNss[Name]}> nss/tests/all.sh"
	echo "This can take a long ass time..."
	cd "${SHMAN_PDIR}${PackageNss[Package]}/nss/tests" || return $?;
	HOST=localhost DOMSUF=localdomain ./all.sh 1> /dev/null || { EchoTest KO ${PackageNss[Name]} && PressAnyKeyToContinue; };
	
	EchoInfo	"${PackageNss[Name]}> Installation"
	cd "${SHMAN_PDIR}${PackageNss[Package]}/dist" || return $?;
	install -v -m755 Linux*/lib/*.so 							/usr/lib && \
	install -v -m644 Linux*/lib/{*.chk,libcrmf.a} 				/usr/lib && \
	install -v -m755 -d 										/usr/include/nss && \
		cp -v -RL {public,private}/nss/* 						/usr/include/nss && \
	install -v -m755 Linux*/bin/{certutil,nss-config,pk12util} 	/usr/bin &&
	install -v -m644 Linux*/lib/pkgconfig/nss.pc 				/usr/lib/pkgconfig || \
	{ EchoTest KO ${PackageNss[Name]} && PressAnyKeyToContinue; return 1; };
}
