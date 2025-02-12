#! /bin/zsh

source Utils.sh

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

# # =====================================||===================================== #
# #																			   #
# #							   Install Packages								   #
# #																			   #
# # ===============ft_linux==============||==============©Othello=============== #

# declare -A binutils;
# binutils[package]="binutils-2.43.1";
# binutils[status]="";
# binutils[SBU]="1";
# binutils[time]="0";

# declare -A gcc
# gcc[package]="gcc-14.2.0";
# gcc[status]="";
# gcc[SBU]="3.2";
# gcc[time]="0";

# declare -A LinuxApiHeader
# LinuxApiHeader[package]="linux-6.10.5";
# LinuxApiHeader[status]="";
# LinuxApiHeader[SBU]="<0.1";
# LinuxApiHeader[time]="0";

# declare -A glibc
# glibc[package]="glibc-2.40";
# glibc[status]="";
# glibc[SBU]="1.3";
# glibc[time]="0";

# declare -A libstdcpp
# libstdcpp[package]="${gcc[package]}";
# libstdcpp[status]="";
# libstdcpp[SBU]="0.2";
# libstdcpp[time]="0";

# MenuCrossToolchain()
# {
# 	# PDIR="$LFS/sources/lfs-packages12.2/";

# 	printf '%*s\n' "$width" '' | tr ' ' '-';
# 	echo	"${C_ORANGE}Cross-Toolchain${C_RESET}";
# 	printf '%*s\n' "$width" '' | tr ' ' '-';
# 	echo -n	"1 ";	PrintPackage	binutils;
# 	echo -n	"2 ";	PrintPackage	gcc;
# 	echo -n	"3 ";	PrintPackage	LinuxApiHeader;
# 	echo -n	"4 ";	PrintPackage	glibc;
# 	echo -n	"5 ";	PrintPackage	libstdcpp;
# 	printf '%*s\n' "$width" '' | tr ' ' '-';
# 	echo -n	"gcc sanity check:";	ToolchainTest1;
# 	# echo -n	"g++ sanity check:";	ValidateLibstdcpp;
# 	printf '%*s\n' "$width" '' | tr ' ' '-';
# 	echo	"#)\tInstall package"
# 	echo	"i)\tInstall all packages"
# 	echo	"f)\tForce install all packages"
# 	echo	"v)\tValidate all packages"
# 	echo	"q)\tReturn to main menu";
# 	printf '%*s\n' "$width" '' | tr ' ' '-';

# 	GetInput;

# 	case $input in
# 		1)	InstallPackageBinutils;
# 			PressAnyKeyToContinue;;
# 		2)	InstallGccPass1;
# 			PressAnyKeyToContinue;;
# 		3)	ExtractApiHeaders;
# 			PressAnyKeyToContinue;;
# 		4)	InstallGlibc;
# 			PressAnyKeyToContinue;;
# 		5)	InstallLibstdcpp;
# 			PressAnyKeyToContinue;;
# 		i|I)	InstallPackages;
# 				PressAnyKeyToContinue;;
# 		f|F)	InstallPackages "true";
# 				PressAnyKeyToContinue;;
# 		v|V)	ValidatePackages;
# 				PressAnyKeyToContinue;;
# 		q|Q)	MENU=0;;
# 		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";;
# 	esac
# }

# PrintPackage()
# {
# 	local STATUS="$(eval echo "\${${1}[status]}")";
# 	local time=$(eval echo "\${${1}[time]}")
# 	local TimeStamp=$(printf "%02d:%02d:%02d"	"$(($time/3600))"	"$((($time % 3600) / 60))"	"$(($time % 60))");

# 	if [ "$STATUS" = true ]; then
# 		printf	"${C_GREEN}%-23s${C_RESET} %-4s SBU %9s\n"	$(eval echo "\${${1}[package]}")	$(eval echo "\${${1}[SBU]}")	"$TimeStamp";
# 	elif [ "$STATUS" = false ]; then
# 		printf	"${C_RED}%-23s${C_RESET} %-4s SBU %9s\n"	$(eval echo "\${${1}[package]}")	$(eval echo "\${${1}[SBU]}")	"$TimeStamp";
# 	else
# 		printf	"${C_GRAY}%-23s${C_RESET} %-4s SBU %9s\n"	$(eval echo "\${${1}[package]}")	$(eval echo "\${${1}[SBU]}")	"$TimeStamp";
# 	fi
# }

# InstallPackages()
# {
# 	# PDIR="$LFS/sources/lfs-packages12.2/";
# 	# cd "$PDIR";

# 	if [ "$1" = true ]; then
# 		EchoInfo	"binutils...";
# 		InstallBinutils;
# 		EchoInfo	"gcc...";
# 		InstallGccPass1;
# 		EchoInfo	"Linux API Headers...";
# 		ExtractApiHeaders;
# 		EchoInfo	"glibc...";
# 		InstallGlibc;
# 		EchoInfo	"libstdc++...";
# 		InstallLibstdcpp;
# 	else
# 		# binutils
# 		if [ "$binutils[status]" != true ]; then
# 			EchoInfo	"binutils...";
# 			InstallBinutils;
# 		fi
# 		# gcc
# 		if [ "$binutils[status]" = true ]; then
# 			if [ "$gcc[status]" != true ]; then
# 				EchoInfo	"gcc...";
# 				InstallGccPass1;
# 			fi
# 		else
# 			MSG="${C_RED}Error${C_RESET}: Missing ${C_ORANGE}binutils${C_RESET} which is required before ${C_ORANGE}gcc${C_RESET}";
# 			return ;
# 		fi
# 		# Linux API headers
# 		if [ "$gcc[status]" = true ]; then
# 			if [ "$LinuxApiHeader[status]" != true ]; then
# 				EchoInfo	"Linux API Headers...";
# 				ExtractApiHeaders;
# 			fi
# 		else
# 			MSG="${C_RED}Error${C_RESET}: Missing ${C_ORANGE}gcc${C_RESET} which is required before ${C_ORANGE}Linux API Headers${C_RESET}";
# 			return ;
# 		fi
# 		# glibc
# 		if [ "$LinuxApiHeader[status]" = true ]; then
# 			if [ "$glibc[status]" != true ]; then
# 				EchoInfo	"glibc...";
# 				InstallGlibc;
# 			fi
# 		else
# 			MSG="${C_RED}Error${C_RESET}: Missing ${C_ORANGE}gcc${C_RESET} which is required before ${C_ORANGE}glibc${C_RESET}";
# 			return ;
# 		fi
# 		# LibstdC++
# 		if [ "$glibc[status]" = true ]; then
# 			if [ "$libstdcpp[status]" != true ]; then
# 				EchoInfo	"libstdc++...";
# 				InstallLibstdcpp;
# 			fi
# 		else
# 			MSG="${C_RED}Error${C_RESET}: Missing ${C_ORANGE}glibc${C_RESET} which is required before ${C_ORANGE}libstdc++${C_RESET}";
# 			return ;
# 		fi
# 	fi

