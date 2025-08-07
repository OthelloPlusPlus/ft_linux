#!/bin/bash

if [ ! -z "${PackageLibPwquality[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibPwquality								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibPwquality;
# Manual
PackageLibPwquality[Source]="https://github.com/libpwquality/libpwquality/releases/download/libpwquality-1.4.5/libpwquality-1.4.5.tar.bz2";
PackageLibPwquality[MD5]="6b70e355269aef0b9ddb2b9d17936f21";
# Automated unless edgecase
PackageLibPwquality[Name]="";
PackageLibPwquality[Version]="";
PackageLibPwquality[Extension]="";
if [[ -n "${PackageLibPwquality[Source]}" ]]; then
	filename="${PackageLibPwquality[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibPwquality[Name]}" ]] && PackageLibPwquality[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibPwquality[Version]}" ]] && PackageLibPwquality[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibPwquality[Extension]}" ]] && PackageLibPwquality[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibPwquality[Package]="${PackageLibPwquality[Name]}-${PackageLibPwquality[Version]}";

PackageLibPwquality[Programs]="pwscore pwmake";
PackageLibPwquality[Libraries]="pam_pwquality.so libpwquality.so";
PackageLibPwquality[Python]="";

InstallLibPwquality()
{
	# Check Installation
	CheckLibPwquality && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibPwquality[Name]}> Checking dependencies..."
	Required=(CrackLib)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageLibPwquality[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(LinuxPAM)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageLibPwquality[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageLibPwquality[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibPwquality[Name]}> Building package..."
	_ExtractPackageLibPwquality || return $?;
	_BuildLibPwquality || return $?;
	_ConfigureLibPwquality || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageLibPwquality[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckLibPwquality()
{
	CheckInstallation 	"${PackageLibPwquality[Programs]}"\
						"${PackageLibPwquality[Libraries]}"\
						"${PackageLibPwquality[Python]}" 1> /dev/null;
	return $?;
}

CheckLibPwqualityVerbose()
{
	CheckInstallationVerbose	"${PackageLibPwquality[Programs]}"\
								"${PackageLibPwquality[Libraries]}"\
								"${PackageLibPwquality[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibPwquality()
{
	DownloadPackage	"${PackageLibPwquality[Source]}"	"${SHMAN_PDIR}"	"${PackageLibPwquality[Package]}${PackageLibPwquality[Extension]}"	"${PackageLibPwquality[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibPwquality[Package]}"	"${PackageLibPwquality[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLibPwquality()
{
	if ! cd "${SHMAN_PDIR}${PackageLibPwquality[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibPwquality[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibPwquality[Package]}/build \
	# 				|| { EchoError "${PackageLibPwquality[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibPwquality[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibPwquality[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--with-securedir=/usr/lib/security \
				--disable-python-bindings \
				1> /dev/null || { EchoTest KO ${PackageLibPwquality[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibPwquality[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageLibPwquality[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibPwquality[Name]}> pip3 wheel"
	pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD/python

	EchoInfo	"${PackageLibPwquality[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageLibPwquality[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibPwquality[Name]}> pip3 pip3 install"
	pip3 install --no-index --find-links dist --no-user pwquality
}

_ConfigureLibPwquality()
{
	EchoInfo	"${PackageLibPwquality[Name]}> mv /etc/pam.d/system-password{,.orig}"
	mv /etc/pam.d/system-password{,.orig}

	EchoInfo	"${PackageLibPwquality[Name]}> /etc/pam.d/system-password"
	cat > /etc/pam.d/system-password << "EOF"
# Begin /etc/pam.d/system-password

# check new passwords for strength (man pam_pwquality)
password  required    pam_pwquality.so   authtok_type=UNIX retry=1 difok=1 \
                                         minlen=8 dcredit=0 ucredit=0 \
                                         lcredit=0 ocredit=0 minclass=1 \
                                         maxrepeat=0 maxsequence=0 \
                                         maxclassrepeat=0 gecoscheck=0 \
                                         dictcheck=1 usercheck=1 \
                                         enforcing=1 badwords="" \
                                         dictpath=/usr/lib/cracklib/pw_dict

# use yescrypt hash for encryption, use shadow, and try to use any
# previously defined authentication token (chosen password) set by any
# prior module.
password  required    pam_unix.so        yescrypt shadow try_first_pass

# End /etc/pam.d/system-password
EOF
}