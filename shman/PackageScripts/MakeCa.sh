#!/bin/bash

if [ ! -z "${PackageMakeCa[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									MakeCa								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMakeCa;
PackageMakeCa[Source]="https://github.com/lfs-book/make-ca/archive/v1.15/make-ca-1.15.tar.gz";
PackageMakeCa[MD5]="1af805d92b55091b5f11fd7db77c9b0e";
PackageMakeCa[Name]="make-ca";
PackageMakeCa[Version]="1.15";
PackageMakeCa[Package]="${PackageMakeCa[Name]}-${PackageMakeCa[Version]}";
PackageMakeCa[Extension]=".tar.gz";

PackageMakeCa[Programs]="make-ca";
PackageMakeCa[Libraries]="";
PackageMakeCa[Python]="";

InstallMakeCa()
{
	# Check Installation
	CheckMakeCa && return $?;

	# Check Dependencies
	EchoInfo	"${PackageMakeCa[Name]}> Checking dependencies..."
	Required=(LibTasn1 P11Kit Nss)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageMakeCa[Name]}> Building packages..."
	_ExtractPackageMakeCa || return $?;
	_BuildMakeCa || return $?;
	_SetupCertificateStore;
	return $?
}

CheckMakeCa()
{
	CheckInstallation 	"${PackageMakeCa[Programs]}"\
						"${PackageMakeCa[Libraries]}"\
						"${PackageMakeCa[Python]}" 1> /dev/null;
	return $?;
}

CheckMakeCaVerbose()
{
	CheckInstallationVerbose	"${PackageMakeCa[Programs]}"\
								"${PackageMakeCa[Libraries]}"\
								"${PackageMakeCa[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageMakeCa()
{
	DownloadPackage	"${PackageMakeCa[Source]}"	"${SHMAN_PDIR}"	"${PackageMakeCa[Package]}${PackageMakeCa[Extension]}"	"${PackageMakeCa[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageMakeCa[Package]}"	"${PackageMakeCa[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildMakeCa()
{
	if ! cd "${SHMAN_PDIR}${PackageMakeCa[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageMakeCa[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageMakeCa[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageMakeCa[Name]} && PressAnyKeyToContinue; return 1; };
	install -vdm755 /etc/ssl/local 1> /dev/null || { EchoTest KO ${PackageMakeCa[Name]} && PressAnyKeyToContinue; return 1; };
}

_SetupCertificateStore()
{
	CheckNss || return $?;

	EchoInfo	"${PackageMakeCa[Name]}> Download the certificate source and prepare for system use"
	/usr/sbin/make-ca -g

	source "${SHMAN_SDIR}/Fcron.sh" && CheckFcron && cat > /etc/cron.weekly/update-pki.sh << "EOF"
#!/bin/bash
/usr/sbin/make-ca -g
EOF
chmod 754 /etc/cron.weekly/update-pki.sh
}
