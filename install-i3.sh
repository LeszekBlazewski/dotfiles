#!/bin/env bash

## author: beard
##
## use this script to install fully working i3-gaps arch linux
## This script does not only installs window manager, but also sound settings, bluetooth etc.
## use sudo bash <(curl https://raw.githubusercontent.com/beard/dotfiles/master/install-i3.sh)
## Run this script as root!
## When running this script with sudo, all standard commands are executed as root and those with
## sudo -u $real_user are run with current user privileges

set -euo pipefail

# ref: https://askubuntu.com/questions/425754/how-do-i-run-a-sudo-command-inside-a-script
if ! [ $(id -u) = 0 ]; then
   echo "The script needs to bu run with sudo." >&2
   exit 1
fi

if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi

# update packages list
pacman --noconfirm -Syyu

#  install git
pacman --noconfirm --needed -S git

# install yay
sudo -u $real_user git clone https://aur.archlinux.org/yay-git.git
cd yay-git
sudo -u $real_user makepkg -si --rmdeps --noconfirm --needed
cd /home/$real_user
sudo -u $real_user rm -rf yay-git

# clone dotefiles repo
sudo -u $real_user git clone https://github.com/LeszekBlazewski/dotfiles.git
cd dotfiles

# install all of the packages from i3-purple setup
sudo -u $real_user yay -S --needed --noconfirm - < pkglist.txt
sudo -u $real_user yay --clean --noconfirm

# enable lightdm
systemctl enable lightdm

# enable bluetooth deamon
systemctl enable bluetooth.service

# set npt
timedatectl set-ntp true

# i3-purple
cd i3-purple

# copy and enable lightdm theme
cp -r themes/.themes/Dracula /usr/share/themes
cp -r icons/.icons/Dracula /usr/share/icons
mkdir -p /usr/share/wallpapers
cp wallpaper/.config/wallpaper/wallpaper.jpg /usr/share/wallpapers
sed -i 's|#background=|background=/usr/share/wallpapers/wallpaper.jpg|' /etc/lightdm/lightdm-gtk-greeter.conf
sed -i 's|#theme-name=|theme-name=Dracula|' /etc/lightdm/lightdm-gtk-greeter.conf
sed -i 's|#icon-theme-name=|icon-theme-name=Dracula|' /etc/lightdm/lightdm-gtk-greeter.conf
sed -i 's/Inherits=Adwaita/Inherits=Breeze_Purple/' /usr/share/icons/default/index.theme

# create python environment for i3scripts and install the dependencies
sudo -u $real_user python3 -m venv i3-gaps/.config/i3/i3scripts/venv
sudo -u $real_user i3-gaps/.config/i3/i3scripts/venv/bin/pip install -r i3-gaps/.config/i3/i3scripts/requirements.txt

# remove default profiles
sudo -u $real_user rm -f /home/$real_user/.bashrc /home/$real_user/.bash_profile

# symlink the dotfiles to home folder
# you can also stow individual app by running stow folder_name
sudo -u $real_user stow * -t ../.. --adopt

# copy and enable grub theme
# if you see many pci AER errors in dmesg or journalctl when using system
# add pci=noaer parameter to GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub
cp -r grub/.config/grub/themes/liquid-amethyst /boot/grub/themes/liquid-amethyst
sed -i 's|#GRUB_THEME="/path/to/gfxtheme"|GRUB_THEME="/boot/grub/themes/liquid-amethyst/theme.txt"|' /etc/default/grub
sed -i 's/GRUB_GFXMODE=auto/GRUB_GFXMODE=1920x1080/'   /etc/default/grub
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# load gnome dconf settings
sudo -u $real_user dbus-launch dconf load / < dconf/.config/dconf/dconf.ini

# set betterlockscreen image
sudo -u $real_user betterlockscreen -u ./wallpaper/.config/wallpaper/liquid-amethyst-lock.jpg

echo "Customization complete! Automatic reboot in 2 seconds"
sleep 2 && reboot
