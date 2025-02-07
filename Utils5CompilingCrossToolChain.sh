#! /bin/zsh

source Utils.sh

# =====================================||===================================== #
#																			   #
#					 Chapter 5. Compiling a Cross-Toolchain					   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A binutils;
binutils[name]="binutils";
binutils[version]="2.43.1";
binutils[package]="binutils-2.43.1";
binutils[status]="";
binutils[SBU]="1";
binutils[time]="0";

declare -A gcc;
gcc[name]="gcc";
gcc[version]="14.2.0";
gcc[package]="gcc-14.2.0";
gcc[status]="";
gcc[SBU]="3.2";
gcc[time]="0";

declare -A LinuxApiHeader;
LinuxApiHeader[name]="LinuxApiHeader";
LinuxApiHeader[version]="6.10.5";
LinuxApiHeader[package]="linux-6.10.5";
LinuxApiHeader[status]="";
LinuxApiHeader[SBU]="<0.1";
LinuxApiHeader[time]="0";

declare -A glibc;
glibc[name]="glibc";
glibc[version]="2.40";
glibc[package]="glibc-2.40";
glibc[status]="";
glibc[SBU]="1.3";
glibc[time]="0";

declare -A libstdcpp;
libstdcpp[name]="libstdcpp";
libstdcpp[version]="${gcc[version]}";
libstdcpp[package]="${gcc[package]}";
libstdcpp[status]="";
libstdcpp[SBU]="0.2";
libstdcpp[time]="0";

# =====================================||===================================== #
#																			   #
#					 				  Utils									   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

PrintPackage()
{
	local STATUS="$(eval echo "\${${1}[status]}")";
	local time=$(eval echo "\${${1}[time]}")
	local TimeStamp=$(printf "%02d:%02d:%02d"	"$(($time/3600))"	"$((($time % 3600) / 60))"	"$(($time % 60))");

	if [ "$STATUS" = true ]; then
		printf	"${C_GREEN}%-23s${C_RESET} %-4s SBU %9s\n"	$(eval echo "\${${1}[name]}-\${${1}[version]}")	$(eval echo "\${${1}[SBU]}")	"$TimeStamp";
	elif [ "$STATUS" = false ]; then
		printf	"${C_RED}%-23s${C_RESET} %-4s SBU %9s\n"	$(eval echo "\${${1}[name]}-\${${1}[version]}")	$(eval echo "\${${1}[SBU]}")	"$TimeStamp";
	else
		printf	"${C_GRAY}%-23s${C_RESET} %-4s SBU %9s\n"	$(eval echo "\${${1}[name]}-\${${1}[version]}")	$(eval echo "\${${1}[SBU]}")	"$TimeStamp";
	fi
}

InstallPackages()
{
	# PDIR="$LFS/sources/lfs-packages12.2/";
	# cd "$PDIR";

	if [ "$1" = true ]; then
		EchoInfo	"binutils...";
		InstallBinutils;
		EchoInfo	"gcc...";
		InstallGccPass1;
		EchoInfo	"Linux API Headers...";
		ExtractApiHeaders;
		EchoInfo	"glibc...";
		InstallGlibc;
		EchoInfo	"libstdc++...";
		InstallLibstdcpp;
	else
		# binutils
		if [ "$binutils[status]" != true ]; then
			EchoInfo	"binutils...";
			InstallBinutils;
		fi
		# gcc
		if [ "$binutils[status]" = true ]; then
			if [ "$gcc[status]" != true ]; then
				EchoInfo	"gcc...";
				InstallGccPass1;
			fi
		else
			MSG="${C_RED}Error${C_RESET}: Missing ${C_ORANGE}binutils${C_RESET} which is required before ${C_ORANGE}gcc${C_RESET}";
			return ;
		fi
		# Linux API headers
		if [ "$gcc[status]" = true ]; then
			if [ "$LinuxApiHeader[status]" != true ]; then
				EchoInfo	"Linux API Headers...";
				ExtractApiHeaders;
			fi
		else
			MSG="${C_RED}Error${C_RESET}: Missing ${C_ORANGE}gcc${C_RESET} which is required before ${C_ORANGE}Linux API Headers${C_RESET}";
			return ;
		fi
		# glibc
		if [ "$LinuxApiHeader[status]" = true ]; then
			if [ "$glibc[status]" != true ]; then
				EchoInfo	"glibc...";
				InstallGlibc;
			fi
		else
			MSG="${C_RED}Error${C_RESET}: Missing ${C_ORANGE}gcc${C_RESET} which is required before ${C_ORANGE}glibc${C_RESET}";
			return ;
		fi
		# LibstdC++
		if [ "$glibc[status]" = true ]; then
			if [ "$libstdcpp[status]" != true ]; then
				EchoInfo	"libstdc++...";
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
		EchoError	"No $SRC or $DST";
		return 1;
	fi

	for FILENAME in $(tar -tf "$SRC"); do
		if [ ! -e ${DST}/${FILENAME} ]; then
			EchoInfo	"Unpacking $SRC($FILENAME)...";
			mkdir -p "$DST";
			tar -xf "$SRC" -C "$DST";
			return $?;
		fi
	done
	return 0;
}

