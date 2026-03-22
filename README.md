# Killer Queen

Godot 4 prototype for a 2D jetpack action-metroidvania. The opening fantasy is a forced upward escape through a hive-city shaft; once you reach safety, the longer-term direction is a broader explorable world of ruins, overgrowth, and bio-industrial structures.

## Progress Video



## What is in the project

- A playable vertical slice in `res://scenes/main.tscn`
- Momentum-focused player controller with:
  - run acceleration
  - jump buffer
  - coyote time
  - burst-driven jetpack recovery
  - wall slide and wall kick
  - forward blaster fire
- Animated player and hazard sprite-sheet scaffolds
- Drone and mine hazards
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

## Itch.io build

This repo now includes a Windows desktop export preset for itch.io in `export_presets.cfg`.

To build and zip the itch.io package on this machine:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\package_itchio.ps1
```

The script exports the game to `dist\itchio\windows\KillerQueen.exe`, copies the Windows README, and creates a zip ready for upload.

Page copy and release notes live in:

- `release/itchio/ITCHIO-PAGE-COPY.md`
- `release/itchio/WINDOWS-README.txt`

## Aseprite workflow

This repo is set up to use Aseprite as the sprite authoring tool, not as a runtime dependency inside Godot.

1. Put `.aseprite` source files in `art/source`
2. Export sheets with:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\export_aseprite.ps1
```

3. Import the exported PNG/JSON assets into Godot from `art/export`

## Next high-value improvements

- Lock the first 20 seconds of the escape tower for feel and readability
- Build the platform tileset so the world matches the player and hazard bar
- Expand the backdrop into the sunset-ruin and overgrowth themes described in `DESIGN.md`
- Turn the tower into the opening chapter of the eventual metroidvania map
