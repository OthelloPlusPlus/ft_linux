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

declare -A binutils;
binutils[package]="binutils-2.43.1";
binutils[status]="";
binutils[SBU]="1";
binutils[time]="0";

declare -A gcc
gcc[package]="gcc-14.2.0";
gcc[status]="";
gcc[SBU]="3.2";
gcc[time]="0";

declare -A LinuxApiHeader
LinuxApiHeader[package]="linux-6.10.5";
LinuxApiHeader[status]="";
LinuxApiHeader[SBU]="<0.1";
LinuxApiHeader[time]="0";

declare -A glibc
glibc[package]="glibc-2.40";
glibc[status]="";
glibc[SBU]="1.3";
glibc[time]="0";

declare -A libstdcpp
libstdcpp[package]="${gcc[package]}";
libstdcpp[status]="";
libstdcpp[SBU]="0.2";
libstdcpp[time]="0";

MenuCrossToolchain()
{
	PDIR="$LFS/sources/lfs-packages12.2/";

	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE}Cross-Toolchain${C_RESET}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	ValidateBinutils;				echo -n	"1 ";	PrintPackage	binutils;
	ValidateGcc;					echo -n	"2 ";	PrintPackage	gcc;
	ValidateAPIHeaders;				echo -n	"3 ";	PrintPackage	LinuxApiHeader;
	ToolchainTest1 >/dev/null;		echo -n	"4 ";	PrintPackage	glibc;
	ValidateLibstdCpp >/dev/null;	echo -n	"5 ";	PrintPackage	libstdcpp;
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo -n	"gcc sanity check:";	ToolchainTest1;
	echo -n	"g++ sanity check:";	ValidateLibstdCpp;
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"#)\tInstall package"
	echo	"i)\tInstall all packages"
	echo	"f)\tForce install all packages"
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	case $input in
		1)	InstallPackageBinutils;
			PressAnyKeyToContinue;;
		2)	InstallCrossGCC;
			PressAnyKeyToContinue;;
		3)	ExposeAPIHeaders;
			PressAnyKeyToContinue;;
		4)	InstallGlibc;
			PressAnyKeyToContinue;;
		5)	InstallLibstdcpp;
			PressAnyKeyToContinue;;
		i|I)	InstallPackages;
				PressAnyKeyToContinue;;
		f|F)	InstallPackages "true";
				PressAnyKeyToContinue;;
		q|Q)	MENU=0;;
		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";;
	esac
}

PrintPackage()
{
	local STATUS="$(eval echo "\${${1}[status]}")";
	local time=$(eval echo "\${${1}[time]}")
	local TimeStamp=$(printf "%02d:%02d:%02d"	"$(($time/3600))"	"$((($time % 3600) / 60))"	"$(($time % 60))");

	if [ "$STATUS" = true ]; then
		printf	"${C_GREEN}%-23s${C_RESET} %-4s SBU %9s\n"	$(eval echo "\${${1}[package]}")	$(eval echo "\${${1}[SBU]}")	"$TimeStamp";
	elif [ "$STATUS" = false ]; then
		printf	"${C_RED}%-23s${C_RESET} %-4s SBU %9s\n"	$(eval echo "\${${1}[package]}")	$(eval echo "\${${1}[SBU]}")	"$TimeStamp";
	else
		printf	"${C_GRAY}%-23s${C_RESET} %-4s SBU %9s\n"	$(eval echo "\${${1}[package]}")	$(eval echo "\${${1}[SBU]}")	"$TimeStamp";
	fi
}

