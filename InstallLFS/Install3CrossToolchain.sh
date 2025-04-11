#! /bin/zsh

source Utils.sh
source UtilInstallPackages.sh

# =====================================||===================================== #
#																			   #
#									Functions								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

Install5CrossToolchain()
{
	InstallBinutils_CT1;
	InstallGCC_CT1;
	InstallLinuxAPI_CT;
	InstallGlibc_CT;
	if SanityCheckGlibc; then
		InstallLibstdCPP_CT;
	fi
}


ValidateCrossToolchain()
{
	# Binutils
	if command -v $LFS_TGT-as &> /dev/null && command -v $LFS_TGT-ld &> /dev/null; then
		printf	"%-11s ${C_GREEN}OK${C_RESET}\n" "Binutils:"
	else
		printf	"%-11s ${C_RED}KO${C_RESET}\n" "Binutils:"
	fi

	# GCC
	if command -v $LFS_TGT-gcc &> /dev/null; then
		printf	"%-11s ${C_GREEN}OK${C_RESET}\n" "GCC:"
	else
		printf	"%-11s ${C_RED}KO${C_RESET}\n" "GCC:"
	fi

	# LinuxAPI
	TempStatus=true;
	local INCLUDE_DIR="$LFS/usr/include";
	if [ ! -d "$INCLUDE_DIR" ]; then
		TempStatus=false;
	fi

	declare -A HeaderDirectoryList;
	HeaderDirectoryList[asm]=65;
	HeaderDirectoryList[asm-generic]=37;
	HeaderDirectoryList[drm]=28;
	HeaderDirectoryList[linux]=781;
	HeaderDirectoryList[misc]=7;
	HeaderDirectoryList[mtd]=5;
	HeaderDirectoryList[rdma]=29;
	HeaderDirectoryList[regulator]=1;
	HeaderDirectoryList[scsi]=10;
	HeaderDirectoryList[sound]=23;
	HeaderDirectoryList[video]=3;
	HeaderDirectoryList[xen]=4;

	for DIRECTORY in ${(k)HeaderDirectoryList}; do
		if [ ! -d "$INCLUDE_DIR/$DIRECTORY" ]; then
			MSG="${C_RED}Error${C_RESET}(${C_ORANGE}Linux API Header${C_RESET}): Missing directory ${C_ORANGE}$INCLUDE_DIR/$DIRECTORY${C_RESET}"
			TempStatus=false;
		elif [ ${HeaderDirectoryList[$DIRECTORY]} -gt $(find $INCLUDE_DIR/$DIRECTORY -type f -name '*.h' | wc -l) ]; then
			MSG="${C_RED}Error${C_RESET}(${C_ORANGE}Linux API Header${C_RESET}): Missing headers in directory ${C_ORANGE}$INCLUDE_DIR/$DIRECTORY${C_RESET}"
			TempStatus=false;
		fi
	done
	if [ "${TempStatus}" = "true" ]; then
		printf	"%-11s ${C_GREEN}OK${C_RESET}\n" "Linux API:";
	else
		printf	"%-11s ${C_RED}KO${C_RESET}\n" "Linux API:";
	fi

	# Glibc
	echo 'int main(){}' | $LFS_TGT-gcc -xc - -o gcctest.out
	if [ -f "gcctest.out" ]; then
		readelf -l gcctest.out | grep ld-linux 1> /dev/null
		if [ $? -eq 0 ]; then
			printf	"%-11s ${C_GREEN}OK${C_RESET}\n" "Glibc:"
		else
			printf	"%-11s ${C_RED}KO${C_RESET}\n" "Glibc:"
		fi
		rm gcctest.out
	else
		printf	"%-11s ${C_RED}KO${C_RESET}\n" "Glibc:"
	fi

	# LibstdC++
	if command -v $LFS_TGT-g++ &> /dev/null; then
		printf	"%-11s ${C_GREEN}OK${C_RESET}\n" "LibstdC++:"
	else
		printf	"%-11s ${C_RED}KO${C_RESET}\n" "LibstdC++:"
	fi

	printf '%*s\n' "$Width" '' | tr ' ' '-';
}

Install6CrossTemporaryTools()
{
	InstallM4_TT;
	InstallNcurses_TT;
	InstallBash_TT;
	InstallCoreutils_TT;
	InstallDiffutils_TT;
	InstallFile_TT;
	InstallFindutils_TT;
	InstallGawk_TT;
	InstallGrep_TT;
	InstallGzip_TT;
	InstallMake_TT;
	InstallPatch_TT;
	InstallSed_TT;
	InstallTar_TT;
	InstallXz_TT;
	InstallBinutils_TT2;
	InstallGCC_TT2;
}

ValidateTemporaryTools()
{
	printf	"WIP\n";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
}

# =====================================||===================================== #
#																			   #
#									Execution								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

if [ $# -gt 0 ]; then
	case "$1" in
		RunAll)	Install5CrossToolchain;
				Install6CrossTemporaryTools;
				PrepareChrootForTemporaryTools;;
		*)		echo "Bad flag: '$1'";;
	esac
	exit;
fi

while true; do
	Width=$(tput cols);
	clear;

	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"${C_ORANGE}${C_BOLD}5. Compiling a Cross-Toolchain${C_RESET}";
	echo	"Option:\t${-}";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"0)\t Compile Cross-Toolchain and Temporary Tools";
	echo	"5)\t Compile Cross-Toolchain packages";
	echo	"6)\t Cross-Compile Temporary Tool packages";
	# echo	"7)\t Prepare Chroot";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"c)\t Display Cross Toolchain";
	echo	"t)\t Display Temporary Tools";
	echo	"r)\t Remove Directories";
	echo	"q)\t Return to main menu";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	$LocalCommand;
	unset LocalCommand;
	echo -n	"Input> ";

	GetKeyPress;
	case $input in
		0)	Install5CrossToolchain;
			Install6CrossTemporaryTools;
			PrepareChrootForTemporaryTools;;
		5)	Install5CrossToolchain;;
		6)	Install6CrossTemporaryTools;;
		# 7)	PrepareChrootForTemporaryTools;;
		c)	local LocalCommand="ValidateCrossToolchain";;
		t)	local LocalCommand="ValidateTemporaryTools";;
		r)	RemovePackageDirectories;;
		q)	exit;;
	esac
done
