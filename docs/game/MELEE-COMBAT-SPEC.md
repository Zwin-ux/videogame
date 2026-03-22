# MELEE COMBAT SPEC

## Combat Thesis

`Killer Queen` should stop feeling like “parkour with a sidearm” and start feeling like “parkour with a morph-blade.”

The player should be cutting through threats at close range, not hovering back and plinking them from safety.

The design reference is Mega Man ZX, but the goal is not imitation. The goal is:

- clean melee readability
- stylish forward pressure
- movement and attacks behaving like one system

## Core Fantasy

The player uses a saber rig and later melee weapon modules to:

- cut lanes open
- bounce off valid targets
- anti-air bugs and drones
- dash through pressure points
- convert combat back into movement

Combat should feed traversal. Traversal should feed combat.

## Default Starter Kit

Start with one weapon and four core verbs.

### 1. Saber String

- three-hit ground chain
- two-hit air chain
- low commitment
- bread-and-butter pressure tool

### 2. Rising Slash

- upward cutter
- anti-air answer
- route-correction tool
- used after jump, wall kick, or grounded starter

### 3. Dive Cleave

- downward strike
- spikes into valid targets
- grants rebound, bounce, or follow-up window on success
- the main aggression-to-height converter

### 4. Dash Slash

- forward commitment move
- wide and readable
- breaks through crowded lanes
- one of the coolest verbs in the game when tuned well

## Later Weapon Modules

Add only a few weapons, and give each one a clear purpose.

### Queen Fang Saber

- balanced default form
- best all-purpose route and combat kit

### Ripper Talons

- faster strings
- stronger air combo pressure
- shorter reach
- better for stylish aggressive players

### Arc Glaive

- slower but wider
- better crowd control
- better against armored targets

### Breaker Claw

- armor-piercing dash cut
- progression-sensitive barrier interaction
- utility weapon for gates and heavy enemies

## Interaction Rules

- Attacks should preserve or redirect momentum whenever possible.
- Air attacks should be shorter and more decisive than grounded ones.
- Only a small number of verbs should move the player significantly.
- Dive Cleave should only bounce on explicit valid targets or bounce surfaces.
- Dash Slash should be strong enough to matter but not so safe that it erases all spacing.
- Rising Slash should be the main anti-air answer instead of a free double jump replacement.

## Movement Chains

The game should reward chains like:

```text
dash slash
    -> wall kick
    -> rising slash
    -> burst
    -> dive cleave
    -> land in motion
```

If the player must stop to “do combat,” the system has failed.

## Enemy Rules

Enemies need to be built for melee readability:

- clear hurt zones
- clear punish windows
- readable body language before attacks
- no unfair contact blobs
- clear rebound logic for dive attacks

Recommended enemy families:

1. `Hover Bugs`
- bait Rising Slash

2. `Shield Crawlers`
- demand Dash Slash or flank timing

3. `Nest Pods`
- create localized pressure and stage variation

4. `Lancer Wasps`
- punish passive spacing, reward aggressive cut-ins

5. `Champion Units`
- mission anchors and mini-bosses

## Effects Rules

- slash arcs must be clean and readable
- hit sparks must confirm connection instantly
- death pops must be short and satisfying
- no muzzle-flash or projectile-centric visual language in the main combat kit

## What To Remove

The ranged blaster should no longer define the game.

That means:

- do not build combat around standing back and shooting
- do not make the saber a backup tool
- do not keep adding projectile complexity if the melee loop is not already fun

If a ranged option survives later, it should be a limited utility or specialty module, not the fantasy anchor.

## First Combat Slice

Ship this first:

- saber string
- rising slash
- dive cleave
- dash slash
- four enemy types designed around melee windows
- one elite target or boss mission

That is enough to prove the new combat identity.
