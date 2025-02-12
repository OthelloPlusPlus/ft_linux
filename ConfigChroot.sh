history -c
# C_RESET="\x1b[0m";
# C_RED="\x1b[38;2;255;0;0m";

EchoError()
{
	echo "[${C_RED}ERR${C_RESET} ]  $1" >&2;
	PressAnyKeyToContinue;
	exit;
}

PressAnyKeyToContinue()
{
	if [ -t 0 ]; then echo 'Press any key to continue...'; stty -echo -icanon; input=$(dd bs=1 count=1 2>/dev/null); stty sane;
	else echo "Press Enter/Return to continue..."; read -n 1 input;
	fi
}

# 7.5. Creating Directories

# Create some root-level directories {boot,home,mnt,opt,srv}
mkdir -pv /{boot,home,mnt,opt,srv};

# Create the required set of subdirectories below the root-level
mkdir -pv /etc/{opt,sysconfig}
mkdir -pv /lib/firmware
mkdir -pv /media/{floppy,cdrom}
mkdir -pv /usr/{,local/}{include,src}
mkdir -pv /usr/lib/locale
mkdir -pv /usr/local/{bin,lib,sbin}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}share/man/man{1..8}
mkdir -pv /var/{cache,local,log,mail,opt,spool}
mkdir -pv /var/lib/{color,misc,locate}

ln -sfv /run /var/run
ln -sfv /run/lock /var/lock

install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp

# 7.6. Creating Essential Files and Symlinks

# Create a symbolic link for mounts
ln -sv /proc/self/mounts /etc/mtab

# Create a basic /etc/hosts file
cat > /etc/hosts << EOF
127.0.0.1 localhost $(hostname)
::1       localhost
EOF

# Create the /etc/passwd file
cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF

# Create the /etc/group file
cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
uuidd:x:80:
wheel:x:97:
users:x:999:
nogroup:x:65534:
EOF

# Defining locale
localedef -i C -f UTF-8 C.UTF-8

# Creating temporary 'tester' user
echo "tester:x:101:101::/home/tester:/bin/bash" >> /etc/passwd
echo "tester:x:101:" >> /etc/group
install -o tester -d /home/tester

# Create log files
touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664 /var/log/lastlog
chmod -v 600 /var/log/btmp

PDIR="/sources/lfs-packages12.2/";

# 7.7 - 7.12 Packages
ExtractPackage()
{
	tar -xf "${PDIR}${1}" -C "${PDIR}";
}

# gettext
PACKAGE="gettext";
VERSION="0.22.5";
EXTENSION=".tar.xz";

ExtractPackage "${PACKAGE}-${VERSION}${EXTENSION}";
cd "${PDIR}${PACKAGE}-${VERSION}";

./configure --disable-shared || EchoError "Configure ${PACKAGE}" >&2;
make || EchoError "make ${PACKAGE}" >&2;
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

cd -;
rm -rf "${PDIR}${PACKAGE}-${VERSION}"

# bison
PACKAGE="bison";
VERSION="3.8.2";
EXTENSION=".tar.xz";

ExtractPackage "${PACKAGE}-${VERSION}${EXTENSION}";
cd "${PDIR}${PACKAGE}-${VERSION}";

./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2 || EchoError "Configure ${PACKAGE}" >&2;
make || EchoError "make ${PACKAGE}" >&2;
make install || EchoError "make install ${PACKAGE}" >&2;

cd -;
rm -rf "${PDIR}${PACKAGE}-${VERSION}"

# perl
PACKAGE="perl";
VERSION="5.40.0";
EXTENSION=".tar.xz";

ExtractPackage "${PACKAGE}-${VERSION}${EXTENSION}";
cd "${PDIR}${PACKAGE}-${VERSION}";

sh Configure -des -D prefix=/usr -D vendorprefix=/usr -D useshrplib -D privlib=/usr/lib/perl5/5.40/core_perl -D archlib=/usr/lib/perl5/5.40/core_perl -D sitelib=/usr/lib/perl5/5.40/site_perl -D sitearch=/usr/lib/perl5/5.40/site_perl -D vendorlib=/usr/lib/perl5/5.40/vendor_perl -D vendorarch=/usr/lib/perl5/5.40/vendor_perl || EchoError "Configure ${PACKAGE}" >&2;
make || EchoError "make ${PACKAGE}" >&2;
make install || EchoError "make install ${PACKAGE}" >&2;

cd -;
rm -rf "${PDIR}${PACKAGE}-${VERSION}"

# python
PACKAGE="Python";
VERSION="3.12.5";
EXTENSION=".tar.xz";

ExtractPackage "${PACKAGE}-${VERSION}${EXTENSION}";
cd "${PDIR}${PACKAGE}-${VERSION}";

./configure --prefix=/usr --enable-shared --without-ensurepip || EchoError "Configure ${PACKAGE}" >&2;
make || EchoError "make ${PACKAGE}" >&2;
make install || EchoError "make install ${PACKAGE}" >&2;

cd -;
rm -rf "${PDIR}${PACKAGE}-${VERSION}"

# texinfo
PACKAGE="texinfo";
VERSION="7.1";
EXTENSION=".tar.xz";

ExtractPackage "${PACKAGE}-${VERSION}${EXTENSION}";
cd "${PDIR}${PACKAGE}-${VERSION}";

./configure --prefix=/usr || EchoError "Configure ${PACKAGE}" >&2;
make || EchoError "make ${PACKAGE}" >&2;
make install || EchoError "make install ${PACKAGE}" >&2;

cd -;
rm -rf "${PDIR}${PACKAGE}-${VERSION}"

# util-linux
PACKAGE="util-linux";
VERSION="2.40.2";
EXTENSION=".tar.xz";

ExtractPackage "${PACKAGE}-${VERSION}${EXTENSION}";
cd "${PDIR}${PACKAGE}-${VERSION}";

mkdir -pv /var/lib/hwclock
./configure --libdir=/usr/lib --runstatedir=/run --disable-chfn-chsh --disable-login --disable-nologin --disable-su --disable-setpriv --disable-runuser --disable-pylibmount --disable-static --disable-liblastlog2 --without-python ADJTIME_PATH=/var/lib/hwclock/adjtime --docdir=/usr/share/doc/util-linux-2.40.2 || EchoError "Configure ${PACKAGE}";
make || EchoError "make ${PACKAGE}" >&2;
make install || EchoError "make install ${PACKAGE}" >&2;

cd -;
rm -rf "${PDIR}${PACKAGE}-${VERSION}"

# 7.13 Cleanup

# Remove installed documentatoin files
rm -rf /usr/share/{info,man,doc}/*;

# Remove libtool .la files
find /usr/{lib,libexec} -name \*.la -delete

# Remove /tools
rm -rf /tools
