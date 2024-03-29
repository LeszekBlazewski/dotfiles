#!/bin/env bash

## author: si9ma
## modified by beard
##
## use this script to install smallest archlinux
##

#  log
exec 2> >(tee -a "installer.log")

HEADER="Archlinux Installer"
CHROOT="arch-chroot /mnt"
EXIT_MSG="You have left from Archlinux Installer!" 

### 1.Verify the boot mode

# if `sys/firware/efi/efivars` directory exist, the 
# boot mode is UEFI. otherwise,the boot mode is BIOS
if [ -d "/sys/firmware/efi/efivars" ]
then
    BOOT_MODE="UEFI"
else
    BOOT_MODE="BIOS"
fi


### 2.Update the system clock
timedatectl set-ntp true


### 3.Check the network connection
echo "Checking network connection."
echo "Please wait..."
ping archlinux.org -c 1 >/dev/null 2>&1

if [ $? != "0" ]
then
    echo "Network error, please check network connection"
    echo "exiting..."
    exit
fi


# synchronize pacman database and install dialog
pacman --noconfirm --needed -Sy dialog

### 4.Keymap selection

# window
title="Keymap Selection"
msg="The default console keymap is US. Would you want to set a \
non-default keymap for your keyboard?  [ESC] to exit installer\n\nPlease confirm before typing the [ENTER], because you can't undo it."
dialog --ascii-lines --default-button "No" --title "$title" --backtitle "$HEADER" --yesno "$msg" 10 45

# never add a command between command `dialog -ascii-lines...` and command retval_out=$?
retval_out=$?
echo

case $retval_out in
    # 0) Yes -- reset keymap
        0)

        # get all keymap
        function list_all_keymap
        {
            for keymap in $(find /usr/share/kbd/keymaps/ -name "*.map.gz") # should enclose the pattern in quotes
            do
                # get basename
                file=${keymap##*/}
                printf "${file%%.*} ...... "
            done
        }

        # window
        title="Keymap Selection"
        backtitle="Archlinux Installer"
        msg="The default console keymap is US.Other keymaps can be chosen below.\
        \n\n[Arrow keys] to move,[ENTER] to select.	[ESC] to exit installer\n\nPlease confirm before typing the [ENTER], because you can't undo it."
        keymap_list="US default $(list_all_keymap)"

        dialog --no-cancel --ascii-lines --ok-label "Select" --title "$title" \
            --backtitle "$HEADER" --menu "$msg" 18 59 18 $keymap_list 2>tempfile

        retval_inner=$?
        echo
        case $retval_inner in
            0) # Yes
                choice=$(cat tempfile)

                #reset keymap temporary
                if [ "$choice" != "US" ]
                then
                    loadkeys "$choice"
                    KEY_MAP="$choice"
                else
                    loadkeys us
                    KEY_MAP="us"
                fi
                ;;
            255) # ESC
                echo $EXIT_MSG
                exit 255
                ;;
        esac
        ;;

    # 255) ESC -- exit the installer
        255)
        echo $EXIT_MSG
        exit 255
        ;;
esac

### 5.Partition the disks

# window
title="Partition the disks"
msg="Before you install Archlinux, you need to partition your hard disk.\n\n[ESC] to exit installer"
dialog --no-cancel --ascii-lines --title "$title" --backtitle "$HEADER" --msgbox "$msg" 9 45

retval=$?
echo

