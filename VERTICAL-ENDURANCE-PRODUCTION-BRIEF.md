# Vertical Endurance Production Brief

## Current Call

For the current benchmark build, the game is:

`a vertical endurance jetpack climb with fun combat pressure`

It is not:

- a combat-setpiece game
- a pure boss-rush game
- a room-to-room brawler
- a content expansion pass

Combat exists to sharpen the climb. The climb is the product.

## What Changes Now

These calls are locked for the next pass:

- The camera is not locked. It can tighten in danger and rivalry beats.
- The rival section is no longer part of the main climb route. It should be a separate encounter space with a clean transfer.
- Platform colors are not final. Rebuild the platform language.
- The tower must support multiple upward choices with recovery options. A player who commits left or right should still be able to continue upward.
- The tower should feel like vertical endurance first, stylish action second.

## Success Bar

The build is correct when a player says:

- "I almost fell, but I saved it."
- "That upper route looked faster."
- "I can fight while climbing without losing the run."
- "The boss area felt like an arrival, not an accident."

The build is wrong when a player says:

- "I got stranded."
- "Every room looks the same."
- "I lost track of my character."
- "The rival section came out of nowhere."

## North Star

Keep the run readable, fast, and forgiving enough to recover from a bad line.

The player should always understand:

1. where to go next
2. what the safe recovery is
3. what the faster riskier option is
4. what is trying to stop them

If a room does not create those four reads, it is unfinished.

## Route Model

The climb should be rebuilt as authored chunks with repeatable jobs.

```text
start shelf
  ->
teach fork
  ->
recovery basin
  ->
pressure ladder
  ->
cross-route split
  ->
relief shelf
  ->
speed gauntlet
  ->
transfer shelf
  ->
rival arena
```

The rival arena is separate. Do not make the main endurance route double as boss staging.

## Chunk Rules

Every climb chunk must contain:

- one primary route
- one faster alternate route
- one visible recovery option
- one clear landing surface after a risky commit

Every chunk must avoid:

- single-solution routing
- dead air with no next read
- long falls that feel like layout punishment
- mirrored repeated platform ladders

## Chunk Specs

### 1. Start Shelf

Job:
- establish the first safe read
- let the player re-center

Must include:
- one wide anchor platform
- one obvious upward line
- one optional side reward or short detour

Must not include:
- early visual clutter
- aggressive combat density

### 2. Teach Fork

Job:
- teach that there is more than one valid upward path

Must include:
- a left route and right route that both reconnect upward
- one route that is safer and slower
- one route that is faster and more demanding

### 3. Recovery Basin

Job:
- give the player a fair place to save a bad line

Must include:
- one lower recovery shelf
- one wall or spring that lets the player regain height
- enough headroom to correct with burst

This chunk is where trust is built.

### 4. Pressure Ladder

Job:
- combine movement and enemy pressure without stopping the run

Must include:
- 2-3 staggered platforms
- one enemy or hazard that changes timing
- one safe perch after the pressured move

Combat here should redirect movement, not freeze it.

### 5. Cross-Route Split

Job:
- make the player choose a style of ascent

Required split:
- high-risk speed route with narrow relays
- slower route with larger catches

Both routes must reconnect within one chunk.

### 6. Relief Shelf

Job:
- let the run breathe
- reset visual rhythm

Must include:
- one larger stable platform
- lower enemy count
- a stronger landmark or background read

This is not downtime. It is pacing.

### 7. Speed Gauntlet

Job:
- create the best "I barely made that" moment in the run

Must include:
- one sequence where burst, wall kick, or spring saves a bad line
- one visible backup platform underneath the fast route

The fast line must feel thrilling, not mandatory.

### 8. Transfer Shelf

Job:
- cleanly end the endurance route
- signal that a different kind of space is next

Must include:
- one broad arrival platform
- one obvious gate, lift, breach, or door into the rival arena
- no awkward sideways crawl into the boss

## Platform System

Do not keep treating every platform as the same cyan slab.

Keep `kind` for gameplay behavior. Add `archetype` for route role and visual treatment.

### Required Archetypes

#### Anchor

Job:
- main safe support

Rules:
- medium to wide
- darkest body
- pale top lip
- easy to trust at a glance

#### Relay

Job:
- fast route continuation

Rules:
- thinner than anchor
- brighter edge read
- should feel temporary even if mechanically stable

#### Recovery

Job:
- catch a bad route

Rules:
- slightly wider than relay
- visually quieter than main route
- placed one tier below a risk point

#### Kick Wall

Job:
- obvious wall-kick support

Rules:
- vertical trim language
- clear side face
- never visually disguised as background architecture

#### Spring

Job:
- dramatic height gain

Rules:
- amber family
- must read before landing
- should look mechanically different from every other platform

#### Fuel

Job:
- optional recovery resource

Rules:
- contained teal reservoir
- side-route lure, not mandatory route tax

#### Gate

Job:
- transition marker for rival or stage boundary

Rules:
- broader silhouette
- heavier trim
- should feel infrastructural, not like a normal ledge

## Platform Color Hierarchy

Do not let platform color compete with the player's main read.

Use this hierarchy:

- Player: cream body, controlled cyan accents, amber highlights
- Anchor platforms: dark steel body with pale cream top edge
- Relay platforms: muted blue-green edge, not player-cyan
- Recovery platforms: quieter slate and worn brass
- Springs: amber-orange
- Fuel: contained teal reservoir, dimmer than player trim
- Hazards: amber to hot red
- Rival gate: heavier bronze or warning-metal treatment

