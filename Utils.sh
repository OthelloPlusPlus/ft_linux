#! /bin/zsh

source colors.sh

PDIR="$LFS/sources/lfs-packages12.2/";
CLEARING=true;

GetInput()
{
	echo	"$MSG";
	echo -n	"Choose an option: ";
	unset MSG;
	read	input;
	printf '%*s\n' "$width" '' | tr ' ' '-';
}

PressAnyKeyToContinue()
{
	printf '%*s\n' "$width" '' | tr ' ' '-';
	if [ -t 0 ]; then
		echo	"Press any key to continue...";
		stty -echo -icanon
		input=$(dd bs=1 count=1 2>/dev/null)
		stty sane
	else
		echo	"Press Enter/Return to continue...";
		read -n 1 input;
	fi
	printf '%*s\n' "$width" '' | tr ' ' '-';
}

EchoError()
{
	echo	"[${C_RED}ERR${C_RESET} ]  $1"	>&2;
}

EchoInfo()
{
	echo	"[${C_CYAN}INFO${C_RESET}]$1";
}

EchoTest()
{
	if [ "$1" = OK ]; then
		echo	"[${C_GREEN} OK ${C_RESET}] $2";
	elif [ "$1" = KO ]; then
		echo	"[${C_RED} KO ${C_RESET}] $2";
	else
		echo	"[${C_GRAY}TEST${C_RESET}] $1";
	fi
}
