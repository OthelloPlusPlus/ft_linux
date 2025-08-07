#!/bin/bash

if [ ! -z "${PackageOpenSSH[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									OpenSSH								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageOpenSSH;
PackageOpenSSH[Source]="https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.9p2.tar.gz";
PackageOpenSSH[MD5]="f617b95fe278bfea8d004589c7a68a85";
PackageOpenSSH[Name]="openssh";
PackageOpenSSH[Version]="9.9p2";
PackageOpenSSH[Package]="${PackageOpenSSH[Name]}-${PackageOpenSSH[Version]}";
PackageOpenSSH[Extension]=".tar.gz";

PackageOpenSSH[Programs]="scp sftp ssh ssh-add ssh-agent ssh-copy-id ssh-keygen ssh-keyscan sshd";
PackageOpenSSH[Libraries]="";
PackageOpenSSH[Python]="";

InstallOpenSSH()
{
	# Check Installation
	CheckOpenSSH && return $?;

	# Check Dependencies
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(GDB LinuxPAM Shadow XorgBuildEnv MITKerberos Which)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"Package ${PackageOpenSSH[Name]}"
	# _ExtractPackageOpenSSH || return $?;
	# _BuildOpenSSH;
	return $?
}

CheckOpenSSH()
{
	CheckInstallation 	"${PackageOpenSSH[Programs]}"\
						"${PackageOpenSSH[Libraries]}"\
						"${PackageOpenSSH[Python]}" 1> /dev/null;
	return $?;
}

CheckOpenSSHVerbose()
{
	CheckInstallationVerbose	"${PackageOpenSSH[Programs]}"\
								"${PackageOpenSSH[Libraries]}"\
								"${PackageOpenSSH[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageOpenSSH()
{
	DownloadPackage	"${PackageOpenSSH[Source]}"	"${SHMAN_PDIR}"	"${PackageOpenSSH[Package]}${PackageOpenSSH[Extension]}"	"${PackageOpenSSH[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageOpenSSH[Package]}"	"${PackageOpenSSH[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildOpenSSH()
{
	if ! cd "${SHMAN_PDIR}${PackageOpenSSH[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageOpenSSH[Package]}";
		return 1;
	fi

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageOpenSSH[Package]}/build \
	# 				|| { EchoError "${PackageOpenSSH[Name]}> Failed to enter ${SHMAN_PDIR}${PackageOpenSSH[Package]}/build"; return 1; }

	EchoInfo	"${PackageOpenSSH[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { EchoTest KO ${PackageOpenSSH[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageOpenSSH[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageOpenSSH[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageOpenSSH[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageOpenSSH[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageOpenSSH[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageOpenSSH[Name]} && PressAnyKeyToContinue; return 1; };
}
