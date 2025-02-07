#! /bin/zsh

source Utils.sh

# =====================================||===================================== #
#																			   #
#				   Chapter 6. Cross Compiling Temporary Tools				   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

InstallPackages()
{
	InstallM4;
	InstallNcurses;
	InstallBash;
	InstallCoreutils;
	InstallDiffutils;
	InstallFile;
	InstallFindutils;
	InstallGawk;
	InstallGrep;
	InstallGzip;
	InstallMake;
	InstallPatch;
	InstallSed;
	InstallTar;
	InstallXz;
}

ValidatePackages()
{
	ValidateM4;
	ValidateNcurses;
	ValidateBash;
	ValidateCoreutils;
	ValidateDiffutils;
	ValidateFile;
	ValidateFindutils;
	ValidateGawk;
	ValidateGrep;
	ValidateGzip;
	ValidateMake;
	ValidatePatch;
	ValidateSed;
	ValidateTar;
	ValidateXz;
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

RunMakeCheckTest()
{
	if make -n check &> /dev/null; then
		if make check &> /dev/null; then
			EchoTest	OK	"$1";
		else
			EchoTest	KO	"$1";
			if [ -d "test" ]; then
				ls test/_*;
			fi
		fi
	else
		EchoTest	"$1 ${C_DGRAY}make -n check failed${C_RESET}";
	fi
}

# =====================================||===================================== #
#																			   #
#				 					Packages								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

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
# 	time make 1> /dev/null  || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

# 	EchoInfo	"Installing $PACKAGE...";
# 	echo		"${C_DGRAY}> make install 1> /dev/null${C_RESET}";
# 	time make install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

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

# =====================================||===================================== #
#									  M4									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallM4()
{
	PACKAGE="m4-1.4.19";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

	ConfigureM4;
	InstallPackageM4;

	# EchoInfo	"Testing $PACKAGE";
	# ValidateM4;

	cd -;
}

ConfigureM4()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Configuring $PACKAGE...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null

	cd -;
}

InstallPackageM4()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Compiling $PACKAGE...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};
	EchoInfo	"Installing $PACKAGE...";
	echo		"${C_DGRAY}> DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateM4()
{
	PACKAGE="m4-1.4.19";
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	RunMakeCheckTest	"$PACKAGE";

	cd -;
}

# =====================================||===================================== #
#									  Ncurses									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallNcurses()
{
	PACKAGE="ncurses-6.5";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.gz"	"${PDIR}";

	if ! mkdir -pv "${PDIR}${PACKAGE}/build"; then
		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
		return ;
	fi

	ConfigureNcurses;
	InstallPackageNcurses;

	# EchoInfo	"Testing $PACKAGE";
	# ValidateNcurses;
}

ConfigureNcurses()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	sed -i s/mawk// configure;

	if [ ! -d "${PDIR}${PACKAGE}/build"] ; then
		return ;
	fi

	EchoInfo	"Configuring $PACKAGE...";
	pushd build
		../configure	1> /dev/null
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
				1> /dev/null

	cd -;
}

InstallPackageNcurses()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Compiling $PACKAGE...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing $PACKAGE...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS TIC_PATH=\$(pwd)/build/progs/tic install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	EchoInfo	"Configuring libncurses library...";
	# symlink to use libncursesw.so
	ln -sv libncursesw.so $LFS/usr/lib/libncurses.so;
	# Edit the header file so it will always use the wide-character data structure definition compatible with libncursesw.so.
	sed -e 's/^#if.*XOPEN.*$/#if 1/' \
		-i $LFS/usr/include/curses.h;

	cd -;
}

ValidateNcurses()
{
	PACKAGE="ncurses-6.5";
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	RunMakeCheckTest	"$PACKAGE";

	cd -;
}

# =====================================||===================================== #
#									  Bash									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallBash()
{
	PACKAGE="bash-5.2.32";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.gz"	"${PDIR}";

	ConfigureBash;
	InstallPackageBash;

	# EchoInfo	"Testing $PACKAGE";
	# ValidateBash;
}

ConfigureBash()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Configuring $PACKAGE...";

	./configure	--prefix=/usr	\
				--build=$(sh support/config.guess) \
				--host=$LFS_TGT	\
				--without-bash-malloc	\
				bash_cv_strtold_broken=no	\
				1>/dev/null
	cd -;
}

InstallPackageBash()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Compiling $PACKAGE...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing $PACKAGE...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	# Link for the programs that use sh for a shell
	ln -sv bash $LFS/bin/sh

	cd -;
}

ValidateBash()
{
	PACKAGE="bash-5.2.32";
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	RunMakeCheckTest	"$PACKAGE";

	cd -;
}

