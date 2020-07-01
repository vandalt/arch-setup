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
    'ant-gtk-theme'
    'paper-icon-theme'

    # EXTENSIONS
    'gnome-shell-extension-dash-to-dock'
    'gnome-shell-extension-tray-icons'
    'gnome-shell-extension-hidetopbar-git'
    'gnome-shell-extension-put-window-git'

)

PKGS_RM=(
    'epiphany'
    'gnome-books'
    'sushi'
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
cd ~

# enable required packages
sudo systemctl enable gdm
sudo systemctl enable bluetooth

##################
#### DOTFILES ####
##################
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
echo ".dotfiles" >> .gitignore
git clone --bare git@github.com:vandalt/gnome-dotfiles.git $HOME/.dotfiles
config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} rm -rf {}
config checkout
config config --local status.showUntrackedFiles no

####################
#### EXTENSIONS ####
####################

# enable
gnome-extensions enable hidetopbar@mathieu.bidon.ca
gnome-extensions enable putWindow@clemens.lab21.org
gnome-extensions enable tray-icons@zhangkaizhao.com
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gnome-extensions enable auto-move-windows@gnome-shell-extensions.gcampax.github.com

# hide top bar
gsettings set org.gnome.shell.extensions.hidetopbar enable-intellihide true
gsettings set org.gnome.shell.extensions.hidetopbar enable-active-window true
gsettings set org.gnome.shell.extensions.hidetopbar mouse-sensitive true
gsettings set org.gnome.shell.extensions.hidetopbar shortcut-toggles true
gsettings set org.gnome.shell.extensions.hidetopbar shortcut-keybind "['<Shift><Super>i']"
gsettings set org.gnome.shell.extensions.hidetopbar pressure-timeout 100
gsettings set org.gnome.shell.extensions.hidetopbar pressure-threshold 200
gsettings set org.gnome.shell.extensions.hidetopbar shortcut-delay 1.0

# dash-to-dock
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode 'ALL_WINDOWS'
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen false
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 50
gsettings set org.gnome.shell.extensions.dash-to-dock show-favorites true
gsettings set org.gnome.shell.extensions.dash-to-dock show-running true
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.20
gsettings set org.gnome.shell.extensions.dash-to-dock force-straight-corner false

###############
#### THEME ####
###############
gsettings set org.gnome.shell.extensions.user-theme name 'Nordic'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Nordic'
gsettings set org.gnome.desktop.interface cursor-theme 'Paper'

##################
#### TERMINAL ####
##################

# get nord and set as default
git clone https://github.com/arcticicestudio/nord-gnome-terminal.git
cd nord-gnome-terminal/src
./nord.sh
cd ../..
rm -rf nord-gnome-terminal
proflist=$(gsettings get org.gnome.Terminal.ProfilesList list | tr -d \[ | tr -d \] | tr -d \' | tr -d , | tr -d \s)
for prof in $proflist; do
    name=$(gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$prof/ visible-name | tr -d \')
    if [ $name == Nord ]; then
        gsettings set org.gnome.Terminal.ProfilesList default $prof
        termprof=$prof
    fi
done

# customize
gsettings set org.gnome.Terminal.Legacy.Settings headerbar false
gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$termprof/ use-transparent-background true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$termprof/ background-transparency-percent 20
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$termprof/ audible-bell false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$termprof/ scrollbar-policy 'never'

######################
#### FILE MANAGER ####
######################
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'

#####################################
#### WORKSPACES AND APPLICATIONS ####
#####################################

# dynamic workspaces
gsettings set org.gnome.shell.overrides dynamic-workspaces false
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 7
gsettings set org.gnome.shell.app-switcher current-workspace-only true

# assign applications to workspace
gsettings set org.gnome.shell.extensions.auto-move-windows application-list "['firefox.desktop:2', 'chromium.desktop:2', 'thunderbird.desktop:6', 'joplin.desktop:3', 'spotify.desktop:7', 'slack.desktop:6', 'cpod.desktop:7']"

# favorite applications
gsettings set org.gnome.shell favorite-apps "['org.gnome.Terminal.desktop', 'firefox.desktop', 'thunderbird.desktop', 'joplin.desktop', 'org.gnome.Nautilus.desktop', 'vim.desktop', 'zotero.desktop', 'spotify.desktop', 'libreoffice-impress.desktop','slack.desktop', 'Zoom.desktop', 'texmaker.desktop']"

##################
#### SETTINGS ####
##################
# sound
gsettings set org.gnome.desktop.wm.preferences audible-bell 'false'

# power
gsettings  set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
gsettings  set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings  set org.gnome.settings-daemon.plugins.power power-button-action 'interactive'

# night light
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 12.0
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 12.0
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000

# mouse and touchpad
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false

# keyboard (french ca)
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'ca')]"

