#!/bin/env bash

## author: beard
##
## use this script to install fully working i3-gaps arch linux
## This script does not only installs window manager, but also sound settings, bluetooth etc.
## use bash <(curl https://raw.githubusercontent.com/beard/dotfiles/master/install-i3.sh)

# update packages list
pacman -Syyu

#  install git
pacman --noconfirm -S git

# install yay
git clone https://aur.archlinux.org/yay-git.git
cd yay-git
makepkg -si
cd ..
rm -r yay-git

# clone dotefiles repo
git clone https://github.com/LeszekBlazewski/dotfiles.git
cd dotfiles/i3-purple

# install all of the packages from i3-purple setup
yay -S --needed --noconfirm - < pkglist.txt

# enable lightdm
systemctl enable lightdm

# set Xorg keyboard layout
sudo localectl set-x11-keymap pl

# symlink the dotfiles to home folder
stow * -t ../.. --adopt

# copy and enable grub theme
ln -s i3-purple/grub.config/grub/themes/liquid-amethyst /boot/grub/themes/liquid-amethyst
sudo sed -i 's|#GRUB_THEME=|GRUB_THEME="/boot/grub/themes/liquid-amethyst/theme.txt"|' /etc/default/grub
sudo sed -i 's/#GRUB_GFXMODE=/GRUB_GFXMODE=1920x1080/'   /etc/default/grub

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
