# Arch Linux Hyprland installation script

Just a noob installation script to install Arch Linux and the Hyrpland Wayland compositor with Hyrpanel.
The script is fully automatic, it also wipes partitions but will show which partitions will be wiped and ask you to confirm before it continues.
After install you will have a running system with Hyprland as your compositor, Hyrpanel as your panel, Rofi application launcher etc etc.

Automatic login is enabled.
There is no need for a display manager, if you need to password protect your system you can make it boot into hyprlock by uncommenting this line in your hyrpland config: exec-once = hyprlock || hyprctl dispatch exit

Use this script as an example to make your own script or edit it for your needs and run it.

Replace all disk id (nvme-eui) with the one of your disk. To find disk id look here: https://wiki.archlinux.org/title/persistent_block_device_naming#World_Wide_Name

Example how to use this script:

Boot into Arch ISO from Ventoy or extract it to the root of USB drive and boot it.
Type lsblk -f to list your paritions.
Type mkdir ntfs.
Type mount -t ntfs /dev/pathtopartition (for sata disks it is something like /dev/sda3 and for nvme /dev/nvme1n1p3.
Cd into the ntfs dir and the folder where you saved this script.
Type sh arch_install.sh

After install is completed copy the sysconfig folder to user home dir on the arch partition.
For example cp -rp postconfig /mnt/home/desmond

After reboot login to your account and cd into the postconfig folder and run config script to do post install.
After it has completed delete the postconfig folder and reboot.
