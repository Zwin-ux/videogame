# Player Animation Bible

Goal: make the player read like a fast Capcom action lead, not a neutral platformer pawn.

North star:
- `Mega Man & Bass` sprite density and silhouette discipline
- `Mega Man ZX` saber flow and forward pressure
- Capcom beat-'em-up contact/recovery weight

Non-negotiables:
- 32x32 canvas
- 24-28 px readable body height
- helmet, torso, boots, and weapon arm remain readable in every frame
- hybrid kit silhouette, with blade read staying stronger than gun read
- no soft gradients, no universal black outline, no palette drift

First-hour identity:
- the player is not a pure swordsman and not a pure shooter
- the blade is the primary silhouette cue
- the gun is a compact support module
- the jet nozzles remain part of the read in motion states

## Key Poses

### Run
- `run_0`: forward reach, chest leading, rear arm back
- `run_1`: contact, body centered
- `run_2`: opposite stride, slight recoil
- `run_3`: passing frame, reset into loop

### Burst
- `burst_start`: compressed ignition, shoulders braced
- `burst_loop`: stretched airborne line, legs tucked, jets hottest read on frame
- `burst_end`: recover silhouette, momentum still forward

### Wall Interaction
- `wall_slide`: compressed body, contact-side sparks, head still readable
- `wall_kick`: full extension, leg silhouette obvious, torso still on-model

### Ground Slash
- `blade_ground_0`: anticipation, blade arm loaded back
- `blade_ground_1`: contact frame, chest open, strongest forward lane read
- `blade_ground_2`: recovery, still moving through the lane

### Air Slash
- `blade_air_0`: lift and gather
- `blade_air_1`: diagonal contact
- `blade_air_2`: follow-through into fall or rebound

### Hurt
- `hurt_0`: sharp recoil
- `hurt_1`: controlled recovery, not a ragdoll collapse

## Timing Rules

- Anticipation is short and readable.
- Contact gets the highest contrast and clearest silhouette.
- Recovery returns quickly to a controllable action line.
- If a frame only reads when zoomed in, redraw it.

## Composite Check

Always review against:
- dark hive backdrop
- light ruin backdrop
- live slash FX
- one drone or crawler on screen

If the player loses blade, boots, or feet contrast in any of those, simplify the art before adding detail.
