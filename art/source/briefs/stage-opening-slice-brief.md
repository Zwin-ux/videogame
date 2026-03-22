# Stage Opening Slice Brief

## Purpose

Define the environment art for the opening slice so the first 10 minutes feel authored, readable, and distinct.
This brief covers the starter armory, first shaft, cave foyer, boss arena, and the route-out corridor toward the ski-line direction.

## Camera/Scale

- Built for side-view gameplay read, not concept-art framing
- Platforms and route cues must hold at gameplay zoom while the player is moving fast
- Use 3 to 5 background layers with disciplined contrast separation
- Review every room with the player, one threat, one effect, and one UI strip visible

Asset groups:

- armory deck and racks
- shaft tiles and support language
- cave foyer threshold
- boss arena floor, wall, and platform set
- route-out corridor and mountain-facing cue layer

## Silhouette

- Armory should use rails, rack spacing, and ceremonial deck striping
- Shaft should use ribbed vertical constriction and broken service braces
- Cave foyer should use one strong arch or threshold mass
- Boss arena should read as a duel room first, cave second
- Route-out corridor should point forward with a strong lateral vector

Required room reads:

- active starter rack
- next safe platform
- cave mouth destination
- rival intro stage line
- boss weak-state readable zone
- exit line after victory

## Palette

- Armory: steel slate, muted teal, warm gold rack pulse, restrained cream practicals
- Shaft: foundry blue, oxidized teal, amber warning seams, deep navy voids
- Cave: basalt blue-black, bone stone edges, old amber practicals
- Boss arena: slightly warmer cave stone with quiet ember seams for tension
- Route-out corridor: cave darks opening into dusk violet, hot rust rose, and gold distance color

Rules:

- platform tops and collision edges stay cleaner than wall decoration
- active rack pulse is the only hot accent in the armory choice beat
- cave practicals stay dim until they are doing a gameplay job
- route-out corridor can carry more color than the boss arena, but still less than the player

## Materials

- Decks are worn industrial metal with clean edge reads
- Support braces should feel load-bearing, not decorative
- Cave stone should feel carved by pressure and age, not generic noise
- Hive traces can appear in ribs, seams, and repeating organic support forms
- Mountain-facing exit cues should feel like air and distance, not a new biome yet

## Animation

Environment motion is restrained and purposeful:

- rack pulse during starter selection
- occasional hazard or warning blink in the shaft
- practical flicker in the cave foyer
- weak-state vents or architecture tells in the boss arena
- route-clear cue and exit light after victory

Parallax priorities:

- mid-ground support forms establish room depth
- far background establishes world scale
- no near-background motion should compete with boss telegraphs or player attacks

## Readability Tests

- Can a new player tell where to stand, jump, and move next without footer text.
- Does the cave mouth read as a destination from the previous room.
- Does the boss arena still read as a fight space with platforms when the rival and FX are active.
- Are route-critical edges always clearer than decorative cave trim.
- Can the route-out corridor decompress the scene without looking empty or unfinished.
- Does every room have one memorable silhouette.

## Do Not Do

- Do not build rooms from anonymous flat rectangles
- Do not flood the shaft with equal-detail props
- Do not make the boss room a flat black box
- Do not hide exits in color noise
- Do not use generic stalactite cave filler as the primary visual identity
- Do not let the route-out corridor turn into a second boss room

## Export Target

- Existing background direction reference: `art/source/BACKGROUND_PACKAGE_01.md`
- Existing stage bar reference: `art/source/STAGE-01-VISUAL-BAR.md`
- New authored source sheets should live under `art/source` as `.aseprite` files and export through `tools/export_aseprite.ps1`
- Recommended stage authoring targets:
  - `art/source/stage_01_tiles.aseprite`
  - `art/source/stage_01_backgrounds.aseprite`
  - `art/source/stage_01_props.aseprite`
- Expected exports:
  - `art/export/stage_01_tiles.png` plus optional JSON if tags are used
  - `art/export/stage_01_backgrounds.png`
  - `art/export/stage_01_props.png`
