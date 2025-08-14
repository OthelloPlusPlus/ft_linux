#!/bin/bash

if [ ! -z "${PackageUnbound[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									Unbound								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageUnbound;
PackageUnbound[Source]="https://nlnetlabs.nl/downloads/unbound/unbound-1.23.0.tar.gz";
PackageUnbound[MD5]="5f82daa38be406a781ef043bd07cb5bd";
PackageUnbound[Name]="unbound";
PackageUnbound[Version]="1.23.0";
PackageUnbound[Package]="${PackageUnbound[Name]}-${PackageUnbound[Version]}";
PackageUnbound[Extension]=".tar.gz";

PackageUnbound[Programs]="unbound unbound-anchor unbound-checkconf unbound-control unbound-control-setup unbound-host";
PackageUnbound[Libraries]="libunbound.so";
PackageUnbound[Python]="";

InstallUnbound()
{
	# Check Installation
	CheckUnbound && return $?;

	# Check Dependencies
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	Optional=(Nettle)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	_BuildUnbound || return $?;
	_ConfigureUnbound;
	return $?
}

CheckUnbound()
{
	CheckInstallation 	"${PackageUnbound[Programs]}"\
						"${PackageUnbound[Libraries]}"\
						"${PackageUnbound[Python]}" 1> /dev/null;
	return $?;
}

CheckUnboundVerbose()
{
	CheckInstallationVerbose	"${PackageUnbound[Programs]}"\
								"${PackageUnbound[Libraries]}"\
								"${PackageUnbound[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildUnbound()
{
	EchoInfo	"Package ${PackageUnbound[Name]}"

	DownloadPackage	"${PackageUnbound[Source]}"	"${SHMAN_PDIR}"	"${PackageUnbound[Package]}${PackageUnbound[Extension]}"	"${PackageUnbound[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageUnbound[Package]}"	"${PackageUnbound[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageUnbound[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageUnbound[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageUnbound[Name]}> Adding dedicated user 'unbound'"
	groupadd -g 88 unbound &&
	useradd -c "Unbound DNS Resolver" \
			-d /var/lib/unbound \
			-u 88 \
       		-g unbound \
			-s /bin/false \
			unbound

	EchoInfo	"${PackageUnbound[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc \
				--disable-static \
				--with-pidfile=/run/unbound.pid \
				1> /dev/null || { EchoTest KO ${PackageUnbound[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageUnbound[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageUnbound[Name]} && PressAnyKeyToContinue; return 1; };

	if CheckBinary doxygen; then
		EchoInfo	"${PackageUnbound[Name]}> make doc"
		make doc 1> /dev/null || { EchoTest KO ${PackageUnbound[Name]} && PressAnyKeyToContinue; return 1; };
	fi

	EchoInfo	"${PackageUnbound[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageUnbound[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageUnbound[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageUnbound[Name]} && PressAnyKeyToContinue; return 1; };
	mv -v /usr/sbin/unbound-host /usr/bin/

	if CheckBinary doxygen; then
		install -v -m755 -d /usr/share/doc/unbound-1.23.0 &&
		install -v -m644 doc/html/* /usr/share/doc/unbound-1.23.0
	fi
}

_ConfigureUnbound()
{
	# echo "nameserver 127.0.0.1" > /etc/resolv.conf

	unbound-anchor

	source ${SHMAN_SDIR}/_BLFSBootscripts.sh && BootScriptUnbound;
	return $?;
}