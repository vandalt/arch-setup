#!/usr/bin/bash

shopt -s expand_aliases

PKGS_PAC=(
    'gdm'
    'gnome'
    'gnome-tweaks'
    'dconf-editor'
    'bluez'
    
    # THEMES
    'arc-gtk-theme'
    'papirus-icon-theme'
)

PKGS_AUR=(
    'gnome-terminal-transparency'

    # THEMES
    'nordic-theme-git'
    'paper-icon-theme'

    # EXTENSIONS
    'gnome-shell-extension-dash-to-dock'
    'gnome-shell-extension-tray-icons'
    'gnome-shell-extension-hidetopbar-git'
    'gnome-shell-extension-put-window-git'

)

PKGS_RM=(
    'epiphany'
    'evince'
    'file-roller'
    'gnome-calculator'
    'gnome-contacts'
    'gnome-maps'
    'gnome-documents'
    'gnome-music'
    'gnome-photos'
    'gnome-remote-desktop'
    'gnome-system-monitor'
    'gnome-weather'
    'totem'
    'gnome-software'
    'gnome-terminal'
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
for PKG in "${PKGS_RM[@]}"; do
    echo "REMOVING: ${PKG}"
    sudo pacman -Rs "$PKG" --noconfirm
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

# enable required packages
sudo systemctl enable gdm
sudo systemctl enable bluetooth

##################
#### DOTFILES ####
##################
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
echo ".dotfiles" >> .gitignore
git clone --bare https://github.com/vandalt/gnome-dotfiles.git $HOME/.dotfiles
config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} rm -rf {}
config checkout
config config --local status.show.UntrackedFiles no

####################
#### EXTENSIONS ####
####################

# enable
gnome-extensions enable hidetopbar@mathieu.bidon.ca
gnome-extensions enable tray-icons@zhangkaizhao.com
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gnome-extensions enable auto-move-windows@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable putWindow@clemens.lab21.org