# 	# cd ~;	
# }

# ExtractPackage()
# {
# 	SRC="$1";
# 	DST="$2";

# 	if [[ -z "$SRC" || ! -f "$SRC"  || -z "$DST" ]]; then
# 		EchoError	"No $SRC or $DST";
# 		return 1;
# 	fi

# 	for FILENAME in $(tar -tf "$SRC"); do
# 		if [ ! -e ${DST}/${FILENAME} ]; then
# 			EchoInfo	"Unpacking $SRC($FILENAME)...";
# 			mkdir -p "$DST";
# 			tar -xf "$SRC" -C "$DST";
# 			return $?;
# 		fi
# 	done
# 	return 0;
# }

# ValidatePackages()
# {
# 	# ConfigureBinutils;
# 	ValidateBinutils;

# 	# ConfigureGccPass1;
# 	ValidateGccPass1;

# 	ValidateAPIHeaders;

# 	ValidateGlibc;

# 	# ConfigureLibstdcpp;
# 	ValidateLibstdcpp;
# }

# # ValidatePackageWithMakefile()
# # {
# # 	local LOCATION="$1";
# # 	if [ -z "$2" ]; then
# # 		local TARGET=check;
# # 	else
# # 		local TARGET="$2";
# # 	fi
# # 	local STATUS=false;

# # 	if [ -d "$LOCATION" ]; then
# # 		cd "$LOCATION";
# # 		if [ -f Makefile ]; then
# # 			if make -n $TARGET 1> /dev/null 2>&1; then
# # 				if make $TARGET 1> /dev/null 2>&1; then
# # 					local STATUS=true;
# # 				else
# # 				fi
# # 			else
# # 				EchoError	"Makefile does not contain target ${C_ORANGE}check${C_RESET}..."
# # 			fi
# # 		else
# # 			EchoError	"Makefile not found..."
# # 		fi
# # 		cd -;
# # 	else
# # 		EchoError	"Directory ${C_ORANGE}$LOCATION${C_RESET} not found..."
# # 	fi

# # 	if [ $STATUS = true ]; then
# # 		return 0;
# # 	else
# # 		return 1;
# # 	fi
# # }

# # =====================================||===================================== #
# #									Binutils								   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallBinutils()
# {
# 	ExtractPackage	"${PDIR}${binutils[package]}.tar.xz"	"${PDIR}";

# 	if [ $? -ne 0 ]; then
# 		EchoError	"Failed to unpack binutils";
# 		return ;
# 	fi

# 	if ! mkdir -pv "${PDIR}${binutils[package]}/build"; then
# 		EchoError	"Failed to make build directory.";
# 		return ;
# 	fi

# 	binutils[time]=$(date +%s);

# 	ConfigureBinutils;
# 	InstallPackageBinutils;

# 	binutils[time]=$(( $(date +%s) - $binutils[time] ));

# 	ValidateBinutils;
# }

# ConfigureBinutils()
# {
# 	local PBDIR="${PDIR}${binutils[package]}/build";

# 	if ! cd "${PDIR}${binutils[package]}/build" 2> /dev/null; then
# 		return ;
# 	fi

# 	if [ ! -f "${PBDIR}/Makefile" ] || [ ! -f "${PBDIR}/config.status" ] || [ ! -f "${PBDIR}/config.log" ]; then
# 		EchoInfo	"Configuring ${binutils[package]}...";
# 		time ../configure	--prefix=$LFS/tools	\
# 							--with-sysroot=$LFS	\
# 							--target=$LFS_TGT	\
# 							--disable-nls		\
# 							--enable-gprofng=no	\
# 							--disable-werror	\
# 							--enable-new-dtags	\
# 							--enable-default-hash-style=gnu	\
# 							1> /dev/null;
# 	fi

# 	cd -;
# }

# InstallPackageBinutils()
# {
# 	if ! cd "${PDIR}${binutils[package]}/build" 2> /dev/null; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling ${binutils[package]}";
# 	echo	"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;
# 	EchoInfo	"Installing ${binutils[package]}...${C_RESET}";
# 	echo	"${C_DGRAY}> make install 1> /dev/null${C_RESET}";
# 	time make install 1> /dev/null;

# 	cd -;
# }

# ValidateBinutils()
# {
# 	if ! cd "${PDIR}${binutils[package]}/build" 2> /dev/null; then
# 		return ;
# 	fi

# 	if make check &>/dev/null && \
# 		command -v as > /dev/null && \
# 		command -v ld > /dev/null; then
# 		binutils[status]=true;
# 	else
# 		binutils[status]=false;
# 	fi

# 	cd -;
# }

# # =====================================||===================================== #
# #									   gcc									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallGccPass1()
# {
# 	if ! ExtracPackagesGccPass1; then
# 		return ;
# 	fi

# 	# On x86_64 hosts, set the default directory name for 64-bit libraries to “lib”
# 	case $(uname -m) in
# 		x86_64) sed -e '/m64=/s/lib64/lib/' -i.orig "${PDIR}${gcc[package]}/gcc/config/i386/t-linux64";;
# 	esac

# 	if ! mkdir -pv "${PDIR}${gcc[package]}/build"; then
# 		EchoError	"Failed to make build directory.";
# 		return ;
# 	fi

# 	gcc[time]=$(date +%s);
# 	ConfigureGccPass1;
# 	InstallPackageGccPass1;
# 	gcc[time]=$(( $(date +%s) - $gcc[time] ));

# 	ValidateGccPass1;

# 	# echo	"${C_ORANGE}Copying header files...${C_RESET}"
# 	# cat ${PDIR}${gcc[package]}/gcc/limitx.h \
# 	# 	${PDIR}${gcc[package]}/gcc/glimits.h \
# 	# 	${PDIR}${gcc[package]}/gcc/limity.h \
# 	# 	> `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h
# }

# ExtracPackagesGccPass1()
# {
# 	ExtractPackage	"${PDIR}${gcc[package]}.tar.xz"	"${PDIR}";

# 	# PACKNAME="mpfr-4.2.1";
# 	ExtractPackage	"${PDIR}mpfr-4.2.1.tar.xz"	"${PDIR}";
# 	mv -fv "${PDIR}mpfr-4.2.1" "${PDIR}${gcc[package]}/mpfr";

