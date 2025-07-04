#!/bin/bash

if [ ! -z "${PackageElogind[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Elogind								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageElogind;
PackageElogind[Source]="https://github.com/elogind/elogind/archive/v255.17/elogind-255.17.tar.gz";
PackageElogind[MD5]="3cd76e1a71e13c4810f6e80e176a8fa7";
PackageElogind[Name]="elogind";
PackageElogind[Version]="255.17";
PackageElogind[Package]="${PackageElogind[Name]}-${PackageElogind[Version]}";
PackageElogind[Extension]=".tar.xz";

PackageElogind[Programs]="busctl elogind-inhibit loginctl";
PackageElogind[Libraries]="libelogind.so";
PackageElogind[Python]="";

InstallElogind()
{
	# Check Installation
	CheckElogind && return $?;

	# Check Dependencies
	EchoInfo	"${PackageElogind[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Dbus LinuxPAM Polkit DocbookXml DocbookXslNons LibXslt)
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Lxml Zsh Valgrind)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageElogind[Name]}> Building package..."
	_ExtractPackageElogind || return $?;
	_BuildElogind || return $?;
	_ConfigureElogind;
	return $?
}

CheckElogind()
{
	CheckInstallation 	"${PackageElogind[Programs]}"\
						"${PackageElogind[Libraries]}"\
						"${PackageElogind[Python]}" 1> /dev/null && \
	loginctl
	return $?;
}

CheckElogindVerbose()
{
	CheckInstallationVerbose	"${PackageElogind[Programs]}"\
								"${PackageElogind[Libraries]}"\
								"${PackageElogind[Python]}" && \
	loginctl
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageElogind()
{
	DownloadPackage	"${PackageElogind[Source]}"	"${SHMAN_PDIR}"	"${PackageElogind[Package]}${PackageElogind[Extension]}"	"${PackageElogind[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageElogind[Package]}"	"${PackageElogind[Extension]}" || return $?;

	for URL in \
	# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildElogind()
{
	if ! cd "${SHMAN_PDIR}${PackageElogind[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageElogind[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageElogind[Name]}> Requires kernel settings"
	PressAnyKeyToContinue;

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageElogind[Package]}/build \
					|| { EchoError "${PackageElogind[Name]}> Failed to enter ${SHMAN_PDIR}${PackageElogind[Package]}/build"; return 1; }

	EchoInfo	"${PackageElogind[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D man=auto \
				-D docdir=/usr/share/doc/elogind-255.17 \
				-D cgroup-controller=elogind \
				-D dev-kvm-mode=0660 \
				-D dbuspolicydir=/etc/dbus-1/system.d \
				1> /dev/null || { EchoTest KO ${PackageElogind[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageElogind[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageElogind[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageElogind[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageElogind[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageElogind[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageElogind[Name]} && PressAnyKeyToContinue; return 1; };
	ln -sfv  libelogind.pc /usr/lib/pkgconfig/libsystemd.pc
	ln -sfvn elogind /usr/include/systemd
}

_ConfigureElogind()
{
	EchoInfo	"${PackageElogind[Name]}> /etc/elogind/logind.conf"
	sed -e '/\[Login\]/a KillUserProcesses=no' \
		-i /etc/elogind/logind.conf

	EchoInfo	"${PackageElogind[Name]}> /etc/pam.d/system-session"	
	cat >> /etc/pam.d/system-session << "EOF" &&
# Begin elogind addition

session  required    pam_loginuid.so
session  optional    pam_elogind.so

# End elogind addition
EOF

	EchoInfo	"${PackageElogind[Name]}> /etc/pam.d/elogind-user"	
	cat > /etc/pam.d/elogind-user << "EOF"
# Begin /etc/pam.d/elogind-user

account  required    pam_access.so
account  include     system-account

session  required    pam_env.so
session  required    pam_limits.so
session  required    pam_unix.so
session  required    pam_loginuid.so
session  optional    pam_keyinit.so force revoke
session  optional    pam_elogind.so

auth     required    pam_deny.so
password required    pam_deny.so

# End /etc/pam.d/elogind-user
EOF
}