#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

resolve_godot() {
  if [[ -n "${GODOT_BIN:-}" ]] && command -v "$GODOT_BIN" >/dev/null 2>&1; then
    printf '%s\n' "$GODOT_BIN"
    return 0
  fi

  local candidates=(
    godot4
    godot
    godot4-headless
    godot-headless
  )

  for candidate in "${candidates[@]}"; do
    if command -v "$candidate" >/dev/null 2>&1; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  cat >&2 <<'EOF'
Godot was not found in this Replit environment.
Set GODOT_BIN or install Godot 4 through Replit Dependencies before exporting.
EOF
  return 127
}

if [[ ! -f export_presets.cfg ]] || ! grep -q 'name="Web"' export_presets.cfg; then
  cat >&2 <<'EOF'
No Godot Web export preset named "Web" is committed yet.

Create the Web preset in the desktop Godot editor, commit the updated
export_presets.cfg, then rerun:

  bash tools/replit_export_web.sh
EOF
  exit 2
fi

GODOT="$(resolve_godot)"
OUT_DIR="dist/replit-web"
OUT_FILE="$OUT_DIR/index.html"

mkdir -p "$OUT_DIR"

printf 'Exporting Killer Queen Web build to %s\n' "$OUT_FILE"
"$GODOT" --headless --path "${GODOT_PROJECT_PATH:-.}" --export-release "Web" "$OUT_FILE"