# window top bar tweaks
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:appmenu'

############################
#### KEYBOARD SHORTCUTS ####
############################

### SYSTEM ###

# disable favorites
for i in {1..9}; do
    gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"
done

# workspace swithcing/moving
for i in {1..4}; do
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "['<Super><Shift>$i']"
done
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<Super>8']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-5 "['<Super><Shift>8']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<Super>9']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-6 "['<Super><Shift>9']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-7 "['<Super>0']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-7 "['<Super><Shift>0']"
for i in {8..9}; do
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "[]"
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "[]"
done

# window switching
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Super>Above_Tab', '<Alt>Above_Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "['<Shift><Super>Above_Tab', '<Shift><Alt>Above_Tab']"
gsettings set org.gnome.mutter.keybindings switch-monitor "['XF86Display']"

# system
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Super>comma']"
gsettings set org.gnome.settings-daemon.plugins.media-keys logout "['<Shift><Super>e']"
gsettings set org.gnome.desktop.wm.keybindings panel-run-dialog "['<Super>r']"
gsettings set org.gnome.shell.keybindings toggle-application-view "['<Super>a']"
gsettings set org.gnome.shell.keybindings focus-active-notification "[]"
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>v']"

# windows general
gsettings set org.gnome.desktop.wm.keybindings close "['<Shift><Super>q']"
gsettings set org.gnome.desktop.wm.keybindings minimize "['<Super>d']"
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Shift><Super>f']"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow move-center-only-toggles 1
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Shift>XF86Keyboard']"

# putwindow snapping
gsettings set org.gnome.shell.extensions.org-lab21-putwindow put-to-side-w "['<Shift><Super>h']"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow put-to-side-n "['<Shift><Super>k']"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow put-to-side-e "['<Shift><Super>l']"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow put-to-side-s "['<Shift><Super>j']"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow put-to-corner-sw "['<Shift><Super>m']"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow put-to-corner-nw "['<Shift><Super>u']"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow put-to-corner-se "['<Shift><Super>eacute']"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow put-to-corner-ne "['<Shift><Super>p']"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow put-to-right-screen "['<Super>semicolon']"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow put-to-left-screen "['<Super>colon']"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow put-to-center "['<Shift><Super>space']"

# putwindow focus
gsettings set org.gnome.shell.extensions.org-lab21-putwindow move-focus-west "['<Super>h']"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow move-focus-north "['<Super>k']"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow move-focus-east "['<Super>l']"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow move-focus-south "['<Super>j']"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow move-focus-left-screen "[]"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow move-focus-right-screen "[]"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow move-focus-cycle "[]"
gsettings set org.gnome.shell.extensions.org-lab21-putwindow move-focus-left-screen-enabled 0
gsettings set org.gnome.shell.extensions.org-lab21-putwindow move-focus-right-screen-enabled 0
gsettings set org.gnome.shell.extensions.org-lab21-putwindow move-focus-cycle-enabled 0

## APPLICATIONS ##
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/']"

# terminal
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'gnome-terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>Return'

# browser
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'Browser'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'firefox'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Super>i'

# email
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'Mail'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'thunderbird'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<Super>m'

# notes
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ name 'Notes'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ command 'joplin-desktop'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ binding '<Super>n'

# pdf
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ name 'PDF'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ command 'env QT_QPA_PLATFORMTHEME=gtk2 okular'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ binding '<Super>p'

# music
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/ name 'Music'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/ command 'spotify'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/ binding '<Super>u'

# chat
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/ name 'Chat'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/ command 'slack'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/ binding '<Super>c'

# file manager
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/ name 'Files'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/ command 'nautilus'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/ binding '<Super>f'

# zotero
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/ name 'Zotero'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/ command 'zotero'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/ binding '<Super>z'
