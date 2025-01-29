#! /bin/zsh

source colors.sh

# =====================================||===================================== #
#																			   #
#								Configure User								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

ConfigureUserMenu()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE}User Configuration${C_RESET}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	if [ -f ~/.bash_profile ]; then
		echo	"${C_GREEN}~./bash_profile${C_RESET}";
	else
		echo 	"${C_RED}~./bash_profile${C_RESET}";
	fi
	if [ -f ~/.bashrc ]; then
		echo	"${C_GREEN}~./bashrc${C_RESET}";
	else
		echo 	"${C_RED}~./bashrc${C_RESET}";
	fi
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"d)\tDisplay files";
	echo	"c)\tCreate files";
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	case $input in
		c|C)	ConfigureUser;
				SourceBashProfile;;
		d|D)	DisplayConfigurationFiles;
				PressAnyKeyToContinue;;
		q|Q)	MENU=0;;
		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";;
	esac
}

ConfigureUser()
{
	CreateBashrc;
	CreateBashProfile;
}

CreateBashProfile()
{
	echo	"Creating ~/.bash_profile";
cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF
}

CreateBashrc()
{
	echo	"Creating ~/bashrc";
cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE

export MAKEFLAGS=-j$(nproc)
EOF
}

SourceBashProfile()
{
	echo	"Reading source ~/.bash_profile"
	source ~/.bash_profile;
}

DisplayConfigurationFiles()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE}~/.bash_profile${C_RESET}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	cat ~/.bash_profile
	printf '%*s\n' "$width" '' | tr ' ' '-';

	echo	"${C_ORANGE}~/.bashrc${C_RESET}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	cat ~/.bashrc
	printf '%*s\n' "$width" '' | tr ' ' '-';
}

# =====================================||===================================== #
#																			   #
#							   Install Packages								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

MenuCrossToolchain()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE}Cross-Toolchain${C_RESET}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	ValidateAndPrintPackage	0	"binutils-2.43.1"	"1 SBU"	ValidateBinutils
	ValidateAndPrintPackage	1	"gcc-14.2.0"	"3.2 SBU"	ValidateGcc
	ValidateAndPrintPackage	2	"linux-6.10.5"	"<0.1 SBU"
	ValidateAndPrintPackage	3	"glibc-2.40"	"1.3 SBU"
	ValidateAndPrintPackage	4	"gcc-14.2.0 (libstdc++)"	"0.2 SBU"
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo -n	"Sanity check:"
	ToolchainTest1
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"i)\tInstall all"
	echo	"f)\tForce install all"
	# echo	"0)\tInstall binutils"
	# if ValidateBinutils; then
	# 	echo	"1)\tInstall gcc"
	# 	if ValidateGcc; then
	# 		echo	"2)\tInstall Linux API Headers"
	# 	fi
	# fi
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	# if [[ "$input" =~ ^-?[0-9]+$ ]]; then
	# 	if [ $input -ge 1 ] && ! ValidateBinutils ; then
	# 		MSG="${C_RED}Error${C_RESET}: binutils requires first";
	# 		return ;
	# 	fi
	# 	if [ $input -ge 2 ] && ! ValidateGcc ; then
	# 		MSG="${C_RED}Error${C_RESET}: gcc requires first";
	# 		return ;
	# 	fi
	# fi

	PDIR="$LFS/sources/lfs-packages12.2/";

	case $input in
		# 0)	InstallPackageBinutils;
		# 	PressAnyKeyToContinue;;
		# 1)	PressAnyKeyToContinue;;
		# 2)	PressAnyKeyToContinue;;
		i|I)	InstallPackages;
				PressAnyKeyToContinue;;
		f|F)	InstallPackages "true";
				PressAnyKeyToContinue;;
		q|Q)	MENU=0;;
		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";;
	esac

}

