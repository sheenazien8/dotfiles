#!/bin/sh

# XDG desktop identification (Firefox only enables XDG desktop portal when
# this is set to a recognized DE; i3 is bare, so pick XFCE as a neutral
# closest match — only used by apps that gate features on this value).
export XDG_CURRENT_DESKTOP=i3
export GTK_USE_PORTAL=1

# GTK/Qt dark mode
export GTK_THEME=Adwaita-dark
export QT_STYLE_OVERRIDE=Adwaita-Dark
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_DATA_DIRS=/usr/local/share:/usr/share
export XDG_CONFIG_DIRS=/etc/xdg

# Set background (restore last feh wallpaper)
[ -x "$HOME/.fehbg" ] && "$HOME/.fehbg" &

# System tray (for bluetooth applet, flameshot, etc)
# stalonetray --icon-size 20 --window-strut none &

# Polkit authentication agent
/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &

# Picom compositor
picom --experimental-backends -b 2>/dev/null &

# Dunst notification daemon
dunst &

# Flameshot
# flameshot &

# Bluetooth applet (tray icon for pairing)
# blueman-applet &

# Screen blanking: dim after 5min, lock after 10min.
# idle-inhibit menonaktifkan sementara saat fullscreen / media playing,
# lalu mengembalikannya saat berhenti (lihat ~/.local/bin/idle-inhibit).
xset s 300 300
xset s blank
xset dpms 600 600 600

# Auto-lock on screensaver
xss-lock -- ~/.local/bin/lockscreen &

# Jangan lock saat menonton video (fullscreen / MPRIS playing)
~/.local/bin/idle-inhibit &

# Thumbnail daemon (for Thunar/GTK)
/usr/lib/x86_64-linux-gnu/tumbler-1/tumblerd &

# Keyboard repeat rate
xset r rate 250 50 &

# Cursor theme
xsetroot -cursor_name left_ptr &

# Disable GTK accessibility (fix slow launch)
export GTK_A11Y=none
export GIO_USE_VFS=local

# Keyboard remapping handled by keyd (system service)
# keyd provides: Caps tap=Esc, hold+hjkl=arrows, ;=Home, '=End
# See: /etc/keyd/default.conf

# KDE Connect daemon: (re)start under this X session so it can read/write the
# X clipboard. Started from the systemd user unit it has no DISPLAY (see
# ~/.config/systemd/user/kdeconnect.service.d/display.conf) and receiving a
# clipboard from a device would only show a notification.
systemctl --user restart kdeconnect.service &

# Start i3 window manager
exec i3
