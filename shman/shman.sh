#! /bin/bash

SHMAN_DIR=/usr/src/shman/
SHMAN_SDIR=${SHMAN_DIR}PackageScripts/
SHMAN_PDIR=${SHMAN_DIR}Packages/
SHMAN_UDIR=${SHMAN_DIR}Utils/

for Directory in $SHMAN_DIR $SHMAN_SDIR $SHMAN_PDIR; do
	if [ ! -d $Directory ]; then mkdir $Directory; fi
done

source "${SHMAN_UDIR}Utils.sh"

# =====================================||===================================== #
#								Configuration									   #
# ===============ft_linux==============||==============©Othello=============== #

# Ensuring /usr/local/shell/colors.sh
if [ ! -d /usr/local/shell ]; then
	mkdir -p /usr/local/shell;
fi
if [ ! -f /usr/local/shell/colors.sh ]; then
	cp colors.sh /usr/local/shell/
fi

# Setting Binary validation function
if which which &> /dev/null; then
	CheckBinary()
	{
		which "$1" &> /dev/null;
		return $?;
	}
else
	CheckBinary()
	{
		if test "$(whereis $1)" != "$1:"; then
			return 0;
		else
			return 1;
		fi
	}
fi

# =====================================||===================================== #
#																			   #
#																			   #
#									 Menus									   #
#																			   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

DisplayPackage()
{
	if [ -z "$1" ]; then local KeyPress=""; else local KeyPress="$1)\t"; fi
	local PackageName="${2:-'N/A'}"
	local DisplayName="${3:-$PackageName}"

	echo -en "${KeyPress}${DisplayName} ";
	if source "$SHMAN_SDIR/$PackageName.sh" &> /dev/null; then 
		if Check${PackageName}Verbose 1> /dev/null; then
			echo -en "${C_GREEN}OK${C_RESET}"
		fi
	else 
		echo -en "${C_YELLOW}N/A${C_RESET}";
	fi
	echo
}

# =====================================||===================================== #
#									Menu LSB								   #
# ===============ft_linux==============||==============©Othello=============== #

