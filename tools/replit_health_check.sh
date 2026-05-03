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

Expected one of: godot4, godot, godot4-headless, godot-headless.
If Replit's Nix package name changes, install a Godot 4 package through
the Dependencies tool or set GODOT_BIN to the available binary name.
EOF
  return 127
}

GODOT="$(resolve_godot)"

printf 'Killer Queen Replit health check\n'
printf 'Project root: %s\n' "$(pwd)"
printf 'Godot binary: %s\n' "$GODOT"
GODOT_VERSION="$("$GODOT" --version || true)"
printf '%s\n' "$GODOT_VERSION"

case "$GODOT_VERSION" in
  4.6*|4.7*|5.*)
    ;;
  *)
    cat >&2 <<'EOF'
Warning: this project is validated on Godot 4.6.1 or newer.
If Replit installed an older Godot package, update replit.nix through
Dependencies or set GODOT_BIN to a manually installed Godot 4.6+ binary.
EOF
    ;;
esac

"$GODOT" --headless --path "${GODOT_PROJECT_PATH:-.}" --script res://tools/run_engine_health_check.gd
