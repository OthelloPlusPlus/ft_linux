#!/bin/bash

if [ ! -z "${PackageBlocaled[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Blocaled								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageBlocaled;
# Manual
PackageBlocaled[Source]="https://github.com/lfs-book/blocaled/releases/download/v0.7/blocaled-0.7.tar.xz";
PackageBlocaled[MD5]="cb3edd8c96539fb1042b68cb63e45e12";
# Automated unless edgecase
PackageBlocaled[Name]="";
PackageBlocaled[Version]="";
PackageBlocaled[Extension]="";
if [[ -n "${PackageBlocaled[Source]}" ]]; then
	filename="${PackageBlocaled[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageBlocaled[Name]}" ]] && PackageBlocaled[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageBlocaled[Version]}" ]] && PackageBlocaled[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageBlocaled[Extension]}" ]] && PackageBlocaled[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageBlocaled[Package]="${PackageBlocaled[Name]}-${PackageBlocaled[Version]}";

PackageBlocaled[Programs]="blocaled";
PackageBlocaled[Libraries]="";
PackageBlocaled[Python]="";

InstallBlocaled()
{
	# Check Installation
	CheckBlocaled && return $?;

	# Check Dependencies
	EchoInfo	"${PackageBlocaled[Name]}> Checking dependencies..."
	Required=(Polkit LibDaemon)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageBlocaled[Name]}> Building package..."
	_ExtractPackageBlocaled || return $?;
	_BuildBlocaled || return $?;
	_ConfigureBlocaled;
	return $?
}

CheckBlocaled()
{
	[ -x /usr/libexec/blocaled ]
	return $?;
}

CheckBlocaledVerbose()
{
	[ -x /usr/libexec/blocaled ] || { echo -en "${C_RED}blocaled${C_RESET} " >&2; return 1; }
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageBlocaled()
{
	DownloadPackage	"${PackageBlocaled[Source]}"	"${SHMAN_PDIR}"	"${PackageBlocaled[Package]}${PackageBlocaled[Extension]}"	"${PackageBlocaled[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageBlocaled[Package]}"	"${PackageBlocaled[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildBlocaled()
{
	if ! cd "${SHMAN_PDIR}${PackageBlocaled[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageBlocaled[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageBlocaled[Package]}/build \
	# 				|| { EchoError "${PackageBlocaled[Name]}> Failed to enter ${SHMAN_PDIR}${PackageBlocaled[Package]}/build"; return 1; }

	EchoInfo	"${PackageBlocaled[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				1> /dev/null || { EchoTest KO ${PackageBlocaled[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBlocaled[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageBlocaled[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageBlocaled[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO "${PackageBlocaled[Name]} but IDC" && PressAnyKeyToContinue;  };

	EchoInfo	"${PackageBlocaled[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageBlocaled[Name]} && PressAnyKeyToContinue; return 1; };
}

_ConfigureBlocaled()
{
	EchoInfo	"${PackageBlocaled[Name]}> /etc/profile.d/i18n.sh"
	cat > /etc/profile.d/i18n.sh << "EOF"
# Begin /etc/profile.d/i18n.sh

if [ -r /etc/locale.conf ]; then source /etc/locale.conf; fi

if [ -n "$LANG" ];              then export LANG; fi
if [ -n "$LC_TYPE" ];           then export LC_TYPE; fi
if [ -n "$LC_NUMERIC" ];        then export LC_NUMERIC; fi
if [ -n "$LC_TIME" ];           then export LC_TIME; fi
if [ -n "$LC_COLLATE" ];        then export LC_COLLATE; fi
if [ -n "$LC_MONETARY" ];       then export LC_MONETARY; fi
if [ -n "$LC_MESSAGES" ];       then export LC_MESSAGES; fi
if [ -n "$LC_PAPER" ];          then export LC_PAPER; fi
if [ -n "$LC_NAME" ];           then export LC_NAME; fi
if [ -n "$LC_ADDRESS" ];        then export LC_ADDRESS; fi
if [ -n "$LC_TELEPHONE" ];      then export LC_TELEPHONE; fi
if [ -n "$LC_MEASUREMENT" ];    then export LC_MEASUREMENT; fi
if [ -n "$LC_IDENTIFICATION" ]; then export LC_IDENTIFICATION; fi

# End /etc/profile.d/i18n.sh
EOF

	EchoInfo	"${PackageBlocaled[Name]}> /etc/locale.conf"
	cat > /etc/locale.conf << EOF
# Begin /etc/locale.conf

LANG=$LANG

# End /etc/locale.conf
EOF

	EchoInfo	"${PackageBlocaled[Name]}> Setup X Keyboard"
	source /etc/sysconfig/console &&
	KEYMAP=${KEYMAP:-us}          &&

	gdbus call --system \
				--dest org.freedesktop.locale1 \
				--object-path /org/freedesktop/locale1 \
				--method org.freedesktop.locale1.SetVConsoleKeyboard \
				"$KEYMAP" "$KEYMAP_CORRECTIONS" true true
}
