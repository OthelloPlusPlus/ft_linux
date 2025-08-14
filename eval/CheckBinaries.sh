#! /bin/bash
#                                                                              #
#                                                         :::      ::::::::    #
#    CheckBinaries.sh                                   :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ohengelm <ohengelm@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/03/13 14:32:33 by ohengelm          #+#    #+#              #
#    Updated: 2025/03/13 14:32:56 by ohengelm         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

colors=$(tput colors 2>/dev/null || echo 0)

if [ "$colors" -ge 256 ]; then
	ESC_SEQ='\x1b[';
	C_RESET="\x1b[0m";
	C_BOLD="\x1b[1m"
	C_RED="\x1b[38;2;255;0;0m";
	C_ORANGE="\x1b[38;2;255;128;0m";
	C_GREEN="\x1b[38;2;0;255;0m";
elif [ "$colors" -ge 8 ]; then
	ESC_SEQ='\e[';
	C_RESET="\e[0m";
	C_RED="\e[1;31m";
	C_ORANGE="\e[1;33m";
	C_GREEN="\e[1;32m";
	C_BOLD="\e[1;38m";
fi


# =====================================||===================================== #
#									Functions								   #
# ===============ft_linux==============||==============©Othello=============== #

IsInstalled()
{
	if [[ $(echo "$1" | wc -c) -gt $WORDWIDTH ]]; then
		WORDWIDTH=$(echo "$1" | wc -c);
	fi

	if [[ $((CURRENT+WORDWIDTH)) -gt $SCREENWIDTH ]] && [ "$CURRENT" -gt 0 ]; then
		echo;
		CURRENT=0;
	fi

	TOTAL=$((TOTAL+1));
	# type -pa "$@" | head -n 1
	if test "$(whereis $1)" = "$1:"; then
		printf	"${C_RED}%-${WORDWIDTH}s${C_RESET}"	"$1" >&2;
	else
		SUCCESS=$((SUCCESS+1));
		printf	"${C_GREEN}%-${WORDWIDTH}s${C_RESET}"	"$1";
	fi

	CURRENT=$((CURRENT+WORDWIDTH));
}

IsGroupInstalled()
{
	if [ "$#" -lt 2 ]; then return ; fi

	printf	"${C_BOLD}%-${WORDWIDTH}s${C_RESET}"	"$1:";
	IncrementWordWidth;

	for Binary in "${@:2}"; do
		IsInstalled	"$Binary";
	done

	echo;
	CURRENT=0;
}

IncrementWordWidth()
{
	CURRENT=$((CURRENT+WORDWIDTH));
	if [[ $((CURRENT+WORDWIDTH)) -gt $SCREENWIDTH ]]; then
		echo;
		CURRENT=0;
	fi
}

ResetVariables()
{
	# Scoring settings
	SUCCESS=0;
	TOTAL=0;

	# Printing settings
	SCREENWIDTH=$(tput cols);
	CURRENT=0;
	if [ -n "$1" ]; then
		WORDWIDTH=$1;
	else
		WORDWIDTH=23;
	fi
}


PrintFinalScore()
{
	if [ "$#" -eq 0 ]; then return ; fi

	printf	"${C_BOLD}%6s %7s %5s %7s${C_RESET}\n"	""	"Result"	"Score"	"~Points"
	for Tests in "${@:1}"; do
		if [[ ! "$Tests" =~ ^[^:]+:[0-9]+:[0-9]+$ ]]; then
			continue
		fi

		local Success=$(echo "$Tests" | cut -d':' -f2);
		local Total=$(echo "$Tests" | cut -d':' -f3);
		if [[ ! "$Success" =~ ^[0-9]+$ ]]; then
			Success=0;
		fi
		if [[ ! "$Total" =~ ^[0-9]+$ ]]; then
			Total=1;
		fi
		local Percent=$((100*Success/Total));
		local Points=$((Percent * 5 / 100));

		# Set colors
		[ "$Success" == "$Total" ] && COL1="${C_GREEN}" || COL1="${C_RED}";
		[ "$Percent" -eq 100 ] && COL2="${C_GREEN}" || COL2="${ESC_SEQ}38;2;255;${Percent};0m";

		printf	"${C_BOLD}%-6s${C_RESET} ${COL1}%3s${C_RESET}/%3s ${COL2}%4s%%${C_RESET} %5s/5\n"	"$(echo "$Tests" | cut -d':' -f1):"	"$Success"	"$Total"	"$Percent"	"$Points";
	done
}

PrintLine()
{
	local NAMELENGTH=$(echo -n "| $1 |" | wc -c);
	local LINELEFT=$(((SCREENWIDTH-NAMELENGTH)/2));
	local LINERIGHT=$((SCREENWIDTH-NAMELENGTH-LINELEFT));

	printf	"%${LINELEFT}s" "=" | tr '  ' '-';
	printf	"| ${C_ORANGE}${C_BOLD}$1${C_RESET} |";
	printf	"%-${LINERIGHT}s\n" "=" | tr '  ' '-';
}

# =====================================||===================================== #
#				 			   ft_linux_basic.sh							   #
# ===============ft_linux==============||==============©Othello=============== #

ResetVariables	"$(wc -c <<< 'Util-linux:')";
PrintLine	"Basic binaries";