ValidateAndPrintPackage()
{
	if [ -z $4 ]; then 
		printf "%-0.2s ${C_DGRAY}%-22s${C_RESET} %-s\n"	"$1" "$2" "$3";
	elif $4; then
		printf "%-0.2s ${C_GREEN}%-22s${C_RESET} %-s\n"	"$1" "$2" "$3";
	else
		printf "%-0.2s ${C_RED}%-22s${C_RESET} %-s\n"	"$1" "$2" "$3";
	fi
}

InstallPackages()
{
	PDIR="$LFS/sources/lfs-packages12.2/";
	# cd "$PDIR";

	local FORCE=$1;

	if [ "$FORCE" = "true" ] || ! ValidateBinutils; then
		echo	"${C_ORANGE}binutils...${C_RESET}";
		InstallPackageBinutils;
	fi

	if ValidateBinutils; then
		if ! ValidateGcc; then 
			echo	"${C_ORANGE}gcc...${C_RESET}";
			InstallCrossGCC;
		fi
	else
		MSG="${C_RED}Error${C_RESET}: Missing ${C_ORANGE}binutils${C_RESET} which is required before ${C_ORANGE}gcc${C_RESET}";
		return ;
	fi
	
	if ValidateGcc; then
		if ValidateGcc; then
			echo	"${C_ORANGE}Linux API Headers...${C_RESET}";
			ExposeAPIHeaders;
		fi
	else
		MSG="${C_RED}Error${C_RESET}: Missing ${C_ORANGE}gcc${C_RESET} which is required before ${C_ORANGE}Linux API Headers${C_RESET}";
		return ;
	fi

	if ValidateGcc; then
		if ValidateGcc; then
			echo	"${C_ORANGE}glibc...${C_RESET}";
			InstallGlibc;
		fi
	else
		MSG="${C_RED}Error${C_RESET}: Missing ${C_ORANGE}Linux API Headers${C_RESET} which is required before ${C_ORANGE}glibc${C_RESET}";
		return ;
	fi

	echo	"${C_ORANGE}Sanity check...${C_RESET}";
	if ToolchainTest1 1> /dev/null; then
		echo "${C_GREEN}OK${C_RESET}";
	else
		MSG="${C_RED}Error${C_RESET}: Failed sanity check...";
		return ;
	fi

	InstallLibstdcpp;

	# cd ~;	
}

ExtractPackage()
{
	SRC="$1";
	DST="$2";

	if [[ -z "$SRC" || ! -f "$SRC"  || -z "$DST" ]]; then
		echo	"Error: no $SRC or $DST";
		return 1;
	fi

	for FILENAME in $(tar -tf "$SRC"); do
		if [ ! -e ${DST}/${FILENAME} ]; then
			echo "Unpacking $SRC($FILENAME)...";
			mkdir -p "$DST";
			tar -xf "$SRC" -C "$DST";
			return $?;
		fi		
	done
	return 0;
}

# =====================================||===================================== #
#									Binutils								   #
# ===============ft_linux==============||==============©Othello=============== #

ValidateBinutils()
{
	if command -v as > /dev/null && command -v ld > /dev/null; then
		return 0
	else
		return 1
	fi
}

InstallPackageBinutils()
{
	PACKNAME="binutils-2.43.1";
	ExtractPackage	"${PDIR}${PACKNAME}.tar.xz"	"${PDIR}";
	if [ $? -ne 0 ]; then
		echo	"${C_RED}Error($?)${C_RESET}: failed to unpack binutils";
		return ;
	fi

	if ! mkdir -pv "${PDIR}${PACKNAME}/build"; then
		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
		return ;
	fi

	PBDIR="${PDIR}${PACKNAME}/build"
	cd "${PBDIR}";
	if [ ! -f "${PBDIR}/Makefile" ] || [ ! -f "${PBDIR}/config.status" ] || [ ! -f "${PBDIR}/config.log" ]; then
		echo	"${C_ORANGE}Configuring...${C_RESET}";
		time ../configure	--prefix=$LFS/tools	\
							--with-sysroot=$LFS	\
							--target=$LFS_TGT	\
							--disable-nls		\
							--enable-gprofng=no	\
							--disable-werror	\
							--enable-new-dtags	\
							--enable-default-hash-style=gnu 1> /dev/null;
	fi

	echo "Installing {$PACKNAME}...";
	time make 1> /dev/null;
	time make install 1> /dev/null;

	cd -;
}