MenuLSB()
{
	while true; do
		Width=$(tput cols);
		clear;

		printf '%*s\n' "$Width" '' | tr ' ' '-';
		echo -e	"${C_ORANGE}${C_BOLD}Linux Standard Base requirements${C_RESET}";
		printf '%*s\n' "$Width" '' | tr ' ' '-';

		echo -e	"c)\t ${C_ORANGE}${C_BOLD}Core${C_RESET}";
		echo -en "  " && DisplayPackage "" "At3" "At";
		# echo -en "  " && DisplayPackage "" "Bash" "Bash";
		# echo -en "  " && DisplayPackage "" "Bc" "Bc";
		# echo -en "  " && DisplayPackage "" "Binutils" "Binutils";
		# echo -en "  " && DisplayPackage "" "Coreutils" "Coreutils";
		echo -en "  " && DisplayPackage "" "Cpio2" "Cpio";
		# echo -en "  " && DisplayPackage "" "Diffutils" "Diffutils";
		echo -en "  " && DisplayPackage "" "Ed1" "Ed";
		echo -en "  " && DisplayPackage "" "Fcron3" "Fcron";
		# echo -en "  " && DisplayPackage "" "Findutls" "Findutls";
		# echo -en "  " && DisplayPackage "" "Gawk" "Gawk";
		# echo -en "  " && DisplayPackage "" "Grep" "Grep";
		# echo -en "  " && DisplayPackage "" "Gzip" "Gzip";
		echo -en "  " && DisplayPackage "" "LSBTools0" "LSB-Tools";
		# echo -en "  " && DisplayPackage "" "M4" "M4";
		# echo -en "  " && DisplayPackage "" "Man-DB" "Man-DB";
		echo -e  "  ${C_BOLD}MTA Mail - Server Software${C_RESET}";
		echo -en "   -" && DisplayPackage "" "Dovecot" "Dovecot";
		echo -en "   -" && DisplayPackage "" "Exim4" "Exim";
		echo -en "   -" && DisplayPackage "" "PostFix" "PostFix";
		echo -en "   -" && DisplayPackage "" "Sendmail8" "Sendmail";
		# echo -en "  " && DisplayPackage "" "Ncurses" "Ncurses";
		echo -en "  " && DisplayPackage "" "NSPR" "NSPR";
		echo -en "  " && DisplayPackage "" "Nss" "NSS";
		echo -en "  " && DisplayPackage "" "LinuxPAM" "PAM";
		echo -en "  " && DisplayPackage "" "Pax" "Pax";
		# echo -en "  " && DisplayPackage "" "Procps" "Procps";
		# echo -en "  " && DisplayPackage "" "Psmisc" "Psmisc";
		# echo -en "  " && DisplayPackage "" "Sed" "Sed";
		# echo -en "  " && DisplayPackage "" "Shadow" "Shadow";
		# echo -en "  " && DisplayPackage "" "Tar" "Tar";
		echo -en "  " && DisplayPackage "" "Time1" "time";
		# echo -en "  " && DisplayPackage "" "Util-linux" "Util-linux";
		# echo -en "  " && DisplayPackage "" "Zlib" "Zlib";
		printf '%*s\n' "$Width" '' | tr ' ' '-';

		echo -e	"d)\t ${C_ORANGE}${C_BOLD}Desktop${C_RESET}";
		# echo -en "  " && DisplayPackage "" "Alsa" "Alsa"
		# echo -en "  " && DisplayPackage "" "ATK" "ATK"
		echo -en "  " && DisplayPackage "" "Cairo" "Cairo"
		echo -en "  " && DisplayPackage "" "DesktopFileUtils" "DesktopFileUtils"
		echo -en "  " && DisplayPackage "" "FreeType" "Freetype"
		echo -en "  " && DisplayPackage "" "Fontconfig" "Fontconfig"
		echo -en "  " && DisplayPackage "" "GdkPixbuf" "Gdk-pixbuf";
		echo -en "  " && DisplayPackage "" "GLib" "Glib2"
		# echo -en "  " && DisplayPackage "" "GTK2" "GTK+2";
		# echo -en "  " && DisplayPackage "" "IconNamingUtils" "Icon-naming";
		echo -en "  " && DisplayPackage "" "LibJpegTurbo" "Libjpeg-turbo";
		echo -en "  " && DisplayPackage "" "LibPng" "Libpng"
		# echo -en "  " && DisplayPackage "" "LibTiff" "Libtiff"
		echo -en "  " && DisplayPackage "" "LibXml2" "Libxml2"
		# echo -en "  " && DisplayPackage "" "MesaLib" "MesaLib"
		echo -en "  " && DisplayPackage "" "Pango" "Pango"
		# echo -en "  " && DisplayPackage "" "Qt5" "Qt5"
		# echo -en "  " && DisplayPackage "" "XdgUtils" "Xdg-utils";
		# echo -en "  " && DisplayPackage "" "Xorg" "Xorg"
		printf '%*s\n' "$Width" '' | tr ' ' '-';

		echo -e	"l)\t ${C_ORANGE}${C_BOLD}Runtime Languages${C_RESET}";
		# echo -en "  " && DisplayPackage "" "Perl" "Perl"
		# echo -en "  " && DisplayPackage "" "Python" "Python"
		echo -en "  " && DisplayPackage "" "LibXml2" "Libxml2"
		echo -en "  " && DisplayPackage "" "LibXslt" "Libxslt"
		printf '%*s\n' "$Width" '' | tr ' ' '-';

		echo -e	"-)\t ${C_ORANGE}${C_BOLD}Imaging${C_RESET}";
		# echo -en "  " && DisplayPackage "" "Cups" "CUPS"
		# echo -en "  " && DisplayPackage "" "CupsFilters" "Cups-filters"
		# echo -en "  " && DisplayPackage "" "Ghostscript" "Ghostscript"
		# echo -en "  " && DisplayPackage "" "SANE" "SANE"
		printf '%*s\n' "$Width" '' | tr ' ' '-';

		echo -e	"g)\t ${C_ORANGE}${C_BOLD}Gtk3 and Graphics${C_RESET}";
		echo -en "  " && DisplayPackage "" "GTK3" "GTK+3"
		printf '%*s\n' "$Width" '' | tr ' ' '-';


		echo -e	"q)\t Return";
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		if [ ! -z "$ErrorMsg" ]; then
			printf	"$ErrorMsg\n"
			unset ErrorMsg;
			printf '%*s\n' "$Width" '' | tr ' ' '-';
		fi

		printf	"Input> ";
		GetKeyPress

		case "$input" in
			c|C)
				# Bash Bc Binutils Coreutils Diffutils Findutls Gawk Grep Gzip M4 Man Ncurses Procps Psmisc Sed Shadow Tar Util-linux Zlib
				# MTA's: Dovecot Exim4 PostFix Sendmail8
				for CorePackage in At3 Cpio2 Ed1 Fcron3 LSBTools0 NSPR Nss LinuxPAM Pax Time1; do
					source "$SHMAN_SDIR/${CorePackage}.sh" && Install"${CorePackage}" || PressAnyKeyToContinue;
				done ;;
			d|D)
				# Alsa ATK GTK2 IconNamingUtils LibTiff MesaLib Qt5 XdgUtils Xorg
				for DesktopPackage in Cairo DesktopFileUtils FreeType Fontconfig GdkPixbuf GLib LibJpegTurbo LibPng LibXml2 Pango; do
							source "$SHMAN_SDIR/${DesktopPackage}.sh" && Install"${DesktopPackage}" || PressAnyKeyToContinue;
				done ;;
			l|L)
				# Perl Python
				for LanguagePackage in LibXml2 LibXslt; do
							source "$SHMAN_SDIR/${LanguagePackage}.sh" && Install"${LanguagePackage}" || PressAnyKeyToContinue;
				done ;;
			g|G)
				# 
				for GraphicsPackage in GTK3; do
							source "$SHMAN_SDIR/${GraphicsPackage}.sh" && Install"${GraphicsPackage}" || PressAnyKeyToContinue;
				done ;;
			q|Q)	return;;
		esac
	done
}