IsGroupInstalled	"Glibc"
IsGroupInstalled	"Bzip2"	"bunzip2"	"bzcat"	"bzip2";
IsGroupInstalled	"Xz"	"lzcat"	"lzma"	"unlzma"	"unxz"	"xz"	"xzcat"
IsGroupInstalled	"Lz4"
IsGroupInstalled	"Zstd"
IsGroupInstalled	"File"
IsGroupInstalled	"M4"
IsGroupInstalled	"Bc"
IsGroupInstalled	"Flex"
IsGroupInstalled	"Tcl"
IsGroupInstalled	"Expect"
IsGroupInstalled	"DejaGNU"
IsGroupInstalled	"Pkgconf"
IsGroupInstalled	"Binutils"
IsGroupInstalled	"Attr"	"attr"	"getfattr"	"setfattr"
IsGroupInstalled	"Acl"	"chacl"	"getfacl"	"setfacl"
IsGroupInstalled	"Libcap"
IsGroupInstalled	"Shadow"	"login"
IsGroupInstalled	"GCC"
IsGroupInstalled	"Ncurses"
IsGroupInstalled	"Sed"	"sed"
IsGroupInstalled	"Psmisc"	"fuser"	"killall"
IsGroupInstalled	"Gettext"
IsGroupInstalled	"Bison"
IsGroupInstalled	"Grep"	"egrep"	"fgrep"	"grep"
IsGroupInstalled	"Bash"	"bashbug"	"sh"
IsGroupInstalled	"Libtool"
IsGroupInstalled	"GDBM"
IsGroupInstalled	"Gperf"
IsGroupInstalled	"Expat"
IsGroupInstalled	"Inetutils"	"hostname"
IsGroupInstalled	"Less"
IsGroupInstalled	"Perl"
IsGroupInstalled	"Inittool"
IsGroupInstalled	"Autoconf"
IsGroupInstalled	"Automake"
IsGroupInstalled	"OpenSSL"
IsGroupInstalled	"Kmod"	"kmod"	"lsmod"
IsGroupInstalled	"Python"
IsGroupInstalled	"Wheel"
IsGroupInstalled	"Ninja"
IsGroupInstalled	"Meson"
IsGroupInstalled	"Coreutils"	"cat"	"chgrp"	"chmod"	"chown"	"cp"	"date"	"dd"	"df"	"echo"	"false"	"groups"	"head"	"ln"	"ls"	"mkdir"	"mknod"	"mv"	"nice"	"pwd"	"rm"	"rmdir"	"sleep"	"stty"	"sync"	"true"	"uname"
IsGroupInstalled	"Check"
IsGroupInstalled	"Diffutils"
IsGroupInstalled	"Gawk"
IsGroupInstalled	"Findutils"	"find"
IsGroupInstalled	"Groff"
IsGroupInstalled	"GRUB"
IsGroupInstalled	"Gzip"	"gunzip"	"gzip"	"zcat"
IsGroupInstalled	"IPRoute"
IsGroupInstalled	"Kbd"
IsGroupInstalled	"Make"
IsGroupInstalled	"Patch"
IsGroupInstalled	"Tar"	"tar"
IsGroupInstalled	"Texinfo"
IsGroupInstalled	"Vim"
IsGroupInstalled	"Udev from Systemd"
IsGroupInstalled	"Man-DB"
IsGroupInstalled	"Procps-ng"	"pidof"	"ps"
IsGroupInstalled	"Util-linux"	"dmesg"	"findmnt"	"kill"	"lsblk"	"more"	"mount"	"mountpoint"	"umount"
IsGroupInstalled	"E2fsprogs"	"chattr"	"compile_et"	"lsattr"	"mk_cmds"
IsGroupInstalled	"Sysklogd"
IsGroupInstalled	"SysVinit"
IsGroupInstalled	"Miscellaneous"

BasicScores="Basic:$SUCCESS:$TOTAL";

# =====================================||===================================== #
#				 			   ft_linux_others.sh							   #
# ===============ft_linux==============||==============©Othello=============== #

PrintLine	"Other binaries";
ResetVariables	"$(wc -c <<< 'intltool-extract')";

