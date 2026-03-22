# Slice 01 Build Order

## Goal

Build the first playable shipped opening for `Killer Queen`:

- live title screen
- no-transition start
- landing intro
- ship armory weapon choice
- weak starter weapon state
- first sanctuary pocket
- first `Hive Shaft` mission set

## Step 1: Title-To-Play Scene

Build one scene that handles:

- title state
- ship landing
- first control handoff

Do first:
- dock backdrop
- title UI overlay
- `Start` flow that retracts UI in-place
- landing animation and player spawn

Do not do yet:
- full options/menu stack
- save system
- continue flow complexity

## Step 2: Landing Stretch

Build the short side-scroll opening lane.

Must teach:
- move
- jump
- burst
- attack

Must not teach yet:
- advanced mission structure
- dense combat
- hard fail pressure

## Step 3: Ship Armory Choice

Build the in-world weapon choice beat.

Requirements:
- both weapons visible physically
- player chooses `Arc Cutter` or `Blaster`
- the unchosen weapon remains visible in the room
- choice updates HUD and starter moveset immediately

## Step 4: Weak Starter Weapon Layer

Implement the intentionally weak starting versions:

- `Service Fang`
- `Dock Blaster`

Need:
- basic stat/moveset downgrade layer
- one first upgrade reward hook

Do not build the whole upgrade tree yet.
Build only the starter forms and first reward.

## Step 5: First Combat Strip

Build the short combat route between armory and sanctuary pocket.

Use only:
- `Mite Drifter`
- `Shellback Crawler`
- `Brood Pod`

Purpose:
- teach why blade and gun solve different problems
- prove weak starter still feels viable

## Step 6: Sanctuary Pocket

Build the first compact hub fragment.

Needs:
- safe footing
- one visible future route
- one mission gate
- one light worldbuilding beat

This is the first emotional exhale after the opening strip.

## Step 7: First Upgrade Reward

Before the first real mission set, grant:

- `Sharpened Edge` if player chose Arc Cutter
- `Refit Barrel` if player chose Blaster

The reward must happen in-world.
No detached abstract upgrade screen first.

## Step 8: Hive Shaft Mission Set

Ship only 3 missions first:

1. `Breach`
2. `Nestbreaker`
3. `Summit`

These should reuse one authored early-game `Hive Shaft` layout.

## Step 9: Starter Rival Boss

Build the first boss as the rival-weapon reveal.

Rule:

- the boss uses the perfected version of the weapon the player did not choose
- this is not a neutral monster
- this is the game proving the alternate weapon matters

If player chose `Arc Cutter`:
- boss uses `Maximum Blaster`

If player chose `Blaster`:
- boss uses `Maximum Arc Cutter`

Reference:
- [STARTER-RIVAL-BOSS.md](/C:/Users/mzwin/Downloads/videogame/STARTER-RIVAL-BOSS.md)

## Step 10: Alternate Weapon Unlock

After the rival boss:

- award the damaged starter-grade version of the unchosen weapon
- do not award the boss version itself

Why:
- long enough for the opening choice to matter
- cleanly tied to a real dramatic beat
- early enough that the game becomes clearly dual-weapon before it goes flat

## Step 11: Mid-Game Ramp

Only after Slice 01 works:

- increase enemy density
- increase climb pressure
- move toward the current live tower benchmark

Do not start the game at the current benchmark.

## Ship Criteria

Slice 01 is good enough to build when:

- the title/start flow feels premium
- the first 5 minutes feel natural
- weapon choice feels meaningful
- first upgrade feels noticeable
- sanctuary pocket makes the game world feel larger
- first `Hive Shaft` missions prove replay structure
