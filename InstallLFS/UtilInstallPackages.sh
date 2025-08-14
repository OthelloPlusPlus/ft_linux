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

# declare -A Packagetemp;
# Packagetemp[Name]="Temp";
# Packagetemp[Version]="";
# Packagetemp[Package]="${Packagetemp[Name]}-${Packagetemp[Version]}";
# Packagetemp[Extension]=".tar.xz";

# InstallTemp()
# {
# 	EchoInfo	"Package ${Packagetemp[Name]}"

# 	ReExtractPackage	"${PDIR}"	"${Packagetemp[Package]}"	"${Packagetemp[Extension]}";

# 	if ! cd "${PDIR}${Packagetemp[Package]}"; then
# 		EchoError	"cd ${PDIR}${Packagetemp[Package]}";
# 		return 1;
# 	fi

# 	EchoInfo	"${Packagetemp[Name]}> Configure"
# 	./configure --prefix=/usr 1> /dev/null || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return 1; };

# 	EchoInfo	"${Packagetemp[Name]}> make"
# 	make  1> /dev/null || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return 1; };

# 	EchoInfo	"${Packagetemp[Name]}> make check"
# 	make check 1> /dev/null || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return 1; };

# 	EchoInfo	"${Packagetemp[Name]}> make install"
# 	make install 1> /dev/null && Packagetemp[Status]=$? || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return 1; };

# 	# if ! mkdir -p build; then
# 	# 	Packagetemp[Status]=1; 
# 	# 	EchoError	"Failed to make ${PDIR}${Packagetemp[Name]}/build";
# 	# 	return ;
# 	# fi
# 	# cd "${PDIR}${Packagetemp[Package]}/build";
# }

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
		return 1;
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
					1> /dev/null || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBinutils[Name]}> make"
	make  1> /dev/null || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBinutils[Name]}> make check"
	make check 1> /dev/null || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBinutils[Name]}> make install"
	make install 1> /dev/null && PackageBinutils[Status]=$? || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return 1; };
}

InstallBinutils_TT2()
{
	EchoInfo	"Package ${PackageBinutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBinutils[Package]}"	"${PackageBinutils[Extension]}";

	if ! cd "${PDIR}${PackageBinutils[Package]}"; then
		EchoError	"cd ${PDIR}${PackageBinutils[Package]}";
		return 1;
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
					1> /dev/null || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBinutils[Name]}> make"
	make  1> /dev/null || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBinutils[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageBinutils[Status]=$? || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return 1; };

	# Remove the libtool archive files because they are harmful for cross compilation, and remove unnecessary static libraries
	EchoInfo	"${PackageBinutils[Name]}> Remove the libtool archive files"
	rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}
}

