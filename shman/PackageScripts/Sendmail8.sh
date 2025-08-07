#!/bin/bash

if [ ! -z "${PackageSendmail8[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Sendmail8								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageSendmail8;
# Manual
PackageSendmail8[Source]="https://ftp.sendmail.org/sendmail.8.18.1.tar.gz";
PackageSendmail8[MD5]="b6b332295b5779036d4c9246f96f673c";
# Automated unless edgecase
PackageSendmail8[Name]="sendmail";
PackageSendmail8[Version]="8.18.1";
PackageSendmail8[Extension]=".tar.gz";
if [[ -n "${PackageSendmail8[Source]}" ]]; then
	filename="${PackageSendmail8[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageSendmail8[Name]}" ]] && PackageSendmail8[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageSendmail8[Version]}" ]] && PackageSendmail8[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageSendmail8[Extension]}" ]] && PackageSendmail8[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageSendmail8[Package]="${PackageSendmail8[Name]}-${PackageSendmail8[Version]}";

PackageSendmail8[Programs]="editmap mailstats makemap praliases sendmail smrsh vacation";
PackageSendmail8[Libraries]="";
PackageSendmail8[Python]="";

InstallSendmail8()
{
	# Check Installation
	CheckSendmail8 && return $?;

	# Check Dependencies
	EchoInfo	"${PackageSendmail8[Name]}> Checking dependencies..."
	Required=(OpenLDAP)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageSendmail8[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { EchoError "${PackageSendmail8[Name]}--->${Dependency}"; PressAnyKeyToContinue; return $?; }
	done

	Recommended=(CyrusSASL)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageSendmail8[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { EchoError "${PackageSendmail8[Name]}-->${Dependency}"; PressAnyKeyToContinue; }
	done

	Optional=(Ghostscript Procmail)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageSendmail8[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"|| EchoWarning "${PackageSendmail8[Name]}->${Dependency}";
		fi
	done

	# Install Package
	EchoInfo	"${PackageSendmail8[Name]}> Building package..."
	_ExtractPackageSendmail8 || return $?;
	_BuildSendmail8 || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageSendmail8[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { EchoError "${PackageSendmail8[Name]}=>${Dependency}"; PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckSendmail8()
{
	CheckInstallation 	"${PackageSendmail8[Programs]}"\
						"${PackageSendmail8[Libraries]}"\
						"${PackageSendmail8[Python]}" 1> /dev/null;
	return $?;
}

CheckSendmail8Verbose()
{
	CheckInstallationVerbose	"${PackageSendmail8[Programs]}"\
								"${PackageSendmail8[Libraries]}"\
								"${PackageSendmail8[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageSendmail8()
{
	DownloadPackage	"${PackageSendmail8[Source]}"	"${SHMAN_PDIR}"	"${PackageSendmail8[Package]}${PackageSendmail8[Extension]}"	"${PackageSendmail8[MD5]}" || return $?;
	mv "${SHMAN_PDIR}/sendmail.8.18.1.tar.gz" "${SHMAN_PDIR}/sendmail-8.18.1.tar.gz"
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageSendmail8[Package]}"	"${PackageSendmail8[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildSendmail8()
{
	if ! cd "${SHMAN_PDIR}${PackageSendmail8[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageSendmail8[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageSendmail8[Name]}> Create user smmsp"
	groupadd -g 26 smmsp                               &&
	useradd -c "Sendmail Daemon" -g smmsp -d /dev/null \
			-s /bin/false -u 26 smmsp                  &&
	chmod -v 1777 /var/mail                            &&
	install -v -m700 -d /var/spool/mqueue

	if ! grep -qF 'APPENDDEF(`confENVDEF' devtools/Site/site.config.m4; then
		EchoInfo	"${PackageSendmail8[Name]}> devtools/Site/site.config.m4"
		cat >> devtools/Site/site.config.m4 << "EOF"
APPENDDEF(`confENVDEF',`-D STARTTLS -D SASL -D LDAPMAP -D HASFLOCK')
APPENDDEF(`confLIBS', `-lssl -lcrypto -lsasl2 -lldap -llber')
APPENDDEF(`confINCDIRS', `-I/usr/include/sasl')
EOF
	fi

	if ! grep -qF 'define(`confMANGRP' devtools/Site/site.config.m4; then
		cat >> devtools/Site/site.config.m4 << "EOF"
define(`confMANGRP',`root')
define(`confMANOWN',`root')
define(`confSBINGRP',`root')
define(`confUBINGRP',`root')
define(`confUBINOWN',`root')
EOF
	fi

	EchoInfo	"${PackageSendmail8[Name]}> Build"
	sed -i 's|/usr/man/man|/usr/share/man/man|' \
		devtools/OS/Linux           &&

	cd sendmail                     &&
	sh Build                        &&
	cd ../cf/cf                     &&
	cp generic-linux.mc sendmail.mc &&
	sh Build sendmail.cf || { EchoTest KO ${PackageSendmail8[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSendmail8[Name]}> install -v -m"
	install -v -d -m755 /etc/mail &&
	sh Build install-cf &&

	cd ../..            &&
	sh Build install    &&

	install -v -m644 cf/cf/{submit,sendmail}.mc /etc/mail &&
	cp -v -R cf/* /etc/mail                               &&

	install -v -m755 -d /usr/share/doc/sendmail-8.18.1/{cf,sendmail} &&

	install -v -m644 CACerts FAQ KNOWNBUGS LICENSE PGPKEYS README RELEASE_NOTES \
			/usr/share/doc/sendmail-8.18.1 &&

	install -v -m644 sendmail/{README,SECURITY,TRACEFLAGS,TUNING} \
			/usr/share/doc/sendmail-8.18.1/sendmail &&

	install -v -m644 cf/README /usr/share/doc/sendmail-8.18.1/cf &&

	for manpage in sendmail editmap mailstats makemap praliases smrsh
	do
		install -v -m644 $manpage/$manpage.8 /usr/share/man/man8
	done &&

	install -v -m644 sendmail/aliases.5    /usr/share/man/man5 &&
	install -v -m644 sendmail/mailq.1      /usr/share/man/man1 &&
	install -v -m644 sendmail/newaliases.1 /usr/share/man/man1 &&
	install -v -m644 vacation/vacation.1   /usr/share/man/man1 || \
	{ EchoTest KO ${PackageSendmail8[Name]} && PressAnyKeyToContinue; return 1; };

	cd doc/op                                       &&
	sed -i 's/groff/GROFF_NO_SGR=1 groff/' Makefile &&
	make op.txt op.pdf

	install -v -d -m755 /usr/share/doc/sendmail-8.18.1 &&
	install -v -m644 op.ps op.txt op.pdf /usr/share/doc/sendmail-8.18.1 &&
	cd ../..
}
