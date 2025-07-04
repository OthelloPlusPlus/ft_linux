#!/bin/bash

if [ ! -z "${PackageLinux[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									Linux								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLinux;
PackageLinux[Source]="https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.10.14.tar.xz";
PackageLinux[MD5]="37212bd36eeacdae65a43fb677502f87";
PackageLinux[Name]="linux";
PackageLinux[Version]="6.10.14";
PackageLinux[Package]="${PackageLinux[Name]}-${PackageLinux[Version]}";
PackageLinux[Extension]=".tar.xz";

PackageLinuxConfigLFS=(
	# General setup --->
		"--disable CONFIG_WERROR"
		# CPU/Task time and stats accounting --->
			"--enable CONFIG_PSI"
			"--disable CONFIG_PSI_DEFAULT_DISABLED"
		"--disable CONFIG_IKHEADERS"
		"--enable CONFIG_CGROUPS"
			"--enable CONFIG_MEMCG"
		"--disable CONFIG_EXPERT"
	# Processor type and features --->
		"--enable CONFIG_RELOCATABLE"
		"--enable CONFIG_RANDOMIZE_BASE"
		"--enable CONFIG_X86_X2APIC" #64
	# General architecture-dependent options --->
		"--enable CONFIG_STACKPROTECTOR"
		"--enable CONFIG_STACKPROTECTOR_STRONG"
	# Device Drivers --->
		# Generic Driver Options --->
			"--disable CONFIG_UEVENT_HELPER"
			"--enable CONFIG_DEVTMPFS"
			"--enable CONFIG_DEVTMPFS_MOUNT"
		# Graphics support --->
			"--module CONFIG_DRM" # Required to add GUI later
				"--enable CONFIG_DRM_FBDEV_EMULATION"
			# Console display driver support --->
				"--enable CONFIG_FRAMEBUFFER_CONSOLE"
		"--enable CONFIG_PCI" #64
			"--enable CONFIG_PCI_MSI" #64
		"--enable CONFIG_IOMMU_SUPPORT" #64
			"--enable CONFIG_IRQ_REMAP" #64
)

PackageLinuxConfigBLFS=(
	
)

PackageLinuxConfigMesa=(
	# Device Drivers --->
		# Graphics support --->
			# Direct Rendering Manager --->
				"--module CONFIG_DRM_RADEON" # r300 or r600
				"--module CONFIG_DRM_AMDGPU" # radeonsi
				"--enable CONFIG_DRM_AMDGPU_SI" # radeonsi
				"--enable CONFIG_DRM_AMDGPU_CIK" # radeonsi
				"--enable CONFIG_DRM_AMD_DC" # radeonsi
				"--module CONFIG_DRM_NOUVEAU" # nouveau
				"--enable CONFIG_DRM_NOUVEAU_GSP_DEFAULT" # nouveau
				"--module CONFIG_DRM_I915" # i915, crocus, or iris
				"--module CONFIG_DRM_VGEM" # llvmpipe or softpipe
				"--module CONFIG_DRM_VMWGFX" # svga
	
)

PackageLinuxConfigLibUSB=(
	# Device Drivers --->
	"--enable CONFIG_USB_SUPPORT"
		# USB support --->
		"--module CONFIG_USB"
		"--enable CONFIG_USB_PCI"
		"--module CONFIG_USB_XHCI_HCD"
		"--module CONFIG_USB_EHCI_HCD"
		"--module CONFIG_USB_OHCI_HCD"
)

PackageLinuxConfigLibAlsaLib=(
	# Device Drivers --->
	"--module CONFIG_SOUND"
		# Sound card support --->    
		"--module CONFIG_SND"
)

PackageLinuxConfigLibEvdev=(
	# Device Drivers --->
		# Input device support --->
		"--enable CONFIG_INPUT"    
		"--module CONFIG_INPUT_EVDEV"
		"--enable CONFIG_INPUT_MISC"
		"--module CONFIG_INPUT_UINPUT"
)

PackageLinuxConfigPolkit=(
	# General setup --->
	"--enable CONFIG_NAMESPACES"    
		# Namespaces support ---> 
		"--enable CONFIG_USER_NS"
)

PackageLinuxConfigElogind=(
	# File systems --->
	"--enable CONFIG_INOTIFY_USER"    
		# Pseudo filesystems --->
		"--enable CONFIG_TMPFS"
		"--enable CONFIG_TMPFS_POSIX_ACL"
	# Cryptographic API --->
	"--enable CONFIG_CRYPTO"
		# 	Crypto core or helper --->
		"--module CONFIG_CRYPTO_USER"
		# Userspace interface --->
		"--module CONFIG_CRYPTO_USER_API_HASH"
)

PackageLinuxConfig=(
	"${PackageLinuxConfigLFS[@]}"
	# "${PackageLinuxConfigBLFS[@]}"
	"${PackageLinuxConfigMesa[@]}"
	"${PackageLinuxConfigLibUSB[@]}"
	"${PackageLinuxConfigLibAlsaLib[@]}"
	"${PackageLinuxConfigLibEvdev[@]}"
	"${PackageLinuxConfigPolkit[@]}"
	"${PackageLinuxConfigElogind[@]}"
)

InstallLinux()
{
	# Check Installation
	CheckLinux && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLinux[Name]}> Checking dependencies..."
	Required=()
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
	EchoInfo	"${PackageLinux[Name]}> Building package..."
	_ExtractPackageLinux || return $?;
	_BuildLinux;
	return $?
}

