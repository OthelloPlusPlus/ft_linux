
# Linux Distribution - Arch Linux
Arch Linux ISO

Pros:
Highly Customizable: Arch’s philosophy of minimalism and simplicity makes it great for learning how each Linux component fits together.
Excellent Documentation (Arch Wiki): Arch’s documentation is among the best in the Linux world, with detailed guides that explain everything from the kernel to system configuration.
Popular with Developers: Arch is widely used by programmers, making it easy to find resources tailored to software development and kernel work.

Cons:
Requires Patience for Setup: Arch’s installation process is command-line based and can be challenging for beginners, requiring more manual configuration.
Not as Stable for Long-Term Development: Arch is a rolling-release distribution, which means software packages are often on the latest versions, leading to potential stability issues.

Verdict:
Arch is fantastic for learning, particularly for the DIY-minded. If you’re willing to take on the challenge, Arch provides a deep, educational experience on Linux internals. However, it might be a bit daunting as a first experience with Linux.`

| Arch Linux	| Link	|
| :--	| :--	|
| Home	|https://archlinux.org/	|
| Download | https://archlinux.org/download/	|
| Wiki	| https://wiki.archlinux.org/title/Main_page	|

## Download 
Source:		https://mirror.bouwhuis.network/archlinux/iso/2024.11.01/
Image:		archlinux-2024.11.01-x86_64.iso
Signature:	archlinux-2024.11.01-x86_64.iso.sig

Download both the Image and Signature to the same directory.

## Download and Validation
The signature is created alongside the image. It can be used to verify the image download has not been intercepted and replaced by a malicious images.

```gpg --keyserver-options auto-key-retrieve --verify archlinux-2024.11.01-x86_64.iso.sig```

# VirtualBox

## Linux Setup
Virtual machine Name and Operating System
Machine Name and OS Type
| Machine Name	| vm_linux	|
| Machine Folder	| /sgoinfre/ohengelm/VirtualMachine	|
| ISO Image	| archlinux-2024.11.01-x86_64.iso	|
| Guest OS Type	| Linux 2.6 / 3.x / 4.x / 5.x (64-bit)	|
Hardware
| Base Memory	| 5120 MB	|
| Processor(s)	| 4	|
| EFI Enable	| false	|
Disk
| Disk Size	| 8.00 GB	|
| Pre-allocate Full Size	| false	|

## Settings

### System

Motherboard > Boot Order: `Optical` before `Hard Disk`

### Storage

Controler: IDE > archlinux-2024.11.01-x86_64.iso
Attributes: Optical Drive: IDE Secondary Drive 0

### Network
Adapter 1 > Attached to: NAT
Advanced > Port Forwarding
| Name	| Protocol	| Host IP	| Host Port	| Guest IP	| Guest Port	|
| :--	| :--	| :--	| :--	| :--	| :--	|
| SSH	| TCP	| 	| 2222	| 	| 22	|

## SSH Communication
```scp -P [Host_Port] [src_file] root@127.0.0.1:[dest_dir]```

# Arch Linux

## Bootup
For more space in airootfs (part of cowspace) interupt bootup and caternade cow_spacesize

> Arch Liux install medium (x86_64, BIOS)
- Press tab
- caternate cow_spacesize=512M
```shell
.linux /arch/boot/x86_64/vmlinuz-linux archisobasedir=arch archisosearchuuid=2024-11-01-10-09-22-00 initrd=/arch/boot/x86_64/initramfs-linux.img cow_spacesize=512M
```


## Formatting and mounting
```shell
fdisk /dev/sda

```

## Setting password
```passwd```

# Linux Kernel
https://www.kernel.org/
longterm:	6.6.63	2024-11-22
linux-6.6.63.tar.xz (tarball)

# Partitions
"In simple terms, partitions are divisions of a storage device, such as a hard drive or SSD. When you set up a storage device (like a hard drive) on a computer, it starts as a single, large block of space. But computers need to organize the data on that storage device in a way that makes sense for the operating system to use. Partitioning is the process of dividing this large block of storage into smaller, manageable sections.

Each partition acts like its own "mini-hard drive" that can be formatted and used independently."

```sh
lsblk

fdisk -l
```
1. Primary Partition:
A primary partition is a direct partition on the disk and can be used to store data. You can have a maximum of 4 primary partitions on a disk.
Primary partitions are the first level of partitioning, and they can hold the operating system or other files directly.
2. Extended Partition:
An extended partition is a special type of partition that allows you to create more than 4 partitions on a single disk. You can only have one extended partition on a disk, but within this extended partition, you can create many logical partitions.
It acts as a container for logical partitions, allowing you to bypass the 4-partition limit imposed by primary partitions.
3. Logical Partition:
A logical partition resides within the extended partition. It is essentially a secondary partition and is used to extend the available partitioning beyond the 4-primary partition limit.
You can create as many logical partitions as you need (limited by the disk size and filesystem constraints).

# Notes
Arch Liux install medium (x86_64, BIOS)
```shell
.linux /arch/boot/x86_64/vmlinuz-linux archisobasedir=arch archisosearchuuid=2024-11-01-10-09-22-00 initrd=/arch/boot/x86_64/initramfs-linux.img
```