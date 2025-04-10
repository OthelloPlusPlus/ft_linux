#! /bin/bash

source colors.sh

PDIR="$LFS/sources/lfs-packages12.2/";
CLEARING=true;

SHELLTYPE="$(basename $(readlink -f /proc/$$/exe))"

case "$SHELLTYPE" in
	bash)	ECHOFLAG='-e';;
esac

# =====================================||===================================== #
#																			   #
#				 					Packages								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

ExtractPackage()
{
	SRC="$1";
	DST="$2";

	if [[ -z "$SRC" || ! -f "$SRC"  || -z "$DST" ]]; then
		EchoError	"No $SRC or $DST";
		return 1;
	fi

	for FILENAME in $(tar -tf "$SRC"); do
		if [ ! -e ${DST}/${FILENAME} ]; then
			EchoInfo	"Unpacking $SRC($FILENAME)...";
			mkdir -p "$DST";
			tar -xf "$SRC" -C "$DST";
			return $?;
		fi
	done
	return 0;
}

RemovePackage()
{
	if [ -d "${PDIR}$1" ]; then
		rm -rf "${PDIR}$1";
	else
		EchoError	"Destination ${C_ORANGE}$1${C_RESET} is not a directory";
	fi
}

RunMakeCheckTest()
{
	if make -n check &> /dev/null; then
		if make check &> /dev/null; then
			EchoTest	OK	"$1";
		else
			EchoTest	KO	"$1";
			if [ -d "test" ]; then
				ls test/_*;
			fi
		fi
	else
		EchoTest	"$1 ${C_DGRAY}make -n check failed${C_RESET}";
	fi
}

# =====================================||===================================== #
#																			   #
#				 					Terminal								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #
# export TERM=xterm;

GetInput()
{
	echo ${ECHOFLAG}	"$MSG";
	echo -n	"Choose an option: ";
	unset MSG;
	read	input;
	printf '%*s\n' "$width" '' | tr ' ' '-';
}

GetKeyPress()
{
	stty -echo -icanon
	input=$(dd bs=1 count=1 2>/dev/null)
	stty sane
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
	echo ${ECHOFLAG}	"[${C_RED}ERR${C_RESET} ]  $1"	>&2;
}

EchoInfo()
{
	echo ${ECHOFLAG}	"[${C_CYAN}INFO${C_RESET}]$1";
}

EchoTest()
{
	if [ "$1" = OK ]; then
		echo ${ECHOFLAG}	"[${C_GREEN} OK ${C_RESET}] $2";
	elif [ "$1" = KO ]; then
		echo ${ECHOFLAG}	"[${C_RED} KO ${C_RESET}] $2";
	else
		echo ${ECHOFLAG}	"[${C_GRAY}TEST${C_RESET}] $1";
	fi
}