InstallPackages()
{
	PDIR="$LFS/sources/lfs-packages12.2/";
	# cd "$PDIR";

	if [ "$1" = true ]; then
		echo	"${C_ORANGE}binutils...${C_RESET}";
		InstallPackageBinutils;
		echo	"${C_ORANGE}gcc...${C_RESET}";
		InstallCrossGCC;
		echo	"${C_ORANGE}Linux API Headers...${C_RESET}";
		ExposeAPIHeaders;
		echo	"${C_ORANGE}glibc...${C_RESET}";
		InstallGlibc;
		echo	"${C_ORANGE}libstdc++...${C_RESET}";
		InstallLibstdcpp;
	else
		# binutils
		if [ $binutils[status] = false ]; then
			echo	"${C_ORANGE}binutils...${C_RESET}";
			InstallPackageBinutils;
			ValidateBinutils;
		fi
		# gcc
		if [ $binutils[status] = true ]; then
			if [ $gcc[status] = false ]; then
				echo	"${C_ORANGE}gcc...${C_RESET}";
				InstallCrossGCC;
				ValidateGcc;
			fi
		else
			MSG="${C_RED}Error${C_RESET}: Missing ${C_ORANGE}binutils${C_RESET} which is required before ${C_ORANGE}gcc${C_RESET}";
			return ;
		fi
		# Linux API headers
		if [ $gcc[status] = true ]; then
			if [ $LinuxApiHeader[status] = false ]; then
				echo	"${C_ORANGE}Linux API Headers...${C_RESET}";
				ExposeAPIHeaders;
				ValidateAPIHeaders;
			fi
		else
			MSG="${C_RED}Error${C_RESET}: Missing ${C_ORANGE}gcc${C_RESET} which is required before ${C_ORANGE}Linux API Headers${C_RESET}";
			return ;
		fi
		# glibc
		if [ $LinuxApiHeader[status] = true ]; then
			if [ $glibc[status] = false ]; then
				echo	"${C_ORANGE}glibc...${C_RESET}";
				InstallGlibc;
				ValidateGlibc;
			fi
		else
			MSG="${C_RED}Error${C_RESET}: Missing ${C_ORANGE}gcc${C_RESET} which is required before ${C_ORANGE}glibc${C_RESET}";
			return ;
		fi
		# LibstdC++
		if [ $glibc[status] = true ]; then
			if [ $libstdcpp[status] = false ]; then
				InstallLibstdcpp;
			fi
		else
			MSG="${C_RED}Error${C_RESET}: Missing ${C_ORANGE}glibc${C_RESET} which is required before ${C_ORANGE}libstdc++${C_RESET}";
			return ;
		fi
	fi

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
			echo "${C_ORANGE}Unpacking $SRC($FILENAME)...${C_RESET}";
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
	if ! cd "${PDIR}${binutils[package]}/build" 2> /dev/null; then
		return ;
	fi

	if	make check >/dev/null 2>&1 && \
		command -v as > /dev/null && \
		command -v ld > /dev/null; then
		binutils[status]=true;
	else
		binutils[status]=false;
	fi

	cd -;

	# if command -v as > /dev/null && command -v ld > /dev/null; then
	# 	binutils[status]=true;
	# 	return 0
	# else
	# 	binutils[status]=false;
	# 	return 1
	# fi
}

InstallPackageBinutils()
{
	ExtractPackage	"${PDIR}${binutils[package]}.tar.xz"	"${PDIR}";

	if [ $? -ne 0 ]; then
		echo	"${C_RED}Error($?)${C_RESET}: failed to unpack binutils";
		return ;
	fi

	if ! mkdir -pv "${PDIR}${binutils[package]}/build"; then
		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
		return ;
	fi

	PBDIR="${PDIR}${binutils[package]}/build"
	cd "${PBDIR}";
	binutils[time]=$(date +%s);
	if [ ! -f "${PBDIR}/Makefile" ] || [ ! -f "${PBDIR}/config.status" ] || [ ! -f "${PBDIR}/config.log" ]; then
		echo	"${C_ORANGE}Configuring ${binutils[package]}...${C_RESET}";
		time ../configure	--prefix=$LFS/tools	\
							--with-sysroot=$LFS	\
							--target=$LFS_TGT	\
							--disable-nls		\
							--enable-gprofng=no	\
							--disable-werror	\
							--enable-new-dtags	\
							--enable-default-hash-style=gnu	\
							1> /dev/null;
	fi
	echo	"${C_ORANGE}Installing ${binutils[package]}${C_RESET}";
	echo	"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null;
	echo	"${C_ORANGE}Installing ${binutils[package]}...${C_RESET}";
	echo	"${C_DGRAY}> make install 1> /dev/null${C_RESET}";
	time make install 1> /dev/null;

	binutils[time]=$(( $(date +%s) - $binutils[time] ));
	cd -;
}

# =====================================||===================================== #
#									   gcc									   #
# ===============ft_linux==============||==============©Othello=============== #

ValidateGcc()
{
	if ! cd "${PDIR}${gcc[package]}/build" 2> /dev/null; then
		return ;
	fi

	if	make check > /dev/null 2>&1 && \
		command -v gcc > /dev/null; then
		gcc[status]=true;
	else
		gcc[status]=false;
	fi

	cd -;
	# if command -v gcc > /dev/null; then
	# 	gcc[status]=true;
	# 	return 0
	# else
	# 	gcc[status]=false;
	# 	return 1
	# fi
}

