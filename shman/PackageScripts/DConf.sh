#!/bin/bash

if [ ! -z "${PackageDConf[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									 DConf									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageDConf;
PackageDConf[Source]="https://download.gnome.org/sources/dconf/0.40/dconf-0.40.0.tar.xz";
PackageDConf[MD5]="ac8db20b0d6b996d4bbbeb96463d01f0";
PackageDConf[Name]="dconf";
PackageDConf[Version]="0.40.0";
PackageDConf[Package]="${PackageDConf[Name]}-${PackageDConf[Version]}";
PackageDConf[Extension]=".tar.xz";

PackageDConf[Programs]="dconf";
PackageDConf[Libraries]="libdconf.so";
PackageDConf[Python]="";

InstallDConf()
{
	# Check Installation
	CheckDConf && return $?;

	# Check Dependencies
	EchoInfo	"${PackageDConf[Name]}> Checking dependencies..."
	Required=(Dbus GLib)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(LibXslt DocbookXml Vala)
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
	EchoInfo	"${PackageDConf[Name]}> Building package..."
	_ExtractPackageDConf || return $?;
	_BuildDConf || return $?;
	source "${SHMAN_SDIR}/DConfEditor.sh" && InstallDConfEditor;
	return $?
}

CheckDConf()
{
	CheckInstallation 	"${PackageDConf[Programs]}"\
						"${PackageDConf[Libraries]}"\
						"${PackageDConf[Python]}" 1> /dev/null;
	return $?;
}

CheckDConfVerbose()
{
	CheckInstallationVerbose	"${PackageDConf[Programs]}"\
								"${PackageDConf[Libraries]}"\
								"${PackageDConf[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageDConf()
{
	DownloadPackage	"${PackageDConf[Source]}"	"${SHMAN_PDIR}"	"${PackageDConf[Package]}${PackageDConf[Extension]}"	"${PackageDConf[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageDConf[Package]}"	"${PackageDConf[Extension]}" || return $?;

	for URL in \
	# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildDConf()
{
	if ! cd "${SHMAN_PDIR}${PackageDConf[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageDConf[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageDConf[Name]}> Prevent unnecessary system units"
	sed -i 's/install_dir: systemd_userunitdir,//' service/meson.build

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageDConf[Package]}/build \
					|| { EchoError "${PackageDConf[Name]}> Failed to enter ${SHMAN_PDIR}${PackageDConf[Package]}/build"; return 1; }

	EchoInfo	"${PackageDConf[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D bash_completion=false \
				.. \
				1> /dev/null || { EchoTest KO ${PackageDConf[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDConf[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageDConf[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDConf[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageDConf[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageDConf[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageDConf[Name]} && PressAnyKeyToContinue; return 1; };
}