case $retval in
    # 0) Yes -- partition the disks
        0)
        # if the boot mode is uefi,we should create a efi system partition
        if [ "$BOOT_MODE" = "UEFI" ]
        then
            #window
            title="Partition the disks"
            msg="Hey! Your boot mode is UEFI, so you must create an ESP partition \
(EFI system partition). If, \n\n(1)You have installed Windows on your computer, and its boot \
mode is also UEFI, if so, you will see a partition of about 200MiB later. You should not delete \
it or format it, you will use it as your ESP.\n\n(2)You don't have an ESP partition on your computer.\
You need to create an ESP partition of about 200MiB.
\n\nRember, you must ensure that there are one \
and just only one ESP on your disks.\n\n[ESC] to exit the installer"
            dialog --ok-button "I Know" --ascii-lines --title "$title" --backtitle "$HEADER" --msgbox "$msg" 18 70

            retval=$?
            case $retval in
                255) #ESC,exit
                    echo 
                    echo $EXIT_MSG
                    exit 255
                    ;;
            esac
        else
            #window
            title="Partition the disks"
            msg="Hey! Your boot mode is Bios. In order to ensure everything goes well, I think you should ensure your disk is MBR(dos) partition structures\n\n\n[ESC] to exit the installer." 
            dialog --ok-button "I Know" --ascii-lines --title "$title" --backtitle "$HEADER" --msgbox "$msg" 18 70

            retval=$?
            case $retval in
                255) #ESC,exit
                    echo 
                    echo $EXIT_MSG
                    exit 255
                    ;;
            esac
        fi

        # windows
        title="Partition the disks"
        msg="Please select the disk you want to partition. Select nothing to skip.	[ESC] to exit the installer\n\nPlease confirm before typing the [ENTER], because you can't undo it."
        disk_list="$(fdisk -l | grep "Disk /dev/" | cut -d "," -f 1)"
        disk_list="${disk_list//Disk /}" # remove Disk
        disk_list="${disk_list// /}"
        disk_list="${disk_list//:/ }"
        disk_list=$(echo $disk_list | xargs)

        ## default to OFF
        count=0
        judge=0
        temp=
        for disk in $disk_list
        do
            count=$[ $count + 1 ]
            judge=$[ $count % 2 ]

            if [ "$judge" = "0" ]
            then
                # set /dev/sda default to ON
                if [ "$disk_temp" = "/dev/sda" ]
                then
                    temp="$temp $disk ON" 
                elif [[ "$disk_temp" = /dev/loop* ]] 
                then
                    continue # ignore /dev/loop*
                else
                    temp="$temp $disk OFF" 
                fi
            else
                if [[ "$disk" = /dev/loop* ]]
                then
                    disk_temp=$disk # ignore /dev/loop*
                else
                    temp="$temp $disk"
                    disk_temp=$disk
                fi
            fi
        done
        disk_list=$temp
        temp=

        dialog --no-cancel --ascii-lines --title "$title" --backtitle "$HEADER" --checklist "$msg" 18 65 18 $disk_list 2>tempfile

        retval=$?
        choice=$(cat tempfile)

        # if ESC,exit
        case $retval in 
            255) # ESC
                echo
                echo $EXIT_MSG
                exit 255
                ;;
        esac

        # use cfdisk to partition disks
        for disk in $choice
        do
            cfdisk $disk
        done

        # info disk table change
        partprobe

        ;;

    ## 255) ESE -- exit the installer
        255)
        echo $EXIT_MSG
        exit 255
        ;;
esac


### 6.Mount the file systems

# firstly,unmount all partition have mounted at /mnt
# swapoff
swap=$(swapon --show | tail -1 | cut -d " " -f 1)
[ -z "$swap" ] || swapoff "$swap"

umount -R /mnt

# select the mount point which you want mount as separated partition
title="Mount the file systems"

# if the boot mode is BIOS,we shouldn't create a separated partition for /boot
if [ "$BOOT_MODE" = "BIOS" ]
then
    msg="Select the mount point which you want mount as separated partition.	[ESC] to exit the installer\n\nPlease confirm before typing the [ENTER], because you can't undo it."
    dialog --no-cancel --ok-label "Continue" --ascii-lines --title "$title" --backtitle "$HEADER" --checklist "$msg" 18 75 18 \
        "/" "Entire system's root directory" "ON"\
        "/boot" "Boot loader files" "OFF"\
        "/bin" "Essential command binaries" "OFF"\
        "/home" "Users' home directories" "OFF"\
        "/var" "Variable files" "OFF"\
        "/etc" "Host-specific system-wide configuration files" "OFF"\
        "/lib" "Libraries essential for the binaries in /bin/ and /sbin/" "OFF"\
        "/opt" "Optional application software packages" "OFF"\
        "/usr" "Secondary hierarchy for read-only user data" "OFF"\
        "/run" "Run-time variable data" "OFF"\
        "swap" "swap partition" "OFF" 2>tempfile
