#!/bin/bash

if [ ! -z "${PackageP11Kit[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									 P11Kit									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageP11Kit;
PackageP11Kit[Source]="https://github.com/p11-glue/p11-kit/releases/download/0.25.5/p11-kit-0.25.5.tar.xz";
PackageP11Kit[MD5]="e9c5675508fcd8be54aa4c8cb8e794fc";
PackageP11Kit[Name]="p11-kit";
PackageP11Kit[Version]="0.25.5";
PackageP11Kit[Package]="${PackageP11Kit[Name]}-${PackageP11Kit[Version]}";
PackageP11Kit[Extension]=".tar.xz";

PackageP11Kit[Programs]="p11-kit trust update-ca-certificates";
PackageP11Kit[Libraries]="libp11-kit.so $(find /usr /lib /lib64 -name p11-kit-proxy.so | head -1)";
PackageP11Kit[Python]="";

InstallP11Kit()
{
	# Check Installation
	CheckP11Kit && return $?;

	# Check Dependencies
	Dependencies=()
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=(LibTasn1)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh";
		fi
	done

	# Install Package
	_BuildP11Kit;
	return $?
}

CheckP11Kit()
{
	CheckInstallation 	"${PackageP11Kit[Programs]}"\
						"${PackageP11Kit[Libraries]}"\
						"${PackageP11Kit[Python]}" 1> /dev/null;
	return $?;
}

CheckP11KitVerbose()
{
	CheckInstallationVerbose	"${PackageP11Kit[Programs]}"\
								"${PackageP11Kit[Libraries]}"\
								"${PackageP11Kit[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildP11Kit()
{
	EchoInfo	"Package ${PackageP11Kit[Name]}"

	DownloadPackage	"${PackageP11Kit[Source]}"	"${SHMAN_PDIR}"	"${PackageP11Kit[Package]}${PackageP11Kit[Extension]}"	"${PackageP11Kit[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageP11Kit[Package]}"	"${PackageP11Kit[Extension]}";

	EchoInfo	"${PackageP11Kit[Name]}> Preparing the distribution specific anchor hook"
	sed '20,$ d' -i trust/trust-extract-compat &&
	cat >> trust/trust-extract-compat << "EOF"
# Copy existing anchor modifications to /etc/ssl/local
/usr/libexec/make-ca/copy-trust-modifications

# Update trust stores
/usr/sbin/make-ca -r
EOF

	if ! cd "${SHMAN_PDIR}${PackageP11Kit[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageP11Kit[Package]}";
		return 1;
	fi

	if ! mkdir -p p11-build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageP11Kit[Name]}/p11-build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageP11Kit[Package]}/p11-build";

	EchoInfo	"${PackageP11Kit[Name]}> meson setup"
	meson setup ..	--prefix=/usr \
					--buildtype=release \
					-D trust_paths=/etc/pki/anchors \
					1> /dev/null || { EchoTest KO ${PackageP11Kit[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageP11Kit[Name]}> ninja"
	ninja  1> /dev/null || { EchoTest KO ${PackageP11Kit[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageP11Kit[Name]}> LC_ALL=C ninja test"
	LC_ALL=C ninja test 1> /dev/null || { EchoTest KO ${PackageP11Kit[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageP11Kit[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageP11Kit[Name]} && PressAnyKeyToContinue; return 1; };

	ln -sfv /usr/libexec/p11-kit/trust-extract-compat \
			/usr/bin/update-ca-certificates
}
