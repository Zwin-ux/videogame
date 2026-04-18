#!/usr/bin/env bash
# Hive Signal test runner. Requires Godot 4.6+ on PATH, or GODOT env var.
set -euo pipefail

GODOT_BIN="${GODOT:-godot}"
if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
    echo "[!] '$GODOT_BIN' not found on PATH."
    echo "    Install Godot 4.6+ and add it to PATH, or set GODOT=..."
    exit 2
fi

cd "$(dirname "$0")/.."
exec "$GODOT_BIN" --headless --script tests/run_tests.gd
