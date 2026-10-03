#!/usr/bin/env bash
# Re-apply the CasaOS-UI local patches after a CasaOS update overwrites the
# web assets. Idempotent: safe to run repeatedly.
#
# Patch 1 (dotfiles): the built-in Files manager hides hidden (dot) files with
#   `return !item.name.startsWith(".");` -> replace with `return true;`.
# Patch 2 (markdown): the built-in MarkdownEditor.vue is BROKEN (hardcoded
#   placeholder content, never loads the file). Instead of enabling it, route
#   `.md` to the working code-editor (CodeMirror):
#     - keep `"mark-down-editor":typeMap['text-markdown'],` commented out
#     - append `typeMap['text-markdown']` to the 'code-editor' union
#
# Run: sudo bash ~/casaos-ui-patches.sh
set -euo pipefail

WWW=/var/lib/casaos/www
ts=$(date +%Y%m%d-%H%M%S)

py() { python3 - "$@"; }

# --- locate current chunk files (names change across builds) ---
home_chunk=$(ls -1 "$WWW"/src_views_Home_vue.*.js 2>/dev/null | grep -v '\.bak' | head -1)
app_chunk=$(ls -1 "$WWW"/app.*.js 2>/dev/null | grep -v '\.bak' | head -1)

if [ -z "$home_chunk" ] || [ -z "$app_chunk" ]; then
  echo "[FAIL] CasaOS UI chunks not found under $WWW" >&2
  exit 1
fi

cp -a "$home_chunk" "$home_chunk.bak-$ts"
cp -a "$app_chunk" "$app_chunk.bak-$ts"

# ---- Patch 1: show dotfiles ----
py "$home_chunk" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p, encoding="utf-8", errors="surrogateescape").read()
old = 'return !item.name.startsWith(".");'
new = 'return true; // dotfiles shown (patched)'
if old not in s:
    print("[skip] dotfiles: already applied")
elif s.count(old) != 1:
    print(f"[FAIL] dotfiles: expected 1 occurrence, found {s.count(old)}"); sys.exit(1)
else:
    open(p, "w", encoding="utf-8", errors="surrogateescape").write(s.replace(old, new))
    print("[ok]   dotfiles: patched")
PYEOF

# ---- Patch 2a: keep markdown editor disabled ----
py "$app_chunk" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p, encoding="utf-8", errors="surrogateescape").read()
active = """  \\"mark-down-editor\\":typeMap['text-markdown'],"""
commented = """  // \\"mark-down-editor\\":typeMap['text-markdown'],"""
if commented in s:
    print("[skip] markdown-editor stays disabled: already")
elif active in s:
    open(p, "w", encoding="utf-8", errors="surrogateescape").write(s.replace(active, commented))
    print("[ok]   markdown-editor disabled (it is broken upstream)")
else:
    print("[warn] markdown-editor line not found; skipping")
PYEOF

# ---- Patch 2b: route .md to the working code editor ----
py "$app_chunk" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p, encoding="utf-8", errors="surrogateescape").read()
old = "'code-editor': lodash_union__WEBPACK_IMPORTED_MODULE_1___default()(typeMap['text-x-generic'], typeMap['text-css'], typeMap['text-html'], typeMap['text-x-cmake'], typeMap['text-dockerfile']),"
new = "'code-editor': lodash_union__WEBPACK_IMPORTED_MODULE_1___default()(typeMap['text-x-generic'], typeMap['text-css'], typeMap['text-html'], typeMap['text-x-cmake'], typeMap['text-dockerfile'], typeMap['text-markdown']),"
if "typeMap['text-dockerfile'], typeMap['text-markdown']" in s:
    print("[skip] code-editor already handles markdown")
elif old in s:
    open(p, "w", encoding="utf-8", errors="surrogateescape").write(s.replace(old, new))
    print("[ok]   code-editor: markdown added")
else:
    print("[FAIL] code-editor line not found"); sys.exit(1)
PYEOF

# Bump mtime + restart gateway so new Last-Modified is served
touch "$home_chunk" "$app_chunk"
systemctl restart casaos-gateway

echo "Done. Hard-refresh the browser (and purge Cloudflare cache if needed)."