else
    msg="Select the mount point which you want mount as separated partition. Your boot mode is UEFI,so \"/\" and \"/boot\" must be selected.		[ESC] to exit the installer\n\nPlease confirm before typing the [ENTER], because you can't undo it."
    dialog --no-cancel --ok-label "Continue" --ascii-lines --title "$title" --backtitle "$HEADER" --checklist "$msg" 18 75 18 \
        "/" "Entire system's root directory" "ON"\
        "/boot" "Boot loader files" "ON"\
        "/home" "Users' home directories" "OFF"\
        "swap" "swap partition" "OFF"\
        "/bin" "Essential command binaries" "OFF"\
        "/var" "Variable files" "OFF"\
        "/etc" "Host-specific system-wide configuration files" "OFF"\
        "/lib" "Libraries essential for the binaries in /bin/ and /sbin/" "OFF"\
        "/opt" "Optional application software packages" "OFF"\
        "/usr" "Secondary hierarchy for read-only user data" "OFF"\
        "/run" "Run-time variable data" "OFF" 2>tempfile
fi

retval=$?
choice=$(cat tempfile)

case $retval in 
    0) # continue
        # usable partition
        partition_list=$(fdisk -l -o Device | grep -P "^/dev/[a-z]+[0-9]+")

        # format partition and mount to suitable mount point use for loop
        for mount_point in $choice
        do

            # window
            title="Mount for $mount_point"
            msg="Please select a partition for $mount_point. the second column is partition info, format is:\n   [Current File System]/[Size]-->[File System Will Be Format To]\n\n[ESC] to exit the installer\n\nPlease confirm before typing the [ENTER], because you can't undo it."

            # for swap partition
            if [ "$mount_point" = "swap" ]
            then
                title="Create swap partition"
                msg="Please select a partition as swap partition. the second column is partition info, format is:\n     [File System]/[Size]\n\nOR,you may be want to use a swap file but not a swap partition. if so,please select \"swapfile\".\n\n[ESC] to exit the installer\n\nPlease confirm before typing the [ENTER], because you can't undo it."
            fi

            # reset mount_point_list
            available_partition_list=
            info=
            for partition in $partition_list
            do
                # partition info
                info=$(df $partition -T -h | tail -1 | tr -s " " | cut -d " " -f 2)
                size=$(lsblk | grep "${partition/\/dev\//}" | head -1 | tr -s " " | cut -d " " -f 4)
                info="$info/$size"

                # will how to format file system
                if [ "$mount_point" = "/boot" ]
                then
                    info=${info}--">"vfat
                    available_partition_list="${available_partition_list} $partition(vfat) $info "
                elif [ "$mount_point" = "swap" ]
                then
                    available_partition_list="${available_partition_list} $partition $info"
                else
                    format_list="ext4" 
                    for format in $format_list
                    do
                        info_1=${info}--">"$format
                        available_partition_list="${available_partition_list} $partition($format) $info_1 "
                    done
                fi
            done

            # for swap file
            if [ "$mount_point" = "swap" ]
            then
                available_partition_list="${available_partition_list} swapfile swapfile"
            fi


            dialog --no-cancel --ok-button "Select" --ascii-lines --title "$title" --backtitle "$HEADER" --menu "$msg" 18 75 18 $available_partition_list 2>tempfile

            retval_1=$?
            selected_partition=$(cat tempfile)
            format=$(echo $selected_partition | cut -d "(" -f 2 | cut -d ")" -f 1 )
            selected_partition=${selected_partition%%(*}

            # get the disk name / on
            if [ "$mount_point" = "/" ]
            then
                # / on which disk 
                ROOT_DISK=$(echo $selected_partition | sed 's/[0-9]//g')
            fi

            # if ESC,exit
            case $retval_1 in
                255) # ESC
                    echo 
                    echo $EXIT_MSG
                    exit 255
                    ;;
            esac

            # for swap partition
            if [ "$mount_point" = "swap" ]
            then
                # create swap file
                if [ "$selected_partition" = "swapfile" ]
                then
                    title="Create swap file"
                    msg="Please input the size(MB) of swap file.	[ESC] to exit installer\n\nPlease confirm before typing the [ENTER], because you can't undo it."
                    dialog --ascii-lines --no-cancel --title "$title" --backtitle "$HEADER" --inputbox "$msg" 10 50 512 2>tempfile

                    retval_2=$?
                    size=$(cat tempfile)

                    case $retval_2 in
                        0) # create swap file
                            dd if=/dev/zero of=/mnt/swap bs=1M count=$size
                            mkswap /mnt/swap >/dev/null 2>&1
                            swapon /mnt/swap >/dev/null 2>&1
                            ;;
                        255) # ESC
                            echo
                            echo $EXIT_MSG
                            exit 255
                            ;;
                    esac
                else
                    mkswap $selected_partition >/dev/null 2>&1
                    swapon $selected_partition >/dev/null 2>&1
                fi

                # next mount point
                continue
            fi

            # format the partition
            # you may don't want't to format ESP
            if [ "$mount_point" = "/boot" ]
            then
                title="Mount for /boot -- Confirm ?"
                msg="$selected_partition may be already a ESP, so you may don't want to format it. Do you want to format it?    [ESC] to exit installer\n\nPlease confirm before typing the [ENTER], because you can't undo it."
                dialog --ascii-lines --default-button "Yes" --title "$title" --backtitle "$HEADER" --yesno "$msg" 10 45

                retval_3=$?
                echo

                case $retval_3 in
                        0)
                        mkfs.$format $selected_partition >/dev/null 2>&1
                        ;;

                    255) # ESC
                        echo $EXIT_MSG
                        exit 255
                        ;;
                esac

            else
                mkfs.$format $selected_partition >/dev/null 2>&1
            fi

            # mount the partition
            echo
            mkdir -p /mnt$mount_point

            # firstly, try to umount the partition
            # umount -l $selected_partition >/dev/null 2>&1 | true
            mount $selected_partition /mnt$mount_point

            # delete selected partition from partition list
            for partition in $partition_list
            do
                if [ "$partition" != "$selected_partition" ]
                then
                    temp="$temp $partition"
                fi
            done
            partition_list=$temp
            # reset temp
            temp=
        done
        ;;

    255) #ESC
        echo $EXIT_MSG
        exit 255
        ;;