IsGroupInstalled	"Glibc"	"gencat"	"getconf"	"getent"	"iconv"	"ldd"	"locale"	"localedef"	"makedb"	"mtrace"	"pcprofiledump"	"pldd"	"sotruss"	"sprof"	"tzselect"	"xtrace"
IsGroupInstalled	"Bzip2"	"bzcmp"	"bzdiff"	"bzegrep"	"bzfgrep"	"bzgrep"	"bzip2recover"	"bzless"	"bzmore";
IsGroupInstalled	"Xz"	"lzcmp"	"lzdiff"	"lzegrep"	"lzfgrep"	"lzgrep"	"lzless"	"lzmadec"	"lzmainfo"	"lzmore"	"xzcmp"	"xzdec"	"xzdiff"	"xzegrep"	"xzfgrep"	"xzgrep"	"xzless"	"xzmore"                      
IsGroupInstalled	"Lz4"
IsGroupInstalled	"Zstd"
IsGroupInstalled	"File"	"file"
IsGroupInstalled	"M4"	"m4"
IsGroupInstalled	"Bc"	"bc"	"dc"
IsGroupInstalled	"Flex"	"flex"	"flex++"
IsGroupInstalled	"Tcl"
IsGroupInstalled	"Expect"
IsGroupInstalled	"DejaGNU"
IsGroupInstalled	"Pkgconf"	"pkg-config"
IsGroupInstalled	"Binutils"	"addr2line"	"ar"	"as"	"c++filt"	"elfedit"	"gprof"	"ld"	"ld.bfd"	"nm"	"objcopy"	"objdump"	"ranlib"	"readelf"	"size"	"strings"	"strip"
IsGroupInstalled	"Attr"
IsGroupInstalled	"Acl"
IsGroupInstalled	"Libcap"
IsGroupInstalled	"Shadow"	"chage"	"chfn"	"chsh"	"expiry"	"faillog"	"gpasswd"
IsGroupInstalled	"GCC"	"c++"	"cc"	"cpp"	"g++"	"gcc"	"gcc-ar"	"gcc-nm"	"gcc-ranlib"	"gcov"	"gcov-tool"
IsGroupInstalled	"Ncurses"	"captoinfo"	"clear"	"infocmp"	"infotocap"	"reset"	"tabs"	"tic"	"toe"	"tput"	"tset"
IsGroupInstalled	"Sed"
IsGroupInstalled	"Psmisc"	"peekfd"	"prtstat"	"pstree"	"pstree.x11"
IsGroupInstalled	"Gettext"	"autopoint"	"envsubst"	"gettext"	"gettext.sh"	"gettextize"	"msgattrib"	"msgcat"	"msgcmp"	"msgcomm"	"msgconv"	"msgen"	"msgexec"	"msgfilter"	"msgfmt"	"msggrep"	"msginit"	"msgmerge"	"msgunfmt"	"msguniq"	"ngettext"	"recode-sr-latin"	"xgettext"
IsGroupInstalled	"Bison"	"bison"	"yacc"
IsGroupInstalled	"Grep"
IsGroupInstalled	"Bash"
IsGroupInstalled	"Libtool"	"libtool"	"libtoolize"
IsGroupInstalled	"GDBM"	"gdbm_dump"	"gdbm_load"	"gdbmtool"
IsGroupInstalled	"Gperf"	"gperf"
IsGroupInstalled	"Expat"	"xmlwf"
IsGroupInstalled	"Inetutils"	"dnsdomainname"	"ftp"	"talk"	"telnet"	"tftp"	"traceroute"
IsGroupInstalled	"Less"	"less"	"lessecho"	"lesskey"
IsGroupInstalled	"Perl"	"corelist"	"cpan"	"enc2xs"	"encguess"	"h2ph"	"h2xs"	"instmodsh"	"json_pp"	"libnetcfg"	"perl"	"perlbug"	"perldoc"	"perlivp"	"perlthanks"	"piconv"	"pl2pm"	"prove"	"ptar"	"ptardiff"	"ptargrep"	"shasum"	"splain"	"xsubpp"	"zipdetails"
IsGroupInstalled	"Inittool"	"intltool-extract"	"intltool-merge"	"intltool-prepare"	"intltool-update"	"intltoolize"
IsGroupInstalled	"Autoconf"	"autoconf"	"autoheader"	"autom4te"	"autoreconf"	"autoscan"	"autoupdate"	"ifnames"
IsGroupInstalled	"Automake"	"aclocal"	"automake"
IsGroupInstalled	"OpenSSL"
IsGroupInstalled	"Kmod"
IsGroupInstalled	"Python"
IsGroupInstalled	"Wheel"
IsGroupInstalled	"Ninja"
IsGroupInstalled	"Meson"
IsGroupInstalled	"Coreutils"	"base64"	"basename"	"chcon"	"cksum"	"comm"	"csplit"	"cut"	"dir"	"dircolors"	"dirname"	"du"	"env"	"expand"	"expr"	"factor"	"fmt"	"fold"	"hostid"	"id"	"install"	"join"	"link"	"logname"	"md5sum"	"mkfifo"	"mktemp"	"nl"	"nohup"	"nproc"	"numfmt"	"od"	"paste"	"pathchk"	"pinky"	"pr"	"printenv"	"printf"	"ptx"	"readlink"	"realpath"	"seq"	"sha1sum"	"sha224sum"	"sha256sum"	"sha384sum"	"sha512sum"	"shred"	"shuf"	"sort"	"split"	"stat"	"stdbuf"	"sum"	"tac"	"tail"	"tee"	"timeout"	"touch"	"tr"	"truncate"	"tsort"	"tty"	"unexpand"	"uniq"	"unlink"	"users"	"vdir"	"wc"	"who"	"whoami"	"yes"
IsGroupInstalled	"Check"
IsGroupInstalled	"Diffutils"	"cmp"	"diff"	"diff3"	"sdiff"
IsGroupInstalled	"Gawk"	"awk"	"gawk"
IsGroupInstalled	"Findutils"	"locate"	"updatedb"	"xargs"
IsGroupInstalled	"Groff"	"addftinfo"	"afmtodit"	"chem"	"eqn"	"eqn2graph"	"gdiffmk"	"glilypond"	"gperl"	"gpinyin"	"grap2graph"	"grn"	"grodvi"	"groff"	"grog"	"grolbp"	"grolj4"	"gropdf"	"grops"	"grotty"	"hpftodit"	"indxbib"	"lkbib"	"lookbib"	"mmroff"	"neqn"	"nroff"	"pdfmom"	"pdfroff"	"pfbtops"	"pic"	"pic2graph"		"preconv"	"refer"	"soelim"	"tbl"	"tfmtodit"	"troff"
IsGroupInstalled	"GRUB"
IsGroupInstalled	"Gzip"	"gzexe"	"uncompress"	"zcmp"	"zdiff"	"zegrep"	"zfgrep"	"zforce"	"zgrep"	"zless"	"zmore"	"znew"
IsGroupInstalled	"IPRoute"
IsGroupInstalled	"Kbd"	"chvt"	"deallocvt"	"dumpkeys"	"fgconsole"	"getkeycodes"	"kbdinfo"	"kbd_mode"	"kbdrate"	"loadkeys"	"loadunimap"	"mapscrn"	"openvt"	"psfaddtable"	"psfgettable"	"psfstriptable"	"psfxtable"	"setfont"	"setkeycodes"	"setleds"	"setmetamode"	"setvtrgb"	"showconsolefont"	"showkey"	"unicode_start"	"unicode_stop"
IsGroupInstalled	"Make"	"make"
IsGroupInstalled	"Patch"	"patch"
IsGroupInstalled	"Tar"
IsGroupInstalled	"Texinfo"	"info"	"install-info"	"makeinfo"	"pdftexi2dvi"	"texi2any"	"texi2dvi"	"texi2pdf"	"texindex"
IsGroupInstalled	"Vim"	"ex"	"vi"	"view"	"xxd"
IsGroupInstalled	"Udec from Systemd"
IsGroupInstalled	"Man-DB"	"apropos"	"catman"	"lexgrog"	"man"	"mandb"	"manpath"	"whatis"
IsGroupInstalled	"Procps-ng"	"free"	"pgrep"	"pkill"	"pmap"	"pwdx"	"slabtop"	"tload"	"top"	"uptime"	"vmstat"	"w"	"watch"
IsGroupInstalled	"Util-linux"	"cal"	"chrt"	"col"	"colcrt"	"colrm"	"column"	"eject"	"fallocate"	"flock"	"getopt"	"hexdump"	"ionice"	"ipcmk"	"ipcrm"	"ipcs"	"isosize"	"last"	"lastb"	"linux32"	"linux64"	"logger"	"look"	"lscpu"	"lslocks"	"lslogins"	"mcookie"	"mesg"	"namei"	"nsenter"	"prlimit"	"rename"	"renice"	"rev"	"script"	"scriptreplay"	"setarch"	"setsid"	"setterm"	"taskset"	"ul"	"uname26"	"unshare"	"utmpdump"	"uuidgen"	"wall"	"whereis"
IsGroupInstalled	"E2fsprogs"
IsGroupInstalled	"Sysklogd"
IsGroupInstalled	"SysVinit"
IsGroupInstalled	"Miscellaneous"	"lynx"	"rexec"

OtherScores="Other:$SUCCESS:$TOTAL";

# =====================================||===================================== #
#				 			   ft_linux_added.sh							   #
# ===============ft_linux==============||==============©Othello=============== #

PrintLine	"Added binaries";
ResetVariables	"$(wc -c <<< 'grub-mkpasswd-pbkdf2')";

