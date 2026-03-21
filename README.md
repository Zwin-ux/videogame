# Scrapyard Comet

Godot 4 prototype for a fast platformer-shooter with a jetpack, fuel pickups, simple drone enemies, and device-aware input prompts.

## Progress Video



## What is in the project

- A playable vertical slice in `res://scenes/main.tscn`
- Momentum-focused player controller with:
  - run acceleration
  - jump buffer
  - coyote time
  - feathered jetpack thrust
  - forward blaster fire
- Fuel cells that power the extraction pad
- Drone enemies that patrol and can be shot down
- HUD prompts powered by `godot-input-prompts`
- An Aseprite-ready art pipeline:
  - source files in `art/source`
  - exports in `art/export`
  - batch export script in `tools/export_aseprite.ps1`

## Controls

- `A / D` or left/right: run
- `Space`: jump
- `Left Shift`: jetpack
- `F` or left mouse: shoot
- `R`: restart the run

The project also has controller mappings enabled in `project.godot`.

## Open the project

Use Godot 4.6+ and open:

- `C:\Users\mzwin\Downloads\videogame`

The console binary already on this machine is:

- `C:\Users\mzwin\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe`

## Aseprite workflow

This repo is set up to use Aseprite as the sprite authoring tool, not as a runtime dependency inside Godot.

1. Put `.aseprite` source files in `art/source`
2. Export sheets with:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\export_aseprite.ps1
```

3. Import the exported PNG/JSON assets into Godot from `art/export`

## Next high-value improvements

- Replace the procedural placeholder art with Aseprite sprite sheets
- Add a real combat enemy that shoots back
- Add landing, jet burst, and hit animations
- Expand the level into multiple rooms with checkpoints
