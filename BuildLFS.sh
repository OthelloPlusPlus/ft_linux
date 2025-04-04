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

# # =====================================||===================================== #
# #									Temp									   #
# # ===============ft_linux==============||==============©Othello=============== #

# declare -A Packagetemp;
# Packagetemp[Name]="Temp";
# Packagetemp[Version]="";
# Packagetemp[Extension]=".tar.xz";
# Packagetemp[Package]="${Packagetemp[Name]}-${Packagetemp[Version]}${Packagetemp[Extension]}";

# InstallTemp()
# {
# 	EchoInfo	"Package ${Packagetemp[Name]}"

# 	ReExtractPackage	"${PDIR}"	"${Packagetemp[Name]}-${Packagetemp[Version]}"	"${Packagetemp[Extension]}";

# 	if ! cd "${PDIR}${Packagetemp[Name]}-${Packagetemp[Version]}"; then
# 		EchoError	"cd ${PDIR}${Packagetemp[Name]}-${Packagetemp[Version]}";
# 		return;
# 	fi

# 	EchoInfo	"${Packagetemp[Name]}> Configure"
# 	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return; };

# 	EchoInfo	"${Packagetemp[Name]}> make"
# 	make  1> /dev/null || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return; };

# 	EchoInfo	"${Packagetemp[Name]}> make check"
# 	make check 1> /dev/null || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return; };
	
# 	EchoInfo	"${Packagetemp[Name]}> make install"
# 	make install 1> /dev/null && Packagetemp[Status]=$? || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return; };

# 	if ! mkdir -p build; then
# 		Packagetemp[Status]=1; 
# 		EchoError	"Failed to make ${PDIR}${Packagetemp[Name]}/build";
# 		cd -;
# 		return ;
# 	fi
# 	cd -;
# 	cd "${PDIR}${Packagetemp[Name]}-${Packagetemp[Version]}/build";

# 	cd -;
# }

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

	EchoInfo	"${PackageBzip2[Name]}> make check"
	make check 1> /dev/null || { PackageBzip2[Status]=$?; EchoTest KO ${PackageBzip2[Name]} && PressAnyKeyToContinue; return; };
	
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
#									Ncurses									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageNcurses;
PackageNcurses[Name]="ncurses";
PackageNcurses[Version]="6.5";
PackageNcurses[Extension]=".tar.gz";
PackageNcurses[Package]="${PackageNcurses[Name]}-${PackageNcurses[Version]}${PackageNcurses[Extension]}";

