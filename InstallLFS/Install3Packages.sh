#! /bin/zsh

source Utils.sh

MirrorSite=mirror.koddos.net
MirrorURL=https://${MirrorSite}/lfs/lfs-packages/12.2/
DEST="$LFS/sources/lfs-packages12.2/"

# =====================================||===================================== #
#																			   #
#									Functions								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

DownloadPackages()
{
	mkdir -p -m 777 "$LFS/sources";
	command -v wget >/dev/null 2>&1 || pacman -Sy wget

	wget -r -np -m --wait=0.1 --timeout=8 -nH --cut-dirs=4 -P "$DEST" "$MirrorURL" \
		-A "md5sums,*.tar.xz,*.tar.gz,*.tar.bz2,*.patch" -nv;
}

RemoveSubDirectories()
{
	while read -r checksum filename; do
	    dirname=$(echo "$filename" | sed -E 's/\.(tar\.(gz|xz|bz2)|patch)$//')
		if [ -d $DEST/$dirname ]; then
			rm -r $DEST/$dirname;
		fi
	done < $DEST/md5sums
}

DisplayPackages()
{
	if [ ! -e "$DEST/md5sums" ]; then
		ls "$DEST"
	else
		local CONTENT=();
		local PREV=0;
		for FILE in $(awk '{print $2}' $DEST/md5sums); do
			if [ -f $DEST/$FILE ] && [ $PREV -ne 2 ]; then
				PREV=2;
				CONTENT+="$(tput setaf 2)$FILE";
			elif [ ! -e $DEST/$FILE ] && [ $PREV -ne 1 ]; then
				PREV=1;
				CONTENT+="$(tput setaf 1)$FILE";
			else
				CONTENT+="$FILE";
			fi
		done
		printf "%s\n" "${CONTENT[@]}" | column -x
		echo -n "$C_RESET";
	fi
	printf '%*s\n' "$Width" '' | tr ' ' '-';

}

DisplayPackageCount()
{
	local GROUP="$1";
	local TABSIZE=13;

	if [ -e "${DEST}/md5sums" ]; then
		local FOUND=$(grep "$GROUP" <<< "$MD5" | grep "OK" | wc -l);
		local TOTAL=$(grep "$GROUP" <<< "$MD5" | wc -l);
		if [ "$FOUND" -eq "$TOTAL" ]; then
			FOUND="${C_GREEN}$FOUND${C_RESET}"
		else
			FOUND="${C_RED}$FOUND${C_RESET}"
		fi
	else
		local FOUND=$(ls "${DEST}" | grep "${GROUP}" | wc -l);
		local TOTAL="${C_ORANGE}N/A${C_RESET}";
	fi
	printf	"%-${TABSIZE}s$FOUND/$TOTAL\n"	"*$GROUP:";
}

# =====================================||===================================== #
#																			   #
#									Execution								   #
#																			   #
# ===============ft_linux==============||==============©Othello=============== #

if [ $# -gt 0 ]; then
	case "$1" in
		RunAll)	DownloadPackages;
				RemoveSubDirectories;;
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
	echo -n	"Mirror:      "; ping -c 1 $MirrorSite 1> /dev/null && echo -n "${C_GREEN}" || echo -n "${C_RED}" && echo "$MirrorURL${C_RESET}";
	echo -n	"Directory:   "; [ -d $DEST ] 1> /dev/null && echo -n "${C_GREEN}" || echo -n "${C_RED}" && echo "$DEST${C_RESET}";
	
	if [ -d $DEST ]; then
		printf	"%-13s"	"md5sums:"
		if [ ! -f "$DEST/md5sums" ]; then
			echo "${C_ORANGE}N/A${C_RESET}"
		else
			cd "$DEST";
			MD5=$(md5sum -c "md5sums" 2> /dev/null);
			if [[ $(md5sum -c "md5sums" --quiet 2> /dev/null | wc -l) -eq 0 ]]; then
				echo "${C_GREEN}OK${C_RESET}"
			else
				echo "${C_RED}KO${C_RESET}"
			fi
			cd -;
		fi

		DisplayPackageCount	".tar.xz";
		DisplayPackageCount	".tar.gz";
		DisplayPackageCount	".tar.bz2";
		DisplayPackageCount	".patch";
	fi

	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"0)\tDownload Packages";
	printf	"1)\tRemove Directories (%s)\n" "$(find $DEST -mindepth 1 -type d | wc -l)";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	echo	"d)\tDisplay Packages";
	echo	"q)\tReturn to main menu";
	printf '%*s\n' "$Width" '' | tr ' ' '-';
	$LocalCommand;
	unset LocalCommand;
	echo -n	"Input> ";

	GetKeyPress;
	case $input in
		0)	DownloadPackages;;
		1)	RemoveSubDirectories;;
		d)	local LocalCommand=DisplayPackages;;
		q)	exit;;
	esac
done
