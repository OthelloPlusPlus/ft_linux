#!/bin/bash

if [ ! -z "${PackageAppStream[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									AppStream								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageAppStream;
# Manual
PackageAppStream[Source]="https://www.freedesktop.org/software/appstream/releases/AppStream-1.0.4.tar.xz";
PackageAppStream[MD5]="a9f9b45b9a3b2125148821b42b218d77";
# Automated unless edgecase
PackageAppStream[Name]="";
PackageAppStream[Version]="";
PackageAppStream[Extension]="";
if [[ -n "${PackageAppStream[Source]}" ]]; then
	filename="${PackageAppStream[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageAppStream[Name]}" ]] && PackageAppStream[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageAppStream[Version]}" ]] && PackageAppStream[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageAppStream[Extension]}" ]] && PackageAppStream[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageAppStream[Package]="${PackageAppStream[Name]}-${PackageAppStream[Version]}";

PackageAppStream[Programs]="appstreamcli";
PackageAppStream[Libraries]="libappstream.so";
PackageAppStream[Python]="";

InstallAppStream()
{
	# Check Installation
	CheckAppStream && return $?;

	# Check Dependencies
	EchoInfo	"${PackageAppStream[Name]}> Checking dependencies..."
	Required=(cURL Elogind Itstool LibXml2 LibXmlb LibYaml)
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageAppStream[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageAppStream[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(GiDocGen Qt)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageAppStream[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageAppStream[Name]}> Building package..."
	_ExtractPackageAppStream || return $?;
	_BuildAppStream || return $?;
	_ConfigureAppStream || return $?;

	RunTime=()
	for Dependency in "${RunTime[@]}"; do
		# EchoInfo	"${PackageAppStream[Name]}> Checking runtime ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	return $?
}

CheckAppStream()
{
	CheckInstallation 	"${PackageAppStream[Programs]}"\
						"${PackageAppStream[Libraries]}"\
						"${PackageAppStream[Python]}" 1> /dev/null;
	return $?;
}

CheckAppStreamVerbose()
{
	CheckInstallationVerbose	"${PackageAppStream[Programs]}"\
								"${PackageAppStream[Libraries]}"\
								"${PackageAppStream[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageAppStream()
{
	DownloadPackage	"${PackageAppStream[Source]}"	"${SHMAN_PDIR}"	"${PackageAppStream[Package]}${PackageAppStream[Extension]}"	"${PackageAppStream[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageAppStream[Package]}"	"${PackageAppStream[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildAppStream()
{
	if ! cd "${SHMAN_PDIR}${PackageAppStream[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageAppStream[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageAppStream[Package]}/build \
					|| { EchoError "${PackageAppStream[Name]}> Failed to enter ${SHMAN_PDIR}${PackageAppStream[Package]}/build"; return 1; }

	EchoInfo	"${PackageAppStream[Name]}> Configure"
	meson setup --prefix=/usr \
				--buildtype=release \
				-D apidocs=false \
				-D stemming=false \
				1> /dev/null || { EchoTest KO ${PackageAppStream[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAppStream[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageAppStream[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAppStream[Name]}> ninja test"
	ninja test 1> /dev/null || { EchoTest KO ${PackageAppStream[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageAppStream[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageAppStream[Name]} && PressAnyKeyToContinue; return 1; };

	mv -v /usr/share/doc/appstream{,-1.0.4}
}

_ConfigureAppStream()
{
	EchoInfo	"${PackageAppStream[Name]}> Install /usr/share/metainfo"
	install -vdm755 /usr/share/metainfo

	EchoInfo	"${PackageAppStream[Name]}> /usr/share/metainfo/org.linuxfromscratch.lfs.xml"
cat > /usr/share/metainfo/org.linuxfromscratch.lfs.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<component type="operating-system">
  <id>org.linuxfromscratch.lfs</id>
  <name>Linux From Scratch</name>
  <summary>A customized Linux system built entirely from source</summary>
  <description>
    <p>
      Linux From Scratch (LFS) is a project that provides you with
      step-by-step instructions for building your own customized Linux
      system entirely from source.
    </p>
  </description>
  <url type="homepage">https://www.linuxfromscratch.org/lfs/</url>
  <metadata_license>MIT</metadata_license>
  <developer id='linuxfromscratch.org'>
    <name>The Linux From Scratch Editors</name>
  </developer>

  <releases>
    <release version="12.3" type="release" date="2025-03-05">
      <description>
        <p>The development snapshot of the next LFS version.</p>
      </description>
    </release>

    <release version="12.2" type="stable" date="2024-09-01">
      <description>
        <p>Now contains Binutils 2.43.1, GCC-14.2.0, Glibc-2.40,
        and Linux kernel 6.10.</p>
      </description>
    </release>
  </releases>
</component>
EOF
}