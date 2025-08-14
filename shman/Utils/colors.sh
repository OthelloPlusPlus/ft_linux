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
# 				 https://en.wikipedia.org/wiki/ANSI_escape_code				   #
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
#							   Foreground Colors							   #
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
#							   Background Colors							   #
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
C_OK="${ESC_SEQ}38;2;16;223;16m"
C_KO="${ESC_SEQ}38;2;223;16;16m"
CB_VSCTERM="${ESC_SEQ}48;2;24;24;24m"
}

: ' ===================================||==================================== *\
||																			  ||
||								   256 Color								  ||
||																			  ||
||						  		8-bit 256 colors							  ||
||																			  ||
||					index = 16 + red * 36 + green * 6 + blue				  ||
||									0:	0									  ||
||									1:	95									  ||
||									2:	135									  ||
||									3:	175									  ||
||									4:	215									  ||
||									5:	255									  ||
||																			  ||
\* ============== Colors ==============||============= ©Othello ============= '
Set256Color()
{
# =====================================||===================================== #
#																			   #
#							   Foreground Colors							   #
#																			   #
# =====================================||===================================== #
#								   Graytones								   #
# =============== Colors ==============||============= ©Othello ============== #
C_WHITE="${ESC_SEQ}38;5;255m"
C_LGRAY="${ESC_SEQ}38;5;250m"
C_GRAY="${ESC_SEQ}38;5;244m"
C_DGRAY="${ESC_SEQ}38;5;238m"
C_BLACK="${ESC_SEQ}38;5;232m"
# =====================================||===================================== #
#									Rainbow									   #
# =============== Colors ==============||============= ©Othello ============== #
C_LRED="${ESC_SEQ}38;5;$((16+5*36+2*6+2))m"
C_RED="${ESC_SEQ}38;5;$((16+5*36+0*6+0))m"
C_DRED="${ESC_SEQ}38;5;$((16+2*36+0*6+0))m"
C_LORANGE="${ESC_SEQ}38;5;$((16+5*36+3*6+2))m"
C_ORANGE="${ESC_SEQ}38;5;$((16+5*36+2*6+0))m"
C_DORANGE="${ESC_SEQ}38;5;$((16+2*36+1*6+0))m"
C_LYELLOW="${ESC_SEQ}38;5;$((16+5*36+5*6+2))m"
C_YELLOW="${ESC_SEQ}38;5;$((16+5*36+5*6+0))m"
C_DYELLOW="${ESC_SEQ}38;5;$((16+2*36+2*6+0))m"
C_LCHRT="${ESC_SEQ}38;5;$((16+3*36+5*6+2))m"
C_CHRT="${ESC_SEQ}38;5;$((16+2*36+5*6+0))m"	#chartreuse
C_DCHRT="${ESC_SEQ}38;5;$((16+1*36+2*6+0))m"
C_LGREEN="${ESC_SEQ}38;5;$((16+2*36+5*6+2))m"
C_GREEN="${ESC_SEQ}38;5;$((16+0*36+5*6+0))m"
C_DGREEN="${ESC_SEQ}38;5;$((16+0*36+2*6+0))m"
C_LSPRGR="${ESC_SEQ}38;5;$((16+2*36+5*6+3))m"
C_SPRGR="${ESC_SEQ}38;5;$((16+0*36+5*6+2))m"	#spring green
C_DSPRGR="${ESC_SEQ}38;5;$((16+0*36+2*6+1))m"
C_LCYAN="${ESC_SEQ}38;5;$((16+2*36+5*6+5))m"
C_CYAN="${ESC_SEQ}38;5;$((16+0*36+5*6+5))m"
C_DCYAN="${ESC_SEQ}38;5;$((16+0*36+2*6+2))m"
C_LAZURE="${ESC_SEQ}38;5;$((16+0*36+3*6+5))m"
C_AZURE="${ESC_SEQ}38;5;$((16+0*36+2*6+5))m"
C_DAZURE="${ESC_SEQ}38;5;$((16+0*36+1*6+2))m"
C_LBLUE="${ESC_SEQ}38;5;$((16+2*36+2*6+5))m"
C_BLUE="${ESC_SEQ}38;5;$((16+0*36+0*6+5))m"
C_DBLUE="${ESC_SEQ}38;5;$((16+0*36+0*6+2))m"
C_LVIOLET="${ESC_SEQ}38;5;$((16+3*36+0*6+5))m"
C_VIOLET="${ESC_SEQ}38;5;$((16+2*36+0*6+5))m"
C_DVIOLET="${ESC_SEQ}38;5;$((16+1*36+0*6+5))m"
C_LMGNT="${ESC_SEQ}38;5;$((16+5*36+2*6+5))m"
C_MGNT="${ESC_SEQ}38;5;$((16+5*36+0*6+5))m"	#magenta
C_DMGNT="${ESC_SEQ}38;5;$((16+2*36+0*6+2))m"
C_LROSE="${ESC_SEQ}38;5;$((16+5*36+2*6+3))m"
C_ROSE="${ESC_SEQ}38;5;$((16+5*36+0*6+2))m"
C_DROSE="${ESC_SEQ}38;5;$((16+2*36+0*6+1))m"
# =====================================||===================================== #
#								 Common Colors								   #
# =============== Colors ==============||============= ©Othello ============== #
C_LBROWN="${ESC_SEQ}38;5;$((16+3*36+2*6+1))m"
C_BROWN="${ESC_SEQ}38;5;$((16+2*36+1*6+0))m" #hue 30
C_DBROWN="${ESC_SEQ}38;5;$((16+1*36+1*6+0))m"
C_LPURPLE="${ESC_SEQ}38;5;$((16+3*36+1*6+3))m"
C_PURPLE="${ESC_SEQ}38;5;$((16+2*36+0*6+2))m" #hue 300
C_DPURPLE="${ESC_SEQ}38;5;$((16+1*36+0*6+1))m"
C_LPINK="${ESC_SEQ}38;5;$((16+5*36+4*6+4))m"
C_PINK="${ESC_SEQ}38;5;$((16+5*36+3*6+4))m" #hue 350
C_DPINK="${ESC_SEQ}38;5;$((16+2*36+1*6+1))m"
# =====================================||===================================== #
#								  Prized Metal								   #
# =============== Colors ==============||============= ©Othello ============== #
C_BRONZE="${ESC_SEQ}38;5;$((16+4*36+2*6+1))m"
C_SILVER="${ESC_SEQ}38;5;$((16+3*36+3*6+3))m"
C_GOLD="${ESC_SEQ}38;5;$((16+5*36+4*6+0))m"
# =====================================||===================================== #
#																			   #
#							   Background Colors							   #
#																			   #
# =====================================||===================================== #
#								   Graytones								   #
# =============== Colors ==============||============= ©Othello ============== #
CB_WHITE="${ESC_SEQ}48;5;$((16+5*36+5*6+5))m"
CB_LGRAY="${ESC_SEQ}48;5;$((16+3*36+3*6+3))m"
CB_GRAY="${ESC_SEQ}48;5;$((16+2*36+2*6+2))m"
CB_DGRAY="${ESC_SEQ}48;5;$((16+1*36+1*6+1))m"
CB_BLACK="${ESC_SEQ}48;5;$((16+0*36+0*6+0))m"
# =====================================||===================================== #
#									Rainbow									   #
# =============== Colors ==============||============= ©Othello ============== #
CB_LRED="${ESC_SEQ}48;5;$((16+5*36+2*6+2))m"
CB_RED="${ESC_SEQ}48;5;$((16+5*36+0*6+0))m"
CB_DRED="${ESC_SEQ}48;5;$((16+2*36+0*6+0))m"
CB_LORANGE="${ESC_SEQ}48;5;$((16+5*36+3*6+2))m"
CB_ORANGE="${ESC_SEQ}48;5;$((16+5*36+2*6+0))m"
CB_DORANGE="${ESC_SEQ}48;5;$((16+2*36+1*6+0))m"
CB_LYELLOW="${ESC_SEQ}48;5;$((16+5*36+5*6+2))m"
CB_YELLOW="${ESC_SEQ}48;5;$((16+5*36+5*6+0))m"
CB_DYELLOW="${ESC_SEQ}48;5;$((16+2*36+2*6+0))m"
CB_LCHRT="${ESC_SEQ}48;5;$((16+3*36+5*6+2))m"
CB_CHRT="${ESC_SEQ}48;5;$((16+2*36+5*6+0))m"	#chartreuse
CB_DCHRT="${ESC_SEQ}48;5;$((16+1*36+2*6+0))m"
CB_LGREEN="${ESC_SEQ}48;5;$((16+2*36+5*6+2))m"
CB_GREEN="${ESC_SEQ}48;5;$((16+0*36+5*6+0))m"
CB_DGREEN="${ESC_SEQ}48;5;$((16+0*36+2*6+0))m"
CB_LSPRGR="${ESC_SEQ}48;5;$((16+2*36+5*6+3))m"
CB_SPRGR="${ESC_SEQ}48;5;$((16+0*36+5*6+2))m"	#spring green
CB_DSPRGR="${ESC_SEQ}48;5;$((16+0*36+2*6+1))m"
CB_LCYAN="${ESC_SEQ}48;5;$((16+2*36+5*6+5))m"
CB_CYAN="${ESC_SEQ}48;5;$((16+0*36+5*6+5))m"
CB_DCYAN="${ESC_SEQ}48;5;$((16+0*36+2*6+2))m"
CB_LAZURE="${ESC_SEQ}48;5;$((16+0*36+3*6+5))m"
CB_AZURE="${ESC_SEQ}48;5;$((16+0*36+2*6+5))m"
CB_DAZURE="${ESC_SEQ}48;5;$((16+0*36+1*6+2))m"
CB_LBLUE="${ESC_SEQ}48;5;$((16+2*36+2*6+5))m"
CB_BLUE="${ESC_SEQ}48;5;$((16+0*36+0*6+5))m"
CB_DBLUE="${ESC_SEQ}48;5;$((16+0*36+0*6+2))m"
CB_LVIOLET="${ESC_SEQ}48;5;$((16+3*36+0*6+5))m"
CB_VIOLET="${ESC_SEQ}48;5;$((16+2*36+0*6+5))m"
CB_DVIOLET="${ESC_SEQ}48;5;$((16+1*36+0*6+5))m"
CB_LMGNT="${ESC_SEQ}48;5;$((16+5*36+2*6+5))m"
CB_MGNT="${ESC_SEQ}48;5;$((16+5*36+0*6+5))m"	#magenta
CB_DMGNT="${ESC_SEQ}48;5;$((16+2*36+0*6+2))m"
CB_LROSE="${ESC_SEQ}48;5;$((16+5*36+2*6+3))m"
CB_ROSE="${ESC_SEQ}48;5;$((16+5*36+0*6+2))m"
CB_DROSE="${ESC_SEQ}48;5;$((16+2*36+0*6+1))m"
# =====================================||===================================== #
#								 Common Colors								   #
# =============== Colors ==============||============= ©Othello ============== #
CB_LBROWN="${ESC_SEQ}48;5;$((16+3*36+2*6+1))m"
CB_BROWN="${ESC_SEQ}48;5;$((16+2*36+1*6+0))m" #hue 30
CB_DBROWN="${ESC_SEQ}48;5;$((16+1*36+1*6+0))m"
CB_LPURPLE="${ESC_SEQ}48;5;$((16+3*36+1*6+3))m"
CB_PURPLE="${ESC_SEQ}48;5;$((16+2*36+0*6+2))m" #hue 300
CB_DPURPLE="${ESC_SEQ}48;5;$((16+1*36+0*6+1))m"
CB_LPINK="${ESC_SEQ}48;5;$((16+5*36+4*6+4))m"
CB_PINK="${ESC_SEQ}48;5;$((16+5*36+3*6+4))m" #hue 350
CB_DPINK="${ESC_SEQ}48;5;$((16+2*36+1*6+1))m"
# =====================================||===================================== #
#								  Prized Metal								   #
# =============== Colors ==============||============= ©Othello ============== #
CB_BRONZE="${ESC_SEQ}48;5;$((16+4*36+2*6+1))m"
CB_SILVER="${ESC_SEQ}48;5;$((16+3*36+3*6+3))m"
CB_GOLD="${ESC_SEQ}48;5;$((16+5*36+4*6+0))m"
# =====================================||===================================== #
#																			   #
#								 Miscellaneous								   #
#																			   #
# =====================================||===================================== #
C_OK="${ESC_SEQ}38;5;$((16+0*36+4*6+0))m"
C_KO="${ESC_SEQ}38;5;$((16+4*36+0*6+0))m"
CB_VSCTERM="${ESC_SEQ}48;5;234m"
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
#							   Foreground Colors							   #
#																			   #
# =====================================||===================================== #
#								   Graytones								   #
# =============== Colors ==============||============= ©Othello ============== #
C_WHITE="${ESC_SEQ}1;37m"
C_LGRAY="${C_WHITE}"
C_GRAY="${ESC_SEQ}1;90m"
C_DGRAY="${C_GRAY}"
C_BLACK="${ESC_SEQ}1;30m"
# =====================================||===================================== #
#									Rainbow									   #
# =============== Colors ==============||============= ©Othello ============== #
C_LRED="${ESC_SEQ}1;91m"
C_RED="${ESC_SEQ}1;31m"
C_DRED="${C_RED}"
C_LORANGE="${C_LRED}"
C_ORANGE="${C_RED}"
C_DORANGE="${C_ORANGE}"
C_LYELLOW="${ESC_SEQ}1;93m"
C_YELLOW="${ESC_SEQ}1;33m"
C_DYELLOW="${C_YELLOW}"
C_LCHRT="${C_LYELLOW}"
C_CHRT="${C_YELLOW}"
C_DCHRT="${C_CHRT}"
C_LGREEN="${ESC_SEQ}1;92m"
C_GREEN="${ESC_SEQ}1;32m"
C_DGREEN="${C_GREEN}"
C_LSPRGR="${C_LGREEN}"
C_SPRGR="${C_GREEN}"
C_DSPRGR="${C_SPRGR}"
C_LCYAN="${ESC_SEQ}1;96m"
C_CYAN="${ESC_SEQ}1;36m"
C_DCYAN="${C_CYAN}"
C_LAZURE="${C_LCYAN}"
C_AZURE="${C_CYAN}"
C_DAZURE="${C_AZURE}"
C_LBLUE="${ESC_SEQ}1;94m"
C_BLUE="${ESC_SEQ}1;34m"
C_DBLUE="${C_BLUE}"
C_LVIOLET="${C_LBLUE}"
C_VIOLET="${C_BLUE}"
C_DVIOLET="${C_VIOLET}"
C_LMGNT="${ESC_SEQ}1;95m"
C_MGNT="${ESC_SEQ}1;35m"
C_DMGNT="${C_MGNT}"
C_LROSE="${C_LMGNT}"
C_ROSE="${C_MGNT}"
C_DROSE="${C_ROSE}"
# =====================================||===================================== #
#								 Common Colors								   #
# =============== Colors ==============||============= ©Othello ============== #
C_LBROWN="${C_DORANGE}"
C_BROWN="${C_DORANGE}"
C_DBROWN="${C_BROWN}"
C_LPURPLE="${C_MGNT}"
C_PURPLE="${C_DMGNT}"
C_DPURPLE="${C_PURPLE}"
C_LPINK="${C_LROSE}"
C_PINK="${C_ROSE}"
C_DPINK="${C_PINK}"
# =====================================||===================================== #
#								  Prized Metal								   #
# =============== Colors ==============||============= ©Othello ============== #
C_BRONZE="${C_LBROWN}"
C_SILVER="${C_LGRAY}"
C_GOLD="${C_YELLOW}"
# =====================================||===================================== #
#																			   #
#							   Background Colors							   #
#																			   #
# =====================================||===================================== #
#								   Graytones								   #
# =============== Colors ==============||============= ©Othello ============== #
CB_WHITE="${ESC_SEQ}1;47m"
CB_LGRAY="${CB_WHITE}"
CB_GRAY="${ESC_SEQ}1;100m"
CB_DGRAY="${CB_GRAY}"
CB_BLACK="${ESC_SEQ}1;40m"
# =====================================||===================================== #
#									Rainbow									   #
# =============== Colors ==============||============= ©Othello ============== #
CB_LRED="${ESC_SEQ}1;101m"
CB_RED="${ESC_SEQ}1;41m"
CB_DRED="${CB_RED}"
CB_LORANGE="${CB_LRED}"
CB_ORANGE="${CB_RED}"
CB_DORANGE="${CB_ORANGE}"
CB_LYELLOW="${ESC_SEQ}1;103m"
CB_YELLOW="${ESC_SEQ}1;43m"
CB_DYELLOW="${CB_YELLOW}"
CB_LCHRT="${CB_LYELLOW}"
CB_CHRT="${CB_YELLOW}"
CB_DCHRT="${CB_CHRT}"
CB_LGREEN="${ESC_SEQ}1;102m"
CB_GREEN="${ESC_SEQ}1;42m"
CB_DGREEN="${CB_GREEN}"
CB_LSPRGR="${CB_LGREEN}"
CB_SPRGR="${CB_GREEN}"
CB_DSPRGR="${CB_SPRGR}"
CB_LCYAN="${ESC_SEQ}1;106m"
CB_CYAN="${ESC_SEQ}1;46m"
CB_DCYAN="${CB_CYAN}"
CB_LAZURE="${CB_LCYAN}"
CB_AZURE="${CB_CYAN}"
CB_DAZURE="${CB_AZURE}"
CB_LBLUE="${ESC_SEQ}1;104m"
CB_BLUE="${ESC_SEQ}1;44m"
CB_DBLUE="${CB_BLUE}"
CB_LVIOLET="${CB_LBLUE}"
CB_VIOLET="${CB_BLUE}"
CB_DVIOLET="${CB_VIOLET}"
CB_LMGNT="${ESC_SEQ}1;105m"
CB_MGNT="${ESC_SEQ}1;45m"
CB_DMGNT="${CB_MGNT}"
CB_LROSE="${CB_LMGNT}"
CB_ROSE="${CB_MGNT}"
CB_DROSE="${CB_ROSE}"
# =====================================||===================================== #
#								 Common Colors								   #
# =============== Colors ==============||============= ©Othello ============== #
CB_LBROWN="${CB_DORANGE}"
CB_BROWN="${CB_DORANGE}"
CB_DBROWN="${CB_BROWN}"
CB_LPURPLE="${CB_MGNT}"
CB_PURPLE="${CB_DMGNT}"
CB_DPURPLE="${CB_PURPLE}"
CB_LPINK="${CB_LROSE}"
CB_PINK="${CB_ROSE}"
CB_DPINK="${CB_PINK}"
# =====================================||===================================== #
#								  Prized Metal								   #
# =============== Colors ==============||============= ©Othello ============== #
CB_BRONZE="${CB_LBROWN}"
CB_SILVER="${CB_LGRAY}"
CB_GOLD="${CB_YELLOW}"
# =====================================||===================================== #
#																			   #
#								 Miscellaneous								   #
#																			   #
# =====================================||===================================== #
C_OK="${C_GREEN}"
C_KO="${C_RED}"
CB_VSCTERM="${CB_GRAY}"
}

