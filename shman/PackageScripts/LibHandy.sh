#!/bin/bash

if [ ! -z "${PackageLibHandy[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibHandy								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibHandy;
PackageLibHandy[Source]="https://download.gnome.org/sources/libhandy/1.8/libhandy-1.8.3.tar.xz";
PackageLibHandy[MD5]="af586a91ff6d4093a6e7e283dfab5f7f";
PackageLibHandy[Name]="libhandy";
PackageLibHandy[Version]="1.8.3";
PackageLibHandy[Package]="${PackageLibHandy[Name]}-${PackageLibHandy[Version]}";
PackageLibHandy[Extension]=".tar.xz";

PackageLibHandy[Programs]="handy-1-demo";
PackageLibHandy[Libraries]="libhandy-1.so";
PackageLibHandy[Python]="";

InstallLibHandy()
{
	# Check Installation
	CheckLibHandy && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibHandy[Name]}> Checking dependencies..."
	Required=(GTK3)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Vala)
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(GTKDoc)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageLibHandy[Name]}> Building package..."
	_ExtractPackageLibHandy || return $?;
	_BuildLibHandy;
	return $?
}

CheckLibHandy()
{
	CheckInstallation 	"${PackageLibHandy[Programs]}"\
						"${PackageLibHandy[Libraries]}"\
						"${PackageLibHandy[Python]}" 1> /dev/null;
	return $?;
}

CheckLibHandyVerbose()
{
	CheckInstallationVerbose	"${PackageLibHandy[Programs]}"\
								"${PackageLibHandy[Libraries]}"\
								"${PackageLibHandy[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibHandy()
{
	DownloadPackage	"${PackageLibHandy[Source]}"	"${SHMAN_PDIR}"	"${PackageLibHandy[Package]}${PackageLibHandy[Extension]}"	"${PackageLibHandy[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibHandy[Package]}"	"${PackageLibHandy[Extension]}" || return $?;

	for URL in \
	# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibHandy()
{
	if ! cd "${SHMAN_PDIR}${PackageLibHandy[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibHandy[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibHandy[Package]}/build \
					|| { EchoError "${PackageLibHandy[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibHandy[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibHandy[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageLibHandy[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibHandy[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLibHandy[Name]} && PressAnyKeyToContinue; return 1; };



	if [[ -n "$DISPLAY" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
		EchoInfo	"${PackageLibHandy[Name]}> ninja test (graphical)"
		ninja test 1> /dev/null || { EchoTest KO ${PackageLibHandy[Name]} && PressAnyKeyToContinue; return 1; };
	else
		EchoInfo	"${PackageLibHandy[Name]}> ninja test (non-graphical)"
		ninja test || { EchoTest KO "${PackageLibHandy[Name]}> Errors could be due to non-graphical testing" && PressAnyKeyToContinue; };
	fi

	EchoInfo	"${PackageLibHandy[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLibHandy[Name]} && PressAnyKeyToContinue; return 1; };
}
