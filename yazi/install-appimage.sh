#!/usr/bin/env bash
set -euo pipefail

src=$(realpath "$1")
apps_dir="$HOME/Applications"
desktop_dir="$HOME/.local/share/applications"
base=$(basename "$src")
id="${base%.*}"
[ -n "${AI_ID:-}" ] && id="$AI_ID"
dest="$apps_dir/$base"

mkdir -p "$apps_dir" "$desktop_dir"
[ "$src" = "$dest" ] || cp -f "$src" "$dest"
chmod +x "$dest"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
(cd "$tmp" && "$dest" --appimage-extract '*.desktop' >/dev/null 2>&1 || true)

entry=$(find "$tmp/squashfs-root" -maxdepth 1 -name '*.desktop' 2>/dev/null | head -n1 || true)
field() { [ -n "$entry" ] && grep -m1 "^$1=" "$entry" | cut -d= -f2- || true; }

name=$(field Name); name=${name:-$id}
comment=$(field Comment)
wm_class=$(field StartupWMClass)
categories=$(field Categories); categories=${categories:-Utility;}

[ -n "${AI_NAME:-}" ] && name="$AI_NAME"
[ -n "${AI_COMMENT:-}" ] && comment="$AI_COMMENT"
[ -n "${AI_CATEGORIES:-}" ] && categories="$AI_CATEGORIES"
[ -n "${AI_WMCLASS:-}" ] && wm_class="$AI_WMCLASS"

exec_args=${AI_EXEC_ARGS:-%U}

icon=""
icon_name=$(field Icon)
if [ -n "$icon_name" ]; then
	for ext in svg png xpm; do
		(cd "$tmp" && "$dest" --appimage-extract "$icon_name.$ext" >/dev/null 2>&1 || true)
	done
	found=$(find "$tmp/squashfs-root" -maxdepth 1 \( -name "$icon_name.svg" -o -name "$icon_name.png" -o -name "$icon_name.xpm" \) 2>/dev/null | head -n1 || true)
	if [ -L "$found" ]; then
		(cd "$tmp" && "$dest" --appimage-extract "$(readlink "$found")" >/dev/null 2>&1 || true)
	fi
	if [ -n "$found" ] && [ -e "$found" ]; then
		ext="${found##*.}"
		icon="$apps_dir/$id.$ext"
		cp -fL "$found" "$icon"
		case "$ext" in
			svg) theme_dir="$HOME/.local/share/icons/hicolor/scalable/apps" ;;
			png) theme_dir="$HOME/.local/share/icons/hicolor/512x512/apps" ;;
			*) theme_dir="" ;;
		esac
		if [ -n "$theme_dir" ]; then
			mkdir -p "$theme_dir"
			cp -fL "$found" "$theme_dir/$icon_name.$ext"
			if [ -n "$wm_class" ]; then
				cp -fL "$found" "$theme_dir/$wm_class.$ext"
				cp -fL "$found" "$theme_dir/${wm_class,,}.$ext"
			fi
			gtk-update-icon-cache -q -t "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1 || true
			icon="$icon_name"
		fi
	fi
fi

if [ -n "${AI_ICON:-}" ] && [ -e "$AI_ICON" ]; then
	icon="$apps_dir/$id.${AI_ICON##*.}"
	cp -fL "$AI_ICON" "$icon"
fi

cat > "$desktop_dir/$id.desktop" <<DESKTOP
[Desktop Entry]
Name=$name
Exec=$dest $exec_args
Type=Application
Categories=$categories
DESKTOP
[ -z "$icon" ] || echo "Icon=$icon" >> "$desktop_dir/$id.desktop"
[ -z "$comment" ] || echo "Comment=$comment" >> "$desktop_dir/$id.desktop"
[ -z "$wm_class" ] || echo "StartupWMClass=$wm_class" >> "$desktop_dir/$id.desktop"

update-desktop-database "$desktop_dir" >/dev/null 2>&1 || true
notify-send "AppImage installed" "$name" 2>/dev/null || true
echo "Installed $name -> $dest"
read -rp "Press enter to exit" _ || true
