# Opening Slice Palette And Staging Matrix

This file assigns color lanes, contrast floors, and focal hierarchy for the opening slice.

Use it with `OPENING-SLICE-ART-BIBLE.md`.

## Color Lane Matrix

| Lane | Role | Value Range | Saturation Range | Allowed Accents | Notes |
| --- | --- | --- | --- | --- | --- |
| Player | Hero and weapon overlays | high-mid to high | focused | teal jets, blade cyan, brass heat, ivory trim | Always brighter and cleaner than the room behind it |
| Rival | Boss body and rival weapon | high-mid | focused | tactical orange, warm ivory, ember red, steel blue | Must separate from player without becoming louder than hazards |
| Hazards | Active damage, telegraphs, live danger | highest local spike | narrow and hot | amber, ember red, acid warning white | Reserved for danger cores and active hit moments |
| Interactables | Racks, prompts, salvage, exit cue | mid-high | controlled | signal cyan, warm gold, clear white | Only one interactable accent should dominate at a time |
| Architecture | Walkable platforms, rails, braces, cave forms | mid to dark | muted | steel slate, foundry blue, dust stone, oxidized teal | Platform tops get the clearest edge treatment |
| Deep Background | Skyline, distant hive, cavern depth | dark to mid-dark | selective | dusk violet, sunset rose, old gold, muted teal | Richest color lives here, but never hottest contrast |
| UI | HUD, boss bar, shell readout, framing | high contrast but low area | disciplined | warm cream, amber line, cool cyan reserve | UI should be sharp and thin, not massive |

## Contrast Floors

- Player must hold a readable edge against both the darkest cave wall and the brightest breach sky.
- Hazard cores must peak above environment contrast but below pure white UI text.
- Walkable surface tops need a visible value break from their undersides in every room.
- Deep background should stay at least one full contrast step quieter than collision geometry.
- The rival boss must not disappear against the cave wall during intro framing or weak-state windows.

## Saturation Rules

- Highest saturation belongs in sky events, hazard cores, salvage sparks, and key ceremonial props.
- The gameplay plane uses saturation in short, intentional bursts.
- Do not saturate every metal trim or cave prop.
- If the room feels colorful but route clarity drops, pull saturation out of architecture first.

## Room Hierarchy Matrix

### Starter Armory

- First read: player and active rack
- Second read: claim prompt guide and rail silhouette
- Third read: dock hull and ceremonial floor striping
- Background richness ceiling: low
- Allowed hot color: rack pulse only

### First Shaft

- First read: player and next landing
- Second read: enemy lane or refuel line
- Third read: breach light above
- Background richness ceiling: medium-low
- Allowed hot color: hazard seams and kill-floor warning

### Cave Foyer

- First read: cave arch and player
- Second read: rival staging position or duel trigger
- Third read: support braces and wall carving
- Background richness ceiling: medium
- Allowed hot color: held amber practicals, not flashing noise

### Boss Arena

- First read: player and rival
- Second read: floor, support platforms, vulnerable-state cue
- Third read: chamber arch and quiet background depth
- Background richness ceiling: medium-low
- Allowed hot color: boss telegraph, hit confirm, weak-state vent, salvage spark

### Route-Out Corridor

- First read: player and forward exit line
- Second read: opened route cue
- Third read: mountain-facing atmosphere
- Background richness ceiling: medium
- Allowed hot color: route-clear cue and distance sky break

## Shape And Light Allocation

- Broad lit planes belong to floors and ceremonial surfaces.
- Narrow bright trims belong to interactables and hero gear.
- Large shadow masses belong to cave walls, ribs, and deep skyline cutouts.
- Sonic CD-style glow belongs behind the play plane, not on it.
- If a prop needs more than two pixels of highlight to read, simplify the prop.

## Palette Families By Asset Class

### Hero

- shell cream
- muted gold
- tactical teal
- blade cyan
- deep navy
- controlled charcoal

### Rival

- tactical orange
- warm ivory
- ember red
- slate blue
- dark gunmetal
- optional vent cyan on overclock moments only

### Cave Architecture

- basalt blue-black
- foundry slate
- old bone stone
- oxidized teal trace
- restrained amber practical

### Exterior Dusk

- dusk violet
- hot rust rose
- sunset gold
- dust cream
- deep indigo

## Failure Conditions

The palette is wrong if:

- the player blends into the room at gameplay zoom
- a background prop looks more important than a landing surface
- the boss intro frame feels loud everywhere instead of focused
- the front-door UI reads brighter than the world
- the room looks modern-glossy instead of hand-authored 16-bit
