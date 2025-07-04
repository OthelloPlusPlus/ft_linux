#!/bin/bash

if [ ! -z "${PackagePolkit[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Polkit								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePolkit;
# Manual
PackagePolkit[Source]="https://github.com/polkit-org/polkit/archive/126/polkit-126.tar.gz";
PackagePolkit[MD5]="db4ce0a42d5bf8002061f8e34ee9bdd0";
# Automated unless edgecase
PackagePolkit[Name]="";
PackagePolkit[Version]="";
PackagePolkit[Extension]="";
if [[ -n "${PackagePolkit[Source]}" ]]; then
	filename="${PackagePolkit[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackagePolkit[Name]}" ]] && PackagePolkit[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackagePolkit[Version]}" ]] && PackagePolkit[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackagePolkit[Extension]}" ]] && PackagePolkit[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackagePolkit[Package]="${PackagePolkit[Name]}-${PackagePolkit[Version]}";

PackagePolkit[Programs]="pkaction pkcheck pkexec pkttyagent polkitd";
PackagePolkit[Libraries]="libpolkit-agent-1.so libpolkit-gobject-1.so";
PackagePolkit[Python]="";

InstallPolkit()
{
	# Check Installation
	CheckPolkit && return $?;

	# Check Dependencies
	EchoInfo	"${PackagePolkit[Name]}> Checking dependencies..."
	Required=(Duktape GLib)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(LibXslt LinuxPAM Elogind)
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
	EchoInfo	"${PackagePolkit[Name]}> Building package..."
	_ExtractPackagePolkit || return $?;
	_BuildPolkit;
	return $?
}

CheckPolkit()
{
	CheckInstallation 	"${PackagePolkit[Programs]}"\
						"${PackagePolkit[Libraries]}"\
						"${PackagePolkit[Python]}" 1> /dev/null;
	return $?;
}

CheckPolkitVerbose()
{
	CheckInstallationVerbose	"${PackagePolkit[Programs]}"\
								"${PackagePolkit[Libraries]}"\
								"${PackagePolkit[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackagePolkit()
{
	DownloadPackage	"${PackagePolkit[Source]}"	"${SHMAN_PDIR}"	"${PackagePolkit[Package]}${PackagePolkit[Extension]}"	"${PackagePolkit[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackagePolkit[Package]}"	"${PackagePolkit[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildPolkit()
{
	if ! cd "${SHMAN_PDIR}${PackagePolkit[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackagePolkit[Package]}";
		return 1;
	fi

	EchoInfo	"${PackagePolkit[Name]}> create dedicated group for polkit daemon"
	groupadd -fg 27 polkitd
	useradd -c "PolicyKit Daemon Owner" -d /etc/polkit-1 -u 27 \
			-g polkitd -s /bin/false polkitd

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackagePolkit[Package]}/build \
					|| { EchoError "${PackagePolkit[Name]}> Failed to enter ${SHMAN_PDIR}${PackagePolkit[Package]}/build"; return 1; }

	EchoInfo	"${PackagePolkit[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D man=true \
				-D session_tracking=elogind \
				-D systemdsystemunitdir=/tmp \
				-D tests=true \
				-D authfw=shadow \
				1> /dev/null || { EchoTest KO ${PackagePolkit[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePolkit[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackagePolkit[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePolkit[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackagePolkit[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePolkit[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackagePolkit[Name]} && PressAnyKeyToContinue; return 1; };
	rm -v /tmp/*.service
	rm -rf /usr/lib/{sysusers,tmpfiles}.d 
}