CheckLinux()
{
	local ConfigFile="/boot/config-$(uname -r)"
	for ConfigItem in "${PackageLinuxConfig[@]}"; do
		[[ -z "$ConfigItem" ]] && continue ;
		local ConfigSetting="${ConfigItem%% *}"
		local ConfigName="${ConfigItem#* }";
		case $ConfigSetting in
			"--enable")		if ! grep -Eq "^${ConfigName}=y" $ConfigFile; then return 1; fi;;
			"--module") 	if ! grep -Eq "^${ConfigName}=m" $ConfigFile; then return 1; fi;;
			"--disable") 	if grep -Eq "^${ConfigName}=(y|m)" $ConfigFile; then return 1; fi;;
			*) return 1;;
		esac
	done
	return 0;
}

CheckLinuxVerbose()
{
	local ReturnValue=0;
	local ConfigFile="/boot/config-$(uname -r)"
	for ConfigItem in "${PackageLinuxConfig[@]}"; do
		[[ -z "$ConfigItem" ]] && continue ;
		local ConfigSetting="${ConfigItem%% *}"
		local ConfigName="${ConfigItem#* }";
		case $ConfigSetting in
			"--enable")		if ! grep -Eq "^${ConfigName}=y" $ConfigFile; then ReturnValue=1; echo -en "${C_RED}$ConfigName${C_RESET} " >&2; fi;;
			"--module") 	if ! grep -Eq "^${ConfigName}=(y|m)" $ConfigFile; then ReturnValue=1; echo -en "${C_RED}$ConfigName${C_RESET} ">&2; fi;;
			"--disable") 	if grep -Eq "^${ConfigName}=(y|m)" $ConfigFile; then ReturnValue=1; echo -en "${C_RED}$ConfigName${C_RESET} ">&2; fi;;
			*) echo -en "${C_RED}$ConfigSetting${C_RESET}[$ConfigName] " >&2; return 1;;
		esac
	done
	echo
	return $ReturnValue;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLinux()
{
	DownloadPackage	"${PackageLinux[Source]}"	"${SHMAN_PDIR}"	"${PackageLinux[Package]}${PackageLinux[Extension]}"	"${PackageLinux[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLinux[Package]}"	"${PackageLinux[Extension]}" || return $?;

	for URL in \
	# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildLinux()
{
	if ! cd "${SHMAN_PDIR}${PackageLinux[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLinux[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLinux[Name]}> Clean"
	make mrproper 1> /dev/null || { EchoTest KO ${PackageLinux[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLinux[Name]}> Configure (default settings)"
	make defconfig 1> /dev/null || { EchoTest KO ${PackageLinux[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLinux[Name]}> Configure (custom settings)"
	for Setting in "${PackageLinuxConfig[@]}"; do
		scripts/config $Setting;
	done

	EchoInfo	"${PackageLinux[Name]}> Configure (enable new settings)"
	make olddefconfig 1> /dev/null || { EchoTest KO ${PackageLinux[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLinux[Name]}> make"
	date 2> /dev/null;
	make 1> /dev/null || { EchoTest KO ${PackageLinux[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLinux[Name]}> make modules_install"
	make modules_install 1> /dev/null || { EchoTest KO ${PackageLinux[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLinux[Name]}> Ensuring /boot in mounted";
	mountpoint /boot || mount /dev/sda1 /boot;

	EchoInfo	"${PackageLinux[Name]}> Copying crucial files for GRUB boot";
	cp -iv arch/x86/boot/bzImage /boot/vmlinuz-${PackageLinux[Version]}-lfs-12.2
	cp -iv System.map /boot/System.map-${PackageLinux[Version]}
	cp -iv .config /boot/config-${PackageLinux[Version]}
	cp -r Documentation -T /usr/share/doc/linux-${PackageLinux[Version]}

	# 10.3.2. Configuring Linux Module Load Order
	EchoInfo	"${PackageLinux[Name]}> Configuring Linux Module Load Order"
	install -v -m755 -d /etc/modprobe.d
	EchoInfo	"${PackageLinux[Name]}> /etc/modprobe.d/usb.conf"
	cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF
}

# _AddLinuxConfiguration()
# {
# 	for Setting in "$@"; do
# 		scripts/config $Setting;
# 	done
# }