InstallNcurses()
{
	EchoInfo	"Package ${PackageNcurses[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageNcurses[Name]}-${PackageNcurses[Version]}"	"${PackageNcurses[Extension]}";

	if ! cd "${PDIR}${PackageNcurses[Name]}-${PackageNcurses[Version]}"; then
		EchoError	"cd ${PDIR}${PackageNcurses[Name]}-${PackageNcurses[Version]}";
		return;
	fi

	EchoInfo	"${PackageNcurses[Name]}> Configure"
	./configure --prefix=/usr \
				--mandir=/usr/share/man \
				--with-shared \
				--without-debug \
				--without-normal \
				--with-cxx-shared \
				--enable-pc-files \
				--with-pkg-config-libdir=/usr/lib/pkgconfig \
				1> /dev/null || { EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageNcurses[Name]}> make"
	make  1> /dev/null || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageNcurses[Name]}> make DESTDIR=\$PWD/dest install"
	make DESTDIR=$PWD/dest install 1> /dev/null || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return; };
	install -vm755 dest/usr/lib/libncursesw.so.6.5 /usr/lib 1> /dev/null && PackageNcurses[Status]=$? || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return; };
	rm -v dest/usr/lib/libncursesw.so.6.5
	sed -e 's/^#if.*XOPEN.*$/#if 1/' -i dest/usr/include/curses.h
	cp -av dest/* /	1> /dev/null

	EchoInfo	"${PackageNcurses[Name]}> Linking with wide-character libraries by means of symlinks"
	for lib in ncurses form panel menu ; do
		ln -sfv lib${lib}w.so 	/usr/lib/lib${lib}.so
		ln -sfv ${lib}w.pc 		/usr/lib/pkgconfig/${lib}.pc
	done

	EchoInfo	"${PackageNcurses[Name]}> Ensure old applications that look for -lcurses at build time are still buildable"
	ln -sfv libncursesw.so /usr/lib/libcurses.so

	EchoInfo	"${PackageNcurses[Name]}> Install documentation"
	cp -v -R doc -T /usr/share/doc/ncurses-6.5

	EchoInfo	"${PackageNcurses[Name]}> Rebuild for non-wide-character Ncurses libraries"
	EchoInfo	"${PackageNcurses[Name]}> make distclean"
	make distclean 1> /dev/null || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return; };
	EchoInfo	"${PackageNcurses[Name]}> configure"
	./configure --prefix=/usr \
				--with-shared \
				--without-normal \
				--without-debug \
				--without-cxx-binding \
				--with-abi-version=5 \
				 1> /dev/null || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return; };
	EchoInfo	"${PackageNcurses[Name]}> make sources libs"
	make sources libs 1> /dev/null && PackageNcurses[Status]=$? || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return; };
	cp -av lib/lib*.so.5* /usr/lib

	EchoInfo	"${PackageNcurses[Name]}> Ncurses Testing is done manually:"
	if [ "$width" -lt 42 ]; then
		local LineWidth=$((width-2));
	else
		local LineWidth=42;
	fi
	printf	"${CB_BLACK} %-*s\n %-*s\n %-*s\n${C_DGREEN} %-*s\n %-*s${C_RESET}\n${CB_BLACK} %-*s${C_RESET}\n" \
		"$LineWidth"	"> cd test" \
		"$LineWidth"	"> .configure" \
		"$LineWidth"	"> make" \
		"$LineWidth"	"# README for meaning of tests" \
		"$LineWidth"	"# To see list of exectables:" \
		"$LineWidth"	"> find . -type f -executable"

	cd -;
}

# =====================================||===================================== #
#									  Sed									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageSed;
PackageSed[Name]="sed";
PackageSed[Version]="4.9";
PackageSed[Extension]=".tar.xz";
PackageSed[Package]="${PackageSed[Name]}-${PackageSed[Version]}${PackageSed[Extension]}";

InstallSed()
{
	EchoInfo	"Package ${PackageSed[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageSed[Name]}-${PackageSed[Version]}"	"${PackageSed[Extension]}";

	if ! cd "${PDIR}${PackageSed[Name]}-${PackageSed[Version]}"; then
		EchoError	"cd ${PDIR}${PackageSed[Name]}-${PackageSed[Version]}";
		return;
	fi

	EchoInfo	"${PackageSed[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageSed[Name]}> make"
	make  1> /dev/null || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageSed[Name]}> make html"
	make html 1> /dev/null || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageSed[Name]}> u tester -c \"PATH=\$PATH make check\""
	chown -R tester .
	su tester -c "PATH=$PATH make check" 1> /dev/null || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageSed[Name]}> make install"
	make install 1> /dev/null && PackageSed[Status]=$? || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return; };
	install -d -m755 			/usr/share/doc/sed-4.9 1> /dev/null || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return; };
	install -m644 doc/sed.html 	/usr/share/doc/sed-4.9 1> /dev/null || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									Psmisc									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePsmisc;
PackagePsmisc[Name]="psmisc";
PackagePsmisc[Version]="23.7";
PackagePsmisc[Extension]=".tar.xz";
PackagePsmisc[Package]="${PackagePsmisc[Name]}-${PackagePsmisc[Version]}${PackagePsmisc[Extension]}";

InstallPsmisc()
{
	EchoInfo	"Package ${PackagePsmisc[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackagePsmisc[Name]}-${PackagePsmisc[Version]}"	"${PackagePsmisc[Extension]}";

	if ! cd "${PDIR}${PackagePsmisc[Name]}-${PackagePsmisc[Version]}"; then
		EchoError	"cd ${PDIR}${PackagePsmisc[Name]}-${PackagePsmisc[Version]}";
		return;
	fi

	EchoInfo	"${PackagePsmisc[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackagePsmisc[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackagePsmisc[Name]}> make"
	make  1> /dev/null || { PackagePsmisc[Status]=$?; EchoTest KO ${PackagePsmisc[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackagePsmisc[Name]}> make check"
	make check 1> /dev/null || { PackagePsmisc[Status]=$?; EchoTest KO ${PackagePsmisc[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackagePsmisc[Name]}> make install"
	make install 1> /dev/null && PackagePsmisc[Status]=$? || { PackagePsmisc[Status]=$?; EchoTest KO ${PackagePsmisc[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									Gettext									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGettext;
PackageGettext[Name]="gettext";
PackageGettext[Version]="0.22.5";
PackageGettext[Extension]=".tar.xz";
PackageGettext[Package]="${PackageGettext[Name]}-${PackageGettext[Version]}${PackageGettext[Extension]}";

InstallGettext()
{
	EchoInfo	"Package ${PackageGettext[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGettext[Name]}-${PackageGettext[Version]}"	"${PackageGettext[Extension]}";

	if ! cd "${PDIR}${PackageGettext[Name]}-${PackageGettext[Version]}"; then
		EchoError	"cd ${PDIR}${PackageGettext[Name]}-${PackageGettext[Version]}";
		return;
	fi

	EchoInfo	"${PackageGettext[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--docdir=/usr/share/doc/gettext-0.22.5 \
				1> /dev/null || { EchoTest KO ${PackageGettext[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGettext[Name]}> make"
	make  1> /dev/null || { PackageGettext[Status]=$?; EchoTest KO ${PackageGettext[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGettext[Name]}> make check"
	make check 1> /dev/null || { PackageGettext[Status]=$?; EchoTest KO ${PackageGettext[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageGettext[Name]}> make install"
	make install 1> /dev/null && PackageGettext[Status]=$? || { PackageGettext[Status]=$?; EchoTest KO ${PackageGettext[Name]} && PressAnyKeyToContinue; return; };

	chmod -v 0755 /usr/lib/preloadable_libintl.so

	cd -;
}

# =====================================||===================================== #
#									 Bison									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageBison;
PackageBison[Name]="bison";
PackageBison[Version]="3.8.2";
PackageBison[Extension]=".tar.xz";
PackageBison[Package]="${PackageBison[Name]}-${PackageBison[Version]}${PackageBison[Extension]}";

InstallBison()
{
	EchoInfo	"Package ${PackageBison[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBison[Name]}-${PackageBison[Version]}"	"${PackageBison[Extension]}";

	if ! cd "${PDIR}${PackageBison[Name]}-${PackageBison[Version]}"; then
		EchoError	"cd ${PDIR}${PackageBison[Name]}-${PackageBison[Version]}";
		return;
	fi

	EchoInfo	"${PackageBison[Name]}> Configure"
	./configure --prefix=/usr \
				--docdir=/usr/share/doc/bison-3.8.2 \
				1> /dev/null || { EchoTest KO ${PackageBison[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBison[Name]}> make"
	make  1> /dev/null || { PackageBison[Status]=$?; EchoTest KO ${PackageBison[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBison[Name]}> make check"
	make check 1> /dev/null || { PackageBison[Status]=$?; EchoTest KO ${PackageBison[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageBison[Name]}> make install"
	make install 1> /dev/null && PackageBison[Status]=$? || { PackageBison[Status]=$?; EchoTest KO ${PackageBison[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									Grep									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGrep;
PackageGrep[Name]="grep";
PackageGrep[Version]="3.11";
PackageGrep[Extension]=".tar.xz";
PackageGrep[Package]="${PackageGrep[Name]}-${PackageGrep[Version]}${PackageGrep[Extension]}";

InstallGrep()
{
	EchoInfo	"Package ${PackageGrep[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGrep[Name]}-${PackageGrep[Version]}"	"${PackageGrep[Extension]}";

	if ! cd "${PDIR}${PackageGrep[Name]}-${PackageGrep[Version]}"; then
		EchoError	"cd ${PDIR}${PackageGrep[Name]}-${PackageGrep[Version]}";
		return;
	fi

	EchoInfo	"${PackageGrep[Name]}> Remove warning about egrep and fgrep"
	sed -i "s/echo/#echo/" src/egrep.sh

	EchoInfo	"${PackageGrep[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageGrep[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGrep[Name]}> make"
	make  1> /dev/null || { PackageGrep[Status]=$?; EchoTest KO ${PackageGrep[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGrep[Name]}> make check"
	make check 1> /dev/null || { PackageGrep[Status]=$?; EchoTest KO ${PackageGrep[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageGrep[Name]}> make install"
	make install 1> /dev/null && PackageGrep[Status]=$? || { PackageGrep[Status]=$?; EchoTest KO ${PackageGrep[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									Bash									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageBash;
PackageBash[Name]="bash";
PackageBash[Version]="5.2.32";
PackageBash[Extension]=".tar.gz";
PackageBash[Package]="${PackageBash[Name]}-${PackageBash[Version]}${PackageBash[Extension]}";

InstallBash()
{
	EchoInfo	"Package ${PackageBash[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBash[Name]}-${PackageBash[Version]}"	"${PackageBash[Extension]}";

	if ! cd "${PDIR}${PackageBash[Name]}-${PackageBash[Version]}"; then
		EchoError	"cd ${PDIR}${PackageBash[Name]}-${PackageBash[Version]}";
		return;
	fi

	EchoInfo	"${PackageBash[Name]}> Configure"
	./configure --prefix=/usr \
				--without-bash-malloc \
				--with-installed-readline \
				bash_cv_strtold_broken=no \
				--docdir=/usr/share/doc/bash-5.2.32 \
				1> /dev/null || { EchoTest KO ${PackageBash[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBash[Name]}> make"
	make  1> /dev/null || { PackageBash[Status]=$?; EchoTest KO ${PackageBash[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBash[Name]}> su -s /usr/bin/expect tester"
	chown -R tester .
	(su -s /usr/bin/expect tester \
		1> /dev/null\
		<< "EOF"
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF
) || { PackageBash[Status]=$?; EchoTest KO ${PackageBash[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageBash[Name]}> make install"
	make install 1> /dev/null && PackageBash[Status]=$? || { PackageBash[Status]=$?; EchoTest KO ${PackageBash[Name]} && PressAnyKeyToContinue; return; };

	echo	
	echo $BASH_VERSION;
	bash --version | grep "bash";

	cd -;

	EchoInfo	"${PackageBash[Name]}> Please run the following command outside of the script"
	printf	"${CB_BLACK}> %s ${C_RESET}\n"	"exec /usr/bin/bash --login"
}

# =====================================||===================================== #
#									Libtool									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibtool;
PackageLibtool[Name]="libtool";
PackageLibtool[Version]="2.4.7";
PackageLibtool[Extension]=".tar.xz";
PackageLibtool[Package]="${PackageLibtool[Name]}-${PackageLibtool[Version]}${PackageLibtool[Extension]}";

InstallLibtool()
{
	EchoInfo	"Package ${PackageLibtool[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLibtool[Name]}-${PackageLibtool[Version]}"	"${PackageLibtool[Extension]}";

	if ! cd "${PDIR}${PackageLibtool[Name]}-${PackageLibtool[Version]}"; then
		EchoError	"cd ${PDIR}${PackageLibtool[Name]}-${PackageLibtool[Version]}";
		return;
	fi

	EchoInfo	"${PackageLibtool[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageLibtool[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLibtool[Name]}> make"
	make  1> /dev/null || { PackageLibtool[Status]=$?; EchoTest KO ${PackageLibtool[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLibtool[Name]}> make -k check"
	make -k check 1> TempMakeCheck.log
	if [ $? -gt 0 ]; then
		local TempLibStatus=0;
		local TempCount=$(grep "^[ |0-9].*FAILED " "TempMakeCheck.log" | grep "libltdl" -c);
		if [ "$TempCount" -gt 5 ]; then
			local TempLibStatus=$((TempLibStatus+1));
			EchoTest	"KO"	"${TempCount}/5 allowed libltdl errors";

		else
			EchoTest	"OK"	"${TempCount}/5 allowed libltdl errors";
		fi
		grep "^[ |0-9].*FAILED " "TempMakeCheck.log" | grep "libltdl";

				local TempCount=$(grep "^[ |0-9].*FAILED " "TempMakeCheck.log" | grep -v "libltdl" -c);
		if [ "$TempCount" -gt 2 ]; then
			local TempLibStatus=$((TempLibStatus+1));
			EchoTest	"KO"	"${TempCount}/5 allowed miscellaneous errors";
		else
			EchoTest	"OK"	"${TempCount}/5 allowed miscellaneous errors";
		fi
		grep "^[ |0-9].*FAILED " "TempMakeCheck.log" | grep -v "libltdl";

		if [ $TempLibStatus -gt 0 ]; then
			PackageLibtool[Status]=$TempLibStatus;
			EchoTest KO ${PackageLibtool[Name]};
			PressAnyKeyToContinue;
			return;
		fi
	fi
	rm TempMakeCheck.log

	EchoInfo	"${PackageLibtool[Name]}> make install"
	make install 1> /dev/null && PackageLibtool[Status]=$? || { PackageLibtool[Status]=$?; EchoTest KO ${PackageLibtool[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLibtool[Name]}> Remove useless static library"
	rm -fv /usr/lib/libltdl.a

	cd -;
}

# =====================================||===================================== #
#									  GDBM									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGDBM;
PackageGDBM[Name]="gdbm";
PackageGDBM[Version]="1.24";
PackageGDBM[Extension]=".tar.gz";
PackageGDBM[Package]="${PackageGDBM[Name]}-${PackageGDBM[Version]}${PackageGDBM[Extension]}";

InstallGDBM()
{
	EchoInfo	"Package ${PackageGDBM[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGDBM[Name]}-${PackageGDBM[Version]}"	"${PackageGDBM[Extension]}";

	if ! cd "${PDIR}${PackageGDBM[Name]}-${PackageGDBM[Version]}"; then
		EchoError	"cd ${PDIR}${PackageGDBM[Name]}-${PackageGDBM[Version]}";
		return;
	fi

	EchoInfo	"${PackageGDBM[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--enable-libgdbm-compat \
				1> /dev/null || { EchoTest KO ${PackageGDBM[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGDBM[Name]}> make"
	make  1> /dev/null || { PackageGDBM[Status]=$?; EchoTest KO ${PackageGDBM[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGDBM[Name]}> make check"
	make check 1> /dev/null || { PackageGDBM[Status]=$?; EchoTest KO ${PackageGDBM[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageGDBM[Name]}> make install"
	make install 1> /dev/null && PackageGDBM[Status]=$? || { PackageGDBM[Status]=$?; EchoTest KO ${PackageGDBM[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									Gperf									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGperf;
PackageGperf[Name]="gperf";
PackageGperf[Version]="3.1";
PackageGperf[Extension]=".tar.gz";
PackageGperf[Package]="${PackageGperf[Name]}-${PackageGperf[Version]}${PackageGperf[Extension]}";

InstallGperf()
{
	EchoInfo	"Package ${PackageGperf[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGperf[Name]}-${PackageGperf[Version]}"	"${PackageGperf[Extension]}";

	if ! cd "${PDIR}${PackageGperf[Name]}-${PackageGperf[Version]}"; then
		EchoError	"cd ${PDIR}${PackageGperf[Name]}-${PackageGperf[Version]}";
		return;
	fi

	EchoInfo	"${PackageGperf[Name]}> Configure"
	./configure --prefix=/usr \
				--docdir=/usr/share/doc/gperf-3.1 \
				1> /dev/null || { EchoTest KO ${PackageGperf[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGperf[Name]}> make"
	make  1> /dev/null || { PackageGperf[Status]=$?; EchoTest KO ${PackageGperf[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGperf[Name]}> make -j1 check"
	make -j1 check 1> /dev/null || { PackageGperf[Status]=$?; EchoTest KO ${PackageGperf[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageGperf[Name]}> make install"
	make install 1> /dev/null && PackageGperf[Status]=$? || { PackageGperf[Status]=$?; EchoTest KO ${PackageGperf[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									 Expat									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageExpat;
PackageExpat[Name]="expat";
PackageExpat[Version]="2.6.2";
PackageExpat[Extension]=".tar.xz";
PackageExpat[Package]="${PackageExpat[Name]}-${PackageExpat[Version]}${PackageExpat[Extension]}";

InstallExpat()
{
	EchoInfo	"Package ${PackageExpat[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageExpat[Name]}-${PackageExpat[Version]}"	"${PackageExpat[Extension]}";

	if ! cd "${PDIR}${PackageExpat[Name]}-${PackageExpat[Version]}"; then
		EchoError	"cd ${PDIR}${PackageExpat[Name]}-${PackageExpat[Version]}";
		return;
	fi

	EchoInfo	"${PackageExpat[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--docdir=/usr/share/doc/expat-2.6.2 \
				1> /dev/null || { EchoTest KO ${PackageExpat[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageExpat[Name]}> make"
	make  1> /dev/null || { PackageExpat[Status]=$?; EchoTest KO ${PackageExpat[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageExpat[Name]}> make check"
	make check 1> /dev/null || { PackageExpat[Status]=$?; EchoTest KO ${PackageExpat[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageExpat[Name]}> make install"
	make install 1> /dev/null && PackageExpat[Status]=$? || { PackageExpat[Status]=$?; EchoTest KO ${PackageExpat[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageExpat[Name]}> Install documentation"
	install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.6.2 1> /dev/null

	cd -;
}

# =====================================||===================================== #
#								   Inetutils								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageInetutils;
PackageInetutils[Name]="inetutils";
PackageInetutils[Version]="2.5";
PackageInetutils[Extension]=".tar.xz";
PackageInetutils[Package]="${PackageInetutils[Name]}-${PackageInetutils[Version]}${PackageInetutils[Extension]}";

InstallInetutils()
{
	EchoInfo	"Package ${PackageInetutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageInetutils[Name]}-${PackageInetutils[Version]}"	"${PackageInetutils[Extension]}";

	if ! cd "${PDIR}${PackageInetutils[Name]}-${PackageInetutils[Version]}"; then
		EchoError	"cd ${PDIR}${PackageInetutils[Name]}-${PackageInetutils[Version]}";
		return;
	fi

	EchoInfo	"${PackageInetutils[Name]}> Configure"
	sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c
	./configure --prefix=/usr \
				--bindir=/usr/bin \
				--localstatedir=/var \
				--disable-logger \
				--disable-whois \
				--disable-rcp \
				--disable-rexec \
				--disable-rlogin \
				--disable-rsh \
				--disable-servers \
				1> /dev/null || { EchoTest KO ${PackageInetutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageInetutils[Name]}> make"
	make  1> /dev/null || { PackageInetutils[Status]=$?; EchoTest KO ${PackageInetutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageInetutils[Name]}> make check"
	make check 1> /dev/null || { PackageInetutils[Status]=$?; EchoTest KO ${PackageInetutils[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageInetutils[Name]}> make install"
	make install 1> /dev/null && PackageInetutils[Status]=$? || { PackageInetutils[Status]=$?; EchoTest KO ${PackageInetutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageInetutils[Name]}> Move ifconfig to the proper location"
	mv -v /usr/{,s}bin/ifconfig

	cd -;
}

# =====================================||===================================== #
#									  Less									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLess;
PackageLess[Name]="less";
PackageLess[Version]="661";
PackageLess[Extension]=".tar.gz";
PackageLess[Package]="${PackageLess[Name]}-${PackageLess[Version]}${PackageLess[Extension]}";

InstallLess()
{
	EchoInfo	"Package ${PackageLess[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLess[Name]}-${PackageLess[Version]}"	"${PackageLess[Extension]}";

	if ! cd "${PDIR}${PackageLess[Name]}-${PackageLess[Version]}"; then
		EchoError	"cd ${PDIR}${PackageLess[Name]}-${PackageLess[Version]}";
		return;
	fi

	EchoInfo	"${PackageLess[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				1> /dev/null || { EchoTest KO ${PackageLess[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLess[Name]}> make"
	make  1> /dev/null || { PackageLess[Status]=$?; EchoTest KO ${PackageLess[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLess[Name]}> make check"
	make check 1> /dev/null || { PackageLess[Status]=$?; EchoTest KO ${PackageLess[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageLess[Name]}> make install"
	make install 1> /dev/null && PackageLess[Status]=$? || { PackageLess[Status]=$?; EchoTest KO ${PackageLess[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									  Perl									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePerl;
PackagePerl[Name]="perl";
PackagePerl[Version]="5.40.0";
PackagePerl[Extension]=".tar.xz";
PackagePerl[Package]="${PackagePerl[Name]}-${PackagePerl[Version]}${PackagePerl[Extension]}";

InstallPerl()
{
	EchoInfo	"Package ${PackagePerl[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackagePerl[Name]}-${PackagePerl[Version]}"	"${PackagePerl[Extension]}";

	if ! cd "${PDIR}${PackagePerl[Name]}-${PackagePerl[Version]}"; then
		EchoError	"cd ${PDIR}${PackagePerl[Name]}-${PackagePerl[Version]}";
		return;
	fi

	EchoInfo	"${PackagePerl[Name]}> Configure"
	export BUILD_ZLIB=False
	export BUILD_BZIP2=0
	sh Configure -des \
				-D prefix=/usr \
				-D vendorprefix=/usr \
				-D privlib=/usr/lib/perl5/5.40/core_perl \
				-D archlib=/usr/lib/perl5/5.40/core_perl \
				-D sitelib=/usr/lib/perl5/5.40/site_perl \
				-D sitearch=/usr/lib/perl5/5.40/site_perl \
				-D vendorlib=/usr/lib/perl5/5.40/vendor_perl \
				-D vendorarch=/usr/lib/perl5/5.40/vendor_perl \
				-D man1dir=/usr/share/man/man1 \
				-D man3dir=/usr/share/man/man3 \
				-D pager="/usr/bin/less -isR" \
				-D useshrplib \
				-D usethreads \
				1> /dev/null || { EchoTest KO ${PackagePerl[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackagePerl[Name]}> make"
	make  1> /dev/null || { PackagePerl[Status]=$?; EchoTest KO ${PackagePerl[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackagePerl[Name]}> TEST_JOBS=\$(nproc) make test_harness"
	TEST_JOBS=$(nproc) make test_harness 1> /dev/null || { PackagePerl[Status]=$?; EchoTest KO ${PackagePerl[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackagePerl[Name]}> make install"
	make install 1> /dev/null && PackagePerl[Status]=$? || { PackagePerl[Status]=$?; EchoTest KO ${PackagePerl[Name]} && PressAnyKeyToContinue; return; };

	unset BUILD_ZLIB BUILD_BZIP2
	cd -;
}

# =====================================||===================================== #
#								   XMLParser								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXMLParser;
PackageXMLParser[Name]="XML-Parser";
PackageXMLParser[Version]="2.47";
PackageXMLParser[Extension]=".tar.gz";
PackageXMLParser[Package]="${PackageXMLParser[Name]}-${PackageXMLParser[Version]}${PackageXMLParser[Extension]}";

InstallXMLParser()
{
	EchoInfo	"Package ${PackageXMLParser[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageXMLParser[Name]}-${PackageXMLParser[Version]}"	"${PackageXMLParser[Extension]}";

	if ! cd "${PDIR}${PackageXMLParser[Name]}-${PackageXMLParser[Version]}"; then
		EchoError	"cd ${PDIR}${PackageXMLParser[Name]}-${PackageXMLParser[Version]}";
		return;
	fi

	EchoInfo	"${PackageXMLParser[Name]}> perl Makefile.PL"
	perl Makefile.PL 1> /dev/null || { EchoTest KO ${PackageXMLParser[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageXMLParser[Name]}> make"
	make  1> /dev/null || { PackageXMLParser[Status]=$?; EchoTest KO ${PackageXMLParser[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageXMLParser[Name]}> make test"
	make test 1> /dev/null || { PackageXMLParser[Status]=$?; EchoTest KO ${PackageXMLParser[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageXMLParser[Name]}> make install"
	make install 1> /dev/null && PackageXMLParser[Status]=$? || { PackageXMLParser[Status]=$?; EchoTest KO ${PackageXMLParser[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									Intltool								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageIntltool;
PackageIntltool[Name]="intltool";
PackageIntltool[Version]="0.51.0";
PackageIntltool[Extension]=".tar.gz";
PackageIntltool[Package]="${PackageIntltool[Name]}-${PackageIntltool[Version]}${PackageIntltool[Extension]}";

InstallIntltool()
{
	EchoInfo	"Package ${PackageIntltool[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageIntltool[Name]}-${PackageIntltool[Version]}"	"${PackageIntltool[Extension]}";

	if ! cd "${PDIR}${PackageIntltool[Name]}-${PackageIntltool[Version]}"; then
		EchoError	"cd ${PDIR}${PackageIntltool[Name]}-${PackageIntltool[Version]}";
		return;
	fi

	EchoInfo	"${PackageIntltool[Name]}> Fix a warning caused by perl-5.22+"
	sed -i 's:\\\${:\\\$\\{:' intltool-update.in

	EchoInfo	"${PackageIntltool[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageIntltool[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageIntltool[Name]}> make"
	make  1> /dev/null || { PackageIntltool[Status]=$?; EchoTest KO ${PackageIntltool[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageIntltool[Name]}> make check"
	make check 1> /dev/null || { PackageIntltool[Status]=$?; EchoTest KO ${PackageIntltool[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageIntltool[Name]}> make install"
	make install 1> /dev/null && PackageIntltool[Status]=$? || { PackageIntltool[Status]=$?; EchoTest KO ${PackageIntltool[Name]} && PressAnyKeyToContinue; return; };
	install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO || { PackageIntltool[Status]=$?; EchoTest KO ${PackageIntltool[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									Autoconf								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageAutoconf;
PackageAutoconf[Name]="autoconf";
PackageAutoconf[Version]="2.72";
PackageAutoconf[Extension]=".tar.xz";
PackageAutoconf[Package]="${PackageAutoconf[Name]}-${PackageAutoconf[Version]}${PackageAutoconf[Extension]}";

InstallAutoconf()
{
	EchoInfo	"Package ${PackageAutoconf[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageAutoconf[Name]}-${PackageAutoconf[Version]}"	"${PackageAutoconf[Extension]}";

	if ! cd "${PDIR}${PackageAutoconf[Name]}-${PackageAutoconf[Version]}"; then
		EchoError	"cd ${PDIR}${PackageAutoconf[Name]}-${PackageAutoconf[Version]}";
		return;
	fi

	EchoInfo	"${PackageAutoconf[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageAutoconf[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageAutoconf[Name]}> make"
	make  1> /dev/null || { PackageAutoconf[Status]=$?; EchoTest KO ${PackageAutoconf[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageAutoconf[Name]}> make check"
	make check 1> /dev/null || { PackageAutoconf[Status]=$?; EchoTest KO ${PackageAutoconf[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageAutoconf[Name]}> make install"
	make install 1> /dev/null && PackageAutoconf[Status]=$? || { PackageAutoconf[Status]=$?; EchoTest KO ${PackageAutoconf[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									Automake								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageAutomake;
PackageAutomake[Name]="automake";
PackageAutomake[Version]="1.17";
PackageAutomake[Extension]=".tar.xz";
PackageAutomake[Package]="${PackageAutomake[Name]}-${PackageAutomake[Version]}${PackageAutomake[Extension]}";

InstallAutomake()
{
	EchoInfo	"Package ${PackageAutomake[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageAutomake[Name]}-${PackageAutomake[Version]}"	"${PackageAutomake[Extension]}";

	if ! cd "${PDIR}${PackageAutomake[Name]}-${PackageAutomake[Version]}"; then
		EchoError	"cd ${PDIR}${PackageAutomake[Name]}-${PackageAutomake[Version]}";
		return;
	fi

	EchoInfo	"${PackageAutomake[Name]}> Configure"
	./configure --prefix=/usr \
				--docdir=/usr/share/doc/automake-1.17 \
				1> /dev/null || { EchoTest KO ${PackageAutomake[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageAutomake[Name]}> make"
	make  1> /dev/null || { PackageAutomake[Status]=$?; EchoTest KO ${PackageAutomake[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageAutomake[Name]}> make -j\$((\$(nproc)>4\?\$(nproc):4)) check"
	make -j$(($(nproc)>4?$(nproc):4)) check 1> /dev/null || { PackageAutomake[Status]=$?; EchoTest KO ${PackageAutomake[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageAutomake[Name]}> make install"
	make install 1> /dev/null && PackageAutomake[Status]=$? || { PackageAutomake[Status]=$?; EchoTest KO ${PackageAutomake[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									OpenSSL									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageOpenSSL;
PackageOpenSSL[Name]="openssl";
PackageOpenSSL[Version]="3.3.1";
PackageOpenSSL[Extension]=".tar.gz";
PackageOpenSSL[Package]="${PackageOpenSSL[Name]}-${PackageOpenSSL[Version]}${PackageOpenSSL[Extension]}";

InstallOpenSSL()
{
	EchoInfo	"Package ${PackageOpenSSL[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageOpenSSL[Name]}-${PackageOpenSSL[Version]}"	"${PackageOpenSSL[Extension]}";

	if ! cd "${PDIR}${PackageOpenSSL[Name]}-${PackageOpenSSL[Version]}"; then
		EchoError	"cd ${PDIR}${PackageOpenSSL[Name]}-${PackageOpenSSL[Version]}";
		return;
	fi

	EchoInfo	"${PackageOpenSSL[Name]}> Configure"
	./config 	--prefix=/usr \
				--openssldir=/etc/ssl \
				--libdir=lib \
				shared \
				zlib-dynamic \
				1> /dev/null || { EchoTest KO ${PackageOpenSSL[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageOpenSSL[Name]}> make"
	make  1> /dev/null || { PackageOpenSSL[Status]=$?; EchoTest KO ${PackageOpenSSL[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageOpenSSL[Name]}> HARNESS_JOBS=\$(nproc) make test"
	HARNESS_JOBS=$(nproc) make test 1> /dev/null || { PackageOpenSSL[Status]=$?; EchoTest KO ${PackageOpenSSL[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageOpenSSL[Name]}> make install"
	sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
	make MANSUFFIX=ssl install 1> /dev/null && PackageOpenSSL[Status]=$? || { PackageOpenSSL[Status]=$?; EchoTest KO ${PackageOpenSSL[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageOpenSSL[Name]}> Add version to directory name"
	mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.3.1

	EchoInfo	"${PackageOpenSSL[Name]}> Add documentation"
	cp -vfr doc/* /usr/share/doc/openssl-3.3.1

	cd -;
}

# =====================================||===================================== #
#									  Kmod									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageKmod;
PackageKmod[Name]="kmod";
PackageKmod[Version]="33";
PackageKmod[Extension]=".tar.xz";
PackageKmod[Package]="${PackageKmod[Name]}-${PackageKmod[Version]}${PackageKmod[Extension]}";

InstallKmod()
{
	EchoInfo	"Package ${PackageKmod[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageKmod[Name]}-${PackageKmod[Version]}"	"${PackageKmod[Extension]}";

	if ! cd "${PDIR}${PackageKmod[Name]}-${PackageKmod[Version]}"; then
		EchoError	"cd ${PDIR}${PackageKmod[Name]}-${PackageKmod[Version]}";
		return;
	fi

	EchoInfo	"${PackageKmod[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--with-openssl \
				--with-xz \
				--with-zstd \
				--with-zlib \
				--disable-manpages \
				1> /dev/null || { EchoTest KO ${PackageKmod[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageKmod[Name]}> make"
	make  1> /dev/null || { PackageKmod[Status]=$?; EchoTest KO ${PackageKmod[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageKmod[Name]}> make install"
	make install 1> /dev/null && PackageKmod[Status]=$? || { PackageKmod[Status]=$?; EchoTest KO ${PackageKmod[Name]} && PressAnyKeyToContinue; return; };
	for target in depmod insmod modinfo modprobe rmmod; do
		ln -sfv ../bin/kmod /usr/sbin/$target
		rm -fv /usr/bin/$target
	done

	cd -;
}

# =====================================||===================================== #
#									Elfutils								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageElfutils;
PackageElfutils[Name]="elfutils";
PackageElfutils[Version]="0.191";
PackageElfutils[Extension]=".tar.bz2";
PackageElfutils[Package]="${PackageElfutils[Name]}-${PackageElfutils[Version]}${PackageElfutils[Extension]}";

InstallElfutils()
{
	EchoInfo	"Package ${PackageElfutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageElfutils[Name]}-${PackageElfutils[Version]}"	"${PackageElfutils[Extension]}";

	if ! cd "${PDIR}${PackageElfutils[Name]}-${PackageElfutils[Version]}"; then
		EchoError	"cd ${PDIR}${PackageElfutils[Name]}-${PackageElfutils[Version]}";
		return;
	fi

	EchoInfo	"${PackageElfutils[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-debuginfod \
				--enable-libdebuginfod=dummy \
				1> /dev/null || { EchoTest KO ${PackageElfutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageElfutils[Name]}> make"
	make  1> /dev/null || { PackageElfutils[Status]=$?; EchoTest KO ${PackageElfutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageElfutils[Name]}> make check"
	make check 1> /dev/null || { PackageElfutils[Status]=$?; EchoTest KO ${PackageElfutils[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageElfutils[Name]}> make install"
	make -C libelf install 1> /dev/null && PackageElfutils[Status]=$? || { PackageElfutils[Status]=$?; EchoTest KO ${PackageElfutils[Name]} && PressAnyKeyToContinue; return; };
	install -vm644 config/libelf.pc /usr/lib/pkgconfig 1> /dev/null && PackageElfutils[Status]=$? || { PackageElfutils[Status]=$?; EchoTest KO ${PackageElfutils[Name]} && PressAnyKeyToContinue; return; };
	rm /usr/lib/libelf.a

	cd -;
}

# =====================================||===================================== #
#									 Libffi									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibffi;
PackageLibffi[Name]="libffi";
PackageLibffi[Version]="3.4.6";
PackageLibffi[Extension]=".tar.gz";
PackageLibffi[Package]="${PackageLibffi[Name]}-${PackageLibffi[Version]}${PackageLibffi[Extension]}";

InstallLibffi()
{
	EchoInfo	"Package ${PackageLibffi[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLibffi[Name]}-${PackageLibffi[Version]}"	"${PackageLibffi[Extension]}";

	if ! cd "${PDIR}${PackageLibffi[Name]}-${PackageLibffi[Version]}"; then
		EchoError	"cd ${PDIR}${PackageLibffi[Name]}-${PackageLibffi[Version]}";
		return;
	fi

	EchoInfo	"${PackageLibffi[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--with-gcc-arch=native \
				1> /dev/null || { EchoTest KO ${PackageLibffi[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLibffi[Name]}> make"
	make  1> /dev/null || { PackageLibffi[Status]=$?; EchoTest KO ${PackageLibffi[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLibffi[Name]}> make check"
	make check 1> /dev/null || { PackageLibffi[Status]=$?; EchoTest KO ${PackageLibffi[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageLibffi[Name]}> make install"
	make install 1> /dev/null && PackageLibffi[Status]=$? || { PackageLibffi[Status]=$?; EchoTest KO ${PackageLibffi[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									 Python									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePython;
PackagePython[Name]="Python";
PackagePython[Version]="3.12.5";
PackagePython[Extension]=".tar.xz";
PackagePython[Package]="${PackagePython[Name]}-${PackagePython[Version]}${PackagePython[Extension]}";

InstallPython()
{
	EchoInfo	"Package ${PackagePython[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackagePython[Name]}-${PackagePython[Version]}"	"${PackagePython[Extension]}";

	if ! cd "${PDIR}${PackagePython[Name]}-${PackagePython[Version]}"; then
		EchoError	"cd ${PDIR}${PackagePython[Name]}-${PackagePython[Version]}";
		return;
	fi

	EchoInfo	"${PackagePython[Name]}> Configure"
	./configure --prefix=/usr \
				--enable-shared \
				--with-system-expat \
				--enable-optimizations \
				1> /dev/null || { EchoTest KO ${PackagePython[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackagePython[Name]}> make"
	make  1> /dev/null || { PackagePython[Status]=$?; EchoTest KO ${PackagePython[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackagePython[Name]}> make test TESTOPTS=\"--timeout 120\""
	make test TESTOPTS="--timeout 120" 1> /dev/null || { PackagePython[Status]=$?; EchoTest KO ${PackagePython[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackagePython[Name]}> make install"
	make install 1> /dev/null && PackagePython[Status]=$? || { PackagePython[Status]=$?; EchoTest KO ${PackagePython[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackagePython[Name]}> Silence pip3 warning"
	cat > /etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF

	EchoInfo	"${PackagePython[Name]}> Install documentation"
	install -v \
			-dm755 /usr/share/doc/python-3.12.5/html \
			1> /dev/null
	tar 	--no-same-owner \
			-xvf ../python-3.12.5-docs-html.tar.bz2 \
			1> /dev/null
	cp -R \
		--no-preserve=mode python-3.12.5-docs-html/* \
		/usr/share/doc/python-3.12.5/html \
		1> /dev/null

	cd -;
}

# =====================================||===================================== #
#									FlitCore								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageFlitCore;
PackageFlitCore[Name]="flit_core";
PackageFlitCore[Version]="3.9.0";
PackageFlitCore[Extension]=".tar.gz";
PackageFlitCore[Package]="${PackageFlitCore[Name]}-${PackageFlitCore[Version]}${PackageFlitCore[Extension]}";

InstallFlitCore()
{
	EchoInfo	"Package ${PackageFlitCore[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageFlitCore[Name]}-${PackageFlitCore[Version]}"	"${PackageFlitCore[Extension]}";

	if ! cd "${PDIR}${PackageFlitCore[Name]}-${PackageFlitCore[Version]}"; then
		EchoError	"cd ${PDIR}${PackageFlitCore[Name]}-${PackageFlitCore[Version]}";
		return;
	fi

	EchoInfo	"${PackageFlitCore[Name]}> pip3 Build"
	pip3 wheel 	-w dist \
				--no-cache-dir \
				--no-build-isolation \
				--no-deps \
				$PWD 1> /dev/null || { PackageFlitCore[Status]=$?; EchoTest KO ${PackageFlitCore[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageFlitCore[Name]}> pip3 Install"
	pip3 install 	--no-index \
					--no-user \
					--find-links dist flit_core \
					1> /dev/null && PackagePython[Status]=$? || { PackageFlitCore[Status]=$?; EchoTest KO ${PackageFlitCore[Name]} && PressAnyKeyToContinue; return; };
	
	cd -;
}

# =====================================||===================================== #
#									 Wheel									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageWheel;
PackageWheel[Name]="wheel";
PackageWheel[Version]="0.44.0";
PackageWheel[Extension]=".tar.gz";
PackageWheel[Package]="${PackageWheel[Name]}-${PackageWheel[Version]}${PackageWheel[Extension]}";

InstallWheel()
{
	EchoInfo	"Package ${PackageWheel[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageWheel[Name]}-${PackageWheel[Version]}"	"${PackageWheel[Extension]}";

	if ! cd "${PDIR}${PackageWheel[Name]}-${PackageWheel[Version]}"; then
		EchoError	"cd ${PDIR}${PackageWheel[Name]}-${PackageWheel[Version]}";
		return;
	fi

	EchoInfo	"${PackageWheel[Name]}> pip3 Compile"
	pip3 wheel 	-w dist \
				--no-cache-dir \
				--no-build-isolation \
				--no-deps \
				$PWD \
				1> /dev/null || { EchoTest KO ${PackageWheel[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageWheel[Name]}> pip3 Install"
	pip3 install 	--no-index \
					--find-links=dist \
					wheel \
					1> /dev/null && PackageWheel[Status]=$? || { PackageWheel[Status]=$?; EchoTest KO ${PackageWheel[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#								   Setuptools								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageSetuptools;
PackageSetuptools[Name]="setuptools";
PackageSetuptools[Version]="72.2.0";
PackageSetuptools[Extension]=".tar.gz";
PackageSetuptools[Package]="${PackageSetuptools[Name]}-${PackageSetuptools[Version]}${PackageSetuptools[Extension]}";

InstallSetuptools()
{
	EchoInfo	"Package ${PackageSetuptools[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageSetuptools[Name]}-${PackageSetuptools[Version]}"	"${PackageSetuptools[Extension]}";

	if ! cd "${PDIR}${PackageSetuptools[Name]}-${PackageSetuptools[Version]}"; then
		EchoError	"cd ${PDIR}${PackageSetuptools[Name]}-${PackageSetuptools[Version]}";
		return;
	fi

	EchoInfo	"${PackageSetuptools[Name]}> pip3 Build"
	pip3 wheel 	-w dist \
				--no-cache-dir \
				--no-build-isolation \
				--no-deps \
				$PWD \
				1> /dev/null || { PackageSetuptools[Status]=$?; EchoTest KO ${PackageSetuptools[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageSetuptools[Name]}> pip3 Install"
	pip3 install 	--no-index \
					--find-links dist setuptools \
					1> /dev/null && PackageSetuptools[Status]=$? || { PackageSetuptools[Status]=$?; EchoTest KO ${PackageSetuptools[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									 Ninja									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageNinja;
PackageNinja[Name]="ninja";
PackageNinja[Version]="1.12.1";
PackageNinja[Extension]=".tar.gz";
PackageNinja[Package]="${PackageNinja[Name]}-${PackageNinja[Version]}${PackageNinja[Extension]}";

InstallNinja()
{
	EchoInfo	"Package ${PackageNinja[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageNinja[Name]}-${PackageNinja[Version]}"	"${PackageNinja[Extension]}";

	if ! cd "${PDIR}${PackageNinja[Name]}-${PackageNinja[Version]}"; then
		EchoError	"cd ${PDIR}${PackageNinja[Name]}-${PackageNinja[Version]}";
		return;
	fi

	EchoInfo	"${PackageNinja[Name]}> Limit parallel processes"
	export NINJAJOBS=4
	sed -i '/int Guess/a \
int
j = 0;\
char* jobs = getenv( "NINJAJOBS" );\
if ( jobs != NULL ) j = atoi( jobs );\
if ( j > 0 ) return j;\
' src/ninja.cc

	EchoInfo	"${PackageNinja[Name]}> python3 build"
	python3 configure.py --bootstrap 1> /dev/null || { EchoTest KO ${PackageNinja[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageNinja[Name]}> install"
	install -vm755 ninja /usr/bin/ 1> /dev/nul && \
	install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja 1> /dev/nul && \
	install -vDm644 misc/zsh-completion /usr/share/zsh/site-functions/_ninja 1> /dev/null && \
	PackageNinja[Status]=$? || { PackageNinja[Status]=$?; EchoTest KO ${PackageNinja[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									 Meson									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMeson;
PackageMeson[Name]="meson";
PackageMeson[Version]="1.5.1";
PackageMeson[Extension]=".tar.gz";
PackageMeson[Package]="${PackageMeson[Name]}-${PackageMeson[Version]}${PackageMeson[Extension]}";

InstallMeson()
{
	EchoInfo	"Package ${PackageMeson[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageMeson[Name]}-${PackageMeson[Version]}"	"${PackageMeson[Extension]}";

	if ! cd "${PDIR}${PackageMeson[Name]}-${PackageMeson[Version]}"; then
		EchoError	"cd ${PDIR}${PackageMeson[Name]}-${PackageMeson[Version]}";
		return;
	fi

	EchoInfo	"${PackageMeson[Name]}> pip3 Compile"
	pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD 1> /dev/null || { EchoTest KO ${PackageMeson[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageMeson[Name]}> pip3 Install"
	pip3 install --no-index --find-links dist meson 1> /dev/null && \
	install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson 1> /dev/null && \
	install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson 1> /dev/null && \
	PackageMeson[Status]=$? || { PackageMeson[Status]=$?; EchoTest KO ${PackageMeson[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#								   Coreutils								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageCoreutils;
PackageCoreutils[Name]="coreutils";
PackageCoreutils[Version]="9.5";
PackageCoreutils[Extension]=".tar.xz";
PackageCoreutils[Package]="${PackageCoreutils[Name]}-${PackageCoreutils[Version]}${PackageCoreutils[Extension]}";

InstallCoreutils()
{
	EchoInfo	"Package ${PackageCoreutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageCoreutils[Name]}-${PackageCoreutils[Version]}"	"${PackageCoreutils[Extension]}";

	if ! cd "${PDIR}${PackageCoreutils[Name]}-${PackageCoreutils[Version]}"; then
		EchoError	"cd ${PDIR}${PackageCoreutils[Name]}-${PackageCoreutils[Version]}";
		return;
	fi

	EchoInfo	"${PackageCoreutils[Name]}> Patch"
	patch -Np1 -i ../coreutils-9.5-i18n-2.patch 1> /dev/null

	EchoInfo	"${PackageCoreutils[Name]}> Configure"
	autoreconf -fiv 1> /dev/null
	FORCE_UNSAFE_CONFIGURE=1 ./configure 	--prefix=/usr \
											--enable-no-install-program=kill,uptime \
											1> /dev/null || { EchoTest KO ${PackageCoreutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageCoreutils[Name]}> make"
	make  1> /dev/null || { PackageCoreutils[Status]=$?; EchoTest KO ${PackageCoreutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageCoreutils[Name]}> make NON_ROOT_USERNAME=tester check-root"
	make NON_ROOT_USERNAME=tester check-root 1> /dev/null || { PackageCoreutils[Status]=$?; EchoTest KO ${PackageCoreutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageCoreutils[Name]}> make test (as tester in dummy group)"
	groupadd -g 102 dummy -U tester
	chown -R tester .
	su tester -c "PATH=$PATH make -k RUN_EXPENSIVE_TESTS=yes check" \
		< /dev/null 1> /dev/null
	groupdel dummy

	EchoInfo	"${PackageCoreutils[Name]}> make install"
	make install 1> /dev/null && PackageCoreutils[Status]=$? || { PackageCoreutils[Status]=$?; EchoTest KO ${PackageCoreutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageCoreutils[Name]}> Move programs"
	mv -v /usr/bin/chroot /usr/sbin
	mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
	sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8

	cd -;
}

# =====================================||===================================== #
#									 Check									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageCheck;
PackageCheck[Name]="check";
PackageCheck[Version]="0.15.2";
PackageCheck[Extension]=".tar.gz";
PackageCheck[Package]="${PackageCheck[Name]}-${PackageCheck[Version]}${PackageCheck[Extension]}";

InstallCheck()
{
	EchoInfo	"Package ${PackageCheck[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageCheck[Name]}-${PackageCheck[Version]}"	"${PackageCheck[Extension]}";

	if ! cd "${PDIR}${PackageCheck[Name]}-${PackageCheck[Version]}"; then
		EchoError	"cd ${PDIR}${PackageCheck[Name]}-${PackageCheck[Version]}";
		return;
	fi

	EchoInfo	"${PackageCheck[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageCheck[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageCheck[Name]}> make"
	make  1> /dev/null || { PackageCheck[Status]=$?; EchoTest KO ${PackageCheck[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageCheck[Name]}> make check"
	make check 1> /dev/null || { PackageCheck[Status]=$?; EchoTest KO ${PackageCheck[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageCheck[Name]}> make docdir=/usr/share/doc/check-0.15.2 install"
	make docdir=/usr/share/doc/check-0.15.2 install 1> /dev/null && PackageCheck[Status]=$? || { PackageCheck[Status]=$?; EchoTest KO ${PackageCheck[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#								   Diffutils								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageDiffutils;
PackageDiffutils[Name]="diffutils";
PackageDiffutils[Version]="3.10";
PackageDiffutils[Extension]=".tar.xz";
PackageDiffutils[Package]="${PackageDiffutils[Name]}-${PackageDiffutils[Version]}${PackageDiffutils[Extension]}";

InstallDiffutils()
{
	EchoInfo	"Package ${PackageDiffutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageDiffutils[Name]}-${PackageDiffutils[Version]}"	"${PackageDiffutils[Extension]}";

	if ! cd "${PDIR}${PackageDiffutils[Name]}-${PackageDiffutils[Version]}"; then
		EchoError	"cd ${PDIR}${PackageDiffutils[Name]}-${PackageDiffutils[Version]}";
		return;
	fi

	EchoInfo	"${PackageDiffutils[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageDiffutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageDiffutils[Name]}> make"
	make  1> /dev/null || { PackageDiffutils[Status]=$?; EchoTest KO ${PackageDiffutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageDiffutils[Name]}> make check"
	make check 1> /dev/null || { PackageDiffutils[Status]=$?; EchoTest KO ${PackageDiffutils[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageDiffutils[Name]}> make install"
	make install 1> /dev/null && PackageDiffutils[Status]=$? || { PackageDiffutils[Status]=$?; EchoTest KO ${PackageDiffutils[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									  Gawk									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGawk;
PackageGawk[Name]="gawk";
PackageGawk[Version]="5.3.0";
PackageGawk[Extension]=".tar.xz";
PackageGawk[Package]="${PackageGawk[Name]}-${PackageGawk[Version]}${PackageGawk[Extension]}";

InstallGawk()
{
	EchoInfo	"Package ${PackageGawk[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGawk[Name]}-${PackageGawk[Version]}"	"${PackageGawk[Extension]}";

	if ! cd "${PDIR}${PackageGawk[Name]}-${PackageGawk[Version]}"; then
		EchoError	"cd ${PDIR}${PackageGawk[Name]}-${PackageGawk[Version]}";
		return;
	fi

	sed -i 's/extras//' Makefile.in

	EchoInfo	"${PackageGawk[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageGawk[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGawk[Name]}> make"
	make  1> /dev/null || { PackageGawk[Status]=$?; EchoTest KO ${PackageGawk[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGawk[Name]}> su tester -c \"PATH=$PATH make check\""
	chown -R tester .
	su tester -c "PATH=$PATH make check" 1> /dev/null || { PackageGawk[Status]=$?; EchoTest KO ${PackageGawk[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGawk[Name]}> make install"
	rm -f /usr/bin/gawk-5.3.0
	make install 1> /dev/null && PackageGawk[Status]=$? || { PackageGawk[Status]=$?; EchoTest KO ${PackageGawk[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageGawk[Name]}> symlink awk to gawk"
	ln -sv gawk.1 /usr/share/man/man1/awk.1

	EchoInfo	"${PackageGawk[Name]}> install documentation"
	mkdir 	-pv 									/usr/share/doc/gawk-5.3.0
	cp 		-v 	doc/{awkforai.txt,*.{eps,pdf,jpg}} 	/usr/share/doc/gawk-5.3.0 1> /dev/null

	cd -;
}

# =====================================||===================================== #
#								   Findutils								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageFindutils;
PackageFindutils[Name]="findutils";
PackageFindutils[Version]="4.10.0";
PackageFindutils[Extension]=".tar.xz";
PackageFindutils[Package]="${PackageFindutils[Name]}-${PackageFindutils[Version]}${PackageFindutils[Extension]}";

InstallFindutils()
{
	EchoInfo	"Package ${PackageFindutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageFindutils[Name]}-${PackageFindutils[Version]}"	"${PackageFindutils[Extension]}";

	if ! cd "${PDIR}${PackageFindutils[Name]}-${PackageFindutils[Version]}"; then
		EchoError	"cd ${PDIR}${PackageFindutils[Name]}-${PackageFindutils[Version]}";
		return;
	fi

	EchoInfo	"${PackageFindutils[Name]}> Configure"
	./configure --prefix=/usr \
				--localstatedir=/var/lib/locate \
				1> /dev/null || { EchoTest KO ${PackageFindutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageFindutils[Name]}> make"
	make  1> /dev/null || { PackageFindutils[Status]=$?; EchoTest KO ${PackageFindutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageFindutils[Name]}> su tester -c \"PATH=\$PATH make check\""
	chown -R tester .
	su tester -c "PATH=$PATH make check" 1> /dev/null || { PackageFindutils[Status]=$?; EchoTest KO ${PackageFindutils[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageFindutils[Name]}> make install"
	make install 1> /dev/null && PackageFindutils[Status]=$? || { PackageFindutils[Status]=$?; EchoTest KO ${PackageFindutils[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									 Groff									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGroff;
PackageGroff[Name]="groff";
PackageGroff[Version]="1.23.0";
PackageGroff[Extension]=".tar.gz";
PackageGroff[Package]="${PackageGroff[Name]}-${PackageGroff[Version]}${PackageGroff[Extension]}";

InstallGroff()
{
	EchoInfo	"Package ${PackageGroff[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGroff[Name]}-${PackageGroff[Version]}"	"${PackageGroff[Extension]}";

	if ! cd "${PDIR}${PackageGroff[Name]}-${PackageGroff[Version]}"; then
		EchoError	"cd ${PDIR}${PackageGroff[Name]}-${PackageGroff[Version]}";
		return;
	fi

	EchoInfo	"${PackageGroff[Name]}> Configure"
	PAGE=A4 ./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageGroff[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGroff[Name]}> make"
	make  1> /dev/null || { PackageGroff[Status]=$?; EchoTest KO ${PackageGroff[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGroff[Name]}> make check"
	make check 1> /dev/null || { PackageGroff[Status]=$?; EchoTest KO ${PackageGroff[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageGroff[Name]}> make install"
	make install 1> /dev/null && PackageGroff[Status]=$? || { PackageGroff[Status]=$?; EchoTest KO ${PackageGroff[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									  GRUB									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGRUB;
PackageGRUB[Name]="grub";
PackageGRUB[Version]="2.12";
PackageGRUB[Extension]=".tar.xz";
PackageGRUB[Package]="${PackageGRUB[Name]}-${PackageGRUB[Version]}${PackageGRUB[Extension]}";

InstallGRUB()
{
	EchoInfo	"Package ${PackageGRUB[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGRUB[Name]}-${PackageGRUB[Version]}"	"${PackageGRUB[Extension]}";

	if ! cd "${PDIR}${PackageGRUB[Name]}-${PackageGRUB[Version]}"; then
		EchoError	"cd ${PDIR}${PackageGRUB[Name]}-${PackageGRUB[Version]}";
		return;
	fi

	unset {C,CPP,CXX,LD}FLAGS
	echo depends bli part_gpt > grub-core/extra_deps.lst

	EchoInfo	"${PackageGRUB[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--disable-efiemu \
				--disable-werror \
				1> /dev/null || { EchoTest KO ${PackageGRUB[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGRUB[Name]}> make"
	make  1> /dev/null || { PackageGRUB[Status]=$?; EchoTest KO ${PackageGRUB[Name]} && PressAnyKeyToContinue; return; };

	# EchoInfo	"${PackageGRUB[Name]}> make check"
	# make check 1> /dev/null || { PackageGRUB[Status]=$?; EchoTest KO ${PackageGRUB[Name]} && EchoInfo "Most of the tests depend on packages that are not available in the limited LFS environment." && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageGRUB[Name]}> make install"
	make install 1> /dev/null && PackageGRUB[Status]=$? || { PackageGRUB[Status]=$?; EchoTest KO ${PackageGRUB[Name]} && PressAnyKeyToContinue; return; };
	mv -v 	/etc/bash_completion.d/grub 	/usr/share/bash-completion/completions

	cd -;
}

# =====================================||===================================== #
#									  Gzip									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGzip;
PackageGzip[Name]="gzip";
PackageGzip[Version]="1.13";
PackageGzip[Extension]=".tar.xz";
PackageGzip[Package]="${PackageGzip[Name]}-${PackageGzip[Version]}${PackageGzip[Extension]}";

InstallGzip()
{
	EchoInfo	"Package ${PackageGzip[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGzip[Name]}-${PackageGzip[Version]}"	"${PackageGzip[Extension]}";

	if ! cd "${PDIR}${PackageGzip[Name]}-${PackageGzip[Version]}"; then
		EchoError	"cd ${PDIR}${PackageGzip[Name]}-${PackageGzip[Version]}";
		return;
	fi

	EchoInfo	"${PackageGzip[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageGzip[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGzip[Name]}> make"
	make  1> /dev/null || { PackageGzip[Status]=$?; EchoTest KO ${PackageGzip[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGzip[Name]}> make check"
	make check 1> /dev/null || { PackageGzip[Status]=$?; EchoTest KO ${PackageGzip[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageGzip[Name]}> make install"
	make install 1> /dev/null && PackageGzip[Status]=$? || { PackageGzip[Status]=$?; EchoTest KO ${PackageGzip[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									IPRoute2								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageIPRoute2;
PackageIPRoute2[Name]="iproute2";
PackageIPRoute2[Version]="6.10.0";
PackageIPRoute2[Extension]=".tar.xz";
PackageIPRoute2[Package]="${PackageIPRoute2[Name]}-${PackageIPRoute2[Version]}${PackageIPRoute2[Extension]}";

InstallIPRoute2()
{
	EchoInfo	"Package ${PackageIPRoute2[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageIPRoute2[Name]}-${PackageIPRoute2[Version]}"	"${PackageIPRoute2[Extension]}";

	if ! cd "${PDIR}${PackageIPRoute2[Name]}-${PackageIPRoute2[Version]}"; then
		EchoError	"cd ${PDIR}${PackageIPRoute2[Name]}-${PackageIPRoute2[Version]}";
		return;
	fi

	EchoInfo	"${PackageIPRoute2[Name]}> Prevent arpd man page"
	sed -i /ARPD/d Makefile
	rm -fv man/man8/arpd.8

	EchoInfo	"${PackageIPRoute2[Name]}> make NETNS_RUN_DIR=/run/netns"
	make NETNS_RUN_DIR=/run/netns 1> /dev/null || { PackageIPRoute2[Status]=$?; EchoTest KO ${PackageIPRoute2[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageIPRoute2[Name]}> make SBINDIR=/usr/sbin install"
	make SBINDIR=/usr/sbin install 1> /dev/null && PackageIPRoute2[Status]=$? || { PackageIPRoute2[Status]=$?; EchoTest KO ${PackageIPRoute2[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageIPRoute2[Name]}> Install documentation"
	mkdir 	-pv 				/usr/share/doc/iproute2-6.10.0
	cp 		-v COPYING README* 	/usr/share/doc/iproute2-6.10.0 1> /dev/null

	cd -;
}

# =====================================||===================================== #
#									  Kbd									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageKbd;
PackageKbd[Name]="kbd";
PackageKbd[Version]="2.6.4";
PackageKbd[Extension]=".tar.xz";
PackageKbd[Package]="${PackageKbd[Name]}-${PackageKbd[Version]}${PackageKbd[Extension]}";

InstallKbd()
{
	EchoInfo	"Package ${PackageKbd[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageKbd[Name]}-${PackageKbd[Version]}"	"${PackageKbd[Extension]}";

	if ! cd "${PDIR}${PackageKbd[Name]}-${PackageKbd[Version]}"; then
		EchoError	"cd ${PDIR}${PackageKbd[Name]}-${PackageKbd[Version]}";
		return;
	fi

	EchoInfo	"${PackageKbd[Name]}> Patch"
	patch -Np1 -i ../kbd-2.6.4-backspace-1.patch 1> /dev/null || { EchoTest KO ${PackageKbd[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageKbd[Name]}> Remove redundant resizecons program"
	sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
	sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

	EchoInfo	"${PackageKbd[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-vlock \
				1> /dev/null || { EchoTest KO ${PackageKbd[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageKbd[Name]}> make"
	make  1> /dev/null || { PackageKbd[Status]=$?; EchoTest KO ${PackageKbd[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageKbd[Name]}> make check"
	make check 1> /dev/null || { PackageKbd[Status]=$?; EchoTest KO ${PackageKbd[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageKbd[Name]}> make install"
	make install 1> /dev/null && PackageKbd[Status]=$? || { PackageKbd[Status]=$?; EchoTest KO ${PackageKbd[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageIPRoute2[Name]}> Install documentation"
	cp -R -v docs/doc -T /usr/share/doc/kbd-2.6.4

	cd -;
}

# =====================================||===================================== #
#								  Libpipeline								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibpipeline;
PackageLibpipeline[Name]="libpipeline";
PackageLibpipeline[Version]="1.5.7";
PackageLibpipeline[Extension]=".tar.gz";
PackageLibpipeline[Package]="${PackageLibpipeline[Name]}-${PackageLibpipeline[Version]}${PackageLibpipeline[Extension]}";

InstallLibpipeline()
{
	EchoInfo	"Package ${PackageLibpipeline[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLibpipeline[Name]}-${PackageLibpipeline[Version]}"	"${PackageLibpipeline[Extension]}";

	if ! cd "${PDIR}${PackageLibpipeline[Name]}-${PackageLibpipeline[Version]}"; then
		EchoError	"cd ${PDIR}${PackageLibpipeline[Name]}-${PackageLibpipeline[Version]}";
		return;
	fi

	EchoInfo	"${PackageLibpipeline[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageLibpipeline[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLibpipeline[Name]}> make"
	make  1> /dev/null || { PackageLibpipeline[Status]=$?; EchoTest KO ${PackageLibpipeline[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLibpipeline[Name]}> make check"
	make check 1> /dev/null || { PackageLibpipeline[Status]=$?; EchoTest KO ${PackageLibpipeline[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageLibpipeline[Name]}> make install"
	make install 1> /dev/null && PackageLibpipeline[Status]=$? || { PackageLibpipeline[Status]=$?; EchoTest KO ${PackageLibpipeline[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									  Make									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMake;
PackageMake[Name]="make";
PackageMake[Version]="4.4.1";
PackageMake[Extension]=".tar.gz";
PackageMake[Package]="${PackageMake[Name]}-${PackageMake[Version]}${PackageMake[Extension]}";

InstallMake()
{
	EchoInfo	"Package ${PackageMake[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageMake[Name]}-${PackageMake[Version]}"	"${PackageMake[Extension]}";

	if ! cd "${PDIR}${PackageMake[Name]}-${PackageMake[Version]}"; then
		EchoError	"cd ${PDIR}${PackageMake[Name]}-${PackageMake[Version]}";
		return;
	fi

	EchoInfo	"${PackageMake[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageMake[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageMake[Name]}> make"
	make  1> /dev/null || { PackageMake[Status]=$?; EchoTest KO ${PackageMake[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageMake[Name]}> su tester -c \"PATH=\$PATH make check\""
	chown -R tester .
	su tester -c "PATH=$PATH make check" 1> /dev/null || { PackageMake[Status]=$?; EchoTest KO ${PackageMake[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageMake[Name]}> make install"
	make install 1> /dev/null && PackageMake[Status]=$? || { PackageMake[Status]=$?; EchoTest KO ${PackageMake[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									 Patch									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePatch;
PackagePatch[Name]="patch";
PackagePatch[Version]="2.7.6";
PackagePatch[Extension]=".tar.xz";
PackagePatch[Package]="${PackagePatch[Name]}-${PackagePatch[Version]}${PackagePatch[Extension]}";

InstallPatch()
{
	EchoInfo	"Package ${PackagePatch[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackagePatch[Name]}-${PackagePatch[Version]}"	"${PackagePatch[Extension]}";

	if ! cd "${PDIR}${PackagePatch[Name]}-${PackagePatch[Version]}"; then
		EchoError	"cd ${PDIR}${PackagePatch[Name]}-${PackagePatch[Version]}";
		return;
	fi

	EchoInfo	"${PackagePatch[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackagePatch[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackagePatch[Name]}> make"
	make  1> /dev/null || { PackagePatch[Status]=$?; EchoTest KO ${PackagePatch[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackagePatch[Name]}> make check"
	make check 1> /dev/null || { PackagePatch[Status]=$?; EchoTest KO ${PackagePatch[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackagePatch[Name]}> make install"
	make install 1> /dev/null && PackagePatch[Status]=$? || { PackagePatch[Status]=$?; EchoTest KO ${PackagePatch[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									  Tar									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageTar;
PackageTar[Name]="tar";
PackageTar[Version]="1.35";
PackageTar[Extension]=".tar.xz";
PackageTar[Package]="${PackageTar[Name]}-${PackageTar[Version]}${PackageTar[Extension]}";

InstallTar()
{
	EchoInfo	"Package ${PackageTar[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageTar[Name]}-${PackageTar[Version]}"	"${PackageTar[Extension]}";

	if ! cd "${PDIR}${PackageTar[Name]}-${PackageTar[Version]}"; then
		EchoError	"cd ${PDIR}${PackageTar[Name]}-${PackageTar[Version]}";
		return;
	fi

	EchoInfo	"${PackageTar[Name]}> Configure"
	FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageTar[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageTar[Name]}> make"
	make  1> /dev/null || { PackageTar[Status]=$?; EchoTest KO ${PackageTar[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageTar[Name]}> make check"
	make check > TempMakeCheck.log || \
	if [ $(grep "^[ |0-9].*FAILED " "TempMakeCheck.log" | grep -v "capabilities: binary store/restore" -c) -gt 0 ]; then
		EchoTest KO ${PackageTar[Name]};
		grep "^[ |0-9].*FAILED " "TempMakeCheck.log";
		PackageTar[Status]=$(grep "^[ |0-9].*FAILED " "TempMakeCheck.log" -c);
		PressAnyKeyToContinue;
		return;
	else
		EchoTest OK ${PackageTar[Name]};
		grep "^[ |0-9].*FAILED " "TempMakeCheck.log";
		rm TempMakeCheck.log;
	fi
	
	EchoInfo	"${PackageTar[Name]}> make install"
	make install 1> /dev/null && PackageTar[Status]=$? || { PackageTar[Status]=$?; EchoTest KO ${PackageTar[Name]} && PressAnyKeyToContinue; return; };
	make -C doc install-html docdir=/usr/share/doc/tar-1.35 1> /dev/null && PackageTar[Status]=$? || { PackageTar[Status]=$?; EchoTest KO ${PackageTar[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									Texinfo									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageTexinfo;
PackageTexinfo[Name]="texinfo";
PackageTexinfo[Version]="7.1";
PackageTexinfo[Extension]=".tar.xz";
PackageTexinfo[Package]="${PackageTexinfo[Name]}-${PackageTexinfo[Version]}${PackageTexinfo[Extension]}";

InstallTexinfo()
{
	EchoInfo	"Package ${PackageTexinfo[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageTexinfo[Name]}-${PackageTexinfo[Version]}"	"${PackageTexinfo[Extension]}";

	if ! cd "${PDIR}${PackageTexinfo[Name]}-${PackageTexinfo[Version]}"; then
		EchoError	"cd ${PDIR}${PackageTexinfo[Name]}-${PackageTexinfo[Version]}";
		return;
	fi

	EchoInfo	"${PackageTexinfo[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageTexinfo[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageTexinfo[Name]}> make"
	make  1> /dev/null || { PackageTexinfo[Status]=$?; EchoTest KO ${PackageTexinfo[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageTexinfo[Name]}> make check"
	make check 1> /dev/null || { PackageTexinfo[Status]=$?; EchoTest KO ${PackageTexinfo[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageTexinfo[Name]}> make install"
	make install 1> /dev/null && PackageTexinfo[Status]=$? || { PackageTexinfo[Status]=$?; EchoTest KO ${PackageTexinfo[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageTexinfo[Name]}> TEXMF=/usr/share/texmf install-tex"
	make TEXMF=/usr/share/texmf install-tex 1> /dev/null && PackageTexinfo[Status]=$? || { PackageTexinfo[Status]=$?; EchoTest KO ${PackageTexinfo[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageTexinfo[Name]}> (Re)create /usr/share/info/dir"
	pushd /usr/share/info
		rm -v dir
		for f in *
			do install-info $f dir 2>/dev/null
		done
	popd

	cd -;
}

# =====================================||===================================== #
#									  Vim									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageVim;
PackageVim[Name]="vim";
PackageVim[Version]="9.1.0660";
PackageVim[Extension]=".tar.gz";
PackageVim[Package]="${PackageVim[Name]}-${PackageVim[Version]}${PackageVim[Extension]}";

InstallVim()
{
	EchoInfo	"Package ${PackageVim[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageVim[Name]}-${PackageVim[Version]}"	"${PackageVim[Extension]}";

	if ! cd "${PDIR}${PackageVim[Name]}-${PackageVim[Version]}"; then
		EchoError	"cd ${PDIR}${PackageVim[Name]}-${PackageVim[Version]}";
		return;
	fi

	EchoInfo	"${PackageVim[Name]}> Setting default location for vimrc to /etc";
	echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

	EchoInfo	"${PackageVim[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageVim[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageVim[Name]}> make"
	make  1> /dev/null || { PackageVim[Status]=$?; EchoTest KO ${PackageVim[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageVim[Name]}> make check"
	chown -R tester .
	su tester -c "TERM=xterm-256color LANG=en_US.UTF-8 make -j1 test" < /dev/null &> vim-test.log
	
	EchoInfo	"${PackageVim[Name]}> make install"
	make install 1> /dev/null && PackageVim[Status]=$? || { PackageVim[Status]=$?; EchoTest KO ${PackageVim[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageVim[Name]}> Create symlink from vi to vim"
	ln -sv vim /usr/bin/vi
	for L in /usr/share/man/{,*/}man1/vim.1; do
		ln -sv vim.1 $(dirname $L)/vi.1
	done

	EchoInfo	"${PackageVim[Name]}> Create symlink for doc"
	ln -sv ../vim/vim91/doc /usr/share/doc/vim-9.1.0660

	EchoInfo	"${PackageVim[Name]}> Create default configuration file"
	cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc
" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1
set nocompatible
set backspace=2
set mouse=
set number
syntax on
if (&term == "xterm") || (&term == "putty")
set background=dark
endif
" End /etc/vimrc
EOF

	EchoInfo	">vim -c ':options' for more settin options";

	cd -;
}

# =====================================||===================================== #
#								   MarkupSafe								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMarkupSafe;
PackageMarkupSafe[Name]="MarkupSafe";
PackageMarkupSafe[Version]="2.1.5";
PackageMarkupSafe[Extension]=".tar.gz";
PackageMarkupSafe[Package]="${PackageMarkupSafe[Name]}-${PackageMarkupSafe[Version]}${PackageMarkupSafe[Extension]}";

InstallMarkupSafe()
{
	EchoInfo	"Package ${PackageMarkupSafe[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageMarkupSafe[Name]}-${PackageMarkupSafe[Version]}"	"${PackageMarkupSafe[Extension]}";

	if ! cd "${PDIR}${PackageMarkupSafe[Name]}-${PackageMarkupSafe[Version]}"; then
		EchoError	"cd ${PDIR}${PackageMarkupSafe[Name]}-${PackageMarkupSafe[Version]}";
		return;
	fi

	EchoInfo	"${PackageMarkupSafe[Name]}> pip3 Compile"
	pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD 1> /dev/null || { EchoTest KO ${PackageMarkupSafe[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageMarkupSafe[Name]}> pip3 Install"
	pip3 install --no-index --no-user --find-links dist Markupsafe 1> /dev/null && PackageMarkupSafe[Status]=$? || { PackageMarkupSafe[Status]=$?; EchoTest KO ${PackageMarkupSafe[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									 Jinja2									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageJinja2;
PackageJinja2[Name]="jinja2";
PackageJinja2[Version]="3.1.4";
PackageJinja2[Extension]=".tar.gz";
PackageJinja2[Package]="${PackageJinja2[Name]}-${PackageJinja2[Version]}${PackageJinja2[Extension]}";

InstallJinja2()
{
	EchoInfo	"Package ${PackageJinja2[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageJinja2[Name]}-${PackageJinja2[Version]}"	"${PackageJinja2[Extension]}";

	if ! cd "${PDIR}${PackageJinja2[Name]}-${PackageJinja2[Version]}"; then
		EchoError	"cd ${PDIR}${PackageJinja2[Name]}-${PackageJinja2[Version]}";
		return;
	fi

	EchoInfo	"${PackageJinja2[Name]}> pip3 Build"
	pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD 1> /dev/null || { EchoTest KO ${PackageJinja2[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageJinja2[Name]}> pip3 Install"
	pip3 install --no-index --no-user --find-links dist Jinja2 1> /dev/null && PackageJinja2[Status]=$? || { PackageJinja2[Status]=$?; EchoTest KO ${PackageJinja2[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									  Udev									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageUdev;
PackageUdev[Name]="Udev";
PackageUdev[Version]="(systemd-256.4)";
PackageUdev[Extension]=".tar.gz";
PackageUdev[Package]="${PackageUdev[Name]}-${PackageUdev[Version]}${PackageUdev[Extension]}";

InstallUdev()
{
	EchoInfo	"Package ${PackageUdev[Name]}"

	ReExtractPackage	"${PDIR}"	"systemd-256.4"	"${PackageUdev[Extension]}";

	if ! cd "${PDIR}systemd-256.4"; then
		EchoError	"cd ${PDIR}systemd-256.4";
		return;
	fi

	EchoInfo	"${PackageUdev[Name]}> Remove unneeded groups"
	sed -i	-e 's/GROUP="render"/GROUP="video"/' \
			-e 's/GROUP="sgx", //' \
			rules.d/50-udev-default.rules.in

	EchoInfo	"${PackageUdev[Name]}> Remove rule"
	sed '/systemd-sysctl/s/^/#/' -i rules.d/99-systemd.rules.in

	EchoInfo	"${PackageUdev[Name]}> Adjust hardcoded path"
	sed '/NETWORK_DIRS/s/systemd/udev/' -i src/basic/path-lookup.h

	if ! mkdir -p build; then
		PackageUdev[Status]=1; 
		EchoError	"Failed to make ${PDIR}${PackageUdev[Name]}/build";
		cd -;
		return ;
	fi
	cd -;
	cd "${PDIR}systemd-256.4/build";

	EchoInfo	"${PackageUdev[Name]}> Configure"
	meson setup .. 	--prefix=/usr \
					--buildtype=release \
					-D mode=release \
					-D dev-kvm-mode=0660 \
					-D link-udev-shared=false \
					-D logind=false \
					-D vconsole=false \
					1> /dev/null || { EchoTest KO ${PackageUdev[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageUdev[Name]}> Export udev helpers to env"
	export udev_helpers=$(grep "'name' :" ../src/udev/meson.build | awk '{print $3}' | tr -d ",'" | grep -v 'udevadm')

	EchoInfo	"${PackageUdev[Name]}> Build"
	ninja 	udevadm systemd-hwdb \
			$(ninja -n | grep -Eo '(src/(lib)?udev|rules.d|hwdb.d)/[^ ]*') \
			$(realpath libudev.so --relative-to .) \
			$udev_helpers \
			1> /dev/null || { PackageUdev[Status]=$?; EchoTest KO ${PackageUdev[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageUdev[Name]}> Install"
	install -vm755 -d {/usr/lib,/etc}/udev/{hwdb.d,rules.d,network}				1> /dev/null && \
	install -vm755 -d /usr/{lib,share}/pkgconfig								1> /dev/null && \
	install -vm755 udevadm								/usr/bin/				1> /dev/null && \
	install -vm755 systemd-hwdb							/usr/bin/udev-hwdb		1> /dev/null && \
	ln	-svfn ../bin/udevadm							/usr/sbin/udevd			1> /dev/null && \
	cp	-av	libudev.so{,*[0-9]}							/usr/lib/				1> /dev/null && \
	install -vm644 ../src/libudev/libudev.h				/usr/include/			1> /dev/null && \
	install -vm644 src/libudev/*.pc						/usr/lib/pkgconfig/		1> /dev/null && \
	install -vm644 src/udev/*.pc						/usr/share/pkgconfig/	1> /dev/null && \
	install -vm644 ../src/udev/udev.conf				/etc/udev/				1> /dev/null && \
	install -vm644 rules.d/* ../rules.d/README			/usr/lib/udev/rules.d/	1> /dev/null && \
	install -vm644 $(find ../rules.d/*.rules -not -name '*power-switch*') \
														/usr/lib/udev/rules.d/	1> /dev/null && \
	install -vm644 hwdb.d/* ../hwdb.d/{*.hwdb,README} 	/usr/lib/udev/hwdb.d/	1> /dev/null && \
	install -vm755 $udev_helpers						/usr/lib/udev			1> /dev/null && \
	install -vm644 ../network/99-default.link			/usr/lib/udev/network 	1> /dev/null && \
	PackageUdev[Status]=$? || { PackageUdev[Status]=$?; EchoTest KO ${PackageUdev[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageUdev[Name]}> Install custom rules and support files"
	tar -xvf ../../udev-lfs-20230818.tar.xz || { PackageUdev[Status]=$?; EchoTest KO ${PackageUdev[Name]} && PressAnyKeyToContinue; return; };
	make -f udev-lfs-20230818/Makefile.lfs install || { PackageUdev[Status]=$?; EchoTest KO ${PackageUdev[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageUdev[Name]}> Install man pages"
	tar -xf ../../systemd-man-pages-256.4.tar.xz \
		--no-same-owner --strip-components=1 \
		-C /usr/share/man --wildcards '*/udev*' '*/libudev*' '*/systemd.link.5' '*/systemd-'{hwdb,udevd.service}.8

	sed 's|systemd/network|udev/network|' \
		/usr/share/man/man5/systemd.link.5 \
		> /usr/share/man/man5/udev.link.5
	
	sed 's/systemd\(\\\?-\)/udev\1/' /usr/share/man/man8/systemd-hwdb.8 \
		> /usr/share/man/man8/udev-hwdb.8

	sed 's|lib.*udevd|sbin/udevd|' \
		/usr/share/man/man8/systemd-udevd.service.8 \
		> /usr/share/man/man8/udevd.8

	rm /usr/share/man/man*/systemd*

	EchoInfo	"${PackageUdev[Name]}> Configure"
	udev-hwdb update

	unset udev_helpers
	cd -;
}

# =====================================||===================================== #
#									 ManDB									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageManDB;
PackageManDB[Name]="man-db";
PackageManDB[Version]="2.12.1";
PackageManDB[Extension]=".tar.xz";
PackageManDB[Package]="${PackageManDB[Name]}-${PackageManDB[Version]}${PackageManDB[Extension]}";

InstallManDB()
{
	EchoInfo	"Package ${PackageManDB[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageManDB[Name]}-${PackageManDB[Version]}"	"${PackageManDB[Extension]}";

	if ! cd "${PDIR}${PackageManDB[Name]}-${PackageManDB[Version]}"; then
		EchoError	"cd ${PDIR}${PackageManDB[Name]}-${PackageManDB[Version]}";
		return;
	fi

	EchoInfo	"${PackageManDB[Name]}> Configure"
	./configure --prefix=/usr \
				--docdir=/usr/share/doc/mandb-2.12.1 \
				--sysconfdir=/etc \
				--disable-setuid \
				--enable-cache-owner=bin \
				--with-browser=/usr/bin/lynx \
				--with-vgrind=/usr/bin/vgrind \
				--with-grap=/usr/bin/grap \
				--with-systemdtmpfilesdir= \
				--with-systemdsystemunitdir= \
				1> /dev/null || { EchoTest KO ${PackageManDB[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageManDB[Name]}> make"
	make  1> /dev/null || { PackageManDB[Status]=$?; EchoTest KO ${PackageManDB[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageManDB[Name]}> make check"
	make check 1> /dev/null || { PackageManDB[Status]=$?; EchoTest KO ${PackageManDB[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageManDB[Name]}> make install"
	make install 1> /dev/null && PackageManDB[Status]=$? || { PackageManDB[Status]=$?; EchoTest KO ${PackageManDB[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#									ProcpsNg								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageProcpsNg;
PackageProcpsNg[Name]="procps-ng";
PackageProcpsNg[Version]="4.0.4";
PackageProcpsNg[Extension]=".tar.xz";
PackageProcpsNg[Package]="${PackageProcpsNg[Name]}-${PackageProcpsNg[Version]}${PackageProcpsNg[Extension]}";

InstallProcpsNg()
{
	EchoInfo	"Package ${PackageProcpsNg[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageProcpsNg[Name]}-${PackageProcpsNg[Version]}"	"${PackageProcpsNg[Extension]}";

	if ! cd "${PDIR}${PackageProcpsNg[Name]}-${PackageProcpsNg[Version]}"; then
		EchoError	"cd ${PDIR}${PackageProcpsNg[Name]}-${PackageProcpsNg[Version]}";
		return;
	fi

	EchoInfo	"${PackageProcpsNg[Name]}> Configure"
	./configure --prefix=/usr \
				--docdir=/usr/share/doc/procpsNg-4.0.4 \
				--disable-static \
				--disable-kill \
				1> /dev/null || { EchoTest KO ${PackageProcpsNg[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageProcpsNg[Name]}> make"
	make  1> /dev/null || { PackageProcpsNg[Status]=$?; EchoTest KO ${PackageProcpsNg[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageProcpsNg[Name]}> su tester -c \"PATH=\$PATH make check\""
	chown -R tester .
	su tester -c "PATH=$PATH make check" 1> /dev/null || { PackageProcpsNg[Status]=$?; EchoTest KO ${PackageProcpsNg[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageProcpsNg[Name]}> make install"
	make install 1> /dev/null && PackageProcpsNg[Status]=$? || { PackageProcpsNg[Status]=$?; EchoTest KO ${PackageProcpsNg[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#								   UtilLinux								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageUtilLinux;
PackageUtilLinux[Name]="util-linux";
PackageUtilLinux[Version]="2.40.2";
PackageUtilLinux[Extension]=".tar.xz";
PackageUtilLinux[Package]="${PackageUtilLinux[Name]}-${PackageUtilLinux[Version]}${PackageUtilLinux[Extension]}";

InstallUtilLinux()
{
	EchoInfo	"Package ${PackageUtilLinux[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageUtilLinux[Name]}-${PackageUtilLinux[Version]}"	"${PackageUtilLinux[Extension]}";

	if ! cd "${PDIR}${PackageUtilLinux[Name]}-${PackageUtilLinux[Version]}"; then
		EchoError	"cd ${PDIR}${PackageUtilLinux[Name]}-${PackageUtilLinux[Version]}";
		return;
	fi

	EchoInfo	"${PackageUtilLinux[Name]}> Configure"
	./configure --bindir=/usr/bin \
				--libdir=/usr/lib \
				--runstatedir=/run \
				--sbindir=/usr/sbin \
				--disable-chfn-chsh \
				--disable-login \
				--disable-nologin \
				--disable-su \
				--disable-setpriv \
				--disable-runuser \
				--disable-pylibmount \
				--disable-liblastlog2 \
				--disable-static \
				--without-python \
				--without-systemd \
				--without-systemdsystemunitdir \
				ADJTIME_PATH=/var/lib/hwclock/adjtime \
				--docdir=/usr/share/doc/util-linux-2.40.2 \
				1> /dev/null || { EchoTest KO ${PackageUtilLinux[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageUtilLinux[Name]}> make"
	make  1> /dev/null || { PackageUtilLinux[Status]=$?; EchoTest KO ${PackageUtilLinux[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageUtilLinux[Name]}> make check"
	touch /etc/fstab
	chown -R tester .
	su tester -c "make -k check" 1> /dev/null || { PackageUtilLinux[Status]=$?; EchoTest KO ${PackageUtilLinux[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageUtilLinux[Name]}> make install"
	make install 1> /dev/null && PackageUtilLinux[Status]=$? || { PackageUtilLinux[Status]=$?; EchoTest KO ${PackageUtilLinux[Name]} && PressAnyKeyToContinue; return; };

	cd -;
}

# =====================================||===================================== #
#								   E2fsprogs								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageE2fsprogs;
PackageE2fsprogs[Name]="e2fsprogs";
PackageE2fsprogs[Version]="1.47.1";
PackageE2fsprogs[Extension]=".tar.gz";
PackageE2fsprogs[Package]="${PackageE2fsprogs[Name]}-${PackageE2fsprogs[Version]}${PackageE2fsprogs[Extension]}";

InstallE2fsprogs()
{
	EchoInfo	"Package ${PackageE2fsprogs[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageE2fsprogs[Name]}-${PackageE2fsprogs[Version]}"	"${PackageE2fsprogs[Extension]}";

	if ! cd "${PDIR}${PackageE2fsprogs[Name]}-${PackageE2fsprogs[Version]}"; then
		EchoError	"cd ${PDIR}${PackageE2fsprogs[Name]}-${PackageE2fsprogs[Version]}";
		return;
	fi

	if ! mkdir -p build; then
		PackageE2fsprogs[Status]=1; 
		EchoError	"Failed to make ${PDIR}${PackageE2fsprogs[Name]}/build";
		cd -;
		return ;
	fi
	cd -;
	cd "${PDIR}${PackageE2fsprogs[Name]}-${PackageE2fsprogs[Version]}/build";

	EchoInfo	"${PackageE2fsprogs[Name]}> Configure"
	../configure 	--prefix=/usr \
					--sysconfdir=/etc \
					--enable-elf-shlibs \
					--disable-libblkid \
					--disable-libuuid \
					--disable-uuidd \
					--disable-fsck \
					1> /dev/null || { EchoTest KO ${PackageE2fsprogs[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageE2fsprogs[Name]}> make"
	make  1> /dev/null || { PackageE2fsprogs[Status]=$?; EchoTest KO ${PackageE2fsprogs[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageE2fsprogs[Name]}> make check"
	make check &> TempMakeCheck.log ||
	if [ $(grep ": failed" TempMakeCheck.log | grep -v "m_assume_storage_prezeroed" -c) -gt 0 ]; then
		PackageE2fsprogs[Status]=$(grep ": failed" TempMakeCheck.log -c)
		EchoTest KO ${PackageE2fsprogs[Name]}
		grep " test failed" TempMakeCheck.log
		grep ": failed" TempMakeCheck.log
		PressAnyKeyToContinue;
		return;
	else
		EchoTest OK ${PackageE2fsprogs[Name]}
		grep " test failed" TempMakeCheck.log
		grep ": failed" TempMakeCheck.log
	fi
	rm TempMakeCheck.log

	EchoInfo	"${PackageE2fsprogs[Name]}> make install"
	make install 1> /dev/null && PackageE2fsprogs[Status]=$? || { PackageE2fsprogs[Status]=$?; EchoTest KO ${PackageE2fsprogs[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageE2fsprogs[Name]}> Remove useless static libraries"
	rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

	EchoInfo	"${PackageE2fsprogs[Name]}> Unpack and update system dir file"
	gunzip -v /usr/share/info/libext2fs.info.gz
	install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

	EchoInfo	"${PackageE2fsprogs[Name]}> Install documentation"
	makeinfo -o 		doc/com_err.info 	../lib/et/com_err.texinfo
	install -v -m644 	doc/com_err.info 	/usr/share/info
	install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

	# EchoInfo	"${PackageE2fsprogs[Name]}> Adjust default values"
	# sed 's/metadata_csum_seed,//' -i /etc/mke2fs.conf

	cd -;
}

# =====================================||===================================== #
#									Sysklogd								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageSysklogd;
PackageSysklogd[Name]="sysklogd";
PackageSysklogd[Version]="2.6.1";
PackageSysklogd[Extension]=".tar.gz";
PackageSysklogd[Package]="${PackageSysklogd[Name]}-${PackageSysklogd[Version]}${PackageSysklogd[Extension]}";

InstallSysklogd()
{
	EchoInfo	"Package ${PackageSysklogd[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageSysklogd[Name]}-${PackageSysklogd[Version]}"	"${PackageSysklogd[Extension]}";

	if ! cd "${PDIR}${PackageSysklogd[Name]}-${PackageSysklogd[Version]}"; then
		EchoError	"cd ${PDIR}${PackageSysklogd[Name]}-${PackageSysklogd[Version]}";
		return;
	fi

	EchoInfo	"${PackageSysklogd[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--runstatedir=/run \
				--without-logger \
				1> /dev/null || { EchoTest KO ${PackageSysklogd[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageSysklogd[Name]}> make"
	make  1> /dev/null || { PackageSysklogd[Status]=$?; EchoTest KO ${PackageSysklogd[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageSysklogd[Name]}> make install"
	make install 1> /dev/null && PackageSysklogd[Status]=$? || { PackageSysklogd[Status]=$?; EchoTest KO ${PackageSysklogd[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageSysklogd[Name]}> Configuring /etc/syslog.conf"
	cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf
auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *
# Do not open any internet ports.
secure_mode 2
# End /etc/syslog.conf
EOF

	cd -;
}

# =====================================||===================================== #
#									SysVinit								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageSysVinit;
PackageSysVinit[Name]="sysvinit";
PackageSysVinit[Version]="3.10";
PackageSysVinit[Extension]=".tar.xz";
PackageSysVinit[Package]="${PackageSysVinit[Name]}-${PackageSysVinit[Version]}${PackageSysVinit[Extension]}";

InstallSysVinit()
{
	EchoInfo	"Package ${PackageSysVinit[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageSysVinit[Name]}-${PackageSysVinit[Version]}"	"${PackageSysVinit[Extension]}";

	if ! cd "${PDIR}${PackageSysVinit[Name]}-${PackageSysVinit[Version]}"; then
		EchoError	"cd ${PDIR}${PackageSysVinit[Name]}-${PackageSysVinit[Version]}";
		return;
	fi

	EchoInfo	"${PackageSysVinit[Name]}> Patch"
	patch -Np1 -i ../sysvinit-3.10-consolidated-1.patch

	EchoInfo	"${PackageSysVinit[Name]}> make"
	make  1> /dev/null || { PackageSysVinit[Status]=$?; EchoTest KO ${PackageSysVinit[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageSysVinit[Name]}> make install"
	make install 1> /dev/null && PackageSysVinit[Status]=$? || { PackageSysVinit[Status]=$?; EchoTest KO ${PackageSysVinit[Name]} && PressAnyKeyToContinue; return; };

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
	InstallNcurses;
	InstallSed;
	InstallPsmisc;
	InstallGettext;
	InstallBison;
	InstallGrep;
	InstallBash;
	InstallLibtool;
	InstallGDBM;
	InstallGperf;
	InstallExpat;
	InstallInetutils;
	InstallLess;
	InstallPerl;
	InstallXMLParser;
	InstallIntltool;
	InstallAutoconf;
	InstallAutomake;
	InstallOpenSSL;
	InstallKmod;
	InstallElfutils;
	InstallLibffi;
	InstallPython;
	InstallFlitCore;
	InstallWheel;
	InstallSetuptools;
	InstallNinja;
	InstallMeson;
	InstallCoreutils;
	InstallCheck;
	InstallDiffutils;
	InstallGawk;
	InstallFindutils;
	InstallGroff;
	InstallGRUB;
	InstallGzip;
	InstallIPRoute2;
	InstallKbd;
	InstallLibpipeline;
	InstallMake;
	InstallPatch;
	InstallTar;
	InstallTexinfo;
	InstallVim;
	InstallMarkupSafe;
	InstallJinja2;
	InstallUdev;
	InstallManDB;
	InstallProcpsNg;
	InstallUtilLinux;
	InstallE2fsprogs;
	InstallSysklogd;
	InstallSysVinit;
}

CleanUp()
{
	find "${PDIR}" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +
	rm -rf /tmp/{*,.*}
	find /usr/lib /usr/libexec -name \*.la -delete

	while true; do
		echo	"Remove Cross-Compiler and user tester? (y/n)"
		GetKeyPress
		case "$input" in
			Y|y)	find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf;
					userdel -r tester;
					break ;;
			N|n)	break ;;
		esac
	done
}

PrintMenu()
{
	width=$(tput cols);
	height=$(tput lines);

	MenuOptions=82;
	MenuTop=$((MenuOptions+5));
	MenuStart=$((MenuIndex-(height/2)));
	if [ $MenuStart -gt $((MenuTop-height)) ] || [ $MenuIndex -lt 3 ]; then
		MenuStart=$((MenuTop-height+2));
	fi
	if [ $MenuStart -lt 2 ]; then
		MenuStart=2;
	fi
	
	echo -e	"${ESC_SEQ}H";
	for ((counter=0; counter < height - 2; counter++)); do
		case $((counter+MenuStart)) in
			2)	printf '%*s\n' "$width" '' | tr ' ' '-';;
			3)	PrintMenuLine	"3 ${PackageMan[Name]}-${PackageMan[Version]}"				$MenuIndex	3	"${PackageMan[Status]}";;
			4)	PrintMenuLine	"4 ${PackageIanaEtc[Name]}-${PackageIanaEtc[Version]}"		$MenuIndex	4	"${PackageIanaEtc[Status]}";;
			5)	PrintMenuLine	"5 ${PackageGlibc[Name]}-${PackageGlibc[Version]}"			$MenuIndex	5	"${PackageGlibc[Status]}";;
			6)	PrintMenuLine	"6 ${PackageZlib[Name]}-${PackageZlib[Version]}"			$MenuIndex	6	"${PackageZlib[Status]}";;
			7)	PrintMenuLine	"7 ${PackageBzip2[Name]}-${PackageBzip2[Version]}"			$MenuIndex	7	"${PackageBzip2[Status]}";;
			8)	PrintMenuLine	"8 ${PackageXz[Name]}-${PackageXz[Version]}"				$MenuIndex	8	"${PackageXz[Status]}";;
			9)	PrintMenuLine	"9 ${PackageLz4[Name]}-${PackageLz4[Version]}"				$MenuIndex	9	"${PackageLz4[Status]}";;
			10)	PrintMenuLine	"10 ${PackageZstd[Name]}-${PackageZstd[Version]}"			$MenuIndex	10	"${PackageZstd[Status]}";;
			11)	PrintMenuLine	"11 ${PackageFile[Name]}-${PackageFile[Version]}"			$MenuIndex	11	"${PackageFile[Status]}";;
			12)	PrintMenuLine	"12 ${PackageReadline[Name]}-${PackageReadline[Version]}"	$MenuIndex	12	"${PackageReadline[Status]}";;
			13)	PrintMenuLine	"13 ${PackageM4[Name]}-${PackageM4[Version]}"				$MenuIndex	13	"${PackageM4[Status]}";;
			14)	PrintMenuLine	"14 ${PackageBc[Name]}-${PackageBc[Version]}"				$MenuIndex	14	"${PackageBc[Status]}";;
			15)	PrintMenuLine	"15 ${PackageFlex[Name]}-${PackageFlex[Version]}"			$MenuIndex	15	"${PackageFlex[Status]}";;
			16)	PrintMenuLine	"16 ${PackageTcl[Name]}-${PackageTcl[Version]}"				$MenuIndex	16	"${PackageTcl[Status]}";;
			17)	PrintMenuLine	"17 ${PackageExpect[Name]}-${PackageExpect[Version]}"		$MenuIndex	17	"${PackageExpect[Status]}";;
			18)	PrintMenuLine	"18 ${PackageDejaGNU[Name]}-${PackageDejaGNU[Version]}"		$MenuIndex	18	"${PackageDejaGNU[Status]}";;
			19)	PrintMenuLine	"19 ${PackagePkgconf[Name]}-${PackagePkgconf[Version]}"		$MenuIndex	19	"${PackagePkgconf[Status]}";;
			20)	PrintMenuLine	"20 ${PackageBinutils[Name]}-${PackageBinutils[Version]}"	$MenuIndex	20	"${PackageBinutils[Status]}";;
			21)	PrintMenuLine	"21 ${PackageGMP[Name]}-${PackageGMP[Version]}"				$MenuIndex	21	"${PackageGMP[Status]}";;
			22)	PrintMenuLine	"22 ${PackageMPFR[Name]}-${PackageMPFR[Version]}"			$MenuIndex	22	"${PackageMPFR[Status]}";;
			23)	PrintMenuLine	"23 ${PackageMPC[Name]}-${PackageMPC[Version]}"				$MenuIndex	23	"${PackageMPC[Status]}";;
			24)	PrintMenuLine	"24 ${PackageAttr[Name]}-${PackageAttr[Version]}"			$MenuIndex	24	"${PackageAttr[Status]}";;
			25)	PrintMenuLine	"25 ${PackageAcl[Name]}-${PackageAcl[Version]}"				$MenuIndex	25	"${PackageAcl[Status]}";;
			26)	PrintMenuLine	"26 ${PackageLibcap[Name]}-${PackageLibcap[Version]}"		$MenuIndex	26	"${PackageLibcap[Status]}";;
			27)	PrintMenuLine	"27 ${PackageLibxcrypt[Name]}-${PackageLibxcrypt[Version]}"	$MenuIndex	27	"${PackageLibxcrypt[Status]}";;
			28)	PrintMenuLine	"28 ${PackageShadow[Name]}-${PackageShadow[Version]}"		$MenuIndex	28	"${PackageShadow[Status]}";;
			29)	PrintMenuLine	"29 ${PackageGcc[Name]}-${PackageGcc[Version]}"				$MenuIndex	29	"${PackageGcc[Status]}";;
			30)	PrintMenuLine	"30 ${PackageNcurses[Name]}-${PackageNcurses[Version]}"		$MenuIndex	30	"${PackageNcurses[Status]}";;
			31)	PrintMenuLine	"31 ${PackageSed[Name]}-${PackageSed[Version]}"				$MenuIndex	31	"${PackageSed[Status]}";;
			32)	PrintMenuLine	"32 ${PackagePsmisc[Name]}-${PackagePsmisc[Version]}"		$MenuIndex	32	"${PackagePsmisc[Status]}";;
			33)	PrintMenuLine	"33 ${PackageGettext[Name]}-${PackageGettext[Version]}"		$MenuIndex	33	"${PackageGettext[Status]}";;
			34)	PrintMenuLine	"34 ${PackageBison[Name]}-${PackageBison[Version]}"			$MenuIndex	34	"${PackageBison[Status]}";;
			35)	PrintMenuLine	"35 ${PackageGrep[Name]}-${PackageGrep[Version]}"			$MenuIndex	35	"${PackageGrep[Status]}";;
			36)	PrintMenuLine	"36 ${PackageBash[Name]}-${PackageBash[Version]}"			$MenuIndex	36	"${PackageBash[Status]}";;
			37)	PrintMenuLine	"37 ${PackageLibtool[Name]}-${PackageLibtool[Version]}"		$MenuIndex	37	"${PackageLibtool[Status]}";;
			38)	PrintMenuLine	"38 ${PackageGDBM[Name]}-${PackageGDBM[Version]}"			$MenuIndex	38	"${PackageGDBM[Status]}";;
			39)	PrintMenuLine	"39 ${PackageGperf[Name]}-${PackageGperf[Version]}"			$MenuIndex	39	"${PackageGperf[Status]}";;
			40)	PrintMenuLine	"40 ${PackageExpat[Name]}-${PackageExpat[Version]}"			$MenuIndex	40	"${PackageExpat[Status]}";;
			41)	PrintMenuLine	"41 ${PackageInetutils[Name]}-${PackageInetutils[Version]}"	$MenuIndex	41	"${PackageInetutils[Status]}";;
			42)	PrintMenuLine	"42 ${PackageLess[Name]}-${PackageLess[Version]}"			$MenuIndex	42	"${PackageLess[Status]}";;
			43)	PrintMenuLine	"43 ${PackagePerl[Name]}-${PackagePerl[Version]}"			$MenuIndex	43	"${PackagePerl[Status]}";;
			44)	PrintMenuLine	"44 ${PackageXMLParser[Name]}-${PackageXMLParser[Version]}"	$MenuIndex	44	"${PackageXMLParser[Status]}";;
			45)	PrintMenuLine	"45 ${PackageIntltool[Name]}-${PackageIntltool[Version]}"	$MenuIndex	45	"${PackageIntltool[Status]}";;
			46)	PrintMenuLine	"46 ${PackageAutoconf[Name]}-${PackageAutoconf[Version]}"	$MenuIndex	46	"${PackageAutoconf[Status]}";;
			47)	PrintMenuLine	"47 ${PackageAutomake[Name]}-${PackageAutomake[Version]}"	$MenuIndex	47	"${PackageAutomake[Status]}";;
			48)	PrintMenuLine	"48 ${PackageOpenSSL[Name]}-${PackageOpenSSL[Version]}"		$MenuIndex	48	"${PackageOpenSSL[Status]}";;
			49)	PrintMenuLine	"49 ${PackageKmod[Name]}-${PackageKmod[Version]}"			$MenuIndex	49	"${PackageKmod[Status]}";;
			50)	PrintMenuLine	"50 ${PackageElfutils[Name]}-${PackageElfutils[Version]}"	$MenuIndex	50	"${PackageElfutils[Status]}";;
			51)	PrintMenuLine	"51 ${PackageLibffi[Name]}-${PackageLibffi[Version]}"		$MenuIndex	51	"${PackageLibffi[Status]}";;
			52)	PrintMenuLine	"52 ${PackagePython[Name]}-${PackagePython[Version]}"		$MenuIndex	52	"${PackagePython[Status]}";;
			53)	PrintMenuLine	"53 ${PackageFlitCore[Name]}-${PackageFlitCore[Version]}"	$MenuIndex	53	"${PackageFlitCore[Status]}";;
			54)	PrintMenuLine	"54 ${PackageWheel[Name]}-${PackageWheel[Version]}"			$MenuIndex	54	"${PackageWheel[Status]}";;
			55)	PrintMenuLine	"55 ${PackageSetuptools[Name]}-${PackageSetuptools[Version]}"	$MenuIndex	55	"${PackageSetuptools[Status]}";;
			56)	PrintMenuLine	"56 ${PackageNinja[Name]}-${PackageNinja[Version]}"			$MenuIndex	56	"${PackageNinja[Status]}";;
			57)	PrintMenuLine	"57 ${PackageMeson[Name]}-${PackageMeson[Version]}"			$MenuIndex	57	"${PackageMeson[Status]}";;
			58)	PrintMenuLine	"58 ${PackageCoreutils[Name]}-${PackageCoreutils[Version]}"	$MenuIndex	58	"${PackageCoreutils[Status]}";;
			59)	PrintMenuLine	"59 ${PackageCheck[Name]}-${PackageCheck[Version]}"			$MenuIndex	59	"${PackageCheck[Status]}";;
			60)	PrintMenuLine	"60 ${PackageDiffutils[Name]}-${PackageDiffutils[Version]}"	$MenuIndex	60	"${PackageDiffutils[Status]}";;
			61)	PrintMenuLine	"61 ${PackageGawk[Name]}-${PackageGawk[Version]}"			$MenuIndex	61	"${PackageGawk[Status]}";;
			62)	PrintMenuLine	"62 ${PackageFindutils[Name]}-${PackageFindutils[Version]}"	$MenuIndex	62	"${PackageFindutils[Status]}";;
			63)	PrintMenuLine	"63 ${PackageGroff[Name]}-${PackageGroff[Version]}"			$MenuIndex	63	"${PackageGroff[Status]}";;
			64)	PrintMenuLine	"64 ${PackageGRUB[Name]}-${PackageGRUB[Version]}"			$MenuIndex	64	"${PackageGRUB[Status]}";;
			65)	PrintMenuLine	"65 ${PackageGzip[Name]}-${PackageGzip[Version]}"			$MenuIndex	65	"${PackageGzip[Status]}";;
			66)	PrintMenuLine	"66 ${PackageIPRoute2[Name]}-${PackageIPRoute2[Version]}"	$MenuIndex	66	"${PackageIPRoute2[Status]}";;
			67)	PrintMenuLine	"67 ${PackageKbd[Name]}-${PackageKbd[Version]}"				$MenuIndex	67	"${PackageKbd[Status]}";;
			68)	PrintMenuLine	"68 ${PackageLibpipeline[Name]}-${PackageLibpipeline[Version]}"	$MenuIndex	68	"${PackageLibpipeline[Status]}";;
			69)	PrintMenuLine	"69 ${PackageMake[Name]}-${PackageMake[Version]}"			$MenuIndex	69	"${PackageMake[Status]}";;
			70)	PrintMenuLine	"70 ${PackagePatch[Name]}-${PackagePatch[Version]}"			$MenuIndex	70	"${PackagePatch[Status]}";;
			71)	PrintMenuLine	"71 ${PackageTar[Name]}-${PackageTar[Version]}"				$MenuIndex	71	"${PackageTar[Status]}";;
			72)	PrintMenuLine	"72 ${PackageTexinfo[Name]}-${PackageTexinfo[Version]}"		$MenuIndex	72	"${PackageTexinfo[Status]}";;
			73)	PrintMenuLine	"73 ${PackageVim[Name]}-${PackageVim[Version]}"				$MenuIndex	73	"${PackageVim[Status]}";;
			74)	PrintMenuLine	"74 ${PackageMarkupSafe[Name]}-${PackageMarkupSafe[Version]}"	$MenuIndex	74	"${PackageMarkupSafe[Status]}";;
			75)	PrintMenuLine	"75 ${PackageJinja2[Name]}-${PackageJinja2[Version]}"		$MenuIndex	75	"${PackageJinja2[Status]}";;
			76)	PrintMenuLine	"76 ${PackageUdev[Name]}-${PackageUdev[Version]}"			$MenuIndex	76	"${PackageUdev[Status]}";;
			77)	PrintMenuLine	"77 ${PackageManDB[Name]}-${PackageManDB[Version]}"			$MenuIndex	77	"${PackageManDB[Status]}";;
			78)	PrintMenuLine	"78 ${PackageProcpsNg[Name]}-${PackageProcpsNg[Version]}"	$MenuIndex	78	"${PackageProcpsNg[Status]}";;
			79)	PrintMenuLine	"79 ${PackageUtilLinux[Name]}-${PackageUtilLinux[Version]}"	$MenuIndex	79	"${PackageUtilLinux[Status]}";;
			80)	PrintMenuLine	"80 ${PackageE2fsprogs[Name]}-${PackageE2fsprogs[Version]}"	$MenuIndex	80	"${PackageE2fsprogs[Status]}";;
			81)	PrintMenuLine	"81 ${PackageSysklogd[Name]}-${PackageSysklogd[Version]}"	$MenuIndex	81	"${PackageSysklogd[Status]}";;
			82)	PrintMenuLine	"82 ${PackageSysVinit[Name]}-${PackageSysVinit[Version]}"	$MenuIndex	82	"${PackageSysVinit[Status]}";;
			83)	printf '%*s\n' "$width" '' | tr ' ' '-';;
			84)	PrintMenuLine	"Install All"	$MenuIndex	0;;
			85)	PrintMenuLine	"Validate"	$MenuIndex	1;;
			86)	PrintMenuLine	"Quit"	$MenuIndex	2;;
			87)	printf '%*s\n' "$width" '' | tr ' ' '-';;
			*)	echo $counter ;;
		esac
	done


	GetKeyPress;
	case "$input" in
		$'\e[A')	((--MenuIndex));;
		$'\e[B')	((++MenuIndex));;
		"")	case $MenuIndex in
				3)	InstallMan;;
				4)	InstallIanaEtc;;
				5)	InstallGlibc;;
				6)	InstallZlib;;
				7)	InstallBzip2;;
				8)	InstallXz;;
				9)	InstallLz4;;
				10)	InstallZstd;;
				11)	InstallFile;;
				12)	InstallReadline;;
				13)	InstallM4;;
				14)	InstallBc;;
				15)	InstallFlex;;
				16)	InstallTcl;;
				17)	InstallExpect;;
				18)	InstallDejaGNU;;
				19)	InstallPkgconf;;
				20)	InstallBinutils;;
				21)	InstallGMP;;
				22)	InstallMPFR;;
				23)	InstallMPC;;
				24)	InstallAttr;;
				25)	InstallAcl;;
				26)	InstallLibcap;;
				27)	InstallLibxcrypt;;
				28)	InstallShadow;;
				29)	InstallGcc;;
				30)	InstallNcurses;;
				31)	InstallSed;;
				32)	InstallPsmisc;;
				33)	InstallGettext;;
				34)	InstallBison;;
				35)	InstallGrep;;
				36)	InstallBash;;
				37) InstallLibtool;;
				38) InstallGDBM;;
				39) InstallGperf;;
				40) InstallExpat;;
				41) InstallInetutils;;
				42) InstallLess;;
				43) InstallPerl;;
				44)	InstallXMLParser;;
				45)	InstallIntltool;;
				46)	InstallAutoconf;;
				47)	InstallAutomake;;
				48)	InstallOpenSSL;;
				49)	InstallKmod;;
				50)	InstallElfutils;;
				51)	InstallLibffi;;
				52)	InstallPython;;
				53)	InstallFlitCore;;
				54)	InstallWheel;;
				55)	InstallSetuptools;;
				56)	InstallNinja;;
				57)	InstallMeson;;
				58)	InstallCoreutils;;
				59) InstallCheck;;
				60) InstallDiffutils;;
				61) InstallGawk;;
				62) InstallFindutils;;
				63) InstallGroff;;
				64) InstallGRUB;;
				65) InstallGzip;;
				66) InstallIPRoute2;;
				67) InstallKbd;;
				68) InstallLibpipeline;;
				69) InstallMake;;
				70) InstallPatch;;
				71) InstallTar;;
				72) InstallTexinfo;;
				73) InstallVim;;
				74)	InstallMarkupSafe;;
				75)	InstallJinja2;;
				76)	InstallUdev;;
				77) InstallManDB;;
				78) InstallProcpsNg;;
				79) InstallUtilLinux;;
				80) InstallE2fsprogs;;
				81) InstallSysklogd;;
				82) InstallSysVinit;;
				0)	InstallAll;;
				1)	./CheckBinaries.sh;;
				2)	MenuIndex=-1;
					CleanUp;
					return ;;
			esac;
			PressAnyKeyToContinue;;
	esac

	MenuIndex=$(( MenuIndex % (MenuOptions+1)));
	if [ $MenuIndex -lt 0 ]; then
		MenuIndex=$MenuOptions;
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

	printf	" %-19s ${C_RESET}${ESC_SEQ}K\n"	"$1";
}

MenuIndex=0
while [ "$MenuIndex" -ge 0 ]; do
	PrintMenu;
done

exit 

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
