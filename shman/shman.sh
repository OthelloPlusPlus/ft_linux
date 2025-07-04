#! /bin/bash

SHMAN_DIR=/usr/src/shman/
SHMAN_SDIR=${SHMAN_DIR}PackageScripts/
SHMAN_PDIR=${SHMAN_DIR}Packages/

for Directory in $SHMAN_DIR $SHMAN_SDIR $SHMAN_PDIR; do
	if [ ! -d $Directory ]; then mkdir $Directory; fi
done

source "${SHMAN_DIR}Utils.sh"

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
		echo -en "0)\t ICU "; 		source "$SHMAN_SDIR/ICU.sh" && CheckICU && 				echo -e "${C_GREEN}OK${C_RESET}" || { echo -en "${C_RED}KO${C_RESET}\t"; CheckICUVerbose 1> /dev/null; echo; }
		echo -en "1)\t Nettle "; 	source "$SHMAN_SDIR/Nettle.sh" && CheckNettle && 		echo -e "${C_GREEN}OK${C_RESET}" || { echo -en "${C_RED}KO${C_RESET}\t"; CheckNettleVerbose 1> /dev/null; echo; }
		echo -en "2)\t GnuTLS "; 	source "$SHMAN_SDIR/GnuTLS.sh" && CheckGnuTLS && 		echo -e "${C_GREEN}OK${C_RESET}" || { echo -en "${C_RED}KO${C_RESET}\t"; CheckGnuTLSVerbose 1> /dev/null; echo; }
		echo -en "3)\t LibUnwind "; source "$SHMAN_SDIR/LibUnwind.sh" && CheckLibUnwind && 	echo -e "${C_GREEN}OK${C_RESET}" || { echo -en "${C_RED}KO${C_RESET}\t"; CheckLibUnwindVerbose 1> /dev/null; echo; }
		echo -en "4)\t LibXml2 "; 	source "$SHMAN_SDIR/LibXml2.sh" && CheckLibXml2 && 		echo -e "${C_GREEN}OK${C_RESET}" || { echo -en "${C_RED}KO${C_RESET}\t"; CheckLibXml2Verbose 1> /dev/null; echo; }
		echo -en "5)\t LibXslt "; 	source "$SHMAN_SDIR/LibXslt.sh" && CheckLibXslt && 		echo -e "${C_GREEN}OK${C_RESET}" || { echo -en "${C_RED}KO${C_RESET}\t"; CheckLibXsltVerbose 1> /dev/null; echo; }
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
			a) source "$SHMAN_SDIR/ICU.sh" && InstallICU;
				source "$SHMAN_SDIR/GnuTLS.sh" && InstallGnuTLS;
				source "$SHMAN_SDIR/LibUnwind.sh" && InstallLibUnwind;
				source "$SHMAN_SDIR/LibXslt.sh" && InstallLibXslt;;
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
		echo -en "c)\t Wget "; 	source "$SHMAN_SDIR/Wget.sh" && CheckWget && 	echo -e "${C_GREEN}OK${C_RESET}" || echo -e "${C_RED}KO${C_RESET}"
		echo -en "c)\t OpenSSH "; 	source "$SHMAN_SDIR/OpenSSH.sh" && CheckOpenSSH && 	echo -e "${C_GREEN}OK${C_RESET}" || echo -e "${C_RED}KO${C_RESET}"
		echo -en "c)\t cURL "; 	source "$SHMAN_SDIR/cURL.sh" && CheckcURL && 	echo -e "${C_GREEN}OK${C_RESET}" || echo -e "${C_RED}KO${C_RESET}"
		echo -en "g)\t git "; 	source "$SHMAN_SDIR/Git.sh" && CheckGit && 		echo -e "${C_GREEN}OK${C_RESET}" || echo -e "${C_RED}KO${C_RESET}"
		echo -en "z)\t zsh "; 	source "$SHMAN_SDIR/Zsh.sh" && CheckZsh && 		echo -e "${C_GREEN}OK${C_RESET}" || echo -e "${C_RED}KO${C_RESET}"
		echo -en "w)\t which "; source "$SHMAN_SDIR/Which.sh" && CheckWhich && 	echo -e "${C_GREEN}OK${C_RESET}" || echo -e "${C_RED}KO${C_RESET}"
		echo -en "l)\t lynx "; 	source "$SHMAN_SDIR/Lynx.sh" && CheckLynx && 	echo -e "${C_GREEN}OK${C_RESET}" || echo -e "${C_RED}KO${C_RESET}"
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
			a) source "$SHMAN_SDIR/cURL.sh" && InstallcURL;
				source "$SHMAN_SDIR/Git.sh" && InstallGit;
				source "$SHMAN_SDIR/Zsh.sh" && InstallZsh;
				source "$SHMAN_SDIR/Which.sh" && InstallWhich;
				if which which &> /dev/null; then CheckBinary() { which "$1" &> /dev/null; return $?; } fi ;
				source "$SHMAN_SDIR/Lynx.sh" && InstallLynx;;
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

		CheckPips	docutils
		# echo -en "FreeTypeChain "; 	source "$SHMAN_SDIR/FreeTypeChain.sh" && CheckFreeTypeChainVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		# echo -en "GstPluginsBase "; 	source "$SHMAN_SDIR/GstPluginsBase.sh" && CheckGstPluginsBaseVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		echo -en "GstPluginsGood "; 	source "$SHMAN_SDIR/GstPluginsGood.sh" && CheckGstPluginsGoodVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		# echo -en "GstPluginsBad "; 	source "$SHMAN_SDIR/GstPluginsBad.sh" && CheckGstPluginsBadVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		echo -en "DocbookXml "; 	source "$SHMAN_SDIR/DocbookXml.sh" && CheckDocbookXmlVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		echo -en "Ibus "; 	source "$SHMAN_SDIR/Ibus.sh" && CheckIbusVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		echo -en "Rustc "; 	source "$SHMAN_SDIR/Rustc.sh" && CheckRustcVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		# echo -en "DConf "; 	source "$SHMAN_SDIR/DConf.sh" && CheckDConfVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		# echo -en "DConfEditor "; 	source "$SHMAN_SDIR/DConfEditor.sh" && CheckDConfEditorVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		# echo -en "GnomeDesktop "; 	source "$SHMAN_SDIR/GnomeDesktop.sh" && CheckGnomeDesktopVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		printf '%*s\n' "$Width" '' | tr ' ' '-';

		echo -en "-)\t Linux "; 	source "$SHMAN_SDIR/Linux.sh" && CheckLinuxVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		echo -en "0)\t GLib "; 		source "$SHMAN_SDIR/GLib.sh" && CheckGLibVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		echo -en "3)\t Gcr3 "; 		source "$SHMAN_SDIR/Gcr3.sh" && CheckGcr3Verbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		echo -en "4)\t Gcr4 "; 		source "$SHMAN_SDIR/Gcr4.sh" && CheckGcr4Verbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		echo -en "-)\t GSettingsDesktopSchemas "; 		source "$SHMAN_SDIR/GSettingsDesktopSchemas.sh" && CheckGSettingsDesktopSchemasVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		printf '%*s\n' "$Width" '' | tr ' ' '-';

		# echo -en "-)\t GnomeBackgrounds "; 		source "$SHMAN_SDIR/GnomeBackgrounds.sh" && CheckGnomeBackgroundsVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		# echo -en "-)\t GnomeKeyring "; 			source "$SHMAN_SDIR/GnomeKeyring.sh" && CheckGnomeKeyringVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		echo -en "-)\t GnomeSettingsDaemon "; 	source "$SHMAN_SDIR/GnomeSettingsDaemon.sh" && CheckGnomeSettingsDaemonVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		# echo -en "-)\t GnomeControlCenter "; 	source "$SHMAN_SDIR/GnomeControlCenter.sh" && CheckGnomeControlCenterVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		echo -en "9)\t GnomeShell "; 			source "$SHMAN_SDIR/GnomeShell.sh" && CheckGnomeShellVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		# echo -en "-)\t GnomeShellExtensions "; 	source "$SHMAN_SDIR/GnomeShellExtensions.sh" && CheckGnomeShellExtensionsVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
		echo -en "-)\t GnomeSession "; 			source "$SHMAN_SDIR/GnomeSession.sh" && CheckGnomeSessionVerbose 1> /dev/null && 	echo -e "${C_GREEN}OK${C_RESET}" || echo;
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
			1) source "$SHMAN_SDIR/GTK3.sh" && InstallGTK3;;
			2) source "$SHMAN_SDIR/GTK4.sh" && InstallGTK4;;
			3) source "$SHMAN_SDIR/Gcr3.sh" && InstallGcr3;;
			4) source "$SHMAN_SDIR/Gcr4.sh" && InstallGcr4;;
			5) source "$SHMAN_SDIR/FreeType.sh" && InstallFreeType;;
			a|A)	source "$SHMAN_SDIR/Gcr3.sh" && InstallGcr3;
					source "$SHMAN_SDIR/Gcr4.sh" && InstallGcr4;
					source "$SHMAN_SDIR/GSettingsDesktopSchemas.sh" && InstallGSettingsDesktopSchemas;
					source "$SHMAN_SDIR/LibSecret.sh" && InstallLibSecret;
					source "$SHMAN_SDIR/Rest.sh" && InstallRest;
					source "$SHMAN_SDIR/TotemPlParser.sh" && InstallTotemPlParser;
					source "$SHMAN_SDIR/VTE.sh" && InstallVTE;;
			9) InstallFunctionForGnomeShell;;
			q|Q)	return;;
		esac
		PressAnyKeyToContinue;
	done
}

