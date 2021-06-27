#!/bin/env bash

## author: beard
##
## use this script to install fully working i3-gaps arch linux
## This script does not only installs window manager, but also sound settings, bluetooth etc.
## use bash <(curl https://raw.githubusercontent.com/beard/dotfiles/master/install-i3.sh)

set -euo pipefail

# update packages list
pacman -Syyu

#  install git
pacman --noconfirm -S git

# install yay
git clone https://aur.archlinux.org/yay-git.git
cd yay-git
makepkg -si
cd $HOME
rm -r yay-git

# clone dotefiles repo
git clone https://github.com/LeszekBlazewski/dotfiles.git
cd dotfiles/i3-purple

# install all of the packages from i3-purple setup
yay -S --needed --noconfirm - < pkglist.txt

# enable lightdm and gnome-keyring in it
systemctl enable lightdm
sudo sed -i 's/-auth/auth/' /etc/pam.d/lightdm
sudo sed -i 's/-session/session/' /etc/pam.d/lightdm

# enable bluetooth deamon
systemctl enable bluetooth.service

# symlink the dotfiles to home folder
stow * -t ../.. --adopt

# copy and enable grub theme
cp -a grub.config/grub/themes/liquid-amethyst /boot/grub/themes/liquid-amethyst
sudo sed -i 's|#GRUB_THEME=|GRUB_THEME="/boot/grub/themes/liquid-amethyst/theme.txt"|' /etc/default/grub
sudo sed -i 's/#GRUB_GFXMODE=/GRUB_GFXMODE=1920x1080/'   /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# copy and enable lightdm theme
sudo cp -a themes/.themes/Dracula /usr/share/themes
sudo cp -a icons/.icons/Dracula /usr/share/icons
sudo cp -a wallpaper/.config/wallpaper/wallpaper.jpg /usr/share/wallpapers
sudo sed -i 's|#background=|background=/usr/share/wallpapers/wallpaper.jpg|' /etc/lightdm/lightdm-gtk-greeter.conf
sudo sed -i 's|#theme-name=|theme-name=Dracula|' /etc/lightdm/lightdm-gtk-greeter.conf
sudo sed -i 's|#icon-theme-name=|icon-theme-name=Dracula|' /etc/lightdm/lightdm-gtk-greeter.conf

# open terminal in nautilius
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal kitty

cd $HOME

# configure light module to adjust brightness
git clone https://github.com/haikarainen/light.git
cd light
./autogen.sh
./configure --with-udev && make
sudo make install
cd $HOME
rm -r light

echo "Customization complete! Automatic reboot in 2 seconds"
sleep 2 && reboot
