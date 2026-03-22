# ASEPRITE ART PASS 01

Goal: produce the first real SNES-quality sprite set for Scrapyard Comet. The art must read cleanly in motion, support fast vertical parkour, and fit the retro-futurist scrapyard tone. Prioritize silhouette, animation clarity, and consistent scale over detail noise.

Primary optimization rule:
- Whenever visuals are created or revised, optimize for Mega Man & Bass style readability, sprite density, palette discipline, and animation clarity over originality-first experimentation.
- Use [PIXEL-ART-FUNDAMENTALS.md](/C:/Users/mzwin/Downloads/videogame/PIXEL-ART-FUNDAMENTALS.md) as the source-of-truth quality bar.

## Global Rules

- Keep the whole set in one visual language: chunky mechanical shapes, bright safety accents, dark steel bodies, no soft gradients.
- Readability first. If a detail is not visible at gameplay distance, remove it.
- Use a disciplined palette with clear value separation. Do not let outlines and fills collapse into the same darkness.
- Favor 2 to 4 strong colors per sprite family, plus shared accent colors.
- Keep proportions slightly exaggerated so the player silhouette stays readable while jumping, wall-sliding, and bursting.
- Animate the important poses, not every possible pose.

## Palette Direction

- Base metal: dark blue-gray / charcoal steel.
- Secondary metal: mid gray-blue.
- Accent 1: scrapyard orange for warnings, exhaust, damage, springs.
- Accent 2: cyan/teal for tech lights, fuel, HUD-facing elements.
- Small warm highlight: pale sand or off-white for visor, trim, sparks.

## Sprite Sizes

- Player: 32x32.
- Drone: 32x32.
- Mine: 24x24 or 32x32 if the silhouette needs it.
- Platform pieces: built from 16x16 tiles or 16x32 / 16x64 modular chunks.

## Hard Model-Sheet Rules

### Player

- The player must read like a premium SNES action hero, not a chibi mascot.
- On the `32x32` canvas, target roughly `24-28 px` of readable body height.
- Keep one stable body model across all frames:
  - helmet or visor mass stays consistent
  - torso volume stays compact and strong
  - boots remain visually heavy
  - weapon arm remains clearly readable
- Do not let jump, burst, hurt, or shoot frames shrink or stretch the character off-model.

### Palette Budgets

- Player: `18-24` colors max.
- Drone: `12-18` colors max.
- Mine: `12-16` colors max.
- Platform family as a shared set: `10-16` colors plus very limited special accents.
- Background layers: `12-20` colors and always quieter than gameplay sprites.

### Contour Rules

- No full black outline around everything.
- Use darkest local colors on shadow edges, undersides, weapon backs, boot bottoms, and hazard undercarriage.
- Break contours on lit top planes and major highlights.
- Keep the strongest edge separation on gameplay-critical reads:
  - feet against platforms
  - visor or face read
  - weapon silhouette
  - hazard core
  - burst exhaust

## Player

The player is the hero silhouette. It must be obvious at a glance which way the character is facing and whether the player is jumping, wall-sliding, bursting, or firing.

Required frames:
- Idle: 1-2 frames.
- Run: 4 frames.
- Jump ascent: 1 frame.
- Fall: 1 frame.
- Wall slide: 2 frames.
- Wall kick: 2 frames.
- Burst / jetpack thrust: 2-3 frames.
- Shoot: 1-2 frames.
- Land: 1 frame.

Shape language:
- Large boots, compact torso, visible backpack thruster, single readable weapon arm.
- Jet exhaust should be the strongest motion cue during burst.
- Wall slide should show a braced, compressed silhouette with sparks on the contact side.
- Head/visor must remain visible even in the smallest frames.

Notes:
- Do not over-animate the run cycle. The game is vertical and fast; motion clarity matters more than animation complexity.
- Keep the player slightly front-loaded so the direction of travel reads instantly.
- Animation must include readable beat structure:
  - anticipation before major action
  - contact or impact on landing and firing
  - recoil on hurt or strong attack moments
  - recovery back into the neutral action line

## Drone

The drone is a moving hazard, not a boss. It should read as a small patrol machine with a sharp, hostile silhouette.

Required frames:
- Hover / idle: 2 frames.
- Move / patrol: 2 frames.
- Hit / destroy: 2 frames.

Shape language:
- Round body or compact hex body with one clear core light.
- Side fins, rotor, or thruster shapes that make the silhouette asymmetric enough to read while moving.
- One strong warning color on the core or eye.

Notes:
- The drone should be readable against both dark background shafts and lighter platform surfaces.
- Keep the destroy animation short and punchy. It should feel like a brief obstacle clear, not a cinematic explosion.

## Mine

The mine is a static or lightly animated hazard. It should look dangerous even when small.

Required frames:
- Idle pulse: 2 frames.
- Trigger / flash: 1-2 frames.
- Destroyed / inert: 1 frame.

Shape language:
- Compact core with clear spikes, fins, or an angular shell.
- Use a bright warning accent on the active core and a darker body shell.
- The active state should be obvious without relying on effects.

Notes:
- The mine must not blend into the scenery. It needs a stronger warning silhouette than the platforms.

## Platforms

Platforms should feel like scrapyard infrastructure, not generic floating blocks. Build them as modular industrial pieces with visible function.

### Stable
- Standard floor and wall pieces.
- Cleanest silhouette, lowest visual noise.
- Use a dark body with one bright edge or brace line.

### Crumble
- Same base language as stable, but visibly weaker and more patched.
- Add cracked plating, missing corners, or warning slashes.
- The broken state should be easy to understand instantly.

### Spring
- Should look reinforced and reactive.
- Add compressed pads, coil hints, or bright mechanical inserts.
- The spring face should be the brightest part of the platform family.

### Fuel
- Should look like a refill station or charging pad.
- Use teal/cyan glow blocks, small canister shapes, or intake vents.
- The empty or spent state must be visibly distinct from the live state.

Platform rules:
- Keep edges crisp and industrial.
- Reuse a shared material language across all platform types so they feel like one set.
- Each type needs one unique read at a distance: stable = plain, crumble = damaged, spring = charged, fuel = glowing.

## Composite Review

- Review every sprite in-engine at gameplay zoom, not just in the sheet.
- Test against:
  - dark shaft backgrounds
  - lighter structural backgrounds
  - platform tops
  - burst and hit effects
- If the player, hazards, or walkable surfaces lose clarity in the real room composite, revise the art before export approval.

## Export Guidance for Godot

- Export PNG with transparency.
- Use nearest-neighbor scaling only.
- Keep sprite pivots consistent:
  - Player pivot near feet / center of mass.
  - Drone pivot centered.
  - Mine pivot centered.
  - Platforms pivot centered or top-centered depending on placement use.
- Keep frames tightly trimmed but consistent enough that offsets do not drift.
- Prefer one sprite sheet per character family, not dozens of loose files.
- Name exports by family and state, for example:
  - `player_run.png`
  - `player_burst.png`
  - `drone_hover.png`
  - `mine_idle.png`
  - `platform_stable.png`
- If using Aseprite slices or tags, preserve frame tags for animation import into Godot.

## Acceptance Bar

- The player is readable in silhouette at gameplay zoom.
- Wall slide and burst are obvious without UI text.
- The drone and mine are immediately hostile-looking.
- Platform types are distinguishable at a glance.
- The palette feels like scrapyard hardware, not generic sci-fi.
- The set looks coherent when placed together in one tower room.
