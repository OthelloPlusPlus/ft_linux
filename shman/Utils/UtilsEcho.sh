#! /bin/bash

case "$SHELLTYPE" in
	bash)	ECHOFLAG='-e';;
esac

EchoInfo()
{
	# echo ${ECHOFLAG}	"[${C_CYAN}INFO${C_RESET}]$1";
	printf	"[${C_CYAN}INFO${C_RESET}] %s\n" "$1";
}

EchoWarning()
{
	# echo ${ECHOFLAG}	"[${C_CYAN}INFO${C_RESET}]$1";
	printf	"[${C_YELLOW}WARN${C_RESET}] %s\n" "$1";
}

EchoError()
{
	# echo ${ECHOFLAG}	"[${C_RED}ERR${C_RESET} ]  $1"	>&2;
	printf	"[${C_RED}ERR${C_RESET} ] %s\n" "$1"	>&2;
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
