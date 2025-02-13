# =====================================||===================================== #
#																			   #
#							   Colors and Styles							   #
#																			   #
#																			   #
#																			   #
#		https://chrisyeh96.github.io/2020/03/28/terminal-colors.html		   #
#				 https://www.google.com/search?q=color+chooser				   #
#				  https://en.wikipedia.org/wiki/Tertiary_color				   #
#																			   #
#																			   #
# https://en.wikipedia.org/wiki/ANSI_escape_code#Select_Graphic_Rendition_parameters #
#																			   #
# =============== Colors ==============||============= ©Othello ============== #

: ' ===================================||==================================== *\
||																			  ||
||								   True Color								  ||
||																			  ||
||						   24-bit 16,777,216 colors							  ||
||																			  ||
\* ============== Colors ==============||============= ©Othello ============= '
SetTrueColor()
{
# =====================================||===================================== #
#																			   #
#									 Reset									   #
#																			   #
# =============== Colors ==============||============= ©Othello ============== #
C_RESET="${ESC_SEQ}0m"
# =====================================||===================================== #
#																			   #
#									 Styles									   #
#																			   #
# =============== Colors ==============||============= ©Othello ============== #
C_BOLD="${ESC_SEQ}1m"
C_WEAK="${ESC_SEQ}2m"
C_CURS="${ESC_SEQ}3m"
C_UNDL="${ESC_SEQ}4m"
C_BLNK="${ESC_SEQ}5m"
C_REV="${ESC_SEQ}7m"
C_HIDDEN="${ESC_SEQ}8m"
C_STRIKE="${ESC_SEQ}9m"
# =====================================||===================================== #
#																			   #
#									 Colors									   #
#																			   #
# =====================================||===================================== #
#								   Graytones								   #
# =============== Colors ==============||============= ©Othello ============== #
C_WHITE="${ESC_SEQ}38;2;255;255;255m"
C_LGRAY="${ESC_SEQ}38;2;192;192;192m"
C_GRAY="${ESC_SEQ}38;2;128;128;128m"
C_DGRAY="${ESC_SEQ}38;2;64;64;64m"
C_BLACK="${ESC_SEQ}38;2;0;0;0m"
# =====================================||===================================== #
#									Rainbow									   #
# =============== Colors ==============||============= ©Othello ============== #
C_LRED="${ESC_SEQ}38;2;255;128;128m"
C_RED="${ESC_SEQ}38;2;255;0;0m"
C_DRED="${ESC_SEQ}38;2;128;0;0m"
C_LORANGE="${ESC_SEQ}38;2;255;192;128m"
C_ORANGE="${ESC_SEQ}38;2;255;128;0m"
C_DORANGE="${ESC_SEQ}38;2;128;64;0m"
C_LYELLOW="${ESC_SEQ}38;2;255;255;128m"
C_YELLOW="${ESC_SEQ}38;2;255;255;0m"
C_DYELLOW="${ESC_SEQ}38;2;128;128;0m"
C_LCHRT="${ESC_SEQ}38;2;192;255;128m"
C_CHRT="${ESC_SEQ}38;2;128;255;0m"	#chartreuse
C_DCHRT="${ESC_SEQ}38;2;64;128;0m"
C_LGREEN="${ESC_SEQ}38;2;128;255;128m"
C_GREEN="${ESC_SEQ}38;2;0;255;0m"
C_DGREEN="${ESC_SEQ}38;2;0;128;0m"
C_LSPRGR="${ESC_SEQ}38;2;128;255;192m"
C_SPRGR="${ESC_SEQ}38;2;0;255;128m"	#spring green
C_DSPRGR="${ESC_SEQ}38;2;0;128;64m"
C_LCYAN="${ESC_SEQ}38;2;128;255;255m"
C_CYAN="${ESC_SEQ}38;2;0;255;255m"
C_DCYAN="${ESC_SEQ}38;2;0;128;128m"
C_LAZURE="${ESC_SEQ}38;2;0;192;255m"
C_AZURE="${ESC_SEQ}38;2;0;128;255m"
C_DAZURE="${ESC_SEQ}38;2;0;64;128m"
C_LBLUE="${ESC_SEQ}38;2;128;128;255m"
C_BLUE="${ESC_SEQ}38;2;0;0;255m"
C_DBLUE="${ESC_SEQ}38;2;0;0;128m"
C_LVIOLET="${ESC_SEQ}38;2;192;0;255m"
C_VIOLET="${ESC_SEQ}38;2;128;0;255m"
C_DVIOLET="${ESC_SEQ}38;2;64;0;255m"
C_LMGNT="${ESC_SEQ}38;2;255;128;255m"
C_MGNT="${ESC_SEQ}38;2;255;0;255m"	#magenta
C_DMGNT="${ESC_SEQ}38;2;128;0;128m"
C_LROSE="${ESC_SEQ}38;2;255;128;192m"
C_ROSE="${ESC_SEQ}38;2;255;0;128m"
C_DROSE="${ESC_SEQ}38;2;128;0;64m"
# =====================================||===================================== #
#								 Common Colors								   #
# =============== Colors ==============||============= ©Othello ============== #
C_LBROWN="${ESC_SEQ}38;2;192;144;96m"
C_BROWN="${ESC_SEQ}38;2;128;64;0m" #hue 30
C_DBROWN="${ESC_SEQ}38;2;64;32;0m"
C_LPURPLE="${ESC_SEQ}38;2;192;96;192m"
C_PURPLE="${ESC_SEQ}38;2;128;0;128m" #hue 300
C_DPURPLE="${ESC_SEQ}38;2;64;0;64m"
C_LPINK="${ESC_SEQ}38;2;255;224;229m"
C_PINK="${ESC_SEQ}38;2;255;192;203m" #hue 350
C_DPINK="${ESC_SEQ}38;2;128;48;62m"
# =====================================||===================================== #
#								  Prized Metal								   #
# =============== Colors ==============||============= ©Othello ============== #
C_BRONZE="${ESC_SEQ}38;2;205;127;50m"
C_SILVER="${ESC_SEQ}38;2;192;192;192m"
C_GOLD="${ESC_SEQ}38;2;255;215;0m"
# =====================================||===================================== #
#																			   #
#								  Backgrounds								   #
#																			   #
# =====================================||===================================== #
#								   Graytones								   #
# =============== Colors ==============||============= ©Othello ============== #
CB_WHITE="${ESC_SEQ}48;2;255;255;255m"
CB_LGRAY="${ESC_SEQ}48;2;192;192;192m"
CB_GRAY="${ESC_SEQ}48;2;128;128;128m"
CB_DGRAY="${ESC_SEQ}48;2;64;64;64m"
CB_BLACK="${ESC_SEQ}48;2;0;0;0m"
# =====================================||===================================== #
#									Rainbow									   #
# =============== Colors ==============||============= ©Othello ============== #
CB_LRED="${ESC_SEQ}48;2;255;128;128m"
CB_RED="${ESC_SEQ}48;2;255;0;0m"
CB_DRED="${ESC_SEQ}48;2;128;0;0m"
CB_LORANGE="${ESC_SEQ}48;2;255;192;128m"
CB_ORANGE="${ESC_SEQ}48;2;255;128;0m"
CB_DORANGE="${ESC_SEQ}48;2;128;64;0m"
CB_LYELLOW="${ESC_SEQ}48;2;255;255;128m"
CB_YELLOW="${ESC_SEQ}48;2;255;255;0m"
CB_DYELLOW="${ESC_SEQ}48;2;128;128;0m"
CB_LCHRT="${ESC_SEQ}48;2;192;255;128m"
CB_CHRT="${ESC_SEQ}48;2;128;255;0m" #chartreuse
CB_DCHRT="${ESC_SEQ}48;2;64;128;0m"
CB_LGREEN="${ESC_SEQ}48;2;128;255;128m"
CB_GREEN="${ESC_SEQ}48;2;0;255;0m"
CB_DGREEN="${ESC_SEQ}48;2;0;128;0m"
CB_LSPRGR="${ESC_SEQ}48;2;128;255;192m"
CB_SPRGR="${ESC_SEQ}48;2;0;255;128m"	#spring green
CB_DSPRGR="${ESC_SEQ}48;2;0;128;64m"
CB_LCYAN="${ESC_SEQ}48;2;128;255;255m"
CB_CYAN="${ESC_SEQ}48;2;0;255;255m"
CB_DCYAN="${ESC_SEQ}48;2;0;128;128m"
CB_LAZURE="${ESC_SEQ}48;2;0;192;255m"
CB_AZURE="${ESC_SEQ}48;2;0;128;255m"
CB_DAZURE="${ESC_SEQ}48;2;0;64;128m"
CB_LBLUE="${ESC_SEQ}48;2;128;128;255m"
CB_BLUE="${ESC_SEQ}48;2;0;0;255m"
CB_DBLUE="${ESC_SEQ}48;2;0;0;128m"
CB_LVIOLET="${ESC_SEQ}48;2;192;0;255m"
CB_VIOLET="${ESC_SEQ}48;2;128;0;255m"
CB_DVIOLET="${ESC_SEQ}48;2;64;0;255m"
CB_LMGNT="${ESC_SEQ}48;2;255;128;255m"
CB_MGNT="${ESC_SEQ}48;2;255;0;255m"	#magenta
CB_DMGNT="${ESC_SEQ}48;2;128;0;128m"
CB_LROSE="${ESC_SEQ}48;2;255;128;192m"
CB_ROSE="${ESC_SEQ}48;2;255;0;128m"
CB_DROSE="${ESC_SEQ}48;2;128;0;64m"
# =====================================||===================================== #
#								 Common Colors								   #
# =============== Colors ==============||============= ©Othello ============== #
CB_LBROWN="${ESC_SEQ}48;2;192;144;96m"
CB_BROWN="${ESC_SEQ}48;2;128;64;0m" #hue 30
CB_DBROWN="${ESC_SEQ}48;2;64;32;0m"
CB_LPURPLE="${ESC_SEQ}48;2;192;96;192m"
CB_PURPLE="${ESC_SEQ}48;2;128;0;128m" #hue 300
CB_DPURPLE="${ESC_SEQ}48;2;64;0;64m"
CB_LPINK="${ESC_SEQ}48;2;255;224;229m"
CB_PINK="${ESC_SEQ}48;2;255;192;203m" #hue 350
CB_DPINK="${ESC_SEQ}48;2;128;48;62m"
# =====================================||===================================== #
#								  Prized Metal								   #
# =============== Colors ==============||============= ©Othello ============== #
CB_BRONZE="${ESC_SEQ}48;2;205;127;50m"
CB_SILVER="${ESC_SEQ}48;2;192;192;192m"
CB_GOLD="${ESC_SEQ}48;2;255;215;0m"
# =====================================||===================================== #
#																			   #
#								 Miscellaneous								   #
#																			   #
# =====================================||===================================== #
C_HEADER="${ESC_SEQ}48;2;85;85;85m ${ESC_SEQ}48;2;139;139;139m \
${ESC_SEQ}48;2;192;192;192m ${ESC_SEQ}48;2;255;128;0m ${ESC_SEQ}1m${ESC_SEQ}38;2;0;0;0m"
C_SUBHEAD="${ESC_SEQ}48;2;85;85;85m ${ESC_SEQ}48;2;139;139;139m \
${ESC_SEQ}48;2;192;192;192m ${ESC_SEQ}1m${ESC_SEQ}38;2;0;0;0m"
C_OK="${ESC_SEQ}38;2;16;223;16m"
}

