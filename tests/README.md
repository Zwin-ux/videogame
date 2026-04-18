# Killer Queen Tests — Hive Signal Test Suite

Tiny home-grown test harness for the 0.2 juice-pass autoloads.

## Run

Requires a Godot 4.6+ binary on PATH.

```bash
# From project root
godot --headless --script tests/run_tests.gd
```

or via the thin batch / shell wrappers:

```bash
# Windows
tests/run_tests.bat

# Linux / mac / git bash
bash tests/run_tests.sh
```

Exits `0` on all-green, `1` on any failure. CI-safe.

## What gets tested

- `test_sound_bank.gd`   — manifest completeness, procedural synthesis, pool voice-steal, mute
- `test_camera_shake.gd` — kick clamps, preset lookup, register/unregister, trauma decay
- `test_hit_stop.gd`     — freeze / restore, frame conversion, cancel, disable
- `test_music_engine.gd` — intensity clamp, stem threshold gating, bump + decay, mute
- `test_wiring.gd`       — the `_service()` helper used by `bullet.gd` / `slash_hitbox.gd`
                            resolves to the right autoload at runtime

Each test file is one script, one extends `RefCounted`, one `run()` method.
Assertions use a tiny inline `Ass` helper — no GUT dependency, no gdUnit.

## Adding a test

1. Add a file `tests/test_<thing>.gd`.
2. Match the `extends RefCounted` + `run()` pattern from the existing files.
3. Register it in `tests/run_tests.gd` under `TESTS`.
