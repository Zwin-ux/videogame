# Killer Queen

## Product Sentence

A 2D parkour action game built around a central hub world, distinct mission-based stages, and ZX-style melee combat, rendered in high-quality SNES-inspired pixel art.

## Product Call

The right structure is no longer pure metroidvania and no longer a one-way climb prototype.

`Killer Queen` should feel like a Mario 64-style hub-and-missions game translated into a sharp 2D action-platformer:

- one compact, memorable hub world
- six strong stages with distinct identities
- around ten missions per stage that remix the same authored space
- one stylish movement-and-melee kit that makes the player look cool without demanding precision-god execution

The current live tower still matters, but it is no longer the actual start of the game.

It should now be treated as the `mid-game benchmark`:

- enemy density
- movement fluency
- blade/gun swap pressure
- visual intensity

That is the quality bar the player grows into after the softer side-scrolling opening.

## Core Fantasy

You break out of the Queen's collapsing hive, reach a sanctuary above the breach, and start raiding the larger world one mission at a time. You do not tiptoe through technical obstacle courses. You move hard, cut through enemies at close range, chain wall kicks and burst movement into saber pressure, and turn dangerous spaces into playgrounds once you know their routes.

The emotional arc is:

```text
panic escape
    -> reach sanctuary
    -> start in-world with no menu cut
    -> choose a weak first weapon
    -> choose a target stage
    -> master its routes and secrets across multiple missions
    -> earn new marks, new tools, and more swagger
```

## Opening Slice

Reference details live in [FIRST-VERTICAL-SLICE.md](/C:/Users/mzwin/Downloads/videogame/FIRST-VERTICAL-SLICE.md).

The game should begin with a short side-scrolling opening, not an immediate hard vertical climb.

Opening rules:

- the title screen is the world
- pressing `Start` begins in the same scene
- the player lands from a ship naturally
- the first weapon choice happens in-world
- both starting weapons are intentionally weak
- the player earns a first upgrade before the first mission gate

The opening should feel natural, premium, and readable before the game ramps into the current mid-game bar.

## Pillars

- Parkour world structure: the hub and stages should feel like places worth learning, not level-select menus.
- Distinct stage identity: every stage needs a unique silhouette, route logic, and combat flavor.
- Stylish melee first: combat should look and feel closer to Mega Man ZX saber pressure than to a ranged platform shooter.
- Cool over technical: mastery should look impressive, but the baseline feel should be aggressive and readable, not punishingly precise.
- Mission remix value: stages must stay fresh across roughly ten objectives each.
- Premium pixel craft: Mega Man & Bass readability, Mega Man ZX energy, no muddy retro filler.

## Structure Overview

Reference details live in [HUB-WORLD-PIVOT.md](/C:/Users/mzwin/Downloads/videogame/HUB-WORLD-PIVOT.md).

### Hub World

The hub should be a compact sanctuary built above the hive breach: part ruined royal transit court, part reclaimed parkour playground.

Its jobs:

- reset the player emotionally after high-pressure missions
- teach free movement without a fail state breathing down their neck
- visually promise where each stage leads
- contain secrets, shortcuts, NPCs, training alcoves, and gate progression

The hub must not feel like a menu room. It should be small enough to memorize and rich enough to revisit.

### Stage Count

Recommend:

- `6` core stages
- `10` missions per stage
- hub-world secrets and side marks on top

That is large enough to feel like a full game without diluting the art and encounter quality.

### Stage Set

1. `Hive Shaft`
- the escape thesis
- vertical pressure
- falling debris, tight walls, aggressive hazard lanes

2. `Sunset Ruin Skyline`
- broad exterior traversal
- broken columns, skyline bridges, exposed air routes
- high-visibility chase and relay missions

3. `Overgrown Foundry`
- reclaimed machinery and root-bound steel
- route splits, hidden chambers, organic hazard growth

4. `Flooded Transit`
- vertical pumps, wet conduits, lift shafts, submerged detours
- strong momentum-control missions

5. `Royal Armory`
- weaponized interior spaces
- sealed halls, moving locks, elite combat encounters

6. `Queen's Core`
- bio-mechanical climax
- denser threat language, ritual machinery, final-route mastery

## Mission Structure

Reference details live in [HUB-WORLD-PIVOT.md](/C:/Users/mzwin/Downloads/videogame/HUB-WORLD-PIVOT.md).

Each stage should support around ten missions that materially change how the same space is read.

Good mission families:

