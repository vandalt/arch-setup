#!/usr/bin/bash

PKGS_PAC=(
    'gdm'
    'gnome'
    'gnome-tweaks'
    'dconf-editor'
    'bluez'
    
    # THEMES
    'papirus-icon-theme'
)

PKGS_AUR=(
    # THEMES
    'ant-gtk-theme'
    'paper-icon-theme'

    # EXTENSIONS
    'gnome-shell-extension-dash-to-dock'
    'gnome-shell-extension-tray-icons'
    'gnome-shell-extension-hidetopbar-git'

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
    cd "$PKG"
    makepkg -si --noconfirm
    cd ..
done
cd ~

# enable required packages
sudo systemctl enable gdm
sudo systemctl enable bluetooth

####################
#### EXTENSIONS ####
####################

# enable
gnome-extensions enable hidetopbar@mathieu.bidon.ca
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
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'LEFT'
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
# Dracula option
# gsettings set org.gnome.shell.extensions.user-theme name 'Ant-Dracula-slim'
# gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
# gsettings set org.gnome.desktop.interface gtk-theme 'Ant-Dracula-slim'
# gsettings set org.gnome.desktop.interface cursor-theme 'Paper'

# Adwaita light option
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Light'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
gsettings set org.gnome.desktop.interface cursor-theme 'Paper'

# Adwaita dark option
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Paper'

###############
### FIREFOX ###
###############
for profile in ~/.mozilla/firefox/*.default-release
do
	mkdir $profile/chrome
    cp ~/.firefox_userContent.css $profile/chrome/userContent.css
done

#####################################
#### WORKSPACES AND APPLICATIONS ####
#####################################

# dynamic workspaces
gsettings set org.gnome.shell.app-switcher current-workspace-only true

# favorite applications
gsettings set org.gnome.shell favorite-apps "['org.gnome.Terminal.desktop', 'firefox.desktop', 'joplin.desktop', 'geary.desktop', 'org.gnome.Nautilus.desktop', 'nvim.desktop', 'zotero.desktop', 'spotify.desktop', 'libreoffice-impress.desktop','slack.desktop', 'Zoom.desktop']"

##################
#### SETTINGS ####
##################
# sound
gsettings set org.gnome.desktop.wm.preferences audible-bell 'false'

# power
gsettings  set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings  set org.gnome.settings-daemon.plugins.power power-button-action 'interactive'

# night light
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 12.0
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 12.0
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4300

# mouse and touchpad
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false

############################
#### KEYBOARD SHORTCUTS ####
############################

### SYSTEM ###

# disable favorites
for i in {1..9}; do
    gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"
done

# workspace swithcing/moving
for i in {1..9}; do
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "['<Super><Shift>$i']"
done
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-10 "['<Super>0']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-10 "['<Super><Shift>0']"

# window switching
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Super>Above_Tab', '<Alt>Above_Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "['<Shift><Super>Above_Tab', '<Shift><Alt>Above_Tab']"
gsettings set org.gnome.mutter.keybindings switch-monitor "['XF86Display']"

# system
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Super>BackSpace']"
gsettings set org.gnome.settings-daemon.plugins.media-keys logout "['<Shift><Super>e']"
gsettings set org.gnome.desktop.wm.keybindings panel-run-dialog "['<Super>r']"
gsettings set org.gnome.shell.keybindings toggle-application-view "['<Super>a']"
gsettings set org.gnome.shell.keybindings focus-active-notification "[]"
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>v']"

# windows general
gsettings set org.gnome.desktop.wm.keybindings close "['<Shift><Super>q']"
gsettings set org.gnome.desktop.wm.keybindings minimize "['<Super>d']"
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Shift><Super>f']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Shift>XF86Keyboard']"

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
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'geary'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<Super>m'

# notes
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ name 'Notes'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ command 'joplin-desktop'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ binding '<Super>t'

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

# make zsh the default
chsh -s /usr/bin/zsh
echo "Do not forget to activate toolkit.legacyUserProfileCustomizations.stylesheets in Firefox"
echo "Reboot for all changes to take effect"
