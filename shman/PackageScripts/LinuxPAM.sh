#!/bin/bash

if [ ! -z "${PackageLinuxPAM[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									LinuxPAM								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLinuxPAM;
# Manual
PackageLinuxPAM[Source]="https://github.com/linux-pam/linux-pam/releases/download/v1.7.0/Linux-PAM-1.7.0.tar.xz";
PackageLinuxPAM[MD5]="c1e41d59d6852e45d0f953c8c8f869d6";
# Automated unless edgecase
PackageLinuxPAM[Name]="";
PackageLinuxPAM[Version]="";
PackageLinuxPAM[Extension]="";
if [[ -n "${PackageLinuxPAM[Source]}" ]]; then
	filename="${PackageLinuxPAM[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLinuxPAM[Name]}" ]] && PackageLinuxPAM[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLinuxPAM[Version]}" ]] && PackageLinuxPAM[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLinuxPAM[Extension]}" ]] && PackageLinuxPAM[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLinuxPAM[Package]="${PackageLinuxPAM[Name]}-${PackageLinuxPAM[Version]}";

# removed unix_update
PackageLinuxPAM[Programs]="faillock mkhomedir_helper pam_namespace_helper pam_timestamp_check pwhistory_helper unix_chkpwd";
PackageLinuxPAM[Libraries]="libpam.so libpamc.so libpam_misc.so";
PackageLinuxPAM[Python]="";

InstallLinuxPAM()
{
	# Check Installation
	CheckLinuxPAM && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLinuxPAM[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(LibNsl LibTirpc1 RpcsvcProto DocbookXml DocbookXslNS Fop LibXslt Lynx)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLinuxPAM[Name]}> Building package..."
	_ExtractPackageLinuxPAM || return $?;
	_BuildLinuxPAM || return $?;
	_ConfigureLinuxPAM;
	return $?
}

CheckLinuxPAM()
{
	CheckInstallation 	"${PackageLinuxPAM[Programs]}"\
						"${PackageLinuxPAM[Libraries]}"\
						"${PackageLinuxPAM[Python]}" 1> /dev/null;
	return $?;
}

CheckLinuxPAMVerbose()
{
	CheckInstallationVerbose	"${PackageLinuxPAM[Programs]}"\
								"${PackageLinuxPAM[Libraries]}"\
								"${PackageLinuxPAM[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLinuxPAM()
{
	DownloadPackage	"${PackageLinuxPAM[Source]}"	"${SHMAN_PDIR}"	"${PackageLinuxPAM[Package]}${PackageLinuxPAM[Extension]}"	"${PackageLinuxPAM[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLinuxPAM[Package]}"	"${PackageLinuxPAM[Extension]}" || return $?;

	for URL in \
		"https://anduin.linuxfromscratch.org/BLFS/Linux-PAM/Linux-PAM-1.7.0-docs.tar.xz"
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLinuxPAM()
{
	if ! cd "${SHMAN_PDIR}${PackageLinuxPAM[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLinuxPAM[Package]}";
		return 1;
	fi

	sed -e "s/'elinks'/'lynx'/" \
		-e "s/'-no-numbering', '-no-references'/ \
			'-force-html', '-nonumbers', '-stdin'/" \
		-i meson.build

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLinuxPAM[Package]}/build \
					|| { EchoError "${PackageLinuxPAM[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLinuxPAM[Package]}/build"; return 1; }

	EchoInfo	"${PackageLinuxPAM[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D docdir=/usr/share/doc/Linux-PAM-1.7.0 \
				1> /dev/null || { EchoTest KO ${PackageLinuxPAM[Name]} && PressAnyKeyToContinue; return 1; };

	local TempContentOther="auth     required       pam_deny.so
account  required       pam_deny.so
password required       pam_deny.so
session  required       pam_deny.so"

	if [ ! -f /etc/pam.d/other ]; then
		EchoInfo	"${PackageLinuxPAM[Name]}> Create config file /etc/pam.d/other (first install)"
		install -v -m755 -d /etc/pam.d
		echo "${TempContentOther}" > /etc/pam.d/other
	fi

	EchoInfo	"${PackageLinuxPAM[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLinuxPAM[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLinuxPAM[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageLinuxPAM[Name]} && PressAnyKeyToContinue; return 1; };

	if [ -f /etc/pam.d/other ] && diff -q <(echo "${TempContentOther}") /etc/pam.d/other >/dev/null; then
		EchoInfo	"${PackageLinuxPAM[Name]}> Removing config file /etc/pam.d/other (first install)"
		rm -fv /etc/pam.d/other
	fi

	EchoInfo	"${PackageLinuxPAM[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLinuxPAM[Name]} && PressAnyKeyToContinue; return 1; };
	chmod -v 4755 /usr/sbin/unix_chkpwd
	rm -rf /usr/lib/systemd
	tar -C / -xvf ../../Linux-PAM-1.7.0-docs.tar.xz
}

_ConfigureLinuxPAM()
{
	EchoInfo	"${PackageLinuxPAM[Name]}> /etc/pam.d/other"
	cat /etc/pam.d/other << EOF
# Begin /etc/pam.d/other

auth            required        pam_unix.so     nullok
account         required        pam_unix.so
session         required        pam_unix.so
password        required        pam_unix.so     nullok

# End /etc/pam.d/other
EOF

	EchoInfo	"${PackageLinuxPAM[Name]}> install"
	install -vdm755 /etc/pam.d

	EchoInfo	"${PackageLinuxPAM[Name]}> /etc/pam.d/system-account"
	cat > /etc/pam.d/system-account << "EOF" &&
# Begin /etc/pam.d/system-account

account   required    pam_unix.so

# End /etc/pam.d/system-account
EOF

	EchoInfo	"${PackageLinuxPAM[Name]}> /etc/pam.d/system-auth"
	cat > /etc/pam.d/system-auth << "EOF" &&
# Begin /etc/pam.d/system-auth

auth      required    pam_unix.so

# End /etc/pam.d/system-auth
EOF

	EchoInfo	"${PackageLinuxPAM[Name]}> /etc/pam.d/system-session"
	cat > /etc/pam.d/system-session << "EOF" &&
# Begin /etc/pam.d/system-session

session   required    pam_unix.so

# End /etc/pam.d/system-session
EOF

	EchoInfo	"${PackageLinuxPAM[Name]}> /etc/pam.d/system-password"
	cat > /etc/pam.d/system-password << "EOF"
# Begin /etc/pam.d/system-password

# use yescrypt hash for encryption, use shadow, and try to use any
# previously defined authentication token (chosen password) set by any
# prior module.
password  required    pam_unix.so       yescrypt shadow try_first_pass

# End /etc/pam.d/system-password
EOF
}