# =====================================||===================================== #
#									Menu Pips								   #
# ===============ft_linux==============||==============©Othello=============== #

MenuPips()
{
	while true; do
		Width=$(tput cols);
		clear;

		printf '%*s\n' "$Width" '' | tr ' ' '-';
		echo -e	"${C_ORANGE}${C_BOLD}Package Installer Python3${C_RESET}";
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		CheckPips	editables hatchling hatch-fancy-pypi-readme hatch_vcs meson_python pyproject-metadata setuptools_scm
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		CheckPips	alabaster attrs chardet charset-normalizer idna imagesize pathspec pytz trove-classifiers
		CheckPips	packaging pyxdg six
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		CheckPips	Cython numpy psutil
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		CheckPips	iniconfig pluggy
		CheckPips	pytest
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		CheckPips	certifi urllib3
		CheckPips	cachecontrol requests sentry-sdk
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		CheckPips	commonmark msgpack smartypants snowballstemmer typogrify webencodings
		CheckPips	cssselect html5lib lxml Mako pyparsing pyserial PyYAML
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		CheckPips	Babel Markdown sphinxcontrib-applehelp sphinxcontrib-devhelp sphinxcontrib-htmlhelp sphinxcontrib-jquery sphinxcontrib-jsmath sphinxcontrib-qthelp sphinxcontrib-serializinghtml
		CheckPips	asciidoc docutils doxypypy doxyqml gi-docgen recommonmark scour sphinx sphinx_rtd_theme
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		CheckPips	ply pygdbmi Pygments
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		CheckPips	pygobject dbus-python python-dbusmock
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		echo -e	"a)\t All";
		echo -e	"q)\t Return";
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		if [ ! -z "$ErrorMsg" ]; then
			printf	"$ErrorMsg\n"
			unset ErrorMsg;
			printf '%*s\n' "$Width" '' | tr ' ' '-';
		fi

		printf	"Input> ";
		GetKeyPress

		case "$input" in
			a)	source $SHMAN_SDIR/_PythonPip3.sh && InstallPips;;
			q|Q)	return;;
		esac
	done	
}

