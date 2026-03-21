# Scrapyard Comet

## Core Fantasy

You are a salvage runner cutting through an orbital junkyard with a half-reliable jetpack and an overclocked sidearm. The fun is momentum: sprint, jump, feather the thrusters, clip a drone out of the air, land, and keep moving.

## Vertical Slice

- Genre: 2D platformer shooter with light speedrun energy.
- Loop: move fast, manage jetpack fuel, grab fuel cells, clear a path with your blaster, hit the extraction pad.
- Feel target: responsive, readable, a little scrappy, never floaty.
- Failure tone: quick reset, low ceremony.

## Visual Direction

- Aesthetic: retro-futurist scrapyard, not clean sci-fi.
- Palette:
  - night navy `#05070B`
  - steel blue `#283C4D`
  - oxidized teal `#49D4E5`
  - signal amber `#F3A457`
  - hazard orange `#D07B44`
  - dust cream `#D1BB94`
  - ember red `#E65A4A`
- Surfaces: chipped steel, caution stripes, hard silhouettes.
- Lighting: cool ambient world, warm exhaust and muzzle flashes.
- Motion: quick takeoff burst, short landing compression, readable shot recoil.

## Sprite Rules

- Base grid: `32x32` for player and common enemies.
- Environment tiles: `16x16`.
- Pickups: `16x16`.
- Large props like the extraction pad: `48x64` or `64x64`.
- Keep silhouettes bold enough to read at a glance when the camera is moving.

## Aseprite Plan

- Source files live in `art/source/`.
- Exported sheets and metadata live in `art/export/`.
- Keep one `.aseprite` file per gameplay actor:
  - `player.aseprite`
  - `drone.aseprite`
  - `fuel_cell.aseprite`
  - `pad.aseprite`
  - `terrain.aseprite`
- Use tags for named animations:
  - player: `idle`, `run`, `jump`, `jetpack`, `shoot`, `hurt`
  - drone: `idle`, `hit`, `break`

## First Art Pass

- Player:
  - chunky boots
  - compact torso
  - bright visor
  - twin jet nozzles
  - one readable blaster silhouette
- Drone:
  - circular body
  - single hostile eye
  - side pods that telegraph danger
- Environment:
  - thick top trim on platforms
  - dark undersides
  - sparse neon beacons instead of busy clutter

## Game Feel Targets

- Run speed should feel slightly aggressive, not cautious.
- Jump should be reliable with coyote time and a short input buffer.
- Jetpack should reward feathering, not infinite hover.
- Shooting should lightly push the player so firing while airborne has texture.
- The best path through the room should feel like a flowing line, not stop-start platform chess.