# =====================================||===================================== #
#									  Coreutils									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallCoreutils()
{
	PACKAGE="coreutils-9.5";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

	ConfigureCoreutils;
	InstallPackageCoreutils;

	# EchoInfo	"Testing $PACKAGE";
	# ValidateCoreutils;
}

ConfigureCoreutils()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Configuring $PACKAGE...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				--enable-install-program=hostname	\
				--enable-no-install-program=kill,uptime	\
				1> /dev/null;

	cd -;
}

InstallPackageCoreutils()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Compiling $PACKAGE...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing $PACKAGE...";
	echo		"${C_DGRAY}> make DESTDIR=$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	# Move programs to their final expected locations
	mv -v $LFS/usr/bin/chroot
	$LFS/usr/sbin
	mkdir -pv $LFS/usr/share/man/man8
	mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
	sed -i 's/"1"/"8"/'
	$LFS/usr/share/man/man8/chroot.8

	cd -;
}

ValidateCoreutils()
{
	PACKAGE="coreutils-9.5";
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	RunMakeCheckTest	"$PACKAGE";

	cd -;
}

# =====================================||===================================== #
#									  Diffutils									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallDiffutils()
{
	PACKAGE="diffutils-3.10";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

	ConfigureDiffutils;
	InstallPackageDiffutils;

	# EchoInfo	"Testing $PACKAGE";
	# ValidateDiffutils;
}

ConfigureDiffutils()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Configuring $PACKAGE...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(./build-aux/config.guess)	\
				1> /dev/null

	cd -;
}

InstallPackageDiffutils()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Compiling $PACKAGE...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing $PACKAGE...";
	echo		"${C_DGRAY}> make DESTDIR=$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateDiffutils()
{
	PACKAGE="diffutils-3.10";
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	RunMakeCheckTest	"$PACKAGE";

	cd -;
}

# =====================================||===================================== #
#									  File									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallFile()
{
	PACKAGE="file-5.45";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.gz"	"${PDIR}";

	if ! mkdir -pv "${PDIR}${PACKAGE}/build"; then
		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
		return ;
	fi

	ConfigureFile;
	InstallPackageFile;

	# EchoInfo	"Testing $PACKAGE";
	# ValidateFile;
}

ConfigureFile()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	if [ ! -d "${PDIR}${PACKAGE}/build" ]; then
		return ;
	fi
	EchoInfo	"Configuring $PACKAGE...";
	pushd build
		../configure	--disable-bzlib	\
						--disable-libseccomp \
						--disable-xzlib	\
						--disable-zlib	\
						1> /dev/null
		make	 1> /dev/null
	popd

	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(./config.guess)	\
				1> /dev/null

	cd -;
}

InstallPackageFile()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Compiling $PACKAGE...";
	echo		"${C_DGRAY}> make FILE_COMPILE=\$(pwd)/build/src/file 1> /dev/null${C_RESET}";
	time make FILE_COMPILE=$(pwd)/build/src/file 1> /dev/null;

	EchoInfo	"Installing $PACKAGE...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	# Remove the libtool archive file because it is harmful for cross compilation
	rm -v $LFS/usr/lib/libmagic.la

	cd -;
}

ValidateFile()
{
	PACKAGE="file-5.45";
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	RunMakeCheckTest	"$PACKAGE";

	cd -;
}


# =====================================||===================================== #
#									  Findutils									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallFindutils()
{
	PACKAGE="findutils-4.10.0";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

	ConfigureFindutils;
	InstallPackageFindutils;

	# EchoInfo	"Testing $PACKAGE";
	# ValidateFindutils;
}

ConfigureFindutils()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Configuring $PACKAGE...";
	./configure	--prefix=/usr	\
				--localstatedir=/var/lib/locate	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null;

	cd -;
}

InstallPackageFindutils()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Compiling $PACKAGE...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing $PACKAGE...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateFindutils()
{
	PACKAGE="findutils-4.10.0";
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	RunMakeCheckTest	"$PACKAGE";

	cd -;
}

# =====================================||===================================== #
#									  Gawk									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallGawk()
{
	PACKAGE="gawk-5.3.0";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

	ConfigureGawk;
	InstallPackageGawk;

	# EchoInfo	"Testing $PACKAGE";
	# ValidateGawk;
}

ConfigureGawk()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	# Ensure some unneeded files are not installed
	sed -i 's/extras//' Makefile.in

	EchoInfo	"Configuring $PACKAGE...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null

	cd -;
}

InstallPackageGawk()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Compiling $PACKAGE...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing $PACKAGE...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateGawk()
{
	PACKAGE="gawk-5.3.0";
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	RunMakeCheckTest	"$PACKAGE";

	cd -;
}

# =====================================||===================================== #
#									  Grep									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallGrep()
{
	PACKAGE="grep-3.11";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

	ConfigureGrep;
	InstallPackageGrep;

	# EchoInfo	"Testing $PACKAGE";
	# ValidateGrep;
}