IsGroupInstalled	"Glibc"	"iconvconfig"	"ldconfig"	"ld.so"	"sln"	"zdump"	"zic"
IsGroupInstalled	"Bzip2"
IsGroupInstalled	"Xz"
IsGroupInstalled	"Lz4"	"lz4"	"lz4c"	"lz4cat"	"unlz4"
IsGroupInstalled	"Zstd"	"zstd"	"zstdcat"	"zstdgrep"	"zstdless"	"zstdmt"	"unzstd"
IsGroupInstalled	"File"
IsGroupInstalled	"M4"
IsGroupInstalled	"Bc"
IsGroupInstalled	"Flex"	"lex"
IsGroupInstalled	"Tcl"	"tclsh"	"tclsh8.6"
IsGroupInstalled	"Expect"	"expect"
IsGroupInstalled	"DejaGNU"	"dejagnu"	"runtest"
IsGroupInstalled	"Pkgconf"	"pkgconf"	"bomtool"
IsGroupInstalled	"Binutils"	"dwp"	"gprofng"	"ld.gold";
IsGroupInstalled	"Attr"
IsGroupInstalled	"Acl"
IsGroupInstalled	"Libcap"	"capsh"	"getcap"	"getpcaps"	"setcap"
IsGroupInstalled	"Shadow"	"chgpasswd"	"chpasswd"	"getsubids"	"groupadd"	"groupdel"	"groupmems"	"groupmod"	"grpck"	"grpconv"	"grpunconv"	"logoutd"	"newgidmap"	"newgrp"	"newuidmap"	"newusers"	"nologin"	"passwd"	"pwck"	"pwconv"	"pwunconv"	"sg"	"su"	"useradd"	"userdel"	"usermod"	"vigr"	"vipw"
IsGroupInstalled	"GCC"	"gcov-dump"	"lto-dump"
IsGroupInstalled	"Ncurses"	"ncursesw6-config"
IsGroupInstalled	"Sed"
IsGroupInstalled	"Psmisc"	"pslog"
IsGroupInstalled	"Gettext"
IsGroupInstalled	"Bison"
IsGroupInstalled	"Grep"
IsGroupInstalled	"Bash"	"bash"
IsGroupInstalled	"Libtool"
IsGroupInstalled	"GDBM"
IsGroupInstalled	"Gperf"
IsGroupInstalled	"Expat"
IsGroupInstalled	"Inetutils"	"ifconfig"	"ping"	"ping6"
IsGroupInstalled	"Less"
IsGroupInstalled	"Perl"	"perl5.40.0"	"pod2html"	"pod2man"	"pod2text"	"pod2usage"	"podchecker"
IsGroupInstalled	"Inittool"
IsGroupInstalled	"Autoconf"
IsGroupInstalled	"Automake"	"aclocal-1.17"	"automake-1.17"
IsGroupInstalled	"OpenSSL"	"c_rehash"	"openssl"
IsGroupInstalled	"Kmod"	"depmod"	"insmod"	"modinfo"	"modprobe"	"rmmod"
IsGroupInstalled	"Python"	"2to3"	"idle3"	"pip3"	"pydoc3"	"python3"	"python3-config"
IsGroupInstalled	"Wheel"	"wheel"
IsGroupInstalled	"Ninja"	"ninja"
IsGroupInstalled	"Meson"	"meson"
IsGroupInstalled	"Coreutils"	"["	"b2sum"	"base32"	"basenc"	"chroot"	"runcon"	"test"
IsGroupInstalled	"Check"	"checkmk"
IsGroupInstalled	"Diffutils"
IsGroupInstalled	"Gawk"	"gawk-5.3.0"
IsGroupInstalled	"Findutils"
IsGroupInstalled	"Groff"	"post-grohtml"	"pre-grohtml"
IsGroupInstalled	"GRUB"	"grub-bios-setup"	"grub-editenv"	"grub-file"	"grub-fstest"	"grub-glue-efi"	"grub-install"	"grub-kbdcomp"	"grub-macbless"	"grub-menulst2cfg"	"grub-mkconfig"	"grub-mkimage"	"grub-mklayout"	"grub-mknetdir"	"grub-mkpasswd-pbkdf2"	"grub-mkrelpath"	"grub-mkrescue"	"grub-mkstandalone"	"grub-ofpathname"	"grub-probe"	"grub-reboot"	"grub-render-label"	"grub-script-check"	"grub-set-default"	"grub-sparc64-setup"	"grub-syslinux2cfg"
IsGroupInstalled	"Gzip"
IsGroupInstalled	"IPRoute"	"bridge"	"ctstat"	"genl"	"ifstat"	"ip"	"lnstat"	"nstat"	"routel"	"rtacct"	"rtmon"	"rtstat"	"ss"	"tc"
IsGroupInstalled	"Kbd"
IsGroupInstalled	"Make"
IsGroupInstalled	"Patch"
IsGroupInstalled	"Tar"
IsGroupInstalled	"Texinfo"	"pod2texi"
IsGroupInstalled	"Vim"	"rview"	"rvim"	"vim"	"vimdiff"	"vimtutor"
IsGroupInstalled	"Udec from Systemd"	"udevadm"	"udevd"	"udev-hwdb"
IsGroupInstalled	"Man-DB"	"accessdb"	"man-recode"
IsGroupInstalled	"Procps-ng"	"sysctl"
IsGroupInstalled	"Util-linux"	"addpart"	"agetty"	"blkdiscard"	"blkid"	"blkzone"	"blockdev"	"cfdisk"	"chcpu"	"chmem"	"choom"	"ctrlaltdel"	"delpart"	"fdisk"	"fincore"	"findfs"	"fsck"	"fsck.cramfs"	"fsck.minix"	"fsfreeze"	"fstrim"	"hardlink"	"hwclock"	"i386"	"irqtop"	"ldattach"	"losetup"	"lsipc"	"lsirq"	"lsfd"	"lsmem"	"lsns"	"mkfs"	"mkfs.bfs"	"mkfs.cramfs"	"mkfs.minix"	"mkswap"	"partx"	"pivot_root"	"readprofile"	"resizepart"	"rfkill"	"rtcwake"	"scriptlive"	"sfdisk"	"sulogin"	"swaplabel"	"swapoff"	"swapon"	"switch_root"	"uclampset"	"uuidd"	"uuidparse"	"wdctl"	"wipefs"	"x86_64"	"zramctl"
IsGroupInstalled	"E2fsprogs"	"badblocks"	"debugfs"	"dumpe2fs"	"e2freefrag"	"e2fsck"	"e2image"	"e2label"	"e2mmpstatus"	"e2scrub"	"e2scrub_all"	"e2undo"	"e4crypt"	"e4defrag"	"filefrag"	"fsck.ext2"	"fsck.ext3"	"fsck.ext4"	"logsave"	"mke2fs"	"mkfs.ext2"	"mkfs.ext3"	"mkfs.ext4"	"mklost+found"	"resize2fs"	"tune2fs"
IsGroupInstalled	"Sysklogd"	"syslogd"
IsGroupInstalled	"SysVinit"	"bootlogd"	"fstab-decode"	"halt"	"init"	"killall5"	"poweroff"	"reboot"	"runlevel"	"shutdown"	"telinit"
IsGroupInstalled	"Miscellaneous"

AddedScores="Added:$SUCCESS:$TOTAL";

# =====================================||===================================== #
#				 			   ft_linux_LSB.sh							   #
# ===============ft_linux==============||==============©Othello=============== #

PrintLine	"LSB binaries";
ResetVariables	"$(wc -c <<< 'install_initd')";

echo -e "\nCore"
IsGroupInstalled	"At"	"at" "atd" "atq" "atrm" "atrun" "batch"
IsGroupInstalled	"Cpio"	"cpio" "mt"
IsGroupInstalled	"Ed"	"ed" "red"
IsGroupInstalled	"Fcrontab"	"fcron" "fcrondyn" "fcronsighup" "fcrontab"
IsGroupInstalled	"LSB-Tools"	"lsb_release" "install_initd" "remove_initd"
IsGroupInstalled	"MTA Mail"	"sendmail"
IsGroupInstalled	"NSPR"	"nspr-config"
IsGroupInstalled	"NSS"	"certutil" "nss-config" "pk12util"
WORDWIDTH="$(wc -c <<< 'pam_namespace_helper')"
IsGroupInstalled	"PAM"	"faillock" "mkhomedir_helper" "pam_namespace_helper" "pam_timestamp_check" "pwhistory_helper" "unix_chkpwd"
IsGroupInstalled	"Pax"	"pax"
IsGroupInstalled	"time"	"time"