esac

### 7.Install the base and base-devel packages
echo

pacstrap /mnt base linux linux-firmware base-devel

# if error
if [ "$?" != "0" ]
then
    pacstrap -i /mnt base linux linux-firmware base-devel
fi


### 8.Configure the system

## Fstab
genfstab -U /mnt >> /mnt/etc/fstab

# clear
temp=

## Time zone

# region
title="Time Zone"
msg="Please Select the region.		[ESC] to exit the installer\n\nPlease confirm before typing the [ENTER], because you can't undo it."
region_list=$(timedatectl list-timezones | cut -d "/" -f 1 | sort -u | xargs)

# duplicate
for region in $region_list
do
    temp="${temp} $region $region"
done
region_list=$temp
temp=

dialog --no-cancel --ok-button "Select" --ascii-lines --title "$title" --backtitle "$HEADER" --menu "$msg" 18 59 18 $region_list 2>tempfile

retval=$?
choice=$(cat tempfile)
region=$choice

# if ESC,exit
case $retval in
    255)
        echo
        echo $EXIT_MSG
        exit 255
        ;;
esac

if [ "$choice" = "UTC" ]
then
    $CHROOT ln -sf /usr/share/zoneinfo/UTC /etc/localtime
    $CHROOT hwclock --systohc
else
    # city
    title="Time Zone"
    msg="Please Select the city.		[ESC] to exit the installer\n\nPlease confirm before typing the [ENTER], because you can't undo it."
    city_list=$(timedatectl list-timezones | grep $choice | cut -d "/" -f 2 | sort -u | xargs)

    # duplicate
    for city in $city_list
    do
        temp="${temp} $city $city"
    done
    city_list=$temp
    temp=

    dialog --no-cancel --ok-button "Select" --ascii-lines --title "$title" --backtitle "$HEADER" --menu "$msg" 18 60 18 $city_list 2>tempfile

    retval=$?
    choice=$(cat tempfile)
    city=$choice

    # if ESC,exit
    case $retval in
        255)
            echo
            echo $EXIT_MSG
            exit 255
            ;;
    esac

    $CHROOT ln -sf /usr/share/zoneinfo/$region/$city /etc/localtime
    $CHROOT hwclock --systohc