ValidatePackages()
{
	# ConfigureBinutils;
	ValidateBinutils;

	# ConfigureGccPass1;
	ValidateGccPass1;

	ValidateAPIHeaders;

	ValidateGlibc;

	# ConfigureLibstdcpp;
	ValidateLibstdcpp;
}

# =====================================||===================================== #
#									Binutils								   #
# ===============ft_linux==============||==============©Othello=============== #

InstallBinutils()
{
	ExtractPackage	"${PDIR}${binutils[package]}.tar.xz"	"${PDIR}";

	if [ $? -ne 0 ]; then
		EchoError	"Failed to unpack binutils";
		return ;
	fi

	if ! mkdir -pv "${PDIR}${binutils[package]}/build"; then
		EchoError	"Failed to make build directory.";
		return ;
	fi

	binutils[time]=$(date +%s);

	ConfigureBinutils;
	InstallPackageBinutils;

	binutils[time]=$(( $(date +%s) - $binutils[time] ));

	ValidateBinutils;
}

ConfigureBinutils()
{
	local PBDIR="${PDIR}${binutils[package]}/build";

	if ! cd "${PDIR}${binutils[package]}/build" 2> /dev/null; then
		return ;
	fi

	if [ ! -f "${PBDIR}/Makefile" ] || [ ! -f "${PBDIR}/config.status" ] || [ ! -f "${PBDIR}/config.log" ]; then
		EchoInfo	"Configuring ${binutils[package]}...";
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

	cd -;
}

InstallPackageBinutils()
{
	if ! cd "${PDIR}${binutils[package]}/build" 2> /dev/null; then
		return ;
	fi

	EchoInfo	"Compiling ${binutils[package]}";
	echo	"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${binutils[package]} && PressAnyKeyToContinue; return;};
	EchoInfo	"Installing ${binutils[package]}...${C_RESET}";
	echo	"${C_DGRAY}> make install 1> /dev/null${C_RESET}";
	time make install 1> /dev/null || {EchoTest KO ${binutils[package]} && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateBinutils()
{
	if ! cd "${PDIR}${binutils[package]}/build" 2> /dev/null; then
		return ;
	fi

	if make check &>/dev/null && \
		command -v as > /dev/null && \
		command -v ld > /dev/null; then
		binutils[status]=true;
	else
		binutils[status]=false;
	fi

	cd -;
}

# =====================================||===================================== #
#									  Gcc									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallGccPass1()
{
	if ! ExtracPackagesGccPass1; then
		return ;
	fi

	# On x86_64 hosts, set the default directory name for 64-bit libraries to “lib”
	case $(uname -m) in
		x86_64) sed -e '/m64=/s/lib64/lib/' -i.orig "${PDIR}${gcc[package]}/gcc/config/i386/t-linux64";;
	esac

	if ! mkdir -pv "${PDIR}${gcc[package]}/build"; then
		EchoError	"Failed to make build directory.";
		return ;
	fi

	gcc[time]=$(date +%s);
	ConfigureGccPass1;
	InstallPackageGccPass1;
	gcc[time]=$(( $(date +%s) - $gcc[time] ));

	ValidateGccPass1;

	# Create a full version of the internal header
	echo	"${C_ORANGE}Copying header files...${C_RESET}"
	cat ${PDIR}${gcc[package]}/gcc/limitx.h \
		${PDIR}${gcc[package]}/gcc/glimits.h \
		${PDIR}${gcc[package]}/gcc/limity.h \
		> $(dirname $($LFS_TGT-gcc -print-libgcc-file-name))/include/limits.h
}

ExtracPackagesGccPass1()
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

	if	[ ! -d "${PDIR}${gcc[package]}" ] ||
		[ ! -d "${PDIR}${gcc[package]}/mpfr" ] ||
		[ ! -d "${PDIR}${gcc[package]}/gmp" ] ||
		[ ! -d "${PDIR}${gcc[package]}/mpc" ]; then
		EchoError	"Failed to unpack a package for gcc{mpfr, gmp, mpc}...";
		return false;
	fi
	return true;
}

