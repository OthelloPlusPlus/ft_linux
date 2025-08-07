#!/bin/bash

if [ ! -z "${PackageAt3[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									At3								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageAt3;
# Manual
PackageAt3[Source]="https://anduin.linuxfromscratch.org/BLFS/at/at_3.2.5.orig.tar.gz";
PackageAt3[MD5]="ca3657a1c90d7c3d252e0bc17feddc6e";
# Automated unless edgecase
PackageAt3[Name]="at";
PackageAt3[Version]="3.2.5";
PackageAt3[Extension]=".tar.gz";
if [[ -n "${PackageAt3[Source]}" ]]; then
	filename="${PackageAt3[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageAt3[Name]}" ]] && PackageAt3[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageAt3[Version]}" ]] && PackageAt3[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageAt3[Extension]}" ]] && PackageAt3[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageAt3[Package]="${PackageAt3[Name]}-${PackageAt3[Version]}";

PackageAt3[Programs]="at atd atq atrm atrun batch";
PackageAt3[Libraries]="";
PackageAt3[Python]="";

InstallAt3()
{
	# Check Installation
	CheckAt3 && return $?;

	# Check Dependencies
	EchoInfo	"${PackageAt3[Name]}> Checking dependencies..."
	local RequiredSuccess=1;
	# Dovecot Postfix Sendmail8
	Required=(Exim4)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageAt3[Name]}> Checking required ${Dependency}..."
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" && RequiredSuccess=0;
	done
	if [ $RequiredSuccess -ne 0 ]; then PressAnyKeyToContinue; return 1; fi

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageAt3[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(LinuxPAM)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageAt3[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageAt3[Name]}> Building package..."
	_ExtractPackageAt3 || return $?;
	_BuildAt3 || return $?;
	_ConfigureAt3;
	return $?
}

CheckAt3()
{
	CheckInstallation 	"${PackageAt3[Programs]}"\
						"${PackageAt3[Libraries]}"\
						"${PackageAt3[Python]}" 1> /dev/null;
	return $?;
}

CheckAt3Verbose()
{
	CheckInstallationVerbose	"${PackageAt3[Programs]}"\
								"${PackageAt3[Libraries]}"\
								"${PackageAt3[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageAt3()
{
	DownloadPackage	"${PackageAt3[Source]}"	"${SHMAN_PDIR}"	"${PackageAt3[Package]}${PackageAt3[Extension]}"	"${PackageAt3[MD5]}";
	mv -f "${SHMAN_PDIR}/at_3.2.5.orig.tar.gz" "${SHMAN_PDIR}/at-3.2.5.tar.gz"
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageAt3[Package]}"	"${PackageAt3[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildAt3()
{
	if ! cd "${SHMAN_PDIR}${PackageAt3[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageAt3[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageAt3[Name]}> Adding user for daemon"
	groupadd -g 17 atd && \
	useradd -d /dev/null -c "atd daemon" -g atd -s /bin/false -u 17 atd

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageAt3[Package]}/build \
	# 				|| { EchoError "${PackageAt3[Name]}> Failed to enter ${SHMAN_PDIR}${PackageAt3[Package]}/build"; return 1; }

	EchoInfo	"${PackageAt3[Name]}> Configure"
	./configure --with-daemon_username=atd \
				--with-daemon_groupname=atd \
				--with-jobdir=/var/spool/atjobs \
				--with-atspool=/var/spool/atspool \
				SENDMAIL=/usr/sbin/sendmail \
				1> /dev/null || { EchoTest KO ${PackageAt3[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAt3[Name]}> make"
	make -j1 1> /dev/null || { EchoTest KO ${PackageAt3[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageAt3[Name]}> make check"
	# make check 1> /dev/null || { EchoTest KO ${PackageAt3[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAt3[Name]}> make install"
	make install docdir=/usr/share/doc/at-3.2.5 \
				atdocdir=/usr/share/doc/at-3.2.5 1> /dev/null || { EchoTest KO ${PackageAt3[Name]} && PressAnyKeyToContinue; return 1; };
}

_ConfigureAt3()
{
	cat > /etc/pam.d/atd << "EOF"
# Begin /etc/pam.d/atd

auth     required pam_unix.so
account  required pam_unix.so
password required pam_unix.so
session  required pam_unix.so

# End /etc/pam.d/atd
EOF

	source ${SHMAN_SDIR}/_BLFSBootscripts.sh && BootScriptAt;
}