fi

## Locale

# function 
function get_locale_list # from /etc/locale.gen
{
    # skip the file header
    first_usable_line=$($CHROOT grep -n "#aa" /etc/locale.gen | head -1 | cut -d ":" -f 1)
    line_amount=$($CHROOT cat /etc/locale.gen | wc -l)
    # line will be used later
    work_line=$[ $line_amount - $first_usable_line + 1]

    locale_list=$($CHROOT tail -$work_line /etc/locale.gen | cut -d "#" -f 2 | sort -u | xargs)
    echo $locale_list
}

# delete old config
last_line=$(grep -n "Add by Archlinux Installer" /mnt/etc/locale.gen | cut -d ":" -f 1 | head -1)

if [ "$last_line" != "" ]
then
    head -$[ $last_line -1 ] /mnt/etc/locale.gen >tempfile
    mv tempfile /mnt/etc/locale.gen
fi

# select locale
title="Locale"
msg="Please select you needed localizations. the first column is locale,the second is charset.<locale> <charset>\n\nPlease confirm before typing the [ENTER], because you can't undo it."
locale_list=$(get_locale_list)

# add status
count=0
for item in $locale_list
do
    count=$[ $count + 1]
    judge=$[ $count % 2]
    if [ "$judge" = "0" ]
    then
        temp="${temp} $item OFF "
    else
        temp="${temp} $item "
    fi
done
locale_list=$temp
temp=

dialog --no-cancel --ascii-lines --title "$title" --backtitle "$HEADER" --checklist "$msg" 18 65 18 $locale_list 2>tempfile

retval=$?
choice=$(cat tempfile)

# if ESC,exit
case $retval in
    255)
        echo
        echo $EXIT_MSG
        exit 255
        ;;
esac

# new line
echo >>/mnt/etc/locale.gen
echo "## Add by Archlinux Installer">>/mnt/etc/locale.gen
for locale in $choice 
do
    item=$($CHROOT grep "$locale " /etc/locale.gen | head -1 |cut -d "#" -f 2)
    system_locale_list="${system_locale_list} $item"
    echo "$item" >>/mnt/etc/locale.gen
done

# generate the locale
$CHROOT locale-gen >/dev/null

# select system locale
title="System Locale"
msg="Please select system locale. the first column is locale, the second column is charset. <locale> <charset>. Don't recommend set chinese locale here. If you want to set chinese locale, you can just set for desktop environment later.	[ESC] to exit the installer\n\nPlease confirm before typing the [ENTER], because you can't undo it."

system_locale_list=$(echo $system_locale_list | xargs)

dialog --no-cancel --ok-button "Select" --ascii-lines --title "$title" --backtitle "$HEADER" --menu "$msg" 18 62 18 $system_locale_list 2>tempfile

retval=$?
choice=$(cat tempfile)

# if ESC,exit
case $retval in
    255)
        echo
        echo $EXIT_MSG
        exit 255
        ;;
esac

echo "## Add by Archlinux Installer">/mnt/etc/locale.conf
echo "LANG=$choice">/mnt/etc/locale.conf

## change Key map
echo "KEYMAP=$KEY_MAP" >/mnt/etc/vconsole.conf

##  hostname
title="Set hostname"
msg="Please input the hostname.		[ESC] to exit the installer.\n\nPlease confirm before typing the [ENTER], because you can't undo it."
dialog --no-cancel --ascii-lines --title "$title" --backtitle "$HEADER" --inputbox "$msg" 10 59 "hostname" 2>tempfile

retval=$?
choice=$(cat tempfile)

# if ESC,exit
case $retval in
    255)
        echo
        echo $EXIT_MSG
        exit 255
        ;;
esac

echo $choice >/mnt/etc/hostname

# set hosts
echo "127.0.1.1		localhost" >>/mnt/etc/hosts
echo "::1		localhost" >>/mnt/etc/hosts
echo "127.0.1.1		$choice.localdomain	$choice" >>/mnt/etc/hosts

