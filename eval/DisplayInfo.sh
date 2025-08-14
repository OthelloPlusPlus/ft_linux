#! /bin/bash

source /usr/local/shell/colors.sh

# =====================================||===================================== #
#				 			 		  Utils									   #
# ===============ft_linux==============||==============©Othello=============== #

# Set terminal size
Width=$(tput cols);
((Width<120)) && Width=120;
Height=$(tput lines)
((Height<48)) && Height=48;
echo -e "\e[8;${Height};${Width}t"
Width=$(tput cols);

GetKeyPress()
{
	read -rsn 1 input
	if [[ "$input" == $'\e' ]]; then
		read -rsn 2 -t 0.1 input
		input=$'\e'"$input"
	fi
}

# =====================================||===================================== #
#				 			  		 Displays								   #
# ===============ft_linux==============||==============©Othello=============== #

KernelInfo()
{
	echo "> uname"
	# uname -a
	NameLength=$(echo -n "Hardware Platform:" | wc -c)
	FlagLength=3
	#  "Processor -p" "Hardware Platform -i"
	for Set in "Kernel " "Release -r" "Host Name -n" "Architecture -m" "OS -o" "Version -v"; do
		Name="${Set% *}"
		Flag="${Set##* }"
		printf "${C_BOLD}%-${NameLength}s${C_RESET} %-${FlagLength}s %-s\n" "$Name:" "$Flag" "$(uname $Flag)"
	done

	printf '%*s\n' "$Width" '' | tr ' ' '-';

	echo "Network> hostname"
	NameLength=$(echo -n "IP-addresses:" | wc -c)
	FlagLength=3
	# "Domain -d" "IP-addresses -i"
	for Set in "Hostname " "Alias -a" "Full Name -f"; do
		Name="${Set% *}"
		Flag="${Set##* }"
		printf "${C_BOLD}%-${NameLength}s${C_RESET} %-${FlagLength}s %-s\n" "$Name:" "$Flag" "$(hostname $Flag)"
	done

	printf '%*s\n' "$Width" '' | tr ' ' '-';

	local KernelSrcDir="/usr/src/linux-$(uname -r)"
	# mkdir "$KernelSrcDir"
	# wget -r -np -m --wait=0.1 --timeout=8 -nH --cut-dirs=4 -P "$KernelSrcDir" "https://mirror.koddos.net/lfs/lfs-packages/12.2" -A "md5sums,*.tar.xz,*.tar.gz,*.tar.bz2,*.patch" -nv
	NameLength=$(echo -n "Kernel Sources:" | wc -c)
	printf "${C_BOLD}%-${NameLength}s${C_RESET} %-s\n" "Kernel Sources:" "$(ls -d $KernelSrcDir)"
	if ls -d "$KernelSrcDir" &> /dev/null; then
		printf "${C_BOLD}%-${NameLength}s${C_RESET} %-s" " MD5:" "$(ls -d $KernelSrcDir/md5sums)"
		if ls -d $KernelSrcDir/md5sums &> /dev/null; then
			pushd "$KernelSrcDir" > /dev/null;
			if md5sum --quiet -c md5sums; then
				printf " ${C_GREEN}%-s${C_RESET}\n" "OK"
			else
				printf " ${C_RED}%-s${C_RESET}\n" "KO"
			fi
			popd > /dev/null;
		else
			echo
		fi
		printf "${C_BOLD}%-${NameLength}s${C_RESET} %-s\n" " Tarballs:" "$(ls $KernelSrcDir | grep -c '.tar.')"
		printf "${C_BOLD}%-${NameLength}s${C_RESET} %-s\n" " Patches:" "$(ls $KernelSrcDir | grep -c '.patch$')"
	fi
}