# =====================================||===================================== #
#							Menu GCC Libraries								   #
# ===============ft_linux==============||==============©Othello=============== #

MenuGccLibraries()
{
	while true; do
		Width=$(tput cols);
		clear;

		printf '%*s\n' "$Width" '' | tr ' ' '-';
		echo -e	"${C_ORANGE}${C_BOLD}gcc libraries${C_RESET}";
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		DisplayPackage "0" "ICU" "";
		DisplayPackage "1" "Nettle" "";
		DisplayPackage "2" "GnuTLS" "";
		DisplayPackage "3" "LibUnwind" "";
		DisplayPackage "4" "LibXml2" "";
		DisplayPackage "5" "LibXslt" "";
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		echo -e	"a)\t All";
		echo -e	"q)\t Return";
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		if [ ! -z "$ErrorMsg" ]; then
			printf	"$ErrorMsg\n"
			unset ErrorMsg;
			printf '%*s\n' "$Width" '' | tr ' ' '-';
		fi

		printf	"Input> ";
		GetKeyPress

		case "$input" in
			0) source "$SHMAN_SDIR/ICU.sh" && InstallICU;;
			1) source "$SHMAN_SDIR/Nettle.sh" && InstallNettle;;
			2) source "$SHMAN_SDIR/GnuTLS.sh" && InstallGnuTLS;;
			3) source "$SHMAN_SDIR/LibUnwind.sh" && InstallLibUnwind;;
			4) source "$SHMAN_SDIR/LibXml2.sh" && InstallLibXml2;;
			5) source "$SHMAN_SDIR/LibXslt.sh" && InstallLibXslt;;
			a) 	for InstallPackage in ICU GnuTLS LibUnwind LibXslt; do
					source "$SHMAN_SDIR/${InstallPackage}.sh" && Install${InstallPackage};
				done ;;
			q|Q)	return;;
		esac
	done
}

# =====================================||===================================== #
#								Menu Binaries								   #
# ===============ft_linux==============||==============©Othello=============== #

MenuBinaries()
{
	while true; do
		Width=$(tput cols);
		clear;

		printf '%*s\n' "$Width" '' | tr ' ' '-';
		echo -e	"${C_ORANGE}${C_BOLD}Binary programs${C_RESET}";
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		DisplayPackage "c" "cURL" "";
		echo -en " -" && DisplayPackage "" "Wget" "";
		echo -en " -" && DisplayPackage "" "OpenSSH" "";
		DisplayPackage "g" "Git" "git";
		DisplayPackage "z" "Zsh" "zsh";
		DisplayPackage "w" "Which" "which";
		DisplayPackage "l" "Lynx" "lynx";
		DisplayPackage "r" "Rustc" "Rust";
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		echo -e	"a)\t All";
		echo -e	"q)\t Return";
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		if [ ! -z "$ErrorMsg" ]; then
			printf	"$ErrorMsg\n"
			unset ErrorMsg;
			printf '%*s\n' "$Width" '' | tr ' ' '-';
		fi

		printf	"Input> ";
		GetKeyPress

		case "$input" in
			c) source "$SHMAN_SDIR/cURL.sh" && InstallcURL;;
			g) source "$SHMAN_SDIR/Git.sh" && InstallGit;;
			z) source "$SHMAN_SDIR/Zsh.sh" && InstallZsh;;
			w) source "$SHMAN_SDIR/Which.sh" && InstallWhich;
				if which which &> /dev/null; then CheckBinary() { which "$1" &> /dev/null; return $?; } fi ;;
			l) source "$SHMAN_SDIR/Lynx.sh" && InstallLynx;;
			r) source "$SHMAN_SDIR/Rustc.sh" && InstallRustc;;
			a) 	source "$SHMAN_SDIR/Which.sh" && InstallWhich;
				if which which &> /dev/null; then CheckBinary() { which "$1" &> /dev/null; return $?; } fi ;
				for InstallPackage in cURL Git Zsh Lynx Rustc; do
					source "$SHMAN_SDIR/${InstallPackage}.sh" && Install${InstallPackage};
				done ;;
			q|Q)	return;;
		esac
	done
}

