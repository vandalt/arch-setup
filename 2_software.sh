#!/usr/bin/bash

shopt -s expand_aliases

PKGS_PAC=(

    # FONTS
    'ttf-dejavu'
    'noto-fonts-emoji'

    # APPEARANCE
    'murrine'

    # DEV
    'neovim'
    'xclip'
    'python-pynvim'
    'git'
    'jdk-openjdk'
    'ipython'
    'python-numpy'
    'python-matplotlib'
    'python-pandas'
    'cmake'
    'nodejs'
    'go'

    # BROWSER
    'firefox'
    'chromium'
    'qutebrowser'

    # EMAIL
    'neomutt'
    'isync'
    'msmtp'

    # OFFICE
    'texlive-most'
    'libreoffice-fresh'
    'okular'
    'gimp'

    # VIDEO
    'kdenlive'
    'mpv'

    # ASTRO
    'stellarium'

    # UTILS
    'zsh'
    'zsh-completions'
    'htop'
    'screen'
    'cups'
    'cups-pdf'
    'openssh'
    'iio-sensor-proxy'
    'pdftk'
)

PKGS_AUR=(

    # DEV
    'vim-dein'

    # OFFICE
    'zotero'
    'joplin'
    'onedrive-abraunegg'

    # SOCIAL
    'zoom'
    'slack-desktop'

    # UTILS
    'qt5-styleplugins'
    'epson-inkjet-printer-201106w'

    # AUDIO
    'pulseaudio-git'
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