: ' ===================================||==================================== *\
||																			  ||
||								General Escapes								  ||
||																			  ||
\* ============== Colors ==============||============= ©Othello ============= '
SetGeneral()
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
#								 Miscellaneous								   #
#																			   #
# =====================================||===================================== #
C_HEADER="${CB_DGRAY} ${CB_GRAY} ${CB_LGRAY} ${CB_ORANGE}${C_BOLD}${C_BLACK} "
C_SUBHEAD="${CB_DGRAY} ${CB_GRAY} ${CB_LGRAY}${C_BOLD}${C_BLACK} "
}

SetCursorControls()
{
CC_SAVE="${ESC_SEQ}s"	# Save cursor position
CC_LOAD="${ESC_SEQ}u"	# Restore cursor position

CC_CLEARLINE="${ESC_SEQ}2K"		# Clear entire current line
CC_CLEARREST="${ESC_SEQ}0J"		# Clear screen from cursor to end
CC_CLEARSCREEN="${ESC_SEQ}2J"	# Clear entire screen

CC_MOVEHOME="${ESC_SEQ}H"	# Move cursor to home position (0,0)
CC_MOVEUP="${ESC_SEQ}A"		# Move cursor up 1 line
CC_MOVEDOWN="${ESC_SEQ}B"	# Move cursor down 1 line
CC_MOVERIGHT="${ESC_SEQ}C"	# Move cursor right 1 column
CC_MOVELEFT="${ESC_SEQ}D"	# Move cursor left 1 column

# Inoperable because required arguments
if false; then
CC_MOVETOROW="${ESC_SEC}${row}H"		# Move cursors to specific row
CC_MOVETOCOL="${ESC_SEC}${col}g"		# Move cursors to specific col
CC_MOVETOPOS="${ESC_SEC}${row}l${col}H"	# Move cursors to specific row and col
fi
}

