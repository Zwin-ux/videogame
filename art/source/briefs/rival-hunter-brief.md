# Rival Hunter Brief

## Purpose

Define the first cave boss as a rival bounty hunter who uses the starter weapon the player did not choose.
The art must sell tension, skill, and overclocked confidence without drifting into monster-boss language.

## Camera/Scale

- Readable at side-view gameplay zoom with the player sharing the screen
- Target body scale: larger and broader than the player, but still fast
- Works in idle standoff, flourish, attack telegraph, weak state, damage, defeat, and salvage-eject beats
- Must hold up against the cave arena without requiring zoom-in drama

Asset groups:

- rival base body
- Fang-overclock variant
- Blaster-overclock variant
- intro and flourish poses
- defeat and salvage poses

## Silhouette

- Human rival first, weapon specialist second
- Orange-armored tactical silhouette with stronger shoulder and forearm blocking than the player
- Head and chest should feel hunter-like, not royal
- Fang variant should read like a heavier cutting specialist
- Blaster variant should read like a compact breacher with dangerous recoil control
- Overclocked means sharper vents, hotter accents, and stronger pose confidence, not giant proportions

Required readable states:

- standoff
- weapon flourish
- grounded pressure pose
- air commitment pose
- telegraph hold
- vulnerable state
- hurt
- defeat breakup
- salvage eject

## Palette

- tactical orange is the signature bias
- warm ivory for armor break-up and focal trim
- deep gunmetal and slate blue for structure
- ember red for danger spikes
- optional vent cyan reserved for overclock moments only

Rules:

- keep orange concentrated on armor plates and weapon housing
- rival must separate from the player at a glance without becoming clown-bright
- vulnerable state should use a clear accent shift, not just more flashing
- salvage frame should inherit the unchosen starter identity in a damaged, dimmer version

## Materials

- Armor feels field-tuned and expensive, not ceremonial
- Weapon modules show hard use and dangerous tuning
- Overclock vents, seams, and exhausts should look engineered
- Damage and defeat frames should show breakup by panels, sparks, and system failure, not gore
- Salvage should look recoverable, not pristine

## Animation

Priority beats:

- calm standoff with weight
- synced flourish before the duel
- clear attack telegraphs
- strong punishable recovery
- sharp hurt snap
- in-motion defeat that ejects the damaged weapon frame

Variant notes:

- Fang rival should sell dash cut and sky cleave pressure
- Blaster rival should sell lane burst and fan sweep control
- Both variants must advertise the weapon type before the first hit lands

## Readability Tests

- Can the player identify the boss weapon from the intro pose alone.
- Does the rival read as a hunter and not a corrupted clone.
- Are the telegraphs readable before danger begins.
- Is the vulnerable state obvious in one glance.
- Does the salvage eject feel tied to the unchosen starter.
- Does the rival remain clear against the boss room wall and weak-state FX.

## Do Not Do

- Do not turn the rival into a giant monster silhouette
- Do not copy the player sprite and recolor it
- Do not flood the design with spikes, capes, or villain clutter
- Do not make the orange armor toy-like or glossy
- Do not hide telegraphs in symmetrical posing
- Do not use a frozen reward pose after defeat

## Export Target

- New authored source target: `art/source/rival_hunter_sheet.aseprite`
- Expected exports: `art/export/rival_hunter_sheet.png` and `art/export/rival_hunter_sheet.json`
- Suggested tag groups:
  - `standoff`
  - `flourish`
  - `fang_dash_cut`
  - `fang_sky_cleave`
  - `blaster_lane_burst`
  - `blaster_fan_sweep`
  - `vulnerable`
  - `hurt`
  - `defeat`
  - `salvage_eject`
- Author the salvage frames so they can also inform a separate pickup or cut-in asset if needed later