# =====================================||===================================== #
#									Menu Gnome								   #
# ===============ft_linux==============||==============©Othello=============== #

MenuGnome()
{
	while true; do
		Width=$(tput cols);
		clear;

		printf '%*s\n' "$Width" '' | tr ' ' '-';
		echo -e	"${C_ORANGE}${C_BOLD}GNU Network Object Model Environment${C_RESET}";
		printf '%*s\n' "$Width" '' | tr ' ' '-';

		echo -en "Python: "
		CheckPips	docutils pygobject dbus-python python-dbusmock
		printf '%*s\n' "$Width" '' | tr ' ' '-';

		# DisplayPackage "" "AdwaitaIconTheme" "";
		# DisplayPackage "" "GnomeShellExtensions" "";
		# DisplayPackage "" "GSettingsDesktopSchemas" "";
		# DisplayPackage "" "GstPluginsGood" "";
		# DisplayPackage "" "Hwdata" "";
		# DisplayPackage "" "PyCairo" "";
		# DisplayPackage "" "UtilMacros" "";
		# DisplayPackage "" "Xbitmaps" "";
		# DisplayPackage "" "XcbProto" "";
		# DisplayPackage "" "XcursorThemes" "";
		# DisplayPackage "" "XkeyboardConfig" "";
		# DisplayPackage "" "Xorgproto" "";
		# printf '%*s\n' "$Width" '' | tr ' ' '-';
		
		DisplayPackage "0" "GLib" "";
		DisplayPackage "1" "Dbus" "";
		DisplayPackage "2" "XorgServer" "";
		echo -en "  " && DisplayPackage "" "XorgApplications" "";
		echo -en "  " && DisplayPackage "" "XorgBuildEnv" "";
		echo -en "  " && DisplayPackage "" "XorgFonts" "";
		echo -en "  " && DisplayPackage "" "XorgLibinput" "";
		echo -en "  " && DisplayPackage "" "XorgLibraries" "";
		echo -en "  " && DisplayPackage "" "Xorgproto" "";
		DisplayPackage "3" "Gcr3" "";
		DisplayPackage "4" "Gcr4" "";
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		DisplayPackage "5" "GDM" "";
		echo -en "  " && DisplayPackage "" "Nautilus" "";
		DisplayPackage "6" "GnomeShell" "";
		DisplayPackage "7" "GnomeShellExtensions" "";
		DisplayPackage "8" "GnomeControlCenter" "";
		DisplayPackage "9" "GnomeSession" "";
		printf '%*s\n' "$Width" '' | tr ' ' '-';

		# echo -e	"a)\t All";
		echo -e	"q)\t Return";
		printf '%*s\n' "$Width" '' | tr ' ' '-';
		if [ ! -z "$ErrorMsg" ]; then
			printf	"$ErrorMsg\n"
			unset ErrorMsg;
			printf '%*s\n' "$Width" '' | tr ' ' '-';
		fi

		printf	"Input> ";
		GetKeyPress

		case "$input" in
			0) source "$SHMAN_SDIR/GLib.sh" && InstallGLib;;
			1) source "$SHMAN_SDIR/Dbus.sh" && InstallDbus;;
			2) InstallFunctionForXorg;;
			3) source "$SHMAN_SDIR/Gcr3.sh" && InstallGcr3;;
			4) source "$SHMAN_SDIR/Gcr4.sh" && InstallGcr4;;
			4) source "$SHMAN_SDIR/GDM.sh" && InstallGDM;;
			6) InstallFunctionForGnomeShell;;
			7) source "$SHMAN_SDIR/GnomeShellExtensions.sh" && InstallGnomeShellExtensions;;
			8) source "$SHMAN_SDIR/GnomeControlCenter.sh" && InstallGnomeControlCenter;;
			9) source "$SHMAN_SDIR/GnomeSession.sh" && InstallGnomeSession;;
			g|G) source "$SHMAN_SDIR/LibNma.sh" && InstallLibNma; PressAnyKeyToContinue;;
			a|A)	for InstallPackage in Gcr3 Gcr4 GSettingsDesktopSchemas LibSecret Rest TotemPlParser VTE; do
						source "$SHMAN_SDIR/${InstallPackage}.sh" && Install${InstallPackage};
					done ;;
			q|Q)	return;;
		esac
	done
}

