#!/bin/bash

if [ ! -z "${PackageGDM[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									GDM								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGDM;
# Manual
PackageGDM[Source]="https://download.gnome.org/sources/gdm/47/gdm-47.0.tar.xz";
PackageGDM[MD5]="0312497290b26525e14fbc153f1a87f2";
# Automated unless edgecase
PackageGDM[Name]="";
PackageGDM[Version]="";
PackageGDM[Extension]="";
if [[ -n "${PackageGDM[Source]}" ]]; then
	filename="${PackageGDM[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageGDM[Name]}" ]] && PackageGDM[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageGDM[Version]}" ]] && PackageGDM[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageGDM[Extension]}" ]] && PackageGDM[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageGDM[Package]="${PackageGDM[Name]}-${PackageGDM[Version]}";

PackageGDM[Programs]="gdm gdmflexiserver";
# stupid complicated checks: pam_gdm.so
PackageGDM[Libraries]="libgdm.so";
PackageGDM[Python]="";

InstallGDM()
{
	# Check Installation
	CheckGDM && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGDM[Name]}> Checking dependencies..."
	# Added Itstool
	Required=(AccountsService DConf GTK3 LibCanberra LinuxPAM Itstool)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Keyutils)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageGDM[Name]}> Building package..."
	_ExtractPackageGDM || return $?;
	_BuildGDM || return $?;
	_ConfigureGDM;
	return $?
}

CheckGDM()
{
	CheckInstallation 	"${PackageGDM[Programs]}"\
						"${PackageGDM[Libraries]}"\
						"${PackageGDM[Python]}" 1> /dev/null || return $?;
	# if [ "$(loginctl | awk '$3 == "gdm"' | wc -l)" -ne 1 ]; then return 1; fi
	return $?;
}

CheckGDMVerbose()
{
	CheckInstallationVerbose	"${PackageGDM[Programs]}"\
								"${PackageGDM[Libraries]}"\
								"${PackageGDM[Python]}" || return $?;

	# local GdmCount=$(loginctl | awk '$3 == "gdm"' | wc -l);
	# if [ "${GdmCount}" -ne 1 ]; then
	# 	echo -en "${C_RED}loginctl[$GdmCount]${C_RESET} " >&2;
	# 	if [ "${GdmCount}" -gt 1 ]; then
	# 		echo -en "'pkill -9 -U root -f gdm-session-worker' " >&2;
	# 	fi
	# 	return 1;
	# fi
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGDM()
{
	DownloadPackage	"${PackageGDM[Source]}"	"${SHMAN_PDIR}"	"${PackageGDM[Package]}${PackageGDM[Extension]}"	"${PackageGDM[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGDM[Package]}"	"${PackageGDM[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

# grep -E "(EE|WW)" /var/log/gdm/greeter.log
# ls -l /dev/tty1
# # usermod -a -G tty gdm
# grep -E "(gdm|tty)" /etc/group
# # usermod -s /bin/bash gdm
# grep ^gdm /etc/passwd


# ps -ef | grep elogind
# loginctl
# grep -E "(elogind| system-session)" /etc/pam.d/*
# grep -v "^#" /etc/elogind/logind.conf; grep -E "(^#HandleLidSwitch|^#KillUserProcesses)" /etc/elogind/logind.conf
# xinit

# vim /etc/rc.d/init.d/xdm 

_BuildGDM()
{
	if ! cd "${SHMAN_PDIR}${PackageGDM[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGDM[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageGDM[Name]}> Creating dedicated user"
	groupadd -g 21 gdm
	useradd -c "GDM Daemon Owner" -d /var/lib/gdm -u 21 \
			-g gdm -s /bin/false gdm &&
	passwd -ql gdm

	EchoInfo	"${PackageGDM[Name]}> Doing something for some reason"
	sed -e 's@systemd@elogind@'                                \
		-e '/elogind/isession  required       pam_loginuid.so' \
		-i data/pam-lfs/gdm-launch-environment.pam 

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGDM[Package]}/build \
					|| { EchoError "${PackageGDM[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGDM[Package]}/build"; return 1; }

	EchoInfo	"${PackageGDM[Name]}> Configure"
	meson setup .. \
				--prefix=/usr \
				--buildtype=release \
				-D gdm-xsession=true \
				-D run-dir=/run/gdm \
				-D logind-provider=elogind \
				-D systemd-journal=false \
				-D systemdsystemunitdir=no \
				-D systemduserunitdir=no \
				1> /dev/null || { EchoTest KO ${PackageGDM[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGDM[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageGDM[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGDM[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageGDM[Name]} && PressAnyKeyToContinue; return 1; };
}

_ConfigureGDM()
{
	ln -s /dev/null /etc/udev/rules.d/61-gdm.rules

	if ! grep -qF 	"^# Begin GDM addition" /etc/pam.d/system-session; then
		EchoInfo	"${PackageElogind[Name]}> /etc/pam.d/system-session"
		cat >> /etc/pam.d/system-session << "EOF"
# Begin GDM addition

session  required    pam_loginuid.so
session  optional    pam_elogind.so

# End GDM addition
EOF
	fi

	source ${SHMAN_SDIR}/_BLFSBootscripts.sh && BootScriptGDM;
}

# pkill -9 -U root -f gdm-session-worker

# bash-5.2# cat /etc/pam.d/system-session
# # Begin /etc/pamd.system-session

# session  required    pam_unix.so

# # End /etc/pam.d/system-session
# # Begin elogind addition

# session  required    pam_loginuid.so
# session  optional    pam_elogind.so

# # End elogind addition
# bash-5.2# cat /etc/pam.d/elogind-user 
# # Begin /etc/pam.d/elogind-user

# account  required    pam_access.so
# account  include     system-account

# session  required    pam_env.so
# session  required    pam_limits.so
# session  required    pam_unix.so
# session  required    pam_loginuid.so
# session  optional    pam_keyinit.so force revoke
# session  optional    pam_elogind.so

# auth     required    pam_deny.so
# password required    pam_deny.so

# # End /etc/pam.d/elogind-user
# bash-5.2# grep "pam_loginuid.so" /etc/pam.d/*
# /etc/pam.d/elogind-user:session  required    pam_loginuid.so
# /etc/pam.d/gdm-launch-environment:session  required       pam_loginuid.so
# /etc/pam.d/system-session:session  required    pam_loginuid.so
# bash-5.2# cat /etc/pam.d/gdm-launch-environment 
# # Begin /etc/pam.d/gdm-launch-environment

# auth     required       pam_succeed_if.so audit quiet_success user = gdm
# auth     required       pam_env.so
# auth     optional       pam_permit.so

# account  required       pam_succeed_if.so audit quiet_success user = gdm
# account  include        system-account

# password required       pam_deny.so

# session  required       pam_succeed_if.so audit quiet_success user = gdm
# session  required       pam_loginuid.so
# -session optional       pam_elogind.so
# session  optional       pam_keyinit.so force revoke
# session  optional       pam_permit.so

# # End /etc/pam.d/gdm-launch-environment
# bash-5.2# vim /etc/pam.d/gdm-launch-environment 