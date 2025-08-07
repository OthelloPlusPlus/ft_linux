#!/bin/bash

if [ ! -z "${PackageXorgLibraries[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#								 XorgLibraries								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXorgLibraries;
PackageXorgLibraries[Source]="https://www.x.org/pub/individual/lib/";
# PackageXorgLibraries[MD5]="";
PackageXorgLibraries[Name]="XorgLibraries";
# PackageXorgLibraries[Version]="";
# PackageXorgLibraries[Package]="${PackageXorgLibraries[Name]}-${PackageXorgLibraries[Version]}";
# PackageXorgLibraries[Extension]=".tar.xz";

PackageXorgLibraries[Programs]="cxpm sxpm";
PackageXorgLibraries[Libraries]="libfontenc.so libFS.so libICE.so libpciaccess.so libSM.so libX11.so libX11-xcb libXaw6.so libXaw7.so libXaw.so libXcomposite.so libXcursor.so libXdamage.so libXext.so libXfixes.so libXfont2.so libXft.so libXinerama.so libXi.so libxkbfile.so libXmu.so libXmuu.so libXpm.so libXpresent.so libXrandr.so libXrender.so libXRes.so libxshmfence.so libXss.so libXt.so libXtst.so libXvMC.so libXvMCW.so libXv.so libXxf86dga.so libXxf86vm.so";
PackageXorgLibraries[Python]="";

InstallXorgLibraries()
{
	# Check Installation
	CheckXorgLibraries && return $?;

	# Check Dependencies
	EchoInfo	"${PackageXorgLibraries[Name]}> Checking dependencies..."
	Dependencies=(LibXcb FreeTypeChain)
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	Optional=(Asciidoc Xmlto Fop Links Lynx)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh";
		fi
	done
	
	# Install Package
	{PDIR}=/usr/src/;
	_DownloadPackageList;
	_BuildXorgLibraries;
	return $?
}

CheckXorgLibraries()
{
	CheckInstallation 	"${PackageXorgLibraries[Programs]}"\
						"${PackageXorgLibraries[Libraries]}"\
						"${PackageXorgLibraries[Python]}" 1> /dev/null;
	return $?;
}

CheckXorgLibrariesVerbose()
{
	CheckInstallationVerbose	"${PackageXorgLibraries[Programs]}"\
								"${PackageXorgLibraries[Libraries]}"\
								"${PackageXorgLibraries[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

# Wrapper for compatiblity
_ExtractPackageXorgLibraries()
{
	_DownloadPackageList

	return $?;
}
_BuildXorgLibraries()
{
	EchoInfo	"Package ${PackageXorgLibraries[Name]}"

for package in $(grep -v '^#' ../lib-7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.?z*}
  echo "Building $packagedir"

  tar -xf $package
  pushd $packagedir
  docdir="--docdir=$XORG_PREFIX/share/doc/$packagedir"
  
  case $packagedir in
    libXfont2-[0-9]* )
      ./configure $XORG_CONFIG $docdir --disable-devel-docs
    ;;

    libXt-[0-9]* )
      ./configure $XORG_CONFIG $docdir \
                  --with-appdefaultdir=/etc/X11/app-defaults
    ;;

    libXpm-[0-9]* )
      ./configure $XORG_CONFIG $docdir --disable-open-zfile
    ;;
  
    libpciaccess* )
      mkdir build
      cd    build
        meson setup --prefix=$XORG_PREFIX --buildtype=release ..
        ninja
        #ninja test
        _AsRoot ninja install || return $?;
      popd     # $packagedir
      continue # for loop
    ;;

    * )
      ./configure $XORG_CONFIG $docdir
    ;;
  esac

  make
  #make check 2>&1 | tee ../$packagedir-make_check.log
  _AsRoot make install || return $?;
  popd
  rm -rf $packagedir
  _AsRoot /sbin/ldconfig || return $?;
done
}

_AsRoot()
{
	EchoInfo	"${PackageXorgLibraries[Name]}> $* $package"
	if   [ $EUID = 0 ]; then 
		$* 1> /dev/null || { EchoTest KO ${PackageXorgLibraries[Name]} && PressAnyKeyToContinue; return 1; };
	elif [ -x /usr/bin/sudo ]; then 
		sudo $* 1> /dev/null || { EchoTest KO ${PackageXorgLibraries[Name]} && PressAnyKeyToContinue; return 1; };
	else
		su -c \\"$*\\" 1> /dev/null || { EchoTest KO ${PackageXorgLibraries[Name]} && PressAnyKeyToContinue; return 1; };
	fi
}