1. reach the high point
2. beat the route under time pressure
3. clear marked combat nests
4. find a hidden relic cache
5. activate a relay chain in one run
6. survive a hazard-variant version of the stage
7. finish with a restricted movement rule
8. hunt a roaming elite target
9. open and finish through a locked sub-route
10. defeat the stage boss or mission champion

Rules:

- missions must remix traversal, combat, and exploration
- mission objectives must change stage rhythm, not just stage text
- the same physical level should feel emotionally different across multiple marks

## Combat Direction

Reference details live in [MELEE-COMBAT-SPEC.md](/C:/Users/mzwin/Downloads/videogame/MELEE-COMBAT-SPEC.md).

The old blaster-first direction is the wrong fantasy.

The right fantasy is:

`parkour with a morph-blade`

That means:

- the player closes distance instead of zoning from safety
- kills should feel like a cut through the lane, not target practice
- movement and attacks should chain as one expression
- enemies should present readable melee windows, not generic contact damage blobs

If a combat idea makes the player stand still and swing, it is wrong.

## Weapon System

Reference the opening structure in [FIRST-VERTICAL-SLICE.md](/C:/Users/mzwin/Downloads/videogame/FIRST-VERTICAL-SLICE.md) and [EARLY-WEAPON-UPGRADES.md](/C:/Users/mzwin/Downloads/videogame/EARLY-WEAPON-UPGRADES.md).

The baseline kit should start with a meaningful ship-armory choice between `Arc Cutter` and `Blaster`, but the game still needs a strong melee identity overall.

Rules:

- the first choice changes the opening hour
- both starters begin humble, not heroic
- both weapons get small early upgrades before they become expressive
- the unchosen weapon should be earned later, not lost forever

### Core Starter Kit

These are the `later real forms`, not the very first weak ship-drop versions.

1. `Saber String`
- fast three-hit ground chain
- short two-hit air chain
- the default pressure tool

2. `Rising Slash`
- anti-air cutter
- route-correction tool
- helps connect into drones and upper lanes

3. `Dive Cleave`
- downward strike
- converts aggression into bounce or rebound on valid targets
- the cleanest way to make combat feed verticality

4. `Dash Slash`
- forward commitment move
- wide, readable lane-clearing hit
- one of the main “that looked sick” verbs

### Later Weapon Modules

Keep later weapons melee-first and purpose-built.

1. `Queen Fang Saber`
- balanced default form
- best all-around kit

2. `Ripper Talons`
- faster strings
- stronger air pressure
- shorter reach, better combo extension

3. `Arc Glaive`
- wider swings
- crowd control and armored target answer
- slower commitment

4. `Breaker Claw`
- armor-piercing dash cut
- barrier and lock interaction tool
- progression-sensitive utility weapon

If a later weapon behaves like a disguised gun, cut it.

## Movement-Combat Rules

- Every major attack should preserve or redirect momentum.
- Ground attacks control space; air attacks keep flow alive.
- Rising Slash is the anti-air answer, not free float.
- Dive Cleave should only bounce on valid targets or marked bounce surfaces.
- Dash Slash should be the signature commitment move, not a spam state.
- Burst, wall kick, and slash should chain cleanly.
- The game should reward sequences like:

```text
wall kick
    -> rising slash
    -> burst
    -> dive cleave
    -> land in motion
```

That is the target expression. Not pure precision. Not pure mash.

## Enemy Design Rules

- Enemies need visible weak zones and punish windows.
- Air enemies should invite Rising Slash or air string answers.
- Heavy enemies should ask for Dash Slash, parry windows, or weapon-module choice.
- Hazard contact should not be the whole enemy design.
- Mines, nests, and pods should create route pressure that melee can solve dramatically.
- Enemies must die loudly and clearly enough to make close combat satisfying.

## Hub World Rules

- The hub must be compact enough to memorize within 15 minutes.
- The hub must contain secrets and movement tests so revisits stay interesting.
- The player should always be able to see or infer at least one future gate.
- The hub should evolve visually as more missions are cleared.
- The hub must support both calm navigation and stylish free-running.

## Feel Rules

- Cool beats exacting.
- The player should look competent quickly.
- Slashes should read big and clean, not noisy.
- Burst is still a recovery tool, not a hover mode.
- Air control should support swagger, not mush.
- The first 20 seconds of play should include one aggressive recovery and one satisfying close-range kill.

## Visual Direction

- Stage structure reference: Mario 64 progression logic
- Combat feel reference: Mega Man ZX saber flow
- Pixel readability reference: Mega Man & Bass / Mega Man 7