# 	# PACKNAME="gmp-6.3.0";
# 	ExtractPackage	"${PDIR}gmp-6.3.0.tar.xz"	"${PDIR}";
# 	mv -fv "${PDIR}gmp-6.3.0" "${PDIR}${gcc[package]}/gmp";

# 	# PACKNAME="mpc-1.3.1.tar.gz";
# 	ExtractPackage	"${PDIR}mpc-1.3.1.tar.gz"	"${PDIR}";
# 	mv -fv "${PDIR}mpc-1.3.1" "${PDIR}${gcc[package]}/mpc";

# 	if	[ ! -d "${PDIR}${gcc[package]}" ] ||
# 		[ ! -d "${PDIR}${gcc[package]}/mpfr" ] ||
# 		[ ! -d "${PDIR}${gcc[package]}/gmp" ] ||
# 		[ ! -d "${PDIR}${gcc[package]}/mpc" ]; then
# 		EchoError	"Failed to unpack a package for gcc{mpfr, gmp, mpc}...";
# 		return false;
# 	fi
# 	return true;
# }

# ConfigureGccPass1()
# {
# 	local PBDIR="${PDIR}${gcc[package]}/build";

# 	if ! cd "${PDIR}${gcc[package]}/build" 2> /dev/null; then
# 		return ;
# 	fi

# 	# if [ ! -f "${PBDIR}/Makefile" ] || [ ! -f "${PBDIR}/config.status" ] || [ ! -f "${PBDIR}/config.log" ]; then
# 		EchoInfo	"Configuring...";
# 		time ../configure	--target=$LFS_TGT	\
# 							--prefix=$LFS/tools	\
# 							--with-glibc-version=2.40 \
# 							--with-sysroot=$LFS	\
# 							--with-newlib	\
# 							--without-headers	\
# 							--enable-default-pie	\
# 							--enable-default-ssp	\
# 							--disable-nls	\
# 							--disable-shared	\
# 							--disable-multilib	\
# 							--disable-threads	\
# 							--disable-libatomic	\
# 							--disable-libgomp	\
# 							--disable-libquadmath	\
# 							--disable-libssp	\
# 							--disable-libvtv	\
# 							--disable-libstdcxx	\
# 							-enable-languages=c,c++	\
# 							1> /dev/null;
# 	# fi

# 	cd -;
# }

# InstallPackageGccPass1()
# {
# 	if ! cd "${PDIR}${gcc[package]}/build" 2> /dev/null; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling ${gcc[package]}...";
# 	echo	"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;
# 	EchoInfo	"Installing ${gcc[package]}...";
# 	echo	"${C_DGRAY}> make install 1> /dev/null${C_RESET}";
# 	time make install 1> /dev/null;

# 	cd -;
# }

# ValidateGccPass1()
# {
# 	if ! cd "${PDIR}${gcc[package]}/build" 2> /dev/null; then
# 		return ;
# 	fi

# 	if command -v gcc >/dev/null && \
# 		make check-gcc &> /dev/null &&
# 	then
# 		gcc[status]=true;
# 	else
# 		if make check &> /dev/null; then
# 			gcc[status]=true;
# 		else
# 			gcc[status]=false;
# 		fi
# 	fi;

# 	cd -;
# }

# # =====================================||===================================== #
# #								Linux API Headers							   #
# # ===============ft_linux==============||==============©Othello=============== #

# ExtractApiHeaders()
# {
# 	# PACKNAME="linux-6.10.5";
# 	ExtractPackage	"${PDIR}${LinuxApiHeader[package]}.tar.xz"	"${PDIR}";

# 	LinuxApiHeader[time]=$(date +%s);

# 	MakeAndMoveApiHeaders;

# 	LinuxApiHeader[time]=$(( $(date +%s) - $LinuxApiHeader[time] ));

# 	ValidateAPIHeaders;

# }

# MakeAndMoveApiHeaders()
# {
# 	if ! cd "${PDIR}${LinuxApiHeader[package]}" 2> /dev/null; then
# 		return ;
# 	fi

# 	EchoInfo	"Cleaning stale files...";
# 	echo	"${C_DGRAY}> make mrproper 1> /dev/null${C_RESET}";
# 	time make mrproper 1> /dev/null;

# 	EchoInfo	"Extracting user-visible kernel headers from source...";
# 	echo	"${C_DGRAY}> make headers 1> /dev/null${C_RESET}";
# 	time make headers 1> /dev/null;

# 	EchoInfo	"Copying headers to $LFS/usr/include...";
# 	echo	"${C_DGRAY}> cp -rv usr/include \$LFS/usr 1> /dev/null${C_RESET}";
# 	find usr/include -type f ! -name '*.h' -delete
# 	cp -rv usr/include $LFS/usr 1> /dev/null

# 	cd -;

# }

# ValidateAPIHeaders()
# {
# 	local INCLUDE_DIR="$LFS/usr/include";
# 	if [ ! -d "$INCLUDE_DIR" ]; then
# 		LinuxApiHeader[status]=false;
# 		return 1;
# 	fi

# 	declare -A HeaderDirectoryList;
# 	HeaderDirectoryList[asm]=65;
# 	HeaderDirectoryList[asm-generic]=37;
# 	HeaderDirectoryList[drm]=28;
# 	HeaderDirectoryList[linux]=781;
# 	HeaderDirectoryList[misc]=7;
# 	HeaderDirectoryList[mtd]=5;
# 	HeaderDirectoryList[rdma]=29;
# 	HeaderDirectoryList[regulator]=1;
# 	HeaderDirectoryList[scsi]=10;
# 	HeaderDirectoryList[sound]=23;
# 	HeaderDirectoryList[video]=3;
# 	HeaderDirectoryList[xen]=4;

# 	for DIRECTORY in ${(k)HeaderDirectoryList}; do
# 		if [ ! -d "$INCLUDE_DIR/$DIRECTORY" ]; then
# 			MSG="${C_RED}Error${C_RESET}(${C_ORANGE}Linux API Header${C_RESET}): Missing directory ${C_ORANGE}$INCLUDE_DIR/$DIRECTORY${C_RESET}"
# 			LinuxApiHeader[status]=false;
# 			return 2;
# 		elif [ ${HeaderDirectoryList[$DIRECTORY]} -gt $(find $INCLUDE_DIR/$DIRECTORY -type f -name '*.h' | wc -l) ]; then
# 			MSG="${C_RED}Error${C_RESET}(${C_ORANGE}Linux API Header${C_RESET}): Missing headers in directory ${C_ORANGE}$INCLUDE_DIR/$DIRECTORY${C_RESET}"
# 			LinuxApiHeader[status]=false;
# 			return 3;
# 		fi
# 	done
# 	LinuxApiHeader[status]=true;
# 	return 0;
# }

