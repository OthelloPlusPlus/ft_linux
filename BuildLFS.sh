#! /bin/bash

PDIR=/sources/lfs-packages12.2/

source colors.sh

# =====================================||===================================== #
#																			   #
#							Building System Software						   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

ReExtractPackage()
{
	local SRC="${1}${2}${3}";
	local DST="${1}";
	local RSLT="${1}${2}";

	if [ ! -f "$SRC" ] || [ ! -d "$DST" ]; then
		EchoError	"ReExtractPackage SRC[$SRC] DST[$DST]";
		# return false;
		return 1;
	fi

	if [ -d "$RSLT" ]; then
		rm -rf "$RSLT";
	fi

	tar -xf "$SRC" -C "$DST";
}

# =====================================||===================================== #
#																			   #
#									 Utils									   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

EchoError()
{
	echo -e	"[${C_RED}ERR${C_RESET} ]  $1"	>&2;
}

EchoInfo()
{
	echo -e	"[${C_CYAN}INFO${C_RESET}]$1";
}

EchoTest()
{
	if [ "$1" = OK ]; then
		echo -e	"[${C_GREEN} OK ${C_RESET}] $2";
	elif [ "$1" = KO ]; then
		echo -e	"[${C_RED} KO ${C_RESET}] $2";
	else
		echo -e	"[${C_GRAY}TEST${C_RESET}] $1";
	fi
}

PressAnyKeyToContinue()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	if [ -t 0 ]; then
		echo	"Press any key to continue...";
		stty -echo -icanon
		input=$(dd bs=1 count=1 2>/dev/null)
		stty sane
	else
		echo	"Press Enter/Return to continue...";
		read -n 1 input;
	fi
	printf '%*s\n' "$width" '' | tr ' ' '-';
}

GetInput()
{
	echo	"$MSG";
	echo -n	"Choose an option: ";
	unset MSG;
	read	input;
	printf '%*s\n' "$width" '' | tr ' ' '-';
}

GetKeyPress()
{
    read -rsn 1 input
	if [[ "$input" == $'\e' ]]; then
		read -rsn 2 -t 0.1 input
		input=$'\e'"$input"
	fi
}

# =====================================||===================================== #
#																			   #
#									Packages								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

# =====================================||===================================== #
#									Temp									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A Packagetemp;
Packagetemp[Name]="Temp";
Packagetemp[Version]="";
Packagetemp[Extension]=".tar.xz";
Packagetemp[Package]="${Packagetemp[Name]}-${Packagetemp[Version]}${Packagetemp[Extension]}";

InstallTemp()
{
	EchoInfo	"Package ${Packagetemp[Name]}"

	ReExtractPackage	"${PDIR}"	"${Packagetemp[Name]}-${Packagetemp[Version]}"	"${Packagetemp[Extension]}";

	if ! cd "${PDIR}${Packagetemp[Name]}-${Packagetemp[Version]}"; then
		EchoError	"cd ${PDIR}${Packagetemp[Name]}-${Packagetemp[Version]}";
		return;
	fi

	EchoInfo	"${Packagetemp[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${Packagetemp[Name]}> make"
	make  1> /dev/null || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${Packagetemp[Name]}> make check"
	make check 1> /dev/null || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${Packagetemp[Name]}> make install"
	make install 1> /dev/null && Packagetemp[Status]=$? || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return; };

	if ! mkdir -v build; then
		Packagetemp[Status]=1; 
		EchoError	"Failed to make ${PDIR}${Packagetemp[Name]}/build";
		cd -;
		return ;
	fi
	cd -;
	cd "${PDIR}${Packagetemp[Name]}-${Packagetemp[Version]}/build";

	cd -;
}

# =====================================||===================================== #
#									  Man									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMan;
PackageMan[Name]="man-pages";
PackageMan[Version]="6.9.1";
PackageMan[Extension]=".tar.xz";
PackageMan[Package]="${PackageMan[Name]}-${PackageMan[Version]}${PackageMan[Extension]}";

InstallMan()
{
	ReExtractPackage	"${PDIR}"	"${PackageMan[Name]}-${PackageMan[Version]}"	"${PackageMan[Extension]}";

	if ! cd "${PDIR}${PackageMan[Name]}-${PackageMan[Version]}"; then
		PackageMan[Status]=1;
		EchoError	"cd ${PDIR}${PackageMan[Name]}-${PackageMan[Version]}";
		return;
	fi

	# Remove two man pages for password hashing functions
	rm -v man3/crypt*

	EchoInfo	"${PackageMan[Name]}> make prefix=/usr install"
	make prefix=/usr install	1> /dev/null;
	PackageMan[Status]=$?;

	cd -;
}