: ' ===================================||==================================== *\
||																			  ||
||								   256 Color								  ||
||																			  ||
||						  		8-bit 256 colors							  ||
||																			  ||
\* ============== Colors ==============||============= ©Othello ============= '
Set256Color()
{
# =====================================||===================================== #
#																			   #
#									 Reset									   #
#																			   #
# =============== Colors ==============||============= ©Othello ============== #
C_RESET="${ESC_SEQ}0m"
# =====================================||===================================== #
#																			   #
#									 Styles									   #
#																			   #
# =============== Colors ==============||============= ©Othello ============== #
C_BOLD="${ESC_SEQ}1;38m"
C_WEAK=""
C_CURS=""
C_UNDL=""
C_BLNK=""
C_REV=""
C_HIDDEN=""
C_STRIKE=""
# =====================================||===================================== #
#																			   #
#									 Colors									   #
#																			   #
# =====================================||===================================== #
#								   Graytones								   #
# =============== Colors ==============||============= ©Othello ============== #
C_WHITE="${ESC_SEQ}1;37m"
C_LGRAY=""
C_GRAY="${ESC_SEQ}1;90m"
C_DGRAY=""
C_BLACK="${ESC_SEQ}1;30m"
# =====================================||===================================== #
#									Rainbow									   #
# =============== Colors ==============||============= ©Othello ============== #
C_LRED="${ESC_SEQ}1;91m"
C_RED="${ESC_SEQ}1;31m"
C_DRED=""
C_LORANGE=""
C_ORANGE=""
C_DORANGE=""
C_LYELLOW="${ESC_SEQ}1;93m"
C_YELLOW="${ESC_SEQ}1;33m"
C_DYELLOW=""
C_LCHRT=""
C_CHRT=""
C_DCHRT=""
C_LGREEN="${ESC_SEQ}1;92m"
C_GREEN="${ESC_SEQ}1;32m"
C_DGREEN=""
C_LSPRGR=""
C_SPRGR=""
C_DSPRGR=""
C_LCYAN="${ESC_SEQ}1;96m"
C_CYAN="${ESC_SEQ}1;36m"
C_DCYAN=""
C_LAZURE=""
C_AZURE=""
C_DAZURE=""
C_LBLUE="${ESC_SEQ}1;94m"
C_BLUE="${ESC_SEQ}1;34m"
C_DBLUE=""
C_LVIOLET=""
C_VIOLET=""
C_DVIOLET=""
C_LMGNT="${ESC_SEQ}1;95m"
C_MGNT="${ESC_SEQ}1;35m"
C_DMGNT=""
C_LROSE=""
C_ROSE=""
C_DROSE=""
# =====================================||===================================== #
#								 Common Colors								   #
# =============== Colors ==============||============= ©Othello ============== #
C_LBROWN=""
C_BROWN=""
C_DBROWN=""
C_LPURPLE=""
C_PURPLE=""
C_DPURPLE=""
C_LPINK=""
C_PINK=""
C_DPINK=""
# =====================================||===================================== #
#								  Prized Metal								   #
# =============== Colors ==============||============= ©Othello ============== #
C_BRONZE=""
C_SILVER=""
C_GOLD=""
# =====================================||===================================== #
#																			   #
#								  Backgrounds								   #
#																			   #
# =====================================||===================================== #
#								   Graytones								   #
# =============== Colors ==============||============= ©Othello ============== #
CB_WHITE="${ESC_SEQ}1;47m"
CB_LGRAY=""
CB_GRAY="${ESC_SEQ}1;100m"
CB_DGRAY=""
CB_BLACK="${ESC_SEQ}1;40m"
# =====================================||===================================== #
#									Rainbow									   #
# =============== Colors ==============||============= ©Othello ============== #
CB_LRED="${ESC_SEQ}1;101m"
CB_RED="${ESC_SEQ}1;41m"
CB_DRED=""
CB_LORANGE=""
CB_ORANGE=""
CB_DORANGE=""
CB_LYELLOW="${ESC_SEQ}1;103m"
CB_YELLOW="${ESC_SEQ}1;43m"
CB_DYELLOW=""
CB_LCHRT=""
CB_CHRT=""
CB_DCHRT=""
CB_LGREEN="${ESC_SEQ}1;102m"
CB_GREEN="${ESC_SEQ}1;42m"
CB_DGREEN=""
CB_LSPRGR=""
CB_SPRGR=""
CB_DSPRGR=""
CB_LCYAN="${ESC_SEQ}1;106m"
CB_CYAN="${ESC_SEQ}1;46m"
CB_DCYAN=""
CB_LAZURE=""
CB_AZURE=""
CB_DAZURE=""
CB_LBLUE="${ESC_SEQ}1;104m"
CB_BLUE="${ESC_SEQ}1;44m"
CB_DBLUE=""
CB_LVIOLET=""
CB_VIOLET=""
CB_DVIOLET=""
CB_LMGNT="${ESC_SEQ}1;105m"
CB_MGNT="${ESC_SEQ}1;45m"
CB_DMGNT=""
CB_LROSE=""
CB_ROSE=""
CB_DROSE=""
# =====================================||===================================== #
#								 Common Colors								   #
# =============== Colors ==============||============= ©Othello ============== #
CB_LBROWN=""
CB_BROWN=""
CB_DBROWN=""
CB_LPURPLE=""
CB_PURPLE=""
CB_DPURPLE=""
CB_LPINK=""
CB_PINK=""
CB_DPINK=""
# =====================================||===================================== #
#								  Prized Metal								   #
# =============== Colors ==============||============= ©Othello ============== #
CB_BRONZE=""
CB_SILVER=""
CB_GOLD=""
# =====================================||===================================== #
#																			   #
#								 Miscellaneous								   #
#																			   #
# =====================================||===================================== #
C_HEADER=""
C_SUBHEAD=""
C_OK=""
}

