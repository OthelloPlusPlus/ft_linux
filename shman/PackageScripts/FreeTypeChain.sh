#!/bin/bash

if [ ! -z "${PackageFreeTypeChain[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									FreeTypeChain							   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageFreeTypeChain;
PackageFreeTypeChain[Source]="Tears";
PackageFreeTypeChain[Name]="FreeType Chain";

InstallFreeTypeChain()
{
	# Check Installation
	CheckFreeTypeChain && return $?;

	# Check Dependencies
	EchoInfo	"${PackageFreeTypeChain[Name]}> Checking dependencies..."
	Required=(LibPng Pixman)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Which GLib Graphite2 ICU XorgLibraries)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Brotli LibRsvg Git GTKDoc Ghostscript LibDrm LibXml2 LZO Poppler Valgrind)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Packages
	EchoInfo	"${PackageFreeTypeChain[Name]}> Building package chain"
	# FreeType
	_ExtractPackageFreeType && \
	_BuildFreeTypeBasic && \
	# HarfBuzz
	_ExtractPackageHarfBuzz && \
	_BuildHarfBuzz && \
	# Cairo
	_ExtractPackageCairo && \
	_BuildCairo && \
	# HarfBuzz
	rm -rf "${SHMAN_PDIR}${PackageHarfBuzz[Package]}" && \
	_ExtractPackageHarfBuzz && \
	_BuildHarfBuzz && \
	# FreeType
	_BuildFreeTypeFull
	# cry
	return $?
}

CheckFreeTypeChain()
{
	CheckInstallation 	"${PackageFreeType[Programs]} ${PackageHarfBuzz[Programs]} ${PackageCairo[Programs]}"\
						"${PackageFreeType[Libraries]} ${PackageHarfBuzz[Libraries]} ${PackageCairo[Libraries]}"\
						"${PackageFreeType[Python]} ${PackageHarfBuzz[Python]} ${PackageCairo[Python]}" 1> /dev/null;
	return $?;
}

CheckFreeTypeChainVerbose()
{
	CheckInstallationVerbose	"${PackageFreeType[Programs]} ${PackageHarfBuzz[Programs]} ${PackageCairo[Programs]}"\
								"${PackageFreeType[Libraries]} ${PackageHarfBuzz[Libraries]} ${PackageCairo[Libraries]}"\
								"${PackageFreeType[Python]} ${PackageHarfBuzz[Python]} ${PackageCairo[Python]}";
	return $?;
}

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

# =====================================||===================================== #
#									HarfBuzz								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageHarfBuzz;
PackageHarfBuzz[Source]="https://github.com/harfbuzz/harfbuzz/releases/download/10.4.0/harfbuzz-10.4.0.tar.xz";
PackageHarfBuzz[MD5]="9ff3796c1b8ae03540e466168c6a5bd1";
PackageHarfBuzz[Name]="harfbuzz";
PackageHarfBuzz[Version]="10.4.0";
PackageHarfBuzz[Package]="${PackageHarfBuzz[Name]}-${PackageHarfBuzz[Version]}";
PackageHarfBuzz[Extension]=".tar.xz";

PackageHarfBuzz[Programs]="hb-info hb-ot-shape-closure hb-shape hb-subset";
PackageHarfBuzz[Libraries]="libharfbuzz.so libharfbuzz-gobject.so libharfbuzz-icu.so libharfbuzz-subset.so";
PackageHarfBuzz[Python]="";

_ExtractPackageHarfBuzz()
{
	DownloadPackage	"${PackageHarfBuzz[Source]}"	"${SHMAN_PDIR}"	"${PackageHarfBuzz[Package]}${PackageHarfBuzz[Extension]}"	"${PackageHarfBuzz[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageHarfBuzz[Package]}"	"${PackageHarfBuzz[Extension]}" || return $?;

	return $?;
}

_BuildHarfBuzz()
{
	if ! cd "${SHMAN_PDIR}${PackageHarfBuzz[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageHarfBuzz[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageHarfBuzz[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageHarfBuzz[Package]}/build";

	EchoInfo	"${PackageHarfBuzz[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				1> /dev/null || { EchoTest KO ${PackageHarfBuzz[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageHarfBuzz[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageHarfBuzz[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageHarfBuzz[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageHarfBuzz[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageHarfBuzz[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageHarfBuzz[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									 Cairo									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageCairo;
PackageCairo[Source]="https://www.cairographics.org/releases/cairo-1.18.2.tar.xz";
PackageCairo[MD5]="5ad67c707edd0003f1b91c8bbc0005c1";
PackageCairo[Name]="cairo";
PackageCairo[Version]="1.18.2";
PackageCairo[Package]="${PackageCairo[Name]}-${PackageCairo[Version]}";
PackageCairo[Extension]=".tar.xz";

PackageCairo[Programs]="cairo-trace";
PackageCairo[Libraries]="libcairo.so libcairo-gobject.so libcairo-script-interpreter.so";
PackageCairo[Python]="";

_ExtractPackageCairo()
{
	DownloadPackage	"${PackageCairo[Source]}"	"${SHMAN_PDIR}"	"${PackageCairo[Package]}${PackageCairo[Extension]}"	"${PackageCairo[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageCairo[Package]}"	"${PackageCairo[Extension]}" || return $?;
	wget -P "${SHMAN_PDIR}" "https://www.linuxfromscratch.org/patches/blfs/12.3/cairo-1.18.2-upstream_fixes-1.patch";

	return $?;
}

_BuildCairo()
{
	if ! cd "${SHMAN_PDIR}${PackageCairo[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageCairo[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageCairo[Name]}> Patching"
	patch -Np1 -i ../cairo-1.18.2-upstream_fixes-1.patch || return $?;

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageCairo[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageCairo[Package]}/build";

	EchoInfo	"${PackageCairo[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageCairo[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCairo[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageCairo[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCairo[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageCairo[Name]} && PressAnyKeyToContinue; return 1; };
}