PartitionInfo()
{
	echo -e "> df -h\n";
	df -h;

	printf '%*s\n' "$Width" '' | tr ' ' '-';

	echo -e "> lsblk -o ...\n";
	lsblk -o NAME,MAJ:MIN,FSUSED,SIZE,FSUSE%,TYPE,FSTYPE,LABEL,MOUNTPOINTS;

	printf '%*s\n' "$Width" '' | tr ' ' '-';

	echo -e "> findmnt --target / --submounts\n";
	findmnt --target / --submounts;
}

ModuleLoaderInfo()
{
	local NameLength=$(echo "Hardware Manager:" | wc -c)

	printf "${C_BOLD}%-${NameLength}s${C_RESET} %-s\n" "Kernel Modules:" "$(ls -d /lib/modules/$(uname -r)/)"
	printf "${C_BOLD}%-${NameLength}s${C_RESET} %-s\n" "Module Loader:" "$(which modprobe)"
	printf "${C_BOLD}%-${NameLength}s${C_RESET} %-s\n" "Hardware Manager:" "$(which udevd)"

	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo "Module list> find / *.ko"
	find /lib/modules/$(uname -r)/ -name '*.ko' -exec basename {} .ko \; | column

	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo "> modinfo evdev"
	modinfo evdev
}

