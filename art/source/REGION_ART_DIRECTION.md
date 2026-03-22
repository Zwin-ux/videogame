# REGION ART DIRECTION

Killer Queen needs regions that feel like a real metroidvania world, not just repeated climb rooms. The visual language should blend sunset ruins, overgrown industrial wilds, and bio-mechanical hive architecture into one coherent world.

## Visual Thesis

The world should read as a fallen kingdom that has been industrialized, infested, and partly reclaimed by nature.

- Sunset ruins give the world scale and melancholy.
- Overgrown industrial wilds give it life and lateral exploration space.
- Hive architecture gives it identity, threat, and visual continuity with the intro escape shaft.

The player should always know where they are from the silhouette of the space alone.

For the opening chapter specifically, follow [STAGE-01-VISUAL-BAR.md](/C:/Users/mzwin/Downloads/videogame/art/source/STAGE-01-VISUAL-BAR.md).
That file overrides any vagueness in this doc for the first stage and first boss room.

## Region Families

### 1. Hive Shaft

The opening escape chapter. Tight vertical shafts, ribbed walls, ventilation chutes, hanging pods, and heavy kill-floor pressure.

Use for:
- intro escape
- early teaching spaces
- vertical gating

Visual notes:
- dark steel
- amber warning lights
- chitin ribs
- narrow platforms
- strong top-down perspective

### 2. Sunset Ruin Skyline

Broad exterior spaces with broken towers, old columns, distant structures, and long sunset gradients behind them.

Use for:
- exterior traversal
- landmark-heavy routes
- world map readability

Visual notes:
- broken monumental shapes
- layered silhouettes in the distance
- warm sky against cool foreground ruin
- more lateral breathing room than the hive shaft

### 3. Overgrown Industrial Wilds

The reclaimed world. Pipes, old machinery, moss, roots, vine bridges, wet metal, and insect life growing through old systems.

Use for:
- midgame exploration
- hidden routes
- safe-zone approaches

Visual notes:
- less rigid symmetry
- more organic breaks in the architecture
- green and teal life against rusted metal
- grounded surfaces that feel traversable

### 4. Royal Husk / Sanctuary Ruins

Safer spaces that still feel haunted. These are the player’s breathers, map hubs, and return points.

Use for:
- save rooms
- NPC spaces
- route reorientation

Visual notes:
- calmer shapes
- cleaner silhouette
- less hazard clutter
- more open negative space

## Palette Families

Use a shared world palette, then bias each region differently.

### Hive Shaft Palette

- night navy
- foundry blue
- steel slate
- oxidized teal
- signal amber
- warning red

Rules:
- highest contrast should be on collision edges and hazard cores
- keep the shaft darker than the player
- use amber as the active danger color

### Sunset Ruin Palette

- dusk violet
- sunset gold
- dust cream
- hot white
- steel slate
- muted teal

Rules:
- warm horizon tones belong in the sky, not on the player
- ruins should silhouette cleanly against the sunset
- distant layers should be softer and simpler than foreground geometry

### Overgrown Wilds Palette

- jungle green
- moss acid
- foundry blue
- steel slate
- dust cream
- oxidized teal

Rules:
- foliage should never wash out walkable surfaces
- green is environmental, not UI-bright
- wet highlights should be used sparingly

### Sanctuary Palette

- dust cream
- hot white
- dusk violet
- muted teal
- softened steel blue

Rules:
- quieter contrast
- less hazard color
- enough clarity for navigation, not noise

## Silhouette Language

At gameplay scale, every region should be recognizable by silhouette first.

- Hive Shaft: tall ribs, vertical constriction, hanging masses, tight cutouts.
- Sunset Ruin: broken columns, giant arcs, skyline fragments, open sky voids.
- Overgrown Wilds: uneven canopy shapes, root bridges, rounded foliage masses, organic gaps.
- Sanctuary: clear open volumes, calmer archways, readable thresholds.

The player must never confuse foreground decoration with a collision surface.

## Parallax Rules

Use 3 to 5 background layers, but keep them disciplined.

- Layer 1: gameplay geometry and collision surfaces.
- Layer 2: mid-ground structural forms.
- Layer 3: distant architecture or foliage masses.
- Layer 4: sky or cavern depth gradient.
- Layer 5: occasional silhouette accents only.

Rules:
- Parallax should establish scale, not clutter.
- The slowest layers can be ornate.
- The nearest background layers must stay simple enough to preserve action reads.
- Never place the brightest accent colors in the same intensity range as the player sprite.
- Boss or landmark silhouettes can interrupt the horizon, but they must not fight platform readability.

## Tile Language

The tile set should feel authored and region-specific, not generic modular blocks.

### Shared Rules

- Tops need thick readable edges.
- Undersides should be darker and quieter.
- Collision surfaces must have a clearer silhouette than decorative trim.
- Repeated tiles should still feel handcrafted through small shape variations, not noisy texture.

### Hive Shaft Tiles

- ribbed steel
- chitin braces
- vent seams
- amber hazard seams

### Sunset Ruin Tiles

- cracked stone
- worn metal inlays
- monumental carved edges
- chipped column bases

### Overgrown Wilds Tiles

- root-bound metal
- moss patches
- vine wraps
- damp stone

### Sanctuary Tiles

- cleaner stone
- polished metal trim
- softer glow sources
- less visual damage

## Gameplay Readability

The metroidvania pivot only works if the world still reads well during movement.

- Platforms must be the clearest shapes on screen after the player.
- Hazards must keep a sharp silhouette against both dark and bright backgrounds.
- Traversal-critical edges need more contrast than decorative background detail.
- Safe routes should feel inviting; secret routes should feel like a readable deviation, not hidden noise.
- Each region should teach a new spatial idea, then remix it later.

## What Must Stay Readable

At gameplay zoom, the player should always be able to read:

- where they can land
- where they can wall slide
- where the next upward route continues
- where the safe return path is
- where the region boundary or landmark sits
- where hazard cores or weak points are

If any region turns these into guesswork, simplify the art before adding more detail.

## Direction Summary

The visual order of priority is:

1. readable traversal
2. strong region silhouette
3. distinct palette family
4. authored environmental detail
5. decorative richness

If a detail makes the world prettier but hurts movement clarity, cut it.
