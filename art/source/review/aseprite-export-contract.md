# Aseprite Export Contract

This contract keeps the opening-slice art bundle tied to the current export pipeline.

Current exporter:

- `tools/export_aseprite.ps1`

Current exporter behavior:

- scans `art/source` recursively for `.aseprite` files
- exports a matching `.png` and `.json` into `art/export`
- uses the source filename as the export basename
- writes JSON in `json-array` format with tag data

## Naming Rules

- Use lowercase snake case for all new `.aseprite` sources.
- Keep one gameplay-facing asset family per source file.
- Basename parity is required:
  - `art/source/player_sheet.aseprite` -> `art/export/player_sheet.png` and `art/export/player_sheet.json`
  - `art/source/rival_hunter_sheet.aseprite` -> `art/export/rival_hunter_sheet.png` and `art/export/rival_hunter_sheet.json`
- Do not mix spaces, hyphens, or title case in sheet filenames.

## Sheet Grouping Rules

### Existing Required Sources

- `art/source/player_sheet.aseprite`
- `art/source/combat_fx_sheet.aseprite`

These remain the source of truth for current runtime-connected player and combat art.

### Recommended New Sources

- `art/source/rival_hunter_sheet.aseprite`
- `art/source/stage_01_tiles.aseprite`
- `art/source/stage_01_backgrounds.aseprite`
- `art/source/stage_01_props.aseprite`
- `art/source/hud_opening_slice.aseprite`
- optional: `art/source/combat_fx_sheet_boss.aseprite`

These names are chosen so the current exporter can pick them up without any new tooling.

## Tag And JSON Expectations

- Any animated source that the runtime reads by tag must keep stable tag names.
- JSON output is expected to remain `json-array` with `--list-tags`.
- If a sheet is runtime-addressed by name and tag, treat tag changes as breaking changes.
- If a source is visual-only and not yet runtime-addressed, name tags as if they may become runtime-facing later.

Existing runtime-sensitive tag families:

- player body and overlay tags in `player_sheet`
- slash and hit-confirm tags in `combat_fx_sheet`

## Opening Slice Asset Map

| Asset family | Source brief | Source file | Export target | Notes |
| --- | --- | --- | --- | --- |
| Player body and weapon overlays | `briefs/hero-player-brief.md` | `art/source/player_sheet.aseprite` | `art/export/player_sheet.png`, `art/export/player_sheet.json` | Preserve current tag contract |
| Weapon icons | `briefs/hero-player-brief.md` | `art/source/player_sheet.aseprite` or a shared HUD source | `art/export/weapon_icon_fang.png`, `art/export/weapon_icon_blaster.png` | Keep existing runtime paths stable |
| Combat FX | `briefs/fx-opening-slice-brief.md` | `art/source/combat_fx_sheet.aseprite` | `art/export/combat_fx_sheet.png`, `art/export/combat_fx_sheet.json` | Extend existing sheet first |
| Boss and route FX extension | `briefs/fx-opening-slice-brief.md` | `art/source/combat_fx_sheet_boss.aseprite` | `art/export/combat_fx_sheet_boss.png`, `art/export/combat_fx_sheet_boss.json` | Only if the main FX sheet gets crowded |
| Rival hunter | `briefs/rival-hunter-brief.md` | `art/source/rival_hunter_sheet.aseprite` | `art/export/rival_hunter_sheet.png`, `art/export/rival_hunter_sheet.json` | New boss sheet |
| Stage tiles | `briefs/stage-opening-slice-brief.md` | `art/source/stage_01_tiles.aseprite` | `art/export/stage_01_tiles.png` | Add JSON only if tag-driven |
| Stage backgrounds | `briefs/stage-opening-slice-brief.md` | `art/source/stage_01_backgrounds.aseprite` | `art/export/stage_01_backgrounds.png` | Static layered art is fine |
| Stage props | `briefs/stage-opening-slice-brief.md` | `art/source/stage_01_props.aseprite` | `art/export/stage_01_props.png` | Use for racks, cave props, and route cues |
| HUD and menu art | `briefs/hud-opening-slice-brief.md` | `art/source/hud_opening_slice.aseprite` | `art/export/hud_opening_slice.png`, `art/export/hud_opening_slice.json` | Consolidate front-door and HUD art |

## Legacy Menu Asset Rule

Current runtime menu assets already in `art/export`:

- `menu_console_logo.png`
- `menu_console_window.png`
- `menu_console_atlas.png`
- `menu_console_cursor.png`

Treat these as legacy exports until a new authored HUD source replaces them.
Do not create a second ad hoc menu art path.
Fold future front-door art into `hud_opening_slice.aseprite`.

## Authoring Rules

- Every new brief must name its export target before art starts.
- Every new prompt pack must point back to one source brief.
- Do not create one-off export names that bypass the snake-case convention.
- If an asset is too broad for one sheet, split by function, not by whim.
- If runtime code already points to a path, preserve that path until code is deliberately updated.

## Pre-Export Checklist

- source filename follows snake case
- target export basename is known in advance
- tag names are stable and spelled exactly
- canvas sizes are intentional
- the sheet still reads at gameplay zoom before export
- no asset in the sheet violates the opening-slice palette and staging rules
