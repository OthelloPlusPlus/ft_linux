#! /bin/bash

source Utils.sh

# =====================================||===================================== #
#																			   #
#									Functions								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

ReExtractPackage()
{
	local SRC="${1}${2}${3}";
	local DST="${1}";
	local RSLT="${1}${2}";

	# EchoInfo	"$SRC";
	# EchoInfo	"$DST";
	# EchoInfo	"$RSLT";
	# EchoInfo	"validate input"; PressAnyKeyToContinue;
	if [ ! -f "$SRC" ] || [ ! -d "$DST" ]; then
		EchoError	"ReExtractPackage SRC[$SRC] DST[$DST]";
		# return false;
		return 1;
	fi
	
	# EchoInfo	"remove old"; PressAnyKeyToContinue;
	if [ -d "$RSLT" ]; then
		# echo "removing old"; PressAnyKeyToContinue;
		rm -rf "$RSLT";
	fi
	
	# EchoInfo	"extract new"; PressAnyKeyToContinue
	tar -xf "$SRC" -C "$DST" || { echo "Failed to extract $?" >&2 && PressAnyKeyToContinue; };
	# PressAnyKeyToContinue;

}

RemovePackageDirectories()
{
	while read -r checksum filename; do
	    dirname=$(echo "$filename" | sed -E 's/\.(tar\.(gz|xz|bz2)|patch)$//')
		if [ -d $PDIR/$dirname ]; then
			rm -r $PDIR/$dirname;
		fi
	done < $PDIR/md5sums
}

# =====================================||===================================== #
#									Temp									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A Packagetemp;
Packagetemp[Name]="Temp";
Packagetemp[Version]="";
Packagetemp[Package]="${Packagetemp[Name]}-${Packagetemp[Version]}";
Packagetemp[Extension]=".tar.xz";

InstallTemp()
{
	EchoInfo	"Package ${Packagetemp[Name]}"

	ReExtractPackage	"${PDIR}"	"${Packagetemp[Package]}"	"${Packagetemp[Extension]}";

	if ! cd "${PDIR}${Packagetemp[Package]}"; then
		EchoError	"cd ${PDIR}${Packagetemp[Package]}";
		return;
	fi

	EchoInfo	"${Packagetemp[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${Packagetemp[Name]}> make"
	make  1> /dev/null || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${Packagetemp[Name]}> make check"
	make check 1> /dev/null || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${Packagetemp[Name]}> make install"
	make install 1> /dev/null && Packagetemp[Status]=$? || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return; };

	# if ! mkdir -p build; then
	# 	Packagetemp[Status]=1; 
	# 	EchoError	"Failed to make ${PDIR}${Packagetemp[Name]}/build";
	# 	return ;
	# fi
	# cd "${PDIR}${Packagetemp[Package]}/build";
}

# =====================================||===================================== #
#																			   #
#									Packages								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

# =====================================||===================================== #
#									Binutils								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageBinutils;
PackageBinutils[Name]="binutils";
PackageBinutils[Version]="2.43.1";
PackageBinutils[Package]="${PackageBinutils[Name]}-${PackageBinutils[Version]}";
PackageBinutils[Extension]=".tar.xz";

InstallBinutils_CT1()
{
	EchoInfo	"Package ${PackageBinutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBinutils[Package]}"	"${PackageBinutils[Extension]}";

	if ! cd "${PDIR}${PackageBinutils[Package]}"; then
		EchoError	"cd ${PDIR}${PackageBinutils[Package]}";
		return;
	fi

	if ! mkdir -p build; then
		PackageBinutils[Status]=1; 
		EchoError	"Failed to make ${PDIR}${PackageBinutils[Name]}/build";
		return ;
	fi
	cd "${PDIR}${PackageBinutils[Package]}/build";

	EchoInfo	"${PackageBinutils[Name]}> Configure"
	../configure	--prefix=$LFS/tools	\
					--with-sysroot=$LFS	\
					--target=$LFS_TGT	\
					--disable-nls		\
					--enable-gprofng=no	\
					--disable-werror	\
					--enable-new-dtags	\
					--enable-default-hash-style=gnu	\
					1> /dev/null || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBinutils[Name]}> make"
	make  1> /dev/null || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBinutils[Name]}> make check"
	make check 1> /dev/null || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageBinutils[Name]}> make install"
	make install 1> /dev/null && PackageBinutils[Status]=$? || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return; };
}

InstallBinutils_TT2()
{
	EchoInfo	"Package ${PackageBinutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBinutils[Package]}"	"${PackageBinutils[Extension]}";

	if ! cd "${PDIR}${PackageBinutils[Package]}"; then
		EchoError	"cd ${PDIR}${PackageBinutils[Package]}";
		return;
	fi

	EchoInfo	"${PackageBinutils[Name]}> Prevent binaries mistakenly linked against libraries from the host distro"
	if [ -f "${PDIR}${PackageBinutils[Package]}/ltmain.sh" ]; then
		sed '6009s/$add_dir//' -i ${PDIR}${PackageBinutils[Package]}/ltmain.sh
	else
		EchoError	"${PackageBinutils[Name]}> Script ${PackageBinutils[Package]}/ltmain.sh not found...";
		return ;
	fi

	if ! mkdir -p build; then
		PackageBinutils[Status]=1; 
		EchoError	"Failed to make ${PDIR}${PackageBinutils[Name]}/build";
		return ;
	fi
	cd "${PDIR}${PackageBinutils[Package]}/build";

	EchoInfo	"${PackageBinutils[Name]}> Configure"
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
					1> /dev/null || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBinutils[Name]}> make"
	make  1> /dev/null || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBinutils[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageBinutils[Status]=$? || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return; };

	# Remove the libtool archive files because they are harmful for cross compilation, and remove unnecessary static libraries
	EchoInfo	"${PackageBinutils[Name]}> Remove the libtool archive files"
	rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}
}

