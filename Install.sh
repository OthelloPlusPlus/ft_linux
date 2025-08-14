#! /bin/bash

# =====================================||===================================== #
#																			   #
#									Functions								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

GetKeyPress()
{
    read -rsn 1 input
	if [[ "$input" == $'\e' ]]; then
		read -rsn 2 -t 0.1 input
		input=$'\e'"$input"
	fi
}

ClearKeygen()
{
	ssh-keygen -f "/home/ohengelm/.ssh/known_hosts" -R "[$ADDRESS]:$PORT";
}

CopyFile()
{
	SRC="$1"
	DEST="$2"

	scp -P $PORT $SRC $USER@$ADDRESS:$DEST
	if [ $? -eq 1 ]; then
		ClearKeygen;
		# ssh-keygen -f "/home/ohengelm/.ssh/known_hosts" -R "[127.0.0.1]:2222";
		scp -P $PORT $SRC $USER@$ADDRESS:$DEST
	fi
}

RunCmd()
{
	Command="$1";
	# Dest="$2"
	ssh -p $PORT $USER@$ADDRESS -t "$Command"
}

CopyForArchLinux()
{
	CopyFile 	"Utils/*.sh InstallArchLinux/*.sh" \
				"/root";
}

CopyForLFS()
{
	CopyFile 	"Utils/*.sh InstallLFS/*.sh eval/*.sh" \
				"/root";
}

CopyBLFS()
{
	scp -P $PORT ./ConfigureBLFS/*.sh ./Utils/*.sh $USER@$ADDRESS:/root;
}

CopyShman()
{
	cp ./Utils/Utils.sh ./shman/Utils.sh;
	chmod +x ./shman/shman.sh
	scp -P $PORT -r ./shman $USER@$ADDRESS:/usr/src/;
	rm ./shman/Utils.sh;
}

CopyEval()
{
	scp -P $PORT ./eval/*.sh $USER@$ADDRESS:/eval
}

PORT=2222
USER=root
ADDRESS=127.0.0.1
PASSWD=xxxx

ClearKeygen;

while true; do
	Width=$(tput cols);
	clear;

	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"Install LFS through SSH";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	MachineName="ft_linux"
	printf "%-9s %s\n"	"Machine:"	"$MachineName"
	printf "%-9s %s\n"	"Image:"	"$(VBoxManage showvminfo "$MachineName" | grep ".vdi" | awk -F'"' '{print $2}' | sed -E 's#/Snapshots/.*\.vdi#.vdi#')"
	printf "%-9s %s\n"	"Checksum:"	"$(cat ft_linux_checksum)"
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	printf	"a)\t Install ArchLinux\n"
	printf	"l)\t Install Linux From Scratch\n"
	printf	"b)\t Configure Beyond Linux From Scratch\n"
	printf	"s)\t shman - Shell package Manager\n"
	printf	"e)\t Evaluation scripts\n"
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	printf	"0)\t Enter as Root\n"
	printf	"1)\t Enter as arch-chroot (ArchLinux Install)\n"
	printf	"2)\t Enter as ArchUser\n"
	printf	"3)\t Enter as Chroot\n"
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	printf	"q)\t exit\n"
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"lowercase to copy files, UPPERCASE to copy and run files"
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	if [ ! -z "$ErrorMsg" ]; then
		printf	"$ErrorMsg\n"
		printf '%*s\n' "$Width" '' | tr ' ' '-';
	fi
	printf	"Input: ";

	GetKeyPress;
	case "$input" in
		a)	CopyForArchLinux;;
		A)	CopyForArchLinux;
			RunCmd	"./InstallArchLinuxRoot.sh";;
		l)	CopyForLFS;;
		L)	CopyForLFS;
			RunCmd	"chmod +x Install*.sh; ./Install.sh";;
		b|B)	CopyBLFS;;&
			B)	ssh -p $PORT $USER@$ADDRESS -t "bash --login /root/ConfigureBLFS.sh" || ErrorMsg="$? Failed to enter as Root";;
		s|S)	CopyShman;;&
			S)	ssh -p $PORT $USER@$ADDRESS -t "bash --login /usr/src/shman/shman.sh" || ErrorMsg="$? Failed to enter as Root";;
		e|E)	CopyEval;;&
			E)	ssh -p $PORT $USER@$ADDRESS -t "cd /eval && bash --login" || ErrorMsg="$? Failed to enter as Root";;
		0)	ssh -p $PORT $USER@$ADDRESS -t "bash --login" || ErrorMsg="$? Failed to enter as Root";;
		1)	ssh -p $PORT $USER@$ADDRESS -t "arch-chroot - ArchUser" || ErrorMsg="$? Failed to arch-chroot";;
		2)	ssh -p $PORT $USER@$ADDRESS -t "su - ArchUser" || ErrorMsg="$? Failed to enter as ArchUser";;
		3)	ssh -p $PORT $USER@$ADDRESS -t "chroot	\"/lfs\" /usr/bin/env -i	\
															HOME=/root	\
															TERM=\"$TERM\"	\
															PS1='(lfs chroot) \u:\w\$ '	\
															PATH=/usr/bin:/usr/sbin	\
															MAKEFLAGS=\"-j$(nproc)\"	\
															TESTSUITEFLAGS=\"-j$(nproc)\"	\
															/bin/bash --login" 	|| ErrorMsg="$? Failed to enter as Chroot";;
		q)	exit;;
	esac
done
