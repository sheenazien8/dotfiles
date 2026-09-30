#!/bin/sh
# Area screen recording
# Select area with slop, then record that region

eval $(slop -f "X=%x Y=%y W=%w H=%h")

[ "$W" -eq 0 ] || [ "$H" -eq 0 ] && exit 0

OUT="$HOME/Screenshots/screenrec-$(date +%s).mp4"

notify-send "Recording" "Area recording started (${W}x${H})\nSaved to: $OUT" -t 2000

ffmpeg -f x11grab -video_size "${W}x${H}" -framerate 30 -i ":0.0+${X},${Y}" \
  -c:v libx264 -preset fast -crf 23 \
  -y "$OUT"

notify-send "Recording" "Area recording saved" -t 2000