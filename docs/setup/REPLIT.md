# Replit Setup

This project is a Godot action game. Replit is useful for code editing, GitHub sync, Replit Agent help, shell scripts, and headless validation. Keep the desktop Godot editor as the source of truth for scene authoring, tilemaps, animation setup, import settings, and final visual export review.

## Import From GitHub

Public repo quick import:

```text
https://replit.com/github.com/<owner>/<repo>
```

Private or guided import:

1. Open `https://replit.com/import`.
2. Choose GitHub.
3. Connect GitHub if needed.
4. Import the Killer Queen repo.

The repo includes `.replit`, `replit.nix`, and `project.godot` so Replit can detect the project shape during import.

## Run Button

The Replit Run button executes:

```bash
bash tools/replit_health_check.sh
```

That script resolves the Godot binary and runs the existing engine health suite headlessly:

```bash
godot --headless --path . --script res://tools/run_engine_health_check.gd
```

This is intentional. Replit should prove the project is still structurally healthy instead of trying to replace the desktop editor.

## Replit Agent Guardrail

Use this instruction when asking Replit Agent to work in the repo:

```text
This is a Godot 4 action game. Edit GDScript, docs, and deterministic tooling safely. Do not rename assets, scene paths, node names, exported variables, input actions, autoloads, or resource paths unless asked. Preserve the desktop Godot editor as the source of truth for visual scene edits and import settings. Keep trailer and capture tooling deterministic.
```

Good Replit tasks:

- GDScript bug fixes
- docs and GitHub-ready cleanup
- deterministic capture and export scripts
- health checks and CI-style validation
- small data/resource edits where paths stay stable

Avoid doing these in Replit unless you verify in desktop Godot afterward:

- tilemap authoring
- animation setup
- import presets
- scene hierarchy rewrites
- final exports

## Web Export

The helper is ready, but it requires a committed Godot export preset named `Web`:

```bash
bash tools/replit_export_web.sh
```

Current repo state has a Windows export preset. Add the Web preset from desktop Godot first, commit `export_presets.cfg`, then run the script in Replit.

Output path:

```text
dist/replit-web/index.html
```

`dist/` is ignored by Git, so exported builds do not pollute the repo.

## Troubleshooting

If Replit cannot find Godot, check the installed binary:

```bash
which godot4 || which godot || which godot4-headless || which godot-headless
```

Then set:

```bash
export GODOT_BIN=<binary-name>
```

If the Nix package name changes, update `replit.nix` through Replit's Dependencies tool and rerun the health check.

If Replit installs an older Godot build, the health check will warn before running. This repo is validated on Godot `4.6.1` or newer. Use a Godot 4.6+ binary through Replit Dependencies or set `GODOT_BIN` to a manually installed binary.

If Web export fails because export templates are missing, install matching Godot 4 export templates in the Replit environment or do the final export from desktop Godot. The script is a convenience path, not the only release path.

If the project works in Replit headless but looks wrong visually, verify in desktop Godot. Replit validation is not a replacement for opening `scenes/main.tscn`, checking the chamber, and confirming playable feel.
