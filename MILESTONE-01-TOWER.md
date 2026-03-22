# Milestone 01: Movement Tower

## Goal

Replace the current horizontal pickup mission with a fixed vertical tower that proves the real game loop is fun:

- climb fast
- recover from mistakes
- chain movement verbs
- restart instantly

Success for this milestone is not content volume. Success is a 60-90 second run that makes you want another attempt immediately.

## One-Liner

A fast 2D jetpack parkour climber with wall-kicks, burst movement, clutch recoveries, and high-quality SNES-inspired pixel art.

## Player Promise

Within the first minute, the player should:

- save at least one bad jump with burst or wall kick
- recognize at least two route choices
- understand that upward speed matters
- restart once and get back into action immediately

## Core Verbs

- run
- jump
- wall slide
- wall kick
- burst
- shoot
- recover

## Tower Structure

Use a fixed authored tower for this milestone.

- Height target: enough for a 60-90 second first clear or strong first failure.
- Build the tower from readable chunk patterns, but place them by hand.
- Keep one kill floor chasing the run from below or positioned to punish missed recovery.
- Route design should create alternating left-right commitments with occasional central relief.

## Required Platform Types

### Stable

- Main route support.
- Clear top surface.
- Never surprises the player.

### Crumble

- Supports brief landings, then forces movement.
- Must telegraph danger before trigger.

### Spring

- Gives a dramatic height spike and route variation.
- Must feel different from burst.

### Fuel Pad

- Restores burst resources or supports recovery.
- Should encourage risky detours.

## Required Hazard Types

### Drone

- Moving aerial threat.
- Can pressure jump timing or reward precise shooting.

### Turret Or Mine

- Static or semi-static denial hazard.
- Forces route choice and timing instead of raw damage racing.

## Shooting Rule

Shooting is secondary.

- It should remove pressure, open a line, or reward timing.
- It should not dominate scoring.
- If needed, enemy kills can restore a small amount of burst or combo stability.

## HUD Rules

Replace mission HUD with climb HUD.

Required readouts:

- altitude
- combo
- burst or fuel
- best run
- quick restart prompt

Remove for this milestone:

- pickup count
- extraction messaging
- mission-clear language

## Run State Model

```text
boot
  ->
spawning
  ->
playing
  ->
failed
  ->
restarting
  ->
playing
```

No win-state ceremony for milestone 1. If the tower has a top endpoint, treat it as a score stop and quick reset, not a separate mission flow.

## Movement Rules

### Wall Slide

- Triggers only on valid wall contact while airborne.
- Slows descent enough to plan a kick.
- Must not allow infinite stall.

### Wall Kick

- Strong horizontal and upward commitment.
- Should reliably convert a bad angle into another chance.
- Needs forgiveness on timing.

### Burst

- Short, readable, high-value movement pulse.
- Best used for saves, corrections, and aggressive route chains.
- Must not feel like free hover.

## Success Criteria

The milestone is successful if all of this is true:

- The first run is understandable without tutorial text.
- The player can feel the difference between jump, wall kick, and burst.
- Failure reads as "my route or timing was off," not "the controls betrayed me."
- Restart is fast enough that failure does not break flow.
- The game feels better moving upward than it did moving sideways.

## Minimal File Plan

Touch as few runtime files as possible.

- `scripts/player.gd`
  - add wall slide, wall kick, burst logic, and any movement-state comments
- `scripts/main.gd`
  - replace pickup-and-goal loop with altitude/combo/fail-floor tower loop
- `scenes/main.tscn`
  - update HUD labels and remove mission framing
- `scripts/enemy.gd`
  - retune drone behavior for upward pressure
- `DESIGN.md`
  - keep art and product rules aligned with the build

Only add new scripts if a platform or hazard type becomes messy without one.

## Things To Avoid

- endless generation
- metaprogression
- multiple weapons
- long fail animations
- verbose tutorial overlays
- cinematic intro logic
- decorative clutter that hurts readability

## Test Checklist

- jump buffered before landing still works
- wall slide transitions cleanly into wall kick
- burst on the same frame as wall contact is reliable
- taking damage does not leave the controller in a broken state
- restart clears stale enemies, timers, combo, and HUD values
- kill floor and camera never create invisible deaths
- a full run stays readable on keyboard and controller

## Exit Condition

Do not start content expansion until this milestone produces a run that feels addictive with placeholder art.
