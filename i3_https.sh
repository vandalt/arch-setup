#!/usr/bin/bash

shopt -s expand_aliases

MYUSER="vandal"
BRANCH=$HOSTNAME

PKGS_PAC=(

    # DE
    'i3-gaps'
    'lightdm'
    'lightdm-webkit2-greeter'
    'feh'
    'picom'
    'ttf-font-awesome'
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
    'lightdm-webkit-theme-aether'
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
mkdir AUR
cd AUR
git clone https://aur.archlinux.org/auracle-git.git
cd auracle-git
makepkg -si --noconfirm
for PKG in "${PKGS_AUR[@]}"; do
    echo "INSTALLING: ${PKG}"
    auracle clone "$PKG"
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
git clone --bare https://github.com/vandalt/i3-dotfiles.git $HOME/.dotfiles
config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} rm -rf {}
config checkout
config config --local status.showUntrackedFiles no
config checkout $BRANCH

#################
#### LIGHTDM ####
#################
sudo systemctl enable lightdm
sudo cp .face /var/lib/AccountsService/icons/"$MYUSER"
if sudo [ -f /var/lib/AccountsService/users/$MYUSER ]; then
    sudo sed -i -e "s/Icon=.*/Icon=\/var\/lib\/AccountsService\/icons\/$MYUSER/g" /var/lib/AccountsService/users/$MYUSER
else
    sudo echo "[User]" >> /var/lib/AccountsService/users/$MYUSER
    sudo echo "Session=i3" >> /var/lib/AccountsService/users/$MYUSER
    sudo echo "XSession=i3" >> /var/lib/AccountsService/users/$MYUSER
    sudo echo "Icon=/var/lib/AccountsService/icons/$MYUSER" >> /var/lib/AccountsService/users/$MYUSER
    sudo echo "SystemAccount=false" >> /var/lib/AccountsService/users/$MYUSER
fi

##################
#### HARDWARE ####
##################
# keyboard layout
sudo localectl set-x11-keymap ca

# touchpad
sudo sed -i '/^ \+MatchIsTouchpad "on"/a \\tOption "Tapping" "true"\n\tOption "TappingButtonMap" "lrm"\n\tOption "NaturalScrolling" "true' /usr/share/X11/xorg.conf.d/40-libinput.conf

# bluetooth
sudo systemctl enable bluetooth
