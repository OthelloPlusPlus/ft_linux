#! /bin/zsh

source Utils.sh

# =====================================||===================================== #
#																			   #
#				   Chapter 6. Cross Compiling Temporary Tools				   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A TempPackages;

InstallPackages()
{
	RemoveAllPackages;

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

RemoveAllPackages()
{
	RemovePackage	"${TempPackages[m4]}";
	RemovePackage	"${TempPackages[ncurses]}";
	RemovePackage	"${TempPackages[bash]}";
	RemovePackage	"${TempPackages[coreutils]}";
	RemovePackage	"${TempPackages[diffutils]}";
	RemovePackage	"${TempPackages[file]}";
	RemovePackage	"${TempPackages[findutils]}";
	RemovePackage	"${TempPackages[gawk]}";
	RemovePackage	"${TempPackages[grep]}";
	RemovePackage	"${TempPackages[gzip]}";
	RemovePackage	"${TempPackages[make]}";
	RemovePackage	"${TempPackages[patch]}";
	RemovePackage	"${TempPackages[sed]}";
	RemovePackage	"${TempPackages[tar]}";
	RemovePackage	"${TempPackages[xz]}";

	RemovePackage	"${TempPackages[binutils]}";
	RemovePackage	"${TempPackages[gcc]}";
}

# =====================================||===================================== #
#																			   #
#				 					Packages								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

# # =====================================||===================================== #
# #									  Temp									   #
# # ===============ft_linux==============||==============©Othello=============== #

# TempPackages[Temp]="";

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

TempPackages[m4]="m4-1.4.19";

InstallM4()
{
	# PACKAGE="m4-1.4.19";

	ExtractPackage	"${PDIR}${TempPackages[m4]}.tar.xz"	"${PDIR}";

	ConfigureM4;
	InstallPackageM4;

	# EchoInfo	"Testing ${TempPackages[m4]}";
	# ValidateM4;

	cd -;
}

ConfigureM4()
{
	if ! cd "${PDIR}${TempPackages[m4]}"; then
		return ;
	fi

	EchoInfo	"Configuring $TempPackages[m4]...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null

	cd -;
}

InstallPackageM4()
{
	if ! cd "${PDIR}${TempPackages[m4]}"; then
		return ;
	fi

	EchoInfo	"Compiling $TempPackages[m4]...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO $TempPackages[m4] && PressAnyKeyToContinue; return;};
	EchoInfo	"Installing $TempPackages[m4]...";
	echo		"${C_DGRAY}> DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${TempPackages[m4]} && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateM4()
{
	# PACKAGE="m4-1.4.19";
	if ! cd "${PDIR}${TempPackages[m4]}"; then
		return ;
	fi

	RunMakeCheckTest	"$TempPackages[m4]";

	cd -;
}

# =====================================||===================================== #
#									  Ncurses									   #
# ===============ft_linux==============||==============©Othello=============== #

TempPackages[ncurses]="ncurses-6.5";

InstallNcurses()
{
	# PACKAGE="ncurses-6.5";

	ExtractPackage	"${PDIR}${TempPackages[ncurses]}.tar.gz"	"${PDIR}";

	if ! mkdir -pv "${PDIR}${TempPackages[ncurses]}/build"; then
		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
		return ;
	fi

	ConfigureNcurses;
	InstallPackageNcurses;

	# EchoInfo	"Testing ${TempPackages[ncurses]}";
	# ValidateNcurses;
}

ConfigureNcurses()
{
	if ! cd "${PDIR}${TempPackages[ncurses]}"; then
		return ;
	fi

	sed -i s/mawk// configure;

	if [ ! -d "${PDIR}${TempPackages[ncurses]}/build"] ; then
		return ;
	fi

	EchoInfo	"Configuring ${TempPackages[ncurses]}...";
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
	if ! cd "${PDIR}${TempPackages[ncurses]}"; then
		return ;
	fi

	EchoInfo	"Compiling ${TempPackages[ncurses]}...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${TempPackages[ncurses]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing ${TempPackages[ncurses]}...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS TIC_PATH=\$(pwd)/build/progs/tic install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install 1> /dev/null || {EchoTest KO ${TempPackages[ncurses]} && PressAnyKeyToContinue; return;};

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
	# PACKAGE="ncurses-6.5";
	if ! cd "${PDIR}${TempPackages[ncurses]}"; then
		return ;
	fi

	RunMakeCheckTest	"${TempPackages[ncurses]}";

	cd -;
}

# =====================================||===================================== #
#									  Bash									   #
# ===============ft_linux==============||==============©Othello=============== #

TempPackages[bash]="bash-5.2.32";

InstallBash()
{
	# PACKAGE="bash-5.2.32";

	ExtractPackage	"${PDIR}${TempPackages[bash]}.tar.gz"	"${PDIR}";

	ConfigureBash;
	InstallPackageBash;

	# EchoInfo	"Testing ${TempPackages[bash]}";
	# ValidateBash;
}

ConfigureBash()
{
	if ! cd "${PDIR}${TempPackages[bash]}"; then
		return ;
	fi

	EchoInfo	"Configuring ${TempPackages[bash]}...";

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
	if ! cd "${PDIR}${TempPackages[bash]}"; then
		return ;
	fi

	EchoInfo	"Compiling ${TempPackages[bash]}...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${TempPackages[bash]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing ${TempPackages[bash]}...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${TempPackages[bash]} && PressAnyKeyToContinue; return;};

	# Link for the programs that use sh for a shell
	ln -sv bash $LFS/bin/sh

	cd -;
}

ValidateBash()
{
	# PACKAGE="bash-5.2.32";
	if ! cd "${PDIR}${TempPackages[bash]}"; then
		return ;
	fi

	RunMakeCheckTest	"${TempPackages[bash]}";

	cd -;
}

# =====================================||===================================== #
#									  Coreutils									   #
# ===============ft_linux==============||==============©Othello=============== #

TempPackages[coreutils]="coreutils-9.5";

InstallCoreutils()
{
	# PACKAGE="coreutils-9.5";

	ExtractPackage	"${PDIR}${TempPackages[coreutils]}.tar.xz"	"${PDIR}";

	ConfigureCoreutils;
	InstallPackageCoreutils;

	# EchoInfo	"Testing ${TempPackages[coreutils]}";
	# ValidateCoreutils;
}

ConfigureCoreutils()
{
	if ! cd "${PDIR}${TempPackages[coreutils]}"; then
		return ;
	fi

	EchoInfo	"Configuring ${TempPackages[coreutils]}...";
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
	if ! cd "${PDIR}${TempPackages[coreutils]}"; then
		return ;
	fi

	EchoInfo	"Compiling ${TempPackages[coreutils]}...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${TempPackages[coreutils]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing ${TempPackages[coreutils]}...";
	echo		"${C_DGRAY}> make DESTDIR=$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${TempPackages[coreutils]} && PressAnyKeyToContinue; return;};

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
	# PACKAGE="coreutils-9.5";
	if ! cd "${PDIR}${TempPackages[coreutils]}"; then
		return ;
	fi

	RunMakeCheckTest	"${TempPackages[coreutils]}";

	cd -;
}

# =====================================||===================================== #
#									  Diffutils									   #
# ===============ft_linux==============||==============©Othello=============== #

TempPackages[diffutils]="diffutils-3.10";

InstallDiffutils()
{
	# PACKAGE="diffutils-3.10";

	ExtractPackage	"${PDIR}${TempPackages[diffutils]}.tar.xz"	"${PDIR}";

	ConfigureDiffutils;
	InstallPackageDiffutils;

	# EchoInfo	"Testing ${TempPackages[diffutils]}";
	# ValidateDiffutils;
}

ConfigureDiffutils()
{
	if ! cd "${PDIR}${TempPackages[diffutils]}"; then
		return ;
	fi

	EchoInfo	"Configuring ${TempPackages[diffutils]}...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(./build-aux/config.guess)	\
				1> /dev/null

	cd -;
}

InstallPackageDiffutils()
{
	if ! cd "${PDIR}${TempPackages[diffutils]}"; then
		return ;
	fi

	EchoInfo	"Compiling ${TempPackages[diffutils]}...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${TempPackages[diffutils]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing ${TempPackages[diffutils]}...";
	echo		"${C_DGRAY}> make DESTDIR=$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${TempPackages[diffutils]} && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateDiffutils()
{
	# PACKAGE="diffutils-3.10";
	if ! cd "${PDIR}${TempPackages[diffutils]}"; then
		return ;
	fi

	RunMakeCheckTest	"${TempPackages[diffutils]}";

	cd -;
}

# =====================================||===================================== #
#									  File									   #
# ===============ft_linux==============||==============©Othello=============== #

TempPackages[file]="file-5.45";

InstallFile()
{
	# PACKAGE="file-5.45";

	ExtractPackage	"${PDIR}${TempPackages[file]}.tar.gz"	"${PDIR}";

	if ! mkdir -pv "${PDIR}${TempPackages[file]}/build"; then
		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
		return ;
	fi

	ConfigureFile;
	InstallPackageFile;

	# EchoInfo	"Testing ${TempPackages[file]}";
	# ValidateFile;
}

ConfigureFile()
{
	if ! cd "${PDIR}${TempPackages[file]}"; then
		return ;
	fi

	if [ ! -d "${PDIR}${TempPackages[file]}/build" ]; then
		return ;
	fi
	EchoInfo	"Configuring ${TempPackages[file]}...";
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
	if ! cd "${PDIR}${TempPackages[file]}"; then
		return ;
	fi

	EchoInfo	"Compiling ${TempPackages[file]}...";
	echo		"${C_DGRAY}> make FILE_COMPILE=\$(pwd)/build/src/file 1> /dev/null${C_RESET}";
	time make FILE_COMPILE=$(pwd)/build/src/file 1> /dev/null;

	EchoInfo	"Installing ${TempPackages[file]}...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${TempPackages[file]} && PressAnyKeyToContinue; return;};

	# Remove the libtool archive file because it is harmful for cross compilation
	rm -v $LFS/usr/lib/libmagic.la

	cd -;
}

ValidateFile()
{
	# PACKAGE="file-5.45";
	if ! cd "${PDIR}${TempPackages[file]}"; then
		return ;
	fi

	RunMakeCheckTest	"${TempPackages[file]}";

	cd -;
}


# =====================================||===================================== #
#									  Findutils									   #
# ===============ft_linux==============||==============©Othello=============== #

TempPackages[findutils]="findutils-4.10.0";

InstallFindutils()
{
	# PACKAGE="findutils-4.10.0";

	ExtractPackage	"${PDIR}${TempPackages[findutils]}.tar.xz"	"${PDIR}";

	ConfigureFindutils;
	InstallPackageFindutils;

	# EchoInfo	"Testing ${TempPackages[findutils]}";
	# ValidateFindutils;
}

ConfigureFindutils()
{
	if ! cd "${PDIR}${TempPackages[findutils]}"; then
		return ;
	fi

	EchoInfo	"Configuring ${TempPackages[findutils]}...";
	./configure	--prefix=/usr	\
				--localstatedir=/var/lib/locate	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null;

	cd -;
}

InstallPackageFindutils()
{
	if ! cd "${PDIR}${TempPackages[findutils]}"; then
		return ;
	fi

	EchoInfo	"Compiling ${TempPackages[findutils]}...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${TempPackages[findutils]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing ${TempPackages[findutils]}...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${TempPackages[findutils]} && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateFindutils()
{
	# PACKAGE="findutils-4.10.0";
	if ! cd "${PDIR}${TempPackages[findutils]}"; then
		return ;
	fi

	RunMakeCheckTest	"${TempPackages[findutils]}";

	cd -;
}

# =====================================||===================================== #
#									  Gawk									   #
# ===============ft_linux==============||==============©Othello=============== #

TempPackages[gawk]="gawk-5.3.0";

InstallGawk()
{
	# PACKAGE="gawk-5.3.0";

	ExtractPackage	"${PDIR}${TempPackages[gawk]}.tar.xz"	"${PDIR}";

	ConfigureGawk;
	InstallPackageGawk;

	# EchoInfo	"Testing ${TempPackages[gawk]}";
	# ValidateGawk;
}

ConfigureGawk()
{
	if ! cd "${PDIR}${TempPackages[gawk]}"; then
		return ;
	fi

	# Ensure some unneeded files are not installed
	sed -i 's/extras//' Makefile.in

	EchoInfo	"Configuring ${TempPackages[gawk]}...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null

	cd -;
}

InstallPackageGawk()
{
	if ! cd "${PDIR}${TempPackages[gawk]}"; then
		return ;
	fi

	EchoInfo	"Compiling ${TempPackages[gawk]}...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${TempPackages[gawk]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing ${TempPackages[gawk]}...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${TempPackages[gawk]} && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateGawk()
{
	# PACKAGE="gawk-5.3.0";
	if ! cd "${PDIR}${TempPackages[gawk]}"; then
		return ;
	fi

	RunMakeCheckTest	"${TempPackages[gawk]}";

	cd -;
}

# =====================================||===================================== #
#									  Grep									   #
# ===============ft_linux==============||==============©Othello=============== #

TempPackages[grep]="grep-3.11";

InstallGrep()
{
	# PACKAGE="grep-3.11";

	ExtractPackage	"${PDIR}${TempPackages[grep]}.tar.xz"	"${PDIR}";

	ConfigureGrep;
	InstallPackageGrep;

	# EchoInfo	"Testing ${TempPackages[grep]}";
	# ValidateGrep;
}

ConfigureGrep()
{
	if ! cd "${PDIR}${TempPackages[grep]}"; then
		return ;
	fi

	EchoInfo	"Configuring ${TempPackages[grep]}...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(./build-aux/config.guess)	\
				1> /dev/null

	cd -;
}

InstallPackageGrep()
{
	if ! cd "${PDIR}${TempPackages[grep]}"; then
		return ;
	fi

	EchoInfo	"Compiling ${TempPackages[grep]}...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${TempPackages[grep]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing ${TempPackages[grep]}...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${TempPackages[grep]} && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateGrep()
{
	# PACKAGE="grep-3.11";
	if ! cd "${PDIR}${TempPackages[grep]}"; then
		return ;
	fi

	RunMakeCheckTest	"${TempPackages[grep]}";

	cd -;
}

# =====================================||===================================== #
#									  Gzip									   #
# ===============ft_linux==============||==============©Othello=============== #

TempPackages[gzip]="gzip-1.13";

InstallGzip()
{
	# PACKAGE="gzip-1.13";

	ExtractPackage	"${PDIR}${TempPackages[gzip]}.tar.xz"	"${PDIR}";

	ConfigureGzip;
	InstallPackageGzip;

	# EchoInfo	"Testing ${TempPackages[gzip]}";
	# ValidateGzip;
}

ConfigureGzip()
{
	if ! cd "${PDIR}${TempPackages[gzip]}"; then
		return ;
	fi

	EchoInfo	"Configuring ${TempPackages[gzip]}...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				1> /dev/null

	cd -;
}

InstallPackageGzip()
{
	if ! cd "${PDIR}${TempPackages[gzip]}"; then
		return ;
	fi

	EchoInfo	"Compiling ${TempPackages[gzip]}...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${TempPackages[gzip]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing ${TempPackages[gzip]}...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${TempPackages[gzip]} && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateGzip()
{
	# PACKAGE="gzip-1.13";
	if ! cd "${PDIR}${TempPackages[gzip]}"; then
		return ;
	fi

	RunMakeCheckTest	"${TempPackages[gzip]}";

	cd -;
}

# =====================================||===================================== #
#									  Make									   #
# ===============ft_linux==============||==============©Othello=============== #

TempPackages[make]="make-4.4.1";

InstallMake()
{
	# PACKAGE="make-4.4.1";

	ExtractPackage	"${PDIR}${TempPackages[make]}.tar.gz"	"${PDIR}";

	ConfigureMake;
	InstallPackageMake;

	# EchoInfo	"Testing ${TempPackages[make]}";
	# ValidateMake;
}

ConfigureMake()
{
	if ! cd "${PDIR}${TempPackages[make]}"; then
		return ;
	fi

	EchoInfo	"Configuring ${TempPackages[make]}...";
	./configure	--prefix=/usr	\
				--without-guile	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null

	cd -;
}

InstallPackageMake()
{
	if ! cd "${PDIR}${TempPackages[make]}"; then
		return ;
	fi

	EchoInfo	"Compiling ${TempPackages[make]}...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${TempPackages[make]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing ${TempPackages[make]}...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${TempPackages[make]} && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateMake()
{
	# PACKAGE="make-4.4.1";
	if ! cd "${PDIR}${TempPackages[make]}"; then
		return ;
	fi

	RunMakeCheckTest	"${TempPackages[make]}";

	cd -;
}

# =====================================||===================================== #
#									  Patch									   #
# ===============ft_linux==============||==============©Othello=============== #

TempPackages[patch]="patch-2.7.6";

InstallPatch()
{
	# PACKAGE="patch-2.7.6";

	ExtractPackage	"${PDIR}${TempPackages[patch]}.tar.xz"	"${PDIR}";

	ConfigurePatch;
	InstallPackagePatch;

	# EchoInfo	"Testing ${TempPackages[patch]}";
	# ValidatePatch;
}

ConfigurePatch()
{
	if ! cd "${PDIR}${TempPackages[patch]}"; then
		return ;
	fi

	EchoInfo	"Configuring ${TempPackages[patch]}...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null

	cd -;
}

InstallPackagePatch()
{
	if ! cd "${PDIR}${TempPackages[patch]}"; then
		return ;
	fi

	EchoInfo	"Compiling ${TempPackages[patch]}...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${TempPackages[patch]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing ${TempPackages[patch]}...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${TempPackages[patch]} && PressAnyKeyToContinue; return;};

	cd -;
}

ValidatePatch()
{
	# PACKAGE="patch-2.7.6";
	if ! cd "${PDIR}${TempPackages[patch]}"; then
		return ;
	fi

	RunMakeCheckTest	"${TempPackages[patch]}";

	cd -;
}

# =====================================||===================================== #
#									  Sed									   #
# ===============ft_linux==============||==============©Othello=============== #

TempPackages[sed]="sed-4.9";

InstallSed()
{
	# PACKAGE="sed-4.9";

	ExtractPackage	"${PDIR}${TempPackages[sed]}.tar.xz"	"${PDIR}";

	ConfigureSed;
	InstallPackageSed;

	# EchoInfo	"Testing ${TempPackages[sed]}";
	# ValidateSed;
}

ConfigureSed()
{
	if ! cd "${PDIR}${TempPackages[sed]}"; then
		return ;
	fi

	EchoInfo	"Configuring ${TempPackages[sed]}...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(./build-aux/config.guess)	\
				1> /dev/null

	cd -;
}

InstallPackageSed()
{
	if ! cd "${PDIR}${TempPackages[sed]}"; then
		return ;
	fi

	EchoInfo	"Compiling ${TempPackages[sed]}...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${TempPackages[sed]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing ${TempPackages[sed]}...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${TempPackages[sed]} && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateSed()
{
	# PACKAGE="sed-4.9";
	if ! cd "${PDIR}${TempPackages[sed]}"; then
		return ;
	fi

	RunMakeCheckTest	"${TempPackages[sed]}";

	cd -;
}

# =====================================||===================================== #
#									  Tar									   #
# ===============ft_linux==============||==============©Othello=============== #

TempPackages[tar]="tar-1.35";

InstallTar()
{
	# PACKAGE="tar-1.35";

	ExtractPackage	"${PDIR}${TempPackages[tar]}.tar.xz"	"${PDIR}";

	ConfigureTar;
	InstallPackageTar;

	# EchoInfo	"Testing ${TempPackages[tar]}";
	# ValidateTar;
}

ConfigureTar()
{
	if ! cd "${PDIR}${TempPackages[tar]}"; then
		return ;
	fi

	EchoInfo	"Configuring ${TempPackages[tar]}...";
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null

	cd -;
}

InstallPackageTar()
{
	if ! cd "${PDIR}${TempPackages[tar]}"; then
		return ;
	fi

	EchoInfo	"Compiling ${TempPackages[tar]}...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${TempPackages[tar]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing ${TempPackages[tar]}...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${TempPackages[tar]} && PressAnyKeyToContinue; return;};

	cd -;
}

ValidateTar()
{
	# PACKAGE="tar-1.35";
	if ! cd "${PDIR}${TempPackages[tar]}"; then
		return ;
	fi

	RunMakeCheckTest	"${TempPackages[tar]}";

	cd -;
}

# =====================================||===================================== #
#									  Xz									   #
# ===============ft_linux==============||==============©Othello=============== #

TempPackages[xz]="xz-5.6.2";

InstallXz()
{
	# PACKAGE="xz-5.6.2";

	ExtractPackage	"${PDIR}${TempPackages[xz]}.tar.xz"	"${PDIR}";

	ConfigureXz;
	InstallPackageXz;

	# EchoInfo	"Testing ${TempPackages[xz]}";
	# ValidateXz;
}

ConfigureXz()
{
	if ! cd "${PDIR}${TempPackages[xz]}"; then
		return ;
	fi

	EchoInfo	"Configuring ${TempPackages[xz]}...";
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
	if ! cd "${PDIR}${TempPackages[xz]}"; then
		return ;
	fi

	EchoInfo	"Compiling ${TempPackages[xz]}...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${TempPackages[xz]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing ${TempPackages[xz]}...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${TempPackages[xz]} && PressAnyKeyToContinue; return;};

	# Remove the libtool archive file because it is harmful for cross compilation
	rm -v $LFS/usr/lib/liblzma.la

	cd -;
}

ValidateXz()
{
	# PACKAGE="xz-5.6.2";
	if ! cd "${PDIR}${TempPackages[xz]}"; then
		return ;
	fi

	RunMakeCheckTest	"${TempPackages[xz]}";

	cd -;
}

# =====================================||===================================== #
#								 BinutilsPass2								   #
# ===============ft_linux==============||==============©Othello=============== #

TempPackages[binutils]="binutils-2.43.1";

InstallBinutilsPass2()
{
	# PACKAGE="binutils-2.43.1";

	# rm -rf binutils-2.43.1;

	ExtractPackage	"${PDIR}${TempPackages[binutils]}.tar.xz"	"${PDIR}";

	if ! mkdir -pv "${PDIR}${TempPackages[binutils]}/build"; then
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
	if [ -f "${PDIR}${TempPackages[binutils]}/ltmain.sh" ]; then
		sed '6009s/$add_dir//' -i ${PDIR}${TempPackages[binutils]}/ltmain.sh
	else
		EchoError	"Script ${TempPackages[binutils]}/ltmain.sh not found...";
		return ;
	fi

	if ! cd "${PDIR}${TempPackages[binutils]}/build"; then
		return ;
	fi

	EchoInfo	"Configuring ${TempPackages[binutils]}...";
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
	if ! cd "${PDIR}${TempPackages[binutils]}/build"; then
		return ;
	fi

	EchoInfo	"Compiling ${TempPackages[binutils]}...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${TempPackages[binutils]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing ${TempPackages[binutils]}...";
	echo		"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${TempPackages[binutils]} && PressAnyKeyToContinue; return;};

	# Remove the libtool archive files because they are harmful for cross compilation, and remove unnecessary static libraries
	rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}

	cd -;
}

ValidateBinutilsPass2()
{
	# PACKAGE="binutils-2.43.1";
	if ! cd "${PDIR}${TempPackages[binutils]}/build"; then
		return ;
	fi

	RunMakeCheckTest	"${TempPackages[binutils]}";

	cd -;
}

# =====================================||===================================== #
#									GccPass2								   #
# ===============ft_linux==============||==============©Othello=============== #

TempPackages[gcc]="gcc-14.2.0";

InstallGccPass2()
{
	# PACKAGE="gcc-14.2.0";

	if ! ExtracPackagesGccPass2; then
		return ;
	fi

	if ! mkdir -pv "${PDIR}${TempPackages[gcc]}/build"; then
		echo	"${C_RED}Error($?)${C_RESET}: Failed to make build directory.";
		return ;
	fi

	ConfigureGccPass2;
	InstallPackageGccPass2;

	# EchoInfo	"Testing $PACKAGE";
	# ValidateGccPass2;
}

ExtracPackagesGccPass2()
{
	ExtractPackage	"${PDIR}${TempPackages[gcc]}.tar.xz"	"${PDIR}";

	# PACKNAME="mpfr-4.2.1";
	ExtractPackage	"${PDIR}mpfr-4.2.1.tar.xz"	"${PDIR}";
	mv -fv "${PDIR}mpfr-4.2.1" "${PDIR}${TempPackages[gcc]}/mpfr";

	# PACKNAME="gmp-6.3.0";
	ExtractPackage	"${PDIR}gmp-6.3.0.tar.xz"	"${PDIR}";
	mv -fv "${PDIR}gmp-6.3.0" "${PDIR}${TempPackages[gcc]}/gmp";

	# PACKNAME="mpc-1.3.1.tar.gz";
	ExtractPackage	"${PDIR}mpc-1.3.1.tar.gz"	"${PDIR}";
	mv -fv "${PDIR}mpc-1.3.1" "${PDIR}${TempPackages[gcc]}/mpc";

	if	[ ! -d "${PDIR}${TempPackages[gcc]}" ] ||
		[ ! -d "${PDIR}${TempPackages[gcc]}/mpfr" ] ||
		[ ! -d "${PDIR}${TempPackages[gcc]}/gmp" ] ||
		[ ! -d "${PDIR}${TempPackages[gcc]}/mpc" ]; then
		EchoError	"Failed to unpack a package for gcc{mpfr, gmp, mpc}...";
		return false;
	fi
	return true;
}

ConfigureGccPass2()
{
	if ! cd "${PDIR}${TempPackages[gcc]}/build"; then
		return ;
	fi

	EchoInfo	"Configuring ${TempPackages[gcc]}...";
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
	if ! cd "${PDIR}${TempPackages[gcc]}/build"; then
		return ;
	fi

	EchoInfo	"Compiling ${TempPackages[gcc]}...";
	echo		"${C_DGRAY}> make 1> /dev/null${C_RESET}";
	time make 1> /dev/null || {EchoTest KO ${TempPackages[gcc]} && PressAnyKeyToContinue; return;};

	EchoInfo	"Installing ${TempPackages[gcc]}...";
	echo		"${C_DGRAY}> make DESTDIR=$LFS install 1> /dev/null${C_RESET}";
	time make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${TempPackages[gcc]} && PressAnyKeyToContinue; return;};

	# Create a utility symlink to cc
	ln -sv gcc $LFS/usr/bin/cc

	cd -;
}

ValidateGccPass2()
{
	# PACKAGE="gcc-14.2.0";
	if ! cd "${PDIR}${TempPackages[gcc]}/build"; then
		return ;
	fi

	RunMakeCheckTest	"${TempPackages[gcc]}";

	cd -;
}

# =====================================||===================================== #
#																			   #
#								  Install All								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

if [ "$1" = "InstallAll" ]; then
	InstallPackages && \
	InstallBinutilsPass2 && \
	InstallGccPass2 && \
	RemoveAllPackages || \
	{EchoError "Chapter 6 failed" && PressAnyKeyToContinue};

	exit $?;
fi

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
		q|Q)	RemoveAllPackages;
				exit 0;;
		*)		MSG="${C_RED}Invalid input${C_RESET}: $input";
				PRESSTOCONTINUE=false;;
	esac

	$PRESSTOCONTINUE && PressAnyKeyToContinue;
done
