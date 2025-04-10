#! /bin/zsh

source Utils.sh

# =====================================||===================================== #
#																			   #
#									Functions								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #


# =====================================||===================================== #
#																			   #
#									Execution								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

if [ $# -gt 0 ]; then
	case "$1" in
		RunAll)	;;
		*)		echo "Bad flag: '$1'";;
	esac
	exit;
fi

while true; do
	Width=$(tput cols);
	clear;

	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"${C_ORANGE}${C_BOLD}Packages${C_RESET}";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	$LocalCommand;
	unset LocalCommand;
	echo -n	"Input> ";

	GetKeyPress;
	case $input in
		q)	exit;;
	esac
done
