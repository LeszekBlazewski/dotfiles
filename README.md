# dotfiles

Dotfiles for various themes mostly gathered from others :D

## i3-nord

https://www.reddit.com/r/unixporn/comments/f3tnh0/i3gaps_nord/

Screenshot:

![screenshot](/i3-nord/i3-nord.png)

Components:

- polybar
- compton-rounded-corners
- vs code nordic theme
- powerline10k
- kitty
- rofi
- [spicetify](https://github.com/khanhas/spicetify-cli)
- [spicetify-themes](https://github.com/morpheusthewhite/spicetify-themes)
- [multilockscreen](https://github.com/jeffmhubbard/multilockscreen)

## i3-orange

Components:

- polybar
- rofi
- kitty
- [zsh bubbly](https://github.com/hohmannr/bubblified)
- [multilockscreen](https://github.com/jeffmhubbard/multilockscreen)

Problems:

- Kitty terminal sucks for SSH
- This ZSH theme does not work with visual studio code

![screenshot](/i3-orange/arch-i3.png)

<h2 align="center">
  <br>
  <img src="logo.svg" alt="Archlinux" width="320">
  <br>
Arch Linux Installer
</h2>

<h4 align="center">Install your Arch Linux more quickly</h4>

<p align="center">
  <a href="#feature">Features</a> •
  <a href="#how-to-use">How To Use</a>
</p>

## Features

- Pseudo interface, more friendly than pure command line.
- Support BIOS and UEFI boot mode
- Automatically detect Windows startup option
- Allows to automaticaly install && configure from backup user packages after system configuration.

## How To Use

First, you need to prepare an Arch Linux LiveUSB and connect to the internet.

Use this Installer in order to get minimal arch setup

```bash
bash <(curl https://raw.githubusercontent.com/beard/dotfiles/master/install-arch.sh)
```

Set keyboard layout to pl

Set locale as en_DK.UTF-8 UTF-8

Set timezone as warsaw

After that your pc will be rebooted and you can use `install-i3.sh` to get a fully working i3 setup.

```bash
bash <(curl https://raw.githubusercontent.com/beard/dotfiles/master/install-i3.sh)
```
