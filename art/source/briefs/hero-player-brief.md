# Hero Player Brief

## Purpose

Define the opening-slice player art for `Killer Queen` so the hero reads as a fast royal hunter with two equally valid primary weapons.
This brief covers body animation, Fang overlay, Blaster overlay, and the key attack/movement states that establish the game's identity in the first 10 minutes.

## Camera/Scale

- 32x32 canvas for body frames
- 24-28 px readable body height
- Review at gameplay zoom over dark cave, dusk breach, and active FX
- The player must read clearly while moving, slashing, blasting, wall sliding, and landing

Asset groups:

- body base states
- Service Fang overlay states
- Dock Blaster overlay states
- starter weapon icons and rack-facing silhouette snapshots

## Silhouette

- Head, chest, boots, and jet nozzles are stable anchors
- The blade side stays the stronger side read even when Blaster is equipped
- Blaster remains compact and brutal, not rifle-like
- Fang arcs should create visible travel direction
- Blaster shots should create visible recoil direction

Required readable states:

- idle
- run
- jump up
- fall
- land
- wall slide
- wall kick
- burst start, loop, end
- neutral slash
- up slash
- down slash
- forward blast
- down blast
- damage
- recovery

## Palette

- shell cream and muted gold on the armor shell
- deep navy and controlled charcoal for structure and undersides
- tactical teal for jets and small system lights
- blade cyan reserved for Fang energy edge
- brass-orange heat reserved for Blaster muzzle and shell chamber feedback

Rules:

- keep highlight placement deliberate
- avoid full black outlines around the entire body
- use the blade cyan and muzzle heat only at moments of active attack or charge
- do not let both weapon overlays glow at full intensity in the same frame

## Materials

- Armor should feel field-ready, not ceremonial chrome
- Cloth or joint sections should be minimal and graphic
- Jets should be readable as hardware, not decorative wings
- Fang should read as a powered industrial blade with clean arc language
- Blaster should read as a compact explosive scatter weapon with a visible two-shell chamber

## Animation

Body sheet priorities:

- `idle(2)`
- `run(4)`
- `jump_up(2)`
- `fall(2)`
- `land(2)`
- `wall_slide(2)`
- `wall_kick(2)`
- `burst_start(2)`
- `burst_loop(2)`
- `burst_end(2)`
- `hurt(2)`

Weapon overlay priorities:

- Fang: `blade_ground(3)`, `blade_air(3)`, plus art support for rising and dive variants
- Blaster: `gun_ground(3)`, `gun_air(3)`, with strong forward and down-shot recoil read

Key motion notes:

- neutral slash carries forward
- up slash lifts and scoops
- down slash in air dives and rebounds
- forward blast kicks the player back hard
- down blast launches the player upward hard
- land and hurt states recover into control quickly

## Readability Tests

- Can a player tell Fang and Blaster apart from silhouette alone in one glance.
- Does the hero still read over a bright breach backdrop.
- Do the forward blast and down blast feel different without needing text.
- Does the rising slash read upward from the contact frame, not just from anticipation.
- Do the boots, head, and weapon side stay readable when FX are active.
- Does the player still feel premium when reduced to gameplay size.

## Do Not Do

- Do not turn the hero into a generic shooter silhouette
- Do not make Fang into an oversized anime sword
- Do not make Blaster a long rifle or pea-shooter
- Do not smooth armor with painterly gradients
- Do not use floppy recovery poses that kill control fantasy
- Do not hide the two-shell chamber on the Blaster read

## Export Target

- Primary body source: `art/source/player_sheet.aseprite`
- Primary exports: `art/export/player_sheet.png` and `art/export/player_sheet.json`
- Keep current shipped tags intact where already used by runtime
- Add new frame polish by preserving tag intent rather than inventing a separate player pipeline
- Starter weapon icons remain `art/export/weapon_icon_fang.png` and `art/export/weapon_icon_blaster.png`
