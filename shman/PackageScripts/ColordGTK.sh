#!/bin/bash

if [ ! -z "${PackageColordGTK[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									ColordGTK								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageColordGTK;
# Manual
PackageColordGTK[Source]="https://www.freedesktop.org/software/colord/releases/colord-gtk-0.3.1.tar.xz";
PackageColordGTK[MD5]="d436740c06e42af421384f16b2a9a0a7";
# Automated unless edgecase
PackageColordGTK[Name]="";
PackageColordGTK[Version]="";
PackageColordGTK[Extension]="";
if [[ -n "${PackageColordGTK[Source]}" ]]; then
	filename="${PackageColordGTK[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageColordGTK[Name]}" ]] && PackageColordGTK[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageColordGTK[Version]}" ]] && PackageColordGTK[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageColordGTK[Extension]}" ]] && PackageColordGTK[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageColordGTK[Package]="${PackageColordGTK[Name]}-${PackageColordGTK[Version]}";

PackageColordGTK[Programs]="cd-convert";
PackageColordGTK[Libraries]="libcolord-gtk.so libcolord-gtk4.so";
PackageColordGTK[Python]="";

InstallColordGTK()
{
	# Check Installation
	CheckColordGTK && return $?;

	# Check Dependencies
	EchoInfo	"${PackageColordGTK[Name]}> Checking dependencies..."
	Required=(Colord GTK3)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageColordGTK[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(GLib GTK4 Vala)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageColordGTK[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(DocbookXml DocbookXslNs LibXslt GTKDoc)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageColordGTK[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageColordGTK[Name]}> Building package..."
	_ExtractPackageColordGTK || return $?;
	_BuildColordGTK || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageColordGTK[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckColordGTK()
{
	CheckInstallation 	"${PackageColordGTK[Programs]}"\
						"${PackageColordGTK[Libraries]}"\
						"${PackageColordGTK[Python]}" 1> /dev/null;
	return $?;
}

CheckColordGTKVerbose()
{
	CheckInstallationVerbose	"${PackageColordGTK[Programs]}"\
								"${PackageColordGTK[Libraries]}"\
								"${PackageColordGTK[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageColordGTK()
{
	DownloadPackage	"${PackageColordGTK[Source]}"	"${SHMAN_PDIR}"	"${PackageColordGTK[Package]}${PackageColordGTK[Extension]}"	"${PackageColordGTK[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageColordGTK[Package]}"	"${PackageColordGTK[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildColordGTK()
{
	if ! cd "${SHMAN_PDIR}${PackageColordGTK[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageColordGTK[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageColordGTK[Package]}/build \
					|| { EchoError "${PackageColordGTK[Name]}> Failed to enter ${SHMAN_PDIR}${PackageColordGTK[Package]}/build"; return 1; }

	EchoInfo	"${PackageColordGTK[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D gtk4=true \
				-D vapi=true \
				-D docs=false \
				-D man=false \
				.. 1> /dev/null || { EchoTest KO ${PackageColordGTK[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageColordGTK[Name]}> ninja"
	ninja -j1 1> /dev/null || { EchoTest KO ${PackageColordGTK[Name]} && PressAnyKeyToContinue; return 1; };

	# sed '/class="manual"/i \
	# 	<refmiscinfo class="source">colord-gtk</refmiscinfo>' \
	# 	-i ../man/*.xml &&
	# meson configure -D man=true &&
	# ninja

	if [ -z "$DISPLAY" ]; then
		EchoWarning "No X graphical environment detected. Tests requiring X will fail."
		ninja test || { EchoWarning "${PackageColordGTK[Name]}> Failures expected due to no X graphical environment." && PressAnyKeyToContinue; };
	else
		ninja test 1> /dev/null || { EchoTest KO ${PackageColordGTK[Name]} && PressAnyKeyToContinue; return 1; };
	fi

	EchoInfo	"${PackageColordGTK[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageColordGTK[Name]} && PressAnyKeyToContinue; return 1; };
}
