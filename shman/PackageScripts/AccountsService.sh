#!/bin/bash

if [ ! -z "${PackageAccountsService[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#								AccountsService								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageAccountsService;
# Manual
PackageAccountsService[Source]="https://www.freedesktop.org/software/accountsservice/accountsservice-23.13.9.tar.xz";
PackageAccountsService[MD5]="03dccfe1b306b7ca19743e86d118e64d";
# Automated unless edgecase
PackageAccountsService[Name]="";
PackageAccountsService[Version]="";
PackageAccountsService[Extension]="";
if [[ -n "${PackageAccountsService[Source]}" ]]; then
	filename="${PackageAccountsService[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageAccountsService[Name]}" ]] && PackageAccountsService[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageAccountsService[Version]}" ]] && PackageAccountsService[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageAccountsService[Extension]}" ]] && PackageAccountsService[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageAccountsService[Package]="${PackageAccountsService[Name]}-${PackageAccountsService[Version]}";

PackageAccountsService[Programs]="accounts-daemon";
PackageAccountsService[Libraries]="libaccountsservice.so";
PackageAccountsService[Python]="";

InstallAccountsService()
{
	# Check Installation
	CheckAccountsService && return $?;

	# Check Dependencies
	EchoInfo	"${PackageAccountsService[Name]}> Checking dependencies..."
	Required=(Polkit)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Glib Elogind Vala)
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(GTKDoc Xmlto)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageAccountsService[Name]}> Building package..."
	_ExtractPackageAccountsService || return $?;
	_BuildAccountsService || return $?;
	ldconfig;
	return $?
}

CheckAccountsService()
{
	[[ -x /usr/libexec/accounts-daemon ]] && \
	CheckInstallation 	""\
						"${PackageAccountsService[Libraries]}"\
						"${PackageAccountsService[Python]}" 1> /dev/null;
	return $?;
}

CheckAccountsServiceVerbose()
{
	local ReturnValue=0
	[[ -x /usr/libexec/accounts-daemon ]] || { ReturnValue=$?; echo -en "${C_RED}accounts-daemon${C_RESET} " >&2; };
	CheckInstallationVerbose	""\
								"${PackageAccountsService[Libraries]}"\
								"${PackageAccountsService[Python]}" || ReturnValue=$?;
	return $ReturnValue;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageAccountsService()
{
	DownloadPackage	"${PackageAccountsService[Source]}"	"${SHMAN_PDIR}"	"${PackageAccountsService[Package]}${PackageAccountsService[Extension]}"	"${PackageAccountsService[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageAccountsService[Package]}"	"${PackageAccountsService[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildAccountsService()
{
	if ! cd "${SHMAN_PDIR}${PackageAccountsService[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageAccountsService[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageAccountsService[Name]}> Rename tests/dbusmock"
	mv tests/dbusmock{,-tests}

	EchoInfo	"${PackageAccountsService[Name]}> Fix a test script so that the new directory is found"
	sed -e '/accounts_service\.py/s/dbusmock/dbusmock-tests/' \
		-e 's/assertEquals/assertEqual/' \
		-i tests/test-libaccountsservice.py || PressAnyKeyToContinue;

	EchoInfo	"${PackageAccountsService[Name]}> Fix failing test"
	sed -i '/^SIMULATED_SYSTEM_LOCALE/s/en_IE.UTF-8/en_HK.iso88591/' tests/test-daemon.py

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageAccountsService[Package]}/build \
					|| { EchoError "${PackageAccountsService[Name]}> Failed to enter ${SHMAN_PDIR}${PackageAccountsService[Package]}/build"; return 1; }

	EchoWarning	"${PackageAccountsService[Name]}> Creating temporary user, cause root errored"
	local TempUser="TempAccountsServiceUser"
	useradd -m -d /tmp/${TempUser}Home -s /bin/bash ${TempUser}
	chown -R ${TempUser}:${TempUser} ${SHMAN_PDIR}${PackageAccountsService[Package]}

	EchoInfo	"${PackageAccountsService[Name]}> Configure"
	su - ${TempUser} <<EOF
cd ${SHMAN_PDIR}${PackageAccountsService[Package]}/build
meson setup .. \
			--prefix=/usr \
			--buildtype=release \
			-D admin_group=adm \
			-D elogind=true \
			-D systemdsystemunitdir=no \
			-D vapi=false \
			|| { 
				ps aux | grep dbus-daemon;
				kill $DBUS_SESSION_BUS_PID
				exit 1;
			};
EOF
	if [[ $? -ne 0 ]]; then EchoTest KO "${PackageAccountsService[Name]}> meson setup as $TempUser"; PressAnyKeyToContinue; return 1; fi

	EchoInfo	"${PackageAccountsService[Name]}> Adapt shipped mocklibc"
	grep 'print_indent'     ../subprojects/mocklibc-1.0/src/netgroup.c \
		| sed 's/ {/;/' >> ../subprojects/mocklibc-1.0/src/netgroup.h &&
	sed -i '1i#include <stdio.h>' \
		../subprojects/mocklibc-1.0/src/netgroup.h

	EchoInfo	"${PackageAccountsService[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageAccountsService[Name]} && PressAnyKeyToContinue; return 1; };
	chown -R ${TempUser}:${TempUser} ${SHMAN_PDIR}${PackageAccountsService[Package]}

	EchoInfo	"${PackageAccountsService[Name]}> ninja test"
	su - ${TempUser} <<EOF
cd ${SHMAN_PDIR}${PackageAccountsService[Package]}/build
ninja test  || { 
		exit 1;
	};
EOF
	if [[ $? -ne 0 ]]; then EchoTest KO "${PackageAccountsService[Name]}> ninja test as $TempUser"; PressAnyKeyToContinue; return 1; fi

	# ninja test 1> /dev/null || { EchoTest KO ${PackageAccountsService[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoWarning	"${PackageAccountsService[Name]}> Removing temporary user"
	userdel -r ${TempUser}
	chown -R root:root ${SHMAN_PDIR}${PackageAccountsService[Package]}
	rm -rf /tmp/${TempUser}Home

	EchoInfo	"${PackageAccountsService[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageAccountsService[Name]} && PressAnyKeyToContinue; return 1; };
}
