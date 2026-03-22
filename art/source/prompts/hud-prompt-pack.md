# HUD Prompt Pack

Source brief: `art/source/briefs/hud-opening-slice-brief.md`

Use these prompts with the opening-slice art bible, the palette matrix, and the current menu critique.

## Navigation Copy Recommendations

Use direct meaning first and fiction second.

- `TAKE CONTRACT`
  - Summary: `Start a run. Drop into Khepri-9 and clear the opening claim.`
- `DOSSIER`
  - Summary: `Review shells, weapon notes, and hunter records.`
- `LEDGER`
  - Summary: `Check credits, payouts, and recent claim totals.`
- `SYSTEMS`
  - Summary: `Adjust audio, display, prompts, and controls.`
- `CREDITS`
  - Summary: `View crew, tools, and fabrication.`
- `QUIT`
  - Summary: `Return to desktop.`

Front-door grouping:

- Primary: `TAKE CONTRACT`
- Secondary: `DOSSIER`, `LEDGER`
- Utility: `SYSTEMS`, `CREDITS`, `QUIT`

Replace weak framing labels like `SHIP BOARD` with `COMMAND BOARD` or remove the label entirely if the logo and rail already carry the concept.

## Asset Group: Live HUD

### Concept

Design a lean live HUD for `Killer Queen` that frames play without overpowering it.
The strip should feel like sharp arcade hardware with tactical discipline.
It must support weapon read, shell count, survivability information already in use, and boss state when needed.
The world stays dominant.

### Production Sprite

Produce final pixel-art HUD elements for `hud_opening_slice.aseprite`.
Build a slim top strip, a concise boss bar, a shell chamber module, and minimal dividers.
Reserve the brightest accent for current selection, current shell event, or boss danger.
Avoid large filled panels and repeated decorative borders.

### Repair/Review

Review the live HUD for hierarchy, spacing, and restraint.
Check whether the world remains the first read.
Check whether shell count is obvious without reading a paragraph.
Remove any border, backing plate, or icon treatment that feels like debug scaffolding.

## Asset Group: World-Space Prompt Guide

### Concept

Design a small world-space guide that teaches buttons the way a Zelda helper or dock drone would, but in this game's tactical shipboard language.
It should point the eye, not narrate the obvious.
The guide needs one clean silhouette, one clear prompt icon, and minimal chatter.

### Production Sprite

Produce the guide sprite, prompt frame, and small idle/hover states for `hud_opening_slice.aseprite`.
Make it readable over dark cave and bright deck surfaces.
Keep motion brisk and snap-focused.
The prompt icon should wake up clearly when the player is in range of a rack or interaction.

### Repair/Review

Review the guide for teaching clarity and visual modesty.
Check whether it highlights the action without becoming the focal point of the room.
If it feels cute but vague, simplify it toward one clear tactical helper read.

## Asset Group: Front-Door Command Menu

### Concept

Redesign the front door as a strong game menu that keeps the retro diegetic sci-fi style but stops behaving like a decorative terminal screenshot.
The eye order must be logo, primary action, active section payoff, then metadata.
Use a cleaner hero strip at the top, a heavier left navigation rail, and a larger section-specific showcase panel on the center-right.
The primary action must feel urgent.
Each section should feel meaningfully different without breaking the overall visual system.

### Production Sprite

Produce front-door UI art for `hud_opening_slice.aseprite`, consolidating the role currently split across `menu_console_logo`, `menu_console_window`, `menu_console_atlas`, and `menu_console_cursor`.
Build:
- a smaller, cleaner hero strip with logo, selected section title, one-line summary, and 2 to 4 useful metadata items
- a heavier left rail with grouped menu entries and a hard active state
- a section showcase panel that can present contract, dossier, ledger, systems, credits, and quit with different internal layouts
- a dedicated controls/help zone separate from fiction chatter
- a stronger CTA treatment for `TAKE CONTRACT`

Typography rules:

- avoid narrow stat boxes
- use larger horizontal modules
- keep body copy and metadata clearly separated
- let important numbers breathe on one line

### Repair/Review

Review the front-door menu for hierarchy, punch, and clarity.
Check whether the top banner has one job instead of five.
Check whether selection feels like a hard snap.
Check whether section changes feel emotionally different.
Check whether the player instantly knows what to click to start the game.
If the screen still feels more like a computer in a room than the start of a game loop, simplify and refocus it.