InstallFunctionForXorg()
{
	# Xorg packages
	# FreeTypeChain contains XorgLibraries
	# XorgFonts XorgApplications are dependencies of XorgServer
	for Dependency in XorgBuildEnv Xorgproto FreeTypeChain XorgServer; do
		source "$SHMAN_SDIR/${Dependency}.sh" && Install${Dependency} || { PressAnyKeyToContinue; return 1; };
	done

	# Required Runtime Dependencies
	for Dependency in XkeyboardConfig; do
		source "$SHMAN_SDIR/${Dependency}.sh" && Install${Dependency} || { PressAnyKeyToContinue; return 1; };
	done

	# Recommended Runtime Dependencies
	for Dependency in XorgLibinput Xinit; do
		source "$SHMAN_SDIR/${Dependency}.sh" && Install${Dependency} || { PressAnyKeyToContinue; };
	done
	# Recommended Runtime Dependencies
	for Dependency in Acpid; do
		source "$SHMAN_SDIR/${Dependency}.sh" && Install${Dependency};
	done
}

InstallFunctionForGnomeShell()
{
	source "$SHMAN_SDIR/GnomeShell.sh" && InstallGnomeShell || return $?;

	# Required Runtime Dependencies
	# removed cause its a hassle GnomeControlCenter (it is important though)
	for Dependency in AdwaitaIconTheme DConf Elogind GDM  LibGweather; do
		source "$SHMAN_SDIR/${Dependency}.sh" && Install${Dependency} || { PressAnyKeyToContinue; return 1; };
	done

	# Recommended Runtime Dependencies
	# Added LibNma
	for Dependency in Blocaled GnomeMenus LibNma; do
		source "$SHMAN_SDIR/${Dependency}.sh" && Install${Dependency} || { PressAnyKeyToContinue; return 1; };
	done
}

# =====================================||===================================== #
#								   Execution								   #
# ===============ft_linux==============||==============©Othello=============== #

