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

	if ! mkdir -p build; then
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

	if ! mkdir -p build; then
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
					1> /dev/null || { PackageGlibc[Status]=$?; EchoError "Issues with glibc configure"; PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGlibc[Name]}> Compile"
	make 1> /dev/null || { PackageGlibc[Status]=$?; EchoTest KO ${PackageGlibc[Name]}; PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGlibc[Name]}> Check"
	# make test t=nptl/tst-thread_local1.o || { EchoError "$?"; PressAnyKeyToContinue; };
	make check 1> /dev/null || { EchoError "Check the errors. Ctrl+C if crucial! ($?)"; }; EchoInfo "Check the test or ctrl C!"; PressAnyKeyToContinue; 

	# Prevent harmless warning
	touch /etc/ld.so.conf

	# Fix the Makefile to skip an outdated sanity check that fails with a modern Glibc configuration
	sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

	EchoInfo	"${PackageGlibc[Name]}> Install"
	make install 1> /dev/null && PackageGlibc[Status]=$? || { PackageGlibc[Status]=$?; EchoTest KO ${PackageGlibc[Name]}; PressAnyKeyToContinue; return; };

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

	# tzselect
	TZ='Europe/Brussels';
	ln -sfv /usr/share/zoneinfo/${TZ} /etc/localtime

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
#									   Xz									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXz;
PackageXz[Name]="xz";
PackageXz[Version]="5.6.2";
PackageXz[Extension]=".tar.xz";
PackageXz[Package]="${PackageXz[Name]}-${PackageXz[Version]}${PackageXz[Extension]}";