# # =====================================||===================================== #
# #									  Glibc									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallGlibc()
# {
# 	# PACKNAME="glibc-2.40";
# 	ExtractPackage	"${PDIR}${glibc[package]}.tar.xz"	"${PDIR}";

# 	if [ $? -ne 0 ]; then
# 		EchoError	"Failed to unpack glibc";
# 		return ;
# 	fi

# 	if ! mkdir -pv "${PDIR}${glibc[package]}/build"; then
# 		EchoError	"Failed to make build directory.";
# 		return ;
# 	fi

# 	glibc[time]=$(date +%s);

# 	PrepareGlibc;
# 	ConfigureGlibc;
# 	InstallPackageGlibc;

# 	glibc[time]=$(( $(date +%s) - $glibc[time] ));

# 	ValidateGlibc;

# 	cd -;
# }

# PrepareGlibc()
# {
# 	if ! cd "${PDIR}${glibc[package]}" 2> /dev/null; then
# 		return ;
# 	fi

# 	# For x86_64, create a compatibility symbolic link required for proper operation of the dynamic library loader
# 	case $(uname -m) in
# 		i?86)	ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3;;
# 		x86_64)	ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64;
# 				ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3;;
# 	esac

# 	# Patch to make programs store their runtime data in the FHS-compliant locations.
# 	patch -Np1 -i ../glibc-2.40-fhs-1.patch;

# 	cd -;

# }

# ConfigureGlibc()
# {
# 	if ! cd "${PDIR}${glibc[package]}/build" 2> /dev/null; then
# 		return ;
# 	fi

# 	if [ ! -f "${PBDIR}/Makefile" ]; then
# 		EchoInfo	"Configuring ${glibc[package]}...";
# 		echo "rootsbindir=/usr/sbin" > configparms
# 		time ../configure	--prefix=/usr	\
# 							--host=$LFS_TGT	\
# 							--build=$(../scripts/config.guess)	\
# 							--enable-kernel=4.19	\
# 							--with-headers=$LFS/usr/include	\
# 							--disable-nscd	\
# 							libc_cv_slibdir=/usr/lib	\
# 							1> /dev/null
# 	fi

# 	cd -;
# }

# InstallPackageGlibc()
# {
# 	if ! cd "${PDIR}${glibc[package]}/build" 2> /dev/null; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling ${glibc[package]}...";
# 	echo	"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;
# 	if [ "$(whoami)" != "root" ] && [ -n "$LFS" ]; then
# 		EchoInfo	"Installing ${glibc[package]}...";
# 		echo	"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
# 		time make DESTDIR=$LFS install 1> /dev/null
# 	else
# 		EchoError "Almost made build unstable with glibc!";
# 		return 1;
# 	fi

# 	EchoInfo	"Fixing hardcoded path...";
# 	sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

# 	cd -;
# }

# ValidateGlibc()
# {
# 	if ToolchainTest1 > /dev/null; then
# 		glibc[status]=true;
# 		return 0;
# 	else
# 		glibc[status]=false;
# 		return 1;
# 	fi
# }

# ToolchainTest1()
# {
# 	echo 'int main(){}' | $LFS_TGT-gcc -xc - -o gcctest.out
# 	if [ -f "gcctest.out" ]; then
# 		readelf -l gcctest.out | grep ld-linux
# 		if [ $? -eq 0 ]; then
# 			glibc[status]=true;
# 		else
# 			glibc[status]=false;
# 		fi

# 		rm gcctest.out
# 	else
# 		glibc[status]=false;
# 	fi
# }

# # =====================================||===================================== #
# #									libstdcpp								   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallLibstdcpp()
# {
# 	PACKNAME="libstdc++";

# 	EchoInfo	"Double checking Toolchain ...";
# 	ToolchainTest1	1> /dev/null;
# 	if [ "$glibc[status]" != true ]; then
# 		MSG="${C_RED}Error${C_RESET}: Toolchain test failed. Aborting $PACKNAME...${C_RESET}"
# 		return ;
# 	fi
	
# 	libstdcpp[time]=$(date +%s);

# 	ConfigureLibstdcpp;
# 	InstallPackageLibstdcpp;

# 	libstdcpp[time]=$(( $(date +%s) - $libstdcpp[time] ));

# 	ValidateLibstdcpp;

# 	cd -
# }

# ConfigureLibstdcpp()
# {
# 	if ! cd "${PDIR}${libstdcpp[package]}/build" 2> /dev/null; then
# 		return ;
# 	fi
	
# 	EchoInfo	"Configuring ${PACKNAME}...";
# 	../libstdc++-v3/configure	--host=$LFS_TGT	\
# 								--build=$(../config.guess)	\
# 								--prefix=/usr	\
# 								--disable-multilib	\
# 								--disable-nls	\
# 								--disable-libstdcxx-pch	\
# 								--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/14.2.0	\
# 								1> /dev/null

# 	cd -;
# }

# InstallPackageLibstdcpp()
# {
# 	if ! cd "${PDIR}${libstdcpp[package]}/build" 2> /dev/null; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling ${libstdcpp[package]}...";
# 	echo	"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	make 1> /dev/null

# 	EchoInfo	"Installing ${PACKNAME} library...";
# 	echo	"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
# 	make DESTDIR=$LFS install 1> /dev/null

# 	EchoInfo	"Removing libtool archive files...";
# 	echo	"${C_DGRAY}(they are harmful for cross-compilation)${C_RESET}";
# 	rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la

# 	cd -;
# }

# ValidateLibstdcpp()
# {
# 	if ! cd "${PDIR}${gcc[package]}/build" 2> /dev/null; then
# 		return ;
# 	fi

# 	if command -v g++ >/dev/null && \
# 		make check &> /dev/null &&
# 	then
# 		libstdcpp[status]=true
# 	else
# 		libstdcpp[status]=false
# 	fi;

# 	cd -;
# 	# echo '#include <cstdlib>
# 	# int main(){}' | $LFS_TGT-g++ -xc - -o gpptest.out

# 	# if [ -f "gpptest.out" ]; then
# 	# 	readelf -l gpptest.out | grep ld-linux
# 	# 	if [ $? -eq 0 ]; then
# 	# 		libstdcpp[status]=true;
# 	# 	else
# 	# 		libstdcpp[status]=false;
# 	# 	fi
# 	# 	rm gpptest.out;
# 	# else
# 	# 	libstdcpp[status]=false;
# 	# fi
# 	# echo	"${C_RED}Note${C_RESET}: Not testing propperly..."
# }

# # =====================================||===================================== #
# #																			   #
# #					Chapter 6. Cross Compiling Temporary Tools				   #
# #																			   #
# # ===============ft_linux==============||==============©Othello=============== #