Rule:
- player cyan must stay the most alive cyan on screen
- danger amber must stay the hottest warm color on screen

## Camera Rules

The player camera in [player.tscn](/C:/Users/mzwin/Downloads/videogame/scenes/player.tscn) currently sits at `zoom = 1.45`.

That should become the middle band, not the only camera.

### Camera Bands

#### Endurance Default

- zoom: `1.36`
- upward look bias: `56-72 px`
- use for neutral climb chunks

This shows more route ahead and supports planning.

#### Pressure Tighten

- zoom: `1.48`
- upward look bias: `40-52 px`
- use for enemy pressure ladders and speed gauntlets

This makes threat timing easier to read.

#### Arrival / Transfer

- zoom: `1.42`
- upward look bias: `28-40 px`
- use for the transfer shelf

This keeps the exit readable without flattening the space.

#### Rival Arena

- zoom: `1.58`
- upward look bias: `16-28 px`
- use once the player enters the separate rival arena

This makes the event feel deliberate.

### Camera Implementation Rule

Do not build a fancy camera system first.

Use simple data-driven camera zones in `main.gd`:

- rect
- zoom
- look_bias_y
- label

Then switch the player camera when the player enters a zone.

## Combat Placement Rules

Combat in the climb should do one of three jobs:

- pressure the route
- reward a smart line
- create a satisfying mid-air kill

Combat should not do these jobs:

- stop the run dead
- demand arena spacing in the main climb
- clutter the frame in recovery sections

Enemy placement rules:

- one pressure moment per chunk is enough
- do not stack enemies and hazards on the same exact landing read
- every enemy should either threaten timing or offer a satisfying kill line

## Rival Separation Rules

The rival section is a separate stagelet, not the awkward top of the climb.

Rules:

- the climb ends on a transfer shelf
- the rival arena begins through a clear gate or chamber transition
- the rival room can stay visually simple for now
- the rival room must read as a different mode of play

Simple is fine.
Awkward is not.

## Immediate Layout Rebuild

Rebuild the current climb with these concrete route rules:

- every major upward decision must reconnect within 1-2 platform tiers
- every fast route needs a visible catch below it
- every long ascent lane needs at least one rest shelf
- every high-risk movement verb should have a recovery answer nearby
- one major chunk should deliberately alternate left-right-left-right to create climb rhythm
- one major chunk should include a central relief line so the player can reset

## What To Cut

Do not spend time on these in this pass:

- more enemy types
- more backgrounds
- more UI copy
- more weapon systems
- broad rival art polish
- extra cinematic logic

The pass is route, platform read, camera, and transition.

## File-by-File Execution Order

### 1. [main.gd](/C:/Users/mzwin/Downloads/videogame/scripts/main.gd)

Primary owner of the rebuild.

Tasks:

- replace the current `PLATFORM_DATA` climb with chunked route data
- add extra recovery and reconnect platforms
- split the rival lead-in out of the main climb route
- add a `TRANSFER_SHELF` and separate rival entry
- add data-driven camera zones for climb, pressure, transfer, and rival
- keep the current movement kit intact while changing layout

### 2. [platform_piece.gd](/C:/Users/mzwin/Downloads/videogame/scripts/platform_piece.gd)

Primary owner of platform read.

Tasks:

- add `archetype` as a visual/route role separate from `kind`
- rebuild platform rendering around archetype and region style
- make anchor, relay, recovery, spring, fuel, and gate visually distinct
- keep collision simple

### 3. [backdrop.gd](/C:/Users/mzwin/Downloads/videogame/scripts/backdrop.gd)

Primary owner of world support.

Tasks:

- quiet the shaft background in the main endurance route
- strengthen landmark reads around relief shelves and transfer shelf
- keep the rival arena background simpler and more contained than the climb

### 4. [player.tscn](/C:/Users/mzwin/Downloads/videogame/scenes/player.tscn)

Primary owner of base camera tuning.

Tasks:

- set the default player camera to the endurance band baseline
- keep smoothing, but tune for the new zoom bands

### 5. [main.tscn](/C:/Users/mzwin/Downloads/videogame/scenes/main.tscn)

Touch only if marker support or transfer staging becomes cleaner with scene anchors.

### 6. [cave_arena.gd](/C:/Users/mzwin/Downloads/videogame/scripts/cave_arena.gd) and [cave_rival_boss.gd](/C:/Users/mzwin/Downloads/videogame/scripts/cave_rival_boss.gd)

Touch only after the route split exists.

Tasks:

- keep the rival encounter compact
- avoid letting rival logic leak back into the endurance route

## Acceptance Criteria

The pass is done when all of this is true:

- the player can choose multiple upward paths and still reach the next chunk
- every major risk point has a visible recovery answer
- the player is the first read in motion, not the platforms
- anchor, relay, spring, fuel, and gate platforms are visually distinct on sight
- the default climb camera shows more route ahead without making the player tiny
- pressure chunks tighten the camera enough to improve readability
- the rival arena is reached through a clean transfer, not a weird accidental lead-in

## Test Checklist

- first 20 seconds contain one safe shelf, one fork, one recovery, and one pressure moment
- a missed fast route can still be recovered from without full reset
- wall-kick chunks still feel intentional after the layout rebuild
- fuel side routes are optional, not mandatory
- springs create delight, not confusion
- the rival transfer is obvious from one screen away
- the rival arena camera feels different from the climb camera
- platform colors stay readable against both hive-dark and warm-stage backgrounds

## Final Call

This pass should make the tower feel like:

- a trustworthy climb
- with stylish interruptions
- and a clear event at the top

Do not chase spectacle before the route reads.
