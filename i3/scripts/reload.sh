#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  i3 Reload Script - Refresh semua personalisasi
#  Usage: ~/.config/i3/scripts/reload.sh
# ═══════════════════════════════════════════════════════════════

set -e

echo "🔄 Reloading i3 personalization..."

# ── 1. Reload i3 config ────────────────────────────────────────
echo "  → Reloading i3 config..."
i3-msg reload >/dev/null 2>&1 || true

# ── 2. Reload polybar ────────────────────────────────────────
echo "  → Restarting polybar..."
~/.config/polybar/launch.sh || true
sleep 1

# ── 3. Reload picom (compositor) ─────────────────────────────
echo "  → Restarting picom..."
killall -q picom 2>/dev/null || true
sleep 0.5
picom --config ~/.config/picom/picom.conf -b 2>/dev/null || true

# ── 4. Reload wallpaper (feh) ────────────────────────────────
echo "  → Restoring wallpaper..."
[ -x "$HOME/.fehbg" ] && "$HOME/.fehbg" || true

# ── 5. Reload kanata (keyboard remapping) ──────────────────────
echo "  → Restarting kanata..."
systemctl --user restart kanata 2>/dev/null || true

# ── 5b. System tray applets ──────────────────────────────────
echo "  → Starting tray applets..."
killall -q blueman-applet 2>/dev/null || true
killall -q nm-applet 2>/dev/null || true
blueman-applet &
nm-applet &

# ── 5c. Clipboard manager ────────────────────────────────────
echo "  → Starting clipboard manager..."
pkill -f 'clipboard-kde\.sh' 2>/dev/null || true
~/.local/bin/clipboard-kde.sh &

# ── 6. Reload dunst (notifications) ──────────────────────────
echo "  → Restarting dunst..."
killall -q dunst 2>/dev/null || true
sleep 0.3
dunst & 2>/dev/null || true

# ── 7. Reload rofi (launcher theme) ────────────────────────
echo "  → Reloading rofi theme..."
# Rofi theme di-load pas dipanggil, nggak perlu restart
# Cuma clear cache aja biar fresh
rm -f ~/.cache/rofi-*.cache 2>/dev/null || true

# ── 8. Set workspace names (optional - customize icons) ──────
# echo "  → Setting workspace names..."
# i3-msg 'rename workspace 1 to "1: ♚"' 2>/dev/null || true
# i3-msg 'rename workspace 2 to "2: ♛"' 2>/dev/null || true
# i3-msg 'rename workspace 3 to "3: ♜"' 2>/dev/null || true
# i3-msg 'rename workspace 4 to "4: ♝"' 2>/dev/null || true

# ── 9. Apply GTK theme (gruvbox) ─────────────────────────────
echo "  → Applying GTK theme..."
# Set theme via gsettings kalau ada
if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme "Gruvbox-Dark" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Ice" 2>/dev/null || true
fi

# ── 10. Refresh zsh (kalau ada window terminal aktif) ────────
# Ini cuma info aja, user perlu manual source ~/.zshrc
echo "  → Note: Run 'source ~/.zshrc' di terminal aktif"

echo ""
echo "✅ Reload complete!"
echo "   i3: config reloaded"
echo "   Polybar: restarted"
echo "   Picom: restarted"
echo "   Wallpaper: restored"
echo "   Kanata: restarted"
echo "   Tray applets: restarted"
echo "   Clipboard: restarted"
echo "   Dunst: restarted"
echo ""
echo "   Keybindings:"
echo "     Mod+Shift+r  = reload semua personalization (reload.sh)"
echo "     Mod+Shift+c  = reload config i3"
echo ""