# MenuTemporaryTools()
# {
# 	printf '%*s\n' "$width" '' | tr ' ' '-';
# 	echo	"${C_ORANGE}Temporary Tools${C_RESET}";
# 	printf '%*s\n' "$width" '' | tr ' ' '-';
# 	echo	"i)\tInstall temporary tools"
# 	echo	"v)\tValidate temporary tools"
# 	echo	"q)\tReturn to main menu";
# 	printf '%*s\n' "$width" '' | tr ' ' '-';

# 	GetInput;

# 	# PDIR="$LFS/sources/lfs-packages12.2/";

# 	case $input in
# 		i|I)	InstallM4;
# 				InstallNcurses;
# 				InstallBash;
# 				InstallCoreutils;
# 				InstallDiffutils;
# 				InstallFile;
# 				InstallFindutils;
# 				InstallGawk;
# 				InstallGrep;
# 				InstallGzip;
# 				InstallMake;
# 				InstallPatch;
# 				InstallSed;
# 				InstallTar;
# 				InstallXz;
# 				PressAnyKeyToContinue;;
# 		v|V)	ValidateM4;
# 				ValidateNcurses;
# 				ValidateBash;
# 				ValidateCoreutils;
# 				ValidateDiffutils;
# 				ValidateFile;
# 				ValidateFindutils;
# 				ValidateGawk;
# 				ValidateGrep;
# 				ValidateGzip;
# 				ValidateMake;
# 				ValidatePatch;
# 				ValidateSed;
# 				ValidateTar;
# 				ValidateXz;
# 				PressAnyKeyToContinue;;
# 		q|Q)	MENU=0;;
# 		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";;
# 	esac
# }

# RunMakeCheckTest()
# {
# 	if make -n check &> /dev/null; then
# 		if make check &> /dev/null; then
# 			EchoTest	OK	"$1";
# 		else
# 			EchoTest	KO	"$1";
# 		fi
# 	else
# 		EchoTest	"$1 make -n check failed";
# 	fi
# }

# # =====================================||===================================== #
# #									  Temp									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallTemp()
# {
# 	PACKAGE="";

# 	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

# 	if ! mkdir -pv "${PDIR}${PACKAGE}/build"; then
# 		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
# 		return ;
# 	fi

# 	ConfigureTemp;
# 	InstallPackageTemp;

# 	# EchoInfo	"Testing $PACKAGE";
# 	# ValidateTemp;
# }

# ConfigureTemp()
# {
# 	if ! cd "${PDIR}${PACKAGE}/build"; then
# 		return ;
# 	fi

# 	EchoInfo	"Configuring $PACKAGE...";



# 	cd -;
# }

# InstallPackageTemp()
# {
# 	if ! cd "${PDIR}${PACKAGE}/build"; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling $PACKAGE...";
# 	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;

# 	EchoInfo	"Installing $PACKAGE...";
# 	echo		"${C_DGRAY}> make install 1> /dev/null${C_RESET}";
# 	time make install 1> /dev/null;

# 	cd -;
# }

# ValidateTemp()
# {
# 	PACKAGE="";
# 	if ! cd "${PDIR}${PACKAGE}/build"; then
# 		return ;
# 	fi

# 	RunMakeCheckTest	"$PACKAGE";

# 	cd -;
# }

# # =====================================||===================================== #
# #									  M4									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallM4()
# {
# 	PACKAGE="m4-1.4.19";

# 	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

# 	ConfigureM4;
# 	InstallPackageM4;

# 	# EchoInfo	"Testing $PACKAGE";
# 	# ValidateM4;

# 	cd -;
# }

# ConfigureM4()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Configuring $PACKAGE...";
# 	./configure	--prefix=/usr	\
# 				--host=$LFS_TGT	\
# 				--build=$(build-aux/config.guess)	\
# 				1> /dev/null

# 	cd -;
# }

# InstallPackageM4()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling $PACKAGE...";
# 	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;
# 	EchoInfo	"Installing $PACKAGE...";
# 	echo		"${C_DGRAY}> DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
# 	time make DESTDIR=$LFS install 1> /dev/null;

# 	cd -;
# }

# ValidateM4()
# {
# 	PACKAGE="m4-1.4.19";
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	RunMakeCheckTest	"$PACKAGE";

# 	cd -;
# }

# # =====================================||===================================== #
# #									  Ncurses									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallNcurses()
# {
# 	PACKAGE="ncurses-6.5";

# 	ExtractPackage	"${PDIR}${PACKAGE}.tar.gz"	"${PDIR}";

# 	if ! mkdir -pv "${PDIR}${PACKAGE}/build"; then
# 		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
# 		return ;
# 	fi

# 	ConfigureNcurses;
# 	InstallPackageNcurses;

# 	# EchoInfo	"Testing $PACKAGE";
# 	# ValidateNcurses;
# }

# ConfigureNcurses()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	sed -i s/mawk// configure;

# 	if [ ! -d "${PDIR}${PACKAGE}/build"] ; then
# 		return ;
# 	fi

# 	EchoInfo	"Configuring $PACKAGE...";
# 	pushd build
# 		../configure	1> /dev/null
# 		make -C include	1> /dev/null
# 		make -C progs tic	1> /dev/null
# 	popd

# 	./configure	--prefix=/usr	\
# 				--host=$LFS_TGT	\
# 				--build=$(./config.guess)	\
# 				--mandir=/usr/share/man	\
# 				--with-manpage-format=normal \
# 				--with-shared	\
# 				--without-normal	\
# 				--with-cxx-shared	\
# 				--without-debug	\
# 				--without-ada	\
# 				--disable-stripping	\
# 				1> /dev/null

# 	cd -;
# }

# InstallPackageNcurses()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling $PACKAGE...";
# 	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;

# 	EchoInfo	"Installing $PACKAGE...";
# 	echo		"${C_DGRAY}> make DESTDIR=\$LFS TIC_PATH=\$(pwd)/build/progs/tic install 1> /dev/null${C_RESET}";
# 	time make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install 1> /dev/null;

# 	EchoInfo	"Configuring libncurses library...";
# 	# symlink to use libncursesw.so
# 	ln -sv libncursesw.so $LFS/usr/lib/libncurses.so;
# 	# Edit the header file so it will always use the wide-character data structure definition compatible with libncursesw.so.
# 	sed -e 's/^#if.*XOPEN.*$/#if 1/' \
# 		-i $LFS/usr/include/curses.h;

# 	cd -;
# }

# ValidateNcurses()
# {
# 	PACKAGE="ncurses-6.5";
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	RunMakeCheckTest	"$PACKAGE";

# 	cd -;
# }