: ' ===================================||==================================== *\
||																			  ||
||								   Ansi Color								  ||
||																			  ||
||								 4-bit 8 colors								  ||
||																			  ||
\* ============== Colors ==============||============= ©Othello ============= '
SetAnsiColor()
{
# =====================================||===================================== #
#																			   #
#									 Reset									   #
#																			   #
# =============== Colors ==============||============= ©Othello ============== #
C_RESET="${ESC_SEQ}0m"
# =====================================||===================================== #
#																			   #
#									 Styles									   #
#																			   #
# =============== Colors ==============||============= ©Othello ============== #
C_BOLD="${ESC_SEQ}1;38m"
C_WEAK=""
C_CURS=""
C_UNDL=""
C_BLNK=""
C_REV=""
C_HIDDEN=""
C_STRIKE=""
# =====================================||===================================== #
#																			   #
#									 Colors									   #
#																			   #
# =====================================||===================================== #
#								   Graytones								   #
# =============== Colors ==============||============= ©Othello ============== #
C_WHITE="${ESC_SEQ}1;37m"
C_LGRAY=""
C_GRAY="${ESC_SEQ}1;90m"
C_DGRAY=""
C_BLACK="${ESC_SEQ}1;30m"
# =====================================||===================================== #
#									Rainbow									   #
# =============== Colors ==============||============= ©Othello ============== #
C_LRED="${ESC_SEQ}1;91m"
C_RED="${ESC_SEQ}1;31m"
C_DRED=""
C_LORANGE=""
C_ORANGE=""
C_DORANGE=""
C_LYELLOW="${ESC_SEQ}1;93m"
C_YELLOW="${ESC_SEQ}1;33m"
C_DYELLOW=""
C_LCHRT=""
C_CHRT=""
C_DCHRT=""
C_LGREEN="${ESC_SEQ}1;92m"
C_GREEN="${ESC_SEQ}1;32m"
C_DGREEN=""
C_LSPRGR=""
C_SPRGR=""
C_DSPRGR=""
C_LCYAN="${ESC_SEQ}1;96m"
C_CYAN="${ESC_SEQ}1;36m"
C_DCYAN=""
C_LAZURE=""
C_AZURE=""
C_DAZURE=""
C_LBLUE="${ESC_SEQ}1;94m"
C_BLUE="${ESC_SEQ}1;34m"
C_DBLUE=""
C_LVIOLET=""
C_VIOLET=""
C_DVIOLET=""
C_LMGNT="${ESC_SEQ}1;95m"
C_MGNT="${ESC_SEQ}1;35m"
C_DMGNT=""
C_LROSE=""
C_ROSE=""
C_DROSE=""
# =====================================||===================================== #
#								 Common Colors								   #
# =============== Colors ==============||============= ©Othello ============== #
C_LBROWN=""
C_BROWN=""
C_DBROWN=""
C_LPURPLE=""
C_PURPLE=""
C_DPURPLE=""
C_LPINK=""
C_PINK=""
C_DPINK=""
# =====================================||===================================== #
#								  Prized Metal								   #
# =============== Colors ==============||============= ©Othello ============== #
C_BRONZE=""
C_SILVER=""
C_GOLD=""
# =====================================||===================================== #
#																			   #
#								  Backgrounds								   #
#																			   #
# =====================================||===================================== #
#								   Graytones								   #
# =============== Colors ==============||============= ©Othello ============== #
CB_WHITE="${ESC_SEQ}1;47m"
CB_LGRAY=""
CB_GRAY="${ESC_SEQ}1;100m"
CB_DGRAY=""
CB_BLACK="${ESC_SEQ}1;40m"
# =====================================||===================================== #
#									Rainbow									   #
# =============== Colors ==============||============= ©Othello ============== #
CB_LRED="${ESC_SEQ}1;101m"
CB_RED="${ESC_SEQ}1;41m"
CB_DRED=""
CB_LORANGE=""
CB_ORANGE=""
CB_DORANGE=""
CB_LYELLOW="${ESC_SEQ}1;103m"
CB_YELLOW="${ESC_SEQ}1;43m"
CB_DYELLOW=""
CB_LCHRT=""
CB_CHRT=""
CB_DCHRT=""
CB_LGREEN="${ESC_SEQ}1;102m"
CB_GREEN="${ESC_SEQ}1;42m"
CB_DGREEN=""
CB_LSPRGR=""
CB_SPRGR=""
CB_DSPRGR=""
CB_LCYAN="${ESC_SEQ}1;106m"
CB_CYAN="${ESC_SEQ}1;46m"
CB_DCYAN=""
CB_LAZURE=""
CB_AZURE=""
CB_DAZURE=""
CB_LBLUE="${ESC_SEQ}1;104m"
CB_BLUE="${ESC_SEQ}1;44m"
CB_DBLUE=""
CB_LVIOLET=""
CB_VIOLET=""
CB_DVIOLET=""
CB_LMGNT="${ESC_SEQ}1;105m"
CB_MGNT="${ESC_SEQ}1;45m"
CB_DMGNT=""
CB_LROSE=""
CB_ROSE=""
CB_DROSE=""
# =====================================||===================================== #
#								 Common Colors								   #
# =============== Colors ==============||============= ©Othello ============== #
CB_LBROWN=""
CB_BROWN=""
CB_DBROWN=""
CB_LPURPLE=""
CB_PURPLE=""
CB_DPURPLE=""
CB_LPINK=""
CB_PINK=""
CB_DPINK=""
# =====================================||===================================== #
#								  Prized Metal								   #
# =============== Colors ==============||============= ©Othello ============== #
CB_BRONZE=""
CB_SILVER=""
CB_GOLD=""
# =====================================||===================================== #
#																			   #
#								 Miscellaneous								   #
#																			   #
# =====================================||===================================== #
C_HEADER=""
C_SUBHEAD=""
C_OK=""
}

# =====================================||===================================== #
#																			   #
#								Color Definition							   #
#																			   #
# =============== Colors ==============||============= ©Othello ============== #

colors=$(tput colors 2>/dev/null || echo 0)

case $(basename $(readlink -f /proc/$$/exe)) in
	dash)	ESC_SEQ='\033[';;
	*)		ESC_SEQ='\x1b[';;
esac

if [ "$COLORTERM" = "truecolor" ]; then
	SetTrueColor;
else
	if [ "$colors" -ge 256 ]; then
		Set256Color;
	elif [ "$colors" -ge 8 ]; then
		SetAnsiColor;
	fi
fi

if [ "$1" = "demo" ]; then
	if [ $(basename $(readlink -f /proc/$$/exe)) = "bash" ]; then
		echo -e	"${C_RED}$(basename $(readlink -f /proc/$$/exe))${C_RESET}";
	else
		echo	"${C_RED}$(basename $(readlink -f /proc/$$/exe))${C_RESET}";
	fi
fi
