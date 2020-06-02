#!/usr/bin/bash

shopt -s expand_aliases

MYUSER=vandal
BRANCH=$HOSTNAME

PKGS_PAC=(

    # DE
    'lightdm'
    'lightdm-webkit2-greeter'
    'i3-gaps'
    'feh'
    'picom'
    'fontawesome'
    'rofi'
    'i3blocks'
    'udiskie'
    'udisks2'
    'unclutter'
    'lxappearance'
    'autorandr'
    'xfce4-notifyd'
    'acpi'
    'playerctl'
    'redshift'

    # BLUETOOTH
    'bluez'
    'bluez-utils'
    'blueman'

    # AUDIO
    'pulseaudio'
    'pavucontrol'
    'pulseaudio-alsa'
    'pulseaudio-bluetooth'
    'alsa-utils'

    # Applications
    'termite'
    'thunar'
    'ristretto'
    'mousepad'
    
    # THEMES
    'arc-gtk-theme'
    'papirus-icon-theme'
)

PKGS_AUR=(

    # THEMES
    'nordic-theme-git'
    'paper-icon-theme'

    # UTILS
    'escrotum-git'
    'ttf-font-logos'

)

# sudo password only once in 1 h
bypass() {
  sudo -v
  while true;
  do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
}

bypass

##################
#### SOFTWARE ####
##################

# install with pacman
for PKG in "${PKGS_PAC[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

# AUR
cd AUR
for PKG in "${PKGS_AUR[@]}"; do
    echo "INSTALLING: ${PKG}"
    auracle clone "$PKG"
    if [ "$PKG" == "gnome-shell-extension-put-window-git" ]; then
        sed -i '/convenience.js/d' "$PKG"/PKGBUILD
    fi
    cd "$PKG"
    makepkg -si --noconfirm
    cd ..
done
cd ~

##################
#### DOTFILES ####
##################
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
echo ".dotfiles" >> .gitignore
git clone --bare git@github.com:vandalt/i3-dotfiles.git $HOME/.dotfiles
config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} rm -rf {}
config checkout
config config --local status.showUntrackedFiles no
config checkout $BRANCH

#################
#### LIGHTDM ####
#################
sudo systemctl enable lightdm
sudo cp .face /var/lib/AccountsService/icons/"$MYUSER"
sudo sed -i -e "s/Icon=.*/Icon=\/var\/AccountsService\/icons\/$MYUSER/g" /var/lib/AccountsService/users/$MYUSER

##################
#### HARDWARE ####
##################
# keyboard layout
sudo localectl set-x11-keymap ca

# touchpad
sed -i '/MatchIsTouchpad "on"/a \\tOption "Tapping" "true"\n\tOption "TappingButtonMap" "lrm"\n\tOption "NaturalScrolling" "true' /usr/share/X11/xorg.conf.d/40-libinput.conf

# bluetooth
sudo systemctl enable bluetooth
