#!/bin/bash

# Check if parameter is passed
if [ -z "$1" ]; then
  echo "Usage: $0 NewName"
  exit 1
fi

# Setting Colors
C_RESET="\x1b[0m"
C_RED="\x1b[1;31m"
C_GREEN="\x1b[1;32m"

# Setting Variables
ShmanDir="$(readlink -f "${BASH_SOURCE[0]}")"
while [[ "$ShmanDir" != "/" ]]; do
	if [[ "$(basename "$ShmanDir")" == "shman" ]]; then break; fi
	ShmanDir="$(dirname "$ShmanDir")"
done
if [[ "$(basename "$ShmanDir")" != "shman" ]]; then
	echo -e "Invalid shman dir: ${C_RED}$ShmanDir${C_RESET}"; >&2
	exit 1;
fi
TemplateFile="${ShmanDir}/Utils/_Template.sh"
NewName="$1"
DestFile="${ShmanDir}/PackageScripts/${NewName}.sh"

# Check if target file already exists
if [ -e "$DestFile" ]; then
  echo -e "Error: ${C_RED}${DestFile}${C_RESET} already exists." >&2
  exit 1
fi

# Check if template file exists
if [ ! -e "$TemplateFile" ]; then
  echo -e "Error: Template file ${C_RED}${TemplateFile}${C_RESET} not found." >&2
  exit 1
fi

# Copy and rename the file
cp "$TemplateFile" "$DestFile"

# Replace all occurrences of 'Template' with the new name
sed -i "s/Template/${NewName}/g" "$DestFile"

echo -e "Created ${C_GREEN}$NewName.sh${C_RESET}"