InstallFunctionForGnomeShell()
{
	source "$SHMAN_SDIR/GnomeShell.sh" && InstallGnomeShell || return $?;

	# Required Runtime Dependencies
	source "$SHMAN_SDIR/AdwaitaIconTheme.sh" && InstallAdwaitaIconTheme && \
	source "$SHMAN_SDIR/DConf.sh" && InstallDConf && \
	source "$SHMAN_SDIR/Elogind.sh" && InstallElogind && \
	source "$SHMAN_SDIR/GDM.sh" && InstallGDM && \
	source "$SHMAN_SDIR/LibGweather.sh" && InstallLibGweather || \
	PressAnyKeyToContinue;

	# Recommended Runtime Dependencies
	source "$SHMAN_SDIR/Blocaled.sh" && InstallBlocaled && \
	source "$SHMAN_SDIR/GnomeMenus.sh" && InstallGnomeMenus || \
	PressAnyKeyToContinue;
}

# =====================================||===================================== #
#								   Execution								   #
# ===============ft_linux==============||==============©Othello=============== #

while true; do
	Width=$(tput cols);
	clear;

	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo -e	"${C_ORANGE}${C_BOLD}Shman - Shell Package Manager${C_RESET}";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo -e "p)\t Python Packages"
	echo -e "l)\t gcc Libraries"
	echo -e "b)\t Binaries"
	echo -e "G)\t Gnome"
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo -e "c)\t Clean";
	echo -e	"q)\t Quit";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	if [ ! -z "$ErrorMsg" ]; then
		printf	"$ErrorMsg\n"
		unset ErrorMsg;
		printf '%*s\n' "$Width" '' | tr ' ' '-';
	fi

	printf	"Input> ";
	GetKeyPress

	case "$input" in
		p)	MenuPips;;
		l)	MenuGccLibraries;;
		b)	MenuBinaries;;
		G)	MenuGnome;;
		c|C)	find "/usr/src/shman/Packages/" -maxdepth 1 -type f -name '*.tar.*' | while read -r Tarball; do
					ExtractedDirectory="$(tar -tf "$Tarball" | head -1 | cut -f1 -d"/")";
					[ -d ${SHMAN_PDIR}${ExtractedDirectory} ] && rm -r ${SHMAN_PDIR}${ExtractedDirectory};
				done
				;;&
		C)	rm ${SHMAN_PDIR}*.patch*;
			rm ${SHMAN_PDIR}*.tar.*;;
		q|Q)	break;;
		*)	ErrorMsg="Bad input: $input";;
	esac
done
