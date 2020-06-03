#!/usr/bin/bash

# options
MYHOST=$1
DEVICE="sda"
TIMEZONE="America/New_York"
DISKPART="diskpartlayout"

# time and date
echo "Setting time and date..."
timedatectl set-ntp true
timedatectl set-timezone $TIMEZONE

# disk partitions
echo "Partitioning disk"
if [ ! -f $DISKPART ]; then
    echo "ERROR: Disk partition file not found."
    exit 1
fi
sfdisk /dev/"$DEVICE" < diskpartlayout

# filesystem
echo "Creating file system"
mkfs.fat -F32 /dev/"$DEVICE"1
mkfs.ext4 /dev/"$DEVICE"2

# mount
echo "Mounting partitions..."
mount /dev/"$DEVICE"2 /mnt
mkdir -p /mnt/boot/EFI
mount /dev/"$DEVICE"1 /mnt/boot/EFI

# sort mirrors
echo "Sorting mirrors..."
pacman -Sy pacman-contrib --noconfirm
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.back
curl -s "https://www.archlinux.org/mirrorlist/?country=CA&country=US&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 6 - > /etc/pacman.d/mirrorlist

# main packages with pacstrap
echo "Pacstrap..."
pacstrap /mnt base linux linux-firmware

# generate fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# chroot to new install
echo "Entering new install"
wget https://raw.githubusercontent.com/vandalt/arch-setup/master/inchroot.sh
chmod +x inchroot.sh
mv inchroot.sh /mnt
arch-chroot /mnt ./inchroot.sh $MYHOST $TIMEZONE

# sucess message
echo "Done with config. You can exit, umount -a, and reboot"
