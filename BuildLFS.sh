PDIR=/sources/lfs-packages12.2/

# =====================================||===================================== #
#																			   #
#							Building System Software						   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

ReExtractPackage()
{
	local SRC="$1";
	local DST="$2";
	if [ ! -f "$SRC" ] || [ ! -f $"$DST" ]; then
		EchoError	"ReExtractPackage SRD[$SRC] DST[$DST]";
		return false;
	fi

	if [ -d "$DST" ]; then
		rm -rf "$DST";
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
	echo	"[${C_RED}ERR${C_RESET} ]  $1"	>&2;
}

EchoInfo()
{
	echo	"[${C_CYAN}INFO${C_RESET}]$1";
}

EchoTest()
{
	if [ "$1" = OK ]; then
		echo	"[${C_GREEN} OK ${C_RESET}] $2";
	elif [ "$1" = KO ]; then
		echo	"[${C_RED} KO ${C_RESET}] $2";
	else
		echo	"[${C_GRAY}TEST${C_RESET}] $1";
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

# =====================================||===================================== #
#																			   #
#									Packages								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

# =====================================||===================================== #
#									Temp									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallTemp()
{
	local NAME="Temp";
	local VERSION="";
	local EXTENSION=".tar.xz";
	local PACKAGE="${NAME}-${VERSION}${EXTENSION}";

	EchoInfo	"Package ${NAME}"

	ReExtractPackage	"${PDIR}${PACKAGE}"	"${PDIR}";

	if ! cd "${PDIR}${NAME}"; then
		EchoError	"cd ${PDIR}${NAME}";
		return;
	fi

	EchoInfo	"${NAME}> Configure"
	./configure --prefix=/usr 1> /dev/null || {EchoTest KO ${NAME} && PressAnyKeyToContinue; return;};

	EchoInfo	"${NAME}> make"
	make  1> /dev/null || {EchoTest KO ${NAME} && PressAnyKeyToContinue; return;};

	EchoInfo	"${NAME}> make check"
	make check 1> /dev/null || {EchoTest KO ${NAME} && PressAnyKeyToContinue; return;};
	
	EchoInfo	"${NAME}> make install"
	make install 1> /dev/null || {EchoTest KO ${NAME} && PressAnyKeyToContinue; return;};

	if ! mkdir -v build; then
		EchoError	"Failed to make ${PDIR}${NAME}/build";
		cd -;
		return ;
	fi
	cd -;
	cd "${PDIR}${NAME}/build";

	cd -;
}

# =====================================||===================================== #
#									  Man									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallMan()
{
	local NAME="man-pages";
	local VERSION="6.9.1";
	local EXTENSION=".tar.xz";
	local PACKAGE="${NAME}-${VERSION}${EXTENSION}";

	ReExtractPackage	"${PDIR}${PACKAGE}"	"${PDIR}";

	if ! cd "${PDIR}${NAME}"; then
		EchoError	"cd ${PDIR}${NAME}";
		return;
	fi

	# Remove two man pages for password hashing functions
	rm -v man3/crypt*

	EchoInfo	"${NAME}> make prefix=/usr install"
	make prefix=/usr install	1> /dev/null

	cd -;
}

# =====================================||===================================== #
#									Iana-Etc								   #
# ===============ft_linux==============||==============©Othello=============== #

InstallIana-Etc()
{
	local NAME="iana-etc";
	local VERSION="20240806";
	local EXTENSION=".tar.gz";
	local PACKAGE="${NAME}-${VERSION}${EXTENSION}";

	EchoInfo	"Package ${NAME}"

	ReExtractPackage	"${PDIR}${PACKAGE}"	"${PDIR}";

	if ! cd "${PDIR}${NAME}"; then
		EchoError	"cd ${PDIR}${NAME}";
		return;
	fi

	EchoInfo	"${NAME}> cp services protocols /etc"
	cp services protocols /etc	1> /dev/null

	cd -;
}

# =====================================||===================================== #
#									Glibc									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallGlibc()
{
	local NAME="glibc";
	local VERSION="2.40";
	local EXTENSION=".tar.xz";
	local PACKAGE="${NAME}-${VERSION}${EXTENSION}";

	EchoInfo	"Package ${NAME}"

	ReExtractPackage	"${PDIR}${PACKAGE}"	"${PDIR}";

	if ! cd "${PDIR}${NAME}"; then
		EchoError	"cd ${PDIR}${NAME}";
		return;
	fi

	EchoInfo	"${NAME} patching..."
	patch -Np1 -i ../glibc-2.40-fhs-1.patch

	if ! mkdir -v build; then
		EchoError	"Failed to make ${PDIR}${NAME}/build";
		cd -;
		return ;
	fi
	cd -;
	cd "${PDIR}${NAME}/build";

	InstallGlibcInstall;
	InstallGlibcConfigure;

	cd -;
}

InstallGlibcInstall()
{
	# Ensure that the ldconfig and sln utilities will be installed into /usr/sbin
	echo "rootsbindir=/usr/sbin" > configparms

	EchoInfo	"${NAME}> configure"
	../configure	--prefix=/usr	\
					--disable-werror	\
					--enable-kernel=4.19	\
					--enable-stack-protector=strong	\
					--disable-nscd	\
					libc_cv_slibdir=/usr/lib	\
					1> /dev/null

	EchoInfo	"${NAME}> Compile"
	time make 1> /dev/null || {EchoTest KO ${NAME} && PressAnyKeyToContinue; return;};

	EchoInfo	"${NAME}> Check"
	make check 1> /dev/null; EchoInfo "Check the test or ctrl C!"; PressAnyKeyToContinue; 

	# Prevent harmless warning
	touch /etc/ld.so.conf

	# Fix the Makefile to skip an outdated sanity check that fails with a modern Glibc configuration
	sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

	EchoInfo	"${NAME}> Install"
	time make 1> /dev/null || {EchoTest KO ${NAME} && PressAnyKeyToContinue; return;};

	# Fix a hardcoded path to the executable loader in the ldd script
	sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd;

	# Installing locales using the localedef program
	if true; then
		EchoInfo	"${NAME}> Installing all locales"
		make localedata/install-locales
		# Locales missing from make
		localedef -i C -f UTF-8 C.UTF-8
		localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
	else
		# Installing individual locales
		EchoInfo	"${NAME}> Installing individual Locales"
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

InstallZlib()
{
	local NAME="zlib";
	local VERSION="1.3.1";
	local EXTENSION=".tar.gz";
	local PACKAGE="${NAME}-${VERSION}${EXTENSION}";

	EchoInfo	"Package ${NAME}"

	ReExtractPackage	"${PDIR}${PACKAGE}"	"${PDIR}";

	if ! cd "${PDIR}${NAME}"; then
		EchoError	"cd ${PDIR}${NAME}";
		return;
	fi
	
	EchoInfo	"${NAME}> Configure"
	./configure --prefix=/usr 1> /dev/null || {EchoTest KO ${NAME} && PressAnyKeyToContinue; return;};

	EchoInfo	"${NAME}> make"
	make  1> /dev/null || {EchoTest KO ${NAME} && PressAnyKeyToContinue; return;};

	EchoInfo	"${NAME}> make check"
	make check 1> /dev/null || {EchoTest KO ${NAME} && PressAnyKeyToContinue; return;};
	
	EchoInfo	"${NAME}> make install"
	make install 1> /dev/null || {EchoTest KO ${NAME} && PressAnyKeyToContinue; return;};
	
	# Remove a useless static lbrary
	rm -fv /usr/lib/libz.a

	cd -;
}
