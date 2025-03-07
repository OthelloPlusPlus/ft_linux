#! /bin/bash

history -c

source Utils.sh

# EchoError()
# {
# 	echo -e	"[${C_RED}ERR${C_RESET} ]  $1" >&2;
# 	PressAnyKeyToContinue;
# 	exit;
# }

# EchoInfo()
# {
# 	echo -e	"[${C_CYAN}INFO${C_RESET}]$1";
# }

# EchoTest()
# {
# 	if [ "$1" = OK ]; then
# 		echo -e	"[${C_GREEN} OK ${C_RESET}] $2";
# 	elif [ "$1" = KO ]; then
# 		echo -e	"[${C_RED} KO ${C_RESET}] $2";
# 	else
# 		echo -e	"[${C_GRAY}TEST${C_RESET}] $1";
# 	fi
# }

# PressAnyKeyToContinue()
# {
# 	if [ -t 0 ]; then echo 'Press any key to continue...'; stty -echo -icanon; input=$(dd bs=1 count=1 2>/dev/null); stty sane;
# 	else echo "Press Enter/Return to continue..."; read -n 1 input;
# 	fi
# }

# =====================================||===================================== #
#																			   #
#								7.7 - 7.12 Packages							   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

PDIR="/sources/lfs-packages12.2/";

InstallChrootPackages()
{
	InstallGettext;
	InstallBison;
	InstallPerl;
	InstallPython;
	InstallTexinfo;
	InstallUtilLinux;
}

ExtractPackage()
{
	tar -xf "${PDIR}${1}" -C "${PDIR}";
}

VerifyPackages()
{
	SCREENWIDTH=$(tput cols);
	WORDWIDTH=$(echo "util-linux:" | wc -c);
	CURRENT=0;

	# IsInstalled	"gettext";
	printf	"%-${WORDWIDTH}s"	"gettext:";
	IsInstalled	"msgfmt";
	IsInstalled	"msgmerge";
	IsInstalled	"xgettext";
	echo;
	CURRENT=0;

	IsInstalled	"bison";
	IsInstalled	"perl";
	IsInstalled	"python3";
	IsInstalled	"texinfo";
	echo;
	CURRENT=0;

	# IsInstalled	"util-linux";
	printf	"%-${WORDWIDTH}s"	"util-linux:";
	IsInstalled	"hwclock";
	IsInstalled	"lsblk";
	IsInstalled	"fdisk";
	echo;
}

IsInstalled()
{
	# printf	"Testing %-50s"	"$1 ...";
	if [[ $(echo "$1" | wc -c) -gt $WORDWIDTH ]]; then
		WORDWIDTH=$(echo "$1" | wc -c);
	fi

	# TOTAL=$((TOTAL+1));
	if test "$(whereis $1)" = "$1:"; then
		printf	"${C_RED}%-${WORDWIDTH}s${C_RESET}"	"$1" >&2;
	else
		# SUCCESS=$((SUCCESS+1));
		printf	"${C_GREEN}%-${WORDWIDTH}s${C_RESET}"	"$1";
	fi

	CURRENT=$((CURRENT+WORDWIDTH));
	if [[ $((CURRENT+WORDWIDTH)) -gt $SCREENWIDTH ]]; then
		echo;
		CURRENT=0;
	fi
}

# gettext
InstallGettext()
{
	EchoInfo "# gettext"
	PACKAGE="gettext";
	VERSION="0.22.5";
	EXTENSION=".tar.xz";

	ExtractPackage "${PACKAGE}-${VERSION}${EXTENSION}";
	cd "${PDIR}${PACKAGE}-${VERSION}";

	./configure --disable-shared 1> /dev/null || { EchoError "Configure ${PACKAGE}" >&2; PressAnyKeyToContinue; };
	make 1> /dev/null || { EchoError "make ${PACKAGE}" >&2; PressAnyKeyToContinue; };
	cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

	cd -;
	rm -rf "${PDIR}${PACKAGE}-${VERSION}"
}

# bison
InstallBison()
{
	EchoInfo "# bison"
	PACKAGE="bison";
	VERSION="3.8.2";
	EXTENSION=".tar.xz";

	ExtractPackage "${PACKAGE}-${VERSION}${EXTENSION}";
	cd "${PDIR}${PACKAGE}-${VERSION}";

	./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2 || { EchoError "Configure ${PACKAGE}" >&2; PressAnyKeyToContinue; };
	make || { EchoError "make ${PACKAGE}" >&2; PressAnyKeyToContinue; };
	make install || { EchoError "make install ${PACKAGE}" >&2; PressAnyKeyToContinue; };
	bison --version


	cd -;
	rm -rf "${PDIR}${PACKAGE}-${VERSION}"
}