ConfigureGrep()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Configuring $PACKAGE...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(./build-aux/config.guess)	\
				1> /dev/null

	cd -;
}

InstallPackageGrep()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Compiling $PACKAGE...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing $PACKAGE...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateGrep()
{
	PACKAGE="grep-3.11";
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	RunMakeCheckTest	"$PACKAGE";

	cd -;
}

# =====================================||===================================== #
#									  Gzip									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallGzip()
{
	PACKAGE="gzip-1.13";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

	ConfigureGzip;
	InstallPackageGzip;

	# EchoInfo	"Testing $PACKAGE";
	# ValidateGzip;
}

ConfigureGzip()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Configuring $PACKAGE...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				1> /dev/null

	cd -;
}

InstallPackageGzip()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Compiling $PACKAGE...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing $PACKAGE...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateGzip()
{
	PACKAGE="gzip-1.13";
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	RunMakeCheckTest	"$PACKAGE";

	cd -;
}

# =====================================||===================================== #
#									  Make									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallMake()
{
	PACKAGE="make-4.4.1";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.gz"	"${PDIR}";

	ConfigureMake;
	InstallPackageMake;

	# EchoInfo	"Testing $PACKAGE";
	# ValidateMake;
}

ConfigureMake()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Configuring $PACKAGE...";
	./configure	--prefix=/usr	\
				--without-guile	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null

	cd -;
}

InstallPackageMake()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Compiling $PACKAGE...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing $PACKAGE...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateMake()
{
	PACKAGE="make-4.4.1";
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	RunMakeCheckTest	"$PACKAGE";

	cd -;
}

# =====================================||===================================== #
#									  Patch									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallPatch()
{
	PACKAGE="patch-2.7.6";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

	ConfigurePatch;
	InstallPackagePatch;

	# EchoInfo	"Testing $PACKAGE";
	# ValidatePatch;
}

ConfigurePatch()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Configuring $PACKAGE...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null

	cd -;
}

InstallPackagePatch()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Compiling $PACKAGE...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing $PACKAGE...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	cd -;
}

ValidatePatch()
{
	PACKAGE="patch-2.7.6";
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	RunMakeCheckTest	"$PACKAGE";

	cd -;
}

# =====================================||===================================== #
#									  Sed									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallSed()
{
	PACKAGE="sed-4.9";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

	ConfigureSed;
	InstallPackageSed;

	# EchoInfo	"Testing $PACKAGE";
	# ValidateSed;
}

ConfigureSed()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Configuring $PACKAGE...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(./build-aux/config.guess)	\
				1> /dev/null

	cd -;
}

InstallPackageSed()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Compiling $PACKAGE...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing $PACKAGE...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateSed()
{
	PACKAGE="sed-4.9";
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	RunMakeCheckTest	"$PACKAGE";

	cd -;
}

# =====================================||===================================== #
#									  Tar									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallTar()
{
	PACKAGE="tar-1.35";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

	ConfigureTar;
	InstallPackageTar;

	# EchoInfo	"Testing $PACKAGE";
	# ValidateTar;
}

ConfigureTar()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Configuring $PACKAGE...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null

	cd -;
}

InstallPackageTar()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Compiling $PACKAGE...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing $PACKAGE...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateTar()
{
	PACKAGE="tar-1.35";
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	RunMakeCheckTest	"$PACKAGE";

	cd -;
}

# =====================================||===================================== #
#									  Xz									   #
# ===============ft_linux==============||==============©Othello=============== #

InstallXz()
{
	PACKAGE="xz-5.6.2";

	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

	ConfigureXz;
	InstallPackageXz;

	# EchoInfo	"Testing $PACKAGE";
	# ValidateXz;
}

ConfigureXz()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Configuring $PACKAGE...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				--disable-static	\
				--docdir=/usr/share/doc/xz-5.6.2	\
				1> /dev/null

	cd -;
}

InstallPackageXz()
{
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	EchoInfo	"Compiling $PACKAGE...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing $PACKAGE...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	# Remove the libtool archive file because it is harmful for cross compilation
	rm -v $LFS/usr/lib/liblzma.la

	cd -;
}

ValidateXz()
{
	PACKAGE="xz-5.6.2";
	if ! cd "${PDIR}${PACKAGE}"; then
		return ;
	fi

	RunMakeCheckTest	"$PACKAGE";

	cd -;
}

# =====================================||===================================== #
#								 BinutilsPass2								   #
# ===============ft_linux==============||==============©Othello=============== #

InstallBinutilsPass2()
{
	PACKAGE="binutils-2.43.1";

	rm -rf binutils-2.43.1;

	ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

	if ! mkdir -pv "${PDIR}${PACKAGE}/build"; then
		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
		return ;
	fi

	ConfigureBinutilsPass2;
	InstallPackageBinutilsPass2;

	# EchoInfo	"Testing $PACKAGE";
	# ValidateBinutilsPass2;
}