# 8.20
InstallBinutils()
{
	EchoInfo	"Package ${PackageBinutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBinutils[Name]}-${PackageBinutils[Version]}"	"${PackageBinutils[Extension]}";

	if ! cd "${PDIR}${PackageBinutils[Name]}-${PackageBinutils[Version]}"; then
		EchoError	"cd ${PDIR}${PackageBinutils[Name]}-${PackageBinutils[Version]}";
		return 1;
	fi

	if ! mkdir -p build; then
		PackageBinutils[Status]=1; 
		EchoError	"Failed to make ${PDIR}${PackageBinutils[Name]}/build";
		return ;
	fi
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
					1> /dev/null || { EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBinutils[Name]}> make tooldir=/usr"
	make tooldir=/usr 1> /dev/null || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBinutils[Name]}> make -k check"
	$(make -k check | grep '^FAIL:' $(find -name '*.log') | grep -vE 'gold/testsuite/test-suite.log:FAIL: (weak_undef_test|initpri3a|script_test_1|script_test_2|justsyms|justsyms_exec|binary_test|script_test_3|tls_phdrs_script_test|script_test_12i|incremental_test_2|incremental_test_5)' | wc -l) -gt 0 || echo Error;
	grep '^FAIL:' $(find -name '*.log') | grep -vE 'gold/testsuite/test-suite.log:FAIL: (weak_undef_test|initpri3a|script_test_1|script_test_2|justsyms|justsyms_exec|binary_test|script_test_3|tls_phdrs_script_test|script_test_12i|incremental_test_2|incremental_test_5)'
	make -k check 1> /dev/null || \
		if [ $(grep '^FAIL:' $(find -name '*.log') | grep -vE 'gold/testsuite/test-suite.log:FAIL: (weak_undef_test|initpri3a|script_test_1|script_test_2|justsyms|justsyms_exec|binary_test|script_test_3|tls_phdrs_script_test|script_test_12i|incremental_test_2|incremental_test_5)' | wc -l) -gt 0 ]; then
			PackageBinutils[Status]=$?;
			EchoTest KO ${PackageBinutils[Name]};
			PressAnyKeyToContinue;
			return 1;
		else
			EchoTest OK "${PackageBinutils[Name]} Only the 12 valid errors";
		fi

	EchoInfo	"${PackageBinutils[Name]}> make tooldir=/usr install"
	make tooldir=/usr install 1> /dev/null && PackageBinutils[Status]=$? || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBinutils[Name]}> Remove uselss static libraries";
	rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a;
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
		return 1;
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
					1> /dev/null || { PackageGCC[Status]=$?; EchoTest KO ${PackageGCC[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGCC[Name]}> make"
	make  1> /dev/null || { PackageGCC[Status]=$?; EchoTest KO ${PackageGCC[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGCC[Name]}> make install"
	make install 1> /dev/null && PackageGCC[Status]=$? || { PackageGCC[Status]=$?; EchoTest KO ${PackageGCC[Name]} && PressAnyKeyToContinue; return 1; };

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
		return 1;
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
					1> /dev/null || { PackageGCC[Status]=$?; EchoTest KO ${PackageGCC[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGCC[Name]}> make"
	make  1> /dev/null || { PackageGCC[Status]=$?; EchoTest KO ${PackageGCC[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGCC[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageGCC[Status]=$? || { PackageGCC[Status]=$?; EchoTest KO ${PackageGCC[Name]} && PressAnyKeyToContinue; return 1; };

	# Create a utility symlink to cc
	EchoInfo	"${PackageGCC[Name]}> Create a utility symlink to cc"
	ln -sv gcc $LFS/usr/bin/cc
}

# 8.29
InstallGcc()
{
	EchoInfo	"Package ${PackageGCC[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGCC[Package]}"	"${PackageGCC[Extension]}";

	if ! cd "${PDIR}${PackageGCC[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGCC[Package]}";
		return 1;
	fi

	# Change the default directory name for 64-bit libraries to “lib” for x86_64
	case $(uname -m) in
		x86_64)	sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64;;
	esac

	if ! mkdir -p build; then
		PackageGCC[Status]=1; 
		EchoError	"Failed to make ${PDIR}${PackageGCC[Name]}/build";
		cd -;
		return ;
	fi
	cd "${PDIR}${PackageGCC[Package]}/build";


	EchoInfo	"${PackageGCC[Name]}> Configure"
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
					1> /dev/null || { EchoTest KO ${PackageGCC[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGCC[Name]}> make"
	make  1> /dev/null || { PackageGCC[Status]=$?; EchoTest KO ${PackageGCC[Name]} && PressAnyKeyToContinue; return 1; };

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

	EchoInfo	"${PackageGCC[Name]}> su tester -c \"PATH=$PATH make -k check\"";
	EchoInfo	"${PackageGCC[Name]}> (Takes xx/46 SBU (1:43:27.617))";
	chown -R tester .
	time su tester -c "PATH=$PATH make -k check"
	if [ $(../contrib/test_summary | grep "unexpected" | wc -l) -gt 0 ]; then
		EchoError	"${PackageGCC[Name]}> Unexpected test results:";
		../contrib/test_summary | grep "^FAIL" -B4 -A9;
		if [ $(../contrib/test_summary | grep "^FAIL" | grep -v "/tsan/" | wc -l) -gt 0 ]; then
			PressAnyKeyToContinue ;
			return ;
		else
			EchoInfo	"${PackageGCC[Name]}> tsan errors are ignored.";
		fi
	fi

	EchoInfo	"${PackageGCC[Name]}> make install"
	make install 1> /dev/null && PackageGCC[Status]=$? || { PackageGCC[Status]=$?; EchoTest KO ${PackageGCC[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGCC[Name]}> Change owner to root"
	chown -v -R root:root /usr/lib/gcc/$(gcc -dumpmachine)/14.2.0/include{,-fixed}

	EchoInfo	"${PackageGCC[Name]}> Create symbolic links"
	ln -svr /usr/bin/cpp /usr/lib
	ln -sv gcc.1 /usr/share/man/man1/cc.1
	ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/14.2.0/liblto_plugin.so /usr/lib/bfd-plugins/

	EchoInfo	"${PackageGCC[Name]}> Sanity check"

	echo 'int main(){}' | cc -x c - -v -Wl,--verbose -o gcctest.out &> gcctest.log
	if [ ! -f "gcctest.out" ]; then
		EchoError	"${PackageGCC[Name]}> Failed to create gcctest.out";
		PressAnyKeyToContinue;
		return ;
	fi

	readelf -l gcctest.out | grep "\[Requesting program interpreter: /lib"
	if [ $? -gt 0 ]; then
		EchoError	"${PackageGCC[Name]}> Failed to run gcctest.out";
		PressAnyKeyToContinue;
		return ;
	else
		EchoTest	"OK" "${PackageGCC[Name]} ran succesfully";
	fi

	if [ $(grep -E "crt[1in].* succeeded" gcctest.log -c) -ne 3 ]; then
		EchoError	"${PackageGCC[Name]}> Failed to access crt[1in] libraries";
		grep -E "crt[1in].* failed" gcctest.log;
		PressAnyKeyToContinue;
		return ;
	else
		EchoTest	OK	"crt[1in] libraries accessed"
	fi

	if [ $(grep -A9 "#include *...* search starts here:" gcctest.log | grep -B9 "End of search list." | grep "/usr/.*include" -c ) -lt 4 ]; then
	
		EchoError	"${PackageGCC[Name]}> Compiler fails to search for correct header files";
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
		EchoError	"${PackageGCC[Name]}> Linker is using incorrect search paths";
		echo	"$ActualOutput";
		PressAnyKeyToContinue;
		return ;
	else
		EchoTest	OK	"Correct search paths"
	fi

	if [ $(grep "/lib.*/libc.so.6 succeeded" gcctest.log -c) -ne 1 ]; then
		EchoError	"${PackageGCC[Name]}> Using incorrect libc";
		grep "/lib.*/libc.so.6 succeeded" gcctest.log
		PressAnyKeyToContinue;
		return ;
	else
		EchoTest	OK	"correct libc used"
	fi

	if [ "/usr/lib/$(grep "found" gcctest.log | awk '{print $2}')" != "$(grep "found" gcctest.log | awk '{print $4}')" ]; then
		EchoError	"${PackageGCC[Name]}> Incorrect dynamic linker";
		grep "found" gcctest.log
		PressAnyKeyToContinue;
		return ;
	fi

	rm gcctest.out gcctest.log

	mkdir -pv /usr/share/gdb/auto-load/usr/lib
	if ls /usr/lib/*gdb.py &> /dev/null; then
		mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
	elif ! ls /usr/share/gdb/auto-load/usr/lib/*gdb.py &> /dev/null; then
		EchoError	"${PackageGCC[Name]}> File '*gdb.py' not found";
	fi
}


GCCExtract()
{
	ReExtractPackage	"${PDIR}"	"${PackageGCC[Package]}"	"${PackageGCC[Extension]}";
	ReExtractPackage	"${PDIR}"	"mpfr-4.2.1"				".tar.xz";
	ReExtractPackage	"${PDIR}"	"gmp-6.3.0"					".tar.xz";
	ReExtractPackage	"${PDIR}"	"mpc-1.3.1"					".tar.gz";
	# mv ${PDIR}{mpfr-4.2.1,gmp-6.3.0,mpc-1.3.1}	"${PDIR}/${PackageGCC[Package]}/";
	mv ${PDIR}${PackageMPFR[Package]} 	"${PDIR}/${PackageGCC[Package]}/${PackageMPFR[Name]}";
	mv ${PDIR}${PackageGMP[Package]} 	"${PDIR}/${PackageGCC[Package]}/${PackageGMP[Name]}";
	mv ${PDIR}${PackageMPC[Package]} 	"${PDIR}/${PackageGCC[Package]}/${PackageMPC[Name]}";
}

# =====================================||===================================== #
#								Linux API Headers							   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLinuxAPI;
PackageLinuxAPI[Name]="linux";
PackageLinuxAPI[Version]="6.10.5";
PackageLinuxAPI[Extension]=".tar.xz";
PackageLinuxAPI[Package]="${PackageLinux[Name]}-${PackageLinux[Version]}";

InstallLinuxAPI_CT()
{
	EchoInfo	"Package ${PackageLinuxAPI[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLinuxAPI[Name]}-${PackageLinuxAPI[Version]}"	"${PackageLinuxAPI[Extension]}";

	if ! cd "${PDIR}${PackageLinuxAPI[Name]}-${PackageLinuxAPI[Version]}"; then
		EchoError	"cd ${PDIR}${PackageLinuxAPI[Name]}-${PackageLinuxAPI[Version]}";
		return 1;
	fi

	EchoInfo	"${PackageLinuxAPI[Name]}> make mrproper"
	make mrproper 1> /dev/null || { PackageLinuxAPI[Status]=$?; EchoTest KO ${PackageLinuxAPI[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLinuxAPI[Name]}> make headers"
	make headers 1> /dev/null && PackageLinuxAPI[Status]=$? || { PackageLinuxAPI[Status]=$?; EchoTest KO ${PackageLinuxAPI[Name]} && PressAnyKeyToContinue; return 1; };

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
		return 1;
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
					1> /dev/null 1> /dev/null || { PackageGlibc[Status]=$?; EchoTest KO ${PackageGlibc[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGlibc[Name]}> make"
	make  1> /dev/null || { PackageGlibc[Status]=$?; EchoTest KO ${PackageGlibc[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGlibc[Name]}> make install"
	if [ "$(whoami)" != "root" ] && [ -n "$LFS" ]; then
		echo	"${C_DGRAY}> make DESTDIR=$LFS install 1> /dev/null${C_RESET}";
		make DESTDIR=$LFS install 1> /dev/null || { EchoTest KO ${glibc[package]} && PressAnyKeyToContinue; return 1;};
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

# 8.5
InstallGlibc()
{
	EchoInfo	"Package ${PackageGlibc[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGlibc[Package]}"	"${PackageGlibc[Extension]}";

	if ! cd "${PDIR}${PackageGlibc[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGlibc[Package]}";
		return 1;
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
	../configure	--prefix=/usr \
					--disable-werror \
					--enable-kernel=4.19 \
					--enable-stack-protector=strong \
					--disable-nscd \
					libc_cv_slibdir=/usr/lib \
					1> /dev/null || { PackageGlibc[Status]=$?; EchoError "Issues with glibc configure"; PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGlibc[Name]}> Compile"
	make 1> /dev/null || { PackageGlibc[Status]=$?; EchoTest KO ${PackageGlibc[Name]}; PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGlibc[Name]}> Check"
	# make test t=nptl/tst-thread_local1.o || { EchoError "$?"; PressAnyKeyToContinue; };
	make check 1> /dev/null || { EchoError "Check the errors. Ctrl+C if crucial! ($?)"; }; EchoInfo "Check the test or ctrl C!"; PressAnyKeyToContinue; 

	# Prevent harmless warning
	touch /etc/ld.so.conf

	# Fix the Makefile to skip an outdated sanity check that fails with a modern Glibc configuration
	sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

	EchoInfo	"${PackageGlibc[Name]}> Install"
	make install 1> /dev/null && PackageGlibc[Status]=$? || { PackageGlibc[Status]=$?; EchoTest KO ${PackageGlibc[Name]}; PressAnyKeyToContinue; return 1; };

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
		return 1;
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
								1> /dev/null 1> /dev/null || { PackageLibstdCPP[Status]=$?; EchoTest KO ${PackageLibstdCPP[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibstdCPP[Name]}> make"
	make  1> /dev/null || { PackageLibstdCPP[Status]=$?; EchoTest KO ${PackageLibstdCPP[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibstdCPP[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageLibstdCPP[Status]=$? || { PackageLibstdCPP[Status]=$?; EchoTest KO ${PackageLibstdCPP[Name]} && PressAnyKeyToContinue; return 1; };

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
		return 1;
	fi

	EchoInfo	"${PackageM4[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null 1> /dev/null || { PackageM4[Status]=$?; EchoTest KO ${PackageM4[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageM4[Name]}> make"
	make  1> /dev/null || { PackageM4[Status]=$?; EchoTest KO ${PackageM4[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageM4[Name]}> make check"
	make check 1> /dev/null || { PackageM4[Status]=$?; EchoTest KO ${PackageM4[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageM4[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageM4[Status]=$? || { PackageM4[Status]=$?; EchoTest KO ${PackageM4[Name]} && PressAnyKeyToContinue; return 1; };
}

# 8.13
InstallM4()
{
	EchoInfo	"Package ${PackageM4[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageM4[Package]}"	"${PackageM4[Extension]}";

	if ! cd "${PDIR}${PackageM4[Package]}"; then
		EchoError	"cd ${PDIR}${PackageM4[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageM4[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageM4[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageM4[Name]}> make"
	make  1> /dev/null || { PackageM4[Status]=$?; EchoTest KO ${PackageM4[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageM4[Name]}> make check"
	make check 1> /dev/null || { PackageM4[Status]=$?; EchoTest KO ${PackageM4[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageM4[Name]}> make install"
	make install 1> /dev/null && PackageM4[Status]=$? || { PackageM4[Status]=$?; EchoTest KO ${PackageM4[Name]} && PressAnyKeyToContinue; return 1; };
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
		return 1;
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
				1> /dev/null || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNcurses[Name]}> make"
	make  1> /dev/null || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNcurses[Name]}> make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install"
	make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install 1> /dev/null && PackageNcurses[Status]=$? || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNcurses[Name]}> Configuring libncurses library...";
	# symlink to use libncursesw.so
	ln -sv libncursesw.so $LFS/usr/lib/libncurses.so;
	# Edit the header file so it will always use the wide-character data structure definition compatible with libncursesw.so.
	sed -e 's/^#if.*XOPEN.*$/#if 1/' \
		-i $LFS/usr/include/curses.h;
}

# 8.30
InstallNcurses()
{
	EchoInfo	"Package ${PackageNcurses[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageNcurses[Package]}"	"${PackageNcurses[Extension]}";

	if ! cd "${PDIR}${PackageNcurses[Package]}"; then
		EchoError	"cd ${PDIR}${PackageNcurses[Package]}";
		return 1;
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
				1> /dev/null || { EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNcurses[Name]}> make"
	make  1> /dev/null || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNcurses[Name]}> make DESTDIR=\$PWD/dest install"
	make DESTDIR=$PWD/dest install 1> /dev/null || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return 1; };
	install -vm755 dest/usr/lib/libncursesw.so.6.5 /usr/lib 1> /dev/null && PackageNcurses[Status]=$? || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return 1; };
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
	make distclean 1> /dev/null || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return 1; };
	EchoInfo	"${PackageNcurses[Name]}> configure"
	./configure --prefix=/usr \
				--with-shared \
				--without-normal \
				--without-debug \
				--without-cxx-binding \
				--with-abi-version=5 \
				 1> /dev/null || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return 1; };
	EchoInfo	"${PackageNcurses[Name]}> make sources libs"
	make sources libs 1> /dev/null && PackageNcurses[Status]=$? || { PackageNcurses[Status]=$?; EchoTest KO ${PackageNcurses[Name]} && PressAnyKeyToContinue; return 1; };
	cp -av lib/lib*.so.5* /usr/lib

	EchoInfo	"${PackageNcurses[Name]}> Ncurses Testing is done manually:"
	if [ "$Width" -lt 42 ]; then
		local LineWidth=$((Width-2));
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
}

# =====================================||===================================== #
#									  Bash									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageBash;
PackageBash[Name]="bash";
PackageBash[Version]="5.2.32";
PackageBash[Extension]=".tar.gz";
PackageBash[Package]="${PackageBash[Name]}-${PackageBash[Version]}";

InstallBash_TT()
{
	EchoInfo	"Package ${PackageBash[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBash[Package]}"	"${PackageBash[Extension]}";

	if ! cd "${PDIR}${PackageBash[Package]}"; then
		EchoError	"cd ${PDIR}${PackageBash[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageBash[Name]}> Configure"
	./configure	--prefix=/usr	\
				--build=$(sh support/config.guess) \
				--host=$LFS_TGT	\
				--without-bash-malloc	\
				bash_cv_strtold_broken=no	\
				1>/dev/null || { PackageBash[Status]=$?; EchoTest KO ${PackageBash[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBash[Name]}> make"
	make  1> /dev/null || { PackageBash[Status]=$?; EchoTest KO ${PackageBash[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBash[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageBash[Status]=$? || { PackageBash[Status]=$?; EchoTest KO ${PackageBash[Name]} && PressAnyKeyToContinue; return 1; };

	# Link for the programs that use sh for a shell
	ln -sv bash $LFS/bin/sh
}

# 8.36
InstallBash()
{
	EchoInfo	"Package ${PackageBash[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBash[Package]}"	"${PackageBash[Extension]}";

	if ! cd "${PDIR}${PackageBash[Package]}"; then
		EchoError	"cd ${PDIR}${PackageBash[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageBash[Name]}> Configure"
	./configure --prefix=/usr \
				--without-bash-malloc \
				--with-installed-readline \
				bash_cv_strtold_broken=no \
				--docdir=/usr/share/doc/bash-5.2.32 \
				1> /dev/null || { EchoTest KO ${PackageBash[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBash[Name]}> make"
	make  1> /dev/null || { PackageBash[Status]=$?; EchoTest KO ${PackageBash[Name]} && PressAnyKeyToContinue; return 1; };

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
) || { PackageBash[Status]=$?; EchoTest KO ${PackageBash[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBash[Name]}> make install"
	make install 1> /dev/null && PackageBash[Status]=$? || { PackageBash[Status]=$?; EchoTest KO ${PackageBash[Name]} && PressAnyKeyToContinue; return 1; };

	echo
	echo $BASH_VERSION;
	bash --version | grep "bash";

	cd -;

	EchoInfo	"${PackageBash[Name]}> Please run the following command outside of the script"
	printf	"${CB_BLACK}> %s ${C_RESET}\n"	"exec /usr/bin/bash --login"
	PressAnyKeyToContinue;
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
		return 1;
	fi

	EchoInfo	"${PackageCoreutils[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				--enable-install-program=hostname	\
				--enable-no-install-program=kill,uptime	\
				1> /dev/null || { PackageCoreutils[Status]=$?; EchoTest KO ${PackageCoreutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCoreutils[Name]}> make"
	make  1> /dev/null || { PackageCoreutils[Status]=$?; EchoTest KO ${PackageCoreutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCoreutils[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageCoreutils[Status]=$? || { PackageCoreutils[Status]=$?; EchoTest KO ${PackageCoreutils[Name]} && PressAnyKeyToContinue; return 1; };

	# Move programs to their final expected locations
	EchoInfo	"${PackageCoreutils[Name]}> Move programs to their final expected locations"
	mv -v $LFS/usr/bin/chroot 				$LFS/usr/sbin
	mkdir -pv $LFS/usr/share/man/man8
	mv -v $LFS/usr/share/man/man1/chroot.1 	$LFS/usr/share/man/man8/chroot.8
	sed -i 's/"1"/"8"/' 					$LFS/usr/share/man/man8/chroot.8
}

# 8.58
InstallCoreutils()
{
	EchoInfo	"Package ${PackageCoreutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageCoreutils[Package]}"	"${PackageCoreutils[Extension]}";

	if ! cd "${PDIR}${PackageCoreutils[Package]}"; then
		EchoError	"cd ${PDIR}${PackageCoreutils[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageCoreutils[Name]}> Patch"
	patch -Np1 -i ../coreutils-9.5-i18n-2.patch 1> /dev/null

	EchoInfo	"${PackageCoreutils[Name]}> Configure"
	autoreconf -fiv 1> /dev/null
	FORCE_UNSAFE_CONFIGURE=1 ./configure 	--prefix=/usr \
											--enable-no-install-program=kill,uptime \
											1> /dev/null || { EchoTest KO ${PackageCoreutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCoreutils[Name]}> make"
	make  1> /dev/null || { PackageCoreutils[Status]=$?; EchoTest KO ${PackageCoreutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCoreutils[Name]}> make NON_ROOT_USERNAME=tester check-root"
	make NON_ROOT_USERNAME=tester check-root 1> /dev/null || { PackageCoreutils[Status]=$?; EchoTest KO ${PackageCoreutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCoreutils[Name]}> make test (as tester in dummy group)"
	groupadd -g 102 dummy -U tester
	chown -R tester .
	su tester -c "PATH=$PATH make -k RUN_EXPENSIVE_TESTS=yes check" \
		< /dev/null 1> /dev/null
	groupdel dummy

	EchoInfo	"${PackageCoreutils[Name]}> make install"
	make install 1> /dev/null && PackageCoreutils[Status]=$? || { PackageCoreutils[Status]=$?; EchoTest KO ${PackageCoreutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCoreutils[Name]}> Move programs"
	mv -v /usr/bin/chroot /usr/sbin
	mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
	sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
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
		return 1;
	fi

	EchoInfo	"${PackageDiffutils[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(./build-aux/config.guess)	\
				1> /dev/null || { PackageDiffutils[Status]=$?; EchoTest KO ${PackageDiffutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDiffutils[Name]}> make"
	make  1> /dev/null || { PackageDiffutils[Status]=$?; EchoTest KO ${PackageDiffutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDiffutils[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageDiffutils[Status]=$? || { PackageDiffutils[Status]=$?; EchoTest KO ${PackageDiffutils[Name]} && PressAnyKeyToContinue; return 1; };
}

# 8.60
InstallDiffutils()
{
	EchoInfo	"Package ${PackageDiffutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageDiffutils[Package]}"	"${PackageDiffutils[Extension]}";

	if ! cd "${PDIR}${PackageDiffutils[Package]}"; then
		EchoError	"cd ${PDIR}${PackageDiffutils[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageDiffutils[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageDiffutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDiffutils[Name]}> make"
	make  1> /dev/null || { PackageDiffutils[Status]=$?; EchoTest KO ${PackageDiffutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDiffutils[Name]}> make check"
	make check 1> /dev/null || { PackageDiffutils[Status]=$?; EchoTest KO ${PackageDiffutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDiffutils[Name]}> make install"
	make install 1> /dev/null && PackageDiffutils[Status]=$? || { PackageDiffutils[Status]=$?; EchoTest KO ${PackageDiffutils[Name]} && PressAnyKeyToContinue; return 1; };
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
		return 1;
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
				1> /dev/null || { PackageFile[Status]=$?; EchoTest KO ${PackageFile[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFile[Name]}> make FILE_COMPILE=$(pwd)/build/src/file"
	make FILE_COMPILE=$(pwd)/build/src/file 1> /dev/null || { PackageFile[Status]=$?; EchoTest KO ${PackageFile[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFile[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageFile[Status]=$? || { PackageFile[Status]=$?; EchoTest KO ${PackageFile[Name]} && PressAnyKeyToContinue; return 1; };

	# Remove the libtool archive file because it is harmful for cross compilation
	EchoInfo	"${PackageFile[Name]}> Remove the libtool archive file"
	rm -v $LFS/usr/lib/libmagic.la
}

# 8.11
InstallFile()
{
	EchoInfo	"Package ${PackageFile[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageFile[Package]}"	"${PackageFile[Extension]}";

	if ! cd "${PDIR}${PackageFile[Package]}"; then
		EchoError	"cd ${PDIR}${PackageFile[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageFile[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageFile[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFile[Name]}> make"
	make  1> /dev/null || { PackageFile[Status]=$?; EchoTest KO ${PackageFile[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFile[Name]}> make check"
	make check 1> /dev/null || { PackageFile[Status]=$?; EchoTest KO ${PackageFile[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFile[Name]}> make install"
	make install 1> /dev/null && PackageFile[Status]=$? || { PackageFile[Status]=$?; EchoTest KO ${PackageFile[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#								   Findutils								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageFindutils;
PackageFindutils[Name]="findutils";
PackageFindutils[Version]="4.10.0";
PackageFindutils[Extension]=".tar.xz";
PackageFindutils[Package]="${PackageFindutils[Name]}-${PackageFindutils[Version]}";

InstallFindutils_TT()
{
	EchoInfo	"Package ${PackageFindutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageFindutils[Package]}"	"${PackageFindutils[Extension]}";

	if ! cd "${PDIR}${PackageFindutils[Package]}"; then
		EchoError	"cd ${PDIR}${PackageFindutils[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageFindutils[Name]}> Configure"
	./configure	--prefix=/usr	\
				--localstatedir=/var/lib/locate	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null || { PackageFindutils[Status]=$?; EchoTest KO ${PackageFindutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFindutils[Name]}> make"
	make  1> /dev/null || { PackageFindutils[Status]=$?; EchoTest KO ${PackageFindutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFindutils[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageFindutils[Status]=$? || { PackageFindutils[Status]=$?; EchoTest KO ${PackageFindutils[Name]} && PressAnyKeyToContinue; return 1; };
}

# 8.62
InstallFindutils()
{
	EchoInfo	"Package ${PackageFindutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageFindutils[Package]}"	"${PackageFindutils[Extension]}";

	if ! cd "${PDIR}${PackageFindutils[Package]}"; then
		EchoError	"cd ${PDIR}${PackageFindutils[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageFindutils[Name]}> Configure"
	./configure --prefix=/usr \
				--localstatedir=/var/lib/locate \
				1> /dev/null || { EchoTest KO ${PackageFindutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFindutils[Name]}> make"
	make  1> /dev/null || { PackageFindutils[Status]=$?; EchoTest KO ${PackageFindutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFindutils[Name]}> su tester -c \"PATH=\$PATH make check\""
	chown -R tester .
	su tester -c "PATH=$PATH make check" 1> /dev/null || { PackageFindutils[Status]=$?; EchoTest KO ${PackageFindutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFindutils[Name]}> make install"
	make install 1> /dev/null && PackageFindutils[Status]=$? || { PackageFindutils[Status]=$?; EchoTest KO ${PackageFindutils[Name]} && PressAnyKeyToContinue; return 1; };
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
		return 1;
	fi

	EchoInfo	"${PackageGawk[Name]}> Configure"
	# Ensure some unneeded files are not installed
	sed -i 's/extras//' Makefile.in
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null || { PackageGawk[Status]=$?; EchoTest KO ${PackageGawk[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGawk[Name]}> make"
	make  1> /dev/null || { PackageGawk[Status]=$?; EchoTest KO ${PackageGawk[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGawk[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageGawk[Status]=$? || { PackageGawk[Status]=$?; EchoTest KO ${PackageGawk[Name]} && PressAnyKeyToContinue; return 1; };

}

# 8.61
InstallGawk()
{
	EchoInfo	"Package ${PackageGawk[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGawk[Package]}"	"${PackageGawk[Extension]}";

	if ! cd "${PDIR}${PackageGawk[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGawk[Package]}";
		return 1;
	fi

	sed -i 's/extras//' Makefile.in

	EchoInfo	"${PackageGawk[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageGawk[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGawk[Name]}> make"
	make  1> /dev/null || { PackageGawk[Status]=$?; EchoTest KO ${PackageGawk[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGawk[Name]}> su tester -c \"PATH=$PATH make check\""
	chown -R tester .
	su tester -c "PATH=$PATH make check" 1> /dev/null || { PackageGawk[Status]=$?; EchoTest KO ${PackageGawk[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGawk[Name]}> make install"
	rm -f /usr/bin/gawk-5.3.0
	make install 1> /dev/null && PackageGawk[Status]=$? || { PackageGawk[Status]=$?; EchoTest KO ${PackageGawk[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGawk[Name]}> symlink awk to gawk"
	ln -sv gawk.1 /usr/share/man/man1/awk.1

	EchoInfo	"${PackageGawk[Name]}> install documentation"
	mkdir 	-pv 									/usr/share/doc/gawk-5.3.0
	cp 		-v 	doc/{awkforai.txt,*.{eps,pdf,jpg}} 	/usr/share/doc/gawk-5.3.0 1> /dev/null
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
		return 1;
	fi

	EchoInfo	"${PackageGrep[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(./build-aux/config.guess)	\
				1> /dev/null || { PackageGrep[Status]=$?; EchoTest KO ${PackageGrep[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGrep[Name]}> make"
	make  1> /dev/null || { PackageGrep[Status]=$?; EchoTest KO ${PackageGrep[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGrep[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageGrep[Status]=$? || { PackageGrep[Status]=$?; EchoTest KO ${PackageGrep[Name]} && PressAnyKeyToContinue; return 1; };
}

# 8.35
InstallGrep()
{
	EchoInfo	"Package ${PackageGrep[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGrep[Package]}"	"${PackageGrep[Extension]}";

	if ! cd "${PDIR}${PackageGrep[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGrep[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageGrep[Name]}> Remove warning about egrep and fgrep"
	sed -i "s/echo/#echo/" src/egrep.sh

	EchoInfo	"${PackageGrep[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageGrep[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGrep[Name]}> make"
	make  1> /dev/null || { PackageGrep[Status]=$?; EchoTest KO ${PackageGrep[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGrep[Name]}> make check"
	make check 1> /dev/null || { PackageGrep[Status]=$?; EchoTest KO ${PackageGrep[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGrep[Name]}> make install"
	make install 1> /dev/null && PackageGrep[Status]=$? || { PackageGrep[Status]=$?; EchoTest KO ${PackageGrep[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									  Gzip									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGzip;
PackageGzip[Name]="gzip";
PackageGzip[Version]="1.13";
PackageGzip[Extension]=".tar.xz";
PackageGzip[Package]="${PackageGzip[Name]}-${PackageGzip[Version]}";

InstallGzip_TT()
{
	EchoInfo	"Package ${PackageGzip[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGzip[Package]}"	"${PackageGzip[Extension]}";

	if ! cd "${PDIR}${PackageGzip[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGzip[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageGzip[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				1> /dev/null || { PackageGzip[Status]=$?; EchoTest KO ${PackageGzip[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGzip[Name]}> make"
	make  1> /dev/null || { PackageGzip[Status]=$?; EchoTest KO ${PackageGzip[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGzip[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageGzip[Status]=$? || { PackageGzip[Status]=$?; EchoTest KO ${PackageGzip[Name]} && PressAnyKeyToContinue; return 1; };
}

# 8.65
InstallGzip()
{
	EchoInfo	"Package ${PackageGzip[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGzip[Package]}"	"${PackageGzip[Extension]}";

	if ! cd "${PDIR}${PackageGzip[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGzip[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageGzip[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageGzip[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGzip[Name]}> make"
	make  1> /dev/null || { PackageGzip[Status]=$?; EchoTest KO ${PackageGzip[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGzip[Name]}> make check"
	make check 1> /dev/null || { PackageGzip[Status]=$?; EchoTest KO ${PackageGzip[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGzip[Name]}> make install"
	make install 1> /dev/null && PackageGzip[Status]=$? || { PackageGzip[Status]=$?; EchoTest KO ${PackageGzip[Name]} && PressAnyKeyToContinue; return 1; };
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
		return 1;
	fi

	EchoInfo	"${PackageMake[Name]}> Configure"
	./configure	--prefix=/usr	\
				--without-guile	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null || { PackageMake[Status]=$?; EchoTest KO ${PackageMake[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMake[Name]}> make"
	make  1> /dev/null || { PackageMake[Status]=$?; EchoTest KO ${PackageMake[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMake[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageMake[Status]=$? || { PackageMake[Status]=$?; EchoTest KO ${PackageMake[Name]} && PressAnyKeyToContinue; return 1; };
}

# 8.69
InstallMake()
{
	EchoInfo	"Package ${PackageMake[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageMake[Package]}"	"${PackageMake[Extension]}";

	if ! cd "${PDIR}${PackageMake[Package]}"; then
		EchoError	"cd ${PDIR}${PackageMake[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageMake[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageMake[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMake[Name]}> make"
	make  1> /dev/null || { PackageMake[Status]=$?; EchoTest KO ${PackageMake[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMake[Name]}> su tester -c \"PATH=\$PATH make check\""
	chown -R tester .
	su tester -c "PATH=$PATH make check" 1> /dev/null || { PackageMake[Status]=$?; EchoTest KO ${PackageMake[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMake[Name]}> make install"
	make install 1> /dev/null && PackageMake[Status]=$? || { PackageMake[Status]=$?; EchoTest KO ${PackageMake[Name]} && PressAnyKeyToContinue; return 1; };
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
		return 1;
	fi

	EchoInfo	"${PackagePatch[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null || { PackagePatch[Status]=$?; EchoTest KO ${PackagePatch[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePatch[Name]}> make"
	make  1> /dev/null || { PackagePatch[Status]=$?; EchoTest KO ${PackagePatch[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePatch[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackagePatch[Status]=$? || { PackagePatch[Status]=$?; EchoTest KO ${PackagePatch[Name]} && PressAnyKeyToContinue; return 1; };
}

# 8.70
InstallPatch()
{
	EchoInfo	"Package ${PackagePatch[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackagePatch[Package]}"	"${PackagePatch[Extension]}";

	if ! cd "${PDIR}${PackagePatch[Package]}"; then
		EchoError	"cd ${PDIR}${PackagePatch[Package]}";
		return 1;
	fi

	EchoInfo	"${PackagePatch[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackagePatch[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePatch[Name]}> make"
	make  1> /dev/null || { PackagePatch[Status]=$?; EchoTest KO ${PackagePatch[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePatch[Name]}> make check"
	make check 1> /dev/null || { PackagePatch[Status]=$?; EchoTest KO ${PackagePatch[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePatch[Name]}> make install"
	make install 1> /dev/null && PackagePatch[Status]=$? || { PackagePatch[Status]=$?; EchoTest KO ${PackagePatch[Name]} && PressAnyKeyToContinue; return 1; };
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
		return 1;
	fi

	EchoInfo	"${PackageSed[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(./build-aux/config.guess)	\
				1> /dev/null || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSed[Name]}> make"
	make  1> /dev/null || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSed[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageSed[Status]=$? || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return 1; };
}

# 8.31
InstallSed()
{
	EchoInfo	"Package ${PackageSed[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageSed[Package]}"	"${PackageSed[Extension]}";

	if ! cd "${PDIR}${PackageSed[Package]}"; then
		EchoError	"cd ${PDIR}${PackageSed[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageSed[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSed[Name]}> make"
	make  1> /dev/null || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSed[Name]}> make html"
	make html 1> /dev/null || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSed[Name]}> u tester -c \"PATH=\$PATH make check\""
	chown -R tester .
	su tester -c "PATH=$PATH make check" 1> /dev/null || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSed[Name]}> make install"
	make install 1> /dev/null && PackageSed[Status]=$? || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return 1; };
	install -d -m755 			/usr/share/doc/sed-4.9 1> /dev/null || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return 1; };
	install -m644 doc/sed.html 	/usr/share/doc/sed-4.9 1> /dev/null || { PackageSed[Status]=$?; EchoTest KO ${PackageSed[Name]} && PressAnyKeyToContinue; return 1; };
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
		return 1;
	fi

	EchoInfo	"${PackageTar[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				1> /dev/null || { PackageTar[Status]=$?; EchoTest KO ${PackageTar[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTar[Name]}> make"
	make  1> /dev/null || { PackageTar[Status]=$?; EchoTest KO ${PackageTar[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTar[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageTar[Status]=$? || { PackageTar[Status]=$?; EchoTest KO ${PackageTar[Name]} && PressAnyKeyToContinue; return 1; };
}

# 8.71
InstallTar()
{
	EchoInfo	"Package ${PackageTar[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageTar[Package]}"	"${PackageTar[Extension]}";

	if ! cd "${PDIR}${PackageTar[Package]}"; then
		EchoError	"cd ${PDIR}${PackageTar[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageTar[Name]}> Configure"
	FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageTar[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTar[Name]}> make"
	make  1> /dev/null || { PackageTar[Status]=$?; EchoTest KO ${PackageTar[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTar[Name]}> make check"
	make check > TempMakeCheck.log || \
	if [ $(grep "^[ |0-9].*FAILED " "TempMakeCheck.log" | grep -v "capabilities: binary store/restore" -c) -gt 0 ]; then
		EchoTest KO ${PackageTar[Name]};
		grep "^[ |0-9].*FAILED " "TempMakeCheck.log";
		PackageTar[Status]=$(grep "^[ |0-9].*FAILED " "TempMakeCheck.log" -c);
		PressAnyKeyToContinue;
		return 1;
	else
		EchoTest OK ${PackageTar[Name]};
		grep "^[ |0-9].*FAILED " "TempMakeCheck.log";
		rm TempMakeCheck.log;
	fi

	EchoInfo	"${PackageTar[Name]}> make install"
	make install 1> /dev/null && PackageTar[Status]=$? || { PackageTar[Status]=$?; EchoTest KO ${PackageTar[Name]} && PressAnyKeyToContinue; return 1; };
	make -C doc install-html docdir=/usr/share/doc/tar-1.35 1> /dev/null && PackageTar[Status]=$? || { PackageTar[Status]=$?; EchoTest KO ${PackageTar[Name]} && PressAnyKeyToContinue; return 1; };
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
		return 1;
	fi

	EchoInfo	"${PackageXz[Name]}> Configure"
	./configure	--prefix=/usr	\
				--host=$LFS_TGT	\
				--build=$(build-aux/config.guess)	\
				--disable-static	\
				--docdir=/usr/share/doc/xz-5.6.2	\
				1> /dev/null || { PackageXz[Status]=$?; EchoTest KO ${PackageXz[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXz[Name]}> make"
	make  1> /dev/null || { PackageXz[Status]=$?; EchoTest KO ${PackageXz[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXz[Name]}> make DESTDIR=$LFS install"
	make DESTDIR=$LFS install 1> /dev/null && PackageXz[Status]=$? || { PackageXz[Status]=$?; EchoTest KO ${PackageXz[Name]} && PressAnyKeyToContinue; return 1; };

	# Remove the libtool archive file because it is harmful for cross compilation
	EchoInfo	"${PackageXz[Name]}> Remove the libtool archive file"
	rm -v $LFS/usr/lib/liblzma.la
}

# 8.8
InstallXz()
{
	EchoInfo	"Package ${PackageXz[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageXz[Package]}"	"${PackageXz[Extension]}";

	if ! cd "${PDIR}${PackageXz[Package]}"; then
		EchoError	"cd ${PDIR}${PackageXz[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageXz[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--docdir=/usr/share/doc/xz-5.6.2 \
				1> /dev/null || { EchoTest KO ${PackageXz[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXz[Name]}> make"
	make  1> /dev/null || { PackageXz[Status]=$?; EchoTest KO ${PackageXz[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXz[Name]}> make check"
	make check 1> /dev/null || { PackageXz[Status]=$?; EchoTest KO ${PackageXz[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXz[Name]}> make install"
	make install 1> /dev/null && PackageXz[Status]=$? || { PackageXz[Status]=$?; EchoTest KO ${PackageXz[Name]} && PressAnyKeyToContinue; return 1; };
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
		return 1;
	fi

	EchoInfo	"${PackageGettext[Name]}> Configure"
	./configure --disable-shared 1> /dev/null || { PackageGettext[Status]=$?; EchoTest KO ${PackageGettext[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGettext[Name]}> make"
	make  1> /dev/null && PackageGettext[Status]=$? || { PackageGettext[Status]=$?; EchoTest KO ${PackageGettext[Name]} && PressAnyKeyToContinue; return 1; };

	cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
}

# 8.33
InstallGettext()
{
	EchoInfo	"Package ${PackageGettext[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGettext[Package]}"	"${PackageGettext[Extension]}";

	if ! cd "${PDIR}${PackageGettext[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGettext[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageGettext[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--docdir=/usr/share/doc/gettext-0.22.5 \
				1> /dev/null || { EchoTest KO ${PackageGettext[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGettext[Name]}> make"
	make  1> /dev/null || { PackageGettext[Status]=$?; EchoTest KO ${PackageGettext[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGettext[Name]}> make check"
	make check 1> /dev/null || { PackageGettext[Status]=$?; EchoTest KO ${PackageGettext[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGettext[Name]}> make install"
	make install 1> /dev/null && PackageGettext[Status]=$? || { PackageGettext[Status]=$?; EchoTest KO ${PackageGettext[Name]} && PressAnyKeyToContinue; return 1; };

	chmod -v 0755 /usr/lib/preloadable_libintl.so
}

# =====================================||===================================== #
#									 Bison									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageBison;
PackageBison[Name]="bison";
PackageBison[Version]="3.8.2";
PackageBison[Extension]=".tar.xz";
PackageBison[Package]="${PackageBison[Name]}-${PackageBison[Version]}";

InstallBison_TT()
{
	EchoInfo	"Package ${PackageBison[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBison[Package]}"	"${PackageBison[Extension]}";

	if ! cd "${PDIR}${PackageBison[Package]}"; then
		EchoError	"cd ${PDIR}${PackageBison[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageBison[Name]}> Configure"
	./configure --prefix=/usr \
				--docdir=/usr/share/doc/bison-3.8.2 \
				1> /dev/null || { PackageBison[Status]=$?; EchoTest KO ${PackageBison[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBison[Name]}> make"
	make  1> /dev/null || { PackageBison[Status]=$?; EchoTest KO ${PackageBison[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBison[Name]}> make install"
	make install 1> /dev/null && PackageBison[Status]=$? || { PackageBison[Status]=$?; EchoTest KO ${PackageBison[Name]} && PressAnyKeyToContinue; return 1; };
}

# 8.34
InstallBison()
{
	EchoInfo	"Package ${PackageBison[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBison[Package]}"	"${PackageBison[Extension]}";

	if ! cd "${PDIR}${PackageBison[Package]}"; then
		EchoError	"cd ${PDIR}${PackageBison[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageBison[Name]}> Configure"
	./configure --prefix=/usr \
				--docdir=/usr/share/doc/bison-3.8.2 \
				1> /dev/null || { EchoTest KO ${PackageBison[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBison[Name]}> make"
	make  1> /dev/null || { PackageBison[Status]=$?; EchoTest KO ${PackageBison[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBison[Name]}> make check"
	make check 1> /dev/null || { PackageBison[Status]=$?; EchoTest KO ${PackageBison[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBison[Name]}> make install"
	make install 1> /dev/null && PackageBison[Status]=$? || { PackageBison[Status]=$?; EchoTest KO ${PackageBison[Name]} && PressAnyKeyToContinue; return 1; };
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
		return 1;
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
					1> /dev/null || { PackagePerl[Status]=$?; EchoTest KO ${PackagePerl[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePerl[Name]}> make"
	make  1> /dev/null || { PackagePerl[Status]=$?; EchoTest KO ${PackagePerl[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePerl[Name]}> make install"
	make install 1> /dev/null && PackagePerl[Status]=$? || { PackagePerl[Status]=$?; EchoTest KO ${PackagePerl[Name]} && PressAnyKeyToContinue; return 1; };
}

# 8.43
InstallPerl()
{
	EchoInfo	"Package ${PackagePerl[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackagePerl[Package]}"	"${PackagePerl[Extension]}";

	if ! cd "${PDIR}${PackagePerl[Package]}"; then
		EchoError	"cd ${PDIR}${PackagePerl[Package]}";
		return 1;
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
				1> /dev/null || { EchoTest KO ${PackagePerl[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePerl[Name]}> make"
	make  1> /dev/null || { PackagePerl[Status]=$?; EchoTest KO ${PackagePerl[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePerl[Name]}> TEST_JOBS=\$(nproc) make test_harness"
	TEST_JOBS=$(nproc) make test_harness 1> /dev/null || { PackagePerl[Status]=$?; EchoTest KO ${PackagePerl[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePerl[Name]}> make install"
	make install 1> /dev/null && PackagePerl[Status]=$? || { PackagePerl[Status]=$?; EchoTest KO ${PackagePerl[Name]} && PressAnyKeyToContinue; return 1; };

	unset BUILD_ZLIB BUILD_BZIP2
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
		return 1;
	fi

	EchoInfo	"${PackagePython[Name]}> Configure"
	./configure --prefix=/usr \
				--enable-shared \
				--without-ensurepip \
				1> /dev/null || { PackagePython[Status]=$?; EchoTest KO ${PackagePython[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePython[Name]}> make"
	make  1> /dev/null || { PackagePython[Status]=$?; EchoTest KO ${PackagePython[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePython[Name]}> make install"
	make install 1> /dev/null && PackagePython[Status]=$? || { PackagePython[Status]=$?; EchoTest KO ${PackagePython[Name]} && PressAnyKeyToContinue; return 1; };
}

# 8.52
InstallPython()
{
	EchoInfo	"Package ${PackagePython[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackagePython[Package]}"	"${PackagePython[Extension]}";

	if ! cd "${PDIR}${PackagePython[Package]}"; then
		EchoError	"cd ${PDIR}${PackagePython[Package]}";
		return 1;
	fi

	EchoInfo	"${PackagePython[Name]}> Configure"
	./configure --prefix=/usr \
				--enable-shared \
				--with-system-expat \
				--enable-optimizations \
				1> /dev/null || { EchoTest KO ${PackagePython[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePython[Name]}> make"
	make  1> /dev/null || { PackagePython[Status]=$?; EchoTest KO ${PackagePython[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePython[Name]}> make test TESTOPTS=\"--timeout 120\""
	make test TESTOPTS="--timeout 120" 1> /dev/null || { PackagePython[Status]=$?; EchoTest KO ${PackagePython[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePython[Name]}> make install"
	make install 1> /dev/null && PackagePython[Status]=$? || { PackagePython[Status]=$?; EchoTest KO ${PackagePython[Name]} && PressAnyKeyToContinue; return 1; };

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
		return 1;
	fi

	EchoInfo	"${PackageTexinfo[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { PackageTexinfo[Status]=$?; EchoTest KO ${PackageTexinfo[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTexinfo[Name]}> make"
	make  1> /dev/null || { PackageTexinfo[Status]=$?; EchoTest KO ${PackageTexinfo[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTexinfo[Name]}> make install"
	make install 1> /dev/null && PackageTexinfo[Status]=$? || { PackageTexinfo[Status]=$?; EchoTest KO ${PackageTexinfo[Name]} && PressAnyKeyToContinue; return 1; };
}

# 8.72
InstallTexinfo()
{
	EchoInfo	"Package ${PackageTexinfo[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageTexinfo[Package]}"	"${PackageTexinfo[Extension]}";

	if ! cd "${PDIR}${PackageTexinfo[Package]}"; then
		EchoError	"cd ${PDIR}${PackageTexinfo[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageTexinfo[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageTexinfo[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTexinfo[Name]}> make"
	make  1> /dev/null || { PackageTexinfo[Status]=$?; EchoTest KO ${PackageTexinfo[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTexinfo[Name]}> make check"
	make check 1> /dev/null || { PackageTexinfo[Status]=$?; EchoTest KO ${PackageTexinfo[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTexinfo[Name]}> make install"
	make install 1> /dev/null && PackageTexinfo[Status]=$? || { PackageTexinfo[Status]=$?; EchoTest KO ${PackageTexinfo[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTexinfo[Name]}> TEXMF=/usr/share/texmf install-tex"
	make TEXMF=/usr/share/texmf install-tex 1> /dev/null && PackageTexinfo[Status]=$? || { PackageTexinfo[Status]=$?; EchoTest KO ${PackageTexinfo[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTexinfo[Name]}> (Re)create /usr/share/info/dir"
	pushd /usr/share/info
		rm -v dir
		for f in *
			do install-info $f dir 2>/dev/null
		done
	popd
}

# =====================================||===================================== #
#								   UtilLinux								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageUtilLinux;
PackageUtilLinux[Name]="util-linux";
PackageUtilLinux[Version]="2.40.2";
PackageUtilLinux[Extension]=".tar.xz";
PackageUtilLinux[Package]="${PackageUtilLinux[Name]}-${PackageUtilLinux[Version]}";

InstallUtilLinux_TT()
{
	EchoInfo	"Package ${PackageUtilLinux[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageUtilLinux[Package]}"	"${PackageUtilLinux[Extension]}";

	if ! cd "${PDIR}${PackageUtilLinux[Package]}"; then
		EchoError	"cd ${PDIR}${PackageUtilLinux[Package]}";
		return 1;
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
				1> /dev/null || { PackageUtilLinux[Status]=$?; EchoTest KO ${PackageUtilLinux[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageUtilLinux[Name]}> make"
	make  1> /dev/null || { PackageUtilLinux[Status]=$?; EchoTest KO ${PackageUtilLinux[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageUtilLinux[Name]}> make install"
	make install 1> /dev/null && PackageUtilLinux[Status]=$? || { PackageUtilLinux[Status]=$?; EchoTest KO ${PackageUtilLinux[Name]} && PressAnyKeyToContinue; return 1; };
}

# 8.79
InstallUtilLinux()
{
	EchoInfo	"Package ${PackageUtilLinux[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageUtilLinux[Package]}"	"${PackageUtilLinux[Extension]}";

	if ! cd "${PDIR}${PackageUtilLinux[Package]}"; then
		EchoError	"cd ${PDIR}${PackageUtilLinux[Package]}";
		return 1;
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
				1> /dev/null || { EchoTest KO ${PackageUtilLinux[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageUtilLinux[Name]}> make"
	make  1> /dev/null || { PackageUtilLinux[Status]=$?; EchoTest KO ${PackageUtilLinux[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageUtilLinux[Name]}> make check"
	touch /etc/fstab
	chown -R tester .
	su tester -c "make -k check" 1> /dev/null || { PackageUtilLinux[Status]=$?; EchoTest KO ${PackageUtilLinux[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageUtilLinux[Name]}> make install"
	make install 1> /dev/null && PackageUtilLinux[Status]=$? || { PackageUtilLinux[Status]=$?; EchoTest KO ${PackageUtilLinux[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									  Man									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMan;
PackageMan[Name]="man-pages";
PackageMan[Version]="6.9.1";
PackageMan[Package]="${PackageMan[Name]}-${PackageMan[Version]}";
PackageMan[Extension]=".tar.xz";

# 8.3
InstallMan()
{
	ReExtractPackage	"${PDIR}"	"${PackageMan[Package]}"	"${PackageMan[Extension]}";

	if ! cd "${PDIR}${PackageMan[Package]}"; then
		PackageMan[Status]=1;
		EchoError	"cd ${PDIR}${PackageMan[Package]}";
		return 1;
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

# 8.4
InstallIanaEtc()
{
	EchoInfo	"Package ${PackageIanaEtc[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageIanaEtc[Package]}"	"${PackageIanaEtc[Extension]}";

	if ! cd "${PDIR}${PackageIanaEtc[Package]}"; then
		PackageIanaEtc[Status]=1;
		EchoError	"cd ${PDIR}${PackageIanaEtc[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageIanaEtc[Name]}> cp services protocols /etc"
	cp services protocols /etc	1> /dev/null;
	PackageIanaEtc[Status]=$?;
}

# =====================================||===================================== #
#									  Zlib									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageZlib;
PackageZlib[Name]="zlib";
PackageZlib[Version]="1.3.1";
PackageZlib[Extension]=".tar.gz";
PackageZlib[Package]="${PackageZlib[Name]}-${PackageZlib[Version]}";

# 8.6
InstallZlib()
{
	EchoInfo	"Package ${PackageZlib[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageZlib[Package]}"	"${PackageZlib[Extension]}";

	if ! cd "${PDIR}${PackageZlib[Package]}"; then
		EchoError	"cd ${PDIR}${PackageZlib[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageZlib[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { PackageZlib[Status]=$?; EchoTest KO ${PackageZlib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageZlib[Name]}> make"
	make  1> /dev/null || { PackageZlib[Status]=$?; EchoTest KO ${PackageZlib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageZlib[Name]}> make check"
	make check 1> /dev/null || { PackageZlib[Status]=$?; EchoTest KO ${PackageZlib[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageZlib[Name]}> make install"
	make install 1> /dev/null && PackageZlib[Status]=$? || { PackageZlib[Status]=$?; EchoTest KO ${PackageZlib[Name]} && PressAnyKeyToContinue; return 1; };

	# Remove a useless static lbrary
	rm -fv /usr/lib/libz.a
}

# =====================================||===================================== #
#									 Bzip2									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageBzip2;
PackageBzip2[Name]="bzip2";
PackageBzip2[Version]="1.0.8";
PackageBzip2[Extension]=".tar.gz";
PackageBzip2[Package]="${PackageBzip2[Name]}-${PackageBzip2[Version]}";

# 8.7
InstallBzip2()
{
	EchoInfo	"Package ${PackageBzip2[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBzip2[Package]}"	"${PackageBzip2[Extension]}";

	if ! cd "${PDIR}${PackageBzip2[Package]}"; then
		EchoError	"cd ${PDIR}${PackageBzip2[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageBzip2[Name]}> Patch"
	patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch

	EchoInfo	"${PackageBzip2[Name]}> sed Makefile"
	sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
	sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

	EchoInfo	"${PackageBzip2[Name]}> prepare make"
	make -f Makefile-libbz2_so 1> /dev/null || { PackageBzip2[Status]=$?; EchoTest KO ${PackageBzip2[Name]} && PressAnyKeyToContinue; return 1; };
	make clean 1> /dev/null || { PackageBzip2[Status]=$?; EchoTest KO ${PackageBzip2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBzip2[Name]}> make"
	make  1> /dev/null || { PackageBzip2[Status]=$?; EchoTest KO ${PackageBzip2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBzip2[Name]}> make check"
	make check 1> /dev/null || { PackageBzip2[Status]=$?; EchoTest KO ${PackageBzip2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBzip2[Name]}> make PREFIX=/usr install"
	make PREFIX=/usr install 1> /dev/null && PackageBzip2[Status]=$? || { PackageBzip2[Status]=$?; EchoTest KO ${PackageBzip2[Name]} && PressAnyKeyToContinue; return 1; };

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

# =====================================||===================================== #
#									  Lz4									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLz4;
PackageLz4[Name]="lz4";
PackageLz4[Version]="1.10.0";
PackageLz4[Extension]=".tar.gz";
PackageLz4[Package]="${PackageLz4[Name]}-${PackageLz4[Version]}";

# 8.9
InstallLz4()
{
	EchoInfo	"Package ${PackageLz4[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLz4[Package]}"	"${PackageLz4[Extension]}";

	if ! cd "${PDIR}${PackageLz4[Package]}"; then
		EchoError	"cd ${PDIR}${PackageLz4[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLz4[Name]}> make BUILD_STATIC=no PREFIX=/usr"
	make BUILD_STATIC=no PREFIX=/usr 1> /dev/null || { PackageLz4[Status]=$?; EchoTest KO ${PackageLz4[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLz4[Name]}> make -j1 check"
	make -j1 check 1> /dev/null || { PackageLz4[Status]=$?; EchoTest KO ${PackageLz4[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLz4[Name]}> make BUILD_STATIC=no PREFIX=/usr install"
	make BUILD_STATIC=no PREFIX=/usr install 1> /dev/null && PackageLz4[Status]=$? || { PackageLz4[Status]=$?; EchoTest KO ${PackageLz4[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									  Zstd									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageZstd;
PackageZstd[Name]="zstd";
PackageZstd[Version]="1.5.6";
PackageZstd[Extension]=".tar.gz";
PackageZstd[Package]="${PackageZstd[Name]}-${PackageZstd[Version]}";

# 8.10
InstallZstd()
{
	EchoInfo	"Package ${PackageZstd[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageZstd[Package]}"	"${PackageZstd[Extension]}";

	if ! cd "${PDIR}${PackageZstd[Package]}"; then
		EchoError	"cd ${PDIR}${PackageZstd[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageZstd[Name]}> make prefix=/usr"
	make prefix=/usr 1> /dev/null || { PackageZstd[Status]=$?; EchoTest KO ${PackageZstd[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageZstd[Name]}> make check"
	make check 1> /dev/null || { PackageZstd[Status]=$?; EchoTest KO ${PackageZstd[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageZstd[Name]}> make prefix=/usr install"
	make prefix=/usr install 1> /dev/null && PackageZstd[Status]=$? || { PackageZstd[Status]=$?; EchoTest KO ${PackageZstd[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageZstd[Name]}> Remove the static library"
	rm -v /usr/lib/libzstd.a
}

# =====================================||===================================== #
#									Readline								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageReadline;
PackageReadline[Name]="readline";
PackageReadline[Version]="8.2.13";
PackageReadline[Extension]=".tar.gz";
PackageReadline[Package]="${PackageReadline[Name]}-${PackageReadline[Version]}";

# 8.12
InstallReadline()
{
	EchoInfo	"Package ${PackageReadline[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageReadline[Package]}"	"${PackageReadline[Extension]}";

	if ! cd "${PDIR}${PackageReadline[Package]}"; then
		EchoError	"cd ${PDIR}${PackageReadline[Package]}";
		return 1;
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
				1> /dev/null || { EchoTest KO ${PackageReadline[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageReadline[Name]}> make SHLIB_LIBS=\"-lncursesw\""
	make SHLIB_LIBS="-lncursesw" 1> /dev/null || { PackageReadline[Status]=$?; EchoTest KO ${PackageReadline[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageReadline[Name]}> make SHLIB_LIBS=\"-lncursesw\" install"
	make SHLIB_LIBS="-lncursesw" install 1> /dev/null && PackageReadline[Status]=$? || { PackageReadline[Status]=$?; EchoTest KO ${PackageReadline[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageReadline[Name]}> Install documentation"
	install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.2.13 1> /dev/null && PackageReadline[Status]=$? || { PackageReadline[Status]=$?; EchoTest KO ${PackageReadline[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									   Bc									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageBc;
PackageBc[Name]="bc";
PackageBc[Version]="6.7.6";
PackageBc[Extension]=".tar.xz";
PackageBc[Package]="${PackageBc[Name]}-${PackageBc[Version]}";

# 8.14
InstallBc()
{
	EchoInfo	"Package ${PackageBc[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageBc[Package]}"	"${PackageBc[Extension]}";

	if ! cd "${PDIR}${PackageBc[Package]}"; then
		EchoError	"cd ${PDIR}${PackageBc[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageBc[Name]}> CC=gcc ./configure --prefix=/usr -G -O3 -r"
	CC=gcc ./configure --prefix=/usr -G -O3 -r 1> /dev/null || { EchoTest KO ${PackageBc[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBc[Name]}> make"
	make  1> /dev/null || { PackageBc[Status]=$?; EchoTest KO ${PackageBc[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBc[Name]}> make test"
	make test 1> /dev/null || { PackageBc[Status]=$?; EchoTest KO ${PackageBc[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBc[Name]}> make install"
	make install 1> /dev/null && PackageBc[Status]=$? || { PackageBc[Status]=$?; EchoTest KO ${PackageBc[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									  Flex									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageFlex;
PackageFlex[Name]="flex";
PackageFlex[Version]="2.6.4";
PackageFlex[Extension]=".tar.gz";
PackageFlex[Package]="${PackageFlex[Name]}-${PackageFlex[Version]}";

# 8.15
InstallFlex()
{
	EchoInfo	"Package ${PackageFlex[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageFlex[Package]}"	"${PackageFlex[Extension]}";

	if ! cd "${PDIR}${PackageFlex[Package]}"; then
		EchoError	"cd ${PDIR}${PackageFlex[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageFlex[Name]}> Configure"
	./configure --prefix=/usr \
				--docdir=/usr/share/doc/flex-2.6.4 \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageFlex[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFlex[Name]}> make"
	make  1> /dev/null || { PackageFlex[Status]=$?; EchoTest KO ${PackageFlex[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFlex[Name]}> make check"
	make check 1> /dev/null || { PackageFlex[Status]=$?; EchoTest KO ${PackageFlex[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFlex[Name]}> make install"
	make install 1> /dev/null && PackageFlex[Status]=$? || { PackageFlex[Status]=$?; EchoTest KO ${PackageFlex[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFlex[Name]}> Symbolic link from predecessor lex to flex"
	ln -sv flex	/usr/bin/lex
	ln -sv flex.1 /usr/share/man/man1/lex.1
}

# =====================================||===================================== #
#									  Tcl									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageTcl;
PackageTcl[Name]="tcl";
PackageTcl[Version]="8.6.14";
PackageTcl[Extension]=".tar.gz";
PackageTcl[Package]="${PackageTcl[Name]}${PackageTcl[Version]}";

# 8.16
InstallTcl()
{
	EchoInfo	"Package ${PackageTcl[Name]}"

	# ReExtractPackage	"${PDIR}"	"${PackageTcl[Package]}"	"${PackageTcl[Extension]}";
	ReExtractPackage	"${PDIR}"	"${PackageTcl[Package]}-html"	"${PackageTcl[Extension]}";
	ReExtractPackage	"${PDIR}"	"${PackageTcl[Package]}-src"	"${PackageTcl[Extension]}";

	if ! cd "${PDIR}${PackageTcl[Package]}"; then
		EchoError	"cd ${PDIR}${PackageTcl[Package]}";
		return 1;
	fi

	local SRCDIR=$(pwd);

	EchoInfo	"${PackageTcl[Name]}> Configure"
	cd unix;
	./configure --prefix=/usr \
				--mandir=/usr/share/man \
				--disable-rpath \
				1> /dev/null || { EchoTest KO ${PackageTcl[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTcl[Name]}> make"
	make  1> /dev/null || { PackageTcl[Status]=$?; EchoTest KO ${PackageTcl[Name]} && PressAnyKeyToContinue; return 1; };

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
	make test 1> /dev/null || { PackageTcl[Status]=$?; EchoTest KO ${PackageTcl[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageTcl[Name]}> make install"
	make install 1> /dev/null && PackageTcl[Status]=$? || { PackageTcl[Status]=$?; EchoTest KO ${PackageTcl[Name]} && PressAnyKeyToContinue; return 1; };

	chmod -v u+w /usr/lib/libtcl8.6.so
	make install-private-headers
	ln -sfv tclsh8.6 /usr/bin/tclsh
	mv /usr/share/man/man3/{Thread,Tcl_Thread}.3

	EchoInfo	"${PackageTcl[Name]}> Installing documentation"s
	cd ..
	tar -xf ../tcl8.6.14-html.tar.gz --strip-components=1
	mkdir -v -p /usr/share/doc/tcl-8.6.14
	cp -v -r ./html/* /usr/share/doc/tcl-8.6.14
}

# =====================================||===================================== #
#									 Expect									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageExpect;
PackageExpect[Name]="expect";
PackageExpect[Version]="5.45.4";
PackageExpect[Extension]=".tar.gz";
PackageExpect[Package]="${PackageExpect[Name]}${PackageExpect[Version]}";

# 8.17
InstallExpect()
{
	EchoInfo	"Package ${PackageExpect[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageExpect[Package]}"	"${PackageExpect[Extension]}";

	if ! cd "${PDIR}${PackageExpect[Package]}"; then
		EchoError	"cd ${PDIR}${PackageExpect[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageExpect[Name]}> Verify PTYs are working";
	python3 -c 'from pty import spawn; spawn(["echo", "ok"])' 1> /dev/null || { EchoTest KO ${PackageExpect[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageExpect[Name]}> Patch"
	patch -Np1 -i ../expect-5.45.4-gcc14-1.patch;

	EchoInfo	"${PackageExpect[Name]}> Configure"
	./configure --prefix=/usr \
				--with-tcl=/usr/lib \
				--enable-shared \
				--disable-rpath \
				--mandir=/usr/share/man \
				--with-tclinclude=/usr/include \
				1> /dev/null || { EchoTest KO ${PackageExpect[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageExpect[Name]}> make"
	make  1> /dev/null || { PackageExpect[Status]=$?; EchoTest KO ${PackageExpect[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageExpect[Name]}> make test"
	make test 1> /dev/null || { PackageExpect[Status]=$?; EchoTest KO ${PackageExpect[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageExpect[Name]}> make install"
	make install 1> /dev/null && PackageExpect[Status]=$? || { PackageExpect[Status]=$?; EchoTest KO ${PackageExpect[Name]} && PressAnyKeyToContinue; return 1; };

	ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
}

# =====================================||===================================== #
#									DejaGNU									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageDejaGNU;
PackageDejaGNU[Name]="dejagnu";
PackageDejaGNU[Version]="1.6.3";
PackageDejaGNU[Extension]=".tar.gz";
PackageDejaGNU[Package]="${PackageDejaGNU[Name]}-${PackageDejaGNU[Version]}";

# 8.18
InstallDejaGNU()
{
	EchoInfo	"Package ${PackageDejaGNU[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageDejaGNU[Package]}"	"${PackageDejaGNU[Extension]}";


	if ! cd "${PDIR}${PackageDejaGNU[Package]}"; then
		EchoError	"cd ${PDIR}${PackageDejaGNU[Package]}";
		return 1;
	fi

	if ! mkdir -p "build"; then
		PackageDejaGNU[Status]=1; 
		EchoError	"Failed to make ${PDIR}${PackageDejaGNU[Name]}/build";
		cd -;
		return ;
	fi

	cd "${PDIR}${PackageDejaGNU[Name]}-${PackageDejaGNU[Version]}/build";

	EchoInfo	"${PackageDejaGNU[Name]}> Configure"
	../configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageDejaGNU[Name]} && PressAnyKeyToContinue; return 1; };
	makeinfo --html --no-split	-o doc/dejagnu.html	../doc/dejagnu.texi
	makeinfo --plaintext		-o doc/dejagnu.txt	../doc/dejagnu.texi

	EchoInfo	"${PackageDejaGNU[Name]}> make check"
	make check 1> /dev/null || { PackageDejaGNU[Status]=$?; EchoTest KO ${PackageDejaGNU[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageDejaGNU[Name]}> make install"
	make install 1> /dev/null && PackageDejaGNU[Status]=$? || { PackageDejaGNU[Status]=$?; EchoTest KO ${PackageDejaGNU[Name]} && PressAnyKeyToContinue; return 1; };
	install -v -dm755	/usr/share/doc/dejagnu-1.6.3
	install -v -m644	doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
}

# =====================================||===================================== #
#									Pkgconf									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePkgconf;
PackagePkgconf[Name]="pkgconf";
PackagePkgconf[Version]="2.3.0";
PackagePkgconf[Extension]=".tar.xz";
PackagePkgconf[Package]="${PackagePkgconf[Name]}-${PackagePkgconf[Version]}";

# 8.19
InstallPkgconf()
{
	EchoInfo	"Package ${PackagePkgconf[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackagePkgconf[Package]}"	"${PackagePkgconf[Extension]}";

	if ! cd "${PDIR}${PackagePkgconf[Package]}"; then
		EchoError	"cd ${PDIR}${PackagePkgconf[Package]}";
		return 1;
	fi

	EchoInfo	"${PackagePkgconf[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--docdir=/usr/share/doc/pkgconf-2.3.0 \
				1> /dev/null || { EchoTest KO ${PackagePkgconf[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePkgconf[Name]}> make"
	make  1> /dev/null || { PackagePkgconf[Status]=$?; EchoTest KO ${PackagePkgconf[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePkgconf[Name]}> make install"
	make install 1> /dev/null && PackagePkgconf[Status]=$? || { PackagePkgconf[Status]=$?; EchoTest KO ${PackagePkgconf[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePkgconf[Name]}> Maintain compatability with original Pkg-config";
	ln -sv pkgconf	/usr/bin/pkg-config
	ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1
}

# =====================================||===================================== #
#									  GMP									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGMP;
PackageGMP[Name]="gmp";
PackageGMP[Version]="6.3.0";
PackageGMP[Extension]=".tar.xz";
PackageGMP[Package]="${PackageGMP[Name]}-${PackageGMP[Version]}";

# 8.21
InstallGMP()
{
	EchoInfo	"Package ${PackageGMP[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGMP[Package]}"	"${PackageGMP[Extension]}";

	if ! cd "${PDIR}${PackageGMP[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGMP[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageGMP[Name]}> Configure"
	./configure --prefix=/usr \
				--enable-cxx \
				--disable-static \
				--docdir=/usr/share/doc/gmp-6.3.0 \
				1> /dev/null || { EchoTest KO ${PackageGMP[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGMP[Name]}> make"
	make  1> /dev/null || { PackageGMP[Status]=$?; EchoTest KO ${PackageGMP[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGMP[Name]}> make html"
	make html 1> /dev/null && PackageGMP[Status]=$? || { PackageGMP[Status]=$?; EchoTest KO ${PackageGMP[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGMP[Name]}> make check"
	make check 1> /dev/null | tee gmp-check-log
	if grep -q "Illegal instruction" "gmp-check-log"; then
		PackageGMP[Status]=$?;
		EchoTest KO "${PackageGMP[Name]} Need to be reconfigured with --host=none-linux-gnu and rebuilt";
		PressAnyKeyToContinue;
		return 1;
	elif [ $(awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log) -lt 199 ]; then
		PackageGMP[Status]=$?;
		EchoTest KO "${PackageGMP[Name]} Insufficient PASS";
		PressAnyKeyToContinue;
		return 1;
	fi

	EchoInfo	"${PackageGMP[Name]}> make install"
	make install 1> /dev/null && PackageGMP[Status]=$? || { PackageGMP[Status]=$?; EchoTest KO ${PackageGMP[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGMP[Name]}> make install-html"
	make install-html 1> /dev/null && PackageGMP[Status]=$? || { PackageGMP[Status]=$?; EchoTest KO ${PackageGMP[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									  MPFR									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMPFR;
PackageMPFR[Name]="mpfr";
PackageMPFR[Version]="4.2.1";
PackageMPFR[Extension]=".tar.xz";
PackageMPFR[Package]="${PackageMPFR[Name]}-${PackageMPFR[Version]}";

# 8.22
InstallMPFR()
{
	EchoInfo	"Package ${PackageMPFR[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageMPFR[Package]}"	"${PackageMPFR[Extension]}";

	if ! cd "${PDIR}${PackageMPFR[Package]}"; then
		EchoError	"cd ${PDIR}${PackageMPFR[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageMPFR[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--enable-thread-safe \
				--docdir=/usr/share/doc/mpfr-4.2.1 \
				1> /dev/null || { EchoTest KO ${PackageMPFR[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMPFR[Name]}> make"
	make  1> /dev/null || { PackageMPFR[Status]=$?; EchoTest KO ${PackageMPFR[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMPFR[Name]}> make html"
	make html  1> /dev/null || { PackageMPFR[Status]=$?; EchoTest KO ${PackageMPFR[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMPFR[Name]}> make check"
	make check 1> /dev/null || { PackageMPFR[Status]=$?; EchoTest KO ${PackageMPFR[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMPFR[Name]}> make install"
	make install 1> /dev/null && PackageMPFR[Status]=$? || { PackageMPFR[Status]=$?; EchoTest KO ${PackageMPFR[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMPFR[Name]}> make install-html"
	make install-html 1> /dev/null && PackageMPFR[Status]=$? || { PackageMPFR[Status]=$?; EchoTest KO ${PackageMPFR[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									  MPC									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMPC;
PackageMPC[Name]="mpc";
PackageMPC[Version]="1.3.1";
PackageMPC[Extension]=".tar.gz";
PackageMPC[Package]="${PackageMPC[Name]}-${PackageMPC[Version]}";

# 8.23
InstallMPC()
{
	EchoInfo	"Package ${PackageMPC[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageMPC[Package]}"	"${PackageMPC[Extension]}";

	if ! cd "${PDIR}${PackageMPC[Package]}"; then
		EchoError	"cd ${PDIR}${PackageMPC[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageMPC[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--docdir=/usr/share/doc/mpc-1.3.1 \
				1> /dev/null || { EchoTest KO ${PackageMPC[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMPC[Name]}> make"
	make  1> /dev/null || { PackageMPC[Status]=$?; EchoTest KO ${PackageMPC[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMPC[Name]}> make html"
	make html 1> /dev/null || { PackageMPC[Status]=$?; EchoTest KO ${PackageMPC[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMPC[Name]}> make check"
	make check 1> /dev/null || { PackageMPC[Status]=$?; EchoTest KO ${PackageMPC[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMPC[Name]}> make install"
	make install 1> /dev/null && PackageMPC[Status]=$? || { PackageMPC[Status]=$?; EchoTest KO ${PackageMPC[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMPC[Name]}> make install-html"
	make install-html 1> /dev/null && PackageMPC[Status]=$? || { PackageMPC[Status]=$?; EchoTest KO ${PackageMPC[Name]} && PressAnyKeyToContinue; return 1; };
}
## continue

# =====================================||===================================== #
#									  Attr									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageAttr;
PackageAttr[Name]="attr";
PackageAttr[Version]="2.5.2";
PackageAttr[Extension]=".tar.gz";
PackageAttr[Package]="${PackageAttr[Name]}-${PackageAttr[Version]}";

# 8.24
InstallAttr()
{
	EchoInfo	"Package ${PackageAttr[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageAttr[Package]}"	"${PackageAttr[Extension]}";

	if ! cd "${PDIR}${PackageAttr[Package]}"; then
		EchoError	"cd ${PDIR}${PackageAttr[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageAttr[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--sysconfdir=/etc \
				--docdir=/usr/share/doc/attr-2.5.2 \
				1> /dev/null || { EchoTest KO ${PackageAttr[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAttr[Name]}> make"
	make  1> /dev/null || { PackageAttr[Status]=$?; EchoTest KO ${PackageAttr[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAttr[Name]}> make check"
	make check 1> /dev/null || { PackageAttr[Status]=$?; EchoTest KO ${PackageAttr[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAttr[Name]}> make install"
	make install 1> /dev/null && PackageAttr[Status]=$? || { PackageAttr[Status]=$?; EchoTest KO ${PackageAttr[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									  Acl									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageAcl;
PackageAcl[Name]="acl";
PackageAcl[Version]="2.3.2";
PackageAcl[Extension]=".tar.xz";
PackageAcl[Package]="${PackageAcl[Name]}-${PackageAcl[Version]}";

# 8.25
InstallAcl()
{
	EchoInfo	"Package ${PackageAcl[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageAcl[Package]}"	"${PackageAcl[Extension]}";

	if ! cd "${PDIR}${PackageAcl[Package]}"; then
		EchoError	"cd ${PDIR}${PackageAcl[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageAcl[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--docdir=/usr/share/doc/acl-2.3.2 \
				1> /dev/null || { EchoTest KO ${PackageAcl[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAcl[Name]}> make"
	make  1> /dev/null || { PackageAcl[Status]=$?; EchoTest KO ${PackageAcl[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAcl[Name]}> make install"
	make install 1> /dev/null && PackageAcl[Status]=$? || { PackageAcl[Status]=$?; EchoTest KO ${PackageAcl[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									 Libcap									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibcap;
PackageLibcap[Name]="libcap";
PackageLibcap[Version]="2.70";
PackageLibcap[Extension]=".tar.xz";
PackageLibcap[Package]="${PackageLibcap[Name]}-${PackageLibcap[Version]}";

# 8.26
InstallLibcap()
{
	EchoInfo	"Package ${PackageLibcap[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLibcap[Package]}"	"${PackageLibcap[Extension]}";

	if ! cd "${PDIR}${PackageLibcap[Package]}"; then
		EchoError	"cd ${PDIR}${PackageLibcap[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibcap[Name]}> Prevent static libraries form being installed"
	sed -i '/install -m.*STA/d' libcap/Makefile

	EchoInfo	"${PackageLibcap[Name]}> make prefix=/usr lib=lib"
	make prefix=/usr lib=lib 1> /dev/null || { PackageLibcap[Status]=$?; EchoTest KO ${PackageLibcap[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibcap[Name]}> make test"
	make test 1> /dev/null || { PackageLibcap[Status]=$?; EchoTest KO ${PackageLibcap[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibcap[Name]}> make prefix=/usr lib=lib install"
	make prefix=/usr lib=lib install 1> /dev/null && PackageLibcap[Status]=$? || { PackageLibcap[Status]=$?; EchoTest KO ${PackageLibcap[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#								   Libxcrypt								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibxcrypt;
PackageLibxcrypt[Name]="libxcrypt";
PackageLibxcrypt[Version]="4.4.36";
PackageLibxcrypt[Extension]=".tar.xz";
PackageLibxcrypt[Package]="${PackageLibxcrypt[Name]}-${PackageLibxcrypt[Version]}";

# 8.27
InstallLibxcrypt()
{
	EchoInfo	"Package ${PackageLibxcrypt[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLibxcrypt[Package]}"	"${PackageLibxcrypt[Extension]}";

	if ! cd "${PDIR}${PackageLibxcrypt[Package]}"; then
		EchoError	"cd ${PDIR}${PackageLibxcrypt[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibxcrypt[Name]}> Configure"
	./configure --prefix=/usr \
				--enable-hashes=strong,glibc \
				--enable-obsolete-api=no \
				--disable-static \
				--disable-failure-tokens \
				1> /dev/null || { EchoTest KO ${PackageLibxcrypt[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibxcrypt[Name]}> make"
	make  1> /dev/null || { PackageLibxcrypt[Status]=$?; EchoTest KO ${PackageLibxcrypt[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibxcrypt[Name]}> make check"
	make check 1> /dev/null || { PackageLibxcrypt[Status]=$?; EchoTest KO ${PackageLibxcrypt[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibxcrypt[Name]}> make install"
	make install 1> /dev/null && PackageLibxcrypt[Status]=$? || { PackageLibxcrypt[Status]=$?; EchoTest KO ${PackageLibxcrypt[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									 Shadow									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageShadow;
PackageShadow[Name]="shadow";
PackageShadow[Version]="4.16.0";
PackageShadow[Extension]=".tar.xz";
PackageShadow[Package]="${PackageShadow[Name]}-${PackageShadow[Version]}";

# 8.28
InstallShadow()
{
	EchoInfo	"Package ${PackageShadow[Name]}"

	# Extraction
	ReExtractPackage	"${PDIR}"	"${PackageShadow[Package]}"	"${PackageShadow[Extension]}";

	if ! cd "${PDIR}${PackageShadow[Package]}"; then
		EchoError	"cd ${PDIR}${PackageShadow[Package]}";
		return 1;
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
				1> /dev/null || { EchoTest KO ${PackageShadow[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageShadow[Name]}> make"
	make  1> /dev/null || { PackageShadow[Status]=$?; EchoTest KO ${PackageShadow[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageShadow[Name]}> make exec_prefix=/usr install"
	make exec_prefix=/usr install 1> /dev/null && PackageShadow[Status]=$? || { PackageShadow[Status]=$?; EchoTest KO ${PackageShadow[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageShadow[Name]}> make -C man install-man"
	make -C man install-man 1> /dev/null && PackageShadow[Status]=$? || { PackageShadow[Status]=$?; EchoTest KO ${PackageShadow[Name]} && PressAnyKeyToContinue; return 1; };

	# Configuration
	EchoInfo	"${PackageShadow[Name]}> Enabling Shadow passwords"
	pwconv
	grpconv
	mkdir -p /etc/default
	useradd -D --gid 999

	EchoInfo	"${PackageShadow[Name]}> Enabling Shadow passwords"
	passwd root
}

# ============ft_linux============| 8.29 Gcc |============©Othello============ #

# =====================================||===================================== #
#									Ncurses									   #
# ===========ft_linux===========| 8.30 Ncurses |===========©Othello=========== #

# ============ft_linux============| 8.31 Sed |============©Othello============ #

# =====================================||===================================== #
#									 Psmisc									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackagePsmisc;
PackagePsmisc[Name]="psmisc";
PackagePsmisc[Version]="23.7";
PackagePsmisc[Extension]=".tar.xz";
PackagePsmisc[Package]="${PackagePsmisc[Name]}-${PackagePsmisc[Version]}";

# 8.32
InstallPsmisc()
{
	EchoInfo	"Package ${PackagePsmisc[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackagePsmisc[Package]}"	"${PackagePsmisc[Extension]}";

	if ! cd "${PDIR}${PackagePsmisc[Package]}"; then
		EchoError	"cd ${PDIR}${PackagePsmisc[Package]}";
		return 1;
	fi

	EchoInfo	"${PackagePsmisc[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackagePsmisc[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePsmisc[Name]}> make"
	make  1> /dev/null || { PackagePsmisc[Status]=$?; EchoTest KO ${PackagePsmisc[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePsmisc[Name]}> make check"
	make check 1> /dev/null || { PackagePsmisc[Status]=$?; EchoTest KO ${PackagePsmisc[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackagePsmisc[Name]}> make install"
	make install 1> /dev/null && PackagePsmisc[Status]=$? || { PackagePsmisc[Status]=$?; EchoTest KO ${PackagePsmisc[Name]} && PressAnyKeyToContinue; return 1; };
}

# ===========ft_linux===========| 8.33 Gettext |===========©Othello=========== #

# ============ft_linux===========| 8.34 Bison |===========©Othello============ #

# ============ft_linux============| 8.35 Grep |===========©Othello============ #

# ============ft_linux============| 8.36 Bash |===========©Othello============ #

# =====================================||===================================== #
#									Libtool									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibtool;
PackageLibtool[Name]="libtool";
PackageLibtool[Version]="2.4.7";
PackageLibtool[Extension]=".tar.xz";
PackageLibtool[Package]="${PackageLibtool[Name]}-${PackageLibtool[Version]}";

# 8.37
InstallLibtool()
{
	EchoInfo	"Package ${PackageLibtool[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLibtool[Package]}"	"${PackageLibtool[Extension]}";

	if ! cd "${PDIR}${PackageLibtool[Package]}"; then
		EchoError	"cd ${PDIR}${PackageLibtool[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibtool[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageLibtool[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibtool[Name]}> make"
	make  1> /dev/null || { PackageLibtool[Status]=$?; EchoTest KO ${PackageLibtool[Name]} && PressAnyKeyToContinue; return 1; };

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
			return 1;
		fi
	fi
	rm TempMakeCheck.log

	EchoInfo	"${PackageLibtool[Name]}> make install"
	make install 1> /dev/null && PackageLibtool[Status]=$? || { PackageLibtool[Status]=$?; EchoTest KO ${PackageLibtool[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibtool[Name]}> Remove useless static library"
	rm -fv /usr/lib/libltdl.a
}

# =====================================||===================================== #
#									  GDBM									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGDBM;
PackageGDBM[Name]="gdbm";
PackageGDBM[Version]="1.24";
PackageGDBM[Extension]=".tar.gz";
PackageGDBM[Package]="${PackageGDBM[Name]}-${PackageGDBM[Version]}";

# 8.38
InstallGDBM()
{
	EchoInfo	"Package ${PackageGDBM[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGDBM[Package]}"	"${PackageGDBM[Extension]}";

	if ! cd "${PDIR}${PackageGDBM[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGDBM[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageGDBM[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--enable-libgdbm-compat \
				1> /dev/null || { EchoTest KO ${PackageGDBM[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGDBM[Name]}> make"
	make  1> /dev/null || { PackageGDBM[Status]=$?; EchoTest KO ${PackageGDBM[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGDBM[Name]}> make check"
	make check 1> /dev/null || { PackageGDBM[Status]=$?; EchoTest KO ${PackageGDBM[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGDBM[Name]}> make install"
	make install 1> /dev/null && PackageGDBM[Status]=$? || { PackageGDBM[Status]=$?; EchoTest KO ${PackageGDBM[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									 Gperf									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGperf;
PackageGperf[Name]="gperf";
PackageGperf[Version]="3.1";
PackageGperf[Extension]=".tar.gz";
PackageGperf[Package]="${PackageGperf[Name]}-${PackageGperf[Version]}";

# 8.39
InstallGperf()
{
	EchoInfo	"Package ${PackageGperf[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGperf[Package]}"	"${PackageGperf[Extension]}";

	if ! cd "${PDIR}${PackageGperf[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGperf[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageGperf[Name]}> Configure"
	./configure --prefix=/usr \
				--docdir=/usr/share/doc/gperf-3.1 \
				1> /dev/null || { EchoTest KO ${PackageGperf[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGperf[Name]}> make"
	make  1> /dev/null || { PackageGperf[Status]=$?; EchoTest KO ${PackageGperf[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGperf[Name]}> make -j1 check"
	make -j1 check 1> /dev/null || { PackageGperf[Status]=$?; EchoTest KO ${PackageGperf[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGperf[Name]}> make install"
	make install 1> /dev/null && PackageGperf[Status]=$? || { PackageGperf[Status]=$?; EchoTest KO ${PackageGperf[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									 Expat									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageExpat;
PackageExpat[Name]="expat";
PackageExpat[Version]="2.6.2";
PackageExpat[Extension]=".tar.xz";
PackageExpat[Package]="${PackageExpat[Name]}-${PackageExpat[Version]}";

# 8.40
InstallExpat()
{
	EchoInfo	"Package ${PackageExpat[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageExpat[Package]}"	"${PackageExpat[Extension]}";

	if ! cd "${PDIR}${PackageExpat[Package]}"; then
		EchoError	"cd ${PDIR}${PackageExpat[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageExpat[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--docdir=/usr/share/doc/expat-2.6.2 \
				1> /dev/null || { EchoTest KO ${PackageExpat[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageExpat[Name]}> make"
	make  1> /dev/null || { PackageExpat[Status]=$?; EchoTest KO ${PackageExpat[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageExpat[Name]}> make check"
	make check 1> /dev/null || { PackageExpat[Status]=$?; EchoTest KO ${PackageExpat[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageExpat[Name]}> make install"
	make install 1> /dev/null && PackageExpat[Status]=$? || { PackageExpat[Status]=$?; EchoTest KO ${PackageExpat[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageExpat[Name]}> Install documentation"
	install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.6.2 1> /dev/null
}

# =====================================||===================================== #
#								   Inetutils								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageInetutils;
PackageInetutils[Name]="inetutils";
PackageInetutils[Version]="2.5";
PackageInetutils[Extension]=".tar.xz";
PackageInetutils[Package]="${PackageInetutils[Name]}-${PackageInetutils[Version]}";

# 8.41
InstallInetutils()
{
	EchoInfo	"Package ${PackageInetutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageInetutils[Package]}"	"${PackageInetutils[Extension]}";

	if ! cd "${PDIR}${PackageInetutils[Package]}"; then
		EchoError	"cd ${PDIR}${PackageInetutils[Package]}";
		return 1;
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
				1> /dev/null || { EchoTest KO ${PackageInetutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageInetutils[Name]}> make"
	make  1> /dev/null || { PackageInetutils[Status]=$?; EchoTest KO ${PackageInetutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageInetutils[Name]}> make check"
	make check 1> /dev/null || { PackageInetutils[Status]=$?; EchoTest KO ${PackageInetutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageInetutils[Name]}> make install"
	make install 1> /dev/null && PackageInetutils[Status]=$? || { PackageInetutils[Status]=$?; EchoTest KO ${PackageInetutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageInetutils[Name]}> Move ifconfig to the proper location"
	mv -v /usr/{,s}bin/ifconfig
}

# =====================================||===================================== #
#									  Less									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLess;
PackageLess[Name]="less";
PackageLess[Version]="661";
PackageLess[Extension]=".tar.gz";
PackageLess[Package]="${PackageLess[Name]}-${PackageLess[Version]}";

# 8.42
InstallLess()
{
	EchoInfo	"Package ${PackageLess[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLess[Package]}"	"${PackageLess[Extension]}";

	if ! cd "${PDIR}${PackageLess[Package]}"; then
		EchoError	"cd ${PDIR}${PackageLess[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLess[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				1> /dev/null || { EchoTest KO ${PackageLess[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLess[Name]}> make"
	make  1> /dev/null || { PackageLess[Status]=$?; EchoTest KO ${PackageLess[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLess[Name]}> make check"
	make check 1> /dev/null || { PackageLess[Status]=$?; EchoTest KO ${PackageLess[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLess[Name]}> make install"
	make install 1> /dev/null && PackageLess[Status]=$? || { PackageLess[Status]=$?; EchoTest KO ${PackageLess[Name]} && PressAnyKeyToContinue; return 1; };
}

# ============ft_linux============| 8.43 Perl |===========©Othello============ #

# =====================================||===================================== #
#								   XMLParser								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXMLParser;
PackageXMLParser[Name]="XML-Parser";
PackageXMLParser[Version]="2.47";
PackageXMLParser[Extension]=".tar.gz";
PackageXMLParser[Package]="${PackageXMLParser[Name]}-${PackageXMLParser[Version]}";

# 8.44
InstallXMLParser()
{
	EchoInfo	"Package ${PackageXMLParser[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageXMLParser[Package]}"	"${PackageXMLParser[Extension]}";

	if ! cd "${PDIR}${PackageXMLParser[Package]}"; then
		EchoError	"cd ${PDIR}${PackageXMLParser[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageXMLParser[Name]}> perl Makefile.PL"
	perl Makefile.PL 1> /dev/null || { EchoTest KO ${PackageXMLParser[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXMLParser[Name]}> make"
	make  1> /dev/null || { PackageXMLParser[Status]=$?; EchoTest KO ${PackageXMLParser[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXMLParser[Name]}> make test"
	make test 1> /dev/null || { PackageXMLParser[Status]=$?; EchoTest KO ${PackageXMLParser[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageXMLParser[Name]}> make install"
	make install 1> /dev/null && PackageXMLParser[Status]=$? || { PackageXMLParser[Status]=$?; EchoTest KO ${PackageXMLParser[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									Intltool								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageIntltool;
PackageIntltool[Name]="intltool";
PackageIntltool[Version]="0.51.0";
PackageIntltool[Extension]=".tar.gz";
PackageIntltool[Package]="${PackageIntltool[Name]}-${PackageIntltool[Version]}";

# 8.45
InstallIntltool()
{
	EchoInfo	"Package ${PackageIntltool[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageIntltool[Package]}"	"${PackageIntltool[Extension]}";

	if ! cd "${PDIR}${PackageIntltool[Package]}"; then
		EchoError	"cd ${PDIR}${PackageIntltool[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageIntltool[Name]}> Fix a warning caused by perl-5.22+"
	sed -i 's:\\\${:\\\$\\{:' intltool-update.in

	EchoInfo	"${PackageIntltool[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageIntltool[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageIntltool[Name]}> make"
	make  1> /dev/null || { PackageIntltool[Status]=$?; EchoTest KO ${PackageIntltool[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageIntltool[Name]}> make check"
	make check 1> /dev/null || { PackageIntltool[Status]=$?; EchoTest KO ${PackageIntltool[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageIntltool[Name]}> make install"
	make install 1> /dev/null && PackageIntltool[Status]=$? || { PackageIntltool[Status]=$?; EchoTest KO ${PackageIntltool[Name]} && PressAnyKeyToContinue; return 1; };
	install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO || { PackageIntltool[Status]=$?; EchoTest KO ${PackageIntltool[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									Autoconf								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageAutoconf;
PackageAutoconf[Name]="autoconf";
PackageAutoconf[Version]="2.72";
PackageAutoconf[Extension]=".tar.xz";
PackageAutoconf[Package]="${PackageAutoconf[Name]}-${PackageAutoconf[Version]}";

# 8.46
InstallAutoconf()
{
	EchoInfo	"Package ${PackageAutoconf[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageAutoconf[Package]}"	"${PackageAutoconf[Extension]}";

	if ! cd "${PDIR}${PackageAutoconf[Package]}"; then
		EchoError	"cd ${PDIR}${PackageAutoconf[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageAutoconf[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageAutoconf[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAutoconf[Name]}> make"
	make  1> /dev/null || { PackageAutoconf[Status]=$?; EchoTest KO ${PackageAutoconf[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAutoconf[Name]}> make check"
	make check 1> /dev/null || { PackageAutoconf[Status]=$?; EchoTest KO ${PackageAutoconf[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAutoconf[Name]}> make install"
	make install 1> /dev/null && PackageAutoconf[Status]=$? || { PackageAutoconf[Status]=$?; EchoTest KO ${PackageAutoconf[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									Automake								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageAutomake;
PackageAutomake[Name]="automake";
PackageAutomake[Version]="1.17";
PackageAutomake[Extension]=".tar.xz";
PackageAutomake[Package]="${PackageAutomake[Name]}-${PackageAutomake[Version]}";

# 8.47
InstallAutomake()
{
	EchoInfo	"Package ${PackageAutomake[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageAutomake[Package]}"	"${PackageAutomake[Extension]}";

	if ! cd "${PDIR}${PackageAutomake[Package]}"; then
		EchoError	"cd ${PDIR}${PackageAutomake[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageAutomake[Name]}> Configure"
	./configure --prefix=/usr \
				--docdir=/usr/share/doc/automake-1.17 \
				1> /dev/null || { EchoTest KO ${PackageAutomake[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAutomake[Name]}> make"
	make  1> /dev/null || { PackageAutomake[Status]=$?; EchoTest KO ${PackageAutomake[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAutomake[Name]}> make -j\$((\$(nproc)>4\?\$(nproc):4)) check"
	make -j$(($(nproc)>4?$(nproc):4)) check 1> /dev/null || { PackageAutomake[Status]=$?; EchoTest KO ${PackageAutomake[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAutomake[Name]}> make install"
	make install 1> /dev/null && PackageAutomake[Status]=$? || { PackageAutomake[Status]=$?; EchoTest KO ${PackageAutomake[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									OpenSSL									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageOpenSSL;
PackageOpenSSL[Name]="openssl";
PackageOpenSSL[Version]="3.3.1";
PackageOpenSSL[Extension]=".tar.gz";
PackageOpenSSL[Package]="${PackageOpenSSL[Name]}-${PackageOpenSSL[Version]}";

# 8.48
InstallOpenSSL()
{
	EchoInfo	"Package ${PackageOpenSSL[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageOpenSSL[Package]}"	"${PackageOpenSSL[Extension]}";

	if ! cd "${PDIR}${PackageOpenSSL[Package]}"; then
		EchoError	"cd ${PDIR}${PackageOpenSSL[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageOpenSSL[Name]}> Configure"
	./config 	--prefix=/usr \
				--openssldir=/etc/ssl \
				--libdir=lib \
				shared \
				zlib-dynamic \
				1> /dev/null || { EchoTest KO ${PackageOpenSSL[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageOpenSSL[Name]}> make"
	make  1> /dev/null || { PackageOpenSSL[Status]=$?; EchoTest KO ${PackageOpenSSL[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageOpenSSL[Name]}> HARNESS_JOBS=\$(nproc) make test"
	HARNESS_JOBS=$(nproc) make test 1> /dev/null || { PackageOpenSSL[Status]=$?; EchoTest KO ${PackageOpenSSL[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageOpenSSL[Name]}> make install"
	sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
	make MANSUFFIX=ssl install 1> /dev/null && PackageOpenSSL[Status]=$? || { PackageOpenSSL[Status]=$?; EchoTest KO ${PackageOpenSSL[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageOpenSSL[Name]}> Add version to directory name"
	mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.3.1

	EchoInfo	"${PackageOpenSSL[Name]}> Add documentation"
	cp -vfr doc/* /usr/share/doc/openssl-3.3.1
}

# =====================================||===================================== #
#									  Kmod									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageKmod;
PackageKmod[Name]="kmod";
PackageKmod[Version]="33";
PackageKmod[Extension]=".tar.xz";
PackageKmod[Package]="${PackageKmod[Name]}-${PackageKmod[Version]}";

# 8.49
InstallKmod()
{
	EchoInfo	"Package ${PackageKmod[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageKmod[Package]}"	"${PackageKmod[Extension]}";

	if ! cd "${PDIR}${PackageKmod[Package]}"; then
		EchoError	"cd ${PDIR}${PackageKmod[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageKmod[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--with-openssl \
				--with-xz \
				--with-zstd \
				--with-zlib \
				--disable-manpages \
				1> /dev/null || { EchoTest KO ${PackageKmod[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageKmod[Name]}> make"
	make  1> /dev/null || { PackageKmod[Status]=$?; EchoTest KO ${PackageKmod[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageKmod[Name]}> make install"
	make install 1> /dev/null && PackageKmod[Status]=$? || { PackageKmod[Status]=$?; EchoTest KO ${PackageKmod[Name]} && PressAnyKeyToContinue; return 1; };
	for target in depmod insmod modinfo modprobe rmmod; do
		ln -sfv ../bin/kmod /usr/sbin/$target
		rm -fv /usr/bin/$target
	done
}

# =====================================||===================================== #
#									Elfutils								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageElfutils;
PackageElfutils[Name]="elfutils";
PackageElfutils[Version]="0.191";
PackageElfutils[Extension]=".tar.bz2";
PackageElfutils[Package]="${PackageElfutils[Name]}-${PackageElfutils[Version]}";

# 8.50
InstallElfutils()
{
	EchoInfo	"Package ${PackageElfutils[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageElfutils[Package]}"	"${PackageElfutils[Extension]}";

	if ! cd "${PDIR}${PackageElfutils[Package]}"; then
		EchoError	"cd ${PDIR}${PackageElfutils[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageElfutils[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-debuginfod \
				--enable-libdebuginfod=dummy \
				1> /dev/null || { EchoTest KO ${PackageElfutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageElfutils[Name]}> make"
	make  1> /dev/null || { PackageElfutils[Status]=$?; EchoTest KO ${PackageElfutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageElfutils[Name]}> make check"
	make check 1> /dev/null || { PackageElfutils[Status]=$?; EchoTest KO ${PackageElfutils[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageElfutils[Name]}> make install"
	make -C libelf install 1> /dev/null && PackageElfutils[Status]=$? || { PackageElfutils[Status]=$?; EchoTest KO ${PackageElfutils[Name]} && PressAnyKeyToContinue; return 1; };
	install -vm644 config/libelf.pc /usr/lib/pkgconfig 1> /dev/null && PackageElfutils[Status]=$? || { PackageElfutils[Status]=$?; EchoTest KO ${PackageElfutils[Name]} && PressAnyKeyToContinue; return 1; };
	rm /usr/lib/libelf.a
}

# =====================================||===================================== #
#									 Libffi									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibffi;
PackageLibffi[Name]="libffi";
PackageLibffi[Version]="3.4.6";
PackageLibffi[Extension]=".tar.gz";
PackageLibffi[Package]="${PackageLibffi[Name]}-${PackageLibffi[Version]}";

# 8.51
InstallLibffi()
{
	EchoInfo	"Package ${PackageLibffi[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLibffi[Package]}"	"${PackageLibffi[Extension]}";

	if ! cd "${PDIR}${PackageLibffi[Package]}"; then
		EchoError	"cd ${PDIR}${PackageLibffi[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibffi[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--with-gcc-arch=native \
				1> /dev/null || { EchoTest KO ${PackageLibffi[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibffi[Name]}> make"
	make  1> /dev/null || { PackageLibffi[Status]=$?; EchoTest KO ${PackageLibffi[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibffi[Name]}> make check"
	make check 1> /dev/null || { PackageLibffi[Status]=$?; EchoTest KO ${PackageLibffi[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibffi[Name]}> make install"
	make install 1> /dev/null && PackageLibffi[Status]=$? || { PackageLibffi[Status]=$?; EchoTest KO ${PackageLibffi[Name]} && PressAnyKeyToContinue; return 1; };
}

# ============ft_linux===========| 8.52 Python |===========©Othello=========== #

# =====================================||===================================== #
#									FlitCore								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageFlitCore;
PackageFlitCore[Name]="flit_core";
PackageFlitCore[Version]="3.9.0";
PackageFlitCore[Extension]=".tar.gz";
PackageFlitCore[Package]="${PackageFlitCore[Name]}-${PackageFlitCore[Version]}";

# 8.53
InstallFlitCore()
{
	EchoInfo	"Package ${PackageFlitCore[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageFlitCore[Package]}"	"${PackageFlitCore[Extension]}";

	if ! cd "${PDIR}${PackageFlitCore[Package]}"; then
		EchoError	"cd ${PDIR}${PackageFlitCore[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageFlitCore[Name]}> pip3 Build"
	pip3 wheel 	-w dist \
				--no-cache-dir \
				--no-build-isolation \
				--no-deps \
				$PWD 1> /dev/null || { PackageFlitCore[Status]=$?; EchoTest KO ${PackageFlitCore[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageFlitCore[Name]}> pip3 Install"
	pip3 install 	--no-index \
					--no-user \
					--find-links dist flit_core \
					1> /dev/null && PackagePython[Status]=$? || { PackageFlitCore[Status]=$?; EchoTest KO ${PackageFlitCore[Name]} && PressAnyKeyToContinue; return 1; };

	cd -;
}

# =====================================||===================================== #
#									 Wheel									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageWheel;
PackageWheel[Name]="wheel";
PackageWheel[Version]="0.44.0";
PackageWheel[Extension]=".tar.gz";
PackageWheel[Package]="${PackageWheel[Name]}-${PackageWheel[Version]}";

# 8.54
InstallWheel()
{
	EchoInfo	"Package ${PackageWheel[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageWheel[Package]}"	"${PackageWheel[Extension]}";

	if ! cd "${PDIR}${PackageWheel[Package]}"; then
		EchoError	"cd ${PDIR}${PackageWheel[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageWheel[Name]}> pip3 Compile"
	pip3 wheel 	-w dist \
				--no-cache-dir \
				--no-build-isolation \
				--no-deps \
				$PWD \
				1> /dev/null || { EchoTest KO ${PackageWheel[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageWheel[Name]}> pip3 Install"
	pip3 install 	--no-index \
					--find-links=dist \
					wheel \
					1> /dev/null && PackageWheel[Status]=$? || { PackageWheel[Status]=$?; EchoTest KO ${PackageWheel[Name]} && PressAnyKeyToContinue; return 1; };
				}

# =====================================||===================================== #
#								   Setuptools								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageSetuptools;
PackageSetuptools[Name]="setuptools";
PackageSetuptools[Version]="72.2.0";
PackageSetuptools[Extension]=".tar.gz";
PackageSetuptools[Package]="${PackageSetuptools[Name]}-${PackageSetuptools[Version]}";

# 8.55
InstallSetuptools()
{
	EchoInfo	"Package ${PackageSetuptools[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageSetuptools[Package]}"	"${PackageSetuptools[Extension]}";

	if ! cd "${PDIR}${PackageSetuptools[Package]}"; then
		EchoError	"cd ${PDIR}${PackageSetuptools[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageSetuptools[Name]}> pip3 Build"
	pip3 wheel 	-w dist \
				--no-cache-dir \
				--no-build-isolation \
				--no-deps \
				$PWD \
				1> /dev/null || { PackageSetuptools[Status]=$?; EchoTest KO ${PackageSetuptools[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSetuptools[Name]}> pip3 Install"
	pip3 install 	--no-index \
					--find-links dist setuptools \
					1> /dev/null && PackageSetuptools[Status]=$? || { PackageSetuptools[Status]=$?; EchoTest KO ${PackageSetuptools[Name]} && PressAnyKeyToContinue; return 1; };
				}

# =====================================||===================================== #
#									 Ninja									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageNinja;
PackageNinja[Name]="ninja";
PackageNinja[Version]="1.12.1";
PackageNinja[Extension]=".tar.gz";
PackageNinja[Package]="${PackageNinja[Name]}-${PackageNinja[Version]}";

# 8.56
InstallNinja()
{
	EchoInfo	"Package ${PackageNinja[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageNinja[Package]}"	"${PackageNinja[Extension]}";

	if ! cd "${PDIR}${PackageNinja[Package]}"; then
		EchoError	"cd ${PDIR}${PackageNinja[Package]}";
		return 1;
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
	python3 configure.py --bootstrap 1> /dev/null || { EchoTest KO ${PackageNinja[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageNinja[Name]}> install"
	install -vm755 ninja /usr/bin/ 1> /dev/nul && \
	install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja 1> /dev/nul && \
	install -vDm644 misc/zsh-completion /usr/share/zsh/site-functions/_ninja 1> /dev/null && \
	PackageNinja[Status]=$? || { PackageNinja[Status]=$?; EchoTest KO ${PackageNinja[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									 Meson									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMeson;
PackageMeson[Name]="meson";
PackageMeson[Version]="1.5.1";
PackageMeson[Extension]=".tar.gz";
PackageMeson[Package]="${PackageMeson[Name]}-${PackageMeson[Version]}";

# 8.57
InstallMeson()
{
	EchoInfo	"Package ${PackageMeson[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageMeson[Package]}"	"${PackageMeson[Extension]}";

	if ! cd "${PDIR}${PackageMeson[Package]}"; then
		EchoError	"cd ${PDIR}${PackageMeson[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageMeson[Name]}> pip3 Compile"
	pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD 1> /dev/null || { EchoTest KO ${PackageMeson[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMeson[Name]}> pip3 Install"
	pip3 install --no-index --find-links dist meson 1> /dev/null && \
	install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson 1> /dev/null && \
	install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson 1> /dev/null && \
	PackageMeson[Status]=$? || { PackageMeson[Status]=$?; EchoTest KO ${PackageMeson[Name]} && PressAnyKeyToContinue; return 1; };
}

# ===========ft_linux==========| 8.58 Coreutils |==========©Othello=========== #

# =====================================||===================================== #
#									 Check									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageCheck;
PackageCheck[Name]="check";
PackageCheck[Version]="0.15.2";
PackageCheck[Extension]=".tar.gz";
PackageCheck[Package]="${PackageCheck[Name]}-${PackageCheck[Version]}";

# 8.59
InstallCheck()
{
	EchoInfo	"Package ${PackageCheck[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageCheck[Package]}"	"${PackageCheck[Extension]}";

	if ! cd "${PDIR}${PackageCheck[Package]}"; then
		EchoError	"cd ${PDIR}${PackageCheck[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageCheck[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				1> /dev/null || { EchoTest KO ${PackageCheck[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCheck[Name]}> make"
	make  1> /dev/null || { PackageCheck[Status]=$?; EchoTest KO ${PackageCheck[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCheck[Name]}> make check"
	make check 1> /dev/null || { PackageCheck[Status]=$?; EchoTest KO ${PackageCheck[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageCheck[Name]}> make docdir=/usr/share/doc/check-0.15.2 install"
	make docdir=/usr/share/doc/check-0.15.2 install 1> /dev/null && PackageCheck[Status]=$? || { PackageCheck[Status]=$?; EchoTest KO ${PackageCheck[Name]} && PressAnyKeyToContinue; return 1; };
}

# ===========ft_linux==========| 8.60 Diffutils |==========©Othello=========== #

# ============ft_linux============| 8.61 Gawk |===========©Othello============ #

# ===========ft_linux==========| 8.62 Findutils |==========©Othello=========== #

# =====================================||===================================== #
#									 Groff									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGroff;
PackageGroff[Name]="groff";
PackageGroff[Version]="1.23.0";
PackageGroff[Extension]=".tar.gz";
PackageGroff[Package]="${PackageGroff[Name]}-${PackageGroff[Version]}";

# 8.63
InstallGroff()
{
	EchoInfo	"Package ${PackageGroff[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGroff[Package]}"	"${PackageGroff[Extension]}";

	if ! cd "${PDIR}${PackageGroff[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGroff[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageGroff[Name]}> Configure"
	PAGE=A4 ./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageGroff[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGroff[Name]}> make"
	make  1> /dev/null || { PackageGroff[Status]=$?; EchoTest KO ${PackageGroff[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGroff[Name]}> make check"
	make check 1> /dev/null || { PackageGroff[Status]=$?; EchoTest KO ${PackageGroff[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGroff[Name]}> make install"
	make install 1> /dev/null && PackageGroff[Status]=$? || { PackageGroff[Status]=$?; EchoTest KO ${PackageGroff[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									  GRUB									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGRUB;
PackageGRUB[Name]="grub";
PackageGRUB[Version]="2.12";
PackageGRUB[Extension]=".tar.xz";
PackageGRUB[Package]="${PackageGRUB[Name]}-${PackageGRUB[Version]}";

# 8.64
InstallGRUB()
{
	EchoInfo	"Package ${PackageGRUB[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGRUB[Package]}"	"${PackageGRUB[Extension]}";

	if ! cd "${PDIR}${PackageGRUB[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGRUB[Package]}";
		return 1;
	fi

	unset {C,CPP,CXX,LD}FLAGS
	echo depends bli part_gpt > grub-core/extra_deps.lst

	EchoInfo	"${PackageGRUB[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--disable-efiemu \
				--disable-werror \
				1> /dev/null || { EchoTest KO ${PackageGRUB[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGRUB[Name]}> make"
	make  1> /dev/null || { PackageGRUB[Status]=$?; EchoTest KO ${PackageGRUB[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageGRUB[Name]}> make check"
	# make check 1> /dev/null || { PackageGRUB[Status]=$?; EchoTest KO ${PackageGRUB[Name]} && EchoInfo "Most of the tests depend on packages that are not available in the limited LFS environment." && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGRUB[Name]}> make install"
	make install 1> /dev/null && PackageGRUB[Status]=$? || { PackageGRUB[Status]=$?; EchoTest KO ${PackageGRUB[Name]} && PressAnyKeyToContinue; return 1; };
	mv -v 	/etc/bash_completion.d/grub 	/usr/share/bash-completion/completions
}

# ============ft_linux============| 8.65 Gzip |===========©Othello============ #

# =====================================||===================================== #
#									IPRoute2								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageIPRoute2;
PackageIPRoute2[Name]="iproute2";
PackageIPRoute2[Version]="6.10.0";
PackageIPRoute2[Extension]=".tar.xz";
PackageIPRoute2[Package]="${PackageIPRoute2[Name]}-${PackageIPRoute2[Version]}";

# 8.66
InstallIPRoute2()
{
	EchoInfo	"Package ${PackageIPRoute2[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageIPRoute2[Package]}"	"${PackageIPRoute2[Extension]}";

	if ! cd "${PDIR}${PackageIPRoute2[Package]}"; then
		EchoError	"cd ${PDIR}${PackageIPRoute2[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageIPRoute2[Name]}> Prevent arpd man page"
	sed -i /ARPD/d Makefile
	rm -fv man/man8/arpd.8

	EchoInfo	"${PackageIPRoute2[Name]}> make NETNS_RUN_DIR=/run/netns"
	make NETNS_RUN_DIR=/run/netns 1> /dev/null || { PackageIPRoute2[Status]=$?; EchoTest KO ${PackageIPRoute2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageIPRoute2[Name]}> make SBINDIR=/usr/sbin install"
	make SBINDIR=/usr/sbin install 1> /dev/null && PackageIPRoute2[Status]=$? || { PackageIPRoute2[Status]=$?; EchoTest KO ${PackageIPRoute2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageIPRoute2[Name]}> Install documentation"
	mkdir 	-pv 				/usr/share/doc/iproute2-6.10.0
	cp 		-v COPYING README* 	/usr/share/doc/iproute2-6.10.0 1> /dev/null
}

# =====================================||===================================== #
#									  Kbd									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageKbd;
PackageKbd[Name]="kbd";
PackageKbd[Version]="2.6.4";
PackageKbd[Extension]=".tar.xz";
PackageKbd[Package]="${PackageKbd[Name]}-${PackageKbd[Version]}";

# 8.67
InstallKbd()
{
	EchoInfo	"Package ${PackageKbd[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageKbd[Package]}"	"${PackageKbd[Extension]}";

	if ! cd "${PDIR}${PackageKbd[Package]}"; then
		EchoError	"cd ${PDIR}${PackageKbd[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageKbd[Name]}> Patch"
	patch -Np1 -i ../kbd-2.6.4-backspace-1.patch 1> /dev/null || { EchoTest KO ${PackageKbd[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageKbd[Name]}> Remove redundant resizecons program"
	sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
	sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

	EchoInfo	"${PackageKbd[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-vlock \
				1> /dev/null || { EchoTest KO ${PackageKbd[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageKbd[Name]}> make"
	make  1> /dev/null || { PackageKbd[Status]=$?; EchoTest KO ${PackageKbd[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageKbd[Name]}> make check"
	make check 1> /dev/null || { PackageKbd[Status]=$?; EchoTest KO ${PackageKbd[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageKbd[Name]}> make install"
	make install 1> /dev/null && PackageKbd[Status]=$? || { PackageKbd[Status]=$?; EchoTest KO ${PackageKbd[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageIPRoute2[Name]}> Install documentation"
	cp -R -v docs/doc -T /usr/share/doc/kbd-2.6.4
}

# =====================================||===================================== #
#								  Libpipeline								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibpipeline;
PackageLibpipeline[Name]="libpipeline";
PackageLibpipeline[Version]="1.5.7";
PackageLibpipeline[Extension]=".tar.gz";
PackageLibpipeline[Package]="${PackageLibpipeline[Name]}-${PackageLibpipeline[Version]}";

# 8.68
InstallLibpipeline()
{
	EchoInfo	"Package ${PackageLibpipeline[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLibpipeline[Package]}"	"${PackageLibpipeline[Extension]}";

	if ! cd "${PDIR}${PackageLibpipeline[Package]}"; then
		EchoError	"cd ${PDIR}${PackageLibpipeline[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibpipeline[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageLibpipeline[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibpipeline[Name]}> make"
	make  1> /dev/null || { PackageLibpipeline[Status]=$?; EchoTest KO ${PackageLibpipeline[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibpipeline[Name]}> make check"
	make check 1> /dev/null || { PackageLibpipeline[Status]=$?; EchoTest KO ${PackageLibpipeline[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibpipeline[Name]}> make install"
	make install 1> /dev/null && PackageLibpipeline[Status]=$? || { PackageLibpipeline[Status]=$?; EchoTest KO ${PackageLibpipeline[Name]} && PressAnyKeyToContinue; return 1; };
}

# ============ft_linux============| 8.69 Make |===========©Othello============ #

# ============ft_linux===========| 8.70 Patch |===========©Othello============ #

# ============ft_linux============| 8.71 Tar |============©Othello============ #

# ===========ft_linux===========| 8.72 Texinfo |===========©Othello=========== #

# =====================================||===================================== #
#									  Vim									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageVim;
PackageVim[Name]="vim";
PackageVim[Version]="9.1.0660";
PackageVim[Extension]=".tar.gz";
PackageVim[Package]="${PackageVim[Name]}-${PackageVim[Version]}";

# 8.73
InstallVim()
{
	EchoInfo	"Package ${PackageVim[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageVim[Package]}"	"${PackageVim[Extension]}";

	if ! cd "${PDIR}${PackageVim[Package]}"; then
		EchoError	"cd ${PDIR}${PackageVim[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageVim[Name]}> Setting default location for vimrc to /etc";
	echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

	EchoInfo	"${PackageVim[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageVim[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageVim[Name]}> make"
	make  1> /dev/null || { PackageVim[Status]=$?; EchoTest KO ${PackageVim[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageVim[Name]}> make check"
	chown -R tester .
	su tester -c "TERM=xterm-256color LANG=en_US.UTF-8 make -j1 test" < /dev/null &> vim-test.log

	EchoInfo	"${PackageVim[Name]}> make install"
	make install 1> /dev/null && PackageVim[Status]=$? || { PackageVim[Status]=$?; EchoTest KO ${PackageVim[Name]} && PressAnyKeyToContinue; return 1; };

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
}

# =====================================||===================================== #
#								   MarkupSafe								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMarkupSafe;
PackageMarkupSafe[Name]="MarkupSafe";
PackageMarkupSafe[Version]="2.1.5";
PackageMarkupSafe[Extension]=".tar.gz";
PackageMarkupSafe[Package]="${PackageMarkupSafe[Name]}-${PackageMarkupSafe[Version]}";

# 8.74
InstallMarkupSafe()
{
	EchoInfo	"Package ${PackageMarkupSafe[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageMarkupSafe[Package]}"	"${PackageMarkupSafe[Extension]}";

	if ! cd "${PDIR}${PackageMarkupSafe[Package]}"; then
		EchoError	"cd ${PDIR}${PackageMarkupSafe[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageMarkupSafe[Name]}> pip3 Compile"
	pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD 1> /dev/null || { EchoTest KO ${PackageMarkupSafe[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMarkupSafe[Name]}> pip3 Install"
	pip3 install --no-index --no-user --find-links dist Markupsafe 1> /dev/null && PackageMarkupSafe[Status]=$? || { PackageMarkupSafe[Status]=$?; EchoTest KO ${PackageMarkupSafe[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									 Jinja2									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageJinja2;
PackageJinja2[Name]="jinja2";
PackageJinja2[Version]="3.1.4";
PackageJinja2[Extension]=".tar.gz";
PackageJinja2[Package]="${PackageJinja2[Name]}-${PackageJinja2[Version]}";

# 8.75
InstallJinja2()
{
	EchoInfo	"Package ${PackageJinja2[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageJinja2[Package]}"	"${PackageJinja2[Extension]}";

	if ! cd "${PDIR}${PackageJinja2[Package]}"; then
		EchoError	"cd ${PDIR}${PackageJinja2[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageJinja2[Name]}> pip3 Build"
	pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD 1> /dev/null || { EchoTest KO ${PackageJinja2[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageJinja2[Name]}> pip3 Install"
	pip3 install --no-index --no-user --find-links dist Jinja2 1> /dev/null && PackageJinja2[Status]=$? || { PackageJinja2[Status]=$?; EchoTest KO ${PackageJinja2[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									  Udev									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageUdev;
PackageUdev[Name]="Udev";
PackageUdev[Version]="256.4";
PackageUdev[Extension]=".tar.gz";
PackageUdev[Package]="systemd-${PackageUdev[Version]}";

# 8.76
InstallUdev()
{
	EchoInfo	"Package ${PackageUdev[Name]} (From ${PackageUdev[Package]})";

	ReExtractPackage	"${PDIR}"	"${PackageUdev[Package]}"	"${PackageUdev[Extension]}";

	if ! cd "${PDIR}${PackageUdev[Package]}"; then
		EchoError	"cd ${PDIR}${PackageUdev[Package]}";
		return 1;
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
		return ;
	fi
	cd "${PDIR}${PackageUdev[Package]}/build";

	EchoInfo	"${PackageUdev[Name]}> Configure"
	meson setup .. 	--prefix=/usr \
					--buildtype=release \
					-D mode=release \
					-D dev-kvm-mode=0660 \
					-D link-udev-shared=false \
					-D logind=false \
					-D vconsole=false \
					1> /dev/null || { EchoTest KO ${PackageUdev[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageUdev[Name]}> Export udev helpers to env"
	export udev_helpers=$(grep "'name' :" ../src/udev/meson.build | awk '{print $3}' | tr -d ",'" | grep -v 'udevadm')

	EchoInfo	"${PackageUdev[Name]}> Build"
	ninja 	udevadm systemd-hwdb \
			$(ninja -n | grep -Eo '(src/(lib)?udev|rules.d|hwdb.d)/[^ ]*') \
			$(realpath libudev.so --relative-to .) \
			$udev_helpers \
			1> /dev/null || { PackageUdev[Status]=$?; EchoTest KO ${PackageUdev[Name]} && PressAnyKeyToContinue; return 1; };

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
	PackageUdev[Status]=$? || { PackageUdev[Status]=$?; EchoTest KO ${PackageUdev[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageUdev[Name]}> Install custom rules and support files"
	tar -xvf ../../udev-lfs-20230818.tar.xz || { PackageUdev[Status]=$?; EchoTest KO ${PackageUdev[Name]} && PressAnyKeyToContinue; return 1; };
	make -f udev-lfs-20230818/Makefile.lfs install || { PackageUdev[Status]=$?; EchoTest KO ${PackageUdev[Name]} && PressAnyKeyToContinue; return 1; };

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
}

# =====================================||===================================== #
#									 ManDB									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageManDB;
PackageManDB[Name]="man-db";
PackageManDB[Version]="2.12.1";
PackageManDB[Extension]=".tar.xz";
PackageManDB[Package]="${PackageManDB[Name]}-${PackageManDB[Version]}";

# 8.77
InstallManDB()
{
	EchoInfo	"Package ${PackageManDB[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageManDB[Package]}"	"${PackageManDB[Extension]}";

	if ! cd "${PDIR}${PackageManDB[Package]}"; then
		EchoError	"cd ${PDIR}${PackageManDB[Package]}";
		return 1;
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
				1> /dev/null || { EchoTest KO ${PackageManDB[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageManDB[Name]}> make"
	make  1> /dev/null || { PackageManDB[Status]=$?; EchoTest KO ${PackageManDB[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageManDB[Name]}> make check"
	make check 1> /dev/null || { PackageManDB[Status]=$?; EchoTest KO ${PackageManDB[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageManDB[Name]}> make install"
	make install 1> /dev/null && PackageManDB[Status]=$? || { PackageManDB[Status]=$?; EchoTest KO ${PackageManDB[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									ProcpsNg								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageProcpsNg;
PackageProcpsNg[Name]="procps-ng";
PackageProcpsNg[Version]="4.0.4";
PackageProcpsNg[Extension]=".tar.xz";
PackageProcpsNg[Package]="${PackageProcpsNg[Name]}-${PackageProcpsNg[Version]}";

# 8.78
InstallProcpsNg()
{
	EchoInfo	"Package ${PackageProcpsNg[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageProcpsNg[Package]}"	"${PackageProcpsNg[Extension]}";

	if ! cd "${PDIR}${PackageProcpsNg[Package]}"; then
		EchoError	"cd ${PDIR}${PackageProcpsNg[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageProcpsNg[Name]}> Configure"
	./configure --prefix=/usr \
				--docdir=/usr/share/doc/procpsNg-4.0.4 \
				--disable-static \
				--disable-kill \
				1> /dev/null || { EchoTest KO ${PackageProcpsNg[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageProcpsNg[Name]}> make"
	make  1> /dev/null || { PackageProcpsNg[Status]=$?; EchoTest KO ${PackageProcpsNg[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageProcpsNg[Name]}> su tester -c \"PATH=\$PATH make check\""
	chown -R tester .
	su tester -c "PATH=$PATH make check" 1> /dev/null || { PackageProcpsNg[Status]=$?; EchoTest KO ${PackageProcpsNg[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageProcpsNg[Name]}> make install"
	make install 1> /dev/null && PackageProcpsNg[Status]=$? || { PackageProcpsNg[Status]=$?; EchoTest KO ${PackageProcpsNg[Name]} && PressAnyKeyToContinue; return 1; };
}

# ===========ft_linux==========| 8.79 UtilLinux |==========©Othello=========== #

# =====================================||===================================== #
#								   E2fsprogs								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageE2fsprogs;
PackageE2fsprogs[Name]="e2fsprogs";
PackageE2fsprogs[Version]="1.47.1";
PackageE2fsprogs[Extension]=".tar.gz";
PackageE2fsprogs[Package]="${PackageE2fsprogs[Name]}-${PackageE2fsprogs[Version]}";

# 8.80
InstallE2fsprogs()
{
	EchoInfo	"Package ${PackageE2fsprogs[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageE2fsprogs[Package]}"	"${PackageE2fsprogs[Extension]}";

	if ! cd "${PDIR}${PackageE2fsprogs[Package]}"; then
		EchoError	"cd ${PDIR}${PackageE2fsprogs[Package]}";
		return 1;
	fi

	if ! mkdir -p build; then
		PackageE2fsprogs[Status]=1; 
		EchoError	"Failed to make ${PDIR}${PackageE2fsprogs[Name]}/build";
		return ;
	fi
	cd "${PDIR}${PackageE2fsprogs[Package]}/build";

	EchoInfo	"${PackageE2fsprogs[Name]}> Configure"
	../configure 	--prefix=/usr \
					--sysconfdir=/etc \
					--enable-elf-shlibs \
					--disable-libblkid \
					--disable-libuuid \
					--disable-uuidd \
					--disable-fsck \
					1> /dev/null || { EchoTest KO ${PackageE2fsprogs[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageE2fsprogs[Name]}> make"
	make  1> /dev/null || { PackageE2fsprogs[Status]=$?; EchoTest KO ${PackageE2fsprogs[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageE2fsprogs[Name]}> make check"
	make check &> TempMakeCheck.log ||
	if [ $(grep ": failed" TempMakeCheck.log | grep -v "m_assume_storage_prezeroed" -c) -gt 0 ]; then
		PackageE2fsprogs[Status]=$(grep ": failed" TempMakeCheck.log -c)
		EchoTest KO ${PackageE2fsprogs[Name]}
		grep " test failed" TempMakeCheck.log
		grep ": failed" TempMakeCheck.log
		PressAnyKeyToContinue;
		return 1;
	else
		EchoTest OK ${PackageE2fsprogs[Name]}
		grep " test failed" TempMakeCheck.log
		grep ": failed" TempMakeCheck.log
	fi
	rm TempMakeCheck.log

	EchoInfo	"${PackageE2fsprogs[Name]}> make install"
	make install 1> /dev/null && PackageE2fsprogs[Status]=$? || { PackageE2fsprogs[Status]=$?; EchoTest KO ${PackageE2fsprogs[Name]} && PressAnyKeyToContinue; return 1; };

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
}

# =====================================||===================================== #
#									Sysklogd								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageSysklogd;
PackageSysklogd[Name]="sysklogd";
PackageSysklogd[Version]="2.6.1";
PackageSysklogd[Extension]=".tar.gz";
PackageSysklogd[Package]="${PackageSysklogd[Name]}-${PackageSysklogd[Version]}";

# 8.81
InstallSysklogd()
{
	EchoInfo	"Package ${PackageSysklogd[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageSysklogd[Package]}"	"${PackageSysklogd[Extension]}";

	if ! cd "${PDIR}${PackageSysklogd[Package]}"; then
		EchoError	"cd ${PDIR}${PackageSysklogd[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageSysklogd[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--runstatedir=/run \
				--without-logger \
				1> /dev/null || { EchoTest KO ${PackageSysklogd[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSysklogd[Name]}> make"
	make  1> /dev/null || { PackageSysklogd[Status]=$?; EchoTest KO ${PackageSysklogd[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSysklogd[Name]}> make install"
	make install 1> /dev/null && PackageSysklogd[Status]=$? || { PackageSysklogd[Status]=$?; EchoTest KO ${PackageSysklogd[Name]} && PressAnyKeyToContinue; return 1; };

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
}

# =====================================||===================================== #
#									SysVinit								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageSysVinit;
PackageSysVinit[Name]="sysvinit";
PackageSysVinit[Version]="3.10";
PackageSysVinit[Extension]=".tar.xz";
PackageSysVinit[Package]="${PackageSysVinit[Name]}-${PackageSysVinit[Version]}";

# 8.82
InstallSysVinit()
{
	EchoInfo	"Package ${PackageSysVinit[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageSysVinit[Package]}"	"${PackageSysVinit[Extension]}";

	if ! cd "${PDIR}${PackageSysVinit[Package]}"; then
		EchoError	"cd ${PDIR}${PackageSysVinit[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageSysVinit[Name]}> Patch"
	patch -Np1 -i ../sysvinit-3.10-consolidated-1.patch

	EchoInfo	"${PackageSysVinit[Name]}> make"
	make  1> /dev/null || { PackageSysVinit[Status]=$?; EchoTest KO ${PackageSysVinit[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSysVinit[Name]}> make install"
	make install 1> /dev/null && PackageSysVinit[Status]=$? || { PackageSysVinit[Status]=$?; EchoTest KO ${PackageSysVinit[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#						9.2. LFS-Bootscripts-20240825						   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLFSBootscript;
PackageLFSBootscript[Name]="lfs-bootscripts";
PackageLFSBootscript[Version]="20240825";
PackageLFSBootscript[Extension]=".tar.xz";
PackageLFSBootscript[Package]="${PackageLFSBootscript[Name]}-${PackageLFSBootscript[Version]}";

InstallLFSBootscript()
{
	EchoInfo	"Package ${PackageLFSBootscript[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLFSBootscript[Package]}"	"${PackageLFSBootscript[Extension]}";

	if ! cd "${PDIR}${PackageLFSBootscript[Package]}"; then
		EchoError	"cd ${PDIR}${PackageLFSBootscript[Package]}";
		return;
	fi

	EchoInfo	"${PackageLFSBootscript[Name]}> make install"
	make install 1> /dev/null && PackageLFSBootscript[Status]=$? || { PackageLFSBootscript[Status]=$?; EchoTest KO ${PackageLFSBootscript[Name]} && PressAnyKeyToContinue; return; };
}

# =====================================||===================================== #
#								10.3. Linux-6.10.5							   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLinux;
PackageLinux[Name]="linux";
PackageLinux[Version]="6.10.5";
PackageLinux[Extension]=".tar.xz";
PackageLinux[Package]="${PackageLinux[Name]}-${PackageLinux[Version]}";

InstallLinux()
{
	EchoInfo	"Package ${PackageLinux[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLinux[Package]}"	"${PackageLinux[Extension]}";

	if ! cd "${PDIR}${PackageLinux[Package]}"; then
		EchoError	"cd ${PDIR}${PackageLinux[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLinux[Name]}> make mrproper"
	make mrproper 1> /dev/null || { PackageLinux[Status]=$?; EchoTest KO ${PackageLinux[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLinux[Name]}> make defconfig (Sets menuconfig to good starting values)";
	make defconfig 1> /dev/null || { PackageLinux[Status]=$?; EchoTest KO ${PackageLinux[Name]} && PressAnyKeyToContinue; return 1; };
	EchoInfo	"${PackageLinux[Name]}> Adjusting config values";
	# General setup --->
		scripts/config --disable CONFIG_WERROR
		# CPU/Task time and stats accounting --->
			scripts/config --enable CONFIG_PSI
			scripts/config --disable CONFIG_PSI_DEFAULT_DISABLED
		scripts/config --disable CONFIG_IKHEADERS
		scripts/config --enable CONFIG_CGROUPS
			scripts/config --enable CONFIG_MEMCG
		scripts/config --disable CONFIG_EXPERT
	# Processor type and features --->
		scripts/config --enable CONFIG_RELOCATABLE
		scripts/config --enable CONFIG_RANDOMIZE_BASE
		scripts/config --enable CONFIG_X86_X2APIC #64
	# General architecture-dependent options --->
		scripts/config --enable CONFIG_STACKPROTECTOR
		scripts/config --enable CONFIG_STACKPROTECTOR_STRONG
	# Device Drivers --->
		# Generic Driver Options --->
			scripts/config --disable CONFIG_UEVENT_HELPER
			scripts/config --enable CONFIG_DEVTMPFS
			scripts/config --enable CONFIG_DEVTMPFS_MOUNT
		# Graphics support --->
			scripts/config --module CONFIG_DRM # Required to add GUI later
				scripts/config --enable CONFIG_DRM_FBDEV_EMULATION
				scripts/config --module CONFIG_DRM_RADEON # Required by BLFS for Mesa in r300 or r600
				scripts/config --module CONFIG_DRM_AMDGPU # Required by BLFS for Mesa in radeonsi
				scripts/config --enable CONFIG_DRM_AMDGPU_SI # Required by BLFS for Mesa in radeonsi
				scripts/config --enable CONFIG_DRM_AMDGPU_CIK # Required by BLFS for Mesa in radeonsi
				scripts/config --enable CONFIG_DRM_AMD_DC # Required by BLFS for Mesa in radeonsi
				scripts/config --module CONFIG_DRM_NOUVEAU # Required by BLFS for Mesa in nouveau
				scripts/config --enable CONFIG_DRM_NOUVEAU_GSP_DEFAULT # Required by BLFS for Mesa in nouveau
				scripts/config --module CONFIG_DRM_I915 # Required by BLFS for Mesa in i915, crocus, or iris
				scripts/config --module CONFIG_DRM_VGEM # Required by BLFS for Mesa in llvmpipe or softpipe
				scripts/config --enable CONFIG_DRM_VMWGFX # Required by BLFS for Mesa in svga
			# Console display driver support --->
				scripts/config --enable CONFIG_FRAMEBUFFER_CONSOLE
		scripts/config --enable CONFIG_PCI #64
			scripts/config --enable CONFIG_PCI_MSI #64
		scripts/config --enable CONFIG_IOMMU_SUPPORT #64
			scripts/config --enable CONFIG_IRQ_REMAP #64

	# # Added for size
	# scripts/config --enable CONFIG_FB_SIMPLE

	EchoInfo	"${PackageLinux[Name]}> make olddefconfig (replacing make menuconfig)";
	make olddefconfig 1> /dev/null || { PackageLinux[Status]=$?; EchoTest KO ${PackageLinux[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLinux[Name]}> make"
	make  1> /dev/null || { PackageLinux[Status]=$?; EchoTest KO ${PackageLinux[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLinux[Name]}> make modules_install"
	make modules_install 1> /dev/null && PackageLinux[Status]=$? || { PackageLinux[Status]=$?; EchoTest KO ${PackageLinux[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLinux[Name]}> Ensuring /boot in mounted";
	mountpoint /boot || mount /dev/sda1 /boot;

	EchoInfo	"${PackageLinux[Name]}> Copying crucial files for GRUB boot";
	cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.10.5-lfs-12.2
	cp -iv System.map /boot/System.map-6.10.5
	cp -iv .config /boot/config-6.10.5
	cp -r Documentation -T /usr/share/doc/linux-6.10.5

	# 10.3.2. Configuring Linux Module Load Order
	EchoInfo	"Configuring Linux Module Load Order"
	install -v -m755 -d /etc/modprobe.d
	EchoInfo	"/etc/modprobe.d/usb.conf"
	cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF
}
