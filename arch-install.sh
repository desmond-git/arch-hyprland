#! /bin/bash

# Variables
wifi_ssid=""
wifi_password=""
export kb_layout="sv-latin1"
export root_password=""
export username=""
export user_password=""
export locale="en_US"
export timezone="Europe/Stockholm"

# Check if system is being installed to the correct disk
lsblk -o NAME,FSTYPE,LABEL,MOUNTPOINTS /dev/disk/by-id/nvme-eui.00000000000000000026b7686581b745
read -p "Press ENTER to install to above disk or CTRL+C to abort." key

# Set keyboard layout
loadkeys ${kb_layout}

# Connect to wifi
iwctl --passphrase ${wifi_password} station wlan0 connect ${wifi_ssid}
read -p "Connecting to internet...."$'\n' -t 5

#Sync time
hwclock --systohc --utc
timedatectl set-ntp true
sleep 5

# Partition the disk
sgdisk -Z /dev/disk/by-id/nvme-eui.00000000000000000026b7686581b745
sgdisk -n 1:0:+512MiB -t 1:ef00 -c 1:"EFI System Partition" /dev/disk/by-id/nvme-eui.00000000000000000026b7686581b745
sgdisk -n 2:0:0 -t 2:8300 -c 2:"Linux" /dev/disk/by-id/nvme-eui.00000000000000000026b7686581b745
mkfs.fat -n ESP -F 32 /dev/disk/by-id/nvme-eui.00000000000000000026b7686581b745-part1
mkfs.xfs -f -L ArchLinux /dev/disk/by-id/nvme-eui.00000000000000000026b7686581b745-part2

# Mount partitions
mount /dev/disk/by-id/nvme-eui.00000000000000000026b7686581b745-part2 /mnt
mount --mkdir /dev/disk/by-id/nvme-eui.00000000000000000026b7686581b745-part1 /mnt/boot

# Pacstrap
reflector --country Sweden --latest 5 --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
read -p "Generating pacman mirrorlist...."$'\n' -t 30
pacman -Sy --noconfirm archlinux-keyring
pacstrap /mnt base linux linux-firmware

# Continue in chroot
cp arch-chroot.sh /mnt
arch-chroot /mnt /arch-chroot.sh