World mood:

- ruined royal megastructures
- infested industrial transit
- sunset skyline melancholy
- overgrowth reclaiming machinery
- hive bio-mechanical threat

This should not feel like generic industrial sci-fi and should not feel like toy-collectathon whimsy. It should feel like a fallen insect kingdom you can learn, conquer, and cut through.

## Stage 1 Direction

Use [STAGE-01-VISUAL-BAR.md](/C:/Users/mzwin/Downloads/videogame/art/source/STAGE-01-VISUAL-BAR.md) as the hard visual bar for the opening chapter.

Locked calls:

- Stage 1 is a `combat showcase with jetpack flow between fights`.
- The player silhouette is `hybrid kit, blade-led identity`.
- The world can be dark and oppressive, but the gameplay plane must stay clearly above the background in value and contrast.
- The first cave boss room must read as a designed set piece, not a dark slab with UI on top.

## Art Rules

Use [PIXEL-ART-FUNDAMENTALS.md](/C:/Users/mzwin/Downloads/videogame/PIXEL-ART-FUNDAMENTALS.md) as the hard bar.

Extra priorities for this direction:

- stage silhouettes must be recognizable from a screenshot
- hub landmarks must be readable from mid-distance
- saber arcs and hit flashes must never muddy collision reads
- the player silhouette must now prioritize blade shape over gun shape
- slash effects should feel authored and disciplined, not smeared anime noise

## Environment Rules

- Each stage needs one signature skyline or interior silhouette.
- Each stage needs one signature movement problem.
- Each stage needs one signature combat pressure pattern.
- Platforms must still be the clearest surfaces on screen after the player.
- Hub routes should be legible enough that the player builds spatial memory.

## Character Rules

### Player

- Base size: `32x32`
- silhouette priority:
  - helmet or hair mass
  - torso core
  - boots
  - blade read
  - burst nozzles

The player should read more like a mobile blade-user than a small shooter hero.

### Effects

Prioritize:

- slash arc
- hit spark
- burst ignition
- rebound flash
- enemy break pop

Do not prioritize:

- muzzle flash
- tracer spam
- projectile spectacle

## Production Slice

The first complete vertical slice for this direction should be:

- one live title screen that becomes the intro with no hard transition
- one side-scrolling landing stretch into the ship armory
- one first weapon choice: `Arc Cutter` or `Blaster`
- one compact sanctuary hub sector
- one `Hive Shaft` stage door
- three missions that materially remix that first stage
- weak-but-readable early upgrades for both starter weapons
- four enemy archetypes built for readable blade/gun pressure
- one boss or elite mission target later in the slice

Do not try to build all six stages before this slice proves the structure.

## Explicitly Not The Game

- not a pure metroidvania with one seamless map
- not a score-chase climb only
- not a blaster-first platform shooter
- not a punishing precision platformer with melee on top
- not a generic “collect ten things” mission structure

## Source Docs

- hub-world structure: [HUB-WORLD-PIVOT.md](/C:/Users/mzwin/Downloads/videogame/HUB-WORLD-PIVOT.md)
- first vertical slice: [FIRST-VERTICAL-SLICE.md](/C:/Users/mzwin/Downloads/videogame/FIRST-VERTICAL-SLICE.md)
- melee combat spec: [MELEE-COMBAT-SPEC.md](/C:/Users/mzwin/Downloads/videogame/MELEE-COMBAT-SPEC.md)
- early weapon progression: [EARLY-WEAPON-UPGRADES.md](/C:/Users/mzwin/Downloads/videogame/EARLY-WEAPON-UPGRADES.md)
- starter rival boss: [STARTER-RIVAL-BOSS.md](/C:/Users/mzwin/Downloads/videogame/STARTER-RIVAL-BOSS.md)
- enemy roster: [ENEMY-DESIGN-SPEC.md](/C:/Users/mzwin/Downloads/videogame/ENEMY-DESIGN-SPEC.md)
- region art direction: [REGION_ART_DIRECTION.md](/C:/Users/mzwin/Downloads/videogame/art/source/REGION_ART_DIRECTION.md)
- stage 1 visual bar: [STAGE-01-VISUAL-BAR.md](/C:/Users/mzwin/Downloads/videogame/art/source/STAGE-01-VISUAL-BAR.md)
- pixel art fundamentals: [PIXEL-ART-FUNDAMENTALS.md](/C:/Users/mzwin/Downloads/videogame/PIXEL-ART-FUNDAMENTALS.md)