echo -e "\nDesktop"
WORDWIDTH="$(wc -c <<< 'gdk-pixbuf-query-loaders')"
# IsGroupInstalled	"Alsa"	""
# IsGroupInstalled	"ATK"	""
IsGroupInstalled	"Cairo"	"cairo-trace"
IsGroupInstalled	"Desktop-file-utils"	"desktop-file-edit" "desktop-file-install" "desktop-file-validate" "update-desktop-database"
IsGroupInstalled	"Freetype"	"freetype-config"
IsGroupInstalled	"Fontconfig"	"fc-cache" "fc-cat" "fc-conflist" "fc-list" "fc-match" "fc-pattern" "fc-query" "fc-scan" "fc-validate"
IsGroupInstalled	"Gdk-pixbuf"	"gdk-pixbuf-csource" "gdk-pixbuf-pixdata" "gdk-pixbuf-query-loaders" "gdk-pixbuf-thumbnailer"
IsGroupInstalled	"Glib2"	"gapplication" "gdbus" "gdbus-codegen" "gi-compile-repository" "gi-decompile-typelib" "gi-inspect-typelib" "gio" "gio-querymodules" "glib-compile-resources" "glib-compile-schemas" "glib-genmarshal" "glib-gettextize" "glib-mkenums" "gobject-query" "gresource" "gsettings" "gtester" "gtester-report"
#" "IsGroupInstalled	"GTK+2"	""
IsGroupInstalled	"Icon-naming-utils"	"icon-name-mapping"
IsGroupInstalled	"Libjpeg-turbo"	"cjpeg" "djpeg" "jpegtran" "rdjpgcom" "tjbench" "wrjpgcom"
IsGroupInstalled	"Libpng"	"libpng-config" "libpng16-config" "pngfix" "png-fix-itxt"
IsGroupInstalled	"Libtiff"	"fax2ps" "fax2tiff" "pal2rgb" "ppm2tiff" "raw2tiff" "tiff2bw" "tiff2pdf" "tiff2ps" "tiff2rgba" "tiffcmp" "tiffcp" "tiffcrop" "tiffdither" "tiffdump" "tiffgt" "tiffinfo" "tiffmedian" "tiffset" "tiffsplit"
IsGroupInstalled	"Libxml2"	"xml2-config" "xmlcatalog" "xmllint"
#" "IsGroupInstalled	"MesaLib"	""
IsGroupInstalled	"Pango"	"pango-list" "pango-segmentation" "pango-view"
IsGroupInstalled	"Xdg-utils"	"xdg-desktop-menu" "xdg-desktop-icon" "xdg-mime" "xdg-icon-resource" "xdg-open" "xdg-email" "xdg-screensaver" "xdg-settings"
IsGroupInstalled	"Xorg"	"iceauth" "mkfontdir" "mkfontscale" "sessreg" "setxkbmap" "smproxy" "xauth" "xcmsdb" "xcursorgen" "xdpr" "xdpyinfo" "xdriinfo" "xev" "xgamma" "xhost" "xinput" "xkbbell" "xkbcomp" "xkbevd" "xkbvleds" "xkbwatch" "xkill" "xlsatoms" "xlsclients" "xmessage" "xmodmap" "xpr" "xprop" "xrandr" "xrdb" "xrefresh" "xset" "xsetroot" "xvinfo" "xwd" "xwininfo" "xwud"

echo -e "\nRuntime Languages"
WORDWIDTH="$(wc -c <<< 'xml2-config')"
IsGroupInstalled	"Libxml2"	"xml2-config" "xmlcatalog" "xmllint"
IsGroupInstalled	"Libxslt"	"xslt-config" "xsltproc"

echo -e "\nImaging"
WORDWIDTH="$(wc -c <<< 'gamma4scanimage')"
IsGroupInstalled	"CUPS"	"cancel" "cupsaccept" "cups-config" "cupsctl" "cupsd" "cupsdisable" "cupsenable" "cupsfilter" "cupsreject" "cupstestppd" "ippeveprinter" "ippfind" "ipptool" "lp" "lpadmin" "lpc" "lpinfo" "lpmove" "lpoptions" "lpq" "lpr" "lprm" "lpstat" "ppdc" "ppdhtml" "ppdi" "ppdmerge" "ppdpo"
IsGroupInstalled	"Cups-filters"	"driverless" "driverless-fax" "foomatic-rip"
IsGroupInstalled	"Ghostscript"	"dvipdf" "eps2eps" "gs" "gsbj" "gsc" "(from" "soinstall)" "gsdj" "gsdj500" "gslj" "gslp" "gsnd" "gsx" "(from" "soinstall)" "lprsetup.sh" "pdf2dsc" "pdf2ps" "pf2afm" "pfbtopfa" "pphs" "printafm" "ps2ascii" "ps2epsi" "ps2pdf" "ps2pdf12" "ps2pdf13" "ps2pdf14" "ps2pdfwr" "ps2ps" "ps2ps2" "unix-lpr.sh"
IsGroupInstalled	"SANE"	"gamma4scanimage" "sane-config" "saned" "sane-find-scanner" "scanimage" "umax_pp"

echo -e "\nLSB Gtk3 and LSB Graphics"
WORDWIDTH="$(wc -c <<< 'gtk-query-immodules-3.0')"
IsGroupInstalled	"GTK+3"	"broadwayd" "gtk3-demo" "gtk3-demo-application" "gtk3-icon-browser" "gtk3-widget-factory" "gtk-builder-tool" "gtk-encode-symbolic-svg" "gtk-launch" "gtk-query-immodules-3.0" "gtk-query-settings" "gtk-update-icon-cache"

LSBScores="LSB:$SUCCESS:$TOTAL";

# =====================================||===================================== #
#				 			   ft_linux_Bonus.sh							   #
# ===============ft_linux==============||==============©Othello=============== #

PrintLine	"Bonus binaries";
ResetVariables	"$(wc -c <<< 'git-upload-archive')";

