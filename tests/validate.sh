#!/usr/bin/env bash
# Full-stack validation for Killer Queen.
#
# Runs every check we can automate, in order of cheapness. Exits non-zero
# on the first failure and prints a coloured summary so CI / local devs see
# at a glance what broke. Order matters — early stages catch the broadest
# classes of errors.
#
# Stages:
#   1. Reserved-keyword scan (static grep) — 0.01s
#   2. GDScript parse / import sweep       — ~3s
#   3. Scene + script load smoke           — ~5s
#   4. Unit + integration test suite       — ~1s
#
# Usage:
#   tests/validate.sh                   # normal run
#   GODOT=... tests/validate.sh         # pin Godot binary
#   tests/validate.sh --fast            # skip stage 3 (scene load)

set -euo pipefail

GODOT_BIN="${GODOT:-godot}"
if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
    echo "[!] Godot binary '$GODOT_BIN' not on PATH. Set GODOT=... or add to PATH."
    exit 2
fi

FAST_MODE=0
for arg in "$@"; do
    case "$arg" in
        --fast) FAST_MODE=1 ;;
    esac
done

cd "$(dirname "$0")/.."

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; exit 1; }
stage() { echo -e "\n${BOLD}[$1]${NC} $2"; }

stage 1 "Reserved-keyword scan"
# GDScript 4 reserved words that are easy to accidentally shadow as locals
# or loop vars. This list is conservative — tune when false positives show.
RESERVED_PATTERN='\b(for|var|let)\s+(breakpoint|match|extends|func|class|signal|static|enum|self|super|void|in|is|as|return|break|continue|pass|const)\b'
if grep -rnE "$RESERVED_PATTERN" scripts/ tests/ 2>/dev/null | grep -v '^Binary'; then
    fail "reserved keyword used as identifier"
else
    pass "no reserved-keyword collisions"
fi

stage 2 "Project import / parse sweep"
IMPORT_LOG=$(mktemp)
if "$GODOT_BIN" --headless --import >"$IMPORT_LOG" 2>&1; then
    # Import may exit 0 but still log parse errors. Scan the log.
    if grep -qE 'Parse Error|Failed to load script|Failed to instantiate' "$IMPORT_LOG"; then
        echo -e "${RED}--- parse errors found in import log ---${NC}"
        grep -E 'Parse Error|Failed to load script|Failed to instantiate' "$IMPORT_LOG" | head -20
        fail "parse errors logged during import"
    fi
    pass "project imports clean"
else
    echo -e "${RED}--- import failed ---${NC}"
    tail -40 "$IMPORT_LOG"
    fail "godot --import exited non-zero"
fi
rm -f "$IMPORT_LOG"

if [[ "$FAST_MODE" -eq 0 ]]; then
    stage 3 "Scene + script load smoke"
    VALIDATE_LOG=$(mktemp)
    if "$GODOT_BIN" --headless --script tests/validate_scenes.gd >"$VALIDATE_LOG" 2>&1; then
        if grep -q '=== GREEN ===' "$VALIDATE_LOG"; then
            SUMMARY=$(grep -E 'scenes checked|scripts checked|failures:' "$VALIDATE_LOG" | tr '\n' ' ')
            pass "all scenes + scripts load ($SUMMARY)"
        else
            echo -e "${RED}--- scene-load output ---${NC}"
            tail -40 "$VALIDATE_LOG"
            fail "scene load smoke did not reach GREEN"
        fi
    else
        echo -e "${RED}--- scene-load output ---${NC}"
        tail -40 "$VALIDATE_LOG"
        fail "scene / script load smoke failed"
    fi
    rm -f "$VALIDATE_LOG"
else
    echo -e "${YELLOW}  [skipped] scene load smoke (--fast)${NC}"
fi

stage 4 "Unit + integration test suite"
TEST_LOG=$(mktemp)
if "$GODOT_BIN" --headless --script tests/run_tests.gd >"$TEST_LOG" 2>&1; then
    if grep -q '=== GREEN ===' "$TEST_LOG"; then
        SUMMARY=$(grep -E '^[0-9]+ / [0-9]+ suites' "$TEST_LOG" | head -1)
        pass "test suite GREEN ($SUMMARY)"
    else
        echo -e "${RED}--- test output ---${NC}"
        tail -40 "$TEST_LOG"
        fail "test suite did not reach GREEN"
    fi
else
    echo -e "${RED}--- test output ---${NC}"
    tail -40 "$TEST_LOG"
    fail "test suite exit non-zero"
fi
rm -f "$TEST_LOG"

echo -e "\n${GREEN}${BOLD}=== ALL GREEN ===${NC}\n"
