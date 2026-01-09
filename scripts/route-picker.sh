#!/usr/bin/env bash

# Usage:
#   ./route-picker.sh route_list.json
#   php artisan r:l --json | ./route-picker.sh

if [ -t 0 ] && [ -z "$1" ]; then
  echo "Usage: $0 route_list.json OR php artisan r:l --json | $0"
  exit 1
fi

# Load .env (optional)
if [ -f ".env" ]; then
  APP_URL=$(grep -E '^APP_URL=' .env | cut -d '=' -f2-)
  API_TOKEN=$(grep -E '^API_TOKEN=' .env | cut -d '=' -f2-)
else
  APP_URL="http://localhost:8000/"
  API_TOKEN=${API_TOKEN:-}
fi

# --- Read JSON ---
if [ -n "$1" ]; then
  ROUTES=$(jq -r '.[] | [.method, .uri, .name, .action] | @tsv' "$1")
else
  ROUTES=$(jq -r '.[] | [.method, .uri, .name, .action] | @tsv')
fi

# --- Pick route ---
SELECTED=$(echo "$ROUTES" | column -t -s$'\t' | fzf --height=40% --layout=reverse --ansi)

if [ -z "$SELECTED" ]; then
  echo "No route selected."
  exit 0
fi

METHOD=$(echo "$SELECTED" | awk '{print $1}' | cut -d'|' -f1)
URI=$(echo "$SELECTED" | awk '{print $2}')
NAME=$(echo "$SELECTED" | awk '{print $3}')
ACTION=$(echo "$SELECTED" | awk '{print $4}' | sed 's/@.*//' | awk -F'\\\\' '{print $NF}')

# --- Build httpie command ---
if [ -n "$API_TOKEN" ]; then
  HTTP_CMD="http -A bearer -a $API_TOKEN $METHOD $APP_URL$URI"
else
  HTTP_CMD="http $METHOD $APP_URL$URI"
fi

# --- Ask user which column to copy (your original working logic) ---
CHOICE=$(
  printf "method\t$METHOD\nuri\t$URI\nname\t$NAME\naction\t$ACTION\nhttpie\t$HTTP_CMD\n" \
    | column -t -s$'\t' \
    | fzf --height=20% --layout=reverse --ansi --prompt="Copy which column? > "
)

KEY=$(echo "$CHOICE" | awk '{print $1}')
VALUE=$(echo "$CHOICE" | cut -d' ' -f2-)

case "$KEY" in
  method)   TO_COPY="$METHOD" ;;
  uri)      TO_COPY="$URI" ;;
  name)     TO_COPY="$NAME" ;;
  action)   TO_COPY="$ACTION" ;;
  httpie)   TO_COPY="$HTTP_CMD" ;;
  *)        echo "Cancelled."; exit 0 ;;
esac

echo -n "$TO_COPY" | pbcopy
osascript -e "display notification \"Copied $KEY to clipboard\" with title \"Route Picker\""
echo "✅ Copied ($KEY): $TO_COPY"


