#!/bin/bash

if [ ! -z "${PackageElogind[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Elogind								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageElogind;
PackageElogind[Source]="https://github.com/elogind/elogind/archive/v255.17/elogind-255.17.tar.gz";
PackageElogind[MD5]="3cd76e1a71e13c4810f6e80e176a8fa7";
# Automated unless edgecase
PackageElogind[Name]="";
PackageElogind[Version]="";
PackageElogind[Extension]="";
if [[ -n "${PackageElogind[Source]}" ]]; then
	filename="${PackageElogind[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageElogind[Name]}" ]] && PackageElogind[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageElogind[Version]}" ]] && PackageElogind[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageElogind[Extension]}" ]] && PackageElogind[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageElogind[Package]="${PackageElogind[Name]}-${PackageElogind[Version]}";

PackageElogind[Programs]="busctl elogind-inhibit loginctl";
# Added libsystemd.so to check if it properly replaces its utility
PackageElogind[Libraries]="libelogind.so libsystemd.so";
PackageElogind[Python]="";

InstallElogind()
{
	# Check Installation
	CheckElogind && return $?;

	# Check Dependencies
	EchoInfo	"${PackageElogind[Name]}> Checking dependencies..."
	Required=(Linux LinuxPAM) # moved LinuxPAM up because its needed for a directory
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Dbus DocbookXml DocbookXslNons LibXslt)
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
	_ConfigureElogind || return $?;

	/usr/libexec/elogind &
	EchoInfo "${PackageElogind[Name]}> Started daemon PID $!"
	return $?
}

CheckElogind()
{
	CheckInstallation 	"${PackageElogind[Programs]}"\
						"${PackageElogind[Libraries]}"\
						"${PackageElogind[Python]}" 1> /dev/null || return $?;


	if ! pgrep -x dbus-daemon &> /dev/null; then return 2; fi
	if ! ps -p $(cat /run/elogind.pid) &>/dev/null; then return 3; fi
	if ! loginctl &> /dev/null; then return 4; fi
	if ! dbus-send --system \
					--dest=org.freedesktop.login1 \
					--type=method_call \
					--print-reply \
					/org/freedesktop/login1 org.freedesktop.login1.Manager.ListSessions &>/dev/null; then
		return 5;
	fi
	return 0;
}

CheckElogindVerbose()
{
	CheckInstallationVerbose	"${PackageElogind[Programs]}"\
								"${PackageElogind[Libraries]}"\
								"${PackageElogind[Python]}" || return $?;

	if ! pgrep -x dbus-daemon &>/dev/null; then
		/etc/init.d/dbus start &> /dev/null
		if ! pgrep -x dbus-daemon &>/dev/null; then
			echo -en "${C_RED}dbus start${C_RESET} " >&2
			return 2;
		fi
	fi

	if [ -f /run/elogind.pid ]; then
		if ! ps -p $(cat /run/elogind.pid) &> /dev/null; then
			/usr/libexec/elogind &> /dev/null &
			if ! ps -p $(cat /run/elogind.pid) &> /dev/null; then
				echo -en "${C_RED}elogind${C_RESET} " >&2
				return 3;
			fi
		fi
	else
		if ! pgrep -f elogind &>/dev/null; then
			/usr/libexec/elogind &> /dev/null &
			if ! pgrep -f elogind &>/dev/null; then
				echo -en "${C_RED}elogind${C_RESET} " >&2
				return 3;
			fi
		fi
	fi

	for i in {1..10}; do
		if loginctl &>/dev/null; then break; fi
		if [ $i -ge 10 ]; then echo -en "$? ${C_RED}loginctl${C_RESET} " >&2; return 4; fi
		sleep 1;
	done

	if ! dbus-send --system \
					--dest=org.freedesktop.login1 \
					--type=method_call \
					--print-reply \
					/org/freedesktop/login1 org.freedesktop.login1.Manager.ListSessions &>/dev/null; then
		echo -en "$? ${C_RED}dbus interface${C_RESET} " >&2
		return 5;
	fi

	return 0;
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

	EchoInfo	"${PackageElogind[Name]}> Requires kernel settings INOTIFY_USER CONFIG_TMPFS CONFIG_TMPFS_POSIX_ACL CONFIG_CRYPTO CONFIG_CRYPTO_USER CONFIG_CRYPTO_USER_API_HASH"

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
	ninja test 1> /dev/null || {
		EchoTest KO "${PackageElogind[Name]}> 3 tests known to fail:";
		grep -B1 -A999 '^Summary of Failures:' "${SHMAN_PDIR}${PackageElogind[Package]}/build/meson-logs/testlog.txt" | GREP_COLORS='mt=1;33' grep --color=always -E -B10 -A10 "test-login|dbus-docs-fresh|check-version-history" || echo "No summary found.";
		PressAnyKeyToContinue;
	}

	EchoInfo	"${PackageElogind[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageElogind[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageElogind[Name]}> Creating symbolic links"
	ln -sfv  libelogind.pc /usr/lib/pkgconfig/libsystemd.pc
	ln -sfv  libelogind.pc /usr/lib64/pkgconfig/libsystemd.pc
	ln -sfvn elogind /usr/include/systemd
	ln -sv libelogind.so /usr/lib/libsystemd.so
	ln -sv libelogind.so /usr/lib64/libsystemd.so


}

_ConfigureElogind()
{
	EchoInfo	"${PackageElogind[Name]}> /etc/elogind/logind.conf"
	sed -e '/\[Login\]/a KillUserProcesses=no' \
		-i /etc/elogind/logind.conf

	if ! grep -qF 	"^# Begin elogind addition" /etc/pam.d/system-session; then
		EchoInfo	"${PackageElogind[Name]}> /etc/pam.d/system-session"
		cat >> /etc/pam.d/system-session << "EOF"
# Begin elogind addition

session  required    pam_loginuid.so
session  optional    pam_elogind.so

# End elogind addition
EOF
	fi

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