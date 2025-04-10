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
PackageBinutils[Name]="Binutils";
PackageBinutils[Version]="2.43.1";
PackageBinutils[Version]="${PackageBinutils[Name]}-${PackageBinutils[Version]}";
PackageBinutils[Extension]=".tar.xz";

InstallBinutilsCT1()
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
					1> /dev/null; || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBinutils[Name]}> make"
	make  1> /dev/null || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageBinutils[Name]}> make check"
	make check 1> /dev/null || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageBinutils[Name]}> make install"
	make install 1> /dev/null && PackageBinutils[Status]=$? || { PackageBinutils[Status]=$?; EchoTest KO ${PackageBinutils[Name]} && PressAnyKeyToContinue; return; };
}

# =====================================||===================================== #
#									  GCC									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGCC;
PackageGCC[Name]="gcc";
PackageGCC[Version]="14.2.0";
PackageGCC[Package]="${PackageGCC[Name]}-${PackageGCC[Version]}";
PackageGCC[Extension]=".tar.xz";

InstallGCC()
{
	EchoInfo	"Package ${PackageGCC[Name]}"

	ReExtractPackage	"${PDIR}"						"${PackageGCC[Package]}"	"${PackageGCC[Extension]}";
	ReExtractPackage	"${PDIR}${PackageGCC[Package]}"	"mpfr-4.2.1"				".tar.xz";
	ReExtractPackage	"${PDIR}${PackageGCC[Package]}"	"gmp-6.3.0"					".tar.xz";
	ReExtractPackage	"${PDIR}${PackageGCC[Package]}"	"mpc-1.3.1"					".tar.gz";

	if ! cd "${PDIR}${PackageGCC[Package]}"; then
		EchoError	"cd ${PDIR}${PackageGCC[Package]}";
		return;
	fi

	case $(uname -m) in
		x86_64) sed -e '/m64=/s/lib64/lib/' -i.orig "${PDIR}${PackageGCC[package]}/gcc/config/i386/t-linux64";;
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

	EchoInfo	"${PackageGCC[Name]}> make check"
	make check 1> /dev/null || { PackageGCC[Status]=$?; EchoTest KO ${PackageGCC[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageGCC[Name]}> make install"
	make install 1> /dev/null && PackageGCC[Status]=$? || { PackageGCC[Status]=$?; EchoTest KO ${PackageGCC[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageGCC[Name]}> Copying header files..."
	cat ${PDIR}${PackageGCC[Package]}/gcc/limitx.h \
		${PDIR}${PackageGCC[Package]}/gcc/glimits.h \
		${PDIR}${PackageGCC[Package]}/gcc/limity.h \
		> $(dirname $($LFS_TGT-gcc -print-libgcc-file-name))/include/limits.h
}

# =====================================||===================================== #
#								Linux API Headers							   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLinuxAPI;
PackageLinuxAPI[Name]="linux";
PackageLinuxAPI[Version]="6.10.5";
PackageGCC[Package]="${PackageLinuxAPI[Name]}-${PackageLinuxAPI[Version]}";
PackageLinuxAPI[Extension]=".tar.xz";

InstallLinuxAPI()
{
	EchoInfo	"Package ${PackageLinuxAPI[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageLinuxAPI[Name]}-${PackageLinuxAPI[Version]}"	"${PackageLinuxAPI[Extension]}";

	if ! cd "${PDIR}${PackageLinuxAPI[Name]}-${PackageLinuxAPI[Version]}"; then
		EchoError	"cd ${PDIR}${PackageLinuxAPI[Name]}-${PackageLinuxAPI[Version]}";
		return;
	fi

	EchoInfo	"${PackageLinuxAPI[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { PackageLinuxAPI[Status]=$?; EchoTest KO ${PackageLinuxAPI[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLinuxAPI[Name]}> make mrproper"
	make mrproper 1> /dev/null || { PackageLinuxAPI[Status]=$?; EchoTest KO ${PackageLinuxAPI[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLinuxAPI[Name]}> make headers"
	make headers 1> /dev/null || { PackageLinuxAPI[Status]=$?; EchoTest KO ${PackageLinuxAPI[Name]} && PressAnyKeyToContinue; return; };
	
	EchoInfo	"${PackageLinuxAPI[Name]}> Copying headers to $LFS/usr/include...";
	find usr/include -type f ! -name '*.h' -delete
	echo	"${C_DGRAY}> cp -rv usr/include \$LFS/usr 1> /dev/null${C_RESET}";
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

InstallGlibc()
{
	EchoInfo	"Package ${PackageGlibc[Name]}"

	ReExtractPackage	"${PDIR}"	"${PackageGlibc[Name]}-${PackageGlibc[Version]}"	"${PackageGlibc[Extension]}";

	if ! cd "${PDIR}${PackageGlibc[Name]}-${PackageGlibc[Version]}"; then
		EchoError	"cd ${PDIR}${PackageGlibc[Name]}-${PackageGlibc[Version]}";
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
	cd "${PDIR}${PackageGlibc[Name]}-${PackageGlibc[Version]}/build";

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
		echo	"${C_DGRAY}> make DESTDIR=\$LFS install 1> /dev/null${C_RESET}";
		make DESTDIR=$LFS install 1> /dev/null || {EchoTest KO ${glibc[package]} && PressAnyKeyToContinue; return;};
	else
		EchoError "Almost made build unstable with glibc!";
		PressAnyKeyToContinue;
		return 1;
	fi

	EchoInfo	"${PackageGlibc[Name]}> Fixing hardcoded path...";
	sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
}

# =====================================||===================================== #
#									libstdcpp								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibstdCPP;
PackageLibstdCPP[Name]="libstdc++";
PackageLibstdCPP[Version]="";
PackageLibstdCPP[Package]="${PackageGCC[Package]}";
PackageLibstdCPP[Extension]="${PackageGCC[Extension]}";

InstallLibstdCPP()
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

	EchoInfo	"${PackageLibstdCPP[Name]}> make DESTDIR=\$LFS install"
	make DESTDIR=$LFS install 1> /dev/null || { PackageLibstdCPP[Status]=$?; EchoTest KO ${PackageLibstdCPP[Name]} && PressAnyKeyToContinue; return; };

	EchoInfo	"${PackageLibstdCPP[Name]}> Removing libtool archive files...";
	echo	"${C_DGRAY}(they are harmful for cross-compilation)${C_RESET}";
	rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la
}
