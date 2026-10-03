#!/usr/bin/env bash
# Add a shortcut to the CasaOS "Files" sidebar.
#
# CasaOS only shows sidebar shortcuts whose target is a direct child of `/` or
# `/DATA` (the sidebar gate checks the folder appears in that listing). So if the
# target lives elsewhere (e.g. /home/...), we drop a symlink in /DATA and point
# the shortcut at the symlink.
#
# Usage: sudo bash ~/casaos-add-shortcut.sh <Name> <absolute-path>
# Example: sudo bash ~/casaos-add-shortcut.sh Workspace /home/sheenazien8/.openclaw/workspace
set -euo pipefail

NAME="${1:-}"
TARGET="${2:-}"
if [ -z "$NAME" ] || [ -z "$TARGET" ]; then
  echo "Usage: sudo bash $0 <Name> <absolute-path>" >&2
  exit 1
fi
if [ ! -d "$TARGET" ]; then
  echo "ERROR: target is not a directory: $TARGET" >&2
  exit 1
fi

DATA=/DATA
SC=/var/lib/casaos/1/shortcut.json

# Decide the path the sidebar should point at.
dir="$(dirname "$TARGET")"
if [ "$dir" = "/DATA" ] || [ "$dir" = "/" ]; then
  # Target already a direct child of / or /DATA -> use it as-is.
  LINK_PATH="$TARGET"
elif [ -e "/DATA/$NAME" ]; then
  # A /DATA/<Name> path already exists (real dir or symlink) -> reuse it.
  LINK_PATH="/DATA/$NAME"
  echo "reusing existing: $LINK_PATH"
else
  LINK_PATH="/DATA/$NAME"
  ln -sfn "$TARGET" "$LINK_PATH"
  echo "symlink: $LINK_PATH -> $TARGET"
fi

# Append (or replace same-name) entry in shortcut.json
python3 - "$SC" "$NAME" "$LINK_PATH" <<'PYEOF'
import json, sys, os
path, name, link = sys.argv[1], sys.argv[2], sys.argv[3]
if os.path.exists(path):
    try:
        data = json.load(open(path))
    except Exception:
        data = []
else:
    data = []
if not isinstance(data, list):
    data = []
data = [e for e in data if e.get("name") != name]
data.append({
    "name": name, "path": link, "type": "folder", "icon": "folder",
    "pack": "casa", "visible": True, "selected": True, "extensions": None,
})
json.dump(data, open(path, "w"), indent=2)
print("shortcut added:", name, "->", link)
PYEOF

systemctl restart casaos-user-service
echo "Done. Open CasaOS -> Files and reload (hard-refresh)."