IsGroupInstalled	"wget"	"wget"
IsGroupInstalled	"make-ca"	"make-ca"
IsGroupInstalled	"ccmake"	"cmake"	"cmake-gui"	"cpack"	"ctest"
IsGroupInstalled	"openssh"	"scp"	"sftp"	"ssh"	"ssh-add"	"ssh-agent"	"ssh-copy-id"	"ssh-keygen"	"ssh-keyscan"	"sshd"
IsGroupInstalled	"Git"	"git"	"git-receive-pack"	"git-upload-archive"	"git-upload-pack"	"git-cvsserver"	"git-shell"	"gitk"	"scalar"
IsGroupInstalled	"Which"	"which"
IsGroupInstalled	"Zsh"	"zsh" "zsh-5.9"
IsGroupInstalled	"Systemd"	"busctl"	"coredumpctl"	"halt"	"hostnamectl"	"init"	"journalctl"	"kernel-install"	"localectl"	"loginctl"	"machinectl"	"mount.ddi"	"networkctl"	"oomctl"	"portablectl"	"poweroff"	"reboot"	"resolvconf"	"resolvectl"	"runlevel"	"shutdown"	"systemctl"	"telinit"	"timedatectl"	"udevadm"
TempWordWidth="$WORDWIDTH"
WORDWIDTH="$(wc -c <<< 'systemd-tty-ask-password-agent')"
IsGroupInstalled	"Systemd cont."	"systemd-ac-power"	"systemd-analyze"	"systemd-ask-password"	"systemd-cat"	"systemd-cgls"	"systemd-cgtop"	"systemd-confext"	"systemd-creds"	"systemd-delta"	"systemd-detect-virt"	"systemd-dissect"	"systemd-escape"	"systemd-hwdb"	"systemd-id128"	"systemd-inhibit"	"systemd-machine-id-setup"	"systemd-mount"	"systemd-notify"	"systemd-nspawn"	"systemd-path"	"systemd-repart"	"systemd-resolve"	"systemd-run"	"systemd-socket-activate"	"systemd-stdio-bridge"	"systemd-sysext"	"systemd-tmpfiles"	"systemd-tty-ask-password-agent"	"systemd-umount"
WORDWIDTH="$TempWordWidth"
# # Pacman
# # https://archlinux.org/packages/core/x86_64/pacman/
# # https://pacman.archlinux.page/
IsGroupInstalled	"Pacman"	#"pacman"
IsGroupInstalled	"cURL"	"curl"	"curl-config"
IsGroupInstalled	"GnuPG"	#"addgnupghome"	"applygnupgdefaults"	"dirmngr"	"dirmngr-client"	"g13"	"gpg-agent"	"gpg-card"	"gpg-connect-agent"	"gpg"	"gpgconf"	"gpgparsemail"	"gpgscm"	"gpgsm"	"gpgsplit"	"gpgtar"	"gpgv"	"gpg-wks-client"	"gpg-wks-server"	"kbxutil"	"watchgnupg"
IsGroupInstalled	"GPGME"	#"gpgme-json"	"gpgme-tool"
IsGroupInstalled	"libarchive"	#"bsdcat"	"bsdcpio"	"bsdtar"	"bsdunzip"
IsGroupInstalled	"doxygen" #"doxygen"	"doxywizard"	"doxyindexer"	"doxysearch.cgi"
# and more optional
IsGroupInstalled	"pacman-mirrorlist 20250311-1"
IsGroupInstalled	"base-devel" # (optional) - required to use makepkg
IsGroupInstalled	"perl-locale-gettext" # (optional) - translation support in makepkg-template
IsGroupInstalled	"asciidoc" # (make)
IsGroupInstalled	"fakechroot" # (check)
BonusScores="Bonus:$SUCCESS:$TOTAL";

# # =====================================||===================================== #
# #				 			   ft_linux_obsolete.sh							   #
# # ===============ft_linux==============||==============©Othello=============== #

# PrintLine	"Obsolete binaries";
# echo	"Depending on version the following binaries may be obsolete..."
# ResetVariables	"$(echo 'podselect' | wc -c)";

# IsGroupInstalled	"Glibc"	"lddlibc4"
# IsGroupInstalled	"Perl"	"podselect"
# IsGroupInstalled	"Groff"	"groffer"	"roff2dvi"	"roff2html"	"roff2pdf"	"roff2ps"	"roff2text"	"roff2x"
# IsGroupInstalled	"IPRoute"	"rtpr"

# ObsoleteScores="Obslt:$SUCCESS:$TOTAL";


PrintLine	"Scores";
PrintFinalScore	"$BasicScores"	"$OtherScores"	"$AddedScores"	"$LSBScores"	"$BonusScores"
PrintLine	"ft_linux | Othello";

# # =====================================||===================================== #
# #								Original Basic List							   #
# # ===============ft_linux==============||==============©Othello=============== #

# IsInstalled "ls"
# IsInstalled "attr"
# IsInstalled "bashbug"
# IsInstalled "bunzip2"
# IsInstalled "bzcat"
# IsInstalled "bzip2"
# IsInstalled "cat"
# IsInstalled "chacl"
# IsInstalled "chattr"
# IsInstalled "chgrp"
# IsInstalled "chmod"
# IsInstalled "chown"
# IsInstalled "compile_et"
# IsInstalled "cp"
# IsInstalled "date"
# IsInstalled "dd"
# IsInstalled "df"
# IsInstalled "dmesg"
# IsInstalled "echo"
# IsInstalled "egrep"
# IsInstalled "false"
# IsInstalled "fgrep"
# IsInstalled "find"
# IsInstalled "findmnt"
# IsInstalled "fuser"
# IsInstalled "getfacl"
# IsInstalled "getfattr"
# IsInstalled "grep"
# IsInstalled "groups"
# IsInstalled "gunzip"
# IsInstalled "gzip"
# IsInstalled "head"
# IsInstalled "hostname"
# IsInstalled "kill"
# IsInstalled "killall"
# IsInstalled "kmod"
# IsInstalled "ln"
# IsInstalled "login"
# IsInstalled "ls"
# IsInstalled "lsattr"
# IsInstalled "lsblk"
# IsInstalled "lsmod"
# IsInstalled "lzcat"
# IsInstalled "lzma"
# IsInstalled "mk_cmds"
# IsInstalled "mkdir"
# IsInstalled "mknod"
# IsInstalled "more"
# IsInstalled "mount"
# IsInstalled "mountpoint"
# IsInstalled "mv"
# IsInstalled "nice"
# IsInstalled "passwd"
# IsInstalled "pidof"
# IsInstalled "ps"
# IsInstalled "pwd"
# IsInstalled "rm"
# IsInstalled "rmdir"
# IsInstalled "sed"
# IsInstalled "setfacl"
# IsInstalled "setfattr"
# IsInstalled "sh"
# IsInstalled "sleep"
# IsInstalled "stty"
# IsInstalled "su"
# IsInstalled "sync"
# IsInstalled "tar"
# IsInstalled "traceroute"
# IsInstalled "true"
# IsInstalled "umount"
# IsInstalled "uname"
# IsInstalled "unlzma"
# IsInstalled "unxz"
# IsInstalled "wdctl"
# IsInstalled "xz"
# IsInstalled "xzcat"
# IsInstalled "zcat"

# # =====================================||===================================== #
# #								Original Others List						   #
# # ===============ft_linux==============||==============©Othello=============== #

