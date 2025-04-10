#! /bin/zsh

source Utils.sh

export LFS=/lfs
UserName=ArchUser;

Validate()
{
	lsblk -o NAME,MAJ:MIN,FSUSED,SIZE,FSUSE%,TYPE,FSTYPE,LABEL,MOUNTPOINTS;
}

InstallCrossToolchainAsUser()
{
	echo
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	cp Utils.sh colors.sh Install5CrossToolchain.sh /home/${UserName};

	echo	"To continue enter the following command:";

	printf	"${CB_BLACK}%-42s${C_RESET}\n"	" > zsh ./Install5CrossToolchain.sh";

	su - ${UserName}
}

while true; do
	Width=$(tput cols);

	clear;
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"${C_ORANGE}${C_BOLD}Arch linux setup for LFS${C_RESET}";
	echo	"Option:\t${-}";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	printf	"0)\t Install All\n";
	printf	"3)\t Download Packages and Patches\n";
	printf	"4)\t Final Preparations\n";
	printf	"5)\t Compiling a Cross-Toolchain\n";
	printf	"6)\t Cross Compiling Temporary Tools\n";
	printf	"7)\t Entering Chroot and Building Additional Temporary Tools\n";
	printf	"8)\t Installing Basic System Software\n";
	printf	"9)\t System Configuration\n";
	printf	"B)\t Making the LFS System Bootable\n";
	printf	"v)\t Validate LFS\n";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	$ExecuteCommand;
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	printf	"Input> ";

	GetKeyPress;
	case $input in
		0)	./Install3Packages.sh "RunAll" || PressAnyKeyToContinue;;
		3)	./Install3Packages.sh || PressAnyKeyToContinue;;
		4)	./Install4Preparations.sh || PressAnyKeyToContinue;;
		5)	InstallCrossToolchainAsUser;;
		v)	local ExecuteCommand="Validate";;
		q)	exit;;
		*)	local ExecuteCommand=$input;;
	esac
done
# ;
# ;
# printf	"hello"