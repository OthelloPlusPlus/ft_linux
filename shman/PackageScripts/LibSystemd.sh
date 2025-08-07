#!/bin/bash

if [ ! -z "${PackageLibSystemd[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LibSystemd								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibSystemd;
# Manual
PackageLibSystemd[Source]="https://github.com/systemd/systemd/archive/v256.4/systemd-256.4.tar.gz";
PackageLibSystemd[MD5]="03bd1ff158ec0bc55428c77a8f8495bd";
# Automated unless edgecase
PackageLibSystemd[Name]="";
PackageLibSystemd[Version]="";
PackageLibSystemd[Extension]="";
if [[ -n "${PackageLibSystemd[Source]}" ]]; then
	filename="${PackageLibSystemd[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageLibSystemd[Name]}" ]] && PackageLibSystemd[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageLibSystemd[Version]}" ]] && PackageLibSystemd[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageLibSystemd[Extension]}" ]] && PackageLibSystemd[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageLibSystemd[Package]="${PackageLibSystemd[Name]}-${PackageLibSystemd[Version]}";

PackageLibSystemd[Programs]="";
PackageLibSystemd[Libraries]="libsystemd.so";
PackageLibSystemd[Python]="";

InstallLibSystemd()
{
	# Check Installation
	CheckLibSystemd && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLibSystemd[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageLibSystemd[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageLibSystemd[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageLibSystemd[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageLibSystemd[Name]}> Building package..."
	_ExtractPackageLibSystemd || return $?;
	_BuildLibSystemd;
	return $?
}

CheckLibSystemd()
{
	CheckInstallation 	"${PackageLibSystemd[Programs]}"\
						"${PackageLibSystemd[Libraries]}"\
						"${PackageLibSystemd[Python]}" 1> /dev/null;
	return $?;
}

CheckLibSystemdVerbose()
{
	CheckInstallationVerbose	"${PackageLibSystemd[Programs]}"\
								"${PackageLibSystemd[Libraries]}"\
								"${PackageLibSystemd[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLibSystemd()
{
	DownloadPackage	"${PackageLibSystemd[Source]}"	"${SHMAN_PDIR}"	"${PackageLibSystemd[Package]}${PackageLibSystemd[Extension]}"	"${PackageLibSystemd[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLibSystemd[Package]}"	"${PackageLibSystemd[Extension]}" || return $?;

	for URL in \
		"https://anduin.linuxfromscratch.org/LFS/systemd-man-pages-256.4.tar.xz" \
		"https://anduin.linuxfromscratch.org/LFS/udev-lfs-20230818.tar.xz"
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

# _BuildLibSystemd()
# {
# 	if ! cd "${SHMAN_PDIR}${PackageLibSystemd[Package]}"; then
# 		EchoError	"cd ${SHMAN_PDIR}${PackageLibSystemd[Package]}";
# 		return 1;
# 	fi

# 	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibSystemd[Package]}/build \
# 					|| { EchoError "${PackageLibSystemd[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibSystemd[Package]}/build"; return 1; }

# 	EchoInfo	"${PackageLibSystemd[Name]}> Configure"
# 	meson setup .. \
# 				--prefix=/usr \
# 				--buildtype=release \
# 				-D mode=release \
# 				-D dev-kvm-mode=0660 \
# 				-D link-udev-shared=false \
# 				-D logind=false \
# 				-D vconsole=false \
# 				1> /dev/null || { EchoTest KO ${PackageLibSystemd[Name]} && PressAnyKeyToContinue; return 1; };

# 	meson setup .. \
# 				--prefix=/usr \
# 				--buildtype=release \
# 				-D mode=release \
# 				-D dev-kvm-mode=0660 \
# 				-D link-udev-shared=false \
# 				-D logind=false \
# 				-D vconsole=false \
# 				-D static-libsystemd=true \
# 				--reconfigure


# 	EchoInfo	"${PackageLibSystemd[Name]}> make"
# 	make 1> /dev/null || { EchoTest KO ${PackageLibSystemd[Name]} && PressAnyKeyToContinue; return 1; };

# 	EchoInfo	"${PackageLibSystemd[Name]}> make check"
# 	make check 1> /dev/null || { EchoTest KO ${PackageLibSystemd[Name]} && PressAnyKeyToContinue; return 1; };

# 	EchoInfo	"${PackageLibSystemd[Name]}> make install"
# 	make install 1> /dev/null || { EchoTest KO ${PackageLibSystemd[Name]} && PressAnyKeyToContinue; return 1; };
# }

_BuildLibSystemd()
{
	if ! cd "${SHMAN_PDIR}${PackageLibSystemd[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLibSystemd[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibSystemd[Name]}> Remove unneeded groups"
	sed -i	-e 's/GROUP="render"/GROUP="video"/' \
			-e 's/GROUP="sgx", //' \
			rules.d/50-udev-default.rules.in

	EchoInfo	"${PackageLibSystemd[Name]}> Remove rule"
	sed '/systemd-sysctl/s/^/#/' -i rules.d/99-systemd.rules.in

	EchoInfo	"${PackageLibSystemd[Name]}> Adjust hardcoded path"
	sed '/NETWORK_DIRS/s/systemd/udev/' -i src/basic/path-lookup.h

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLibSystemd[Package]}/build \
					|| { EchoError "${PackageLibSystemd[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLibSystemd[Package]}/build"; return 1; }

	EchoInfo	"${PackageLibSystemd[Name]}> Configure"
	meson setup .. 	\
				--prefix=/usr \
				--buildtype=release \
				-D mode=release \
				-D dev-kvm-mode=0660 \
				-D link-udev-shared=false \
				-D logind=false \
				-D vconsole=false \
				-D static-libsystemd=true \
				1> /dev/null || { EchoTest KO ${PackageLibSystemd[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibSystemd[Name]}> Export udev helpers to env"
	export udev_helpers=$(grep "'name' :" ../src/udev/meson.build | awk '{print $3}' | tr -d ",'" | grep -v 'udevadm')

	EchoInfo	"${PackageLibSystemd[Name]}> Build"
	ninja 	udevadm systemd-hwdb \
			$(ninja -n | grep -Eo '(src/(lib)?udev|rules.d|hwdb.d)/[^ ]*') \
			$(realpath libudev.so --relative-to .) \
			$(realpath libsystemd.so --relative-to .) \
			$udev_helpers \
			1> /dev/null || { EchoTest KO ${PackageLibSystemd[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibSystemd[Name]}> Install"
	install -vm755 -d {/usr/lib,/etc}/udev/{hwdb.d,rules.d,network}				1> /dev/null && \
	install -vm755 -d /usr/{lib,share}/pkgconfig								1> /dev/null && \
	install -vm755 udevadm								/usr/bin/				1> /dev/null && \
	install -vm755 systemd-hwdb							/usr/bin/udev-hwdb		1> /dev/null && \
	ln	-svfn ../bin/udevadm							/usr/sbin/udevd			1> /dev/null && \
	cp	-av	libudev.so{,*[0-9]}							/usr/lib/				1> /dev/null && \
	install -vm644 ../src/libudev/libudev.h				/usr/include/			1> /dev/null && \
	install -vm644 src/libudev/*.pc						/usr/lib/pkgconfig/		1> /dev/null && \
	install -vm644 src/udev/*.pc						/usr/share/pkgconfig/	1> /dev/null && \
	install -vm644 ../src/udev/udev.conf				/etc/udev/				1> /dev/null && \
	cp	-av	libsystemd.so{,*[0-9]}						/usr/lib/				1> /dev/null && \
	install -vm644 src/libsystemd/*.pc					/usr/lib/pkgconfig/		1> /dev/null && \
	install -vm644 rules.d/* ../rules.d/README			/usr/lib/udev/rules.d/	1> /dev/null && \
	install -vm644 $(find ../rules.d/*.rules -not -name '*power-switch*') \
														/usr/lib/udev/rules.d/	1> /dev/null && \
	install -vm644 hwdb.d/* ../hwdb.d/{*.hwdb,README} 	/usr/lib/udev/hwdb.d/	1> /dev/null && \
	install -vm755 $udev_helpers						/usr/lib/udev			1> /dev/null && \
	install -vm644 ../network/99-default.link			/usr/lib/udev/network 	1> /dev/null && \
	PackageUdev[Status]=$? || { EchoTest KO ${PackageLibSystemd[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLibSystemd[Name]}> Install custom rules and support files"
	tar -xvf ../../udev-lfs-20230818.tar.xz 1> /dev/null || { EchoTest KO ${PackageLibSystemd[Name]} && PressAnyKeyToContinue; return 1; };
	make -f udev-lfs-20230818/Makefile.lfs install 1> /dev/null || { EchoTest KO ${PackageLibSystemd[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibSystemd[Name]}> Install man pages"
	tar -xf ../../systemd-man-pages-256.4.tar.xz \
		--no-same-owner --strip-components=1 \
		-C /usr/share/man --wildcards '*/udev*' '*/libudev*' '*/systemd.link.5' '*/systemd-'{hwdb,udevd.service}.8

	sed 's|systemd/network|udev/network|' \
		/usr/share/man/man5/systemd.link.5 \
		> /usr/share/man/man5/udev.link.5
	
	sed 's/systemd\(\\\?-\)/udev\1/' /usr/share/man/man8/systemd-hwdb.8 \
		> /usr/share/man/man8/udev-hwdb.8

	sed 's|lib.*udevd|sbin/udevd|' \
		/usr/share/man/man8/systemd-udevd.service.8 \
		> /usr/share/man/man8/udevd.8

	rm /usr/share/man/man*/systemd*

	EchoInfo	"${PackageLibSystemd[Name]}> Configure"
	udev-hwdb update

	unset udev_helpers
}
