#!/bin/bash

if [ ! -z "${PackageLinux[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

UserName="ohengelm"

# =====================================||===================================== #
#									 Linux									   #
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
			"--enable CONFIG_DRM" # Required to add GUI later
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
			"--enable CONFIG_DRM"
			# Direct Rendering Manager --->
				# "--module CONFIG_DRM_RADEON" # r300 or r600
				# "--module CONFIG_DRM_AMDGPU" # radeonsi
				# "--enable CONFIG_DRM_AMDGPU_SI" # radeonsi
				# "--enable CONFIG_DRM_AMDGPU_CIK" # radeonsi
				# "--enable CONFIG_DRM_AMD_DC" # radeonsi
				# "--module CONFIG_DRM_NOUVEAU" # nouveau
				# "--enable CONFIG_DRM_NOUVEAU_GSP_DEFAULT" # nouveau
				# "--module CONFIG_DRM_I915" # i915, crocus, or iris
				"--enable CONFIG_DRM_VGEM" # llvmpipe or softpipe
				"--module CONFIG_DRM_VMWGFX" # svga	

	# AI recommendations
	# "--enable CONFIG_DRM"                         # Must be built-in for early GPU init
	"--enable CONFIG_DRM_KMS_HELPER"             # KMS support for modern X
	# "--enable CONFIG_DRM_VMWGFX"                 # VMware SVGA II graphics driver
	"--enable CONFIG_DRM_TTM"                    # Required by vmwgfx
	"--module CONFIG_DRM_TTM_HELPER"             # Helper for TTM memory manager
	"--enable CONFIG_DRM_GEM_SHMEM_HELPER"       # GEM shared memory for modesetting
	"--enable CONFIG_DRM_PANEL_ORIENTATION_QUIRKS" # Used for orientation hints

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

PackageLinuxConfigLinuxPAM=(
	# General setup --->
	"--enable CONFIG_AUDIT"    
)

# PackageLinuxConfigLinuxXorg=(
# 	DRM
# 	DRM_VMWGFX
# 	DRM_BOCHS
# 	DRM_VBOXVIDEO

# 	SYSFB_SIMPLEFB
# 	DRM  
# 	DRM_SIMPLEDRM 
# )


PackageLinuxConfig=(
	"${PackageLinuxConfigLFS[@]}"
	# "${PackageLinuxConfigBLFS[@]}"
	"${PackageLinuxConfigMesa[@]}"
	"${PackageLinuxConfigLibUSB[@]}"
	"${PackageLinuxConfigLibAlsaLib[@]}"
	"${PackageLinuxConfigLibEvdev[@]}"
	"${PackageLinuxConfigPolkit[@]}"
	"${PackageLinuxConfigElogind[@]}"
	"${PackageLinuxConfigLinuxPAM[@]}"
)

InstallLinux()
{
	# Check Installation
	CheckLinux && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLinux[Name]}> Checking dependencies..."
	local Required=(Bash Bc Binutils Coreutils Diffutils Findutils GCC Glibc Grep Gzip Kmod Libelf Make Ncurses OpenSSL Perl Sed)
	# for Dependency in "${Required[@]}"; do
	# 	(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	# done

	local Recommended=()
	# for Dependency in "${Recommended[@]}"; do
	# 	(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	# done

	local Optional=(Cpio LLVM RustBindgen)
	# for Dependency in "${Optional[@]}"; do
	# 	if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
	# 		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	# 	fi
	# done
	
	# Install Package
	EchoInfo	"${PackageLinux[Name]}> Building package..."
	_ExtractPackageLinux || return $?;
	_BuildLinux;
	return $?
}

CheckLinux()
{
	if [ "$(uname -r)" != "${PackageLinux[Version]}-${UserName}" ]; then return 1; fi

	local ConfigFile="/boot/config-${PackageLinux[Version]}"
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
	if [ "$(uname -r)" != "${PackageLinux[Version]}-${UserName}" ]; then
		if [ -f /boot/config-${PackageLinux[Version]} ]; then
			echo -en "${C_RED}Running kernel $(uname -r) (reboot)${C_RESET}" >&2
			return 1;
		else
			echo -en "${C_RED}/boot/config-${PackageLinux[Version]}${C_RESET}" >&2
		fi
	fi

	local ReturnValue=0;
	local ConfigFile="/boot/config-${PackageLinux[Version]}"
	for ConfigItem in "${PackageLinuxConfig[@]}"; do
		[[ -z "$ConfigItem" ]] && continue ;
		local ConfigSetting="${ConfigItem%% *}"
		local ConfigName="$(echo "${ConfigItem#* }" | tr -d '[:space:]')";
		case $ConfigSetting in
			"--enable")		if ! grep -Eq "^${ConfigName}=y" $ConfigFile; then ReturnValue=1; echo -en "${C_RED}$ConfigName${C_RESET}=y " >&2; fi ;;
			"--module") 	if ! grep -Eq "^${ConfigName}=(y|m)" $ConfigFile; then ReturnValue=1; echo -en "${C_RED}$ConfigName${C_RESET}=m ">&2; fi ;;
			"--disable") 	if grep -Eq "^${ConfigName}=(y|m)" $ConfigFile; then ReturnValue=1; echo -en "${C_RED}$ConfigName${C_RESET} ">&2; fi ;;
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
	# Adding username to version
	scripts/config --disable LOCALVERSION_AUTO
	scripts/config --set-str LOCALVERSION "-${UserName}"

	EchoInfo	"${PackageLinux[Name]}> Configure (enable new settings)"
	make olddefconfig 1> /dev/null || { EchoTest KO ${PackageLinux[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLinux[Name]}> make"
	make 1> /dev/null &
	local MakePid=$!;
	(
		while kill -0 $MakePid 2> /dev/null; do
			date +%T
			sleep 60
		done
	) &
	local MonitorPid=$!;
	echo "MonitorPid: $MonitorPid"
	wait $MakePid && kill $MonitorPid || { 
		kill $MonitorPid;
		EchoTest KO ${PackageLinux[Name]};
		PressAnyKeyToContinue;
		return 1;
	};
	date +%T


	EchoInfo	"${PackageLinux[Name]}> make modules_install"
	date 2> /dev/null;
	make modules_install 1> /dev/null || { EchoTest KO ${PackageLinux[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLinux[Name]}> Ensuring /boot in mounted";
	date 2> /dev/null;
	mountpoint /boot || mount /dev/sda1 /boot;

	EchoInfo	"${PackageLinux[Name]}> Copying crucial files for GRUB boot";
	cp -v arch/x86/boot/bzImage /boot/vmlinuz-${PackageLinux[Version]}-${UserName}
	cp -v System.map /boot/System.map-${PackageLinux[Version]}
	cp -v .config /boot/config-${PackageLinux[Version]}
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

	EchoInfo	"${PackageLinux[Name]}> Setting Grub Loader to ${PackageLinux[Version]}"
	sed -i -E "s|vmlinuz-[0-9.]+-lfs-[0-9.]+|vmlinuz-${PackageLinux[Version]}-${UserName}|g" /boot/grub/grub.cfg
	sed -i -E "s|Linux [0-9.]+-lfs-[0-9.]+|Linux ${PackageLinux[Version]}-${UserName}|g" /boot/grub/grub.cfg
}

# _AddLinuxConfiguration()
# {
# 	for Setting in "$@"; do
# 		scripts/config $Setting;
# 	done
# }
