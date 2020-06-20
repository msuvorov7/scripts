#!/bin/bash

# legacy mode
cfdisk /dev/sda
#dos
#
#/dev/sda1  choose at least 10 GB of space (root of filesystem)
#/dev/sda2  choose all the left space (home)
#/dev/sda3  swap
mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/sda2
mkswap /dev/sda3
swapon /dev/sda3
mount /dev/sda1 /mnt
mkdir /mnt/home
mount /dev/sda2 /mnt/home
pacstrap -i /mnt base base-devel linux linux-firmware sudo nano
genfstab -U -p /mnt >> /mnt/etc/fstab
arch-chroot /mnt /bin/bash
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo LANG=ru_RU.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc --utc
echo dmc > /etc/hostname
echo "\n127.0.1.1 localhost.localdomain archPC" >> /etc/hosts ##
pacman -S networkmanager
systemctl enable NetworkManager
pacman -S pulseaudio pulseaudio-alsa xorg xorg-xinit xorg-server
useradd -m -g users -G wheel -s /bin/bash max
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
pacman -S grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
#MATE
echo "exec mate-session" > ~/.xinitrc
sudo pacman -S mate lightdm lightdm-gtk-greeter
systemctl enable lightdm
echo "Enter root password"
passwd
echo "Enter max password"
passwd max
exit
umount -R /mnt
#reboot
