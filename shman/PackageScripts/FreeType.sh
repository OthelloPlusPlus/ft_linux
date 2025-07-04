#!/bin/bash

if [ ! -z "${PackageFreeType[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									FreeType								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageFreeType;
PackageFreeType[Source]="https://downloads.sourceforge.net/freetype/freetype-2.13.3.tar.xz";
PackageFreeType[MD5]="f3b4432c4212064c00500e1ad63fbc64";
PackageFreeType[Name]="freetype";
PackageFreeType[Version]="2.13.3";
PackageFreeType[Package]="${PackageFreeType[Name]}-${PackageFreeType[Version]}";
PackageFreeType[Extension]=".tar.xz";

PackageFreeType[Programs]="freetype-config";
PackageFreeType[Libraries]="libfreetype.so";
PackageFreeType[Python]="";

InstallFreeType()
{
	# Check Installation
	CheckFreeType && return $?;

	EchoInfo	"${PackageFreeType[Name]}> Checking dependencies..."

	# Check Dependencies
	Required=(LibPng Which)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Brotli LibRsvg)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageFreeType[Name]}> Building package..."
	_ExtractPackageFreeType || return $?;
	_BuildFreeTypeBasic || return $?;
	source "${SHMAN_SDIR}/HarfBuzz.sh" && InstallHarfBuzz;
	EchoInfo	"${PackageFreeType[Name]}> Building package again..."
	_BuildFreeTypeFull;
	return $?
}

CheckFreeType()
{
	CheckInstallation 	"${PackageFreeType[Programs]}"\
						"${PackageFreeType[Libraries]}"\
						"${PackageFreeType[Python]}" 1> /dev/null;
	source "${SHMAN_SDIR}/HarfBuzz.sh" && CheckHarfBuzz || return $?;
	return $?;
}

CheckFreeTypeVerbose()
{
	CheckInstallationVerbose	"${PackageFreeType[Programs]}"\
								"${PackageFreeType[Libraries]}"\
								"${PackageFreeType[Python]}";
	source "${SHMAN_SDIR}/HarfBuzz.sh" && CheckHarfBuzz || { echo -en "${C_RED}HarfBuzz${C_RESET}" && return $?; };
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageFreeType()
{
	DownloadPackage	"${PackageFreeType[Source]}"	"${SHMAN_PDIR}"	"${PackageFreeType[Package]}${PackageFreeType[Extension]}"	"${PackageFreeType[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageFreeType[Package]}"	"${PackageFreeType[Extension]}" || return $?;
	wget -P "${SHMAN_PDIR}" "https://downloads.sourceforge.net/freetype/freetype-doc-2.13.3.tar.xz";

	return $?;
}

_BuildFreeTypeBasic()
{
	if ! cd "${SHMAN_PDIR}${PackageFreeType[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageFreeType[Package]}";
		return 1;
	fi

	sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg

	sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" \
		-i include/freetype/config/ftoption.h

	EchoInfo	"${PackageFreeType[Name]}> Configure"
	./configure --prefix=/usr \
				--enable-freetype-config \
				--disable-static \
				--without-harfbuzz \
				1> /dev/null || { EchoTest KO ${PackageFreeType[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFreeType[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageFreeType[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFreeType[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageFreeType[Name]} && PressAnyKeyToContinue; return 1; };
}

_BuildFreeTypeFull()
{
	if ! cd "${SHMAN_PDIR}${PackageFreeType[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageFreeType[Package]}";
		return 1;
	fi

	make distclean || PressAnyKeyToContinue;

	tar -xf ../freetype-doc-2.13.3.tar.xz --strip-components=2 -C docs

	EchoInfo	"${PackageFreeType[Name]}> Configure"
	./configure --prefix=/usr \
				--enable-freetype-config \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageFreeType[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFreeType[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageFreeType[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFreeType[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageFreeType[Name]} && PressAnyKeyToContinue; return 1; };

	cp -v -R docs -T /usr/share/doc/freetype-2.13.3
	rm -v /usr/share/doc/freetype-2.13.3/freetype-config.1
}
