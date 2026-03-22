# Hero Prompt Pack

Source brief: `art/source/briefs/hero-player-brief.md`

Use these prompts only after reading the source brief and `OPENING-SLICE-ART-BIBLE.md`.

## Asset Group: Player Body

### Concept

Design a 32x32 SNES action-platform hero for `Killer Queen`.
The hero is a fast royal hunter in a fallen insect kingdom.
The silhouette must read blade-led, with helmet, torso, boots, and jet nozzles as stable anchors.
Keep the body readable at gameplay zoom over both dark cave and bright dusk backdrops.
Reference bar: `Mega Man & Bass` readability, not generic anime mecha.
Show idle, run, jump, fall, land, wall slide, wall kick, burst start, burst loop, burst end, hurt, and recovery intent on one compact sheet.
No soft gradients, no universal black outline, no giant rifle silhouette.

### Production Sprite

Produce final pixel-art body frames for `player_sheet.aseprite` on a 32x32 grid.
Match the existing runtime tag set and preserve readable anchors across all states.
Prioritize strong contact and recovery frames over extra decorative detail.
The body should feel expensive in motion but fast to read.
Color usage stays disciplined: shell cream, muted gold, deep navy, tactical teal.
If a frame is only clear when zoomed in, simplify it.

### Repair/Review

Review this player body sheet for gameplay readability.
Check whether the head, chest, boots, and jet nozzles stay visible during motion and over active FX.
Check whether the sprite still feels blade-led even before the weapon overlay is added.
Remove detail that muddies the run, burst, landing, or hurt read.
Do not add texture noise as a fix.

## Asset Group: Service Fang Overlay

### Concept

Design the `Service Fang` overlay as a powered industrial blade system for the player.
It should feel like forward commitment and momentum shaping, not a fantasy greatsword.
Cover neutral slash, up slash, and down slash variants.
The arc language should explain how the player is being carried or redirected.
Keep the blade read stronger than the gun read in the player's overall silhouette.

### Production Sprite

Produce final pixel-art Fang overlay frames that pair cleanly with existing player body tags in `player_sheet.aseprite`.
The neutral slash should carry forward, the up slash should lift, and the down slash should dive and rebound.
Use blade cyan sparingly at active edges only.
The contact frame must be the clearest frame.
Do not create giant anime crescents or magical trails.

### Repair/Review

Review the Fang overlay for directionality, contact clarity, and scale discipline.
Check whether neutral, up, and down variants are readable without text.
Reduce any blade width or FX spill that hides the body silhouette.
If the weapon feels oversized or too fantasy-coded, pull it back into industrial royal-hunter language.

## Asset Group: Dock Blaster Overlay

### Concept

Design the `Dock Blaster` overlay as a compact explosive scatter weapon with a visible two-shell chamber.
It is a primary weapon, not a fallback gun.
The key fantasy is violent recoil: forward blast routes the player, down blast launches the player, and point-blank hits pop the room.
The silhouette should feel compact, brutal, and hand-held.

### Production Sprite

Produce final pixel-art Blaster overlay frames that pair with the player body in `player_sheet.aseprite`.
Support forward blast and down blast recoil states.
Make the two-shell chamber visible at gameplay size.
Use brass-orange heat and hot white only around active muzzle or chamber events.
Do not lengthen the weapon into a rifle or shrink it into a toy.

### Repair/Review

Review the Blaster overlay for recoil readability, chamber visibility, and weapon identity.
Check whether the player movement logic is visually explained by the pose and muzzle burst.
Simplify any muzzle or chamber detail that reads as noise.
If the weapon looks safe or timid, sharpen the stance and recoil read without inflating the sprite.
