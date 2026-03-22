# PIXEL ART FUNDAMENTALS

This is the real art skill for the project. Tools matter less than discipline.

Target bar:
- SNES 16-bit action platformer craft
- closer to Mega Man & Bass / Mega Man 7 readability than minimalist indie pixel art
- hand-authored sprite-sheet quality
- industrial sci-fi stage dressing with crisp tile readability

Primary priority:
- Optimize for readability, sprite density, palette discipline, and animation clarity before originality-first experimentation.
- The goal is not novelty at any cost. The goal is a trustworthy commercial SNES action-platformer bar.

## Non-Negotiables

### 1. Silhouette First

- Every sprite must read at gameplay scale before interior detail is added.
- The player needs distinct readable forms for helmet, hair or visor, weapon arm, torso, and boots.
- Idle, run, jump, fall, shoot, hurt, and dash or burst frames must preserve character identity.
- Hazards must not be confused with platforms.
- Platforms must not be confused with background dressing.

If the silhouette fails, the sprite fails.

### 2. Pixel Clustering

- Build forms out of confident pixel groups, not scattered single pixels.
- Avoid noise pixels, staircase chatter, and accidental banding.
- Detail should come from clean clusters and shape breaks, not random texture.
- Use sub-pixel-looking anti-aliasing only when it is intentional and sparse.

The image should look authored, not fuzzed.

### 3. Palette Discipline

- Keep each sprite family to roughly 16 to 32 colors max.
- Share ramps where possible across character parts.
- Do not let one arm, one boot, and one helmet piece all introduce separate color logic.
- Use a limited set of accents:
  - warm warning orange
  - cyan or teal tech glow
  - pale highlight for visor, sparks, and contact points
- Backgrounds should stay quieter and lower-contrast than gameplay sprites.

The goal is a controlled sprite sheet, not a painterly color soup.

Recommended budgets:
- Player: `18-24` colors.
- Drone or mine: `12-18` colors.
- Platform tileset family: `10-16` shared colors, with very limited per-type accents.
- Background set per layer: `12-20` colors, lower contrast than gameplay sprites.

### 4. Shading With Intent

- No soft gradients.
- No automatic pillow shading.
- Shade to explain plane change, material, weight, and pose.
- Put contrast where the gameplay needs it:
  - feet
  - ledges
  - weapon silhouette
  - hazard cores
  - burst exhaust
  - wall-contact side
- Prefer selective highlights and hard plane breaks over blended ramps.

Shading should clarify function, not just make the sprite look busy.

## Contour Policy

- Do not use universal black outlines.
- Use the darkest local color on shadow-facing edges, undersides, boot bottoms, weapon backs, and hazard undercarriage.
- Break outlines on lit top planes and major highlight edges so forms breathe.
- Use selective outlining where gameplay readability needs it most:
  - feet against platforms
  - weapon silhouette against torso
  - visor or face read
  - hazard cores against stage dressing
- If a contour is doing no readability work, remove or soften it.

### 5. Readability At Small Scale

- Test sprites at real gameplay size, not zoomed-in canvas size.
- Anticipation, contact, recoil, and recovery poses must read in one glance.
- Animation should favor arcade responsiveness over realism.
- Do not shrink the hero into low-information chibi proportions unless explicitly chosen later.
- Strong contrast between player and background is mandatory.

If a frame looks good only when zoomed in, it is not ready.

## Visual North Star

Use these as the quality bar:
- Mega Man & Bass sprite readability
- Mega Man 7 density and pose clarity
- polished archived SNES character sheets and stage assets

This is a homage bar, not a copy job. The project still needs its own scrapyard, jetpack, retro-futurist identity.

## Do Not Generate

- blurry pixel art
- tiny low-information sprites
- AI-smoothed or painterly surfaces
- vector-looking shapes
- generic roguelike placeholder art
- soft gradients
- overoutlined sprites with noisy pixels
- inconsistent proportions between frames
- mismatched palette counts across character parts

## Character Rules

- Hero proportions should feel like a premium SNES action platformer lead.
- On a `32x32` canvas, the hero should occupy most of the playable read:
  - compact but not chibi
  - strong torso mass
  - readable boots
  - head or visor large enough to anchor facing direction
- Target occupancy:
  - roughly `24-28 px` of readable body height inside the `32x32` frame
  - no tiny low-information body floating in unused canvas
  - enough head and boot mass that the sprite still reads while moving
- Helmet or visor, torso, boots, and weapon need separate readable masses.
- Run and jump poses should stay compact and forceful.
- Burst frames need strong ignition and thrust direction.
- Hurt and recoil frames need to be readable without breaking model consistency.
- The final result should look like it belongs on a polished commercial sprite sheet.

## Environment Rules

- Tiles must look hand-authored, not auto-generated.
- Platform tops need crisp edges and clear walkable faces.
- Material identity must read immediately: steel, hazard trim, fuel surface, spring hardware.
- Background layers should support depth but never wash out gameplay sprites.
- Hazards must be immediately distinguishable from safe surfaces.
- Backgrounds should avoid using the player's brightest accents at similar intensity.
- Walkable edges and hazard silhouettes must win the contrast fight over decorative stage detail.

## Production Workflow

Use this order every time:

1. Silhouette blockout in 1-bit or 2-tone.
2. Proportion lock and frame anchoring.
3. Palette lock before detail creep starts.
4. Plane-based shading pass.
5. Animation pass with anticipation, contact, recoil, and recovery.
6. In-engine readability test at gameplay zoom on both dark and light backgrounds.

Do not skip directly to polishing.

## Animation Clarity Rules

- Every action set needs key beats, not just extra in-betweens.
- Prioritize:
  - anticipation
  - contact
  - recoil
  - recovery
- A strong single pose is worth more than two weak transitional frames.
- The pose arc should read even when the game is running at speed.
- Keep volume consistent across frames. Do not let the character inflate, shrink, or drift off-model during action.

## Mega Man Readability Rules

- The pose must be readable before interior detail is added.
- Limbs should separate cleanly from the torso in key action poses.
- Weapon direction must be clear in one glance.
- Contact frames should compress with obvious weight.
- Recovery frames should preserve the same character proportions as idle and run.
- Reused ramps and shape language matter more than decorative surface detail.

This is what keeps the sprite sheet feeling commercial instead of prototype-grade.

## Composite Review Rule

- Never approve sprites from the sheet alone.
- Review player, hazards, tiles, and background together in-engine at gameplay zoom.
- Check at least:
  - dark shaft background
  - lighter platform background
  - burst effect overlapping stage dressing
  - hazard overlapping both tile edges and background props
- If the sprite only reads on a flat checkerboard preview, it is not production-ready.

## Approval Gates

Reject or revise any sprite set that fails one of these:

- Silhouette gate: readable at gameplay size without zoom.
- Cluster gate: no accidental noise, speckling, or muddy AA.
- Palette gate: controlled ramps, no color drift across parts.
- Shading gate: plane and material clarity without soft gradient behavior.
- Animation gate: anticipation, contact, recoil, and recovery all read clearly.
- Integration gate: player stays readable against stage tiles and backgrounds.

## Ship Test

Before approving a sprite set, ask:
- Is the silhouette readable at gameplay zoom?
- Are the clusters clean or noisy?
- Is the palette controlled or drifting?
- Does the shading describe form instead of filling space?
- Can the player, hazards, and platforms be read instantly during motion?

If any answer is weak, keep iterating.
