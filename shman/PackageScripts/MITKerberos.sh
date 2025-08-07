#!/bin/bash

if [ ! -z "${PackageMITKerberos[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									MITKerberos								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMITKerberos;
# Manual
PackageMITKerberos[Source]="https://kerberos.org/dist/krb5/1.21/krb5-1.21.3.tar.gz";
PackageMITKerberos[MD5]="beb34d1dfc72ba0571ce72bed03e06eb";
# Automated unless edgecase
PackageMITKerberos[Name]="";
PackageMITKerberos[Version]="";
PackageMITKerberos[Extension]="";
if [[ -n "${PackageMITKerberos[Source]}" ]]; then
	filename="${PackageMITKerberos[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageMITKerberos[Name]}" ]] && PackageMITKerberos[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageMITKerberos[Version]}" ]] && PackageMITKerberos[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageMITKerberos[Extension]}" ]] && PackageMITKerberos[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageMITKerberos[Package]="${PackageMITKerberos[Name]}-${PackageMITKerberos[Version]}";

PackageMITKerberos[Programs]="gss-client gss-server k5srvutil kadmin kadmin.local kadmind kdb5_util kdestroy kinit klist kpasswd kprop kpropd kproplog krb5-config krb5-send-pr krb5kdc ksu kswitch ktutil kvno sclient sim_client sim_server sserver uuclient uuserver";
PackageMITKerberos[Libraries]="libgssapi_krb5.so libgssrpc.so libk5crypto.so libkadm5clnt_mit.so libkadm5clnt.so libkadm5srv_mit.so libkadm5srv.so libkdb5.so libkrad.so libkrb5.so libkrb5support.so libverto.so";
PackageMITKerberos[Python]="";

InstallMITKerberos()
{
	# Check Installation
	CheckMITKerberos && return $?;

	# Check Dependencies
	EchoInfo	"${PackageMITKerberos[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageMITKerberos[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageMITKerberos[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(BINDUtilities CrackLib GnuPG Keyutils OpenLDAP Valgrind Yasm)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageMITKerberos[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageMITKerberos[Name]}> Building package..."
	_ExtractPackageMITKerberos || return $?;
	_BuildMITKerberos || return $?;
	_ConfigureMITKerberos || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageMITKerberos[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckMITKerberos()
{
	CheckInstallation 	"${PackageMITKerberos[Programs]}"\
						"${PackageMITKerberos[Libraries]}"\
						"${PackageMITKerberos[Python]}" 1> /dev/null;
	return $?;
}

CheckMITKerberosVerbose()
{
	CheckInstallationVerbose	"${PackageMITKerberos[Programs]}"\
								"${PackageMITKerberos[Libraries]}"\
								"${PackageMITKerberos[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageMITKerberos()
{
	DownloadPackage	"${PackageMITKerberos[Source]}"	"${SHMAN_PDIR}"	"${PackageMITKerberos[Package]}${PackageMITKerberos[Extension]}"	"${PackageMITKerberos[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageMITKerberos[Package]}"	"${PackageMITKerberos[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildMITKerberos()
{
	if ! cd "${SHMAN_PDIR}${PackageMITKerberos[Package]}/src"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageMITKerberos[Package]}/src";
		return 1;
	fi

	EchoInfo	"${PackageMITKerberos[Name]}> sed"
	sed -i -e '/eq 0/{N;s/12 //}' plugins/kdb/db2/libdb2/test/run.test

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageMITKerberos[Package]}/build \
	# 				|| { EchoError "${PackageMITKerberos[Name]}> Failed to enter ${SHMAN_PDIR}${PackageMITKerberos[Package]}/build"; return 1; }

	EchoInfo	"${PackageMITKerberos[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--localstatedir=/var/lib \
				--runstatedir=/run \
				--with-system-et \
				--with-system-ss \
				--with-system-verto=no \
				--enable-dns-for-realm \
				--disable-rpath \
				1> /dev/null || { EchoTest KO ${PackageMITKerberos[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMITKerberos[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageMITKerberos[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageMITKerberos[Name]}> make -j1 -k check"
	# make -j1 -k check 1> /dev/null || { EchoTest KO ${PackageMITKerberos[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMITKerberos[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageMITKerberos[Name]} && PressAnyKeyToContinue; return 1; };

	cp -vfr ../doc -T /usr/share/doc/krb5-1.21.3
}

_ConfigureMITKerberos()
{
	EchoWarning	"${PackageMITKerberos[Name]}> Configuration not implemented"; PressAnyKeyToContinue;
# 	EchoInfo	"${PackageMITKerberos[Name]}> /etc/krb5.conf"
# 	EchoWarning "Needs Adjusting"
# 	PressAnyKeyToContinue;
# 	cat > /etc/krb5.conf << "EOF"
# # Begin /etc/krb5.conf

# [libdefaults]
#     default_realm = <EXAMPLE.ORG>
#     encrypt = true

# [realms]
#     <EXAMPLE.ORG> = {
#         kdc = <belgarath.example.org>
#         admin_server = <belgarath.example.org>
#         dict_file = /usr/share/dict/words
#     }

# [domain_realm]
#     .<example.org> = <EXAMPLE.ORG>

# [logging]
#     kdc = SYSLOG:INFO:AUTH
#     admin_server = SYSLOG:INFO:AUTH
#     default = SYSLOG:DEBUG:DAEMON

# # End /etc/krb5.conf
# EOF

}
