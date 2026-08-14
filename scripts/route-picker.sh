#!/usr/bin/env bash

# Usage:
#   ./route-picker.sh route_list.json
#   php artisan r:l --json | ./route-picker.sh
#   ./route-picker.sh postman_collection.json

# --- OS detection ---
case "$(uname -s)" in
  Darwin) OS="macos";;
  Linux)  OS="linux";;
  *)      OS="unknown";;
esac

# --- Clipboard helper ---
clip_copy() {
  local input
  input=$(cat)
  case "$OS" in
    macos)  echo -n "$input" | pbcopy;;
    linux)
      if command -v xclip &>/dev/null; then
        echo -n "$input" | xclip -selection clipboard
      elif command -v xsel &>/dev/null; then
        echo -n "$input" | xsel --clipboard --input
      elif command -v wl-copy &>/dev/null; then
        echo -n "$input" | wl-copy
      else
        echo -n "$input"
      fi
      ;;
    *) echo -n "$input";;
  esac
}

# --- Notification helper ---
notify() {
  local title="$1" body="$2"
  case "$OS" in
    macos)  osascript -e "display notification \"$body\" with title \"$title\"";;
    linux)
      if command -v notify-send &>/dev/null; then
        notify-send "$title" "$body"
      fi
      ;;
  esac
}

# --- Detect JSON format ---
detect_format() {
  python3 -c "
import json, sys
try:
    with open('$1') as f:
        d = json.load(f)
    if isinstance(d, dict) and 'info' in d and '_postman_id' in d.get('info', {}):
        print('postman')
    elif isinstance(d, list) and len(d) > 0 and 'uri' in d[0]:
        print('laravel')
    else:
        print('unknown')
except Exception:
    print('unknown')
" 2>/dev/null
}

# --- Convert Postman to normalized JSON (on-the-fly) ---
convert_postman() {
  python3 - "$1" <<'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)

def flatten(items, folderPath=[]):
    routes = []
    for item in items:
        if 'item' in item:
            routes.extend(flatten(item['item'], folderPath + [item['name']]))
        elif 'request' in item:
            req = item['request']
            url = req.get('url', {}) if isinstance(req.get('url'), dict) else {'raw': req.get('url', '')}
            raw = url.get('raw', '')
            clean = raw
            for v in ['{{url}}', '{{base_url}}', '{{host}}', '{{baseUrl}}']:
                clean = clean.replace(v, '')
            if '://' in clean:
                after = clean.split('://', 1)[1]
                clean = after.split('/', 1)[1] if '/' in after else ''
            clean = clean.split('?')[0]

            body = req.get('body')
            payload = None
            body_mode = None
            if body:
                body_mode = body.get('mode')
                if body_mode == 'raw':
                    payload = body.get('raw')
                elif body_mode == 'formdata':
                    payload = body.get('formdata')
                elif body_mode == 'urlencoded':
                    payload = body.get('urlencoded')

            routes.append({
                'method': req.get('method', '???'),
                'uri': clean,
                'name': item.get('name', ''),
                'action': ' › '.join(folderPath + [item.get('name', '')]),
                '_source': 'postman',
                '_details': {
                    'full_url': raw,
                    'query': url.get('query', []),
                    'headers': req.get('header', []),
                    'auth': req.get('auth'),
                    'body_mode': body_mode,
                    'payload': payload
                }
            })
    return routes

json.dump(flatten(data.get('item', [])), sys.stdout)
PYEOF
}

if [ -t 0 ] && [ -z "$1" ]; then
  echo "Usage: $0 route_list.json OR php artisan r:l --json | $0 OR $0 postman_collection.json"
  exit 1
fi

# Load .env (optional) — only if not already set via env var
if [ -f ".env" ]; then
  APP_URL=${APP_URL:-$(grep -E '^APP_URL=' .env | cut -d '=' -f2-)}
  API_TOKEN=${API_TOKEN:-$(grep -E '^API_TOKEN=' .env | cut -d '=' -f2-)}