ConfigureBinutilsPass2()
{
	# Prevent binaries mistakenly linked against libraries from the host distro
	if [ -f "${PDIR}${PACKAGE}/ltmain.sh" ]; then
		sed '6009s/$add_dir//' -i ${PDIR}${PACKAGE}/ltmain.sh
	else
		EchoError	"Script ${PACKAGE}/ltmain.sh not found...";
		return ;
	fi

	if ! cd "${PDIR}${PACKAGE}/build"; then
		return ;
	fi

	EchoInfo	"Configuring $PACKAGE...";
	../configure	--prefix=/usr	\
					--build=$(../config.guess)	\
					--host=$LFS_TGT	\
					--disable-nls	\
					--enable-shared	\
					--enable-gprofng=no	\
					--disable-werror	\
					--enable-64-bit-bfd	\
					--enable-new-dtags	\
					--enable-default-hash-style=gnu	\
					1> /dev/null;

	cd -;
}

InstallPackageBinutilsPass2()
{
	if ! cd "${PDIR}${PACKAGE}/build"; then
		return ;
	fi

	EchoInfo	"Compiling $PACKAGE...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing $PACKAGE...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	# Remove the libtool archive files because they are harmful for cross compilation, and remove unnecessary static libraries
	rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}

	cd -;
}

ValidateBinutilsPass2()
{
	PACKAGE="binutils-2.43.1";
	if ! cd "${PDIR}${PACKAGE}/build"; then
		return ;
	fi

	RunMakeCheckTest	"$PACKAGE";

	cd -;
}

# =====================================||===================================== #
#									GccPass2								   #
# ===============ft_linux==============||==============©Othello=============== #

InstallGccPass2()
{
	PACKAGE="gcc-14.2.0";

	# ExtractPackage	"${PDIR}${PACKAGE}.tar.xz"	"${PDIR}";

	if ! mkdir -pv "${PDIR}${PACKAGE}/build"; then
		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
		return ;
	fi

	ConfigureGccPass2;
	InstallPackageGccPass2;

	# EchoInfo	"Testing $PACKAGE";
	# ValidateGccPass2;
}

ConfigureGccPass2()
{
	if ! cd "${PDIR}${PACKAGE}/build"; then
		return ;
	fi

	EchoInfo	"Configuring $PACKAGE...";
	../configure	--build=$(../config.guess)	\
					--host=$LFS_TGT	\
					--target=$LFS_TGT	\
					LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc	\
					--prefix=/usr	\
					--with-build-sysroot=$LFS	\
					--enable-default-pie	\
					--enable-default-ssp	\
					--disable-nls	\
					--disable-multilib	\
					--disable-libatomic	\
					--disable-libgomp	\
					--disable-libquadmath	\
					--disable-libsanitizer	\
					--disable-libssp	\
					--disable-libvtv	\
					--enable-languages=c,c++	\
					1> /dev/null

	cd -;
}

InstallPackageGccPass2()
{
	if ! cd "${PDIR}${PACKAGE}/build"; then
		return ;
	fi

	EchoInfo	"Compiling $PACKAGE...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing $PACKAGE...";
	echo		"${C_DGRAY}> make DESTDIR=$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO $PACKAGE && PressAnyKeyToContinue; return;};

	# Create a utility symlink to cc
	ln -sv gcc $LFS/usr/bin/cc

	cd -;
}

ValidateGccPass2()
{
	PACKAGE="gcc-14.2.0";
	if ! cd "${PDIR}${PACKAGE}/build"; then
		return ;
	fi

	RunMakeCheckTest	"$PACKAGE";

	cd -;
}

# =====================================||===================================== #
#																			   #
#									Main Loop								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

while true; do
	width=$(tput cols);
	if [ $CLEARING = true ]; then
		clear;
	fi

	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"${C_ORANGE}Temporary Tools${C_RESET}";
	printf '%*s\n' "$width" '' | tr ' ' '-';
	echo	"i)\tInstall temporary tools";
	echo	"b)\tInstall Binutils Pass2";
	echo	"g)\tInstall Gcc Pass2";
	echo	"v)\tValidate temporary tools";
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$width" '' | tr ' ' '-';

	GetInput;

	local PRESSTOCONTINUE=true;
	case $input in
		i|I)	InstallPackages;;
		b|B)	InstallBinutilsPass2;;
		g|G)	InstallGccPass2;;
		v|V)	ValidatePackages;
				PressAnyKeyToContinue;;
		q|Q)	exit 0;;
		*)		MSG="${C_RED}Invalid input${C_RESET}: $input";
				PRESSTOCONTINUE=false;;
	esac

	$PRESSTOCONTINUE && PressAnyKeyToContinue;
done
