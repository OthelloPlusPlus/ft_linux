#! /bin/bash

source /usr/local/shell/colors.sh

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

DownloadPackage()
{
	if [ ! -z "${1}" ] && [ ! -z "${2}" ]; then
		if [ -f "${2}${3}" ]; then
			if [ ! -z "${4}" ] && [ "$(md5sum "${2}${3}" | awk '{print $1}')" = "$4" ]; then
				return ;
			else
				EchoError	"Issue with MD5sum $4";
			fi
		fi
		EchoInfo	"Downloading ${3}"
		wget -P "${2}" "${1}";
		local WgetStatus=$?
		case $WgetStatus in
			0) ;;
			4) EchoError	"[$WgetStatus]Network failure."
				local HostAddress=${1};
				HostAddress="${HostAddress#*://}";
				HostAddress="${HostAddress%%/*}";
				getent hosts $HostAddress || EchoError "[$?]Check /etc/resolv.conf";;
			6) EchoError	"[$WgetStatus]Username/password auth failure.";;
			8) EchoError	"[$WgetStatus]Server issued an error response.";;
			*) EchoError	"[$WgetStatus]Error";;
		esac
	fi
}

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

ReExtractPackage()
{
	local SRC="${1}${2}${3}";
	local DST="${1}";
	local RSLT="${1}${2}";

	if [ ! -f "$SRC" ] || [ ! -d "$DST" ]; then
		if [ ! -f "$SRC" ]; then EchoError	"ReExtractPackage SRC[$SRC]"; fi
		if [ ! -d "$DST" ]; then EchoError	"ReExtractPackage DST[$DST]"; fi
		return 1;
	fi

	if [ -d "$RSLT" ]; then
		rm -rf "$RSLT";
	fi

	tar -xf "$SRC" -C "$DST" || { echo "Failed to extract $?" >&2 && PressAnyKeyToContinue; };
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
	# echo ${ECHOFLAG}	"[${C_RED}ERR${C_RESET} ]  $1"	>&2;
	printf	"[${C_RED}ERR${C_RESET} ]  $1\n"	>&2;
}

EchoInfo()
{
	# echo ${ECHOFLAG}	"[${C_CYAN}INFO${C_RESET}]$1";
	printf	"[${C_CYAN}INFO${C_RESET}]$1\n";
}

EchoTest()
{
	if [ "$1" = OK ]; then
		# echo ${ECHOFLAG}	"[${C_GREEN} OK ${C_RESET}] $2";
		printf	"[${C_GREEN} OK ${C_RESET}] $2\n";
	elif [ "$1" = KO ]; then
		# echo ${ECHOFLAG}	"[${C_RED} KO ${C_RESET}] $2";
		printf	"[${C_RED} KO ${C_RESET}] $2\n";
	else
		# echo ${ECHOFLAG}	"[${C_GRAY}TEST${C_RESET}] $1";
		printf	"[${C_GRAY}TEST${C_RESET}] $1\n";
	fi
}

# =====================================||===================================== #
#																			   #
#				 				   Validation								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

CheckInstallation()
{
	local ReturnValue=0;
	if [ -n "$1" ]; then CheckBinaries $1 || ReturnValue=$?; fi
	if [ -n "$2" ]; then CheckLibrariesGcc $2 || ReturnValue=$?; rm -f TempLibraryTest.c TempLibraryTest; fi
	if [ -n "$3" ]; then CheckLibrariesPython $3 || ReturnValue=$?; fi
	return $ReturnValue;
}

CheckInstallationVerbose()
{
	local ReturnValue=0;
	if [ -n "$1" ]; then CheckBinariesVerbose $1 || ReturnValue=$?; fi
	if [ -n "$2" ]; then CheckLibrariesGccVerbose $2 || ReturnValue=$?; rm -f TempLibraryTest.c TempLibraryTest; fi
	if [ -n "$3" ]; then CheckLibrariesPythonVerbose $3 || ReturnValue=$?; fi
	echo
	return $ReturnValue;
}

CheckBinaries()
{
	for Binary in $@; do
		if ! CheckBinary $Binary &> /dev/null; then
			return 1;
		fi
	done
}

CheckBinariesVerbose()
{
	local ReturnValue=0;
	for Binary in $@; do
		if ! CheckBinary $Binary &> /dev/null; then
			ReturnValue=1;
			echo -en "${C_RED}$Binary${C_RESET} " >&2
		else
			echo -en "${C_GREEN}$Binary${C_RESET} "
		fi
	done
	return $ReturnValue;
}

DefineCheckBinary()
{
	if which which &> /dev/null; then
		CheckBinary()
		{
			which "$1" &> /dev/null;
			return $?;
		}
	else
		CheckBinary()
		{
			test "$(whereis $1)" != "$1:" &> /dev/null;
			return $?;
		}
	fi
}

CheckLibrariesGcc()
{
	echo 'int main() {return 0;}' > TempLibraryTest.c
	for Library in $@; do
		case $(dirname $Library) in
			.)
				LibName=${Library%.so};
				CFLAG="-l${LibName#lib}";;
			*)	CFLAG=$Library;;
		esac
		if ! gcc TempLibraryTest.c $CFLAG -o TempLibraryTest &> /dev/null; then
			return 1;
		fi
	done
	return 0;
}

CheckLibrariesGccVerbose()
{
	local ReturnValue=0;
	echo "$> $@";
	echo 'int main() {return 0;}' > TempLibraryTest.c
	for Library in $@; do
		echo "$Library[$(dirname $Library)]"
		case $(dirname $Library) in
			.)
				LibName=${Library%.so};
				CFLAG="-l${LibName#lib}";;
			*)	CFLAG=$Library;;
		esac
		if ! gcc TempLibraryTest.c $CFLAG -o TempLibraryTest &> /dev/null; then
			ReturnValue=1;
			echo -en "${C_RED}$Library${C_RESET} " >&2;
		else
			echo -en "${C_GREEN}$Library${C_RESET} ";
		fi
	done
	return $ReturnValue;
}

CheckLibrariesPython()
{
	for Library in $@; do
		if ! python3 -c "import $Library" &> /dev/null; then
			return 1;
		fi
	done
	return 0;
}

CheckLibrariesPythonVerbose()
{
	local ReturnValue=0;
	for Library in $@; do
		if ! python3 -c "import $Library" &> /dev/null; then
			if find /usr -name "$Library*.so" &> /dev/null; then
				echo -en "${C_ORANGE}$Library${C_RESET} " >&2;
				ReturnValue=1;
			else
				echo -e "${C_RED}$Library${C_RESET} " >&2;
				ReturnValue=1;
			fi
		else
			echo -e "${C_GREEN}$Library${C_RESET} ";
		fi
	done
	return $ReturnValue;
}

CheckPips()
{
	for Pip in $@; do
		CheckPip $Pip;
	done
	echo
}

CheckPip()
{
	IFS='[;' read -p $'\e[6n' -d R -rs _ LINE COLUMN _
	if (( COLUMN + ${#1} > $(tput cols) )); then
		echo;
	fi

	if pip3 show $1 &> /dev/null; then
		echo -en	"${C_GREEN}$1${C_RESET} ";
		return 0;
	else
		echo -en	"${C_RED}$1${C_RESET} ";
		return 1
	fi
}
