#!/bin/sh
# Screenshot: save to file + copy to clipboard + notify + send to ALL devices
DIR="/DATA/Pictures/Screenshots"

mkdir -p "$DIR"
FILE="$DIR/screenshot-$(date +%s).png"

# Area/select mode: force region-only selection.
# By default maim/slop has a 2px tolerance, so a click without a real drag is
# treated as a *window* selection -> the area keybind ends up capturing a window.
# `-t 0` disables window selection entirely, so only drag-select gives a region.
case " $* " in
    *" -s "*|*" --select "*)
        set -- "$@" -t 0
        ;;
esac

if maim "$@" "$FILE"; then
    xclip -selection clipboard -t image/png < "$FILE"

    # Share to every paired and reachable KDE Connect device (multi-device).
    # Runs in background so it never blocks the capture/notify.
    for dev in $(kdeconnect-cli -a --id-only 2>/dev/null); do
        [ -n "$dev" ] || continue
        kdeconnect-cli --share "$FILE" --device "$dev" >/dev/null 2>&1 &
    done

    notify-send "Screenshot" "Saved + copied + sent to connected devices" -t 2000
else
    notify-send "Screenshot" "Failed to capture" -u critical
fi
