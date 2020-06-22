#!/bin/bash

ischroot=0

if [ $ischroot -eq 0 ]
then
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
	sed -i 's/ischroot=0/ischroot=1/' ./arch.sh
	cp ./arch.sh /mnt/arch.sh
	arch-chroot /mnt /bin/bash -x << _EOF_
	sh /arch.sh
	_EOF_
fi

if [ $ischroot -eq 1 ]
then
	#nano /etc/pacman.d/mirrorlist
	#Server = http://mirror.yandex.ru/archlinux/$repo/os/$arch
	sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
	sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
	locale-gen
	echo LANG=ru_RU.UTF-8 > /etc/locale.conf
	export LANG=en_US.UTF-8
	ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
	hwclock --systohc --utc # --localtime
	echo dmc > /etc/hostname
	echo -e "\n127.0.1.1 localhost.localdomain dmc" >> /etc/hosts ##
	pacman -S wpa_supplicant wireless_tools networkmanager network-manager-applet --noconfirm
	systemctl enable NetworkManager
	# nm-applet for widget
	systemctl enable wpa_supplicant
	pacman -S pulseaudio pulseaudio-alsa xorg xorg-xinit xorg-server bash-completion nano gpm --noconfirm
	# alsamixer for sound. use 'm' for on/off channel
	pacman -S pavucontrol  papirus-icon-theme volumeicon --noconfirm # for volumeicon check preference -> status icon -> lmb action
	# аппаратное ускорение видео
	pacman -S xf86-video-intel gstreamer-vaapi libva-intel-driver lib32-mesa mesa-libgl lib32-mesa-libgl mesa --noconfirm
	# кодеки
	pacman -S gstreamer gstreamer-vaapi gst-libav gst-plugins-bad gst-plugins-base gst-plugins-good gst-plugins-ugly --noconfirm
	useradd -m -g users -G wheel -s /bin/bash max
	sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
	pacman -S grub
	grub-install /dev/sda
	grub-mkconfig -o /boot/grub/grub.cfg
	#MATE
	echo "exec mate-session" > ~/.xinitrc
	sudo pacman -S mate lightdm lightdm-gtk-greeter
	systemctl enable lightdm
	passwd
	passwd max
	echo "dont forget drivers"
fi

echo -e "Enter: exit \n umount -R /mnt \n reboot