# =====================================||===================================== #
#																			   #
#								Color Definition							   #
#																			   #
# =============== Colors ==============||============= ©Othello ============== #

colors=$(tput colors 2>/dev/null || echo 0)
SHELLTYPE="$(basename $(readlink -f /proc/$$/exe))"

case "$SHELLTYPE" in
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

SetGeneral;
SetCursorControls;

# =====================================||===================================== #
#																			   #
#									  Demo									   #
#																			   #
# =============== Colors ==============||============= ©Othello ============== #

if [ -n "$1" ]; then
PrintDemo()
{
	# Headers
	printf	"${C_HEADER}${colors} ${COLORTERM} ${C_RESET}\n";
	printf	"${C_SUBHEAD}${SHELLTYPE} ${C_RESET}\n";
	# Graytones
	printf	"${CB_BLACK} ${CB_DGRAY} ${CB_GRAY} ${CB_LGRAY} ${CB_WHITE} ${C_RESET}\t${C_BLACK}%s${C_DGRAY}%s${C_GRAY}%s${C_LGRAY}%s${C_WHITE}%s${C_RESET}\n"	"Gr"	"ay"	"t"	"on"	"es";
	# Rainbow
	printf	" ${CB_DRED} ${CB_RED} ${CB_LRED} ${C_RESET} \t${C_RESET}${C_DRED}%s${C_RED}%s${C_LRED}%s${C_RESET}\n"						"C_"	"R"	"ED";
	printf	" ${CB_DORANGE} ${CB_ORANGE} ${CB_LORANGE} ${C_RESET} \t${C_RESET}${C_DORANGE}%s${C_ORANGE}%s${C_LORANGE}%s${C_RESET}\n"	"C_O"	"RA"	"NGE";
	printf	" ${CB_DYELLOW} ${CB_YELLOW} ${CB_LYELLOW} ${C_RESET} \t${C_RESET}${C_DYELLOW}%s${C_YELLOW}%s${C_LYELLOW}%s${C_RESET}\n"	"C_Y"	"EL"	"LOW";
	printf	" ${CB_DCHRT} ${CB_CHRT} ${CB_LCHRT} ${C_RESET} \t${C_RESET}${C_DCHRT}%s${C_CHRT}%s${C_LCHRT}%s${C_RESET}\n"				"C_CHRT"	" (Chart"	"reuse)";
	printf	" ${CB_DGREEN} ${CB_GREEN} ${CB_LGREEN} ${C_RESET} \t${C_RESET}${C_DGREEN}%s${C_GREEN}%s${C_LGREEN}%s${C_RESET}\n"			"C_"	"GRE"	"EN";
	printf	" ${CB_DSPRGR} ${CB_SPRGR} ${CB_LSPRGR} ${C_RESET} \t${C_RESET}${C_DSPRGR}%s${C_SPRGR}%s${C_LSPRGR}%s${C_RESET}\n"			"C_SPRGR"	" (Spring"	" Green)";
	printf	" ${CB_DCYAN} ${CB_CYAN} ${CB_LCYAN} ${C_RESET} \t${C_RESET}${C_DCYAN}%s${C_CYAN}%s${C_LCYAN}%s${C_RESET}\n"				"C_"	"CY"	"AN";
	printf	" ${CB_DAZURE} ${CB_AZURE} ${CB_LAZURE} ${C_RESET} \t${C_RESET}${C_DAZURE}%s${C_AZURE}%s${C_LAZURE}%s${C_RESET}\n"			"C_"	"AZU"	"RE";
	printf	" ${CB_DBLUE} ${CB_BLUE} ${CB_LBLUE} ${C_RESET} \t${C_RESET}${C_DBLUE}%s${C_BLUE}%s${C_LBLUE}%s${C_RESET}\n"				"C_"	"BL"	"UE";
	printf	" ${CB_DVIOLET} ${CB_VIOLET} ${CB_LVIOLET} ${C_RESET} \t${C_RESET}${C_DVIOLET}%s${C_VIOLET}%s${C_LVIOLET}%s${C_RESET}\n"	"C_V"	"IO"	"LET";
	printf	" ${CB_DMGNT} ${CB_MGNT} ${CB_LMGNT} ${C_RESET} \t${C_RESET}${C_DMGNT}%s${C_MGNT}%s${C_LMGNT}%s${C_RESET}\n"				"C_MGNT"	" (Mag"	"enta)";
	printf	" ${CB_DROSE} ${CB_ROSE} ${CB_LROSE} ${C_RESET} \t${C_RESET}${C_DROSE}%s${C_ROSE}%s${C_LROSE}%s${C_RESET}\n"				"C_"	"RO"	"SE";
	# Common Colors
	printf	" ${CB_DBROWN} ${CB_BROWN} ${CB_LBROWN} ${C_RESET} \t${C_RESET}${C_DBROWN}%s${C_BROWN}%s${C_LBROWN}%s${C_RESET}\n"			"C_"	"BRO"	"WN";
	printf	" ${CB_DPURPLE} ${CB_PURPLE} ${CB_LPURPLE} ${C_RESET} \t${C_RESET}${C_DPURPLE}%s${C_PURPLE}%s${C_LPURPLE}%s${C_RESET}\n"	"C_P"	"URP"	"LE";
	printf	" ${CB_DPINK} ${CB_PINK} ${CB_LPINK} ${C_RESET} \t${C_RESET}${C_DPINK}%s${C_PINK}%s${C_LPINK}%s${C_RESET}\n"				"C_"	"PI"	"NK";
	# Prized Metals
	printf	" ${CB_BRONZE} ${CB_SILVER} ${CB_GOLD} ${C_RESET} \t${C_RESET}${C_BRONZE}%s${C_SILVER}%s${C_GOLD}%s${C_RESET}\n"			"Prized"	" Metal "	"Colors";
	# OK / KO
	printf	"${CB_VSCTERM}${C_OK}[OK]${C_KO}[KO]${C_RESET}\n"
}
	case "$1" in
		-d)		PrintDemo;;
		-d8)	SetAnsiColor;	PrintDemo;;
		-d256)	Set256Color;	PrintDemo;;
		-dtrue)	SetTrueColor;	PrintDemo;;
		-d*)	SetAnsiColor;	PrintDemo;
				Set256Color;	PrintDemo;
				SetTrueColor;	PrintDemo;;
		*)		echo	"Known flags: -d -d8 -d256 -dtrue -dall";;
	esac
fi
