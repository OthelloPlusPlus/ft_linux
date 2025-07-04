#!/bin/bash

if [ ! -z "${PackageCMake[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									CMake								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageCMake;
PackageCMake[Source]="https://cmake.org/files/v3.31/cmake-3.31.5.tar.gz";
PackageCMake[MD5]="ea5e8d7208616b1609018db290a67419";
PackageCMake[Name]="cmake";
PackageCMake[Version]="3.31.5";
PackageCMake[Package]="${PackageCMake[Name]}-${PackageCMake[Version]}";
PackageCMake[Extension]=".tar.gz";

PackageCMake[Programs]="cmake cmake cpack ctest";
PackageCMake[Libraries]="";
PackageCMake[Python]="";

InstallCMake()
{
	# Check Installation
	CheckCMake && return $?;

	# Check Dependencies
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=(cURL LibArchive LibUv Nghttp2)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	Optional=(Git Mercurial OpenJDK Qt Sphinx Subversion)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh"
		fi
	done
	
	# Install Package
	EchoInfo	"Package ${PackageCMake[Name]}"
	_ExtractPackageCMake || return $?;
	_BuildCMake;
	return $?
}

CheckCMake()
{
	CheckInstallation 	"${PackageCMake[Programs]}"\
						"${PackageCMake[Libraries]}"\
						"${PackageCMake[Python]}" 1> /dev/null;
	return $?;
}

CheckCMakeVerbose()
{
	CheckInstallationVerbose	"${PackageCMake[Programs]}"\
								"${PackageCMake[Libraries]}"\
								"${PackageCMake[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageCMake()
{
	DownloadPackage	"${PackageCMake[Source]}"	"${SHMAN_PDIR}"	"${PackageCMake[Package]}${PackageCMake[Extension]}"	"${PackageCMake[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageCMake[Package]}"	"${PackageCMake[Extension]}" || return $?;

	return $?;
}

_BuildCMake()
{
	if ! cd "${SHMAN_PDIR}${PackageCMake[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageCMake[Package]}";
		return 1;
	fi

	sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake

	EchoInfo	"${PackageCMake[Name]}> Configure"
	local BootStrapFlags="--prefix=/usr \
		--system-libs \
		--mandir=/share/man \
		--no-system-jsoncpp \
		--no-system-cppdap \
		--no-system-librhash \
		--docdir=/share/doc/cmake-3.31.5";
	source ${SHMAN_SDIR}/cURL.sh 		&& CheckcURL 		|| BootStrapFlags="$BootStrapFlags --no-system-curl"
	source ${SHMAN_SDIR}/LibArchive.sh 	&& CheckLibArchive 	|| BootStrapFlags="$BootStrapFlags --no-system-libarchive"
	source ${SHMAN_SDIR}/LibUv.sh 		&& CheckLibUv 		|| BootStrapFlags="$BootStrapFlags --no-system-libuv"
	source ${SHMAN_SDIR}/Nghttp2.sh 	&& CheckNghttp2 	|| BootStrapFlags="$BootStrapFlags --no-system-nghttp2"
	./bootstrap $BootStrapFlags 1> /dev/null || { EchoTest KO ${PackageCMake[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCMake[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageCMake[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCMake[Name]}> bin/ctest -j$(nproc)"
	bin/ctest 	-j$(nproc) \
				-E ParseImplicitLinkInfo \
				--output-on-failure \
				1> /dev/null || { EchoTest KO ${PackageCMake[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageCMake[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageCMake[Name]} && PressAnyKeyToContinue; return 1; };
}
