#!/bin/bash

if [ ! -z "${PackageFcron3[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Fcron3								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageFcron3;
# Manual
PackageFcron3[Source]="http://fcron.free.fr/archives/fcron-3.2.1.src.tar.gz";
PackageFcron3[MD5]="bd4996e941a40327d11efc5e3fd1f839";
# Automated unless edgecase
PackageFcron3[Name]="";
PackageFcron3[Version]="";
PackageFcron3[Extension]="";
if [[ -n "${PackageFcron3[Source]}" ]]; then
	filename="${PackageFcron3[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageFcron3[Name]}" ]] && PackageFcron3[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageFcron3[Version]}" ]] && PackageFcron3[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageFcron3[Extension]}" ]] && PackageFcron3[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageFcron3[Package]="${PackageFcron3[Name]}-${PackageFcron3[Version]}";

PackageFcron3[Programs]="fcron fcrondyn fcronsighup fcrontab";
PackageFcron3[Libraries]="";
PackageFcron3[Python]="";

InstallFcron3()
{
	# Check Installation
	CheckFcron3 && return $?;

	# Check Dependencies
	EchoInfo	"${PackageFcron3[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageFcron3[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageFcron3[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	# Dovecot Postfix Sendmail8 
	Optional=(Exim4 LinuxPAM DocBookUtils)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageFcron3[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageFcron3[Name]}> Building package..."
	_ExtractPackageFcron3 || return $?;
	_BuildFcron3 || return $?;
	_ConfigureFcron3
	return $?
}

CheckFcron3()
{
	CheckInstallation 	"${PackageFcron3[Programs]}"\
						"${PackageFcron3[Libraries]}"\
						"${PackageFcron3[Python]}" 1> /dev/null;
	return $?;
}

CheckFcron3Verbose()
{
	CheckInstallationVerbose	"${PackageFcron3[Programs]}"\
								"${PackageFcron3[Libraries]}"\
								"${PackageFcron3[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageFcron3()
{
	DownloadPackage	"${PackageFcron3[Source]}"	"${SHMAN_PDIR}"	"${PackageFcron3[Package]}${PackageFcron3[Extension]}"	"${PackageFcron3[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageFcron3[Package]}"	"${PackageFcron3[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildFcron3()
{
	if ! cd "${SHMAN_PDIR}${PackageFcron3[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageFcron3[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageFcron3[Name]}> /etc/syslog.conf"
	if [ "$(grep -c '^cron\.\* -/var/log/cron\.log' /etc/syslog.conf)" -eq 0 ]; then
	cat >> /etc/syslog.conf << "EOF"
# Begin fcron addition to /etc/syslog.conf
cron.* -/var/log/cron.log
# End fcron addition
EOF
	/etc/rc.d/init.d/sysklogd reload
	fi

	EchoInfo	"${PackageFcron3[Name]}> Adding unpriviliged user"
	groupadd -g 22 fcron && \
	useradd -d /dev/null -c "Fcron User" -g fcron -s /bin/false -u 22 fcron

	EchoInfo	"${PackageFcron3[Name]}> Fix documentation"
	find doc -type f -exec sed -i 's:/usr/local::g' {} \;

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageFcron3[Package]}/build \
	# 				|| { EchoError "${PackageFcron3[Name]}> Failed to enter ${SHMAN_PDIR}${PackageFcron3[Package]}/build"; return 1; }

	EchoInfo	"${PackageFcron3[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--localstatedir=/var \
				--without-sendmail \
				--with-boot-install=no \
				--with-systemdsystemunitdir=no 1> /dev/null || { EchoTest KO ${PackageFcron3[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFcron3[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageFcron3[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFcron3[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageFcron3[Name]} && PressAnyKeyToContinue; return 1; };
}

_ConfigureFcron3()
{
	EchoInfo	"${PackageFcron3[Name]}> /usr/bin/run-parts"
	cat > /usr/bin/run-parts << "EOF" &&
#!/bin/sh
# run-parts:  Runs all the scripts found in a directory.
# from Slackware, by Patrick J. Volkerding with ideas borrowed
# from the Red Hat and Debian versions of this utility.

# keep going when something fails
set +e

if [ $# -lt 1 ]; then
  echo "Usage: run-parts <directory>"
  exit 1
fi

if [ ! -d $1 ]; then
  echo "Not a directory: $1"
  echo "Usage: run-parts <directory>"
  exit 1
fi

# There are several types of files that we would like to
# ignore automatically, as they are likely to be backups
# of other scripts:
IGNORE_SUFFIXES="~ ^ , .bak .new .rpmsave .rpmorig .rpmnew .swp"

# Main loop:
for SCRIPT in $1/* ; do
  # If this is not a regular file, skip it:
  if [ ! -f $SCRIPT ]; then
    continue
  fi
  # Determine if this file should be skipped by suffix:
  SKIP=false
  for SUFFIX in $IGNORE_SUFFIXES ; do
    if [ ! "$(basename $SCRIPT $SUFFIX)" = "$(basename $SCRIPT)" ]; then
      SKIP=true
      break
    fi
  done
  if [ "$SKIP" = "true" ]; then
    continue
  fi
  # If we've made it this far, then run the script if it's executable:
  if [ -x $SCRIPT ]; then
    $SCRIPT || echo "$SCRIPT failed."
  fi
done

exit 0
EOF
	chmod -v 755 /usr/bin/run-parts

	EchoInfo	"${PackageFcron3[Name]}> install /etc/cron.{hourly,daily,weekly,monthly}"
	install -vdm754 /etc/cron.{hourly,daily,weekly,monthly}

	EchoInfo	"${PackageFcron3[Name]}> /var/spool/fcron/systab.orig"
	cat > /var/spool/fcron/systab.orig << "EOF"
&bootrun 01 * * * * root run-parts /etc/cron.hourly
&bootrun 02 4 * * * root run-parts /etc/cron.daily
&bootrun 22 4 * * 0 root run-parts /etc/cron.weekly
&bootrun 42 4 1 * * root run-parts /etc/cron.monthly
EOF

	source ${SHMAN_SDIR}/_BLFSBootscripts.sh && BootScriptFcron;

	EchoInfo	"${PackageFcron3[Name]}> start fcron"
	/etc/rc.d/init.d/fcron start && fcrontab -z -u systab
}
