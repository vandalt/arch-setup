#!/usr/bin/bash

PKGS_PAC=(

    # FONTS
    'ttf-dejavu'
    'noto-fonts-emoji'

    # APPEARANCE
    'murrine'

    # DEV
    'gvim'
    'git'
    'jdk-openjdk'
    'ipython'
    'python-numpy'
    'python-matplotlib'
    'cmake'
    'nodejs'
    'go'

    # SOCIAL
    'thunderbird'

    # OFFICE
    'texlive-most'
    'texmaker'
    'libreoffice-fresh'
    'okular'
    'gimp'

    # VIDEO
    'kdenlive'
    'vlc'

    # ASTRO
    'stellarium'

    # UTILS
    'htop'
    'screen'
    'cups'
    'cups-pdf'
    'openssh'
)

PKGS_AUR=(

    # INTERNET
    'brave-bin'

    # DEV
    'vim-plug-git'
    'nvm'
    'gconf'
    'mathematica'

    # OFFICE
    'zotero'
    'joplin'
    'onedrive-abraunegg'

    # SOCIAL
    'zoom'
    'slack-desktop'

    # UTILS
    'safeeyes'
    'qt5-styleplugins'
    'epson-inkjet-printer-201106w'

    # AUDIO
    'spotify'
    'cpod-git'
)

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

# install miniconda python
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3.sh
bash ~/miniconda3.sh -b -p $HOME/miniconda3

# key for spotify
gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 4773BD5E130D1D45

# install with pacman
for PKG in "${PKGS_PAC[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

# setup AUR
mkdir AUR
cd AUR
git clone https://aur.archlinux.org/auracle-git.git
cd auracle-git
makepkg -si --noconfirm
cd ..

for PKG in "${PKGS_AUR[@]}"; do
    echo "INSTALLING: ${PKG}"
    auracle clone "$PKG"
    cd "$PKG"
    makepkg -si --noconfirm
    cd ..
done