InstallXz()
{
	EchoInfo	"Package ${PackageXz[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageXz[Name]}-${PackageXz[Version]}"	"${PackageXz[Extension]}";

	if ! cd "${PDIR}${PackageXz[Name]}-${PackageXz[Version]}"; then
		EchoError	"cd ${PDIR}${PackageXz[Name]}-${PackageXz[Version]}";
		return;
	fi

	EchoInfo	"${PackageXz[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--docdir=/usr/share/doc/xz-5.6.2 \
				1> /dev/null || { EchoTest KO ${PackageXz[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageXz[Name]}> make"
	make  1> /dev/null || { PackageXz[Status]=$?; EchoTest KO ${PackageXz[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageXz[Name]}> make check"
	make check 1> /dev/null || { PackageXz[Status]=$?; EchoTest KO ${PackageXz[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageXz[Name]}> make install"
	make install 1> /dev/null && PackageXz[Status]=$? || { PackageXz[Status]=$?; EchoTest KO ${PackageXz[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									  Lz4									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLz4;
PackageLz4[Name]="lz4";
PackageLz4[Version]="1.10.0";
PackageLz4[Extension]=".tar.gz";
PackageLz4[Package]="${PackageLz4[Name]}-${PackageLz4[Version]}${PackageLz4[Extension]}";

InstallLz4()
{
	EchoInfo	"Package ${PackageLz4[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLz4[Name]}-${PackageLz4[Version]}"	"${PackageLz4[Extension]}";

	if ! cd "${PDIR}${PackageLz4[Name]}-${PackageLz4[Version]}"; then
		EchoError	"cd ${PDIR}${PackageLz4[Name]}-${PackageLz4[Version]}";
		return;
	fi

	EchoInfo	"${PackageLz4[Name]}> make BUILD_STATIC=no PREFIX=/usr"
	make BUILD_STATIC=no PREFIX=/usr 1> /dev/null || { PackageLz4[Status]=$?; EchoTest KO ${PackageLz4[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLz4[Name]}> make -j1 check"
	make -j1 check 1> /dev/null || { PackageLz4[Status]=$?; EchoTest KO ${PackageLz4[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageLz4[Name]}> make BUILD_STATIC=no PREFIX=/usr install"
	make BUILD_STATIC=no PREFIX=/usr install 1> /dev/null && PackageLz4[Status]=$? || { PackageLz4[Status]=$?; EchoTest KO ${PackageLz4[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									  Zstd									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageZstd;
PackageZstd[Name]="zstd";
PackageZstd[Version]="1.5.6";
PackageZstd[Extension]=".tar.gz";
PackageZstd[Package]="${PackageZstd[Name]}-${PackageZstd[Version]}${PackageZstd[Extension]}";

InstallZstd()
{
	EchoInfo	"Package ${PackageZstd[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageZstd[Name]}-${PackageZstd[Version]}"	"${PackageZstd[Extension]}";

	if ! cd "${PDIR}${PackageZstd[Name]}-${PackageZstd[Version]}"; then
		EchoError	"cd ${PDIR}${PackageZstd[Name]}-${PackageZstd[Version]}";
		return;
	fi

	EchoInfo	"${PackageZstd[Name]}> make prefix=/usr"
	make prefix=/usr 1> /dev/null || { PackageZstd[Status]=$?; EchoTest KO ${PackageZstd[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageZstd[Name]}> make check"
	make check 1> /dev/null || { PackageZstd[Status]=$?; EchoTest KO ${PackageZstd[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageZstd[Name]}> make prefix=/usr install"
	make prefix=/usr install 1> /dev/null && PackageZstd[Status]=$? || { PackageZstd[Status]=$?; EchoTest KO ${PackageZstd[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageZstd[Name]}> Remove the static library"
	rm -v /usr/lib/libzstd.a

	cd -;
}

# =====================================||===================================== #
#									File									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageFile;
PackageFile[Name]="file";
PackageFile[Version]="5.45";
PackageFile[Extension]=".tar.gz";
PackageFile[Package]="${PackageFile[Name]}-${PackageFile[Version]}${PackageFile[Extension]}";

InstallFile()
{
	EchoInfo	"Package ${PackageFile[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageFile[Name]}-${PackageFile[Version]}"	"${PackageFile[Extension]}";

	if ! cd "${PDIR}${PackageFile[Name]}-${PackageFile[Version]}"; then
		EchoError	"cd ${PDIR}${PackageFile[Name]}-${PackageFile[Version]}";
		return;
	fi

	EchoInfo	"${PackageFile[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageFile[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageFile[Name]}> make"
	make  1> /dev/null || { PackageFile[Status]=$?; EchoTest KO ${PackageFile[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageFile[Name]}> make check"
	make check 1> /dev/null || { PackageFile[Status]=$?; EchoTest KO ${PackageFile[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageFile[Name]}> make install"
	make install 1> /dev/null && PackageFile[Status]=$? || { PackageFile[Status]=$?; EchoTest KO ${PackageFile[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									Readline									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageReadline;
PackageReadline[Name]="readline";
PackageReadline[Version]="8.2.13";
PackageReadline[Extension]=".tar.gz";
PackageReadline[Package]="${PackageReadline[Name]}-${PackageReadline[Version]}${PackageReadline[Extension]}";

InstallReadline()
{
	EchoInfo	"Package ${PackageReadline[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageReadline[Name]}-${PackageReadline[Version]}"	"${PackageReadline[Extension]}";

	if ! cd "${PDIR}${PackageReadline[Name]}-${PackageReadline[Version]}"; then
		EchoError	"cd ${PDIR}${PackageReadline[Name]}-${PackageReadline[Version]}";
		return;
	fi

	EchoInfo	"${PackageReadline[Name]}> Preventing linking bug with ldconfig";
	sed -i '/MV.*old/d' Makefile.in;
	sed -i '/{OLDSUFF}/c:' support/shlib-install;
	EchoInfo	"${PackageReadline[Name]}> Preventing hardcoding search path";
	sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf;

	EchoInfo	"${PackageReadline[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--with-curses \
				--docdir=/usr/share/doc/readline-8.2.13 \
				1> /dev/null || { EchoTest KO ${PackageReadline[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageReadline[Name]}> make SHLIB_LIBS=\"-lncursesw\""
	make SHLIB_LIBS="-lncursesw" 1> /dev/null || { PackageReadline[Status]=$?; EchoTest KO ${PackageReadline[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageReadline[Name]}> make SHLIB_LIBS=\"-lncursesw\" install"
	make SHLIB_LIBS="-lncursesw" install 1> /dev/null && PackageReadline[Status]=$? || { PackageReadline[Status]=$?; EchoTest KO ${PackageReadline[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageReadline[Name]}> Install documentation"
	install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.2.13 1> /dev/null && PackageReadline[Status]=$? || { PackageReadline[Status]=$?; EchoTest KO ${PackageReadline[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									   M4									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageM4;
PackageM4[Name]="m4";
PackageM4[Version]="1.4.19";
PackageM4[Extension]=".tar.xz";
PackageM4[Package]="${PackageM4[Name]}-${PackageM4[Version]}${PackageM4[Extension]}";

InstallM4()
{
	EchoInfo	"Package ${PackageM4[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageM4[Name]}-${PackageM4[Version]}"	"${PackageM4[Extension]}";

	if ! cd "${PDIR}${PackageM4[Name]}-${PackageM4[Version]}"; then
		EchoError	"cd ${PDIR}${PackageM4[Name]}-${PackageM4[Version]}";
		return;
	fi

	EchoInfo	"${PackageM4[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageM4[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageM4[Name]}> make"
	make  1> /dev/null || { PackageM4[Status]=$?; EchoTest KO ${PackageM4[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageM4[Name]}> make check"
	make check 1> /dev/null || { PackageM4[Status]=$?; EchoTest KO ${PackageM4[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageM4[Name]}> make install"
	make install 1> /dev/null && PackageM4[Status]=$? || { PackageM4[Status]=$?; EchoTest KO ${PackageM4[Name]} && PressAnyKeyToContinue; return; };
	
	cd -;
}

# =====================================||===================================== #
#									   Bc									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageBc;
PackageBc[Name]="bc";
PackageBc[Version]="6.7.6";
PackageBc[Extension]=".tar.xz";
PackageBc[Package]="${PackageBc[Name]}-${PackageBc[Version]}${PackageBc[Extension]}";

InstallBc()
{
	EchoInfo	"Package ${PackageBc[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBc[Name]}-${PackageBc[Version]}"	"${PackageBc[Extension]}";

	if ! cd "${PDIR}${PackageBc[Name]}-${PackageBc[Version]}"; then
		EchoError	"cd ${PDIR}${PackageBc[Name]}-${PackageBc[Version]}";
		return;
	fi

	EchoInfo	"${PackageBc[Name]}> CC=gcc ./configure --prefix=/usr -G -O3 -r"
	CC=gcc ./configure --prefix=/usr -G -O3 -r 1> /dev/null || { EchoTest KO ${PackageBc[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBc[Name]}> make"
	make  1> /dev/null || { PackageBc[Status]=$?; EchoTest KO ${PackageBc[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBc[Name]}> make test"
	make test 1> /dev/null || { PackageBc[Status]=$?; EchoTest KO ${PackageBc[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageBc[Name]}> make install"
	make install 1> /dev/null && PackageBc[Status]=$? || { PackageBc[Status]=$?; EchoTest KO ${PackageBc[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									Flex									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageFlex;
PackageFlex[Name]="flex";
PackageFlex[Version]="2.6.4";
PackageFlex[Extension]=".tar.gz";
PackageFlex[Package]="${PackageFlex[Name]}-${PackageFlex[Version]}${PackageFlex[Extension]}";

InstallFlex()
{
	EchoInfo	"Package ${PackageFlex[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageFlex[Name]}-${PackageFlex[Version]}"	"${PackageFlex[Extension]}";

	if ! cd "${PDIR}${PackageFlex[Name]}-${PackageFlex[Version]}"; then
		EchoError	"cd ${PDIR}${PackageFlex[Name]}-${PackageFlex[Version]}";
		return;
	fi

	EchoInfo	"${PackageFlex[Name]}> Configure"
	./configure --prefix=/usr \
				--docdir=/usr/share/doc/flex-2.6.4 \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageFlex[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageFlex[Name]}> make"
	make  1> /dev/null || { PackageFlex[Status]=$?; EchoTest KO ${PackageFlex[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageFlex[Name]}> make check"
	make check 1> /dev/null || { PackageFlex[Status]=$?; EchoTest KO ${PackageFlex[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageFlex[Name]}> make install"
	make install 1> /dev/null && PackageFlex[Status]=$? || { PackageFlex[Status]=$?; EchoTest KO ${PackageFlex[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageFlex[Name]}> Symbolic link from predecessor lex to flex"
	ln -sv flex	/usr/bin/lex
	ln -sv flex.1 /usr/share/man/man1/lex.1

	cd -;
}

# =====================================||===================================== #
#									  Tcl									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageTcl;
PackageTcl[Name]="tcl";
PackageTcl[Version]="8.6.14";
PackageTcl[Extension]=".tar.gz";
PackageTcl[Package]="${PackageTcl[Name]}-${PackageTcl[Version]}${PackageTcl[Extension]}";

InstallTcl()
{
	EchoInfo	"Package ${PackageTcl[Name]}"

	# ReExtractPackage	"${PDIR}"	"${PackageTcl[Name]}-${PackageTcl[Version]}"	"${PackageTcl[Extension]}";
	ReExtractPackage	"${PDIR}"	"${PackageTcl[Name]}${PackageTcl[Version]}-html"	"${PackageTcl[Extension]}";
	ReExtractPackage	"${PDIR}"	"${PackageTcl[Name]}${PackageTcl[Version]}-src"	"${PackageTcl[Extension]}";

	if ! cd "${PDIR}${PackageTcl[Name]}${PackageTcl[Version]}"; then
		EchoError	"cd ${PDIR}${PackageTcl[Name]}-${PackageTcl[Version]}";
		return;
	fi

	local SRCDIR=$(pwd);

	EchoInfo	"${PackageTcl[Name]}> Configure"
	cd unix;
	./configure --prefix=/usr \
				--mandir=/usr/share/man \
				--disable-rpath \
				1> /dev/null || { EchoTest KO ${PackageTcl[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageTcl[Name]}> make"
	make  1> /dev/null || { PackageTcl[Status]=$?; EchoTest KO ${PackageTcl[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageTcl[Name]}> Remove references to build directory"
	sed -e "s|$SRCDIR/unix|/usr/lib|" \
		-e "s|$SRCDIR|/usr/include|" \
		-i tclConfig.sh
	sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.7|/usr/lib/tdbc1.1.7|" \
		-e "s|$SRCDIR/pkgs/tdbc1.1.7/generic|/usr/include|" \
		-e "s|$SRCDIR/pkgs/tdbc1.1.7/library|/usr/lib/tcl8.6|" \
		-e "s|$SRCDIR/pkgs/tdbc1.1.7|/usr/include|" \
		-i pkgs/tdbc1.1.7/tdbcConfig.sh
	sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.4|/usr/lib/itcl4.2.4|" \
		-e "s|$SRCDIR/pkgs/itcl4.2.4/generic|/usr/include|" \
		-e "s|$SRCDIR/pkgs/itcl4.2.4|/usr/include|" \
		-i pkgs/itcl4.2.4/itclConfig.sh

	EchoInfo	"${PackageTcl[Name]}> make test"
	make test 1> /dev/null || { PackageTcl[Status]=$?; EchoTest KO ${PackageTcl[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageTcl[Name]}> make install"
	make install 1> /dev/null && PackageTcl[Status]=$? || { PackageTcl[Status]=$?; EchoTest KO ${PackageTcl[Name]} && PressAnyKeyToContinue; return; };

	chmod -v u+w /usr/lib/libtcl8.6.so
	make install-private-headers
	ln -sfv tclsh8.6 /usr/bin/tclsh
	mv /usr/share/man/man3/{Thread,Tcl_Thread}.3

	EchoInfo	"${PackageTcl[Name]}> Installing documentation"s
	cd ..
	tar -xf ../tcl8.6.14-html.tar.gz --strip-components=1
	mkdir -v -p /usr/share/doc/tcl-8.6.14
	cp -v -r ./html/* /usr/share/doc/tcl-8.6.14

	cd $SRCDIR;
}

# =====================================||===================================== #
#									 Expect									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageExpect;
PackageExpect[Name]="expect";
PackageExpect[Version]="5.45.4";
PackageExpect[Extension]=".tar.gz";
PackageExpect[Package]="${PackageExpect[Name]}${PackageExpect[Version]}${PackageExpect[Extension]}";

InstallExpect()
{
	EchoInfo	"Package ${PackageExpect[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageExpect[Name]}${PackageExpect[Version]}"	"${PackageExpect[Extension]}";

	if ! cd "${PDIR}${PackageExpect[Name]}${PackageExpect[Version]}"; then
		EchoError	"cd ${PDIR}${PackageExpect[Name]}${PackageExpect[Version]}";
		return;
	fi

	EchoInfo	"${PackageExpect[Name]}> Verify PTYs are working";
	python3 -c 'from pty import spawn; spawn(["echo", "ok"])' 1> /dev/null || { EchoTest KO ${PackageExpect[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageExpect[Name]}> Patch"
	patch -Np1 -i ../expect-5.45.4-gcc14-1.patch;

	EchoInfo	"${PackageExpect[Name]}> Configure"
	./configure --prefix=/usr \
				--with-tcl=/usr/lib \
				--enable-shared \
				--disable-rpath \
				--mandir=/usr/share/man \
				--with-tclinclude=/usr/include \
				1> /dev/null || { EchoTest KO ${PackageExpect[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageExpect[Name]}> make"
	make  1> /dev/null || { PackageExpect[Status]=$?; EchoTest KO ${PackageExpect[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageExpect[Name]}> make test"
	make test 1> /dev/null || { PackageExpect[Status]=$?; EchoTest KO ${PackageExpect[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageExpect[Name]}> make install"
	make install 1> /dev/null && PackageExpect[Status]=$? || { PackageExpect[Status]=$?; EchoTest KO ${PackageExpect[Name]} && PressAnyKeyToContinue; return; };

	ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib

	cd -;
}
#start
# =====================================||===================================== #
#									DejaGNU									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageDejaGNU;
PackageDejaGNU[Name]="dejagnu";
PackageDejaGNU[Version]="1.6.3";
PackageDejaGNU[Extension]=".tar.gz";
PackageDejaGNU[Package]="${PackageDejaGNU[Name]}-${PackageDejaGNU[Version]}${PackageDejaGNU[Extension]}";

InstallDejaGNU()
{
	EchoInfo	"Package ${PackageDejaGNU[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageDejaGNU[Name]}-${PackageDejaGNU[Version]}"	"${PackageDejaGNU[Extension]}";

	
	if ! cd "${PDIR}${PackageDejaGNU[Name]}-${PackageDejaGNU[Version]}"; then
		EchoError	"cd ${PDIR}${PackageDejaGNU[Name]}-${PackageDejaGNU[Version]}";
		return;
	fi

	if ! mkdir -p "build"; then
		PackageDejaGNU[Status]=1; 
		EchoError	"Failed to make ${PDIR}${PackageDejaGNU[Name]}/build";
		cd -;
		return ;
	fi

	cd -
	cd "${PDIR}${PackageDejaGNU[Name]}-${PackageDejaGNU[Version]}/build";

	EchoInfo	"${PackageDejaGNU[Name]}> Configure"
	../configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageDejaGNU[Name]} && PressAnyKeyToContinue; return; };
	makeinfo --html --no-split	-o doc/dejagnu.html	../doc/dejagnu.texi
	makeinfo --plaintext		-o doc/dejagnu.txt	../doc/dejagnu.texi

	EchoInfo	"${PackageDejaGNU[Name]}> make check"
	make check 1> /dev/null || { PackageDejaGNU[Status]=$?; EchoTest KO ${PackageDejaGNU[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageDejaGNU[Name]}> make install"
	make install 1> /dev/null && PackageDejaGNU[Status]=$? || { PackageDejaGNU[Status]=$?; EchoTest KO ${PackageDejaGNU[Name]} && PressAnyKeyToContinue; return; };
	install -v -dm755	/usr/share/doc/dejagnu-1.6.3
	install -v -m644	doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3

	cd -;
}

# =====================================||===================================== #
#									Pkgconf									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePkgconf;
PackagePkgconf[Name]="pkgconf";
PackagePkgconf[Version]="2.3.0";
PackagePkgconf[Extension]=".tar.xz";
PackagePkgconf[Package]="${PackagePkgconf[Name]}-${PackagePkgconf[Version]}${PackagePkgconf[Extension]}";

InstallPkgconf()
{
	EchoInfo	"Package ${PackagePkgconf[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackagePkgconf[Name]}-${PackagePkgconf[Version]}"	"${PackagePkgconf[Extension]}";

	if ! cd "${PDIR}${PackagePkgconf[Name]}-${PackagePkgconf[Version]}"; then
		EchoError	"cd ${PDIR}${PackagePkgconf[Name]}-${PackagePkgconf[Version]}";
		return;
	fi

	EchoInfo	"${PackagePkgconf[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--docdir=/usr/share/doc/pkgconf-2.3.0 \
				1> /dev/null || { EchoTest KO ${PackagePkgconf[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackagePkgconf[Name]}> make"
	make  1> /dev/null || { PackagePkgconf[Status]=$?; EchoTest KO ${PackagePkgconf[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackagePkgconf[Name]}> make install"
	make install 1> /dev/null && PackagePkgconf[Status]=$? || { PackagePkgconf[Status]=$?; EchoTest KO ${PackagePkgconf[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackagePkgconf[Name]}> Maintain compatability with original Pkg-config";
	ln -sv pkgconf	/usr/bin/pkg-config
	ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1

	cd -;
}

# =====================================||===================================== #
#									Binutils									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageBinutils;
PackageBinutils[Name]="binutils";
PackageBinutils[Version]="2.43.1";
PackageBinutils[Extension]=".tar.xz";
PackageBinutils[Package]="${PackageBinutils[Name]}-${PackageBinutils[Version]}${PackageBinutils[Extension]}";

InstallBinutils()
{
	EchoInfo	"Package ${PackageBinutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBinutils[Name]}-${PackageBinutils[Version]}"	"${PackageBinutils[Extension]}";

	if ! cd "${PDIR}${PackageBinutils[Name]}-${PackageBinutils[Version]}"; then
		EchoError	"cd ${PDIR}${PackageBinutils[Name]}-${PackageBinutils[Version]}";
		return;
	fi

	if ! mkdir -p build; then
		PackageBinutils[Status]=1; 
		EchoError	"Failed to make ${PDIR}${PackageBinutils[Name]}/build";
		cd -;
		return ;
	fi
	cd -;
	cd "${PDIR}${PackageBinutils[Name]}-${PackageBinutils[Version]}/build";

	EchoInfo	"${PackageBinutils[Name]}> Configure"
	../configure --prefix=/usr \
					--sysconfdir=/etc \
					--enable-gold \
					--enable-ld=default \
					--enable-plugins \
					--enable-shared \
					--disable-werror \
					--enable-64-bit-bfd \
					--enable-new-dtags \
					--with-system-zlib \
					--enable-default-hash-style=gnu \
					1> /dev/null || { EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBinutils[Name]}> make tooldir=/usr"
	make tooldir=/usr 1> /dev/null || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBinutils[Name]}> make -k check"
	$(make -k check | grep '^FAIL:' $(find -name '*.log') | grep -vE 'gold/testsuite/test-suite.log:FAIL: (weak_undef_test|initpri3a|script_test_1|script_test_2|justsyms|justsyms_exec|binary_test|script_test_3|tls_phdrs_script_test|script_test_12i|incremental_test_2|incremental_test_5)' | wc -l) -gt 0 || echo Error;
	grep '^FAIL:' $(find -name '*.log') | grep -vE 'gold/testsuite/test-suite.log:FAIL: (weak_undef_test|initpri3a|script_test_1|script_test_2|justsyms|justsyms_exec|binary_test|script_test_3|tls_phdrs_script_test|script_test_12i|incremental_test_2|incremental_test_5)'
	make -k check 1> /dev/null || \
		if [ $(grep '^FAIL:' $(find -name '*.log') | grep -vE 'gold/testsuite/test-suite.log:FAIL: (weak_undef_test|initpri3a|script_test_1|script_test_2|justsyms|justsyms_exec|binary_test|script_test_3|tls_phdrs_script_test|script_test_12i|incremental_test_2|incremental_test_5)' | wc -l) -gt 0 ]; then
			PackageBinutils[Status]=$?;
			EchoTest KO ${PackageBinutils[Name]};
			PressAnyKeyToContinue;
			return;
		else
			EchoTest OK "${PackageBinutils[Name]} Only the 12 valid errors";
		fi
	
	EchoInfo	"${PackageBinutils[Name]}> make tooldir=/usr install"
	make tooldir=/usr install 1> /dev/null && PackageBinutils[Status]=$? || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBinutils[Name]}> Remove uselss static libraries";
	rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a;

	cd -;
}

# =====================================||===================================== #
#									  GMP									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGMP;
PackageGMP[Name]="gmp";
PackageGMP[Version]="6.3.0";
PackageGMP[Extension]=".tar.xz";
PackageGMP[Package]="${PackageGMP[Name]}-${PackageGMP[Version]}${PackageGMP[Extension]}";

InstallGMP()
{
	EchoInfo	"Package ${PackageGMP[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGMP[Name]}-${PackageGMP[Version]}"	"${PackageGMP[Extension]}";

	if ! cd "${PDIR}${PackageGMP[Name]}-${PackageGMP[Version]}"; then
		EchoError	"cd ${PDIR}${PackageGMP[Name]}-${PackageGMP[Version]}";
		return;
	fi

	EchoInfo	"${PackageGMP[Name]}> Configure"
	./configure --prefix=/usr \
				--enable-cxx \
				--disable-static \
				--docdir=/usr/share/doc/gmp-6.3.0 \
				1> /dev/null || { EchoTest KO ${PackageGMP[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGMP[Name]}> make"
	make  1> /dev/null || { PackageGMP[Status]=$?; EchoTest KO ${PackageGMP[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGMP[Name]}> make html"
	make html 1> /dev/null && PackageGMP[Status]=$? || { PackageGMP[Status]=$?; EchoTest KO ${PackageGMP[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGMP[Name]}> make check"
	make check 1> /dev/null | tee gmp-check-log
	if grep -q "Illegal instruction" "gmp-check-log"; then
		PackageGMP[Status]=$?;
		EchoTest KO "${PackageGMP[Name]} Need to be reconfigured with --host=none-linux-gnu and rebuilt";
		PressAnyKeyToContinue;
		return;
	elif [ $(awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log) -lt 199 ]; then
		PackageGMP[Status]=$?;
		EchoTest KO "${PackageGMP[Name]} Insufficient PASS";
		PressAnyKeyToContinue;
		return;
	fi

	EchoInfo	"${PackageGMP[Name]}> make install"
	make install 1> /dev/null && PackageGMP[Status]=$? || { PackageGMP[Status]=$?; EchoTest KO ${PackageGMP[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGMP[Name]}> make install-html"
	make install-html 1> /dev/null && PackageGMP[Status]=$? || { PackageGMP[Status]=$?; EchoTest KO ${PackageGMP[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									  MPFR									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMPFR;
PackageMPFR[Name]="mpfr";
PackageMPFR[Version]="4.2.1";
PackageMPFR[Extension]=".tar.xz";
PackageMPFR[Package]="${PackageMPFR[Name]}-${PackageMPFR[Version]}${PackageMPFR[Extension]}";

InstallMPFR()
{
	EchoInfo	"Package ${PackageMPFR[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageMPFR[Name]}-${PackageMPFR[Version]}"	"${PackageMPFR[Extension]}";

	if ! cd "${PDIR}${PackageMPFR[Name]}-${PackageMPFR[Version]}"; then
		EchoError	"cd ${PDIR}${PackageMPFR[Name]}-${PackageMPFR[Version]}";
		return;
	fi

	EchoInfo	"${PackageMPFR[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--enable-thread-safe \
				--docdir=/usr/share/doc/mpfr-4.2.1 \
				1> /dev/null || { EchoTest KO ${PackageMPFR[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageMPFR[Name]}> make"
	make  1> /dev/null || { PackageMPFR[Status]=$?; EchoTest KO ${PackageMPFR[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageMPFR[Name]}> make html"
	make html  1> /dev/null || { PackageMPFR[Status]=$?; EchoTest KO ${PackageMPFR[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageMPFR[Name]}> make check"
	make check 1> /dev/null || { PackageMPFR[Status]=$?; EchoTest KO ${PackageMPFR[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageMPFR[Name]}> make install"
	make install 1> /dev/null && PackageMPFR[Status]=$? || { PackageMPFR[Status]=$?; EchoTest KO ${PackageMPFR[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageMPFR[Name]}> make install-html"
	make install-html 1> /dev/null && PackageMPFR[Status]=$? || { PackageMPFR[Status]=$?; EchoTest KO ${PackageMPFR[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									  MPC									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMPC;
PackageMPC[Name]="mpc";
PackageMPC[Version]="1.3.1";
PackageMPC[Extension]=".tar.gz";
PackageMPC[Package]="${PackageMPC[Name]}-${PackageMPC[Version]}${PackageMPC[Extension]}";

InstallMPC()
{
	EchoInfo	"Package ${PackageMPC[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageMPC[Name]}-${PackageMPC[Version]}"	"${PackageMPC[Extension]}";

	if ! cd "${PDIR}${PackageMPC[Name]}-${PackageMPC[Version]}"; then
		EchoError	"cd ${PDIR}${PackageMPC[Name]}-${PackageMPC[Version]}";
		return;
	fi

	EchoInfo	"${PackageMPC[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--docdir=/usr/share/doc/mpc-1.3.1 \
				1> /dev/null || { EchoTest KO ${PackageMPC[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageMPC[Name]}> make"
	make  1> /dev/null || { PackageMPC[Status]=$?; EchoTest KO ${PackageMPC[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageMPC[Name]}> make html"
	make html 1> /dev/null || { PackageMPC[Status]=$?; EchoTest KO ${PackageMPC[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageMPC[Name]}> make check"
	make check 1> /dev/null || { PackageMPC[Status]=$?; EchoTest KO ${PackageMPC[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageMPC[Name]}> make install"
	make install 1> /dev/null && PackageMPC[Status]=$? || { PackageMPC[Status]=$?; EchoTest KO ${PackageMPC[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageMPC[Name]}> make install-html"
	make install-html 1> /dev/null && PackageMPC[Status]=$? || { PackageMPC[Status]=$?; EchoTest KO ${PackageMPC[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									  Attr									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageAttr;
PackageAttr[Name]="attr";
PackageAttr[Version]="2.5.2";
PackageAttr[Extension]=".tar.gz";
PackageAttr[Package]="${PackageAttr[Name]}-${PackageAttr[Version]}${PackageAttr[Extension]}";

InstallAttr()
{
	EchoInfo	"Package ${PackageAttr[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageAttr[Name]}-${PackageAttr[Version]}"	"${PackageAttr[Extension]}";

	if ! cd "${PDIR}${PackageAttr[Name]}-${PackageAttr[Version]}"; then
		EchoError	"cd ${PDIR}${PackageAttr[Name]}-${PackageAttr[Version]}";
		return;
	fi

	EchoInfo	"${PackageAttr[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--sysconfdir=/etc \
				--docdir=/usr/share/doc/attr-2.5.2 \
				1> /dev/null || { EchoTest KO ${PackageAttr[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageAttr[Name]}> make"
	make  1> /dev/null || { PackageAttr[Status]=$?; EchoTest KO ${PackageAttr[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageAttr[Name]}> make check"
	make check 1> /dev/null || { PackageAttr[Status]=$?; EchoTest KO ${PackageAttr[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageAttr[Name]}> make install"
	make install 1> /dev/null && PackageAttr[Status]=$? || { PackageAttr[Status]=$?; EchoTest KO ${PackageAttr[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									  Acl									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageAcl;
PackageAcl[Name]="acl";
PackageAcl[Version]="2.3.2";
PackageAcl[Extension]=".tar.xz";
PackageAcl[Package]="${PackageAcl[Name]}-${PackageAcl[Version]}${PackageAcl[Extension]}";

InstallAcl()
{
	EchoInfo	"Package ${PackageAcl[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageAcl[Name]}-${PackageAcl[Version]}"	"${PackageAcl[Extension]}";

	if ! cd "${PDIR}${PackageAcl[Name]}-${PackageAcl[Version]}"; then
		EchoError	"cd ${PDIR}${PackageAcl[Name]}-${PackageAcl[Version]}";
		return;
	fi

	EchoInfo	"${PackageAcl[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--docdir=/usr/share/doc/acl-2.3.2 \
				1> /dev/null || { EchoTest KO ${PackageAcl[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageAcl[Name]}> make"
	make  1> /dev/null || { PackageAcl[Status]=$?; EchoTest KO ${PackageAcl[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageAcl[Name]}> make install"
	make install 1> /dev/null && PackageAcl[Status]=$? || { PackageAcl[Status]=$?; EchoTest KO ${PackageAcl[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									 Libcap									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibcap;
PackageLibcap[Name]="libcap";
PackageLibcap[Version]="2.70";
PackageLibcap[Extension]=".tar.xz";
PackageLibcap[Package]="${PackageLibcap[Name]}-${PackageLibcap[Version]}${PackageLibcap[Extension]}";

InstallLibcap()
{
	EchoInfo	"Package ${PackageLibcap[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLibcap[Name]}-${PackageLibcap[Version]}"	"${PackageLibcap[Extension]}";

	if ! cd "${PDIR}${PackageLibcap[Name]}-${PackageLibcap[Version]}"; then
		EchoError	"cd ${PDIR}${PackageLibcap[Name]}-${PackageLibcap[Version]}";
		return;
	fi

	EchoInfo	"${PackageLibcap[Name]}> Prevent static libraries form being installed"
	sed -i '/install -m.*STA/d' libcap/Makefile

	EchoInfo	"${PackageLibcap[Name]}> make prefix=/usr lib=lib"
	make prefix=/usr lib=lib 1> /dev/null || { PackageLibcap[Status]=$?; EchoTest KO ${PackageLibcap[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLibcap[Name]}> make test"
	make test 1> /dev/null || { PackageLibcap[Status]=$?; EchoTest KO ${PackageLibcap[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageLibcap[Name]}> make prefix=/usr lib=lib install"
	make prefix=/usr lib=lib install 1> /dev/null && PackageLibcap[Status]=$? || { PackageLibcap[Status]=$?; EchoTest KO ${PackageLibcap[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#								   Libxcrypt								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibxcrypt;
PackageLibxcrypt[Name]="libxcrypt";
PackageLibxcrypt[Version]="4.4.36";
PackageLibxcrypt[Extension]=".tar.xz";
PackageLibxcrypt[Package]="${PackageLibxcrypt[Name]}-${PackageLibxcrypt[Version]}${PackageLibxcrypt[Extension]}";

InstallLibxcrypt()
{
	EchoInfo	"Package ${PackageLibxcrypt[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLibxcrypt[Name]}-${PackageLibxcrypt[Version]}"	"${PackageLibxcrypt[Extension]}";

	if ! cd "${PDIR}${PackageLibxcrypt[Name]}-${PackageLibxcrypt[Version]}"; then
		EchoError	"cd ${PDIR}${PackageLibxcrypt[Name]}-${PackageLibxcrypt[Version]}";
		return;
	fi

	EchoInfo	"${PackageLibxcrypt[Name]}> Configure"
	./configure --prefix=/usr \
				--enable-hashes=strong,glibc \
				--enable-obsolete-api=no \
				--disable-static \
				--disable-failure-tokens \
				1> /dev/null || { EchoTest KO ${PackageLibxcrypt[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLibxcrypt[Name]}> make"
	make  1> /dev/null || { PackageLibxcrypt[Status]=$?; EchoTest KO ${PackageLibxcrypt[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLibxcrypt[Name]}> make check"
	make check 1> /dev/null || { PackageLibxcrypt[Status]=$?; EchoTest KO ${PackageLibxcrypt[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageLibxcrypt[Name]}> make install"
	make install 1> /dev/null && PackageLibxcrypt[Status]=$? || { PackageLibxcrypt[Status]=$?; EchoTest KO ${PackageLibxcrypt[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									 Shadow									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageShadow;
PackageShadow[Name]="shadow";
PackageShadow[Version]="4.16.0";
PackageShadow[Extension]=".tar.xz";
PackageShadow[Package]="${PackageShadow[Name]}-${PackageShadow[Version]}${PackageShadow[Extension]}";

InstallShadow()
{
	EchoInfo	"Package ${PackageShadow[Name]}"

	# Extraction
	ReExtractPackage	"${PDIR}"	"${PackageShadow[Name]}-${PackageShadow[Version]}"	"${PackageShadow[Extension]}";

	if ! cd "${PDIR}${PackageShadow[Name]}-${PackageShadow[Version]}"; then
		EchoError	"cd ${PDIR}${PackageShadow[Name]}-${PackageShadow[Version]}";
		return;
	fi

	#Installation
	EchoInfo	"${PackageShadow[Name]}> Disable the installation of the groups program and its man page"
	sed -i 's/groups$(EXEEXT) //' src/Makefile.in
	find man -name Makefile.in -exec sed -i 's/groups\.1 / /'	{} \;
	find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /'	{} \;
	find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'	{} \;

	EchoInfo	"${PackageShadow[Name]}> Configure etc/login.defs"
	sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
		-e 's:/var/spool/mail:/var/mail:' \
		-e '/PATH=/{s@/sbin:@@;s@/bin:@@}' \
		-i etc/login.defs

	EchoInfo	"${PackageShadow[Name]}> Configure"
	touch /usr/bin/passwd
	./configure --sysconfdir=/etc \
				--disable-static \
				--with-{b,yes}crypt \
				--without-libbsd \
				--with-group-name-max-length=32 \
				1> /dev/null || { EchoTest KO ${PackageShadow[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageShadow[Name]}> make"
	make  1> /dev/null || { PackageShadow[Status]=$?; EchoTest KO ${PackageShadow[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageShadow[Name]}> make exec_prefix=/usr install"
	make exec_prefix=/usr install 1> /dev/null && PackageShadow[Status]=$? || { PackageShadow[Status]=$?; EchoTest KO ${PackageShadow[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageShadow[Name]}> make -C man install-man"
	make -C man install-man 1> /dev/null && PackageShadow[Status]=$? || { PackageShadow[Status]=$?; EchoTest KO ${PackageShadow[Name]} && PressAnyKeyToContinue; return; };

	# Configuration
	EchoInfo	"${PackageShadow[Name]}> Enabling Shadow passwords"
	pwconv
	grpconv
	mkdir -p /etc/default
	useradd -D --gid 999
	cd -;

	EchoInfo	"${PackageShadow[Name]}> Enabling Shadow passwords"
	passwd root
}

# =====================================||===================================== #
#									Gcc									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGcc;
PackageGcc[Name]="gcc";
PackageGcc[Version]="14.2.0";
PackageGcc[Extension]=".tar.xz";
PackageGcc[Package]="${PackageGcc[Name]}-${PackageGcc[Version]}${PackageGcc[Extension]}";

InstallGcc()
{
	EchoInfo	"Package ${PackageGcc[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGcc[Name]}-${PackageGcc[Version]}"	"${PackageGcc[Extension]}";

	if ! cd "${PDIR}${PackageGcc[Name]}-${PackageGcc[Version]}"; then
		EchoError	"cd ${PDIR}${PackageGcc[Name]}-${PackageGcc[Version]}";
		return;
	fi

	# Change the default directory name for 64-bit libraries to “lib” for x86_64
	case $(uname -m) in
		x86_64)	sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64;;
	esac

	if ! mkdir -p build; then
		PackageGcc[Status]=1; 
		EchoError	"Failed to make ${PDIR}${PackageGcc[Name]}/build";
		cd -;
		return ;
	fi
	cd -;
	cd "${PDIR}${PackageGcc[Name]}-${PackageGcc[Version]}/build";


	EchoInfo	"${PackageGcc[Name]}> Configure"
	../configure	--prefix=/usr \
					LD=ld \
					--enable-languages=c,c++ \
					--enable-default-pie \
					--enable-default-ssp \
					--enable-host-pie \
					--disable-multilib \
					--disable-bootstrap \
					--disable-fixincludes \
					--with-system-zlib \
					1> /dev/null || { EchoTest KO ${PackageGcc[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGcc[Name]}> make"
	make  1> /dev/null || { PackageGcc[Status]=$?; EchoTest KO ${PackageGcc[Name]} && PressAnyKeyToContinue; return; };

	# Set stack space for gcc requirements
	ulimit -s -H unlimited

	sed -e '/cpython/d' \
		-i ../gcc/testsuite/gcc.dg/plugin/plugin.exp
	sed -e 's/no-pic /&-no-pie /' \
		-i ../gcc/testsuite/gcc.target/i386/pr113689-1.c
	sed -e 's/300000/(1|300000)/' \
		-i ../libgomp/testsuite/libgomp.c-c++-common/pr109062.c
	sed -e 's/{ target nonpic } //' \
		-e '/GOTPCREL/d' \
		-i ../gcc/testsuite/gcc.target/i386/fentryname3.c

	EchoInfo	"${PackageGcc[Name]}> su tester -c \"PATH=$PATH make -k check\"";
	EchoInfo	"${PackageGcc[Name]}> (Takes xx/46 SBU (1:43:27.617))";
	chown -R tester .
	time su tester -c "PATH=$PATH make -k check"
	if [ $(../contrib/test_summary | grep "unexpected" | wc -l) -gt 0 ]; then
		EchoError	"${PackageGcc[Name]}> Unexpected test results:";
		../contrib/test_summary | grep "^FAIL" -B4 -A9;
		if [ $(../contrib/test_summary | grep "^FAIL" | grep -v "/tsan/" | wc -l) -gt 0 ]; then
			PressAnyKeyToContinue ;
			return ;
		else
			EchoInfo	"${PackageGcc[Name]}> tsan errors are ignored.";
		fi
	fi

	EchoInfo	"${PackageGcc[Name]}> make install"
	make install 1> /dev/null && PackageGcc[Status]=$? || { PackageGcc[Status]=$?; EchoTest KO ${PackageGcc[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageGcc[Name]}> Change owner to root"
	chown -v -R root:root /usr/lib/gcc/$(gcc -dumpmachine)/14.2.0/include{,-fixed}

	EchoInfo	"${PackageGcc[Name]}> Create symbolic links"
	ln -svr /usr/bin/cpp /usr/lib
	ln -sv gcc.1 /usr/share/man/man1/cc.1
	ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/14.2.0/liblto_plugin.so /usr/lib/bfd-plugins/

	EchoInfo	"${PackageGcc[Name]}> Sanity check"

	echo 'int main(){}' | cc -x c - -v -Wl,--verbose -o gcctest.out &> gcctest.log
	if [ ! -f "gcctest.out" ]; then
		EchoError	"${PackageGcc[Name]}> Failed to create gcctest.out";
		PressAnyKeyToContinue;
		return ;
	fi

	readelf -l gcctest.out | grep "\[Requesting program interpreter: /lib"
	if [ $? -gt 0 ]; then
		EchoError	"${PackageGcc[Name]}> Failed to run gcctest.out";
		PressAnyKeyToContinue;
		return ;
	else
		EchoTest	"OK" "${PackageGcc[Name]} ran succesfully";
	fi

	if [ $(grep -E "crt[1in].* succeeded" gcctest.log -c) -ne 3 ]; then
		EchoError	"${PackageGcc[Name]}> Failed to access crt[1in] libraries";
		grep -E "crt[1in].* failed" gcctest.log;
		PressAnyKeyToContinue;
		return ;
	else
		EchoTest	OK	"crt[1in] libraries accessed"
	fi

	if [ $(grep -A9 "#include *...* search starts here:" gcctest.log | grep -B9 "End of search list." | grep "/usr/.*include" -c ) -lt 4 ]; then
		
		EchoError	"${PackageGcc[Name]}> Compiler fails to search for correct header files";
		grep -A9 "#include *...* search starts here:" gcctest.log | grep -B9 "End of search list.";
		PressAnyKeyToContinue;
		return ;
	else
		EchoTest	OK	"Correct header failes found"
	fi

	local ExpectedOutput='SEARCH_DIR("/usr/x86_64-pc-linux-gnu/lib64")
SEARCH_DIR("/usr/local/lib64")
SEARCH_DIR("/lib64")
SEARCH_DIR("/usr/lib64")
SEARCH_DIR("/usr/x86_64-pc-linux-gnu/lib")
SEARCH_DIR("/usr/local/lib")
SEARCH_DIR("/lib")
SEARCH_DIR("/usr/lib");'
	local ActualOutput=$(grep 'SEARCH.*/usr/lib' gcctest.log | sed 's|; |\n|g')
	if [ "$ActualOutput" != "$ExpectedOutput" ]; then
		EchoError	"${PackageGcc[Name]}> Linker is using incorrect search paths";
		echo	"$ActualOutput";
		PressAnyKeyToContinue;
		return ;
	else
		EchoTest	OK	"Correct search paths"
	fi

	if [ $(grep "/lib.*/libc.so.6 succeeded" gcctest.log -c) -ne 1 ]; then
		EchoError	"${PackageGcc[Name]}> Using incorrect libc";
		grep "/lib.*/libc.so.6 succeeded" gcctest.log
		PressAnyKeyToContinue;
		return ;
	else
		EchoTest	OK	"correct libc used"
	fi

	if [ "/usr/lib/$(grep "found" gcctest.log | awk '{print $2}')" != "$(grep "found" gcctest.log | awk '{print $4}')" ]; then
		EchoError	"${PackageGcc[Name]}> Incorrect dynamic linker";
		grep "found" gcctest.log
		PressAnyKeyToContinue;
		return ;
	fi

	rm gcctest.out gcctest.log

	mkdir -pv /usr/share/gdb/auto-load/usr/lib
	if ls /usr/lib/*gdb.py &> /dev/null; then
		mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
	elif ! ls /usr/share/gdb/auto-load/usr/lib/*gdb.py &> /dev/null; then
		EchoError	"${PackageGcc[Name]}> File '*gdb.py' not found";
	fi

	cd -;
}

# =====================================||===================================== #
#																			   #
#									  Menu									   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

InstallAll()
{
	InstallMan;
	InstallIanaEtc;
	InstallGlibc;
	InstallZlib;
	InstallBzip2;
	InstallXz;
	InstallLz4;
	InstallZstd;
	InstallFile;
	InstallReadline;
	InstallM4;
	InstallBc;
	InstallFlex;
	InstallTcl;
	InstallExpect;
	InstallDejaGNU;
	InstallPkgconf;
	InstallBinutils;
	InstallGMP;
	InstallMPFR;
	InstallMPC;
	InstallAttr;
	InstallAcl;
	InstallLibcap;
	InstallLibxcrypt;
	InstallShadow;
	InstallGcc;
}

PrintMenu()
{
	clear ;
	
	PrintMenuLine	"${PackageMan[Name]}-${PackageMan[Version]}"			$MenuIndex	0	"${PackageMan[Status]}";
	PrintMenuLine	"${PackageIanaEtc[Name]}-${PackageIanaEtc[Version]}"	$MenuIndex	1	"${PackageIanaEtc[Status]}";
	PrintMenuLine	"${PackageGlibc[Name]}-${PackageGlibc[Version]}"		$MenuIndex	2	"${PackageGlibc[Status]}";
	PrintMenuLine	"${PackageZlib[Name]}-${PackageZlib[Version]}"			$MenuIndex	3	"${PackageZlib[Status]}";
	PrintMenuLine	"${PackageBzip2[Name]}-${PackageBzip2[Version]}"		$MenuIndex	4	"${PackageBzip2[Status]}";
	PrintMenuLine	"${PackageXz[Name]}-${PackageXz[Version]}"				$MenuIndex	5	"${PackageXz[Status]}";
	PrintMenuLine	"${PackageLz4[Name]}-${PackageLz4[Version]}"			$MenuIndex	6	"${PackageLz4[Status]}";
	PrintMenuLine	"${PackageZstd[Name]}-${PackageZstd[Version]}"			$MenuIndex	7	"${PackageZstd[Status]}";
	PrintMenuLine	"${PackageFile[Name]}-${PackageFile[Version]}"			$MenuIndex	8	"${PackageFile[Status]}";
	PrintMenuLine	"${PackageReadline[Name]}-${PackageReadline[Version]}"	$MenuIndex	9	"${PackageReadline[Status]}";
	PrintMenuLine	"${PackageM4[Name]}-${PackageM4[Version]}"				$MenuIndex	10	"${PackageM4[Status]}";
	PrintMenuLine	"${PackageBc[Name]}-${PackageBc[Version]}"				$MenuIndex	11	"${PackageBc[Status]}";
	PrintMenuLine	"${PackageFlex[Name]}-${PackageFlex[Version]}"			$MenuIndex	12	"${PackageFlex[Status]}";
	PrintMenuLine	"${PackageTcl[Name]}-${PackageTcl[Version]}"			$MenuIndex	13	"${PackageTcl[Status]}";
	PrintMenuLine	"${PackageExpect[Name]}-${PackageExpect[Version]}"		$MenuIndex	14	"${PackageExpect[Status]}";
	PrintMenuLine	"${PackageDejaGNU[Name]}-${PackageDejaGNU[Version]}"		$MenuIndex	15	"${PackageDejaGNU[Status]}";
	PrintMenuLine	"${PackagePkgconf[Name]}-${PackagePkgconf[Version]}"		$MenuIndex	16	"${PackagePkgconf[Status]}";
	PrintMenuLine	"${PackageBinutils[Name]}-${PackageBinutils[Version]}"		$MenuIndex	17	"${PackageBinutils[Status]}";
	PrintMenuLine	"${PackageGMP[Name]}-${PackageGMP[Version]}"		$MenuIndex	18	"${PackageGMP[Status]}";
	PrintMenuLine	"${PackageMPFR[Name]}-${PackageMPFR[Version]}"		$MenuIndex	19	"${PackageMPFR[Status]}";
	PrintMenuLine	"${PackageMPC[Name]}-${PackageMPC[Version]}"		$MenuIndex	20	"${PackageMPC[Status]}";
	PrintMenuLine	"${PackageAttr[Name]}-${PackageAttr[Version]}"		$MenuIndex	21	"${PackageAttr[Status]}";
	PrintMenuLine	"${PackageAcl[Name]}-${PackageAcl[Version]}"		$MenuIndex	22	"${PackageAcl[Status]}";
	PrintMenuLine	"${PackageLibcap[Name]}-${PackageLibcap[Version]}"		$MenuIndex	23	"${PackageLibcap[Status]}";
	PrintMenuLine	"${PackageLibxcrypt[Name]}-${PackageLibxcrypt[Version]}"		$MenuIndex	24	"${PackageLibxcrypt[Status]}";
	PrintMenuLine	"${PackageShadow[Name]}-${PackageShadow[Version]}"		$MenuIndex	25	"${PackageShadow[Status]}";
	PrintMenuLine	"${PackageGcc[Name]}-${PackageGcc[Version]}"		$MenuIndex	26	"${PackageGcc[Status]}";
	PrintMenuLine	"Install All"	$MenuIndex	27;
	PrintMenuLine	"Quit"	$MenuIndex	28;

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
				5)	InstallXz;;
				6)	InstallLz4;;
				7)	InstallZstd;;
				8)	InstallFile;;
				9)	InstallReadline;;
				10)	InstallM4;;
				11)	InstallBc;;
				12)	InstallFlex;;
				13)	InstallTcl;;
				14)	InstallExpect;;
				15)	InstallDejaGNU;;
				16)	InstallPkgconf;;
				17)	InstallBinutils;;
				18)	InstallGMP;;
				19)	InstallMPFR;;
				20)	InstallMPC;;
				21)	InstallAttr;;
				22)	InstallAcl;;
				23)	InstallLibcap;;
				24)	InstallLibxcrypt;;
				25)	InstallShadow;;
				26) InstallGcc;;
				27)	InstallAll;;
				28)	MenuIndex=-1;
					return ;;
			esac;
			PressAnyKeyToContinue;;
	esac

	MenuIndex=$(( MenuIndex % 29 ));
	if [ $MenuIndex -lt 0 ]; then
		MenuIndex=28;
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
while [ "$MenuIndex" -ge 0 ]; do
	PrintMenu;
done

exit 
# ---------------------------------------------------------------------------- #

# Man-pages
# Iana-Etc
Glibc
Zlib
Bzip2
Xz
Lz4
Zstd
File
Readline
# M4
# Bc
Flex
Tcl
Expect
Pkgconf
Binutils
GMP
MPFR
MPC
Attr
Acl
Libcap
Libxcrypt
Shadow
GCC
Ncurses
# Sed
# Psmisc
Gettext
Bison
# Grep
# Bash
Libtool
GDBM
# Gperf
Expat
# Inetutils
# Less
Perl
# XML::Parser
# Intltool
# Autoconf
# Automake
OpenSSL
Kmod
Libelf
Libffi
Python3
# Filt-Core
# Wheel
# Setuptools
# Ninja
# Meson
	Coreutils
Check
# Diffutils
Gawk
# Findutils
# Groff
# GRUB
# Gzip
# IPRoute2
# Kbd
Libpipeline
# Make
# Patch
# Tar
Texinfo
# Vim
Udev
Man-DB
Procps-ng
Util-linux
E2fsprogs
# Sysklogd
# SysVinit

# ---------------------------------------------------------------------------- #

# MPC		GCC
# GMP		MPFR and GCC
	# MPFR		Gawk and GCC
# Lz4		Zstd
	# Zstd		Binutils, GCC, Libelf, and Udev
		# GCC

# Flex		Binutils, IProute2, Kbd, Kmod, and Man-DB
# Pkgconf	Binutils, E2fsprogs, IProute2, Kmod, Man-DB, Procps-ng, Python, Udev, and Util-linux
	# Binutils

# Glibc

# Make

# Libxcrypt	Perl, Python, Shadow, and Udev
	# Attr		Acl, Libcap, and Patch
		# Acl 		Coreutils, Sed, Tar, and Vim
			# Libcap	IProute2 and Shadow
			# Sed		E2fsprogs, File, Libtool, and Shadow
				# Shadow	Coreutils
	# Zlib		File, Kmod, Libelf, Perl, and Util-linux
		# Iana-Etc	Perl
			# M4		Autoconf and Bison
			# Perl		Autoconf
				# Autoconf	Automake and Coreutils
				# Gettext	Automake and Bison
					# Automake	Coreutils
# OpenSSL	Coreutils, Kmod, Linux, and Udev
						# Coreutils	Bash, Diffutils, Findutils, Man-DB, and Udev
							# Ncurses	Bash, GRUB, Inetutils, Less, Procps-ng, Psmisc, Readline, Texinfo, Util-linux, and Vim
								# Readline	Bash, Bc, and Gawk
									# Bash

# ---------------------------------------------------------------------------- #

# Diffutils
# Findutils
# Gawk
# Grep		Man-DB
# Patch
# Bison		Kbd and Tar
# Inetutils	Tar
	# Tar
# Texinfo
# DejaGNU
# Expect
# Expat		Python and XML::Parser
# Libffi	Python
	# Python	Ninja

# Bzip2		File and Libelf
# Xz		File, GRUB, Kmod, Libelf, Man-DB, and Udev
	# File

# Less		Gzip
	# Gzip		Man-DB
# Linux API Headers

# Procps-ng

# E2fsprogs
# Kmod		Udev
# Flit-Core	Wheel
	# Wheel		Jinja2, MarkupSafe, Meson, and Setuptools
		# Setuptools	Jinja2, MarkupSafe, and Meson
			# Ninja		Meson
				# Meson		Udev
			# MarkupSafe	Jinja2
				# Jinja2	Udev
					# Udev		Util-linux
		# Util-linux

# Bc		Linux
# Libelf	IProute2 and Linux
	# IProute2
	# Linux
# XML::Parser	Intltool
	# Intltool
# Groff		Man-DB
# Libpipeline	Man-DB
	# Man-DB
# Man-Pages

# Check
# GDBM
# Gperf
# GRUB
# Kbd
# Libtool
# Psmisc
# Sysklogd
# SysVinit
# Tcl
# Vim

# ---------------------------------------------------------------------------- #

# Acl 		Coreutils, Sed, Tar, and Vim
# Attr		Acl, Libcap, and Patch
# Autoconf	Automake and Coreutils
# Automake	Coreutils
# Bc		Linux
# Bison		Kbd and Tar
# Bzip2		File and Libelf
# Coreutils	Bash, Diffutils, Findutils, Man-DB, and Udev
# Expat		Python and XML::Parser
# Flex		Binutils, IProute2, Kbd, Kmod, and Man-DB
# Flit-Core	Wheel
# Gettext	Automake and Bison
# GMP		MPFR and GCC
# Grep		Man-DB
# Groff		Man-DB
# Gzip		Man-DB
# Iana-Etc	Perl
# Inetutils	Tar
# Jinja2	Udev
# Kmod		Udev
# Less		Gzip
# Libcap	IProute2 and Shadow
# Libelf	IProute2 and Linux
# Libffi	Python
# Libpipeline	Man-DB
# Libxcrypt	Perl, Python, Shadow, and Udev
# Lz4		Zstd
# M4		Autoconf and Bison
# MarkupSafe	Jinja2
# Meson		Udev
# MPC		GCC
# MPFR		Gawk and GCC
# Ncurses	Bash, GRUB, Inetutils, Less, Procps-ng, Psmisc, Readline, Texinfo, Util-linux, and Vim
# Ninja		Meson
# OpenSSL	Coreutils, Kmod, Linux, and Udev
# Perl		Autoconf
# Pkgconf	Binutils, E2fsprogs, IProute2, Kmod, Man-DB, Procps-ng, Python, Udev, and Util-linux
# Python	Ninja
# Readline	Bash, Bc, and Gawk
# Sed		E2fsprogs, File, Libtool, and Shadow
# Setuptools	Jinja2, MarkupSafe, and Meson
# Shadow	Coreutils
# Udev		Util-linux
# Wheel		Jinja2, MarkupSafe, Meson, and Setuptools
# XML::Parser	Intltool
# Xz		File, GRUB, Kmod, Libelf, Man-DB, and Udev
# Zlib		File, Kmod, Libelf, Perl, and Util-linux
# Zstd		Binutils, GCC, Libelf, and Udev

# Bash
# Binutils
# Coreutils	Bash, Diffutils, Findutils, Man-DB, and Udev
# GCC
# Glibc
# Make


# Check
# DejaGNU
# Diffutils
# E2fsprogs
# Expect
# File
# Findutils
# Gawk
# GDBM
# Gperf
# GRUB
# Intltool
# IProute2
# Kbd
# Libtool
# Linux
# Linux API Headers
# Man-DB
# Man-Pages
# Patch
# Procps-ng
# Psmisc
# Sysklogd
# SysVinit
# Tar
# Tcl
# Texinfo
# Util-linux
# Vim