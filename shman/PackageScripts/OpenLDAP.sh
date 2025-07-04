#!/bin/bash

if [ ! -z "${PackageOpenLDAP[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									OpenLDAP								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageOpenLDAP;
PackageOpenLDAP[Source]="https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.6.9.tgz";
PackageOpenLDAP[MD5]="608973c35cd4924fca0f07d0ea72c016";
PackageOpenLDAP[Name]="openldap";
PackageOpenLDAP[Version]="2.6.9";
PackageOpenLDAP[Package]="${PackageOpenLDAP[Name]}-${PackageOpenLDAP[Version]}";
PackageOpenLDAP[Extension]=".tgz";

# excluded sever programs: slapacl slapadd slapauth slapcat slapd slapdn slapindex slapmodify slappasswd slapschema slaptest
PackageOpenLDAP[Programs]="ldapadd ldapcompare ldapdelete ldapexop ldapmodify ldapmodrdn ldappasswd ldapsearch ldapurl ldapvc ldapwhoami";
PackageOpenLDAP[Libraries]="liblber.so libldap.so";
PackageOpenLDAP[Python]="";

InstallOpenLDAP()
{
	# Check Installation
	CheckOpenLDAP && return $?;

	# Check Dependencies
	EchoInfo	"${PackageOpenLDAP[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(CyrusSASL)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(GnuTLS UnixODBC MariaDB PostgresSQL)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageOpenLDAP[Name]}> Building package..."
	_ExtractPackageOpenLDAP || return $?;
	_BuildOpenLDAP;
	return $?
}

CheckOpenLDAP()
{
	CheckInstallation 	"${PackageOpenLDAP[Programs]}"\
						"${PackageOpenLDAP[Libraries]}"\
						"${PackageOpenLDAP[Python]}" 1> /dev/null;
	return $?;
}

CheckOpenLDAPVerbose()
{
	CheckInstallationVerbose	"${PackageOpenLDAP[Programs]}"\
								"${PackageOpenLDAP[Libraries]}"\
								"${PackageOpenLDAP[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageOpenLDAP()
{
	DownloadPackage	"${PackageOpenLDAP[Source]}"	"${SHMAN_PDIR}"	"${PackageOpenLDAP[Package]}${PackageOpenLDAP[Extension]}"	"${PackageOpenLDAP[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageOpenLDAP[Package]}"	"${PackageOpenLDAP[Extension]}" || return $?;
	wget -P "${SHMAN_PDIR}" "https://www.linuxfromscratch.org/patches/blfs/12.3/openldap-2.6.9-consolidated-1.patch";

	return $?;
}

_BuildOpenLDAP()
{
	if ! cd "${SHMAN_PDIR}${PackageOpenLDAP[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageOpenLDAP[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageOpenLDAP[Name]}> Patching"
	patch -Np1 -i ../openldap-2.6.9-consolidated-1.patch
	autoconf

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageOpenLDAP[Package]}/build \
	# 				|| { EchoError "${PackageOpenLDAP[Name]}> Failed to enter ${SHMAN_PDIR}${PackageOpenLDAP[Package]}/build"; return 1; }

	EchoInfo	"${PackageOpenLDAP[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--disable-static \
				--enable-dynamic \
				--disable-debug \
				--disable-slapd 1> /dev/null || { EchoTest KO ${PackageOpenLDAP[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageOpenLDAP[Name]}> make depend"
	make depend 1> /dev/null || { EchoTest KO ${PackageOpenLDAP[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageOpenLDAP[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageOpenLDAP[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageOpenLDAP[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageOpenLDAP[Name]} && PressAnyKeyToContinue; return 1; };
}