fi
APP_URL=${APP_URL:-http://localhost:8000/}
API_TOKEN=${API_TOKEN:-}

# --- Read JSON ---
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

JSON_FILE=""
if [ -n "$1" ]; then
  FORMAT=$(detect_format "$1")
  if [ "$FORMAT" = "postman" ]; then
    convert_postman "$1" > "$TMPDIR/routes.json"
    JSON_FILE="$TMPDIR/routes.json"
  elif [ "$FORMAT" = "laravel" ]; then
    JSON_FILE="$1"
  else
    echo "Unrecognized JSON format. Expected Laravel routes list or Postman Collection v2.1."
    exit 1
  fi
else
  cat > "$TMPDIR/routes.json"
  FORMAT=$(detect_format "$TMPDIR/routes.json")
  if [ "$FORMAT" = "postman" ]; then
    convert_postman "$TMPDIR/routes.json" > "$TMPDIR/routes_converted.json"
    JSON_FILE="$TMPDIR/routes_converted.json"
  else
    JSON_FILE="$TMPDIR/routes.json"
  fi
fi

# --- Write preview script to temp file ---
cat > "$TMPDIR/preview.py" <<'PYEOF'
import json, sys
uri = sys.argv[2]
with open(sys.argv[1]) as f:
    routes = json.load(f)
for r in routes:
    if r.get('uri') == uri:
        lines = []
        lines.append(f"Method:   {r.get('method', 'N/A')}")
        lines.append(f"URI:      {r.get('uri', 'N/A')}")
        lines.append(f"Name:     {r.get('name', 'N/A')}")
        src = r.get('_source', 'laravel')
        if src == 'postman':
            d = r.get('_details', {})
            lines.append(f"Full URL: {d.get('full_url', 'N/A')}")
            lines.append(f"Folder:   {r.get('action', 'N/A')}")
            if d.get('query'):
                lines.append("")
                lines.append("Query Params:")
                for q in d['query']:
                    disabled = ' (disabled)' if q.get('disabled') else ''
                    lines.append(f"  {q.get('key')}: {q.get('value')}{disabled}")
            if d.get('headers'):
                lines.append("")
                lines.append("Headers:")
                for h in d['headers']:
                    lines.append(f"  {h.get('key')}: {h.get('value')}")
            if d.get('auth'):
                lines.append("")
                auth = d['auth']
                lines.append(f"Auth: {auth.get('type', 'none')}")
                if auth.get('type') == 'basic' and auth.get('basic'):
                    for cred in auth['basic']:
                        lines.append(f"  {cred.get('key')}: {cred.get('value')}")
            if d.get('payload') is not None:
                lines.append("")
                lines.append(f"Body ({d.get('body_mode', 'unknown')}):")
                payload = d['payload']
                if isinstance(payload, str):
                    for pl in payload.splitlines():
                        lines.append(f"  {pl}")
                elif isinstance(payload, list):
                    for p in payload:
                        ptype = f" ({p.get('type')})" if p.get('type') else ''
                        src_file = f" [file: {p.get('src')}]" if p.get('src') else ''
                        val = p.get('value', '')
                        lines.append(f"  {p.get('key')}: {val}{ptype}{src_file}")
                else:
                    lines.append(f"  {payload}")
        else:
            lines.append(f"Action:   {r.get('action', 'N/A')}")
            if r.get('middleware'):
                lines.append(f"Middleware: {', '.join(r['middleware'])}")
            if r.get('domain'):
                lines.append(f"Domain:   {r['domain']}")
        print('\n'.join(lines))
        break
PYEOF

# --- Write payload extractor to temp file ---
cat > "$TMPDIR/extract_payload.py" <<'PYEOF'
import json, sys
uri = sys.argv[2]
with open(sys.argv[1]) as f:
    routes = json.load(f)
for r in routes:
    if r.get('uri') == uri:
        lines = []
        d = r.get('_details', {})
        if d.get('query'):
            qparts = []
            for q in d['query']:
                if not q.get('disabled'):
                    qparts.append(f"{q['key']}={q['value']}")
            if qparts:
                lines.append(f"Query: ?{'&'.join(qparts)}")
        if d.get('headers'):
            lines.append("Headers:")
            for h in d['headers']:
                lines.append(f"  {h.get('key')}: {h.get('value')}")
        if d.get('auth'):
            auth = d['auth']
            lines.append(f"Auth: {auth.get('type', 'none')}")
            if auth.get('type') == 'basic' and auth.get('basic'):
                for cred in auth['basic']:
                    lines.append(f"  {cred.get('key')}: {cred.get('value')}")
        if d.get('payload') is not None:
            lines.append(f"Body ({d.get('body_mode', 'unknown')}):")
            payload = d['payload']
            if isinstance(payload, str):
                for pl in payload.splitlines():
                    lines.append(f"  {pl}")
            elif isinstance(payload, list):
                for p in payload:
                    ptype = f" ({p.get('type')})" if p.get('type') else ''
                    src_file = f" [file: {p.get('src')}]" if p.get('src') else ''
                    val = p.get('value', '')
                    lines.append(f"  {p.get('key')}: {val}{ptype}{src_file}")
            else:
                lines.append(f"  {payload}")
        print('\n'.join(lines))
        break
PYEOF

# --- Extract display list ---
ROUTES=$(jq -r '.[] | [.method, .uri, .name, .action] | @tsv' "$JSON_FILE")

# --- Pick route ---
SELECTED=$(echo "$ROUTES" | column -t -s$'\t' | fzf \
  --height=40% --layout=reverse --ansi \
  --preview "URI=\$(echo {} | awk '{print \$2}'); python3 '$TMPDIR/preview.py' '$JSON_FILE' \"\$URI\"" \
  --preview-window=right:50%:wrap)

if [ -z "$SELECTED" ]; then
  echo "No route selected."
  exit 0
fi

METHOD=$(echo "$SELECTED" | awk '{print $1}' | cut -d'|' -f1)
URI=$(echo "$SELECTED" | awk '{print $2}')
NAME=$(echo "$SELECTED" | awk '{print $3}')
ACTION=$(echo "$SELECTED" | awk '{print $4}' | sed 's/@.*//' | awk -F'\\' '{print $NF}')

# --- Build httpie command with query params + body ---
HTTP_ARGS=$(python3 - "$JSON_FILE" "$URI" <<'PYEOF'
import json, sys
uri = sys.argv[2]
with open(sys.argv[1]) as f:
    routes = json.load(f)
for r in routes:
    if r.get('uri') == uri:
        parts = []
        d = r.get('_details', {})
        if d.get('query'):
            for q in d['query']:
                if not q.get('disabled'):
                    parts.append(f"{q['key']}=={q['value']}")
        if d.get('payload') is not None:
            payload = d['payload']
            mode = d.get('body_mode', '')
            if mode == 'raw' and isinstance(payload, str):
                try:
                    obj = json.loads(payload)
                    if isinstance(obj, dict):
                        for k, v in obj.items():
                            parts.append(f"{k}={v}")
                    else:
                        parts.append(payload)
                except Exception:
                    parts.append(payload)
            elif isinstance(payload, list):
                for p in payload:
                    if p.get('type') == 'file':
                        parts.append(f"{p['key']}@{p.get('src', '')}")
                    else:
                        parts.append(f"{p['key']}={p.get('value', '')}")
            else:
                parts.append(str(payload))
        print(' '.join(parts))
        break
PYEOF
)

if [ -n "$API_TOKEN" ]; then
  HTTP_CMD="http -A bearer -a $API_TOKEN $METHOD $APP_URL$URI"
else
  HTTP_CMD="http $METHOD $APP_URL$URI"
fi

if [ -n "$HTTP_ARGS" ]; then
  HTTP_CMD="$HTTP_CMD $HTTP_ARGS"
fi

# --- Extract payload text for copying ---
PAYLOAD_TEXT=$(python3 "$TMPDIR/extract_payload.py" "$JSON_FILE" "$URI")

# --- Second fzf: pick what to copy ---
CHOICE=$(
  printf "method\t$METHOD\nuri\t$URI\nname\t$NAME\naction\t$ACTION\nhttpie\t$HTTP_CMD\npayload\t[payload]\n" \
    | column -t -s$'\t' \
    | fzf --height=25% --layout=reverse --ansi --prompt="Copy which column? > "
)

KEY=$(echo "$CHOICE" | awk '{print $1}')
VALUE=$(echo "$CHOICE" | cut -d' ' -f2-)

case "$KEY" in
  method)   TO_COPY="$METHOD" ;;
  uri)      TO_COPY="$URI" ;;
  name)     TO_COPY="$NAME" ;;
  action)   TO_COPY="$ACTION" ;;
  httpie)   TO_COPY="$HTTP_CMD" ;;
  payload)  TO_COPY="$PAYLOAD_TEXT" ;;
  *)        echo "Cancelled."; exit 0 ;;
esac

echo -n "$TO_COPY" | clip_copy
notify "Route Picker" "Copied $KEY to clipboard"
echo "✅ Copied ($KEY): $TO_COPY"
