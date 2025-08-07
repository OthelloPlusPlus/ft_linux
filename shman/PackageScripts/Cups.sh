#!/bin/bash

if [ ! -z "${PackageCups[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Cups								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageCups;
# Manual
PackageCups[Source]="https://github.com/OpenPrinting/cups/releases/download/v2.4.11/cups-2.4.11-source.tar.gz";
PackageCups[MD5]="922ef8d3d40e5bf654277ee3d0ae3eba";
# Automated unless edgecase
PackageCups[Name]="";
PackageCups[Version]=""2.4.11;
PackageCups[Extension]=".tar.gz";
if [[ -n "${PackageCups[Source]}" ]]; then
	filename="${PackageCups[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageCups[Name]}" ]] && PackageCups[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageCups[Version]}" ]] && PackageCups[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageCups[Extension]}" ]] && PackageCups[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageCups[Package]="${PackageCups[Name]}-${PackageCups[Version]}";

PackageCups[Programs]="cancel cupsaccept cups-config cupsctl cupsd cupsdisable cupsenable cupsfilter cupsreject cupstestppd ippeveprinter ippfind ipptool lp lpadmin lpc lpinfo lpmove lpoptions lpq lpr lprm lpstat ppdc ppdhtml ppdi ppdmerge ppdpo";
PackageCups[Libraries]="libcupsimage.so libcups.so";
PackageCups[Python]="";

InstallCups()
{
	# Check Installation
	CheckCups && return $?;

	# Check Dependencies
	EchoInfo	"${PackageCups[Name]}> Checking dependencies..."
	Required=(GnuTLS)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageCups[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(Colord Dbus LibUsb LinuxPAM XdgUtils)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageCups[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Avahi LibPaper MITKerberos PHP)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageCups[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageCups[Name]}> Building package..."
	_ExtractPackageCups || return $?;
	_BuildCups || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageCups[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckCups()
{
	return 1;
	CheckInstallation 	"${PackageCups[Programs]}"\
						"${PackageCups[Libraries]}"\
						"${PackageCups[Python]}" 1> /dev/null;
	return $?;
}

CheckCupsVerbose()
{
	EchoWarning	"Unfinished work" >&2;
	return 1;
	CheckInstallationVerbose	"${PackageCups[Programs]}"\
								"${PackageCups[Libraries]}"\
								"${PackageCups[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageCups()
{
	DownloadPackage	"${PackageCups[Source]}"	"${SHMAN_PDIR}"	"${PackageCups[Package]}-source${PackageCups[Extension]}"	"${PackageCups[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageCups[Package]}-source"	"${PackageCups[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildCups()
{
	if ! cd "${SHMAN_PDIR}${PackageCups[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageCups[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageCups[Name]}> Add user lp"
	useradd -c "Print Service User" -d /var/spool/cups -g lp -s /bin/false -u 9 lp
	groupadd -g 19 lpadmin
	# usermod -a -G lpadmin <username>

	sed -i 's#@CUPS_HTMLVIEW@#firefox#' desktop/cups.desktop.in

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageCups[Package]}/build \
	# 				|| { EchoError "${PackageCups[Name]}> Failed to enter ${SHMAN_PDIR}${PackageCups[Package]}/build"; return 1; }

	EchoInfo	"${PackageCups[Name]}> Configure"
	./configure --libdir=/usr/lib \
				--with-rcdir=/tmp/cupsinit \
				--with-rundir=/run/cups \
				--with-system-groups=lpadmin \
				--with-docdir=/usr/share/cups/doc-2.4.11 \
				1> /dev/null || { EchoTest KO ${PackageCups[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCups[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageCups[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageCups[Name]}> make check"
	# make check 1> /dev/null || { EchoTest KO ${PackageCups[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCups[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageCups[Name]} && PressAnyKeyToContinue; return 1; };

	ln -svnf ../cups/doc-2.4.11 /usr/share/doc/cups-2.4.11
	rm -rf /tmp/cupsinit
	echo "ServerName /run/cups/cups.sock" > /etc/cups/client.conf

	gtk-update-icon-cache -qtf /usr/share/icons/hicolor
}

_ConfigureCups()
{
	EchoInfo	"${PackageCups[Name]}> /etc/pam.d/cups"
	cat > /etc/pam.d/cups << "EOF"
# Begin /etc/pam.d/cups

auth    include system-auth
account include system-account
session include system-session

# End /etc/pam.d/cups
EOF

	EchoWarning	"${PackageCups[Name]}> Bootscript not implmented"
	# make install-cups
}
