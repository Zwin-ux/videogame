# THREAD PROMPTS

## Prompt A: Background Package

You are working in `C:\Users\mzwin\Downloads\videogame`.

Read these first:
- `C:\Users\mzwin\Downloads\videogame\DESIGN.md`
- `C:\Users\mzwin\Downloads\videogame\METROIDVANIA-PIVOT.md`
- `C:\Users\mzwin\Downloads\videogame\art\source\REGION_ART_DIRECTION.md`
- `C:\Users\mzwin\Downloads\videogame\art\source\BACKGROUND_PACKAGE_01.md`
- `C:\Users\mzwin\Downloads\videogame\scripts\backdrop.gd`
- `C:\Users\mzwin\Downloads\videogame\scripts\main.gd`
- `C:\Users\mzwin\Downloads\videogame\scenes\main.tscn`

Goal:
Build the first real background package for Killer Queen covering the Hive Shaft and Sunset Ruin Skyline regions.

Product direction:
- The current tower is the forced-ascent intro of a metroidvania, not a standalone arcade room.
- The background should tell that story by starting as a pressured hive interior and opening toward a monumental sunset exterior.
- Favor strong region silhouettes, clear layer hierarchy, and gameplay readability over decoration-first rendering.

Hard constraints:
- Do not rewrite the gameplay scene architecture.
- Keep the backdrop Godot-native and easy to swap later.
- Preserve clear contrast between player, hazards, platforms, and background.
- The skyline must feel monumental and exterior.
- The hive must feel constricting, industrial, and insect-ridden.
- Keep the bright danger read reserved for hazards and the kill floor.

Expected deliverables:
- A region-aware runtime backdrop package.
- A clean breach transition from hive interior into sunset skyline.
- Any notes needed for future final-art replacement.

Acceptance criteria:
- The lower climb reads as Hive Shaft.
- The upper climb reads as Sunset Ruin Skyline.
- The transition sells “escape into a larger world.”
- The project still boots cleanly in Godot.

Validation:
- `& 'C:\Users\mzwin\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --headless --editor --path 'C:\Users\mzwin\Downloads\videogame' --quit`
- `& 'C:\Users\mzwin\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --headless --path 'C:\Users\mzwin\Downloads\videogame' --quit`

## Prompt B: Platform Tileset Package

You are working in `C:\Users\mzwin\Downloads\videogame`.

Read these first:
- `C:\Users\mzwin\Downloads\videogame\DESIGN.md`
- `C:\Users\mzwin\Downloads\videogame\PIXEL-ART-FUNDAMENTALS.md`
- `C:\Users\mzwin\Downloads\videogame\ASEPRITE-ART-PASS-01.md`
- `C:\Users\mzwin\Downloads\videogame\METROIDVANIA-PIVOT.md`
- `C:\Users\mzwin\Downloads\videogame\art\source\REGION_ART_DIRECTION.md`
- `C:\Users\mzwin\Downloads\videogame\scenes\main.tscn`
- `C:\Users\mzwin\Downloads\videogame\scripts\main.gd`
- `C:\Users\mzwin\Downloads\videogame\scripts\player.gd`
- `C:\Users\mzwin\Downloads\videogame\scripts\backdrop.gd`

Goal:
Build the first platform tileset package for Killer Queen so the world matches the current player and hazard quality bar.

Product direction:
- This is a SNES-inspired metroidvania with a forced-ascent intro and later exploration.
- The platform art should feel authored, region-specific, and readable at gameplay scale.
- Prioritize silhouette clarity, collision readability, and strong tile identity over texture noise.

Hard constraints:
- Do not add new gameplay systems.
- Do not rewrite the existing player or hazard pipeline.
- Keep the first package focused on the current regions: Hive Shaft and Sunset Ruin Skyline.
- Favor reusable tile pieces and a small, disciplined palette per region.
- Avoid generic modular blocks, noisy outlines, and overdecorated surfaces.
- Keep backgrounds and platforms readable against the player sprite at the current camera zoom.
- Use Godot-native assets and scenes; keep integration simple and maintainable.

Expected deliverables:
- A first platform tileset package with distinct region variants.
- Exported sprite sheets or equivalent art assets under `art/export`.
- Notes for frame or tile order under `art/source`.
- Any minimal scene hookup needed to preview the tiles in-engine.

Acceptance criteria:
- The platform art clearly matches the current player and hazard visual quality.
- Hive Shaft and Sunset Ruin tiles are distinct at a glance.
- Collision tops, undersides, and edges read cleanly in-game.
- The project still boots cleanly in Godot.
- The art is usable for the next implementation pass without rework.

Validation:
- `& 'C:\Users\mzwin\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --headless --editor --path 'C:\Users\mzwin\Downloads\videogame' --quit`
- `& 'C:\Users\mzwin\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --headless --path 'C:\Users\mzwin\Downloads\videogame' --quit`

## Prompt C: Safe-Zone Handoff

You are working in `C:\Users\mzwin\Downloads\videogame`.

Read these first:
- `C:\Users\mzwin\Downloads\videogame\DESIGN.md`
- `C:\Users\mzwin\Downloads\videogame\METROIDVANIA-PIVOT.md`
- `C:\Users\mzwin\Downloads\videogame\scripts\main.gd`
- `C:\Users\mzwin\Downloads\videogame\scripts\player.gd`
- `C:\Users\mzwin\Downloads\videogame\scripts\backdrop.gd`
- `C:\Users\mzwin\Downloads\videogame\scenes\main.tscn`
- `C:\Users\mzwin\Downloads\videogame\scenes\player.tscn`

Goal:
Design and implement the first safe-zone room plus the handoff from the forced-ascent intro into exploration.

Product direction:
- The game starts as a vertical escape chapter, then opens into a real metroidvania world.
- The safe zone should feel like a structural and emotional reset, not just a room with a save point.
- This transition must make the world feel larger without losing the current movement identity.

Hard constraints:
- Do not add sprawling world generation.
- Do not add a save/load system unless absolutely required for the handoff.
- Keep the transition authored and deterministic.
- Preserve the current movement tuning and keep the opening escape loop intact.
- Avoid overengineering: use the existing scene structure and Godot-native nodes.
- Keep the safe zone visually calmer than the escape shaft, but still on-brand for Killer Queen.
- The handoff should be immediate and clear to the player.

Expected deliverables:
- A playable safe-zone room or hub area.
- A clean transition from the opening ascent into exploration.
- Any minimal camera, door, trigger, or state logic needed to support the handoff.
- HUD and copy updates if the current text still frames the game like a mission instead of a world.
- If needed, a small amount of region art integration to make the transition read correctly.

Acceptance criteria:
- The opening still works as a forced ascent.
- Reaching the safe zone clearly changes the player’s relationship to the world.
- Exploration begins without confusion about where to go or what changed.
- The flow feels authored, not like a generic level end.
- The project boots and the transition path is stable.

Validation:
- `& 'C:\Users\mzwin\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --headless --editor --path 'C:\Users\mzwin\Downloads\videogame' --quit`
- `& 'C:\Users\mzwin\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --headless --path 'C:\Users\mzwin\Downloads\videogame' --quit`
