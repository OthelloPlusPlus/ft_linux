#!/bin/bash

if [ ! -z "${PackageColord[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Colord								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageColord;
# Manual
PackageColord[Source]="https://www.freedesktop.org/software/colord/releases/colord-1.4.7.tar.xz";
PackageColord[MD5]="94bd795efa1931a34990345e4ac439a8";
# Automated unless edgecase
PackageColord[Name]="";
PackageColord[Version]="";
PackageColord[Extension]="";
if [[ -n "${PackageColord[Source]}" ]]; then
	filename="${PackageColord[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageColord[Name]}" ]] && PackageColord[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageColord[Version]}" ]] && PackageColord[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageColord[Extension]}" ]] && PackageColord[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageColord[Package]="${PackageColord[Name]}-${PackageColord[Version]}";

PackageColord[Programs]="cd-create-profile cd-fix-profile cd-iccdump cd-it8 colormgr";
PackageColord[Libraries]="libcolord.so libcolordcompat.so libcolordprivate.so libcolorhug.so";
PackageColord[Python]="";

InstallColord()
{
	# Check Installation
	CheckColord && return $?;

	# Check Dependencies
	EchoInfo	"${PackageColord[Name]}> Checking dependencies..."
	Required=(Dbus GLib LittleCMS2 LibGudev LibGusb Polkit SQLite)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageColord[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Elogind Vala)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageColord[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(GnomeDesktop ColordGtk DocbookXml DocbookXslNs LibXslt GTKDoc SANE)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageColord[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageColord[Name]}> Building package..."
	_ExtractPackageColord || return $?;
	_BuildColord;
	return $?
}

CheckColord()
{
	CheckInstallation 	"${PackageColord[Programs]}"\
						"${PackageColord[Libraries]}"\
						"${PackageColord[Python]}" 1> /dev/null;
	return $?;
}

CheckColordVerbose()
{
	CheckInstallationVerbose	"${PackageColord[Programs]}"\
								"${PackageColord[Libraries]}"\
								"${PackageColord[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageColord()
{
	DownloadPackage	"${PackageColord[Source]}"	"${SHMAN_PDIR}"	"${PackageColord[Package]}${PackageColord[Extension]}"	"${PackageColord[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageColord[Package]}"	"${PackageColord[Extension]}" || return $?;

	for URL in \
		"https://www.linuxfromscratch.org/patches/blfs/12.3/colord-1.4.7-upstream_fixes-1.patch"
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildColord()
{
	if ! cd "${SHMAN_PDIR}${PackageColord[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageColord[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageColord[Name]}> Patching"
	patch -Np1 -i ../colord-1.4.7-upstream_fixes-1.patch

	EchoInfo	"${PackageColord[Name]}> Add user"
	groupadd -g 71 colord
	useradd -c "Color Daemon Owner" \
			-d /var/lib/colord \
			-u 71 \
			-g colord \
			-s /bin/false colord

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageColord[Package]}/build \
					|| { EchoError "${PackageColord[Name]}> Failed to enter ${SHMAN_PDIR}${PackageColord[Package]}/build"; return 1; }

	EchoInfo	"${PackageColord[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D daemon_user=colord \
				-D vapi=true \
				-D systemd=false \
				-D libcolordcompat=true \
				-D argyllcms_sensor=false \
				-D bash_completion=false \
				-D docs=false \
				-D man=false \
				1> /dev/null || { EchoTest KO ${PackageColord[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageColord[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageColord[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageColord[Name]}> ninja check"
	# ninja check 1> /dev/null || { EchoTest KO ${PackageColord[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageColord[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageColord[Name]} && PressAnyKeyToContinue; return 1; };
}
