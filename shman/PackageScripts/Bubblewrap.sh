#!/bin/bash

if [ ! -z "${PackageBubblewrap[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#								   Bubblewrap								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageBubblewrap;
PackageBubblewrap[Source]="https://github.com/containers/bubblewrap/releases/download/v0.11.0/bubblewrap-0.11.0.tar.xz";
PackageBubblewrap[MD5]="630eec714ea04729efd116ea85a715a3";
PackageBubblewrap[Name]="bubblewrap";
PackageBubblewrap[Version]="0.11.0";
PackageBubblewrap[Package]="${PackageBubblewrap[Name]}-${PackageBubblewrap[Version]}";
PackageBubblewrap[Extension]=".tar.xz";

PackageBubblewrap[Programs]="bwrap";
PackageBubblewrap[Libraries]="";
PackageBubblewrap[Python]="";

InstallBubblewrap()
{
	# Check Installation
	CheckBubblewrap && return $?;

	# Check Dependencies
	EchoInfo	"${PackageBubblewrap[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(Libxslt LibSeccomp)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageBubblewrap[Name]}> Building package..."
	_ExtractPackageBubblewrap || return $?;
	_BuildBubblewrap;
	return $?
}

CheckBubblewrap()
{
	CheckInstallation 	"${PackageBubblewrap[Programs]}"\
						"${PackageBubblewrap[Libraries]}"\
						"${PackageBubblewrap[Python]}" 1> /dev/null;
	return $?;
}

CheckBubblewrapVerbose()
{
	CheckInstallationVerbose	"${PackageBubblewrap[Programs]}"\
								"${PackageBubblewrap[Libraries]}"\
								"${PackageBubblewrap[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageBubblewrap()
{
	DownloadPackage	"${PackageBubblewrap[Source]}"	"${SHMAN_PDIR}"	"${PackageBubblewrap[Package]}${PackageBubblewrap[Extension]}"	"${PackageBubblewrap[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageBubblewrap[Package]}"	"${PackageBubblewrap[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildBubblewrap()
{
	if ! cd "${SHMAN_PDIR}${PackageBubblewrap[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageBubblewrap[Package]}";
		return 1;
	fi

	# error potential:
	EchoInfo	"${PackageBubblewrap[Name]}> Might require NAMESPACES & USER_NS"

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageBubblewrap[Package]}/build \
					|| { EchoError "${PackageBubblewrap[Name]}> Failed to enter ${SHMAN_PDIR}${PackageBubblewrap[Package]}/build"; return 1; }

	EchoInfo	"${PackageBubblewrap[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				.. \
				1> /dev/null || { EchoTest KO ${PackageBubblewrap[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBubblewrap[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageBubblewrap[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageBubblewrap[Name]}> ninja test (as non root...)"
	# sed 's@symlink usr/lib64@ro-bind-try /lib64@' -i ../tests/libtest.sh
	# ninja test 1> /dev/null || { EchoTest KO ${PackageBubblewrap[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBubblewrap[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageBubblewrap[Name]} && PressAnyKeyToContinue; return 1; };
}
