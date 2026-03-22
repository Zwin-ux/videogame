# FX Opening Slice Brief

## Purpose

Define the combat and presentation effects that make the opening slice feel expensive, readable, and weapon-specific.
These FX must sharpen timing, recoil, contact, and reward moments without burying gameplay under noise.

## Camera/Scale

- All FX must read at gameplay zoom and while the player is moving
- Effects are viewed over dark cave, bright breach, and active HUD conditions
- Contact frames should peak quickly and decay fast
- Boss telegraphs must be readable as warnings, not just pretty light

Asset groups:

- Fang slash arcs
- Blaster muzzle and recoil bursts
- pellet impact and hit confirm
- boss telegraphs and vulnerable-state cues
- salvage and route-clear effects

## Silhouette

- Fang arcs are lane shapes with a clear travel direction
- Blaster muzzle should feel explosive and compact
- Pellet impact should read like a heavy blast pop, not a generic spark
- Telegraph FX should frame danger zones without hiding collision
- Salvage and route-clear FX should feel celebratory but still legible

Required effect reads:

- neutral slash
- rising slash
- dive slash
- forward blast recoil burst
- down blast lift burst
- pellet hit
- boss warning flash
- weak-state vent cue
- salvage spark trail
- route-clear cue

## Palette

- Fang: warm outer edge, cool cyan inner core
- Blaster: hot white center, brass-orange heat, ember fringe
- Hit confirm: hot white and acid-cold snap used sparingly
- Telegraphs: amber or ember with clear value separation from background
- Salvage: warm gold and clean white with a restrained cyan technology edge

Rules:

- do not use rainbow effects
- do not keep FX at full brightness for too many frames
- do not make slash effects wider than the real threat lane
- save pure white for the hottest contact point only

## Materials

- FX should feel hand-authored and graphic
- Use clean pixel clusters, not smeared airbrush trails
- Sparks should feel metallic in this world, not magical
- Telegraphs should feel tactical and mechanical
- Salvage FX should feel like a damaged system still trying to stay alive

## Animation

Priority tags for the existing combat sheet:

- `ground_slash(3)`
- `air_slash(3)`
- `hit_confirm(2)`

Required expansion targets:

- `rising_slash`
- `dive_slash`
- `blaster_muzzle`
- `blaster_recoil_burst`
- `pellet_hit`
- `boss_telegraph`
- `weak_state`
- `salvage_trail`
- `route_clear`

Timing notes:

- one strong anticipation flash at most
- contact frame is the hero
- decay should return the screen to readability quickly
- route-clear cue can linger slightly longer than combat FX, but should not become a screen wipe

## Readability Tests

- Can the player tell Fang and Blaster apart from FX alone.
- Does the hit confirm still read over a bright background.
- Do telegraphs warn clearly without covering the floor edge.
- Does the salvage effect feel valuable without stopping play.
- Do the recoil bursts visibly explain why the player moved.
- Can the boss weak state be identified in motion.

## Do Not Do

- Do not make anime smear noise or giant crescent walls
- Do not use soft bloom-style gradients
- Do not flood the screen with additive clutter
- Do not use telegraphs that sit under the same value as the cave wall
- Do not make hit confirms so large that they hide the next threat

## Export Target

- Existing source: `art/source/combat_fx_sheet.aseprite`
- Existing exports: `art/export/combat_fx_sheet.png` and `art/export/combat_fx_sheet.json`
- Preserve current shipped tags and extend the same sheet if timing and runtime usage stay compatible
- If combat FX expansion outgrows the current sheet, add a second authored source:
  - `art/source/combat_fx_sheet_boss.aseprite`
  - export to `art/export/combat_fx_sheet_boss.png` and `art/export/combat_fx_sheet_boss.json`