InstallCrossGCC()
{
	ExtractPackage	"${PDIR}${gcc[package]}.tar.xz"	"${PDIR}";

	# PACKNAME="mpfr-4.2.1";
	ExtractPackage	"${PDIR}mpfr-4.2.1.tar.xz"	"${PDIR}";
	mv -fv "${PDIR}mpfr-4.2.1" "${PDIR}${gcc[package]}/mpfr";

	# PACKNAME="gmp-6.3.0";
	ExtractPackage	"${PDIR}gmp-6.3.0.tar.xz"	"${PDIR}";
	mv -fv "${PDIR}gmp-6.3.0" "${PDIR}${gcc[package]}/gmp";

	# PACKNAME="mpc-1.3.1.tar.gz";
	ExtractPackage	"${PDIR}mpc-1.3.1.tar.gz"	"${PDIR}";
	mv -fv "${PDIR}mpc-1.3.1" "${PDIR}${gcc[package]}/mpc";

	case $(uname -m) in
		x86_64) sed -e '/m64=/s/lib64/lib/' -i.orig "${PDIR}${gcc[package]}/gcc/config/i386/t-linux64";;
	esac

	if ! mkdir -pv "${PDIR}${gcc[package]}/build"; then
		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
		return ;
	fi

	PBDIR="${PDIR}${gcc[package]}/build"
	cd "${PBDIR}";

	gcc[time]=$(date +%s);
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
							-enable-languages=c,c++	\
							1> /dev/null;
	fi

	echo	"${C_ORANGE}Installing ${gcc[package]}...${C_RESET}";
	echo	"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null;
	echo	"${C_ORANGE}Installing ${gcc[package]}...${C_RESET}";
	echo	"${C_DGRAY}> make install 1> /dev/null${C_RESET}";
	time make install 1> /dev/null;

	cd -

	echo	"${C_ORANGE}Copying header files...${C_RESET}"
	cat ${PDIR}${gcc[package]}/gcc/limitx.h \
		${PDIR}${gcc[package]}/gcc/glimits.h \
		${PDIR}${gcc[package]}/gcc/limity.h \
		> `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h
	gcc[time]=$(( $(date +%s) - $gcc[time] ));
}


# =====================================||===================================== #
#								Linux API Headers							   #
# ===============ft_linux==============||==============©Othello=============== #

ValidateAPIHeaders()
{
	local INCLUDE_DIR="$LFS/usr/include";
	if [ ! -d "$INCLUDE_DIR" ]; then
		LinuxApiHeader[status]=false;
		return 1;
	fi

	declare -A HeaderDirectoryList;
	HeaderDirectoryList[asm]=65;
	HeaderDirectoryList[asm-generic]=37;
	HeaderDirectoryList[drm]=28;
	HeaderDirectoryList[linux]=781;
	HeaderDirectoryList[misc]=7;
	HeaderDirectoryList[mtd]=5;
	HeaderDirectoryList[rdma]=29;
	HeaderDirectoryList[regulator]=1;
	HeaderDirectoryList[scsi]=10;
	HeaderDirectoryList[sound]=23;
	HeaderDirectoryList[video]=3;
	HeaderDirectoryList[xen]=4;

	for DIRECTORY in ${(k)HeaderDirectoryList}; do
		if [ ! -d "$INCLUDE_DIR/$DIRECTORY" ]; then
			MSG="${C_RED}Error${C_RESET}(${C_ORANGE}Linux API Header${C_RESET}): Missing directory ${C_ORANGE}$INCLUDE_DIR/$DIRECTORY${C_RESET}"
			LinuxApiHeader[status]=false;
			return 2;
		elif [ ${HeaderDirectoryList[$DIRECTORY]} -gt $(find $INCLUDE_DIR/$DIRECTORY -type f -name '*.h' | wc -l) ]; then
			MSG="${C_RED}Error${C_RESET}(${C_ORANGE}Linux API Header${C_RESET}): Missing headers in directory ${C_ORANGE}$INCLUDE_DIR/$DIRECTORY${C_RESET}"
			LinuxApiHeader[status]=false;
			return 3;
		fi
	done
	LinuxApiHeader[status]=true;
	return 0;
}


ExposeAPIHeaders()
{
	# PACKNAME="linux-6.10.5";
	ExtractPackage	"${PDIR}${LinuxApiHeader[package]}.tar.xz"	"${PDIR}";

	cd "${PDIR}${LinuxApiHeader[package]}";
	LinuxApiHeader[time]=$(date +%s);

	echo	"${C_ORANGE}Cleaning stale files...${C_RESET}";
	echo	"${C_DGRAY}> make mrproper 1> /dev/null${C_RESET}";
	time make mrproper 1> /dev/null;

	echo	"${C_ORANGE}Extracting user-visible kernel headers from source...${C_RESET}";
	echo	"${C_DGRAY}> make headers 1> /dev/null${C_RESET}";
	time make headers 1> /dev/null;

	echo	"${C_ORANGE}Copying headers to $LFS/usr/include...${C_RESET}";
	echo	"${C_DGRAY}> cp -rv usr/include \$LFS/usr 1> /dev/null${C_RESET}";
	find usr/include -type f ! -name '*.h' -delete
	cp -rv usr/include $LFS/usr 1> /dev/null

	LinuxApiHeader[time]=$(( $(date +%s) - $LinuxApiHeader[time] ));
	cd -
}

# =====================================||===================================== #
#									  Glibc									   #
# ===============ft_linux==============||==============©Othello=============== #

ValidateGlibc()
{
	if ToolchainTest1 > /dev/null; then
		glibc[status]=true;
		return 0;
	else
		glibc[status]=false;
		return 1;
	fi
}

InstallGlibc()
{
	# PACKNAME="glibc-2.40";
	ExtractPackage	"${PDIR}${glibc[package]}.tar.xz"	"${PDIR}";

	cd "${PDIR}${glibc[package]}";
	glibc[time]=$(date +%s);

	case $(uname -m) in
		i?86)	ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3;;
		x86_64)	ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64;
				ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3;;
	esac

	patch -Np1 -i ../glibc-2.40-fhs-1.patch;

	PBDIR="${PDIR}${glibc[package]}/build"
	if ! mkdir -pv "${PBDIR}"; then
		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
		return ;
	fi
	cd -;
	cd "${PBDIR}";


	if [ ! -f "${PBDIR}/Makefile" ]; then
		echo	"${C_ORANGE}Configuring ${glibc[package]}...${C_RESET}";
		echo "rootsbindir=/usr/sbin" > configparms
		time ../configure	--prefix=/usr	\
							--host=$LFS_TGT	\
							--build=$(../scripts/config.guess)	\
							--enable-kernel=4.19	\
							--with-headers=$LFS/usr/include	\
							--disable-nscd	\
							libc_cv_slibdir=/usr/lib	\
							1> /dev/null
	fi

	echo	"${C_ORANGE}Installing ${glibc[package]}...${C_RESET}";
	echo	"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null;
	if [ "$(whoami)" != "root" ] && [ -n "$LFS" ]; then
		echo	"${C_ORANGE}Installing ${glibc[package]}...${C_RESET}";
		echo	"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
		time make DESTDIR=$LFS install 1> /dev/null
	else
		echo "Error!: Almost made build unstable with glibc!";
		return 1;
	fi

	echo	"${C_ORANGE}Fixing hardcoded path...${C_RESET}";
	sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

	glibc[time]=$(( $(date +%s) - $glibc[time] ));
	cd -;
}

ToolchainTest1()
{
	echo 'int main(){}' | $LFS_TGT-gcc -xc - -o gcctest.out
	if [ -f "gcctest.out" ]; then
		readelf -l gcctest.out | grep ld-linux
		if [ $? -eq 0 ]; then
			glibc[status]=true;
		else
			glibc[status]=false;
		fi

		rm gcctest.out
	else
		glibc[status]=false;
	fi
}

# =====================================||===================================== #
#									libstdcpp								   #
# ===============ft_linux==============||==============©Othello=============== #

ValidateLibstdCpp()
{
	echo '#include <cstdlib>
	int main(){}' | $LFS_TGT-g++ -xc - -o gpptest.out

	if [ -f "gpptest.out" ]; then
		readelf -l gpptest.out | grep ld-linux
		if [ $? -eq 0 ]; then
			libstdcpp[status]=true;
		else
			libstdcpp[status]=false;
		fi
		rm gpptest.out;
	else
		libstdcpp[status]=false;
	fi
	echo	"${C_RED}Note${C_RESET}: Not testing propperly..."
}

InstallLibstdcpp()
{
	PACKNAME="libstdc++";

	echo	"${C_ORANGE}Double checking Toolchain ...${C_RESET}";
	ToolchainTest1	1> /dev/null;
	if [ "$glibc[status]" != true ]; then
		MSG="${C_RED}Error${C_RESET}: Toolchain test failed. Aborting $PACKNAME...${C_RESET}"
		return ;
	fi
	
	PBDIR="${PDIR}${libstdcpp[package]}/build"
	cd "${PBDIR}";
	libstdcpp[time]=$(date +%s);

	echo	"${C_ORANGE}Configuring ${PACKNAME}...${C_RESET}";
	../libstdc++-v3/configure	--host=$LFS_TGT	\
								--build=$(../config.guess)	\
								--prefix=/usr	\
								--disable-multilib	\
								--disable-nls	\
								--disable-libstdcxx-pch	\
								--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/14.2.0	\
								1> /dev/null
	
	echo	"${C_ORANGE}Compiling ${libstdcpp[package]}...${C_RESET}";
	echo	"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	make 1> /dev/null

	echo	"${C_ORANGE}Installing ${PACKNAME} library...${C_RESET}";
	echo	"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	make DESTDIR=$LFS install 1> /dev/null

	echo	"${C_ORANGE}Removing libtool archive files...${C_RESET} (they are harmful for cross-compilation)"
	rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la

	libstdcpp[time]=$(( $(date +%s) - $libstdcpp[time] ));
	cd -
}

# =====================================||===================================== #
#																			   #
#					Chapter 6. Cross Compiling Temporary Tools				   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

MenuTemporaryTools()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE}Temporary Tools${C_RESET}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"i)\tInstall temporary tools"
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	PDIR="$LFS/sources/lfs-packages12.2/";

	case $input in
		i|I)	InstallPackageM4;
				PressAnyKeyToContinue;;
		q|Q)	MENU=0;;
		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";;
	esac
}

InstallPackageTemp()
{
	PACKAGE="";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

	if ! mkdir -pv "${PDIR}${PACKAGE}/build"; then
		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
		return ;
	fi
	PBDIR="${PDIR}${PACKAGE}/build";
	cd "${PBDIR}";

	echo	"${C_ORANGE}Installing ${PACKAGE}...${C_RESET}";
	echo	"${C_DGRAY}> ${C_RESET}";

	cd -;
}

ValidatePackageM4()
{
	PACKAGE="m4-1.4.19";
	make -C "${PDIR}${PACKAGE}" check;

	echo $?;
}

InstallPackageM4()
{
	PACKAGE="m4-1.4.19";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

	PBDIR="${PDIR}${PACKAGE}";
	cd "${PBDIR}";

	echo	"${C_ORANGE}Configuring ${PACKAGE}...${C_RESET}";
	./configure --prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null;
	

	echo	"${C_ORANGE}Installing ${PACKAGE}...${C_RESET}";
	echo	"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	make 1> /dev/null

	echo	"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	make DESTDIR=$LFS install 1> /dev/null
	cd -;
}

InstallPackageNcurses()
{
	PACKAGE="";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

	if ! mkdir -pv "${PDIR}${PACKAGE}/build"; then
		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
		return ;
	fi
	PBDIR="${PDIR}${PACKAGE}";
	cd "${PBDIR}";
	sed -i s/mawk// configure
	if [ $? -ne 0 ]; then
		return ;
	fi
	pushd build
		../configure
		make -C include	1> /dev/null
		make -C progs tic	1> /dev/null
	popd

	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(./config.guess)	\
				--mandir=/usr/share/man	\
				--with-manpage-format=normal \
				--with-shared	\
				--without-normal	\
				--with-cxx-shared	\
				--without-debug	\
				--without-ada	\
				--disable-stripping	\
				1> /dev/null;

	make;
	make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
	ln	-sv libncursesw.so $LFS/usr/lib/libncurses.so
	sed	-e 's/^#if.*XOPEN.*$/#if 1/'	\
		-i $LFS/usr/include/curses.h

	cd -;
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
	echo	"${C_ORANGE} LFS configuration${C_RESET}";
	echo	"Menu:\t${MENU}";
	echo	"Option:\t${-}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"1)\tUser configuration";
	echo	"2)\tCross-Toolchain compilling";
	echo	"3)\tCross-compiling temporary tools"
	echo	"q)\tQuit";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	case $input in
		1)	MENU=1;;
		2)	MENU=2;;
		3)	MENU=3;;
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
		3)	MenuTemporaryTools;;
		*)	echo	"${C_RED}Error${C_RESET}: Invalid menu '$MENU;";
			exit $MENU;;
	esac
done