# # =====================================||===================================== #
# #									  Bash									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallBash()
# {
# 	PACKAGE="bash-5.2.32";

# 	ExtractPackage	"${PDIR}${PACKAGE}.tar.gz"	"${PDIR}";

# 	ConfigureBash;
# 	InstallPackageBash;

# 	# EchoInfo	"Testing $PACKAGE";
# 	# ValidateBash;
# }

# ConfigureBash()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Configuring $PACKAGE...";

# 	./configure	--prefix=/usr	\
# 				--build=$(sh support/config.guess) \
# 				--host=$LFS_TGT	\
# 				--without-bash-malloc	\
# 				bash_cv_strtold_broken=no	\
# 				1>/dev/null
# 	cd -;
# }

# InstallPackageBash()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling $PACKAGE...";
# 	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;

# 	EchoInfo	"Installing $PACKAGE...";
# 	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
# 	time make DESTDIR=$LFS install 1> /dev/null;

# 	# Link for the programs that use sh for a shell
# 	ln -sv bash $LFS/bin/sh

# 	cd -;
# }

# ValidateBash()
# {
# 	PACKAGE="bash-5.2.32";
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	RunMakeCheckTest	"$PACKAGE";

# 	cd -;
# }

# # =====================================||===================================== #
# #									  Coreutils									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallCoreutils()
# {
# 	PACKAGE="coreutils-9.5";

# 	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

# 	ConfigureCoreutils;
# 	InstallPackageCoreutils;

# 	# EchoInfo	"Testing $PACKAGE";
# 	# ValidateCoreutils;
# }

# ConfigureCoreutils()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Configuring $PACKAGE...";
# 	./configure	--prefix=/usr	\
# 				--host=$LFS_TGT	\
# 				--build=$(build-aux/config.guess)	\
# 				--enable-install-program=hostname	\
# 				--enable-no-install-program=kill,uptime	\
# 				1> /dev/null;

# 	cd -;
# }

# InstallPackageCoreutils()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling $PACKAGE...";
# 	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;

# 	EchoInfo	"Installing $PACKAGE...";
# 	echo		"${C_DGRAY}> make DESTDIR=$LFS install 1> /dev/null${C_RESET}";
# 	time make DESTDIR=$LFS install 1> /dev/null;

# 	# Move programs to their final expected locations
# 	mv -v $LFS/usr/bin/chroot
# 	$LFS/usr/sbin
# 	mkdir -pv $LFS/usr/share/man/man8
# 	mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
# 	sed -i 's/"1"/"8"/'
# 	$LFS/usr/share/man/man8/chroot.8

# 	cd -;
# }

# ValidateCoreutils()
# {
# 	PACKAGE="coreutils-9.5";
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	RunMakeCheckTest	"$PACKAGE";

# 	cd -;
# }

# # =====================================||===================================== #
# #									  Diffutils									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallDiffutils()
# {
# 	PACKAGE="diffutils-3.10";

# 	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

# 	ConfigureDiffutils;
# 	InstallPackageDiffutils;

# 	# EchoInfo	"Testing $PACKAGE";
# 	# ValidateDiffutils;
# }

# ConfigureDiffutils()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Configuring $PACKAGE...";
# 	./configure	--prefix=/usr	\
# 				--host=$LFS_TGT	\
# 				--build=$(./build-aux/config.guess)	\
# 				1> /dev/null

# 	cd -;
# }

# InstallPackageDiffutils()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling $PACKAGE...";
# 	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;

# 	EchoInfo	"Installing $PACKAGE...";
# 	echo		"${C_DGRAY}> make DESTDIR=$LFS install 1> /dev/null${C_RESET}";
# 	time make DESTDIR=$LFS install 1> /dev/null;

# 	cd -;
# }

# ValidateDiffutils()
# {
# 	PACKAGE="diffutils-3.10";
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	RunMakeCheckTest	"$PACKAGE";

# 	cd -;
# }

# # =====================================||===================================== #
# #									  File									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallFile()
# {
# 	PACKAGE="file-5.45";

# 	ExtractPackage	"${PDIR}${PACKAGE}.tar.gz"	"${PDIR}";

# 	if ! mkdir -pv "${PDIR}${PACKAGE}/build"; then
# 		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
# 		return ;
# 	fi

# 	ConfigureFile;
# 	InstallPackageFile;

# 	# EchoInfo	"Testing $PACKAGE";
# 	# ValidateFile;
# }

# ConfigureFile()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	if [ ! -d "${PDIR}${PACKAGE}/build" ]; then
# 		return ;
# 	fi
# 	EchoInfo	"Configuring $PACKAGE...";
# 	pushd build
# 		../configure	--disable-bzlib	\
# 						--disable-libseccomp \
# 						--disable-xzlib	\
# 						--disable-zlib	\
# 						1> /dev/null
# 		make	 1> /dev/null
# 	popd

# 	./configure	--prefix=/usr	\
# 				--host=$LFS_TGT	\
# 				--build=$(./config.guess)	\
# 				1> /dev/null

# 	cd -;
# }

# InstallPackageFile()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling $PACKAGE...";
# 	echo		"${C_DGRAY}> make FILE_COMPILE=\$(pwd)/build/src/file 1> /dev/null${C_RESET}";
# 	time make FILE_COMPILE=$(pwd)/build/src/file 1> /dev/null;

# 	EchoInfo	"Installing $PACKAGE...";
# 	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
# 	time make DESTDIR=$LFS install 1> /dev/null;

# 	# Remove the libtool archive file because it is harmful for cross compilation
# 	rm -v $LFS/usr/lib/libmagic.la

# 	cd -;
# }

# ValidateFile()
# {
# 	PACKAGE="file-5.45";
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	RunMakeCheckTest	"$PACKAGE";

# 	cd -;
# }


# # =====================================||===================================== #
# #									  Findutils									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallFindutils()
# {
# 	PACKAGE="findutils-4.10.0";

# 	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

# 	ConfigureFindutils;
# 	InstallPackageFindutils;

# 	# EchoInfo	"Testing $PACKAGE";
# 	# ValidateFindutils;
# }

# ConfigureFindutils()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Configuring $PACKAGE...";
# 	./configure	--prefix=/usr	\
# 				--localstatedir=/var/lib/locate	\
# 				--host=$LFS_TGT	\
# 				--build=$(build-aux/config.guess)	\
# 				1> /dev/null;

# 	cd -;
# }

# InstallPackageFindutils()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling $PACKAGE...";
# 	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;

# 	EchoInfo	"Installing $PACKAGE...";
# 	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
# 	time make DESTDIR=$LFS install 1> /dev/null;

# 	cd -;
# }