# perl
InstallPerl()
{
	EchoInfo "# perl"
	PACKAGE="perl";
	VERSION="5.40.0";
	EXTENSION=".tar.xz";

	ExtractPackage "${PACKAGE}-${VERSION}${EXTENSION}";
	cd "${PDIR}${PACKAGE}-${VERSION}";

	sh Configure -des -D prefix=/usr -D vendorprefix=/usr -D useshrplib -D privlib=/usr/lib/perl5/5.40/core_perl -D archlib=/usr/lib/perl5/5.40/core_perl -D sitelib=/usr/lib/perl5/5.40/site_perl -D sitearch=/usr/lib/perl5/5.40/site_perl -D vendorlib=/usr/lib/perl5/5.40/vendor_perl -D vendorarch=/usr/lib/perl5/5.40/vendor_perl || { EchoError "Configure ${PACKAGE}" >&2; PressAnyKeyToContinue; };
	make || { EchoError "make ${PACKAGE}" >&2; PressAnyKeyToContinue; };
	make install || { EchoError "make install ${PACKAGE}" >&2; PressAnyKeyToContinue; };

	cd -;
	rm -rf "${PDIR}${PACKAGE}-${VERSION}"
}

# python
InstallPython()
{
	EchoInfo "# python"
	PACKAGE="Python";
	VERSION="3.12.5";
	EXTENSION=".tar.xz";

	ExtractPackage "${PACKAGE}-${VERSION}${EXTENSION}";
	cd "${PDIR}${PACKAGE}-${VERSION}";

	./configure --prefix=/usr --enable-shared --without-ensurepip || { EchoError "Configure ${PACKAGE}" >&2; PressAnyKeyToContinue; };
	make || { EchoError "make ${PACKAGE}" >&2; PressAnyKeyToContinue; };
	make install || { EchoError "make install ${PACKAGE}" >&2; PressAnyKeyToContinue; };

	cd -;
	rm -rf "${PDIR}${PACKAGE}-${VERSION}"
}

# texinfo
InstallTexinfo()
{
	EchoInfo "# texinfo"
	PACKAGE="texinfo";
	VERSION="7.1";
	EXTENSION=".tar.xz";

	ExtractPackage "${PACKAGE}-${VERSION}${EXTENSION}";
	cd "${PDIR}${PACKAGE}-${VERSION}";

	./configure --prefix=/usr || { EchoError "Configure ${PACKAGE}" >&2; PressAnyKeyToContinue; };
	make || { EchoError "make ${PACKAGE}" >&2; PressAnyKeyToContinue; };
	make install || { EchoError "make install ${PACKAGE}" >&2; PressAnyKeyToContinue; };

	cd -;
	rm -rf "${PDIR}${PACKAGE}-${VERSION}"
}

# util-linux
InstallUtilLinux()
{
	EchoInfo "# util-linux"
	PACKAGE="util-linux";
	VERSION="2.40.2";
	EXTENSION=".tar.xz";

	ExtractPackage "${PACKAGE}-${VERSION}${EXTENSION}";
	cd "${PDIR}${PACKAGE}-${VERSION}";

	mkdir -pv /var/lib/hwclock
	./configure --libdir=/usr/lib --runstatedir=/run --disable-chfn-chsh --disable-login --disable-nologin --disable-su --disable-setpriv --disable-runuser --disable-pylibmount --disable-static --disable-liblastlog2 --without-python ADJTIME_PATH=/var/lib/hwclock/adjtime --docdir=/usr/share/doc/util-linux-2.40.2 || { EchoError "Configure ${PACKAGE}"; PressAnyKeyToContinue; };
	make || { EchoError "make ${PACKAGE}" >&2; PressAnyKeyToContinue; };
	make install || { EchoError "make install ${PACKAGE}" >&2; PressAnyKeyToContinue; };

	cd -;
	rm -rf "${PDIR}${PACKAGE}-${VERSION}"
}

# =====================================||===================================== #
#																			   #
#									7.13 Cleanup							   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #


CleanupConfigChroot()
{
	EchoInfo "# 7.13 Cleanup"

	# Remove installed documentation files
	EchoInfo "# Remove installed documentation files"
	rm -rf /usr/share/{info,man,doc}/*;

	# Remove libtool .la files
	EchoInfo "# Remove libtool .la files"
	find /usr/{lib,libexec} -name \*.la -delete

	# Remove /tools
	EchoInfo "# Remove /tools"
	rm -rf /tools
}

# =====================================||===================================== #
#																			   #
#									  Run									   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

InstallChrootPackages;
CleanupConfigChroot;
VerifyPackages;

# colors=$(tput colors 2>/dev/null || echo 0)