# =====================================||===================================== #
#									   gcc									   #
# ===============ft_linux==============||==============©Othello=============== #

ValidateGcc()
{
	if command -v gcc > /dev/null; then
		return 0
	else
		return 1
	fi
}

InstallCrossGCC()
{
	# mkdir -p "${PDIR}gcc";

	PACKNAME="gcc-14.2.0";
	ExtractPackage	"${PDIR}${PACKNAME}.tar.xz"	"${PDIR}";

	# PACKNAME="mpfr-4.2.1";
	ExtractPackage	"${PDIR}mpfr-4.2.1.tar.xz"	"${PDIR}";
	mv -fv "${PDIR}mpfr-4.2.1" "${PDIR}${PACKNAME}/mpfr";

	# PACKNAME="gmp-6.3.0";
	ExtractPackage	"${PDIR}gmp-6.3.0.tar.xz"	"${PDIR}";
	mv -fv "${PDIR}gmp-6.3.0" "${PDIR}${PACKNAME}/gmp";

	# PACKNAME="mpc-1.3.1.tar.gz";
	ExtractPackage	"${PDIR}mpc-1.3.1.tar.gz"	"${PDIR}";
	mv -fv "${PDIR}mpc-1.3.1" "${PDIR}${PACKNAME}/mpc";

	case $(uname -m) in
		x86_64) sed -e '/m64=/s/lib64/lib/' -i.orig "${PDIR}${PACKNAME}/gcc/config/i386/t-linux64";;
	esac

	if ! mkdir -pv "${PDIR}${PACKNAME}/build"; then
		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
		return ;
	fi

	PBDIR="${PDIR}${PACKNAME}/build"
	cd "${PBDIR}";
	if [ ! -f "${PBDIR}/Makefile" ] || [ ! -f "${PBDIR}/config.status" ] || [ ! -f "${PBDIR}/config.log" ]; then
		echo	"${C_ORANGE}Configuring...${C_RESET}";
		time ../configure	--target=$LFS_TGT	\
							--prefix=$LFS/tools	\
							--with-glibc-version=2.40 \
							--with-sysroot=$LFS	\
							--with-newlib	\
							--without-headers	\
							--enable-default-pie	\
							--enable-default-ssp	\
							--disable-nls	\
							--disable-shared	\
							--disable-multilib	\
							--disable-threads	\
							--disable-libatomic	\
							--disable-libgomp	\
							--disable-libquadmath	\
							--disable-libssp	\
							--disable-libvtv	\
							--disable-libstdcxx	\
							-enable-languages=c,c++;
	fi

	echo "Installing {$PACKNAME}}...";
	time make 1> /dev/null;
	echo "completed make";
	time make install 1> /dev/null;
	echo "completed make install"

	cd -

	cat ${PDIR}${PACKNAME}/gcc/limitx.h \
		${PDIR}${PACKNAME}/gcc/glimits.h \
		${PDIR}${PACKNAME}/gcc/limity.h \
		> `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h
}


# =====================================||===================================== #
#								Linux API Headers							   #
# ===============ft_linux==============||==============©Othello=============== #

ExposeAPIHeaders()
{
	PACKNAME="linux-6.10.5";
	ExtractPackage	"${PDIR}${PACKNAME}.tar.xz"	"${PDIR}";

	cd "${PDIR}${PACKNAME}";

	echo	"Cleaning stale files...";
	make mrproper;

	echo	"Extracting user-visible kernel headers from source...";
	make headers
	find usr/include -type f ! -name '*.h' -delete
	cp -rv usr/include $LFS/usr

	cd -
}

# =====================================||===================================== #
#									  Glibc									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallGlibc()
{
	PACKNAME="glibc-2.40";
	ExtractPackage	"${PDIR}${PACKNAME}.tar.xz"	"${PDIR}";

	cd "${PDIR}${PACKNAME}";

	case $(uname -m) in
		i?86)	ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3;;
		x86_64)	ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64;
				ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3;;
	esac

	patch -Np1 -i ../glibc-2.40-fhs-1.patch;

	PBDIR="${PDIR}${PACKNAME}/build"
	if ! mkdir -pv "${PBDIR}"; then
		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
		return ;
	fi
	cd -;
	cd "${PBDIR}";


	if [ ! -f "${PBDIR}/Makefile" ]; then
		echo	"${C_ORANGE}Configuring ${PACKNAME}...${C_RESET}";
		echo "rootsbindir=/usr/sbin" > configparms
		time ../configure	--prefix=/usr	\
							--host=$LFS_TGT	\
							--build=$(../scripts/config.guess) \
							--enable-kernel=4.19	\
							--with-headers=$LFS/usr/include	\
							--disable-nscd	\
							libc_cv_slibdir=/usr/lib
	fi

	echo "Installing {$PACKNAME}...";
	time make;
	if [ "$(whoami)" != "root" ] && [ -n "$LFS" ]; then
		time make DESTDIR=$LFS install
	else
		echo "Error!: Almost made build unstable with glibc!";
		return 1;
	fi

	echo "Fixing hardcoded path...";
	sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

	cd -;
}

ToolchainTest1()
{
	echo 'int main(){}' | $LFS_TGT-gcc -xc -
	readelf -l a.out | grep ld-linux

	rm a.out
}

# =====================================||===================================== #
#																			   #
#									libstdcpp								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

InstallLibstdcpp()
{
	PACKNAME="gcc-14.2.0";
	
	PBDIR="${PDIR}${PACKNAME}/build"
	cd "${PBDIR}";

	PACKNAME="libstdc++";
	echo	"${C_ORANGE}Configuring ${PACKNAME}...${C_RESET}";
	../libstdc++-v3/configure	--host=$LFS_TGT\
								--build=$(../config.guess)\
								--prefix=/usr\
								--disable-multilib\
								--disable-nls\
								--disable-libstdcxx-pch\
								--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/14.2.0\
								1> /dev/null
	
	echo	"${C_ORANGE}Compiling ${PACKAGE}...${C_RESET}";
	make

	echo	"${C_ORANGE}Installing ${PACKNAME} library...${C_RESET}";
	make DESTDIR=$LFS install

	echo	"${C_ORANGE}Removing libtool archive files...${C_RESET} (they are harmful for cross-compilation)"
	rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la

	cd -
}

# =====================================||===================================== #
#																			   #
#									 Tools									   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

GetInput()
{
	echo	"$MSG";
	echo -n	"Choose an option: ";
	unset MSG;
	read	input;
	printf '%*s\n' "$width" '' | tr ' ' '-';
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
#									  Menu									   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

MainMenu()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE} LFS configuration${C_RESET} ($MENU)";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"1)\tUser configuration";
	echo	"2)\tCross-Toolchain compilling";
	echo	"q)\tQuit";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	case $input in
		1)	MENU=1;;
		2)	MENU=2;;
		# 1)	ConfigureUser;
		# 	PressAnyKeyToContinue;;
		# 2)	MenuCrossToolchain;
		# 	PressAnyKeyToContinue;;
		q|Q)	MENU=-1;;
		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";;
	esac
}

CLEARING=true;
MENU=0;

while true; do
	width=$(tput cols);
	if [ $CLEARING = true ]; then
		clear;
	fi

	case $MENU in
		-1)	break ;;
		0)	MainMenu;;
		1)	ConfigureUserMenu;;
		2)	MenuCrossToolchain;;
		*)	echo	"${C_RED}Error${C_RESET}: Invalid menu '$MENU;";
			exit $MENU;;
	esac
done