### 9.Set root password
title="Root password"
msg="Please input the password.		[ESC] to exit the installer.\n\nPlease confirm before typing the [ENTER], because you can't undo it."
dialog --no-cancel --ascii-lines --title "$title" --backtitle "$HEADER" --inputbox "$msg" 10 59 "password" 2>tempfile

retval=$?
choice=$(cat tempfile)

# if ESC,exit
case $retval in
    255)
        echo
        echo $EXIT_MSG
        exit 255
        ;;
esac

# change passwd
echo "root:$choice" | $CHROOT chpasswd

### 10.Add New User
title="Add user"
msg="Please input the user name.		[ESC] to exit the installer.\n\nPlease confirm before typing the [ENTER], because you can't undo it."
dialog --no-cancel --ascii-lines --title "$title" --backtitle "$HEADER" --inputbox "$msg" 10 59 "username" 2>tempfile

retval=$?
choice=$(cat tempfile)
usrname=$choice
# if ESC,exit
case $retval in
    255)
        echo
        echo $EXIT_MSG
        exit 255
        ;;
esac

# user add
$CHROOT useradd -m -G wheel,video -s /bin/bash $choice

# init passwd
title="User Passwd"
msg="Please input the password.		[ESC] to exit the installer.\n\nPlease confirm before typing the [ENTER], because you can't undo it."
dialog --no-cancel --ascii-lines --title "$title" --backtitle "$HEADER" --inputbox "$msg" 10 59 "password" 2>tempfile

retval=$?
choice=$(cat tempfile)

# if ESC,exit
case $retval in
    255)
        echo
        echo $EXIT_MSG
        exit 255
        ;;
esac

# init passwd
echo
echo "$usrname:$choice" |$CHROOT chpasswd

# sudo was already installed in base-devel package

#uncomment the wheel group in sudoers file
sed -i "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /mnt/etc/sudoers

### 11.Configure network
# Nework manager
$CHROOT pacman --needed --noconfirm -S networkmanager
$CHROOT  systemctl enable NetworkManager.service
# dhclient (included in network manager)
#$CHROOT pacman --noconfirm -S dhcpcd

### 12.GRUB

# firstly,install grub and efibootmgr
platform=$(uname -m)

# used for probe other os
$CHROOT pacman --needed --noconfirm -S os-prober

# for UEFI,just for x86_64 or i386
if [ "$BOOT_MODE" = "UEFI" ]
then
    $CHROOT pacman --needed --noconfirm -S grub efibootmgr
    echo "GRUB_DISABLE_OS_PROBER=false" >> /mnt/etc/default/grub
    $CHROOT grub-install --target=${platform}-efi --efi-directory=/boot --bootloader-id=Grub 
    $CHROOT grub-mkconfig -o /boot/grub/grub.cfg

else # for BIOS
    $CHROOT pacman --needed --noconfirm -S grub
    $CHROOT grub-install --target=i386-pc --recheck $ROOT_DISK
    $CHROOT grub-mkconfig -o /boot/grub/grub.cfg
fi

# enable dhcpcd.service
# $CHROOT ln -s /usr/lib/systemd/system/dhcpcd.service /etc/systemd/system/multi-user.target.wants/dhcpcd.service

# Done
title="Complete Installation"
msg="Hey! You have installed a small working Archlinux on your computer. Plesase type [ENTER] to reboot your computer. When your computer boots again, you will find install-i3.sh script in your $usrname home direcotry which can get you a full working i3 setup (i3-purple) + some packages,  check https://github.com/LeszekBlazewski/dotfiles for details. [ESC] to exit installer"
dialog --no-cancel --ascii-lines --title "$title" --backtitle "$HEADER" --msgbox "$msg" 10 60

retval=$?
echo

case $retval in
    255) #ESC,exit
        echo 
        echo $EXIT_MSG
        exit 255
        ;;
esac

#download the i3-install script
curl https://raw.githubusercontent.com/LeszekBlazewski/dotfiles/master/install-i3.sh > /mnt/home/$usrname/install-i3.sh
chmod +x /mnt/home/$usrname/install-i3.sh
chown $usrname:$usrname /mnt/home/$usrname/install-i3.sh

# reboot
reboot