# IsInstalled "aclocal"
# IsInstalled "addftinfo"
# IsInstalled "addr2line"
# IsInstalled "afmtodit"
# IsInstalled "apropos"
# IsInstalled "ar"
# IsInstalled "as"
# IsInstalled "autoconf"
# IsInstalled "autoheader"
# IsInstalled "autom4te"
# IsInstalled "automake"
# IsInstalled "autopoint"
# IsInstalled "autoreconf"
# IsInstalled "autoscan"
# IsInstalled "autoupdate"
# IsInstalled "awk"
# IsInstalled "base64"
# IsInstalled "basename"
# IsInstalled "bc"
# IsInstalled "bison"
# IsInstalled "bzcmp"
# IsInstalled "bzdiff"
# IsInstalled "bzegrep"
# IsInstalled "bzfgrep"
# IsInstalled "bzgrep"
# IsInstalled "bzip2recover"
# IsInstalled "bzless"
# IsInstalled "bzmore"
# IsInstalled "c++"
# IsInstalled "c++filt"
# IsInstalled "cal"
# IsInstalled "captoinfo"
# IsInstalled "catman"
# IsInstalled "cc"
# IsInstalled "chage"
# IsInstalled "chcon"
# IsInstalled "chem"
# IsInstalled "chfn"
# IsInstalled "chrt"
# IsInstalled "chsh"
# IsInstalled "chvt"
# IsInstalled "cksum"
# IsInstalled "clear"
# IsInstalled "cmp"
# IsInstalled "col"
# IsInstalled "colcrt"
# IsInstalled "colrm"
# IsInstalled "column"
# IsInstalled "comm"
# IsInstalled "corelist"
# IsInstalled "cpan"
# IsInstalled "cpp"
# IsInstalled "csplit"
# IsInstalled "cut"
# IsInstalled "dc"
# IsInstalled "deallocvt"
# IsInstalled "diff"
# IsInstalled "diff3"
# IsInstalled "dir"
# IsInstalled "dircolors"
# IsInstalled "dirname"
# IsInstalled "dnsdomainname"
# IsInstalled "du"
# IsInstalled "dumpkeys"
# IsInstalled "eject"
# IsInstalled "elfedit"
# IsInstalled "enc2xs"
# IsInstalled "encguess"
# IsInstalled "env"
# IsInstalled "envsubst"
# IsInstalled "eqn"
# IsInstalled "eqn2graph"
# IsInstalled "ex"
# IsInstalled "expand"
# IsInstalled "expiry"
# IsInstalled "expr"
# IsInstalled "factor"
# IsInstalled "faillog"
# IsInstalled "fallocate"
# IsInstalled "fgconsole"
# IsInstalled "file"
# IsInstalled "flex"
# IsInstalled "flex++"
# IsInstalled "flock"
# IsInstalled "fmt"
# IsInstalled "fold"
# IsInstalled "free"
# IsInstalled "ftp"
# IsInstalled "g++"
# IsInstalled "gawk"
# IsInstalled "gcc"
# IsInstalled "gcc-ar"
# IsInstalled "gcc-nm"
# IsInstalled "gcc-ranlib"
# IsInstalled "gcov"
# IsInstalled "gcov-tool"
# IsInstalled "gdbm_dump"
# IsInstalled "gdbm_load"
# IsInstalled "gdbmtool"
# IsInstalled "gdiffmk"
# IsInstalled "gencat"
# IsInstalled "getconf"
# IsInstalled "getent"
# IsInstalled "getkeycodes"
# IsInstalled "getopt"
# IsInstalled "gettext"
# IsInstalled "gettext.sh"
# IsInstalled "gettextize"
# IsInstalled "glilypond"
# IsInstalled "gpasswd"
# IsInstalled "gperf"
# IsInstalled "gperl"
# IsInstalled "gpinyin"
# IsInstalled "gprof"
# IsInstalled "grap2graph"
# IsInstalled "grn"
# IsInstalled "grodvi"
# IsInstalled "groff"
# IsInstalled "grog"
# IsInstalled "grolbp"
# IsInstalled "grolj4"
# IsInstalled "gropdf"
# IsInstalled "grops"
# IsInstalled "grotty"
# IsInstalled "groups"
# IsInstalled "gzexe"
# IsInstalled "h2ph"
# IsInstalled "h2xs"
# IsInstalled "hexdump"
# IsInstalled "hostid"
# IsInstalled "hpftodit"
# IsInstalled "iconv"
# IsInstalled "id"
# IsInstalled "ifnames"
# IsInstalled "indxbib"
# IsInstalled "info"
# IsInstalled "infocmp"
# IsInstalled "infotocap"
# IsInstalled "install"
# IsInstalled "install-info"
# IsInstalled "instmodsh"
# IsInstalled "intltool-extract"
# IsInstalled "intltool-merge"
# IsInstalled "intltool-prepare"
# IsInstalled "intltool-update"
# IsInstalled "intltoolize"
# IsInstalled "ionice"
# IsInstalled "ipcmk"
# IsInstalled "ipcrm"
# IsInstalled "ipcs"
# IsInstalled "isosize"
# IsInstalled "join"
# IsInstalled "json_pp"
# IsInstalled "kbd_mode"
# IsInstalled "kbdinfo"
# IsInstalled "kbdrate"
# IsInstalled "last"
# IsInstalled "lastb"
# IsInstalled "ld"
# IsInstalled "ld.bfd"
# IsInstalled "ldd"
# IsInstalled "less"
# IsInstalled "lessecho"
# IsInstalled "lesskey"
# IsInstalled "lexgrog"
# IsInstalled "libnetcfg"
# IsInstalled "libtool"
# IsInstalled "libtoolize"
# IsInstalled "link"
# IsInstalled "linux32"
# IsInstalled "linux64"
# IsInstalled "lkbib"
# IsInstalled "loadkeys"
# IsInstalled "loadunimap"
# IsInstalled "locale"
# IsInstalled "localedef"
# IsInstalled "locate"
# IsInstalled "logger"
# IsInstalled "logname"
# IsInstalled "look"
# IsInstalled "lookbib"
# IsInstalled "lscpu"
# IsInstalled "lslocks"
# IsInstalled "lslogins"
# IsInstalled "lynx"
# IsInstalled "lzcmp"
# IsInstalled "lzdiff"
# IsInstalled "lzegrep"
# IsInstalled "lzfgrep"
# IsInstalled "lzgrep"
# IsInstalled "lzless"
# IsInstalled "lzmadec"
# IsInstalled "lzmainfo"
# IsInstalled "lzmore"
# IsInstalled "m4"
# IsInstalled "make"
# IsInstalled "makedb"
# IsInstalled "makeinfo"
# IsInstalled "man"
# IsInstalled "mandb"
# IsInstalled "manpath"
# IsInstalled "mapscrn"
# IsInstalled "mcookie"
# IsInstalled "md5sum"
# IsInstalled "mesg"
# IsInstalled "mkfifo"
# IsInstalled "mktemp"
# IsInstalled "mmroff"
# IsInstalled "msgattrib"
# IsInstalled "msgcat"
# IsInstalled "msgcmp"
# IsInstalled "msgcomm"
# IsInstalled "msgconv"
# IsInstalled "msgen"
# IsInstalled "msgexec"
# IsInstalled "msgfilter"
# IsInstalled "msgfmt"
# IsInstalled "msggrep"
# IsInstalled "msginit"
# IsInstalled "msgmerge"
# IsInstalled "msgunfmt"
# IsInstalled "msguniq"
# IsInstalled "mtrace"
# IsInstalled "namei"
# IsInstalled "neqn"
# IsInstalled "newgidmap"
# IsInstalled "newgrp"
# IsInstalled "newuidmap"
# IsInstalled "ngettext"
# IsInstalled "nl"
# IsInstalled "nm"
# IsInstalled "nohup"
# IsInstalled "nproc"
# IsInstalled "nroff"
# IsInstalled "nsenter"
# IsInstalled "numfmt"
# IsInstalled "objcopy"
# IsInstalled "objdump"
# IsInstalled "od"
# IsInstalled "openvt"
# IsInstalled "paste"
# IsInstalled "patch"
# IsInstalled "pathchk"
# IsInstalled "pcprofiledump"
# IsInstalled "pdfmom"
# IsInstalled "pdfroff"
# IsInstalled "pdftexi2dvi"
# IsInstalled "peekfd"
# IsInstalled "perl"
# IsInstalled "perlbug"
# IsInstalled "perldoc"
# IsInstalled "perlivp"
# IsInstalled "perlthanks"
# IsInstalled "pfbtops"
# IsInstalled "pgrep"
# IsInstalled "pic"
# IsInstalled "pic2graph"
# IsInstalled "piconv"
# IsInstalled "pinky"
# IsInstalled "pkg-config"
# IsInstalled "pkill"
# IsInstalled "pl2pm"
# IsInstalled "pldd"
# IsInstalled "pmap"
# IsInstalled "pr"
# IsInstalled "preconv"
# IsInstalled "printenv"
# IsInstalled "printf"
# IsInstalled "prlimit"
# IsInstalled "prove"
# IsInstalled "prtstat"
# IsInstalled "psfaddtable"
# IsInstalled "psfgettable"
# IsInstalled "psfstriptable"
# IsInstalled "psfxtable"
# IsInstalled "pstree"
# IsInstalled "pstree.x11"
# IsInstalled "ptar"
# IsInstalled "ptardiff"
# IsInstalled "ptargrep"
# IsInstalled "ptx"
# IsInstalled "pwdx"
# IsInstalled "ranlib"
# IsInstalled "readelf"
# IsInstalled "readlink"
# IsInstalled "realpath"
# IsInstalled "recode-sr-latin"
# IsInstalled "refer"
# IsInstalled "rename"
# IsInstalled "renice"
# IsInstalled "reset"
# IsInstalled "rev"
# IsInstalled "rexec"
# IsInstalled "script"
# IsInstalled "scriptreplay"
# IsInstalled "sdiff"
# IsInstalled "seq"
# IsInstalled "setarch"
# IsInstalled "setfont"
# IsInstalled "setkeycodes"
# IsInstalled "setleds"
# IsInstalled "setmetamode"
# IsInstalled "setsid"
# IsInstalled "setterm"
# IsInstalled "setvtrgb"
# IsInstalled "sg"
# IsInstalled "sha1sum"
# IsInstalled "sha224sum"
# IsInstalled "sha256sum"
# IsInstalled "sha384sum"
# IsInstalled "sha512sum"
# IsInstalled "shasum"
# IsInstalled "showconsolefont"
# IsInstalled "showkey"
# IsInstalled "shred"
# IsInstalled "shuf"
# IsInstalled "size"
# IsInstalled "slabtop"
# IsInstalled "soelim"
# IsInstalled "sort"
# IsInstalled "sotruss"
# IsInstalled "splain"
# IsInstalled "split"
# IsInstalled "sprof"
# IsInstalled "stat"
# IsInstalled "stdbuf"
# IsInstalled "strings"
# IsInstalled "strip"
# IsInstalled "sum"
# IsInstalled "tabs"
# IsInstalled "tac"
# IsInstalled "tail"
# IsInstalled "talk"
# IsInstalled "taskset"
# IsInstalled "tbl"
# IsInstalled "tee"
# IsInstalled "telnet"
# IsInstalled "texi2any"
# IsInstalled "texi2dvi"
# IsInstalled "texi2pdf"
# IsInstalled "texindex"
# IsInstalled "tfmtodit"
# IsInstalled "tftp"
# IsInstalled "tic"
# IsInstalled "timeout"
# IsInstalled "tload"
# IsInstalled "toe"
# IsInstalled "top"
# IsInstalled "touch"
# IsInstalled "tput"
# IsInstalled "tr"
# IsInstalled "troff"
# IsInstalled "truncate"
# IsInstalled "tset"
# IsInstalled "tsort"
# IsInstalled "tty"
# IsInstalled "tzselect"
# IsInstalled "ul"
# IsInstalled "uname26"
# IsInstalled "uncompress"
# IsInstalled "unexpand"
# IsInstalled "unicode_start"
# IsInstalled "unicode_stop"
# IsInstalled "uniq"
# IsInstalled "unlink"
# IsInstalled "unshare"
# IsInstalled "updatedb"
# IsInstalled "uptime"
# IsInstalled "users"
# IsInstalled "utmpdump"
# IsInstalled "uuidgen"
# IsInstalled "vdir"
# IsInstalled "vi"
# IsInstalled "view"
# IsInstalled "vmstat"
# IsInstalled "w"
# IsInstalled "wall"
# IsInstalled "watch"
# IsInstalled "wc"
# IsInstalled "whatis"
# IsInstalled "whereis"
# IsInstalled "who"
# IsInstalled "whoami"
# IsInstalled "xargs"
# IsInstalled "xgettext"
# IsInstalled "xmlwf"
# IsInstalled "xsubpp"
# IsInstalled "xtrace"
# IsInstalled "xxd"
# IsInstalled "xzcmp"
# IsInstalled "xzdec"
# IsInstalled "xzdiff"
# IsInstalled "xzegrep"
# IsInstalled "xzfgrep"
# IsInstalled "xzgrep"
# IsInstalled "xzless"
# IsInstalled "xzmore"
# IsInstalled "yacc"
# IsInstalled "yes"
# IsInstalled "zcmp"
# IsInstalled "zdiff"
# IsInstalled "zegrep"
# IsInstalled "zfgrep"
# IsInstalled "zforce"
# IsInstalled "zgrep"
# IsInstalled "zipdetails"
# IsInstalled "zless"
# IsInstalled "zmore"
# IsInstalled "znew"