DeviceManagerInfo()
{
	local NameLength=$(echo "Device Manager:" | wc -c)

	printf "${C_BOLD}%-${NameLength}s${C_RESET} %-s (%-s)\n" "Device Manager:" "$(which udevd)"

	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo "Udev rules> /etc/udev/rules.d/*"
	grep -vE "^(#|$)" --color=always /etc/udev/rules.d/*

	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo "Device nodes> udev-hwdb --version"
	udevadm info --export-db | grep -E 'DEVNAME=' | sed 's/^E: //; s/DEVNAME=//' | xargs -n1 basename | uniq | column
}

BootLoaderInfo()
{
	echo "> ls /boot/vm*";
	ls /boot/vm*

	printf '%*s\n' "$Width" '' | tr ' ' '-';

	echo "> grep -vE \"^(#|$)\" /boot/grub/grub.cfg"
	grep -vE "^(#|$)" /boot/grub/grub.cfg
}

DaemonManagerInfo()
{
	echo "Daemon Manager> ps -p 1 -o comm=";
	local DaemonManager=$(ps -p 1 -o comm=)
	echo -n "$DaemonManager"
	case $DaemonManager in
		systemd) 	echo " (SystemD)";;
		init)	if [ ! -f /sbin/upstart ]; then 
					echo " (SysVinit)";
				else
					echo " (Upstart)";
				fi ;;
		upstart)	echo " (Upstart)";;
		*)			echo;;
	esac

	printf '%*s\n' "$Width" '' | tr ' ' '-';

	echo -e "Active Daemons> ps -eo comm ${C_DGRAY}(Not an exhaustive list)${C_RESET}"
	Running=$(ps -eo comm= | sort | uniq | grep -vE "(^kworker|^rcu_)")
	InitList=$(ls /etc/init.d/ | grep -vE "(^rc$)")
	InitList+=" gnome"
	for InitScript in $InitList; do
		echo "$Running" | grep "$InitScript"
	done
}

InternetInfo()
{
	local NameLength=$(echo -n "DNS Servers:" | wc -c)

	printf "${C_BOLD}%-${NameLength}s${C_RESET} %-s\n" "MAC:" 			"$(ip link | awk '/link\/ether/ {print $2}')"
	printf "${C_BOLD}%-${NameLength}s${C_RESET} %-s\n" "IP4 global:" 	"$(ip -4 addr show scope global | awk '/inet/ {print $2}')"
	printf "${C_BOLD}%-${NameLength}s${C_RESET} %-s\n" "    public:" 	"$(curl -s https://api.ipify.org)"
	# printf "${C_BOLD}%-${NameLength}s${C_RESET} %-s\n" "IP6 global:" 	"$(ip -6 addr show scope global | awk '/inet6/ {print $2}')"
	# printf "${C_BOLD}%-${NameLength}s${C_RESET} %-s\n" "    public:" 	"$(curl -s https://api6.ipify.org)"
	printf "${C_BOLD}%-${NameLength}s${C_RESET} %-s\n" "Route:" 		"$(ip route show default | awk '{print $3}')"
	printf "${C_BOLD}%-${NameLength}s${C_RESET} %-s\n" "DNS Servers:" 	"/etc/resolv.conf"
	local TempSpaces=$(printf '%*s ' "${NameLength}" '')
	printf "${C_BOLD}%-${NameLength}s${C_RESET} %-s\n" "" 				"$(grep '^nameserver' /etc/resolv.conf | awk -v sep="\n$TempSpaces" 'NR==1 {printf "%s", $2; next} {printf "%s%s", sep, $2} END {print ""}')"

	printf '%*s\n' "$Width" '' | tr ' ' '-';

	echo -e "> ping"
	ping -c 3 -i 0.1 -q 8.8.8.8

	printf '%*s\n' "$Width" '' | tr ' ' '-';

	echo -e "> wget"
	wget --spider -nv https://www.google.com

	printf '%*s\n' "$Width" '' | tr ' ' '-';

	echo -e "> curl"
	echo -n "HTTP status code: " 
	local ReturnCode=$(curl -s -o /dev/null -w "%{http_code}" https://www.google.com)
	if [ "$ReturnCode" -ge 100 ] && [ "$ReturnCode" -le 399 ]; then
		echo -e "${C_GREEN}$ReturnCode${C_RESET}"
	elif  [ "$ReturnCode" -ge 400 ] && [ "$ReturnCode" -le 599 ]; then
		echo -e "${C_YELLOW}$ReturnCode${C_RESET}"
	else
		echo -e "${C_RED}$ReturnCode${C_RESET}"
	fi
}

MiscellaneousInfo()
{
	echo -e "Active Users> loginctl"
	loginctl

	# CFLAGS="-Wno-implicit-function-declaration -Wno-implicit-int" ./configure --with-socket-dir=/tmp
}

InfoDisplays=(KernelInfo PartitionInfo ModuleLoaderInfo DeviceManagerInfo BootLoaderInfo DaemonManagerInfo InternetInfo MiscellaneousInfo)

# =====================================||===================================== #
#				 			  		 Execution								   #
# ===============ft_linux==============||==============©Othello=============== #

index=0
while true; do
	clear;
	Width=$(tput cols);

	printf '%*s\n' "$Width" '' | tr ' ' '-';
	PrevName="${InfoDisplays[$(( (index - 1 + ${#InfoDisplays[@]}) % ${#InfoDisplays[@]} ))]}"
	CrntName="${InfoDisplays[$index]}"
	NextName="${InfoDisplays[$(( (index + 1) % ${#InfoDisplays[@]} ))]}"
	MiddleWidth=${#CrntName}
	LeftWidth=$(( ( Width - MiddleWidth ) / 2 - 1 ))
	RightWidth=$(( Width - LeftWidth - MiddleWidth - 1 ))
	printf "%-*s"	"$LeftWidth" "< $PrevName"
	printf "${C_BOLD}${C_ORANGE}%s${C_RESET}"	"$CrntName"
	printf "%*s\n"	"$RightWidth" "$NextName >"
	printf '%*s\n' "$Width" '' | tr ' ' '-';

	${InfoDisplays[$index]};

	printf '%*s\n' "$Width" '' | tr ' ' '-';

	GetKeyPress;
	case $input in 
		$'\e[D')
			# < Arrow
			index=$(( (index - 1 + ${#InfoDisplays[@]}) % ${#InfoDisplays[@]} ));;
		 $'\e[C')
			# > Arrow
		 	index=$(( (index + 1) % ${#InfoDisplays[@]} ));;
		e|E|q|Q) break;;
	esac
done