# =====================================||===================================== #
#									Iana-Etc								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageIanaEtc;
PackageIanaEtc[Name]="iana-etc";
PackageIanaEtc[Version]="20240806";
PackageIanaEtc[Extension]=".tar.gz";
PackageIanaEtc[Package]="${PackageIanaEtc[Name]}-${PackageIanaEtc[Version]}${PackageIanaEtc[Extension]}";

InstallIanaEtc()
{
	EchoInfo	"Package ${PackageIanaEtc[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageIanaEtc[Name]}-${PackageIanaEtc[Version]}"	"${PackageIanaEtc[Extension]}";

	if ! cd "${PDIR}${PackageIanaEtc[Name]}-${PackageIanaEtc[Version]}"; then
		PackageIanaEtc[Status]=1;
		EchoError	"cd ${PDIR}${PackageIanaEtc[Name]}-${PackageIanaEtc[Version]}";
		return;
	fi

	EchoInfo	"${PackageIanaEtc[Name]}> cp services protocols /etc"
	cp services protocols /etc	1> /dev/null;
	PackageIanaEtc[Status]=$?;

	cd -;
}

# =====================================||===================================== #
#									Glibc									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGlibc;
PackageGlibc[Name]="glibc";
PackageGlibc[Version]="2.40";
PackageGlibc[Extension]=".tar.xz";
PackageGlibc[Package]="${PackageGlibc[Name]}-${PackageGlibc[Version]}${PackageGlibc[Extension]}";

InstallGlibc()
{
	# local NAME="glibc";
	# local VERSION="2.40";
	# local EXTENSION=".tar.xz";
	# local PACKAGE="${NAME}-${VERSION}${EXTENSION}";

	EchoInfo	"Package ${PackageGlibc[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGlibc[Name]}-${PackageGlibc[Version]}"	"${PackageGlibc[Extension]}";

	if ! cd "${PDIR}${PackageGlibc[Name]}-${PackageGlibc[Version]}"; then
		EchoError	"cd ${PDIR}${PackageGlibc[Name]}-${PackageGlibc[Version]}";
		return;
	fi

	EchoInfo	"${PackageGlibc[Name]} patching..."
	patch -Np1 -i ../glibc-2.40-fhs-1.patch

	if ! mkdir -v build; then
		PackageGlibc[Status]=1;
		EchoError	"Failed to make ${PDIR}${PackageGlibc[Name]}/build";
		cd -;
		return ;
	fi
	cd -;
	cd "${PDIR}${PackageGlibc[Name]}-${PackageGlibc[Version]}/build";

	InstallGlibcInstall;
	InstallGlibcConfigure;

	cd -;
}