# ValidateFindutils()
# {
# 	PACKAGE="findutils-4.10.0";
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	RunMakeCheckTest	"$PACKAGE";

# 	cd -;
# }

# # =====================================||===================================== #
# #									  Gawk									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallGawk()
# {
# 	PACKAGE="gawk-5.3.0";

# 	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

# 	ConfigureGawk;
# 	InstallPackageGawk;

# 	# EchoInfo	"Testing $PACKAGE";
# 	# ValidateGawk;
# }

# ConfigureGawk()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	# Ensure some unneeded files are not installed
# 	sed -i 's/extras//' Makefile.in

# 	EchoInfo	"Configuring $PACKAGE...";
# 	./configure	--prefix=/usr	\
# 				--host=$LFS_TGT	\
# 				--build=$(build-aux/config.guess)	\
# 				1> /dev/null

# 	cd -;
# }

# InstallPackageGawk()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling $PACKAGE...";
# 	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;

# 	EchoInfo	"Installing $PACKAGE...";
# 	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
# 	time make DESTDIR=$LFS install 1> /dev/null;

# 	cd -;
# }

# ValidateGawk()
# {
# 	PACKAGE="gawk-5.3.0";
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	RunMakeCheckTest	"$PACKAGE";

# 	cd -;
# }

# # =====================================||===================================== #
# #									  Grep									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallGrep()
# {
# 	PACKAGE="grep-3.11";

# 	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

# 	if ! mkdir -pv "${PDIR}${PACKAGE}/build"; then
# 		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
# 		return ;
# 	fi

# 	ConfigureGrep;
# 	InstallPackageGrep;

# 	# EchoInfo	"Testing $PACKAGE";
# 	# ValidateGrep;
# }

# ConfigureGrep()
# {
# 	if ! cd "${PDIR}${PACKAGE}/build"; then
# 		return ;
# 	fi

# 	EchoInfo	"Configuring $PACKAGE...";
# 	./configure	--prefix=/usr	\
# 				--host=$LFS_TGT	\
# 				--build=$(./build-aux/config.guess)	\
# 				1> /dev/null

# 	cd -;
# }

# InstallPackageGrep()
# {
# 	if ! cd "${PDIR}${PACKAGE}/build"; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling $PACKAGE...";
# 	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;

# 	EchoInfo	"Installing $PACKAGE...";
# 	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
# 	time make DESTDIR=$LFS install 1> /dev/null;

# 	cd -;
# }

# ValidateGrep()
# {
# 	PACKAGE="grep-3.11";
# 	if ! cd "${PDIR}${PACKAGE}/build"; then
# 		return ;
# 	fi

# 	RunMakeCheckTest	"$PACKAGE";

# 	cd -;
# }

# # =====================================||===================================== #
# #									  Gzip									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallGzip()
# {
# 	PACKAGE="gzip-1.13";

# 	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

# 	ConfigureGzip;
# 	InstallPackageGzip;

# 	# EchoInfo	"Testing $PACKAGE";
# 	# ValidateGzip;
# }

# ConfigureGzip()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Configuring $PACKAGE...";
# 	./configure	--prefix=/usr	\
# 				--host=$LFS_TGT	\
# 				1> /dev/null

# 	cd -;
# }

# InstallPackageGzip()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling $PACKAGE...";
# 	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;

# 	EchoInfo	"Installing $PACKAGE...";
# 	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
# 	time make DESTDIR=$LFS install 1> /dev/null;

# 	cd -;
# }

# ValidateGzip()
# {
# 	PACKAGE="gzip-1.13";
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	RunMakeCheckTest	"$PACKAGE";

# 	cd -;
# }

# # =====================================||===================================== #
# #									  Make									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallMake()
# {
# 	PACKAGE="make-4.4.1";

# 	ExtractPackage	"${PDIR}${PACKAGE}.tar.gz"	"${PDIR}";

# 	ConfigureMake;
# 	InstallPackageMake;

# 	# EchoInfo	"Testing $PACKAGE";
# 	# ValidateMake;
# }

# ConfigureMake()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Configuring $PACKAGE...";
# 	./configure	--prefix=/usr	\
# 				--without-guile	\
# 				--host=$LFS_TGT	\
# 				--build=$(build-aux/config.guess)	\
# 				1> /dev/null

# 	cd -;
# }

# InstallPackageMake()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling $PACKAGE...";
# 	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;

# 	EchoInfo	"Installing $PACKAGE...";
# 	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
# 	time make DESTDIR=$LFS install 1> /dev/null;

# 	cd -;
# }

# ValidateMake()
# {
# 	PACKAGE="make-4.4.1";
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	RunMakeCheckTest	"$PACKAGE";

# 	cd -;
# }

# # =====================================||===================================== #
# #									  Patch									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallPatch()
# {
# 	PACKAGE="patch-2.7.6";

# 	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

# 	ConfigurePatch;
# 	InstallPackagePatch;

# 	# EchoInfo	"Testing $PACKAGE";
# 	# ValidatePatch;
# }

# ConfigurePatch()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Configuring $PACKAGE...";
# 	./configure	--prefix=/usr	\
# 				--host=$LFS_TGT	\
# 				--build=$(build-aux/config.guess)	\
# 				1> /dev/null

# 	cd -;
# }

# InstallPackagePatch()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling $PACKAGE...";
# 	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;

# 	EchoInfo	"Installing $PACKAGE...";
# 	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
# 	time make DESTDIR=$LFS install 1> /dev/null;

# 	cd -;
# }

# ValidatePatch()
# {
# 	PACKAGE="patch-2.7.6";
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	RunMakeCheckTest	"$PACKAGE";

# 	cd -;
# }

# # =====================================||===================================== #
# #									  Sed									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallSed()
# {
# 	PACKAGE="sed-4.9";

# 	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

# 	ConfigureSed;
# 	InstallPackageSed;

# 	# EchoInfo	"Testing $PACKAGE";
# 	# ValidateSed;
# }

# ConfigureSed()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Configuring $PACKAGE...";
# 	./configure	--prefix=/usr	\
# 				--host=$LFS_TGT	\
# 				--build=$(./build-aux/config.guess)	\
# 				1> /dev/null

# 	cd -;
# }

# InstallPackageSed()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling $PACKAGE...";
# 	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;

# 	EchoInfo	"Installing $PACKAGE...";
# 	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
# 	time make DESTDIR=$LFS install 1> /dev/null;

# 	cd -;
# }

# ValidateSed()
# {
# 	PACKAGE="sed-4.9";
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	RunMakeCheckTest	"$PACKAGE";

# 	cd -;
# }

# # =====================================||===================================== #
# #									  Tar									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallTar()
# {
# 	PACKAGE="tar-1.35";

