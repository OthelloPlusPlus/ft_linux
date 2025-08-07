#! /bin/bash


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

RemoveAllPackages()
{
	find "${SHMAN_PDIR}" -maxdepth 1 -type f -name '*.tar.*' | while read -r Tarball; do
		ExtractedDirectory="$(tar -tf "$Tarball" | head -1 | cut -f1 -d"/")";
		[ "${SHMAN_PDIR}${ExtractedDirectory}" != "${SHMAN_PDIR}" ] && [ -d "${SHMAN_PDIR}${ExtractedDirectory}" ] && rm -r "${SHMAN_PDIR}${ExtractedDirectory}";
	done
}

RemoveAllDownloads()
{
	rm ${SHMAN_PDIR}*.patch*;
	rm ${SHMAN_PDIR}*.tar.*;
}