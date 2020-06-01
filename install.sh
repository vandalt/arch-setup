#!/usr/bin/bash

# options
DEVICE="sda"
TIMEZONE="America/New_York"
DISKPART="diskpartlayout"
HOSTNAME="watson"

# time and date
timedatectl set-ntp true
timedatectl set-timezone $TIMEZONE

# disk partitions
if [ ! -f $DISKPART ]; then
    echo "ERROR: Disk partition file not found."
    exit 1
fi
sfdisk /dev/"$DEVICE" < diskpartlayout

# filesystem
mkfs.fat -F32 /dev/"$DEVICE"1
mkfs.ext4 /dev/"$DEVICE"2

# mount
mount /dev/"$DEVICE"2 /mnt
mkdir -p /mnt/boot/EFI
mount /dev/"$DEVICE"1 /mnt/boot/EFI

# sort mirrors
pacman -Sy pacman-contrib --noconfirm
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.back
curl -s "https://www.archlinux.org/mirrorlist/?country=CA&country=US&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 6 - > /etc/pacman.d/mirrorlist

# main packages with pacstrap
pacstrap /mnt base linux linux-firmware

# generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# chroot to new install
arch-chroot /mnt

# swap file
fallocate -l 4GB /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
printf "\n#swap\n/swapfile none swap 0 0\n" >> /etc/fstab

# clock
ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
hwclock --systohc

# localization
sed -i '/en_CA.UTF/s/^#//g' /etc/locale.gen
locale-gen
echo "LANG=en_CA.UTF-8" >> /etc/locale.conf
echo "KEYMAP=cf" >> /etc/vconsole.conf

# Network
echo "$HOSTNAME" >> /etc/hostname
echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    $HOSTNAME.localdomain    $HOSTNAME" >> /etc/hosts

# root password
echo "Will now run passwd to set root password..."
passwd

# last installs
pacman -Syu --noconfirm
pacman -S grub efibootmgr os-prober networkmanager network-manager-applet wireless_tools wpa_supplicant dialog mtools dosfstools base-devel linux-headers intel-ucode --noconfirm

# setup GRUB bootloader
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
sed -i -E '/GRUB_TIMEOUT=/s/[[:digit:]]+/0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# sucess message
echo "Done with config. You can exit, umount -a, and reboot"
