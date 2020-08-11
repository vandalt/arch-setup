#!/usr/bin/bash

# Install i3 and other programs to form a DE
# RUN AFTER LOGIN: sudo sed -i -e "s/Icon=.*/Icon=\/var\/lib\/AccountsService\/icons\/$MYUSER/g" /var/lib/AccountsService/users/$MYUSER

shopt -s expand_aliases

MYUSER="vandal"
BRANCH=$HOSTNAME

PKGS_PAC=(

    # DE
    'gdm'
    'swayidle'
    'waybar'
    'mako'
    'grim'
    'slurp'
    'otf-font-awesome'
    'xdg-user-dirs'
    'brightnessctl'
    'playerctl'
    'acpi'
    'udiskie'
    'udisks2'
    'bluez'
    'bluez-utils'
    'blueberry'
    'gnome-shell'
    'gnome-control-center'
    'qt5-wayland'

    # AUDIO
    'pavucontrol'
    'pulseaudio-alsa'
    'pulseaudio-bluetooth'
    'alsa-utils'
    'sof-firmware'

    # Applications
    'alacritty'
    'kitty'
    'dmenu'
    'nautilus'
    'ranger'
    'qutebrowser'

    # THEMES
    'papirus-icon-theme'
)

PKGS_AUR=(

    # DE
    # 'wlroots-git'
    # 'sway-git'
    'xorg-server-hidpi-git'
    'wlroots-hidpi-git'
    'sway-hidpi-git'
    'swaybg-git'
    'swaylock-effects-git'
    'rot8-git'
    'detect-tablet-mode-git'
    'yoga-usage-mode'
    'virtboard'
    'gammastep'
    'libinput-gestures'

    # THEMES
    'ant-gtk-theme'
    'paper-icon-theme'

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

# AUR
# First because sway is in there
cd AUR
for PKG in "${PKGS_AUR[@]}"; do
    echo "INSTALLING: ${PKG}"
    auracle clone "$PKG"
    cd "$PKG"
    makepkg -si --noconfirm
    cd ..
done

cd ~
# install with pacman
for PKG in "${PKGS_PAC[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

##################
#### DOTFILES ####
##################
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
echo ".dotfiles" >> .gitignore
git clone --bare git@github.com:vandalt/dotfiles.git $HOME/.dotfiles
config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} rm -rf {}
config checkout
config config --local status.showUntrackedFiles no
config checkout arch

#################
#### LIGHTDM ####
#################
sudo systemctl enable gdm

##################
#### HARDWARE ####
##################
# bluetooth
sudo systemctl enable bluetooth

# make zsh the default
chsh -s /usr/bin/zsh
echo "Do not forget to activate toolkit.legacyUserProfileCustomizations.stylesheets in Firefox"
echo "Reboot for all changes to take effect"