ConfigureGccPass1()
{
	local PBDIR="${PDIR}${gcc[package]}/build";

	if ! cd "${PDIR}${gcc[package]}/build" 2> /dev/null; then
		return ;
	fi

	# if [ ! -f "${PBDIR}/Makefile" ] || [ ! -f "${PBDIR}/config.status" ] || [ ! -f "${PBDIR}/config.log" ]; then
		EchoInfo	"Configuring...";
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
	# fi

	cd -;
}

InstallPackageGccPass1()
{
	if ! cd "${PDIR}${gcc[package]}/build" 2> /dev/null; then
		return ;
	fi

	EchoInfo	"Compiling ${gcc[package]}...";
	echo	"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${gcc[package]} && PressAnyKeyToContinue; return;};
	EchoInfo	"Installing ${gcc[package]}...";
	echo	"${C_DGRAY}> make install 1> /dev/null${C_RESET}";
	time make install 1> /dev/null || {EchoTest KO ${gcc[package]} && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateGccPass1()
{
	if ! cd "${PDIR}${gcc[package]}/build" 2> /dev/null; then
		return ;
	fi

	if command -v gcc >/dev/null && \
		make check-gcc &> /dev/null &&
	then
		gcc[status]=true;
	else
		if make check &> /dev/null; then
			gcc[status]=true;
		else
			gcc[status]=false;
		fi
	fi;

	cd -;
}

# =====================================||===================================== #
#								Linux API Headers							   #
# ===============ft_linux==============||==============©Othello=============== #

ExtractApiHeaders()
{
	# PACKNAME="linux-6.10.5";
	ExtractPackage	"${PDIR}${LinuxApiHeader[package]}.tar.xz"	"${PDIR}";

	LinuxApiHeader[time]=$(date +%s);

	MakeAndMoveApiHeaders;

	LinuxApiHeader[time]=$(( $(date +%s) - $LinuxApiHeader[time] ));

	ValidateAPIHeaders;

}

MakeAndMoveApiHeaders()
{
	if ! cd "${PDIR}${LinuxApiHeader[package]}" 2> /dev/null; then
		return ;
	fi

	EchoInfo	"Cleaning stale files...";
	echo	"${C_DGRAY}> make mrproper 1> /dev/null${C_RESET}";
	time make mrproper 1> /dev/null || {EchoTest KO ${LinuxApiHeader[package]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Extracting user-visible kernel headers from source...";
	echo	"${C_DGRAY}> make headers 1> /dev/null${C_RESET}";
	time make headers 1> /dev/null || {EchoTest KO ${LinuxApiHeader[package]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Copying headers to $LFS/usr/include...";
	echo	"${C_DGRAY}> cp -rv usr/include \$LFS/usr 1> /dev/null${C_RESET}";
	find usr/include -type f ! -name '*.h' -delete
	cp -rv usr/include $LFS/usr 1> /dev/null

	cd -;

}

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

# =====================================||===================================== #
#									  Glibc									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallGlibc()
{
	# PACKNAME="glibc-2.40";
	ExtractPackage	"${PDIR}${glibc[package]}.tar.xz"	"${PDIR}";

	if [ $? -ne 0 ]; then
		EchoError	"Failed to unpack glibc";
		return ;
	fi

	if ! mkdir -pv "${PDIR}${glibc[package]}/build"; then
		EchoError	"Failed to make build directory.";
		return ;
	fi

	glibc[time]=$(date +%s);

	PrepareGlibc;
	ConfigureGlibc;
	InstallPackageGlibc;

	glibc[time]=$(( $(date +%s) - $glibc[time] ));

	ValidateGlibc;

	cd -;
}

PrepareGlibc()
{
	if ! cd "${PDIR}${glibc[package]}" 2> /dev/null; then
		return ;
	fi

	# For x86_64, create a compatibility symbolic link required for proper operation of the dynamic library loader
	case $(uname -m) in
		i?86)	ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3;;
		x86_64)	ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64;
				ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3;;
	esac

	# Patch to make programs store their runtime data in the FHS-compliant locations.
	patch -Np1 -i ../glibc-2.40-fhs-1.patch;

	cd -;

}

ConfigureGlibc()
{
	if ! cd "${PDIR}${glibc[package]}/build" 2> /dev/null; then
		return ;
	fi

	if [ ! -f "${PBDIR}/Makefile" ]; then
		EchoInfo	"Configuring ${glibc[package]}...";
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

	cd -;
}

InstallPackageGlibc()
{
	if ! cd "${PDIR}${glibc[package]}/build" 2> /dev/null; then
		return ;
	fi

	EchoInfo	"Compiling ${glibc[package]}...";
	echo	"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${glibc[package]} && PressAnyKeyToContinue; return;};
	if [ "$(whoami)" != "root" ] && [ -n "$LFS" ]; then
		EchoInfo	"Installing ${glibc[package]}...";
		echo	"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
		time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${glibc[package]} && PressAnyKeyToContinue; return;};
	else
		EchoError "Almost made build unstable with glibc!";
		PressAnyKeyToContinue;
		return 1;
	fi

	EchoInfo	"Fixing hardcoded path...";
	sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

	cd -;
}

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

InstallLibstdcpp()
{
	PACKNAME="libstdc++";

	EchoInfo	"Double checking Toolchain ...";
	ToolchainTest1	1> /dev/null;
	if [ "$glibc[status]" != true ]; then
		MSG="${C_RED}Error${C_RESET}: Toolchain test failed. Aborting $PACKNAME...${C_RESET}"
		return ;
	fi
	
	libstdcpp[time]=$(date +%s);

	ConfigureLibstdcpp;
	InstallPackageLibstdcpp;

	libstdcpp[time]=$(( $(date +%s) - $libstdcpp[time] ));

	ValidateLibstdcpp;

	cd -
}

ConfigureLibstdcpp()
{
	if ! cd "${PDIR}${libstdcpp[package]}/build" 2> /dev/null; then
		return ;
	fi
	
	EchoInfo	"Configuring ${PACKNAME}...";
	../libstdc++-v3/configure	--host=$LFS_TGT	\
								--build=$(../config.guess)	\
								--prefix=/usr	\
								--disable-multilib	\
								--disable-nls	\
								--disable-libstdcxx-pch	\
								--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/14.2.0	\
								1> /dev/null

	cd -;
}

InstallPackageLibstdcpp()
{
	if ! cd "${PDIR}${libstdcpp[package]}/build" 2> /dev/null; then
		return ;
	fi

	EchoInfo	"Compiling ${libstdcpp[package]}...";
	echo	"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	make 1> /dev/null || {EchoTest KO ${libstdcpp[name]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing ${PACKNAME} library...";
	echo	"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${libstdcpp[name]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Removing libtool archive files...";
	echo	"${C_DGRAY}(they are harmful for cross-compilation)${C_RESET}";
	rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la

	cd -;
}

ValidateLibstdcpp()
{
	if ! cd "${PDIR}${gcc[package]}/build" 2> /dev/null; then
		return ;
	fi

	if command -v g++ >/dev/null && \
		make check &> /dev/null &&
	then
		libstdcpp[status]=true
	else
		libstdcpp[status]=false
	fi;

	cd -;
}

# =====================================||===================================== #
#																			   #
#									Main Loop								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

if [ $CLEARING = true ]; then
	clear;
fi

EchoInfo	"Validating packages...";
ValidatePackages;

while true ; do
	width=$(tput cols);
	if [ $CLEARING = true ]; then
		clear;
	fi
	
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE}Cross-Toolchain${C_RESET}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo -n	"1 ";	PrintPackage	binutils;
	echo -n	"2 ";	PrintPackage	gcc;
	echo -n	"3 ";	PrintPackage	LinuxApiHeader;
	echo -n	"4 ";	PrintPackage	glibc;
	echo -n	"5 ";	PrintPackage	libstdcpp;
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo -n	"gcc sanity check:";	ToolchainTest1;
	# echo -n	"g++ sanity check:";	ValidateLibstdcpp;
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"#)\tInstall package"
	echo	"i)\tInstall all packages"
	echo	"f)\tForce install all packages"
	echo	"v)\tValidate all packages"
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	local PRESSTOCONTINUE=true;
	case $input in
		1)	InstallPackageBinutils;;
		2)	InstallGccPass1;;
		3)	ExtractApiHeaders;;
		4)	InstallGlibc;;
		5)	InstallLibstdcpp;;
		i|I)	InstallPackages;;
		f|F)	InstallPackages "true";;
		v|V)	ValidatePackages;;
		q|Q)	exit 0;;
		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";
			PRESSTOCONTINUE=false;;
	esac

	$PRESSTOCONTINUE || PressAnyKeyToContinue;
done
