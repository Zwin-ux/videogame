# HUD Opening Slice Brief

## Purpose

Define the minimal presentation and HUD layer for the opening slice so the UI stops looking like scaffolding and starts behaving like a sharp arcade frame around live play.
This brief covers the slim top HUD, boss bar, shell readout, world-space prompt guide, and the reduced front-door overlay.

## Camera/Scale

- Designed for desktop first, but readable on smaller window sizes
- UI should occupy as little vertical space as possible during live play
- The world remains the dominant screen read
- Boss moments may temporarily elevate the boss bar, but never bury the play lane

Asset groups:

- top HUD strip
- boss bar strip
- shell chamber readout
- world-space prompt guide
- front-door hero strip and starter-choice framing
- terminal menu navigation and section showcase panels

## Silhouette

- HUD should read as one disciplined line system, not stacked blocks
- Boss bar should feel like one tactical meter with a clear name read
- World-space prompt guide should have a clean mascot or guide silhouette and one obvious button callout
- Front-door overlay should frame the live world instead of replacing it

Required UI reads:

- current weapon
- health or survivability state already in use
- Blaster shell count when equipped
- boss health and name
- active claim prompt
- one-line title framing at the start
- primary play action before secondary and utility options
- selected terminal section and what it actually does

## Palette

- warm cream and sharp white for primary text
- amber line work for emphasis and warnings
- restrained cyan for guide, prompt, or secondary tactical read
- deep navy and charcoal for quiet panel backing when a backing is necessary

Rules:

- keep opaque backing narrow
- use one dominant accent per strip
- avoid bright purple, generic neon, and unrelated accent colors
- UI accents must not outshine gameplay hazards
- reserve the brightest UI accent for the selected state and primary CTA

## Materials

- UI should feel like a lived-in tactical display, not a software dashboard
- Borders are thin and deliberate
- Fill panels only when readability genuinely needs them
- Prompt guide can be characterful, but must stay small and instantly readable
- Typography should feel like sharp arcade hardware, not terminal debug sludge
- Front-door menu panels should feel like real command modules, not placeholder monitors

## Animation

- starter guide hover and snap-to-rack motion
- short boss bar intro wipe
- shell chamber tick and refill beat
- route-clear confirmation strip
- no giant panel slides or soft tween soup

Motion notes:

- movement should be brisk and confident
- the guide should help the eye, not become the main actor
- front-door framing should appear ceremonial, then get out of the way
- menu selection should snap harder than ambient panel animation

## Readability Tests

- Does the world remain the dominant read while the HUD is on screen.
- Can a player understand the starter choice without reading dense panels.
- Does the shell readout explain Blaster scarcity in one glance.
- Does the boss bar feel premium without taking over the top quarter of the screen.
- Is the guide still readable on both dark cave and bright deck backgrounds.
- Does the UI look authored rather than debug-built.
- Does the terminal menu direct the eye logo to primary action to section payoff without wandering.
- Do section changes feel distinct instead of like the same panel with different labels.

## Do Not Do

- Do not build stacked terminal slabs
- Do not duplicate the same information in overlay, footer, and world-space prompt
- Do not use heavy opaque boxes by default
- Do not animate UI with slow floaty tweening
- Do not make the guide cute at the expense of clarity
- Do not let the boss bar overpower the rival silhouette
- Do not let fiction chatter bury the actual menu meaning
- Do not use narrow stat boxes that split words into awkward stacked fragments

## Export Target

- Recommended authored source target: `art/source/hud_opening_slice.aseprite`
- Expected exports:
  - `art/export/hud_opening_slice.png`
  - `art/export/hud_opening_slice.json`
- World-space prompt guide may also export separate icon slices if the runtime keeps prompt assembly modular
- If the front-door title art remains a standalone asset, keep it grouped under the same source file rather than creating a separate UI pipeline
- Existing runtime-only menu art that should be consolidated into the same authored source over time:
  - `art/export/menu_console_logo.png`
  - `art/export/menu_console_window.png`
  - `art/export/menu_console_atlas.png`
  - `art/export/menu_console_cursor.png`
