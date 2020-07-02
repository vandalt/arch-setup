#!/usr/bin/bash

# options
if [ $# -ne 4 ]; then
    echo "ERROR: no hostname specified."
    echo "USAGE: ./0-install.sh HOST DEVICE PARTITION SWAP"
    echo "SWAP is in M"
    echo "EXAMPLE: ./0-install.sh laptop sda diskfile 4000"
    exit 1
fi
MYHOST=$1
DEVICE=$2
TIMEZONE="America/New_York"
DISKPART=$3
MYSWAP=$4

# time and date
echo "Setting time and date..."
timedatectl set-ntp true
timedatectl set-timezone $TIMEZONE

# disk partitions
echo "Partitioning disk"
if [ ! -f $DISKPART ]; then
    echo "ERROR: Disk partition file not found."
    exit 2
fi
sfdisk /dev/"$DEVICE" < "$DISKPART"
d1=$(fdisk -l | grep -o '^/dev/.*1\b')
d2=$(fdisk -l | grep -o '^/dev/.*2\b')

# filesystem
echo "Creating file system"
mkfs.fat -F32 /dev/"$d1"
mkfs.ext4 /dev/"$d2"

# mount
echo "Mounting partitions..."
mount /dev/"$d2" /mnt
mkdir -p /mnt/boot/EFI
mount /dev/"$d1" /mnt/boot/EFI

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
wget https://raw.githubusercontent.com/vandalt/arch-setup/main/inchroot.sh
chmod +x inchroot.sh
mv inchroot.sh /mnt
arch-chroot /mnt ./inchroot.sh $MYHOST $TIMEZONE $MYSWAP

# sucess message
echo "Done with config. You can exit, umount -a, and reboot"
