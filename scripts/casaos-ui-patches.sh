#!/usr/bin/env bash
# Re-apply the CasaOS-UI local patches after a CasaOS update overwrites the
# web assets. Idempotent: safe to run repeatedly.
#
# Patch 1 (dotfiles): the built-in Files manager hides hidden (dot) files with
#   `return !item.name.startsWith(".");` -> replace with `return true;`.
# Patch 2 (markdown): the markdown viewer is disabled upstream with a commented
#   line `// "mark-down-editor":typeMap['text-markdown'],` -> uncomment it.
#
# Run: sudo bash ~/casaos-ui-patches.sh
set -euo pipefail

WWW=/var/lib/casaos/www
ts=$(date +%Y%m%d-%H%M%S)

patch_file() {
  local file="$1"; shift
  python3 - "$file" "$@" <<'PYEOF'
import sys
path, old, new, label = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
s = open(path, encoding="utf-8", errors="surrogateescape").read()
if old not in s:
    print(f"[skip] {label}: already applied (no target string found)")
    sys.exit(0)
n = s.count(old)
if n != 1:
    print(f"[FAIL] {label}: expected 1 occurrence, found {n}")
    sys.exit(1)
open(path, "w", encoding="utf-8", errors="surrogateescape").write(s.replace(old, new))
print(f"[ok]   {label}: patched")
PYEOF
}

# --- locate current chunk files (names change across builds) ---
home_chunk=$(ls -1 "$WWW"/src_views_Home_vue.*.js 2>/dev/null | grep -v '\.bak' | head -1)
app_chunk=$(ls -1 "$WWW"/app.*.js 2>/dev/null | grep -v '\.bak' | head -1)

if [ -z "$home_chunk" ] || [ -z "$app_chunk" ]; then
  echo "[FAIL] CasaOS UI chunks not found under $WWW" >&2
  exit 1
fi

cp -a "$home_chunk" "$home_chunk.bak-$ts"
cp -a "$app_chunk" "$app_chunk.bak-$ts"

# Patch 1: show dotfiles
patch_file "$home_chunk" \
  'return !item.name.startsWith(".");' \
  'return true; // dotfiles shown (patched)' \
  "dotfiles ($(basename "$home_chunk"))"

# Patch 2: enable markdown viewer
patch_file "$app_chunk" \
  '// \"mark-down-editor\":typeMap['"'"'text-markdown'"'"'],' \
  '\"mark-down-editor\":typeMap['"'"'text-markdown'"'"'],' \
  "markdown viewer ($(basename "$app_chunk"))"

# Bump mtime + restart gateway so new Last-Modified is served
touch "$home_chunk" "$app_chunk"
systemctl restart casaos-gateway

echo "Done. Hard-refresh the browser (and purge Cloudflare cache if needed)."
