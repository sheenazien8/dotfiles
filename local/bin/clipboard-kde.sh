#!/bin/bash
# Mirror clipboard text to ALL paired+reachable KDE Connect devices.
# Multi-device: the device list is rebuilt on every send, so any phone/tablet
# that is currently connected receives the clipboard automatically.
LAST_CLIP=""

while clipnotify; do
    # Only proceed if the clipboard actually offers plain text
    if ! xclip -selection clipboard -t TARGETS -o 2>/dev/null | grep -q 'text/plain'; then
        continue
    fi

    # Grab the text content explicitly (not binary/image data)
    CLIP=$(xclip -o -selection clipboard -t text/plain 2>/dev/null | tr -d '\0' | head -c 50000)

    # Skip empty, whitespace-only, or unchanged content
    [[ -z "$CLIP" ]] && continue
    [[ "$CLIP" == "$LAST_CLIP" ]] && continue
    [[ "$CLIP" =~ ^[[:space:]]*$ ]] && continue

    LAST_CLIP="$CLIP"

    # Send to every paired and reachable device
    mapfile -t DEVICES < <(kdeconnect-cli -a --id-only 2>/dev/null)
    for dev in "${DEVICES[@]}"; do
        [ -n "$dev" ] || continue
        kdeconnect-cli --share-text "$CLIP" --device "$dev" >/dev/null 2>&1
    done
done
