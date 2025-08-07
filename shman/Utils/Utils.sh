#! /bin/bash

if [ -z "${SHMAN_UDIR}" ]; then 
	echo "Util directory not configured" >&2;
	exit 1;
elif [ ! -d "${SHMAN_UDIR}" ]; then
	echo "'${SHMAN_UDIR}' is not a directory" >&2;
	exit 1;
fi

CLEARING=true;
SHELLTYPE="$(basename $(readlink -f /proc/$$/exe))"

source "/usr/local/shell/colors.sh"
for UtilName in Echo UserInput Validation Packages; do
	source "${SHMAN_UDIR}/Utils${UtilName}.sh"
done