InstallGlibcInstall()
{
	# Ensure that the ldconfig and sln utilities will be installed into /usr/sbin
	echo "rootsbindir=/usr/sbin" > configparms

	EchoInfo	"${PackageGlibc[Name]}> configure"
	../configure	--prefix=/usr	\
					--disable-werror	\
					--enable-kernel=4.19	\
					--enable-stack-protector=strong	\
					--disable-nscd	\
					libc_cv_slibdir=/usr/lib	\
					1> /dev/null

	EchoInfo	"${PackageGlibc[Name]}> Compile"
	time make 1> /dev/null || { EchoTest KO ${PackageGlibc[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGlibc[Name]}> Check"
	make test t=nptl/tst-thread_local1.o || { EchoError "$?"; PressAnyKeyToContinue; };
	make check 1> /dev/null || { EchoError "Check the errors. Ctrl+C if crucial! ($?)"; }; EchoInfo "Check the test or ctrl C!"; PressAnyKeyToContinue; 

	# Prevent harmless warning
	touch /etc/ld.so.conf

	# Fix the Makefile to skip an outdated sanity check that fails with a modern Glibc configuration
	sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

	EchoInfo	"${PackageGlibc[Name]}> Install"
	time make 1> /dev/null || { PackageGlibc[Status]=$?; EchoTest KO ${PackageGlibc[Name]} && PressAnyKeyToContinue; return; };

	# Fix a hardcoded path to the executable loader in the ldd script
	sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd;

	# Installing locales using the localedef program
	if true; then
		EchoInfo	"${PackageGlibc[Name]}> Installing all locales"
		make localedata/install-locales;
		PackageGlibc=$?;
		# Locales missing from make
		localedef -i C -f UTF-8 C.UTF-8
		localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
	else
		# Installing individual locales
		EchoInfo	"${PackageGlibc[Name]}> Installing individual Locales"
		localedef -i C -f UTF-8 C.UTF-8
		localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
		localedef -i de_DE -f ISO-8859-1 de_DE
		localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
		localedef -i de_DE -f UTF-8 de_DE.UTF-8
		localedef -i el_GR -f ISO-8859-7 el_GR
		localedef -i en_GB -f ISO-8859-1 en_GB
		localedef -i en_GB -f UTF-8 en_GB.UTF-8
		localedef -i en_HK -f ISO-8859-1 en_HK
		localedef -i en_PH -f ISO-8859-1 en_PH
		localedef -i en_US -f ISO-8859-1 en_US
		localedef -i en_US -f UTF-8 en_US.UTF-8
		localedef -i es_ES -f ISO-8859-15 es_ES@euro
		localedef -i es_MX -f ISO-8859-1 es_MX
		localedef -i fa_IR -f UTF-8 fa_IR
		localedef -i fr_FR -f ISO-8859-1 fr_FR
		localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
		localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
		localedef -i is_IS -f ISO-8859-1 is_IS
		localedef -i is_IS -f UTF-8 is_IS.UTF-8
		localedef -i it_IT -f ISO-8859-1 it_IT
		localedef -i it_IT -f ISO-8859-15 it_IT@euro
		localedef -i it_IT -f UTF-8 it_IT.UTF-8
		localedef -i ja_JP -f EUC-JP ja_JP
		localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
		localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
		localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
		localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
		localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
		localedef -i se_NO -f UTF-8 se_NO.UTF-8
		localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
		localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
		localedef -i zh_CN -f GB18030 zh_CN.GB18030
		localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
		localedef -i zh_TW -f UTF-8 zh_TW.UTF-8
	fi
}

InstallGlibcConfigure()
{
# Adding nsswitch.conf
cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf
passwd: files
group: files
shadow: files
hosts: files dns
networks: files
protocols: files
services: files
ethers: files
rpc: files
# End /etc/nsswitch.conf
EOF

	# Adding Time Zone Data
	tar -xf ../../tzdata2024a.tar.gz

	ZONEINFO=/usr/share/zoneinfo
	mkdir -pv $ZONEINFO/{posix,right}

	for tz in etcetera southamerica northamerica europe africa antarctica asia australasia backward; do
		zic -L /dev/null	-d $ZONEINFO		${tz}
		zic -L /dev/null	-d $ZONEINFO/posix	${tz}
		zic -L leapseconds	-d $ZONEINFO/right	${tz}
	done

	cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
	zic -d $ZONEINFO -p America/New_York
	unset ZONEINFO

	PressAnyKeyToContinue;
	EchoError	"Timezoneneeds to be configured!"
	# tzselect
	# ln -sfv /usr/share/zoneinfo/<xxx> /etc/localtime

	# Configuring the Dynamic Loader
cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf
EOF
mkdir -pv /etc/ld.so.conf.d
}

# =====================================||===================================== #
#									Zlib									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageZlib;
PackageZlib[Name]="zlib";
PackageZlib[Version]="1.3.1";
PackageZlib[Extension]=".tar.gz";
PackageZlib[Package]="${PackageZlib[Name]}-${PackageZlib[Version]}${PackageZlib[Extension]}";

InstallZlib()
{
	# local NAME="zlib";
	# local VERSION="1.3.1";
	# local EXTENSION=".tar.gz";
	# local PACKAGE="${NAME}-${VERSION}${EXTENSION}";

	EchoInfo	"Package ${PackageZlib[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageZlib[Name]}-${PackageZlib[Version]}"	"${PackageZlib[Extension]}";

	if ! cd "${PDIR}${PackageZlib[Name]}-${PackageZlib[Version]}"; then
		EchoError	"cd ${PDIR}${PackageZlib[Name]}-${PackageZlib[Version]}";
		return;
	fi
	
	EchoInfo	"${PackageZlib[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { PackageZlib[Status]=$?; EchoTest KO ${PackageZlib[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageZlib[Name]}> make"
	make  1> /dev/null || { PackageZlib[Status]=$?; EchoTest KO ${PackageZlib[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageZlib[Name]}> make check"
	make check 1> /dev/null || { PackageZlib[Status]=$?; EchoTest KO ${PackageZlib[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageZlib[Name]}> make install"
	make install 1> /dev/null && PackageZlib[Status]=$? || { PackageZlib[Status]=$?; EchoTest KO ${PackageZlib[Name]} && PressAnyKeyToContinue; return; };
	
	# Remove a useless static lbrary
	rm -fv /usr/lib/libz.a

	cd -;
}

# =====================================||===================================== #
#									Bzip2									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageBzip2;
PackageBzip2[Name]="bzip2";
PackageBzip2[Version]="1.0.8";
PackageBzip2[Extension]=".tar.gz";
PackageBzip2[Package]="${PackageBzip2[Name]}-${PackageBzip2[Version]}${PackageBzip2[Extension]}";

InstallBzip2()
{
	# local NAME="Bzip2";
	# local VERSION="";
	# local EXTENSION=".tar.xz";
	# local PACKAGE="${NAME}-${VERSION}${EXTENSION}";

	EchoInfo	"Package ${PackageBzip2[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBzip2[Name]}-${PackageBzip2[Version]}"	"${PackageBzip2[Extension]}";

	if ! cd "${PDIR}${PackageBzip2[Name]}-${PackageBzip2[Version]}"; then
		EchoError	"cd ${PDIR}${PackageBzip2[Name]}-${PackageBzip2[Version]}";
		return;
	fi

	EchoInfo	"${PackageBzip2[Name]}> Patch"
	patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch

	EchoInfo	"${PackageBzip2[Name]}> sed Makefile"
	sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
	sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

	EchoInfo	"${PackageBzip2[Name]}> prepare make"
	make -f Makefile-libbz2_so 1> /dev/null || { PackageBzip2[Status]=$?; EchoTest KO ${PackageBzip2[Name]} && PressAnyKeyToContinue; return; };
	make clean 1> /dev/null || { PackageBzip2[Status]=$?; EchoTest KO ${PackageBzip2[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBzip2[Name]}> make"
	make  1> /dev/null || { PackageBzip2[Status]=$?; EchoTest KO ${PackageBzip2[Name]} && PressAnyKeyToContinue; return; };

	# EchoInfo	"${PackageBzip2[Name]}> make check"
	# make check 1> /dev/null || { PackageBzip2[Status]=$?; EchoTest KO ${PackageBzip2[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageBzip2[Name]}> make PREFIX=/usr install"
	make PREFIX=/usr install 1> /dev/null && PackageBzip2[Status]=$? || { PackageBzip2[Status]=$?; EchoTest KO ${PackageBzip2[Name]} && PressAnyKeyToContinue; return; };

	# Install shared library
	cp -av libbz2.so.* /usr/lib
	ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so
	# Install shared bzip binary
	cp -v bzip2-shared /usr/bin/bzip2
	for i in /usr/bin/{bzcat,bunzip2}; do
		ln -sfv bzip2 $i
	done

	# Remove useless static library
	rm -fv /usr/lib/libbz2.a

	cd -;
}

# =====================================||===================================== #
#																			   #
#									  Menu									   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

PrintMenu()
{
	clear ;
	
	PrintMenuLine	"${PackageMan[Name]}-${PackageMan[Version]}"	$MenuIndex	0	"${PackageMan[Status]}";
	PrintMenuLine	"${PackageIanaEtc[Name]}-${PackageIanaEtc[Version]}"	$MenuIndex	1	"${PackageIanaEtc[Status]}";
	PrintMenuLine	"${PackageGlibc[Name]}-${PackageGlibc[Version]}"	$MenuIndex	2	"${PackageGlibc[Status]}";
	PrintMenuLine	"${PackageZlib[Name]}-${PackageZlib[Version]}"	$MenuIndex	3	"${PackageZlib[Status]}";
	PrintMenuLine	"${PackageBzip2[Name]}-${PackageBzip2[Version]}"	$MenuIndex	4	"${PackageBzip2[Status]}";
	PrintMenuLine	"Quit"	$MenuIndex	5;

	GetKeyPress;
	case "$input" in
		$'\e[A')	((--MenuIndex));;
		$'\e[B')	((++MenuIndex));;
		"")	case $MenuIndex in
				0)	InstallMan;;
				1)	InstallIanaEtc;;
				2)	InstallGlibc;;
				3)	InstallZlib;;
				4)	InstallBzip2;;
				5)	break ;;
			esac;
			PressAnyKeyToContinue;;
	esac

	MenuIndex=$(( MenuIndex % 6 ));
	if [ $MenuIndex -lt 0 ]; then
		MenuIndex=5;
	fi	
}

PrintMenuLine()
{
	if [ ! -z "$4" ] ; then
		if [ "$4" -eq 0 ]; then
			echo -ne	"${C_GREEN}";
		elif [ "$4" -gt 0 ]; then
			echo -ne	"${C_RED}";
		fi
	fi

	if [ "$2" = "$3" ]; then
		echo -ne	"${CB_LGRAY}";
	fi

	printf	" %-18s${C_RESET}\n"	"$1";
}

MenuIndex=0;
while true; do
	PrintMenu;
done
