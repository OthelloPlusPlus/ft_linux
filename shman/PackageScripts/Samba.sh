#!/bin/bash

if [ ! -z "${PackageSamba[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Samba								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageSamba;
# Manual
PackageSamba[Source]="https://download.samba.org/pub/samba/stable/samba-4.21.4.tar.gz";
PackageSamba[MD5]="6d0b330364e05fed58cc63fbb43037fe";
# Automated unless edgecase
PackageSamba[Name]="";
PackageSamba[Version]="";
PackageSamba[Extension]="";
if [[ -n "${PackageSamba[Source]}" ]]; then
	filename="${PackageSamba[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageSamba[Name]}" ]] && PackageSamba[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageSamba[Version]}" ]] && PackageSamba[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageSamba[Extension]}" ]] && PackageSamba[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageSamba[Package]="${PackageSamba[Name]}-${PackageSamba[Version]}";

PackageSamba[Programs]="cifsdd dbwrap_tool dumpmscat eventlogadm gentest ldbadd ldbdel ldbedit ldbmodify ldbrename ldbsearch locktest masktest mdsearch mvxattr ndrdump net nmbd nmblookup ntlm_auth oLschema2ldif pdbedit profiles regdiff regpatch regshell regtree rpcclient samba-log-parser samba-gpupdate samba-regedit samba-tool sharesec smbcacls smbclient smbcontrol smbcquotas smbd smbget smbpasswd smbspool smbstatus smbtar smbtorture smbtree tdbbackup tdbdump tdbrestore tdbtool testparm wbinfo winbindd";
PackageSamba[Libraries]="libdcerpc-binding.so libdcerpc-samr.so libdcerpc-server-core.so libdcerpc.so libndr-krb5pac.so libndr-nbt.so libndr.so libndr-standard.so libnetapi.so libnss_winbind.so libnss_wins.so libsamba-credentials.so libsamba-errors.so libsamba-hostconfig.so libsamba-passdb.so libsamba-policy.cpython-311-x86_64-linux-gnu.so libsamba-util.so libsamdb.so libsmbclient.so libsmbconf.so libsmbldap.so libtevent-util.so libwbclient.so filesystem";
PackageSamba[Python]="";

InstallSamba()
{
	# Check Installation
	CheckSamba && return $?;

	# Check Dependencies
	EchoInfo	"${PackageSamba[Name]}> Checking dependencies..."
	#Parse Yapp
	Required=(GnuTLS LibTirpc1 RpcsvcProto)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageSamba[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Dbus Fuse GPGME ICU Jansson LibTasn1 LibXslt LinuxPAM Lmdb MITKerberos OpenLDAP)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageSamba[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Avahi BIND Cups CyrusSASL GDB Git GnuPG LibAio LibArchive LibCap LibGcrypt LibNsl LibUnwind Markdown Nss Popt Talloc Vala Valgrind Xfsprogs)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageSamba[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageSamba[Name]}> Building package..."
	_ExtractPackageSamba || return $?;
	_BuildSamba || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageSamba[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckSamba()
{
	CheckInstallation 	"${PackageSamba[Programs]}"\
						"${PackageSamba[Libraries]}"\
						"${PackageSamba[Python]}" 1> /dev/null;
	return $?;
}

CheckSambaVerbose()
{
	CheckInstallationVerbose	"${PackageSamba[Programs]}"\
								"${PackageSamba[Libraries]}"\
								"${PackageSamba[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageSamba()
{
	DownloadPackage	"${PackageSamba[Source]}"	"${SHMAN_PDIR}"	"${PackageSamba[Package]}${PackageSamba[Extension]}"	"${PackageSamba[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageSamba[Package]}"	"${PackageSamba[Extension]}" || return $?;

	for URL in \
		"https://www.linuxfromscratch.org/patches/blfs/12.3/samba-4.21.4-testsuite_linux_6_13-1.patch"
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildSamba()
{
	if ! cd "${SHMAN_PDIR}${PackageSamba[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageSamba[Package]}";
		return 1;
	fi

	python3 -m venv --system-site-packages pyvenv &&
	./pyvenv/bin/pip3 install cryptography pyasn1 iso8601 &&
	patch -Np1 -i ../samba-4.21.4-testsuite_linux_6_13-1.patch

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageSamba[Package]}/build \
	# 				|| { EchoError "${PackageSamba[Name]}> Failed to enter ${SHMAN_PDIR}${PackageSamba[Package]}/build"; return 1; }

	EchoInfo	"${PackageSamba[Name]}> Configure"
	PYTHON=$PWD/pyvenv/bin/python3 \
	PATH=$PWD/pyvenv/bin:$PATH \
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--localstatedir=/var \
				--with-piddir=/run/samba \
				--with-pammodulesdir=/usr/lib/security \
				--enable-fhs \
				--without-ad-dc \
				--without-systemd \
				--with-system-mitkrb5 \
				--enable-selftest \
				--disable-rpath-install \
				1> /dev/null || { EchoTest KO ${PackageSamba[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSamba[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageSamba[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageSamba[Name]}> make check"
	# make check 1> /dev/null || { EchoTest KO ${PackageSamba[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSamba[Name]}> sed"
	sed '1s@^.*$@#!/usr/bin/python3@' \
    -i ./bin/default/source4/scripting/bin/*.inst

	rm -rf /usr/lib/python3.13/site-packages/samba

	EchoInfo	"${PackageSamba[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageSamba[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSamba[Name]}> install -v -m"
	install -v -m644    examples/smb.conf.default /etc/samba

	EchoInfo	"${PackageSamba[Name]}> make"
	sed -e "s;log file =.*;log file = /var/log/samba/%m.log;" \
		-e "s;path = /usr/spool/samba;path = /var/spool/samba;" \
		-i /etc/samba/smb.conf.default

	mkdir -pv /etc/openldap/schema

	EchoInfo	"${PackageSamba[Name]}> install -v -m"
	install -v -m644    examples/LDAP/README \
						/etc/openldap/schema/README.samba

	install -v -m644    examples/LDAP/samba* \
						/etc/openldap/schema

	install -v -m755    examples/LDAP/{get*,ol*} \
						/etc/openldap/schema
}
