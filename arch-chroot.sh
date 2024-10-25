#! /bin/bash

# Hostname and time
echo "NUC12SNKi72" > /etc/hostname
ln -s /usr/share/zoneinfo/${timezone} /etc/localtime
hwclock --systohc --utc

# Locale
echo "${locale}.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=${locale}.UTF-8" > /etc/locale.conf
echo "KEYMAP=${kb_layout}" > /etc/vconsole.conf

# User config
echo "root:${root_password}" | chpasswd
useradd -m -G wheel ${username}
echo "${username}:${user_password}" | chpasswd

# Enable sudo
pacman -Sy --noconfirm sudo
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/99_wheel

# Create fstab
UEFI_UUID=$(blkid -s UUID -o value /dev/disk/by-id/nvme-eui.00000000000000000026b7686581b745-part1)
ROOT_UUID=$(blkid -s UUID -o value /dev/disk/by-id/nvme-eui.00000000000000000026b7686581b745-part2)
cat << EOF >> /etc/fstab
UUID=${ROOT_UUID} / xfs defaults 0 1
UUID=${UEFI_UUID} /boot vfat defaults,noatime 0 2
EOF

# Swapfile
fallocate -l 4G /swapfile
chmod 0600 /swapfile
mkswap /swapfile
swapon /swapfile
cat << EOF >> /etc/fstab
/swapfile none swap sw 0 0
EOF

# EFI stub booting
mount -t efivarfs efivarfs /sys/firmware/efi/efivars
pacman -S --noconfirm efibootmgr
efibootmgr -d /dev/disk/by-id/nvme-eui.00000000000000000026b7686581b745 -p 1 -c -L "Arch Linux" -l /vmlinuz-linux -u "root=/dev/disk/by-id/nvme-eui.00000000000000000026b7686581b745-part2 rw initrd=\intel-ucode.img initrd=\initramfs-linux.img"

# Development tools
pacman -S --noconfirm --needed base-devel git

# Essential packages and useful tools
pacman -S --noconfirm --needed intel-ucode ntfs-3g intel-media-driver nano mlocate tree wget git polkit gvfs unzip unrar p7zip fd yazi power-profiles-daemon

# GPU
pacman -S --noconfirm --needed mesa vulkan-intel

# Wayland
pacman -S --noconfirm --needed wayland xorg-xwayland xorg-xlsclients glfw-wayland

# Sound
pacman -S --noconfirm --needed pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack wireplumber pamixer playerctl

# Install fonts
pacman -S --noconfirm --needed ttf-roboto noto-fonts noto-fonts-emoji noto-fonts-cjk noto-fonts-extra ttf-jetbrains-mono-nerd

# Multimedia
pacman -S --noconfirm --needed ffmpeg mpv cmus
pacman -S --noconfirm --needed gstreamer gst-libav gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly

# Wayland
pacman -S --noconfirm --needed wayland-protocols wayland-utils wlroots

# Hyprland
pacman -S --noconfirm --needed hyprland hyprcursor hypridle hyprlock hyprutils rofi-wayland grim slurp wl-clipboard libnotify nwg-look kitty polkit-gnome

# Gnome applications
pacman -S --noconfirm --needed gnome-characters gnome-disk-utility gnome-logs gnome-system-monitor gnome-themes-extra loupe dconf gsettings-desktop-schemas gsettings-system-schemas adwaita-icon-theme

# Nemo
pacman -S --noconfirm --needed nemo nemo-audio-tab nemo-fileroller nemo-image-converter nemo-preview

# XDG
pacman -S --noconfirm --needed xdg-utils xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-user-dirs
#xdg-desktop-portal-kde

# QT / KDE
pacman -S --noconfirm --needed qt5-wayland qt6-wayland qt6ct breeze-icons

# Software
pacman -S --noconfirm --needed font-manager pinta qbittorrent yazi gnumeric

# Enable NetworkManager and use iwd backend
pacman -S --noconfirm --needed iwd networkmanager network-manager-applet
cat << EOF >> /etc/NetworkManager/NetworkManager.conf
[device]
wifi.backend=iwd
wifi.iwd.autoconnect=yes
EOF
systemctl enable NetworkManager.service

# Acpid
pacman -S --noconfirm --needed acpid
systemctl enable acpid

# Enable pacman colors
sed -i '/Color/s/^#//g' /etc/pacman.conf

# Self delete & exit
rm arch-chroot.sh && exit 0
