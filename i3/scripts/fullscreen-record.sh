#!/bin/sh
# Fullscreen video recording
# Records 1920x1080, press Ctrl+C in terminal to stop

OUT="$HOME/Screenshots/screenrec-$(date +%s).mp4"

notify-send "Recording" "Fullscreen recording started\nSaved to: $OUT" -t 2000

ffmpeg -f x11grab -video_size 1920x1080 -framerate 30 -i :0.0 \
  -c:v libx264 -preset fast -crf 23 \
  -y "$OUT"

notify-send "Recording" "Fullscreen recording saved" -t 2000