while true; do
	Width=$(tput cols);
	clear;

	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo -e	"${C_ORANGE}${C_BOLD}Shman - Shell Package Manager${C_RESET}";
	echo 	"Dir: ${SHMAN_DIR}";
	echo -n "Scripts: "; ls ${SHMAN_SDIR}/*.sh -l | wc -l;
	echo 	"PATH: $PATH"
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	DisplayPackage "0" "Linux" " Linux";
	echo -e "l)\t LSB requirements"
	echo -e "p)\t Python Packages"
	echo -e "y)\t gcc Libraries"
	echo -e "b)\t Binaries"
	echo -e "g)\t Gnome"
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo -e "c)\t Clean";
	echo -e "q)\t Quit";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	if [ ! -z "$ErrorMsg" ]; then
		printf	"$ErrorMsg\n"
		unset ErrorMsg;
		printf '%*s\n' "$Width" '' | tr ' ' '-';
	fi

	printf	"Input> ";
	GetKeyPress

	case "$input" in
		0) source "$SHMAN_SDIR/Linux.sh" && InstallLinux;;
		l)	MenuLSB;;
		p)	MenuPips;;
		y)	MenuGccLibraries;;
		b)	MenuBinaries;;
		g|G)	MenuGnome;;
		c)	RemoveAllPackages;;
		C)	RemoveAllPackages;
			RemoveAllDownloads;;
		q)	break;;
		Q)	poweroff -n;;
		*)	ErrorMsg="Bad input: $input";;
	esac
done


# bash-5.2# cat /etc/pam.d/system-session /etc/pam.d/gdm-launch-environment 
# # Begin /etc/pam.d/system-session

# session   required    pam_unix.so

# # End /etc/pam.d/system-session
# # Begin elogind addition

# session  required    pam_loginuid.so
# session  required    pam_elogind.so

# # End elogind addition

# # Begin /etc/pam.d/gdm-launch-environment

# auth     required       pam_succeed_if.so audit quiet_success user = gdm
# auth     required       pam_env.so
# auth     optional       pam_permit.so

# account  required       pam_succeed_if.so audit quiet_success user = gdm
# account  include        system-account

# password required       pam_deny.so

# session  required       pam_succeed_if.so audit quiet_success user = gdm
# session  required       pam_loginuid.so
# session  required       pam_elogind.so
# session  optional       pam_keyinit.so force revoke
# session  optional       pam_permit.so

# # End /etc/pam.d/gdm-launch-environment
# bash-5.2# echo '' > /var/log/gdm/greeter.log 
# bash-5.2# ps aux | grep gdm
# root      1202  0.1  0.0 306192  8324 ?        Ssl  21:44   0:00 /usr/sbin/gdm
# root      1269  0.0  0.0   2708  1484 pts/0    S+   21:45   0:00 grep gdm
# bash-5.2# kill 1202
# bash-5.2# cat /var/log/gdm/greeter.log | grep -E "(EE|WW)"
# Current Operating System: Linux ohengelm 6.10.14 #1 SMP PREEMPT_DYNAMIC Wed Jul 16 16:43:40 CEST 2025 x86_64
#         (WW) warning, (EE) error, (NI) not implemented, (??) unknown.
# (WW) `fonts.dir' not found (or not valid) in "/usr/share/fonts/X11/misc".
# (WW) `fonts.dir' not found (or not valid) in "/usr/share/fonts/X11/100dpi".
# (WW) `fonts.dir' not found (or not valid) in "/usr/share/fonts/X11/75dpi".
# (WW) Open ACPI failed (/var/run/acpid.socket) (No such file or directory)
# (WW) Warning, couldn't open module vmware
# (EE) Failed to load module "vmware" (module does not exist, 0)
# (WW) Warning, couldn't open module fbdev
# (EE) Failed to load module "fbdev" (module does not exist, 0)
# (WW) Warning, couldn't open module vesa
# (EE) Failed to load module "vesa" (module does not exist, 0)
# (EE) 
# (EE) xf86OpenConsole: Cannot open virtual console 1 (Permission denied)
# (EE) 
# (EE) 
# (EE) Please also check the log file at "/var/log/Xorg.0.log" for additional information.
# (EE) 
# (WW) xf86CloseConsole: KDSETMODE failed: Bad file descriptor
# (WW) xf86CloseConsole: VT_GETMODE failed: Bad file descriptor
# (EE) Server terminated with error (1). Closing log file.
# bash-5.2# loginctl
# No sessions.