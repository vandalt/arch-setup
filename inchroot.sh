#!/usr/bin/bash

$MYHOST=$1

# swap file
echo "Creating swap..."
fallocate -l 4GB /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
printf "\n#swap\n/swapfile none swap 0 0\n" >> /etc/fstab

# clock
echo "Setting clock..."
ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
hwclock --systohc

# localization
echo "Setting localization..."
sed -i '/en_CA.UTF/s/^#//g' /etc/locale.gen
locale-gen
echo "LANG=en_CA.UTF-8" >> /etc/locale.conf
echo "KEYMAP=cf" >> /etc/vconsole.conf

# Network
echo "Setting network..."
echo "$MYHOST" >> /etc/hostname
echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    $MYHOST.localdomain    $MYHOST" >> /etc/hosts

# root password
until passwd
do
    echo "Try again"
done

# last installs
pacman -Syu --noconfirm
pacman -S grub efibootmgr os-prober networkmanager network-manager-applet wireless_tools wpa_supplicant dialog mtools dosfstools base-devel linux-headers intel-ucode --noconfirm

# setup GRUB bootloader
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
sed -i -E '/GRUB_TIMEOUT=/s/[[:digit:]]+/0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
