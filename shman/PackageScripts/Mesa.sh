#!/bin/bash

if [ ! -z "${PackageMesa[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									  Mesa									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageMesa;
PackageMesa[Source]="https://mesa.freedesktop.org/archive/mesa-24.3.4.tar.xz";
PackageMesa[MD5]="c64b7e2b4f1c7782c41bf022edbb365c";
PackageMesa[Name]="mesa";
PackageMesa[Version]="24.3.4";
PackageMesa[Package]="${PackageMesa[Name]}-${PackageMesa[Version]}";
PackageMesa[Extension]=".tar.xz";

# removed debugging programs mme_fermi_sim_hw_test mme_tu104_sim_hw_test
PackageMesa[Programs]="glxgears glxinfo";
PackageMesa[Libraries]="libEGL.so libGL.so libGLESv1_CM.so libGLESv2.so libgbm.so libglapi.so libgallium-24.3.4.so libxatracker.so";
PackageMesa[Python]="";

InstallMesa()
{
	# Check Installation
	CheckMesa && return $?;

	# Check Dependencies
	Required=(XorgLibraries LibDrm LibYaml Linux)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	source "${SHMAN_SDIR}/_PythonPip3.sh" && InstallPip Mako Cython PyYAML

	Recommended=(WaylandProtocols)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(LibGcrypt LibUnwind Nettle Pciutils)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"Package ${PackageMesa[Name]}"
	_CheckKernelConfigurationForMesa || return $?;
	_ExtractPackageMesa || return $?;
	_BuildMesa;
	return $?
}

CheckMesa()
{
	CheckInstallation 	"${PackageMesa[Programs]}"\
						"${PackageMesa[Libraries]} swrast_dri.so llvmpipe_dri.so"\
						"${PackageMesa[Python]}" 1> /dev/null;
	return $?;
}

CheckMesaVerbose()
{
	CheckInstallationVerbose	"${PackageMesa[Programs]}"\
								"${PackageMesa[Libraries]} swrast_dri.so llvmpipe_dri.so"\
								"${PackageMesa[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageMesa()
{
	DownloadPackage	"${PackageMesa[Source]}"	"${SHMAN_PDIR}"	"${PackageMesa[Package]}${PackageMesa[Extension]}"	"${PackageMesa[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageMesa[Package]}"	"${PackageMesa[Extension]}" || return $?;
	wget -P "${SHMAN_PDIR}" "https://www.linuxfromscratch.org/patches/blfs/12.3/mesa-add_xdemos-4.patch";

	return $?;
}

_CheckKernelConfigurationForMesa()
{
	local ConfigFile="/boot/config-$(uname -r)";

	case $(lspci | grep VGA | awk '{print tolower($0)}') in
		*r300*|*r600*) 	EchoInfo	"Found match for r300|r600";
						grep -E "DRM_RADEON" $ConfigFile;;
		*radeonsi*) 	EchoInfo	"Found match for radeonsi";
						grep -E "DRM_AMDGPU|DRM_AMDGPU_SI|DRM_AMDGPU_CIK|DRM_AMD_DC" $ConfigFile;;
		*nouveau*) 		EchoInfo	"Found match for nouveau";
						grep -E "DRM_NOUVEAU|DRM_NOUVEAU_GSP_DEFAULT" $ConfigFile;;
		*i915|crocus|iris*) 	EchoInfo	"Found match for i915|crocus|iris";
								grep -E "DRM_I915" $ConfigFile;;
		*llvmpipe|softpipe*) 	EchoInfo	"Found match for llvmpipe|softpipe";
								grep -E "DRM_VGEM" $ConfigFile;;
		*svga*) 		EchoInfo	"Found match for svga";
						grep -E "DRM_VMWGFX" $ConfigFile;;
		*) EchoError "No case for $(lspci | grep VGA)";
			PressAnyKeyToContinue;
			return 1;;
	esac
}

_BuildMesa()
{
	if ! cd "${SHMAN_PDIR}${PackageMesa[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageMesa[Package]}";
		return 1;
	fi

	# Might Require Kernel Configuration
	# https://www.linuxfromscratch.org/blfs/view/stable/x/mesa.html

	EchoInfo	"${PackageMesa[Name]}> Patching"
	patch -Np1 -i ../mesa-add_xdemos-4.patch

	if ! mkdir -p build; then
		EchoError	"Failed to make ${SHMAN_PDIR}${PackageMesa[Name]}/build";
		return 1;
	fi
	cd "${SHMAN_PDIR}${PackageMesa[Package]}/build";

	EchoInfo	"${PackageMesa[Name]}> Configure"
	meson setup .. \
				--prefix=$XORG_PREFIX \
				--buildtype=release \
				-D platforms=x11,wayland \
				-D gallium-drivers=svga,llvmpipe,swrast \
				-D vulkan-drivers="swrast" \
				-D valgrind=disabled \
				-D video-codecs=all \
				1> /dev/null || { EchoTest KO ${PackageMesa[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMesa[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageMesa[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMesa[Name]}> ninja test"
	meson configure -D build-tests=true && ninja test 1> /dev/null || { EchoTest KO ${PackageMesa[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageMesa[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageMesa[Name]} && PressAnyKeyToContinue; return 1; };

	cp -rv ../docs -T /usr/share/doc/mesa-24.3.4
}
