#! /bin/bash

# Auto login
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/test.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin desmond %I $TERM
EOF

# Enable FS Trim
sudo systemctl enable fstrim.timer

# Install Paru
git clone https://aur.archlinux.org/paru-bin.git ~/paru-bin/
cd ~/paru-bin/ && makepkg -rsi --noconfirm
cd ~ && rm -Rf ~/paru-bin/

## Hyprland
# Config
cp -r ~/postconfig/hypr ~/.config/

# Autostart
cat <<'EOF' > ~/.zlogin
if [ "$(tty)" = "/dev/tty1" ];then
  dbus-launch --exit-with-session Hyprland
fi
EOF

## Hyprpanel
# Dependencies
sudo pacman -S --noconfirm --needed pipewire libgtop bluez bluez-utils btop networkmanager dart-sass wl-clipboard brightnessctl swww python gnome-bluetooth-3.0 pacman-contrib power-profiles-daemon
paru -S grimblast-git gpu-screen-recorder hyprpicker matugen-bin python-gpustat aylurs-gtk-shell-git

# Bun
curl -fsSL https://bun.sh/install | bash && \
  sudo ln -s $HOME/.bun/bin/bun /usr/local/bin/bun

bun install -g sass

# Installs HyprPanel to ~/.config/ags
git clone https://github.com/Jas-SinghFSU/HyprPanel.git ~/.HyprPanel
ln -s ~/.HyprPanel ~/.config/ags

## Shell
# Zhs shell
sudo pacman -S --noconfirm --needed zsh zsh-completions

# Zhs save history
cat <<'EOF' >> ~/.zshrc
HISTFILE=~/.zsh_history # location of the history file
HISTFILESIZE=1000 # history limit of the file on disk
HISTSIZE=1000 # current session's history limit
SAVEHIST=1000 # zsh saves this many lines from the in-memory history list to the history file upon shell exit
HISTTIMEFORMAT="%d/%m/%Y %H:%M] "

setopt extended_history hist_expire_dups_first hist_ignore_dups hist_ignore_all_dups hist_find_no_dups hist_save_no_dups hist_ignore_space hist_verify share_history inc_append_history
EOF

# Starship shell prompt
sudo pacman -S --noconfirm --needed starship
cp ~/postconfig/starship/starship.toml ~/.config/
echo eval "$(starship init zsh)" >> ~/.zshrc

# Make Zsh default shell
chsh -s /bin/zsh

## Themes
# Papirus icons
mkdir -p ~/.local/share/icons/
wget -qO- https://git.io/papirus-icon-theme-install | DESTDIR="$HOME/.local/share/icons" sh
wget -qO- https://git.io/papirus-folders-install | sh
papirus-folders -C blue --theme Papirus
gsettings set org.gnome.desktop.interface icon-theme Papirus

# Breeze cursor
unzip ~/postconfig/cursors/BreezeX-Amber.zip -d ~/.local/share/icons/
unzip ~/postconfig/cursors/BreezeX-Amber-Hyprcursor.zip -d ~/.local/share/icons/

# Dark mode
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

# Rofi themes
git clone --depth=1 https://github.com/adi1090x/rofi.git ~/postconfig/rofi
chmod +x ~/postconfig/rofi/setup.sh
cd ~/postconfig/rofi/
./setup.sh
sed -i '15s/style-1/style-5/' ~/.config/rofi/launchers/type-1/launcher.sh

# Copy images
cp ~/postconfig/images/* ~/Pictures

## Misc
# Nemo default terminal
gsettings set org.cinnamon.desktop.default-applications.terminal exec kitty

# Hide apps from menu/search
mkdir -p ~/.local/share/applications/

cp /usr/share/applications/avahi-discover.desktop ~/.local/share/applications/
echo NoDisplay=true >> ~/.local/share/applications/avahi-discover.desktop

cp /usr/share/applications/bssh.desktop ~/.local/share/applications/
echo NoDisplay=true >> ~/.local/share/applications/bssh.desktop

cp /usr/share/applications/btop.desktop ~/.local/share/applications/
echo NoDisplay=true >> ~/.local/share/applications/btop.desktop

cp /usr/share/applications/bvnc.desktop ~/.local/share/applications/
echo NoDisplay=true >> ~/.local/share/applications/bvnc.desktop

cp /usr/share/applications/cmake-gui.desktop ~/.local/share/applications/
echo NoDisplay=true >> ~/.local/share/applications/cmake-gui.desktop

cp /usr/share/applications/nm-connection-editor.desktop ~/.local/share/applications/
echo NoDisplay=true >> ~/.local/share/applications/nm-connection-editor.desktop

cp /usr/share/applications/rofi.desktop ~/.local/share/applications/
echo NoDisplay=true >> ~/.local/share/applications/rofi.desktop

cp /usr/share/applications/rofi-theme-selector.desktop ~/.local/share/applications/
echo NoDisplay=true >> ~/.local/share/applications/rofi-theme-selector.desktop

cp /usr/share/applications/qv4l2.desktop ~/.local/share/applications/
echo NoDisplay=true >> ~/.local/share/applications/qv4l2.desktop

cp /usr/share/applications/qvidcap.desktop ~/.local/share/applications/
echo NoDisplay=true >> ~/.local/share/applications/qvidcap.desktop

cp /usr/share/applications/cmake-gui.desktop ~/.local/share/applications/
echo NoDisplay=true >> ~/.local/share/applications/cmake-gui.desktop

cp /usr/share/applications/mpv.desktop ~/.local/share/applications/
echo NoDisplay=true >> ~/.local/share/applications/mpv.desktop

# Pipewire
systemctl --user enable --now pipewire.socket
systemctl --user enable --now pipewire-pulse.socket
systemctl --user enable --now wireplumber.service

# Copy Yazi config
cp -r ~/postconfig/yazi ~/.config/

# SwayOSD
paru -S swayosd-git
sudo systemctl enable --now swayosd-libinput-backend.service

# Install packages from AUR
paru -S hyprshot sublime-text-4 bashmount zen-browser-avx2-bin