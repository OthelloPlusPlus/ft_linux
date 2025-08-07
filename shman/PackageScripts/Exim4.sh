#!/bin/bash

if [ ! -z "${PackageExim4[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Exim4								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageExim4;
# Manual
PackageExim4[Source]="https://ftp.exim.org/pub/exim/exim4/exim-4.98.2.tar.xz";
PackageExim4[MD5]="";
# Automated unless edgecase
PackageExim4[Name]="";
PackageExim4[Version]="";
PackageExim4[Extension]="";
if [[ -n "${PackageExim4[Source]}" ]]; then
	filename="${PackageExim4[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageExim4[Name]}" ]] && PackageExim4[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageExim4[Version]}" ]] && PackageExim4[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageExim4[Extension]}" ]] && PackageExim4[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageExim4[Package]="${PackageExim4[Name]}-${PackageExim4[Version]}";

PackageExim4[Programs]="exicyclog exigrep exim exim-4.98.2-2 exim_checkaccess exim_dbmbuild exim_dumpdb exim_fixdb exim_id_update exim_lock exim_msgdate exim_tidydb eximstats exinext exipick exiqgrep exiqsumm exiwhat sendmail";
PackageExim4[Libraries]="";
PackageExim4[Python]="";

InstallExim4()
{
	# Check Installation
	CheckExim4 && return $?;

	# Check Dependencies
	EchoInfo	"${PackageExim4[Name]}> Checking dependencies..."
	Required=(LibNsl2 PCRE2)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageExim4[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done
	cpan File::FcntlLock || { PressAnyKeyToContinue; return $?; }

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageExim4[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(CyrusSASL2 LibIdn1 LinuxPAM DariaDB11 OpenLDAP GnuTLS PostgreSQL17 SQLite)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageExim4[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageExim4[Name]}> Building package..."
	_ExtractPackageExim4 || return $?;
	_BuildExim4 || return $?
	_ConfigureExim4;
	return $?
}

CheckExim4()
{
	CheckInstallation 	"${PackageExim4[Programs]}"\
						"${PackageExim4[Libraries]}"\
						"${PackageExim4[Python]}" 1> /dev/null;
	return $?;
}

CheckExim4Verbose()
{
	CheckInstallationVerbose	"${PackageExim4[Programs]}"\
								"${PackageExim4[Libraries]}"\
								"${PackageExim4[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageExim4()
{
	DownloadPackage	"${PackageExim4[Source]}"	"${SHMAN_PDIR}"	"${PackageExim4[Package]}${PackageExim4[Extension]}"	"${PackageExim4[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageExim4[Package]}"	"${PackageExim4[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildExim4()
{
	if ! cd "${SHMAN_PDIR}${PackageExim4[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageExim4[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageExim4[Name]}> add user"
	groupadd -g 31 exim && \
	useradd -d /dev/null -c "Exim Daemon" -g exim -s /bin/false -u 31 exim

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageExim4[Package]}/build \
	# 				|| { EchoError "${PackageExim4[Name]}> Failed to enter ${SHMAN_PDIR}${PackageExim4[Package]}/build"; return 1; }

	EchoInfo	"${PackageExim4[Name]}> Configure"
	sed -e 's,^BIN_DIR.*$,BIN_DIRECTORY=/usr/sbin,' \
		-e 's,^CONF.*$,CONFIGURE_FILE=/etc/exim.conf,' \
		-e 's,^EXIM_USER.*$,EXIM_USER=exim,' \
		-e '/# USE_OPENSSL/s,^#,,' src/EDITME > Local/Makefile \
		1> /dev/null || { EchoTest KO ${PackageExim4[Name]} && PressAnyKeyToContinue; return 1; };
	printf "USE_GDBM = yes\nDBMLIB = -lgdbm\n" >> Local/Makefile

	EchoInfo	"${PackageExim4[Name]}> Add Linux PAM support"
	sed -i '/# SUPPORT_PAM=yes/s,^#,,' Local/Makefile \
		1> /dev/null || { EchoTest KO ${PackageExim4[Name]} && PressAnyKeyToContinue; return 1; };
	echo "EXTRALIBS=-lpam" >> Local/Makefile

	EchoInfo	"${PackageExim4[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageExim4[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageExim4[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageExim4[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageExim4[Name]}> install -v"
	install -v -m644 doc/exim.8 /usr/share/man/man8
	
	install -vdm 755    /usr/share/doc/exim-4.98.1
	cp      -Rv doc/*   /usr/share/doc/exim-4.98.1

	ln -sfv exim /usr/sbin/sendmail
	install -v -d -m750 -o exim -g exim /var/spool/exim
}

_ConfigureExim4()
{
	EchoInfo	"${PackageExim4[Name]}> /var/mail"
	chmod -v a+wt /var/mail

	EchoInfo	"${PackageExim4[Name]}> /etc/aliases"
	cat >> /etc/aliases << "EOF"
postmaster: root
MAILER-DAEMON: root
EOF
	/usr/sbin/exim -bd -q15m

	EchoInfo	"${PackageExim4[Name]}> /etc/pam.d/exim"
	cat > /etc/pam.d/exim << "EOF"
# Begin /etc/pam.d/exim

auth    include system-auth
account include system-account
session include system-session

# End /etc/pam.d/exim
EOF

	source ${SHMAN_SDIR}/_BLFSBootscripts.sh && BootScriptExim;
}