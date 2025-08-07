#!/bin/bash

if [ ! -z "${PackageXorgApplications[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									XorgApplications								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageXorgApplications;
# Manual
PackageXorgApplications[Source]="https://www.x.org/pub/individual/app/";
PackageXorgApplications[MD5]="";
# Automated unless edgecase
PackageXorgApplications[Name]="xorgapplications";
PackageXorgApplications[Version]="";
PackageXorgApplications[Extension]="";
if [[ -n "${PackageXorgApplications[Source]}" ]]; then
	filename="${PackageXorgApplications[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageXorgApplications[Name]}" ]] && PackageXorgApplications[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageXorgApplications[Version]}" ]] && PackageXorgApplications[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageXorgApplications[Extension]}" ]] && PackageXorgApplications[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageXorgApplications[Package]="${PackageXorgApplications[Name]}-${PackageXorgApplications[Version]}";

PackageXorgApplications[Programs]="iceauth mkfontdir mkfontscale sessreg setxkbmap smproxy xauth xcmsdb xcursorgen xdpr xdpyinfo xdriinfo xev xgamma xhost xinput xkbbell xkbcomp xkbevd xkbvleds xkbwatch xkill xlsatoms xlsclients xmessage xmodmap xpr xprop xrandr xrdb xrefresh xset xsetroot xvinfo xwd xwininfo xwud";
PackageXorgApplications[Libraries]="";
PackageXorgApplications[Python]="";

InstallXorgApplications()
{
	# Check Installation
	CheckXorgApplications && return $?;

	# Check Dependencies
	EchoInfo	"${PackageXorgApplications[Name]}> Checking dependencies..."
	Required=(LibPng Mesa Xbitmaps XcbUtil)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageXorgApplications[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(LinuxPAM)
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageXorgApplications[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=()
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageXorgApplications[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageXorgApplications[Name]}> Building package..."
	if [ $(whoami) != "root" ]; then return 1; fi
	_ExtractPackageXorgApplications || return $?;
	_BuildXorgApplications;
	return $?
}

CheckXorgApplications()
{
	CheckInstallation 	"${PackageXorgApplications[Programs]}"\
						"${PackageXorgApplications[Libraries]}"\
						"${PackageXorgApplications[Python]}" 1> /dev/null;
	return $?;
}

CheckXorgApplicationsVerbose()
{
	CheckInstallationVerbose	"${PackageXorgApplications[Programs]}"\
								"${PackageXorgApplications[Libraries]}"\
								"${PackageXorgApplications[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageXorgApplications()
{
	mkdir -p ${SHMAN_PDIR}${PackageXorgApplications[Package]} 	&& cd ${SHMAN_PDIR}${PackageXorgApplications[Package]} \
	 				|| { EchoError "${PackageXorgApplications[Name]}> Failed to enter ${SHMAN_PDIR}${PackageXorgApplications[Package]}"; return 1; }

	cat > app-7.md5 << "EOF"
30f898d71a7d8e817302970f1976198c  iceauth-1.0.10.tar.xz
7dcf5f702781bdd4aaff02e963a56270  mkfontscale-1.2.3.tar.xz
05423bb42a006a6eb2c36ba10393de23  sessreg-1.1.3.tar.xz
1d61c9f4a3d1486eff575bf233e5776c  setxkbmap-1.3.4.tar.xz
9f7a4305f0e79d5a46c3c7d02df9437d  smproxy-1.0.7.tar.xz
595c941d9aff6f6d6e038c4e42dcff58  xauth-1.1.3.tar.xz
37063ccf902fe3d55a90f387ed62fe1f  xcmsdb-1.0.7.tar.xz
89e81a1c31e4a1fbd0e431425cd733d7  xcursorgen-1.0.8.tar.xz
933e6d65f96c890f8e96a9f21094f0de  xdpyinfo-1.3.4.tar.xz
34aff1f93fa54d6a64cbe4fee079e077  xdriinfo-1.0.7.tar.xz
f29d1544f8dd126a1b85e2f7f728672d  xev-1.2.6.tar.xz
41afaa5a68cdd0de7e7ece4805a37f11  xgamma-1.0.7.tar.xz
45c7e956941194e5f06a9c7307f5f971  xhost-1.0.10.tar.xz
8e4d14823b7cbefe1581c398c6ab0035  xinput-1.6.4.tar.xz
83d711948de9ccac550d2f4af50e94c3  xkbcomp-1.4.7.tar.xz
543c0535367ca30e0b0dbcfa90fefdf9  xkbevd-1.1.6.tar.xz
07483ddfe1d83c197df792650583ff20  xkbutils-1.0.6.tar.xz
f62b99839249ce9a7a8bb71a5bab6f9d  xkill-1.0.6.tar.xz
da5b7a39702841281e1d86b7349a03ba  xlsatoms-1.1.4.tar.xz
ab4b3c47e848ba8c3e47c021230ab23a  xlsclients-1.1.5.tar.xz
ba2dd3db3361e374fefe2b1c797c46eb  xmessage-1.0.7.tar.xz
0d66e07595ea083871048c4b805d8b13  xmodmap-1.0.11.tar.xz
ab6c9d17eb1940afcfb80a72319270ae  xpr-1.2.0.tar.xz
5ef4784b406d11bed0fdf07cc6fba16c  xprop-1.2.8.tar.xz
dc7680201afe6de0966c76d304159bda  xrandr-1.5.3.tar.xz
c8629d5a0bc878d10ac49e1b290bf453  xrdb-1.2.2.tar.xz
55003733ef417db8fafce588ca74d584  xrefresh-1.1.0.tar.xz
18ff5cdff59015722431d568a5c0bad2  xset-1.2.5.tar.xz
fa9a24fe5b1725c52a4566a62dd0a50d  xsetroot-1.1.3.tar.xz
d698862e9cad153c5fefca6eee964685  xvinfo-1.1.5.tar.xz
b0081fb92ae56510958024242ed1bc23  xwd-1.0.9.tar.xz
c91201bc1eb5e7b38933be8d0f7f16a8  xwininfo-1.1.6.tar.xz
3e741db39b58be4fef705e251947993d  xwud-1.0.7.tar.xz
EOF

	mkdir -p app 	&& cd ${SHMAN_PDIR}${PackageXorgApplications[Package]}/app \
					|| { EchoError "${PackageXorgApplications[Name]}> Failed to enter ${SHMAN_PDIR}${PackageXorgApplications[Package]}/font"; return 1; }

	grep -v '^#' ../app-7.md5 | \
		awk '{print $2}' | \
		wget -i- -c \
			-B https://www.x.org/pub/individual/app/
	md5sum -c ../app-7.md5

	return $?;
}

_BuildXorgApplications()
{
	if ! cd "${SHMAN_PDIR}${PackageXorgApplications[Package]}/app"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageXorgApplications[Package]}/app";
		return 1;
	fi

	for package in $(grep -v '^#' ../app-7.md5 | awk '{print $2}'); do
		EchoInfo	"${PackageXorgApplications[Name]}> $package"
		packagedir=${package%.tar.?z*}
		tar -xf $package
		pushd $packagedir
			./configure $XORG_CONFIG &> /dev/null && \
			make &> /dev/null && \
			make install &> /dev/null || { 
				EchoTest KO "${PackageXorgApplications[Name]} Retrying $package";
				PressAnyKeyToContinue;
				./configure $XORG_CONFIG && \
				make && \
				make install || { 
					EchoTest KO "${PackageXorgApplications[Name]} $package";
					PressAnyKeyToContinue;
					return 1;
				};
			};
		popd
		rm -rf $packagedir
	done

	EchoInfo	"${PackageXorgApplications[Name]}> rm $XORG_PREFIX/bin/xkeystone"
	rm -f $XORG_PREFIX/bin/xkeystone
}
