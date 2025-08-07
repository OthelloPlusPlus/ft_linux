#! /bin/bash

CheckInstallation()
{
	local ReturnValue=0;
	if [ -n "$1" ]; then CheckBinaries $1 || ReturnValue=$?; fi
	if [ -n "$2" ]; then CheckLibrariesGcc $2 || ReturnValue=$?; rm -f /tmp/TempLibraryTest.c /tmp/TempLibraryTest; fi
	if [ -n "$3" ]; then CheckLibrariesPython $3 || ReturnValue=$?; fi
	return $ReturnValue;
}

CheckInstallationVerbose()
{
	local ReturnValue=0;
	if [ -n "$1" ]; then CheckBinariesVerbose $1 || ReturnValue=$?; fi
	if [ -n "$2" ]; then CheckLibrariesGccVerbose $2 || ReturnValue=$?; rm -f /tmp/TempLibraryTest.c /tmp/TempLibraryTest; fi
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
	echo 'int main() {return 0;}' > /tmp/TempLibraryTest.c
	for Library in $@; do
		case $(dirname $Library) in
			.)	
				LibName=${Library%.so};
				CFLAG="-l${LibName#lib}";;
			*)	CFLAG=$Library;;
		esac
		if ! gcc /tmp/TempLibraryTest.c $CFLAG -o /tmp/TempLibraryTest &> /dev/null; then
			return 1;
		fi
	done
	return 0;
}

CheckLibrariesGccVerbose()
{
	local ReturnValue=0;
	echo "$> $@";
	echo 'int main() {return 0;}' > /tmp/TempLibraryTest.c
	for Library in $@; do
		echo "$Library[$(dirname $Library)]"
		case $(dirname $Library) in
			.)	
				LibName=${Library%.so};
				CFLAG="-l${LibName#lib}";;
			*)	CFLAG=$Library;;
		esac
		if ! gcc /tmp/TempLibraryTest.c $CFLAG -o /tmp/TempLibraryTest &> /dev/null; then
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
