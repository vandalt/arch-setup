#!/usr/bin/bash

MYHOST=$1
TIMEZONE=$2
MYSWAP=$3
WINPART=$4

# swap file
echo "Creating swap..."
dd if=/dev/zero of=/swapfile bs=1M count="$MYSWAP" status=progress
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
pacman -S vi wget git openssh grub efibootmgr os-prober networkmanager network-manager-applet wireless_tools wpa_supplicant dialog mtools dosfstools base-devel linux-headers intel-ucode --noconfirm

# Get setup file for later
cd /root
wget https://raw.githubusercontent.com/vandalt/arch-setup/main/1_setup.sh
cd /

sed -i -e "s/#MAKEFLAGS=.*/MAKEFLAGS=\"-j\$\(nproc\)\"/g" /etc/makepkg.conf

# setup GRUB bootloader
if [ ! -z "$WINPART" ]
then
	mkdir /mnt/windows10
	mount $WINPART /mnt/windows10
fi
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
