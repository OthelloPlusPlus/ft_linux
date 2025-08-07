#!/bin/bash

if [ ! -z "${PackageCairo[Source]}" ] && declare -F InstallCairo > /dev/null; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									 Cairo								   #
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

InstallCairo()
{
	# Check Installation
	CheckCairo && return $?;

	# Check Dependencies
	EchoInfo	"${PackageCairo[Name]}> Checking dependencies..."
	Required=(LibPng Pixman)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageCairo[Name]}> Checking ${Dependency}..."
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	# removed Fontconfig and XorgLibraries because circular dependencies
	Recommended=(GLib FreeTypeChain)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageCairo[Name]}> Checking ${Dependency}..."
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

 	# removed LibRsvg because circular
	Optional=(Ghostscript GTKDoc LibDrm LibXml2 LZO Popplet Valgrind GTK+ LibSpectre)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageCairo[Name]}> Checking ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"Package ${PackageCairo[Name]}"
	_ExtractPackageCairo || return $?;
	_BuildCairo;
	return $?
}

CheckCairo()
{
	CheckInstallation 	"${PackageCairo[Programs]}"\
						"${PackageCairo[Libraries]}"\
						"${PackageCairo[Python]}" 1> /dev/null;
	return $?;
}

CheckCairoVerbose()
{
	CheckInstallationVerbose	"${PackageCairo[Programs]}"\
								"${PackageCairo[Libraries]}"\
								"${PackageCairo[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

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