_DownloadPackageList()
{
	if [ ! -d "${SHMAN_PDIR}/${PackageXorgLibraries[Name]}" ]; then
		mkdir -p "${SHMAN_PDIR}/${PackageXorgLibraries[Name]}";
	fi
	cd "${SHMAN_PDIR}/${PackageXorgLibraries[Name]}"

	cat > lib-7.md5 << "EOF"
1155b410c778f805659baf4373db2b92  xtrans-1.5.2.tar.xz
e12f988eb037b978071e21b2d58d1d70  libX11-1.8.11.tar.xz
e59476db179e48c1fb4487c12d0105d1  libXext-1.3.6.tar.xz
c5cc0942ed39c49b8fcd47a427bd4305  libFS-1.0.10.tar.xz
d1ffde0a07709654b20bada3f9abdd16  libICE-1.1.2.tar.xz
ef6167bfcb675f65a790e0f517a87455  libSM-1.2.5.tar.xz
e613751d38e13aa0d0fd8e0149cec057  libXScrnSaver-1.2.4.tar.xz
9acd189c68750b5028cf120e53c68009  libXt-1.3.1.tar.xz
85edefb7deaad4590a03fccba517669f  libXmu-1.2.1.tar.xz
05b5667aadd476d77e9b5ba1a1de213e  libXpm-3.5.17.tar.xz
2a9793533224f92ddad256492265dd82  libXaw-1.0.16.tar.xz
65b9ba1e9ff3d16c4fa72915d4bb585a  libXfixes-6.0.1.tar.xz
af0a5f0abb5b55f8411cd738cf0e5259  libXcomposite-0.4.6.tar.xz
4c54dce455d96e3bdee90823b0869f89  libXrender-0.9.12.tar.xz
5ce55e952ec2d84d9817169d5fdb7865  libXcursor-1.2.3.tar.xz
ca55d29fa0a8b5c4a89f609a7952ebf8  libXdamage-1.1.6.tar.xz
8816cc44d06ebe42e85950b368185826  libfontenc-1.1.8.tar.xz
66e03e3405d923dfaf319d6f2b47e3da  libXfont2-2.0.7.tar.xz
cea0a3304e47a841c90fbeeeb55329ee  libXft-2.3.8.tar.xz
95a960c1692a83cc551979f7ffe28cf4  libXi-1.8.2.tar.xz
228c877558c265d2f63c56a03f7d3f21  libXinerama-1.1.5.tar.xz
24e0b72abe16efce9bf10579beaffc27  libXrandr-1.5.4.tar.xz
66c9e9e01b0b53052bb1d02ebf8d7040  libXres-1.2.2.tar.xz
b62dc44d8e63a67bb10230d54c44dcb7  libXtst-1.2.5.tar.xz
8a26503185afcb1bbd2c65e43f775a67  libXv-1.0.13.tar.xz
a90a5f01102dc445c7decbbd9ef77608  libXvMC-1.0.14.tar.xz
74d1acf93b83abeb0954824da0ec400b  libXxf86dga-1.1.6.tar.xz
d3db4b6dc924dc151822f5f7e79ae873  libXxf86vm-1.1.6.tar.xz
57c7efbeceedefde006123a77a7bc825  libpciaccess-0.18.1.tar.xz
229708c15c9937b6e5131d0413474139  libxkbfile-1.1.3.tar.xz
9805be7e18f858bed9938542ed2905dc  libxshmfence-1.3.3.tar.xz
bdd3ec17c6181fd7b26f6775886c730d  libXpresent-1.0.1.tar.xz
EOF

	if [ ! -d "${SHMAN_PDIR}/${PackageXorgLibraries[Name]}/lib" ]; then
		mkdir -p "${SHMAN_PDIR}/${PackageXorgLibraries[Name]}/lib";
	fi
	cd "${SHMAN_PDIR}/${PackageXorgLibraries[Name]}/lib"

	grep -v '^#' ../lib-7.md5 | \
		awk '{print $2}' | \
		wget -i- -c -B https://www.x.org/pub/individual/lib/ > /dev/null

	md5sum -c ../lib-7.md5
}
