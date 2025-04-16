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
	cp Utils.sh colors.sh UtilInstallPackages.sh /home/${UserName};
	mv Install3CrossToolchain.sh /home/${UserName}

	echo	"To continue enter the following command:";
	printf	"${CB_BLACK}%-42s${C_RESET}\n"	" > zsh ./Install3CrossToolchain.sh";

	su - ${UserName}
}

BuildLFSSystemAsUser()
{
	echo
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	cp Utils.sh colors.sh UtilInstallPackages.sh $LFS/;
	mv Install4BuildLFS.sh $LFS/

	echo	"To continue enter the following command:";
	printf	"${CB_BLACK}%-42s${C_RESET}\n"	" > bash ./Install4BuildLFS.sh";

	chroot	"$LFS" /usr/bin/env -i	\
			HOME=/root	\
			TERM="$TERM"	\
			PS1='(lfs chroot) \u:\w\$ '	\
			PATH=/usr/bin:/usr/sbin	\
			MAKEFLAGS="-j$(nproc)"	\
			TESTSUITEFLAGS="-j$(nproc)"	\
			/bin/bash --login
}

while true; do
	Width=$(tput cols);

	clear;
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"${C_ORANGE}${C_BOLD}Arch linux setup for LFS${C_RESET}";
	echo	"Option:\t${-}";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"0)\t Install All";
	echo	"2)\t Prepare the Host System";
	echo	"3)\t Building Cross-Toolchain and Temporary Tools";
	echo	" p)\t  3.2 Prepare chroot and build more Temporary Tools";
	echo	"4)\t Building LFS";
	# echo	"3)\t Download Packages and Patches";
	# echo	"4)\t Final Preparations";
	# echo	"5)\t Compiling a Cross-Toolchain";
	# echo	"6)\t Cross Compiling Temporary Tools";
	# echo	"7)\t Entering Chroot and Building Additional Temporary Tools";
	# echo	"8)\t Installing Basic System Software";
	# echo	"9)\t System Configuration";
	# echo	"B)\t Making the LFS System Bootable";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"v)\t Validate LFS";
	echo -e	"q)\t Quit";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	$ExecuteCommand;
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	printf	"Input> ";

	GetKeyPress;
	case $input in
		0)	./Install2HostSystem.sh "RunAll" || PressAnyKeyToContinue;
			./InstallCrossToolchainAsUser.sh "RunAll" || PressAnyKeyToContinue;;
		2)	./Install2HostSystem.sh || PressAnyKeyToContinue;;
		3)	InstallCrossToolchainAsUser || PressAnyKeyToContinue;;
		p)	./Install3_2PrepareChroot.sh || PressAnyKeyToContinue;;
		4)	BuildLFSSystemAsUser || PressAnyKeyToContinue;;
		# 3)	./Install3Packages.sh || PressAnyKeyToContinue;;
		# 4)	./Install4Preparations.sh || PressAnyKeyToContinue;;
		# 5)	InstallCrossToolchainAsUser;;
		v)	local ExecuteCommand="Validate";;
		q)	exit;;
		*)	local ExecuteCommand=$input;;
	esac
done
# ;
# ;
# printf	"hello"