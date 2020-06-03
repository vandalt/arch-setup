#!/usr/bin/bash

# Post-install basic setup

# enable internet
#systemctl start NetworkManager
#systemctl enable NetworkManager

# connect wifi
read -r -p "Connect with nmtui [Y/n] " response
case "$response" in
    [nN])
        ;;
    *)
        nmtui
        ;;
esac

# add user(s)
re='^[0-9]+$'
read -r -p "How many users do you want to add? " nuser
while ! [[ $nuser =~ $re ]]
do
    echo "$nuser is not a valid number. Please enter an integer."
    read -r -p "How many users do you want to add? " nuser
done
for i in $(seq 1 $nuser)
do
    read -r -p "Username: " uname
    passwd $uname
done

# sudo privileges for wheel group
read -p "Press [Enter] key to enter visudo. You can then safely uncomment the wheel group."
visudo

# graphical installs
pacman -S mesa xorg xf86-video-intel