# =====================================||===================================== #
#									  GCC									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGCC;
PackageGCC[Name]="gcc";
PackageGCC[Version]="14.2.0";
PackageGCC[Package]="${PackageGCC[Name]}-${PackageGCC[Version]}";
PackageGCC[Extension]=".tar.xz";

InstallGCC_CT1()
{
	EchoInfo	"Package ${PackageGCC[Name]}";
	GCCExtract;

	if ! cd "${PDIR}${PackageGCC[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGCC[Package]}";
		return;
	fi

	case $(uname -m) in
		x86_64) sed -e '/m64=/s/lib64/lib/' \
					-i.orig "${PDIR}${PackageGCC[package]}/gcc/config/i386/t-linux64";;
	esac

	if ! mkdir -p build; then
		PackageGCC[Status]=1; 
		EchoError	"Failed to make ${PDIR}${PackageGCC[Name]}/build";
		return ;
	fi
	cd "${PDIR}${PackageGCC[Name]}-${PackageGCC[Version]}/build";

	EchoInfo	"${PackageGCC[Name]}> Configure"
	../configure	--target=$LFS_TGT	\
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
					1> /dev/null || { PackageGCC[Status]=$?; EchoTest KO ${PackageGCC[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGCC[Name]}> make"
	make  1> /dev/null || { PackageGCC[Status]=$?; EchoTest KO ${PackageGCC[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGCC[Name]}> make install"
	make install 1> /dev/null && PackageGCC[Status]=$? || { PackageGCC[Status]=$?; EchoTest KO ${PackageGCC[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGCC[Name]}> Copying header files..."
	cat ${PDIR}${PackageGCC[Package]}/gcc/limitx.h \
		${PDIR}${PackageGCC[Package]}/gcc/glimits.h \
		${PDIR}${PackageGCC[Package]}/gcc/limity.h \
		> $(dirname $($LFS_TGT-gcc -print-libgcc-file-name))/include/limits.h
}

InstallGCC_TT2()
{
	EchoInfo	"Package ${PackageGCC[Name]}";
	GCCExtract;

	if ! cd "${PDIR}${PackageGCC[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGCC[Package]}";
		return;
	fi

	case $(uname -m) in
		x86_64)	EchoInfo	"${PackageGCC[Name]}> Changing default directory name for 64-bit libraries to \"lib\"";
				sed	-e '/m64=/s/lib64/lib/' \
					-i.orig gcc/config/i386/t-linux64;;
	esac

	EchoInfo	"${PackageGCC[Name]}> Overriding building rule of libgcc and libstdc++ headers"
	sed	'/thread_header =/s/@.*@/gthr-posix.h/' \
		-i libgcc/Makefile.in libstdc++-v3/include/Makefile.in;

	if ! mkdir -p build; then
		PackageGCC[Status]=1; 
		EchoError	"Failed to make ${PDIR}${PackageGCC[Name]}/build";
		return ;
	fi
	cd "${PDIR}${PackageGCC[Package]}/build";

	EchoInfo	"${PackageGCC[Name]}> Configure"
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
					1> /dev/null || { PackageGCC[Status]=$?; EchoTest KO ${PackageGCC[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGCC[Name]}> make"
	make  1> /dev/null || { PackageGCC[Status]=$?; EchoTest KO ${PackageGCC[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGCC[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageGCC[Status]=$? || { PackageGCC[Status]=$?; EchoTest KO ${PackageGCC[Name]} && PressAnyKeyToContinue; return; };

	# Create a utility symlink to cc
	EchoInfo	"${PackageGCC[Name]}> Create a utility symlink to cc"
	ln -sv gcc $LFS/usr/bin/cc
}

GCCExtract()
{
	ReExtractPackage	"${PDIR}"	"${PackageGCC[Package]}"	"${PackageGCC[Extension]}";
	ReExtractPackage	"${PDIR}"	"mpfr-4.2.1"				".tar.xz";
	ReExtractPackage	"${PDIR}"	"gmp-6.3.0"					".tar.xz";
	ReExtractPackage	"${PDIR}"	"mpc-1.3.1"					".tar.gz";
	# mv ${PDIR}{mpfr-4.2.1,gmp-6.3.0,mpc-1.3.1}	"${PDIR}/${PackageGCC[Package]}/";
	mv ${PDIR}mpfr-4.2.1 	"${PDIR}/${PackageGCC[Package]}/mpfr";
	mv ${PDIR}gmp-6.3.0 	"${PDIR}/${PackageGCC[Package]}/gmp";
	mv ${PDIR}mpc-1.3.1 	"${PDIR}/${PackageGCC[Package]}/mpc";
}

# =====================================||===================================== #
#								Linux API Headers							   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLinuxAPI;
PackageLinuxAPI[Name]="linux";
PackageLinuxAPI[Version]="6.10.5";
PackageLinuxAPI[Package]="${PackageGCC[Name]}-${PackageGCC[Version]}";
PackageLinuxAPI[Extension]=".tar.xz";

InstallLinuxAPI_CT()
{
	EchoInfo	"Package ${PackageLinuxAPI[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLinuxAPI[Name]}-${PackageLinuxAPI[Version]}"	"${PackageLinuxAPI[Extension]}";

	if ! cd "${PDIR}${PackageLinuxAPI[Name]}-${PackageLinuxAPI[Version]}"; then
		EchoError	"cd ${PDIR}${PackageLinuxAPI[Name]}-${PackageLinuxAPI[Version]}";
		return;
	fi

	EchoInfo	"${PackageLinuxAPI[Name]}> make mrproper"
	make mrproper 1> /dev/null || { PackageLinuxAPI[Status]=$?; EchoTest KO ${PackageLinuxAPI[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLinuxAPI[Name]}> make headers"
	make headers 1> /dev/null && PackageLinuxAPI[Status]=$? || { PackageLinuxAPI[Status]=$?; EchoTest KO ${PackageLinuxAPI[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageLinuxAPI[Name]}> Copying headers to $LFS/usr/include...";
	find usr/include -type f ! -name '*.h' -delete
	echo	"${C_DGRAY}> cp -rv usr/include $LFS/usr 1> /dev/null${C_RESET}";
	cp -rv usr/include $LFS/usr 1> /dev/null
}

# =====================================||===================================== #
#									  Glibc									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGlibc;
PackageGlibc[Name]="glibc";
PackageGlibc[Version]="2.40";
PackageGlibc[Package]="${PackageGlibc[Name]}-${PackageGlibc[Version]}";
PackageGlibc[Extension]=".tar.xz";

InstallGlibc_CT()
{
	EchoInfo	"Package ${PackageGlibc[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGlibc[Package]}"	"${PackageGlibc[Extension]}";

	if ! cd "${PDIR}${PackageGlibc[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGlibc[Package]}";
		return;
	fi

	case $(uname -m) in
		i?86)	ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3;;
		x86_64)	ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64;
				ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3;;
	esac

	EchoInfo	"${PackageGlibc[Name]}> Patch"
	patch -Np1 -i ../glibc-2.40-fhs-1.patch;

	if ! mkdir -p build; then
		PackageGlibc[Status]=1; 
		EchoError	"Failed to make ${PDIR}${PackageGlibc[Name]}/build";
		return ;
	fi
	cd "${PDIR}${PackageGlibc[Package]}/build";

	EchoInfo	"${PackageGlibc[Name]}> Configure"
	../configure	--prefix=/usr	\
					--host=$LFS_TGT	\
					--build=$(../scripts/config.guess)	\
					--enable-kernel=4.19	\
					--with-headers=$LFS/usr/include	\
					--disable-nscd	\
					libc_cv_slibdir=/usr/lib	\
					1> /dev/null 1> /dev/null || { PackageGlibc[Status]=$?; EchoTest KO ${PackageGlibc[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGlibc[Name]}> make"
	make  1> /dev/null || { PackageGlibc[Status]=$?; EchoTest KO ${PackageGlibc[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGlibc[Name]}> make install"
	if [ "$(whoami)" != "root" ] && [ -n "$LFS" ]; then
		echo	"${C_DGRAY}> make DESTDIR=$LFS install 1> /dev/null${C_RESET}";
		make DESTDIR=$LFS install 1> /dev/null || { EchoTest KO ${glibc[package]} && PressAnyKeyToContinue; return;};
	else
		EchoError "${PackageGlibc[Name]}> Almost made build unstable with glibc!";
		PressAnyKeyToContinue;
		return 1;
	fi

	EchoInfo	"${PackageGlibc[Name]}> Fixing hardcoded path...";
	sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
}

SanityCheckGlibc()
{
	echo 'int main(){}' | $LFS_TGT-gcc -xc - -o gcctest.out
	if [ -f "gcctest.out" ]; then
		readelf -l gcctest.out | grep ld-linux
		if [ $? -eq 0 ]; then
			PackageGlibc[status]=true;
		else
			EchoError "${PackageGlibc[Name]}> Failed ($?) to test 'int main(){}'";
			PackageGlibc[status]=false;
			PressAnyKeyToContinue;
			exit;
		fi
		rm gcctest.out
	else
		PackageGlibc[status]=false;
		EchoError "${PackageGlibc[Name]}> Failed to compile 'int main(){}'";
		PressAnyKeyToContinue;
		exit;
	fi
}

InstallGlibc()
{
	EchoInfo	"Package ${PackageGlibc[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGlibc[Package]}"	"${PackageGlibc[Extension]}";

	if ! cd "${PDIR}${PackageGlibc[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGlibc[Package]}";
		return;
	fi

	EchoInfo	"${PackageGlibc[Name]} patching..."
	patch -Np1 -i ../glibc-2.40-fhs-1.patch

	if ! mkdir -p build; then
		PackageGlibc[Status]=1;
		EchoError	"Failed to make ${PDIR}${PackageGlibc[Name]}/build";
		return ;
	fi
	cd "${PDIR}${PackageGlibc[Package]}/build";

	InstallGlibcInstall;
	InstallGlibcConfigure;
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
#									libstdcpp								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibstdCPP;
PackageLibstdCPP[Name]="libstdc++";
PackageLibstdCPP[Version]="";
PackageLibstdCPP[Package]="${PackageGCC[Package]}";
PackageLibstdCPP[Extension]="${PackageGCC[Extension]}";

InstallLibstdCPP_CT()
{
	EchoInfo	"Package ${PackageLibstdCPP[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLibstdCPP[Package]}"	"${PackageLibstdCPP[Extension]}";

	if ! cd "${PDIR}${PackageLibstdCPP[Package]}"; then
		EchoError	"cd ${PDIR}${PackageLibstdCPP[Package]}";
		return;
	fi

	if ! mkdir -p build; then
		PackageLibstdCPP[Status]=1; 
		EchoError	"Failed to make ${PDIR}${PackageLibstdCPP[Name]}/build";
		return ;
	fi
	cd "${PDIR}${PackageLibstdCPP[Package]}/build";

	EchoInfo	"${PackageLibstdCPP[Name]}> Configure"
	../libstdc++-v3/configure	--host=$LFS_TGT	\
								--build=$(../config.guess)	\
								--prefix=/usr	\
								--disable-multilib	\
								--disable-nls	\
								--disable-libstdcxx-pch	\
								--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/14.2.0	\
								1> /dev/null 1> /dev/null || { PackageLibstdCPP[Status]=$?; EchoTest KO ${PackageLibstdCPP[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLibstdCPP[Name]}> make"
	make  1> /dev/null || { PackageLibstdCPP[Status]=$?; EchoTest KO ${PackageLibstdCPP[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLibstdCPP[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageLibstdCPP[Status]=$? || { PackageLibstdCPP[Status]=$?; EchoTest KO ${PackageLibstdCPP[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLibstdCPP[Name]}> Removing libtool archive files...";
	echo	"${C_DGRAY}(they are harmful for cross-compilation)${C_RESET}";
	rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la
}

# =====================================||===================================== #
#									  M4									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageM4;
PackageM4[Name]="m4";
PackageM4[Version]="1.4.19";
PackageM4[Package]="${PackageM4[Name]}-${PackageM4[Version]}";
PackageM4[Extension]=".tar.xz";

InstallM4_TT()
{
	EchoInfo	"Package ${PackageM4[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageM4[Package]}"	"${PackageM4[Extension]}";

	if ! cd "${PDIR}${PackageM4[Package]}"; then
		EchoError	"cd ${PDIR}${PackageM4[Package]}";
		return;
	fi

	EchoInfo	"${PackageM4[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null 1> /dev/null || { PackageM4[Status]=$?; EchoTest KO ${PackageM4[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageM4[Name]}> make"
	make  1> /dev/null || { PackageM4[Status]=$?; EchoTest KO ${PackageM4[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageM4[Name]}> make check"
	make check 1> /dev/null || { PackageM4[Status]=$?; EchoTest KO ${PackageM4[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageM4[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageM4[Status]=$? || { PackageM4[Status]=$?; EchoTest KO ${PackageM4[Name]} && PressAnyKeyToContinue; return; };
}

# =====================================||===================================== #
#									Ncurses									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageNcurses;
PackageNcurses[Name]="ncurses";
PackageNcurses[Version]="6.5";
PackageNcurses[Package]="${PackageNcurses[Name]}-${PackageNcurses[Version]}";
PackageNcurses[Extension]=".tar.gz";

InstallNcurses_TT()
{
	EchoInfo	"Package ${PackageNcurses[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageNcurses[Package]}"	"${PackageNcurses[Extension]}";

	if ! cd "${PDIR}${PackageNcurses[Package]}"; then
		EchoError	"cd ${PDIR}${PackageNcurses[Package]}";
		return;
	fi

	if ! mkdir -p build; then
		PackageNcurses[Status]=1; 
		EchoError	"Failed to make ${PDIR}${PackageNcurses[Name]}/build";
		return ;
	fi

	sed -i s/mawk// configure;

	EchoInfo	"${PackageNcurses[Name]}> Buidling tic program";
	pushd build
		../configure	1> /dev/null
		make -C include	1> /dev/null
		make -C progs tic	1> /dev/null
	popd

	EchoInfo	"${PackageNcurses[Name]}> Configure"
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
				1> /dev/null || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageNcurses[Name]}> make"
	make  1> /dev/null || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageNcurses[Name]}> make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install"
	make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install 1> /dev/null && PackageNcurses[Status]=$? || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageNcurses[Name]}> Configuring libncurses library...";
	# symlink to use libncursesw.so
	ln -sv libncursesw.so $LFS/usr/lib/libncurses.so;
	# Edit the header file so it will always use the wide-character data structure definition compatible with libncursesw.so.
	sed -e 's/^#if.*XOPEN.*$/#if 1/' \
		-i $LFS/usr/include/curses.h;
}

# =====================================||===================================== #
#									  Bash									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageBash;
PackageBash[Name]="bash";
PackageBash[Version]="5.2.32";
PackageBash[Package]="${PackageBash[Name]}-${PackageBash[Version]}";
PackageBash[Extension]=".tar.gz";

InstallBash_TT()
{
	EchoInfo	"Package ${PackageBash[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBash[Package]}"	"${PackageBash[Extension]}";

	if ! cd "${PDIR}${PackageBash[Package]}"; then
		EchoError	"cd ${PDIR}${PackageBash[Package]}";
		return;
	fi

	EchoInfo	"${PackageBash[Name]}> Configure"
	./configure	--prefix=/usr	\
				--build=$(sh support/config.guess) \
				--host=$LFS_TGT	\
				--without-bash-malloc	\
				bash_cv_strtold_broken=no	\
				1>/dev/null || { PackageBash[Status]=$?; EchoTest KO ${PackageBash[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBash[Name]}> make"
	make  1> /dev/null || { PackageBash[Status]=$?; EchoTest KO ${PackageBash[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBash[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageBash[Status]=$? || { PackageBash[Status]=$?; EchoTest KO ${PackageBash[Name]} && PressAnyKeyToContinue; return; };

	# Link for the programs that use sh for a shell
	ln -sv bash $LFS/bin/sh
}

# =====================================||===================================== #
#								   Coreutils								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageCoreutils;
PackageCoreutils[Name]="coreutils";
PackageCoreutils[Version]="9.5";
PackageCoreutils[Package]="${PackageCoreutils[Name]}-${PackageCoreutils[Version]}";
PackageCoreutils[Extension]=".tar.xz";

InstallCoreutils_TT()
{
	EchoInfo	"Package ${PackageCoreutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageCoreutils[Package]}"	"${PackageCoreutils[Extension]}";

	if ! cd "${PDIR}${PackageCoreutils[Package]}"; then
		EchoError	"cd ${PDIR}${PackageCoreutils[Package]}";
		return;
	fi

	EchoInfo	"${PackageCoreutils[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				--enable-install-program=hostname	\
				--enable-no-install-program=kill,uptime	\
				1> /dev/null || { PackageCoreutils[Status]=$?; EchoTest KO ${PackageCoreutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageCoreutils[Name]}> make"
	make  1> /dev/null || { PackageCoreutils[Status]=$?; EchoTest KO ${PackageCoreutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageCoreutils[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageCoreutils[Status]=$? || { PackageCoreutils[Status]=$?; EchoTest KO ${PackageCoreutils[Name]} && PressAnyKeyToContinue; return; };

	# Move programs to their final expected locations
	EchoInfo	"${PackageCoreutils[Name]}> Move programs to their final expected locations"
	mv -v $LFS/usr/bin/chroot 				$LFS/usr/sbin
	mkdir -pv $LFS/usr/share/man/man8
	mv -v $LFS/usr/share/man/man1/chroot.1 	$LFS/usr/share/man/man8/chroot.8
	sed -i 's/"1"/"8"/' 					$LFS/usr/share/man/man8/chroot.8
}

# =====================================||===================================== #
#								   Diffutils								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageDiffutils;
PackageDiffutils[Name]="diffutils";
PackageDiffutils[Version]="3.10";
PackageDiffutils[Package]="${PackageDiffutils[Name]}-${PackageDiffutils[Version]}";
PackageDiffutils[Extension]=".tar.xz";

InstallDiffutils_TT()
{
	EchoInfo	"Package ${PackageDiffutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageDiffutils[Package]}"	"${PackageDiffutils[Extension]}";

	if ! cd "${PDIR}${PackageDiffutils[Package]}"; then
		EchoError	"cd ${PDIR}${PackageDiffutils[Package]}";
		return;
	fi

	EchoInfo	"${PackageDiffutils[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(./build-aux/config.guess)	\
				1> /dev/null || { PackageDiffutils[Status]=$?; EchoTest KO ${PackageDiffutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageDiffutils[Name]}> make"
	make  1> /dev/null || { PackageDiffutils[Status]=$?; EchoTest KO ${PackageDiffutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageDiffutils[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageDiffutils[Status]=$? || { PackageDiffutils[Status]=$?; EchoTest KO ${PackageDiffutils[Name]} && PressAnyKeyToContinue; return; };
}

# =====================================||===================================== #
#									  File									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageFile;
PackageFile[Name]="file";
PackageFile[Version]="5.45";
PackageFile[Package]="${PackageFile[Name]}-${PackageFile[Version]}";
PackageFile[Extension]=".tar.gz";

InstallFile_TT()
{
	EchoInfo	"Package ${PackageFile[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageFile[Package]}"	"${PackageFile[Extension]}";

	if ! cd "${PDIR}${PackageFile[Package]}"; then
		EchoError	"cd ${PDIR}${PackageFile[Package]}";
		return;
	fi

	if ! mkdir -p build; then
		PackageFile[Status]=1; 
		EchoError	"Failed to make ${PDIR}${PackageFile[Name]}/build";
		return ;
	fi

	EchoInfo	"${PackageFile[Name]}> Making temporary copy of the file command";
	pushd build
		../configure	--disable-bzlib	\
						--disable-libseccomp \
						--disable-xzlib	\
						--disable-zlib	\
						1> /dev/null
		make	 1> /dev/null
	popd

	EchoInfo	"${PackageFile[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(./config.guess)	\
				1> /dev/null || { PackageFile[Status]=$?; EchoTest KO ${PackageFile[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageFile[Name]}> make FILE_COMPILE=$(pwd)/build/src/file"
	make FILE_COMPILE=$(pwd)/build/src/file 1> /dev/null || { PackageFile[Status]=$?; EchoTest KO ${PackageFile[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageFile[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageFile[Status]=$? || { PackageFile[Status]=$?; EchoTest KO ${PackageFile[Name]} && PressAnyKeyToContinue; return; };

	# Remove the libtool archive file because it is harmful for cross compilation
	EchoInfo	"${PackageFile[Name]}> Remove the libtool archive file"
	rm -v $LFS/usr/lib/libmagic.la
}

# =====================================||===================================== #
#								   Findutils								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageFindutils;
PackageFindutils[Name]="findutils";
PackageFindutils[Version]="4.10.0";
PackageFindutils[Package]="${PackageFindutils[Name]}-${PackageFindutils[Version]}";
PackageFindutils[Extension]=".tar.xz";

InstallFindutils_TT()
{
	EchoInfo	"Package ${PackageFindutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageFindutils[Package]}"	"${PackageFindutils[Extension]}";

	if ! cd "${PDIR}${PackageFindutils[Package]}"; then
		EchoError	"cd ${PDIR}${PackageFindutils[Package]}";
		return;
	fi

	EchoInfo	"${PackageFindutils[Name]}> Configure"
	./configure	--prefix=/usr	\
				--localstatedir=/var/lib/locate	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null || { PackageFindutils[Status]=$?; EchoTest KO ${PackageFindutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageFindutils[Name]}> make"
	make  1> /dev/null || { PackageFindutils[Status]=$?; EchoTest KO ${PackageFindutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageFindutils[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageFindutils[Status]=$? || { PackageFindutils[Status]=$?; EchoTest KO ${PackageFindutils[Name]} && PressAnyKeyToContinue; return; };
}

# =====================================||===================================== #
#									  Gawk									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGawk;
PackageGawk[Name]="gawk";
PackageGawk[Version]="5.3.0";
PackageGawk[Package]="${PackageGawk[Name]}-${PackageGawk[Version]}";
PackageGawk[Extension]=".tar.xz";

InstallGawk_TT()
{
	EchoInfo	"Package ${PackageGawk[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGawk[Package]}"	"${PackageGawk[Extension]}";

	if ! cd "${PDIR}${PackageGawk[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGawk[Package]}";
		return;
	fi

	EchoInfo	"${PackageGawk[Name]}> Configure"
	# Ensure some unneeded files are not installed
	sed -i 's/extras//' Makefile.in
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null || { PackageGawk[Status]=$?; EchoTest KO ${PackageGawk[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGawk[Name]}> make"
	make  1> /dev/null || { PackageGawk[Status]=$?; EchoTest KO ${PackageGawk[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGawk[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageGawk[Status]=$? || { PackageGawk[Status]=$?; EchoTest KO ${PackageGawk[Name]} && PressAnyKeyToContinue; return; };

}

# =====================================||===================================== #
#									  Grep									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGrep;
PackageGrep[Name]="grep";
PackageGrep[Version]="3.11";
PackageGrep[Package]="${PackageGrep[Name]}-${PackageGrep[Version]}";
PackageGrep[Extension]=".tar.xz";

InstallGrep_TT()
{
	EchoInfo	"Package ${PackageGrep[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGrep[Package]}"	"${PackageGrep[Extension]}";

	if ! cd "${PDIR}${PackageGrep[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGrep[Package]}";
		return;
	fi

	EchoInfo	"${PackageGrep[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(./build-aux/config.guess)	\
				1> /dev/null || { PackageGrep[Status]=$?; EchoTest KO ${PackageGrep[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGrep[Name]}> make"
	make  1> /dev/null || { PackageGrep[Status]=$?; EchoTest KO ${PackageGrep[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGrep[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageGrep[Status]=$? || { PackageGrep[Status]=$?; EchoTest KO ${PackageGrep[Name]} && PressAnyKeyToContinue; return; };
}

# =====================================||===================================== #
#									  Gzip									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGzip;
PackageGzip[Name]="gzip";
PackageGzip[Version]="1.13";
PackageGzip[Package]="${PackageGzip[Name]}-${PackageGzip[Version]}";
PackageGzip[Extension]=".tar.xz";

InstallGzip_TT()
{
	EchoInfo	"Package ${PackageGzip[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGzip[Package]}"	"${PackageGzip[Extension]}";

	if ! cd "${PDIR}${PackageGzip[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGzip[Package]}";
		return;
	fi

	EchoInfo	"${PackageGzip[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				1> /dev/null || { PackageGzip[Status]=$?; EchoTest KO ${PackageGzip[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGzip[Name]}> make"
	make  1> /dev/null || { PackageGzip[Status]=$?; EchoTest KO ${PackageGzip[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGzip[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageGzip[Status]=$? || { PackageGzip[Status]=$?; EchoTest KO ${PackageGzip[Name]} && PressAnyKeyToContinue; return; };
}

# =====================================||===================================== #
#									  Make									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMake;
PackageMake[Name]="make";
PackageMake[Version]="4.4.1";
PackageMake[Package]="${PackageMake[Name]}-${PackageMake[Version]}";
PackageMake[Extension]=".tar.gz";

InstallMake_TT()
{
	EchoInfo	"Package ${PackageMake[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageMake[Package]}"	"${PackageMake[Extension]}";

	if ! cd "${PDIR}${PackageMake[Package]}"; then
		EchoError	"cd ${PDIR}${PackageMake[Package]}";
		return;
	fi

	EchoInfo	"${PackageMake[Name]}> Configure"
	./configure	--prefix=/usr	\
				--without-guile	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null || { PackageMake[Status]=$?; EchoTest KO ${PackageMake[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageMake[Name]}> make"
	make  1> /dev/null || { PackageMake[Status]=$?; EchoTest KO ${PackageMake[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageMake[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageMake[Status]=$? || { PackageMake[Status]=$?; EchoTest KO ${PackageMake[Name]} && PressAnyKeyToContinue; return; };
}

# =====================================||===================================== #
#									 Patch									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePatch;
PackagePatch[Name]="patch";
PackagePatch[Version]="2.7.6";
PackagePatch[Package]="${PackagePatch[Name]}-${PackagePatch[Version]}";
PackagePatch[Extension]=".tar.xz";

InstallPatch_TT()
{
	EchoInfo	"Package ${PackagePatch[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackagePatch[Package]}"	"${PackagePatch[Extension]}";

	if ! cd "${PDIR}${PackagePatch[Package]}"; then
		EchoError	"cd ${PDIR}${PackagePatch[Package]}";
		return;
	fi

	EchoInfo	"${PackagePatch[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null || { PackagePatch[Status]=$?; EchoTest KO ${PackagePatch[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackagePatch[Name]}> make"
	make  1> /dev/null || { PackagePatch[Status]=$?; EchoTest KO ${PackagePatch[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackagePatch[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackagePatch[Status]=$? || { PackagePatch[Status]=$?; EchoTest KO ${PackagePatch[Name]} && PressAnyKeyToContinue; return; };
}

# =====================================||===================================== #
#									  Sed									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageSed;
PackageSed[Name]="sed";
PackageSed[Version]="4.9";
PackageSed[Package]="${PackageSed[Name]}-${PackageSed[Version]}";
PackageSed[Extension]=".tar.xz";

InstallSed_TT()
{
	EchoInfo	"Package ${PackageSed[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageSed[Package]}"	"${PackageSed[Extension]}";

	if ! cd "${PDIR}${PackageSed[Package]}"; then
		EchoError	"cd ${PDIR}${PackageSed[Package]}";
		return;
	fi

	EchoInfo	"${PackageSed[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(./build-aux/config.guess)	\
				1> /dev/null || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageSed[Name]}> make"
	make  1> /dev/null || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageSed[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageSed[Status]=$? || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return; };
}

# =====================================||===================================== #
#									  Tar									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageTar;
PackageTar[Name]="tar";
PackageTar[Version]="1.35";
PackageTar[Package]="${PackageTar[Name]}-${PackageTar[Version]}";
PackageTar[Extension]=".tar.xz";

InstallTar_TT()
{
	EchoInfo	"Package ${PackageTar[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageTar[Package]}"	"${PackageTar[Extension]}";

	if ! cd "${PDIR}${PackageTar[Package]}"; then
		EchoError	"cd ${PDIR}${PackageTar[Package]}";
		return;
	fi

	EchoInfo	"${PackageTar[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null || { PackageTar[Status]=$?; EchoTest KO ${PackageTar[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageTar[Name]}> make"
	make  1> /dev/null || { PackageTar[Status]=$?; EchoTest KO ${PackageTar[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageTar[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageTar[Status]=$? || { PackageTar[Status]=$?; EchoTest KO ${PackageTar[Name]} && PressAnyKeyToContinue; return; };
}

# =====================================||===================================== #
#									   Xz									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXz;
PackageXz[Name]="xz";
PackageXz[Version]="5.6.2";
PackageXz[Package]="${PackageXz[Name]}-${PackageXz[Version]}";
PackageXz[Extension]=".tar.xz";

InstallXz_TT()
{
	EchoInfo	"Package ${PackageXz[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageXz[Package]}"	"${PackageXz[Extension]}";

	if ! cd "${PDIR}${PackageXz[Package]}"; then
		EchoError	"cd ${PDIR}${PackageXz[Package]}";
		return;
	fi

	EchoInfo	"${PackageXz[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				--disable-static	\
				--docdir=/usr/share/doc/xz-5.6.2	\
				1> /dev/null || { PackageXz[Status]=$?; EchoTest KO ${PackageXz[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageXz[Name]}> make"
	make  1> /dev/null || { PackageXz[Status]=$?; EchoTest KO ${PackageXz[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageXz[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageXz[Status]=$? || { PackageXz[Status]=$?; EchoTest KO ${PackageXz[Name]} && PressAnyKeyToContinue; return; };

	# Remove the libtool archive file because it is harmful for cross compilation
	EchoInfo	"${PackageXz[Name]}> Remove the libtool archive file"
	rm -v $LFS/usr/lib/liblzma.la
}

# =====================================||===================================== #
#									Gettext									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGettext;
PackageGettext[Name]="gettext";
PackageGettext[Version]="0.22.5";
PackageGettext[Package]="${PackageGettext[Name]}-${PackageGettext[Version]}";
PackageGettext[Extension]=".tar.xz";

InstallGettext_TT()
{
	EchoInfo	"Package ${PackageGettext[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGettext[Package]}"	"${PackageGettext[Extension]}";

	if ! cd "${PDIR}${PackageGettext[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGettext[Package]}";
		return;
	fi

	EchoInfo	"${PackageGettext[Name]}> Configure"
	./configure --disable-shared 1> /dev/null || { PackageGettext[Status]=$?; EchoTest KO ${PackageGettext[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGettext[Name]}> make"
	make  1> /dev/null && PackageGettext[Status]=$? || { PackageGettext[Status]=$?; EchoTest KO ${PackageGettext[Name]} && PressAnyKeyToContinue; return; };

	cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
}

# =====================================||===================================== #
#									 Bison									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageBison;
PackageBison[Name]="bison";
PackageBison[Version]="3.8.2";
PackageBison[Package]="${PackageBison[Name]}-${PackageBison[Version]}";
PackageBison[Extension]=".tar.xz";

InstallBison_TT()
{
	EchoInfo	"Package ${PackageBison[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBison[Package]}"	"${PackageBison[Extension]}";

	if ! cd "${PDIR}${PackageBison[Package]}"; then
		EchoError	"cd ${PDIR}${PackageBison[Package]}";
		return;
	fi

	EchoInfo	"${PackageBison[Name]}> Configure"
	./configure --prefix=/usr \
				--docdir=/usr/share/doc/bison-3.8.2 \
				1> /dev/null || { PackageBison[Status]=$?; EchoTest KO ${PackageBison[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBison[Name]}> make"
	make  1> /dev/null || { PackageBison[Status]=$?; EchoTest KO ${PackageBison[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBison[Name]}> make install"
	make install 1> /dev/null && PackageBison[Status]=$? || { PackageBison[Status]=$?; EchoTest KO ${PackageBison[Name]} && PressAnyKeyToContinue; return; };
}

# =====================================||===================================== #
#									  Perl									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePerl;
PackagePerl[Name]="perl";
PackagePerl[Version]="5.40.0";
PackagePerl[Package]="${PackagePerl[Name]}-${PackagePerl[Version]}";
PackagePerl[Extension]=".tar.xz";

InstallPerl_TT()
{
	EchoInfo	"Package ${PackagePerl[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackagePerl[Package]}"	"${PackagePerl[Extension]}";

	if ! cd "${PDIR}${PackagePerl[Package]}"; then
		EchoError	"cd ${PDIR}${PackagePerl[Package]}";
		return;
	fi

	EchoInfo	"${PackagePerl[Name]}> Configure"
	sh Configure 	-des \
					-D prefix=/usr \
					-D vendorprefix=/usr \
					-D useshrplib \
					-D privlib=/usr/lib/perl5/5.40/core_perl \
					-D archlib=/usr/lib/perl5/5.40/core_perl \
					-D sitelib=/usr/lib/perl5/5.40/site_perl \
					-D sitearch=/usr/lib/perl5/5.40/site_perl \
					-D vendorlib=/usr/lib/perl5/5.40/vendor_perl \
					-D vendorarch=/usr/lib/perl5/5.40/vendor_perl \
					1> /dev/null || { PackagePerl[Status]=$?; EchoTest KO ${PackagePerl[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackagePerl[Name]}> make"
	make  1> /dev/null || { PackagePerl[Status]=$?; EchoTest KO ${PackagePerl[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackagePerl[Name]}> make install"
	make install 1> /dev/null && PackagePerl[Status]=$? || { PackagePerl[Status]=$?; EchoTest KO ${PackagePerl[Name]} && PressAnyKeyToContinue; return; };
}

# =====================================||===================================== #
#									Python									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePython;
PackagePython[Name]="Python";
PackagePython[Version]="3.12.5";
PackagePython[Package]="${PackagePython[Name]}-${PackagePython[Version]}";
PackagePython[Extension]=".tar.xz";

InstallPython_TT()
{
	EchoInfo	"Package ${PackagePython[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackagePython[Package]}"	"${PackagePython[Extension]}";

	if ! cd "${PDIR}${PackagePython[Package]}"; then
		EchoError	"cd ${PDIR}${PackagePython[Package]}";
		return;
	fi

	EchoInfo	"${PackagePython[Name]}> Configure"
	./configure --prefix=/usr \
				--enable-shared \
				--without-ensurepip \
				1> /dev/null || { PackagePython[Status]=$?; EchoTest KO ${PackagePython[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackagePython[Name]}> make"
	make  1> /dev/null || { PackagePython[Status]=$?; EchoTest KO ${PackagePython[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackagePython[Name]}> make install"
	make install 1> /dev/null && PackagePython[Status]=$? || { PackagePython[Status]=$?; EchoTest KO ${PackagePython[Name]} && PressAnyKeyToContinue; return; };
}

# =====================================||===================================== #
#									Texinfo									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageTexinfo;
PackageTexinfo[Name]="texinfo";
PackageTexinfo[Version]="7.1";
PackageTexinfo[Package]="${PackageTexinfo[Name]}-${PackageTexinfo[Version]}";
PackageTexinfo[Extension]=".tar.xz";

InstallTexinfo_TT()
{
	EchoInfo	"Package ${PackageTexinfo[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageTexinfo[Package]}"	"${PackageTexinfo[Extension]}";

	if ! cd "${PDIR}${PackageTexinfo[Package]}"; then
		EchoError	"cd ${PDIR}${PackageTexinfo[Package]}";
		return;
	fi

	EchoInfo	"${PackageTexinfo[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { PackageTexinfo[Status]=$?; EchoTest KO ${PackageTexinfo[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageTexinfo[Name]}> make"
	make  1> /dev/null || { PackageTexinfo[Status]=$?; EchoTest KO ${PackageTexinfo[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageTexinfo[Name]}> make install"
	make install 1> /dev/null && PackageTexinfo[Status]=$? || { PackageTexinfo[Status]=$?; EchoTest KO ${PackageTexinfo[Name]} && PressAnyKeyToContinue; return; };
}

# =====================================||===================================== #
#								   UtilLinux								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageUtilLinux;
PackageUtilLinux[Name]="util-linux";
PackageUtilLinux[Version]="2.40.2";
PackageUtilLinux[Package]="${PackageUtilLinux[Name]}-${PackageUtilLinux[Version]}";
PackageUtilLinux[Extension]=".tar.xz";

InstallUtilLinux_TT()
{
	EchoInfo	"Package ${PackageUtilLinux[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageUtilLinux[Package]}"	"${PackageUtilLinux[Extension]}";

	if ! cd "${PDIR}${PackageUtilLinux[Package]}"; then
		EchoError	"cd ${PDIR}${PackageUtilLinux[Package]}";
		return;
	fi

	EchoInfo	"${PackageUtilLinux[Name]}> Configure"
	./configure --libdir=/usr/lib \
				--runstatedir=/run \
				--disable-chfn-chsh \
				--disable-login \
				--disable-nologin \
				--disable-su \
				--disable-setpriv \
				--disable-runuser \
				--disable-pylibmount \
				--disable-static \
				--disable-liblastlog2 \
				--without-python \
				ADJTIME_PATH=/var/lib/hwclock/adjtime \
				--docdir=/usr/share/doc/util-linux-2.40.2 \
				1> /dev/null || { PackageUtilLinux[Status]=$?; EchoTest KO ${PackageUtilLinux[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageUtilLinux[Name]}> make"
	make  1> /dev/null || { PackageUtilLinux[Status]=$?; EchoTest KO ${PackageUtilLinux[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageUtilLinux[Name]}> make install"
	make install 1> /dev/null && PackageUtilLinux[Status]=$? || { PackageUtilLinux[Status]=$?; EchoTest KO ${PackageUtilLinux[Name]} && PressAnyKeyToContinue; return; };
}

# =====================================||===================================== #
#									  Man									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMan;
PackageMan[Name]="man-pages";
PackageMan[Version]="6.9.1";
PackageMan[Package]="${PackageMan[Name]}-${PackageMan[Version]}";
PackageMan[Extension]=".tar.xz";

InstallMan()
{
	ReExtractPackage	"${PDIR}"	"${PackageMan[Package]}"	"${PackageMan[Extension]}";

	if ! cd "${PDIR}${PackageMan[Package]}"; then
		PackageMan[Status]=1;
		EchoError	"cd ${PDIR}${PackageMan[Package]}";
		return;
	fi

	# Remove two man pages for password hashing functions
	rm -v man3/crypt*

	EchoInfo	"${PackageMan[Name]}> make prefix=/usr install"
	make prefix=/usr install	1> /dev/null;
	PackageMan[Status]=$?;
}

# =====================================||===================================== #
#									Iana-Etc								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageIanaEtc;
PackageIanaEtc[Name]="iana-etc";
PackageIanaEtc[Version]="20240806";
PackageIanaEtc[Package]="${PackageIanaEtc[Name]}-${PackageIanaEtc[Version]}";
PackageIanaEtc[Extension]=".tar.gz";

InstallIanaEtc()
{
	EchoInfo	"Package ${PackageIanaEtc[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageIanaEtc[Package]}"	"${PackageIanaEtc[Extension]}";

	if ! cd "${PDIR}${PackageIanaEtc[Package]}"; then
		PackageIanaEtc[Status]=1;
		EchoError	"cd ${PDIR}${PackageIanaEtc[Package]}";
		return;
	fi

	EchoInfo	"${PackageIanaEtc[Name]}> cp services protocols /etc"
	cp services protocols /etc	1> /dev/null;
	PackageIanaEtc[Status]=$?;
}

# =====================================||===================================== #
#									Zlib									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageZlib;
PackageZlib[Name]="zlib";
PackageZlib[Version]="1.3.1";
PackageZlib[Extension]=".tar.gz";
PackageZlib[Package]="${PackageZlib[Name]}-${PackageZlib[Version]}";

InstallZlib()
{
	EchoInfo	"Package ${PackageZlib[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageZlib[Package]}"	"${PackageZlib[Extension]}";

	if ! cd "${PDIR}${PackageZlib[Package]}"; then
		EchoError	"cd ${PDIR}${PackageZlib[Package]}";
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
}

# =====================================||===================================== #
#									Bzip2									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageBzip2;
PackageBzip2[Name]="bzip2";
PackageBzip2[Version]="1.0.8";
PackageBzip2[Extension]=".tar.gz";
PackageBzip2[Package]="${PackageBzip2[Name]}-${PackageBzip2[Version]}";

InstallBzip2()
{
	EchoInfo	"Package ${PackageBzip2[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBzip2[Package]}"	"${PackageBzip2[Extension]}";

	if ! cd "${PDIR}${PackageBzip2[Package]}"; then
		EchoError	"cd ${PDIR}${PackageBzip2[Package]}";
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
}