# 	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

# 	ConfigureTar;
# 	InstallPackageTar;

# 	# EchoInfo	"Testing $PACKAGE";
# 	# ValidateTar;
# }

# ConfigureTar()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Configuring $PACKAGE...";
# 	./configure	--prefix=/usr	\
# 				--host=$LFS_TGT	\
# 				--build=$(build-aux/config.guess)	\
# 				1> /dev/null

# 	cd -;
# }

# InstallPackageTar()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling $PACKAGE...";
# 	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;

# 	EchoInfo	"Installing $PACKAGE...";
# 	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
# 	time make DESTDIR=$LFS install 1> /dev/null;

# 	cd -;
# }

# ValidateTar()
# {
# 	PACKAGE="tar-1.35";
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	RunMakeCheckTest	"$PACKAGE";

# 	cd -;
# }

# # =====================================||===================================== #
# #									  Xz									   #
# # ===============ft_linux==============||==============©Othello=============== #

# InstallXz()
# {
# 	PACKAGE="xz-5.6.2";

# 	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

# 	ConfigureXz;
# 	InstallPackageXz;

# 	# EchoInfo	"Testing $PACKAGE";
# 	# ValidateXz;
# }

# ConfigureXz()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Configuring $PACKAGE...";
# 	./configure	--prefix=/usr	\
# 				--host=$LFS_TGT	\
# 				--build=$(build-aux/config.guess)	\
# 				--disable-static	\
# 				--docdir=/usr/share/doc/xz-5.6.2	\
# 				1> /dev/null

# 	cd -;
# }

# InstallPackageXz()
# {
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	EchoInfo	"Compiling $PACKAGE...";
# 	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
# 	time make 1> /dev/null;

# 	EchoInfo	"Installing $PACKAGE...";
# 	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
# 	time make DESTDIR=$LFS install 1> /dev/null;

# 	# Remove the libtool archive file because it is harmful for cross compilation
# 	rm -v $LFS/usr/lib/liblzma.la

# 	cd -;
# }

# ValidateXz()
# {
# 	PACKAGE="xz-5.6.2";
# 	if ! cd "${PDIR}${PACKAGE}"; then
# 		return ;
# 	fi

# 	RunMakeCheckTest	"$PACKAGE";

# 	cd -;
# }

# # =====================================||===================================== #
# #																			   #
# #									 Tools									   #
# #																			   #
# # ===============ft_linux==============||==============©Othello=============== #

# GetInput()
# {
# 	echo	"$MSG";
# 	echo -n	"Choose an option: ";
# 	unset MSG;
# 	read	input;
# 	printf '%*s\n' "$width" '' | tr ' ' '-';
# }

# PressAnyKeyToContinue()
# {
# 	printf '%*s\n' "$width" '' | tr ' ' '-';
# 	if [ -t 0 ]; then
# 		echo	"Press any key to continue...";
# 		stty -echo -icanon
# 		input=$(dd bs=1 count=1 2>/dev/null)
# 		stty sane
# 	else
# 		echo	"Press Enter/Return to continue...";
# 		read -n 1 input;
# 	fi
# 	printf '%*s\n' "$width" '' | tr ' ' '-';
# }

# EchoError()
# {
# 	echo	"[${C_RED}ERR${C_RESET} ]  $1"	>&2;
# }

# EchoInfo()
# {
# 	echo	"[${C_CYAN}INFO${C_RESET}]$1";
# }

# EchoTest()
# {
# 	if [ "$1" = OK ]; then
# 		echo	"[${C_GREEN} OK ${C_RESET}] $2";
# 	elif [ "$1" = KO ]; then
# 		echo	"[${C_RED} KO ${C_RESET}] $2";
# 	else
# 		echo	"[${C_GRAY}TEST${C_RESET}] $1";
# 	fi
# }

# =====================================||===================================== #
#																			   #
#									  Menu									   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

# PDIR="$LFS/sources/lfs-packages12.2/";

# MainMenu()
# {
# 	printf '%*s\n' "$width" '' | tr ' ' '-';
# 	echo	"${C_ORANGE} LFS configuration${C_RESET}";
# 	echo	"Menu:\t${MENU}";
# 	echo	"Option:\t${-}";
# 	printf '%*s\n' "$width" '' | tr ' ' '-';
# 	echo	"1)\tUser configuration";
# 	echo	"2)\tCross-Toolchain compilling";
# 	echo	"3)\tCross-compiling temporary tools"
# 	echo	"q)\tQuit";
# 	printf '%*s\n' "$width" '' | tr ' ' '-';

# 	GetInput;

# 	case $input in
# 		1)	MENU=1;;
# 		# 2)	ValidatePackages;
# 		# 	MENU=2;;
# 		2)	./Utils5CompilingCrossToolChain.sh || PressAnyKeyToContinue;;
# 		3)	./Utils6CrossCompilingTemporaryTools.sh || PressAnyKeyToContinue;;
# 		# 1)	ConfigureUser;
# 		# 	PressAnyKeyToContinue;;
# 		# 2)	MenuCrossToolchain;
# 		# 	PressAnyKeyToContinue;;
# 		q|Q)	MENU=-1;;
# 		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";;
# 	esac
# }

# CLEARING=true;
# MENU=0;

# while true; do
# 	width=$(tput cols);
# 	if [ $CLEARING = true ]; then
# 		clear;
# 	fi

# 	case $MENU in
# 		-1)	break ;;
# 		0)	MainMenu;;
# 		1)	ConfigureUserMenu;;
# 		2)	MenuCrossToolchain;;
# 		3)	MenuTemporaryTools;;
# 		*)	EchoError	"Invalid menu '$MENU;";
# 			exit $MENU;;
# 	esac
# done

while true; do
	width=$(tput cols);
	if [ $CLEARING = true ]; then
		clear;
	fi

	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE} LFS configuration${C_RESET}";
	echo	"Menu:\t${MENU}";
	echo	"Option:\t${-}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"0)\tInstall all";
	# echo	"1)\tUser configuration";
	echo	"2)\tCross-Toolchain compilling";
	echo	"3)\tCross-compiling temporary tools"
	echo	"q)\tQuit";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	case $input in
		0)		./Utils5CompilingCrossToolChain.sh "InstallAll" && \
				./Utils6CrossCompilingTemporaryTools.sh "InstallAll";;
		# 1)		MENU=1;;
		2)		./Utils5CompilingCrossToolChain.sh || PressAnyKeyToContinue;;
		3)		./Utils6CrossCompilingTemporaryTools.sh || PressAnyKeyToContinue;;
		q|Q)	exit 0;;
		*)	MSG="${C_RED}Invalid input${C_RESET}: $input";;
	esac
done
