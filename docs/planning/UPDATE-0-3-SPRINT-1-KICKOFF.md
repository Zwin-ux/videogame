# Update 0.3 — Sprint 1 Kickoff

Picking-up doc for the day `0.2 Hive Signal` tags. The full 0.3 spec lives at
`UPDATE-0-3-SKYLINE-SHIFT.md`; this file turns that spec into the first five
days of concrete work.

If this file disagrees with the larger spec, the larger spec wins. This is
just the task list for the first pass.

---

## Prerequisite

`0.2 Hive Signal` tagged as `v0.2.0`. Final reviewer signs off. Any leftover
review items fall into this sprint's cleanup slot, not the main tracks.

## What this sprint proves

The mission OS runtime actually dispatches a second region, using the feel
foundation from `0.2` as the audible layer. After five days we should be able
to select `Mission 2` from the sanctuary terminal and play through two rooms
of Skyline using live audio, shake, hit-stop, combo tick. It will look like
Dock Breach reskinned — that's fine. Silhouette art comes in sprint 2.

Explicit non-goal for this sprint: polish. If it loads, runs, and does not
regress 0.2, it shipped.

## Day-by-day plan

### Day 1 — Mission descriptor plumbing

- Read `scripts/hive_region_data.gd` MISSION_ORDER and the metadata slots
  for missions 2-5. Confirm fields: `timer`, `enemy_remix`, `route_state`,
  `reward`.
- In `scripts/main.gd`, find the mission loader that today special-cases
  `Dock Breach`. Lift it behind a `MissionDescriptor` pointer: the loader
  consumes the metadata dict instead of hardcoded constants.
- Smoke test: launch `Mission 2 Skyline Shift` from dev console and confirm
  it loads the Dock Breach geometry without crashing. Geometry stub is OK;
  we are testing dispatch, not content.

Success gate: `godot --headless --script tests/run_tests.gd` still green.
Add one test: `test_mission_dispatch.gd` that instantiates MissionDescriptor
for mission 2 and asserts the loader accepts it.

### Day 2 — Skyline geometry blockout (steal + mirror)

- Copy Dock Breach's seven subarea geometry arrays into a new Skyline block
  in `scripts/hive_region_data.gd`. Rename per the Skyline room list:
  Lift Crest, Cable Walk, Comm Tower Rise, Bridge Cross, Rooftop Garden,
  Wind Lash, Roof Edge Duel.
- Leave art/silhouettes untouched — the rooms are mechanically identical to
  Dock for now. This is to validate the mission dispatch works against a
  different geometry table, not to build distinct level design.
- Mission 2 loads the new Skyline block; Dock Breach still loads its own.

Success gate: play through mission 2 end-to-end on keyboard. No crash.
The climb FEELS like Dock Breach because it mechanically is. Good — we
haven't regressed.

### Day 3 — Mission remix: `Rooftop Rush` (mission 3)

- Mission 3 loads Skyline geometry but enforces a tightened timer contract
  (Rush metadata already exists). Extract timer logic from main.gd into the
  MissionService the same way dispatch got lifted on day 1.
- Confirm `_threats_cleared / _total_threats` tallying still works.
- Combat intensity should peak faster because Rush missions pressure more.

Success gate: mission 3 completable. Timer UI reads correctly. 0.2 tests
all still green.

### Day 4 — Skywatcher enemy bringup

- Create `scripts/skywatcher.gd` extending `shooter_enemy.gd`. Hover
  patrol pattern. One lateral drift attack, one dive attack. Weak zone on
  the underside exhaust cowl per spec.
- Placeholder sprite: blockout pass using `tools/generate_hazard_sheets.gd`
  pattern with a distinct silhouette palette. Real art sprint 2.
- Place two Skywatchers in Skyline mission 2 room 2 (`Cable Walk`).

Success gate: player can kill a Skywatcher with either weapon. 0.2 feel
chain fires on the kill (verified via the `juice_integration` test
pattern — consider a new integration test per enemy family).

### Day 5 — Sanctuary mission terminal + cleanup

- The sanctuary front door scene currently hard-routes to Dock Breach.
  Replace the panel with a diegetic mission manifest board showing four
  pinned slips: `Dock Breach`, `Skyline Shift`, `Rooftop Rush`, `Elite
  Sweep`. Selection glows gold; no boxes. (See
  `feedback_arcade_cabinet` memory or `CODEX-UI-DIRECTOR-PROMPT-PACK`.)
- Locked missions show a red stamp, unlocked a gold one. For now, unlock
  state is hardcoded while the save system lands in 0.4.
- Sweep any loose `Bugs BE Munchin` copy that re-emerged during the
  sprint (grep `Bugs`, `bugs be munchin` case-insensitive).

Success gate: sanctuary → mission select → Skyline 2 round-trip. No web-UI
drift in the terminal layout. Five playtesters rotate through the four
missions; collect notes in `docs/playtest/beta-round-2.md`.

## What the sprint does NOT touch

- Foundry. Stays metadata until post-beta.
- `main.gd` monolith split. That lands under 0.4 The Royal Cut.
- Save system. 0.4.
- Authored audio stems. Procedural bed stays in place until a human
  composer supplies .ogg files — they drop into `art/audio/music/` with
  the naming `dock_breach_<stem>.ogg`, `skyline_<stem>.ogg`, etc. and
  MusicEngine auto-loads them on first play of that track.
- Skyline background silhouettes. Sprint 2.

## Cut-lines (what to drop if time slips)

- Mission 4 `Elite Sweep` and Mission 5 `Blackout` can slip to sprint 2.
- Sanctuary manifest terminal can fall back to a single `Play Next
  Mission` prompt.
- Skywatcher can ship with only the lateral drift attack; the dive attack
  is cleanup.

## Tests to add during the sprint

- `test_mission_dispatch.gd` — mission descriptor loader contract.
- `test_mission_skyline_smoke.gd` — mission 2 loads without crash from a
  clean session.
- `test_skywatcher.gd` — take_hit, weak-zone dispatch, death signal.
- Extend `test_juice_integration.gd` with a Skywatcher kill scenario to
  prove the feel chain works on the new enemy family too.

## Definition of done

Sprint 1 is done when:
1. Missions 2 and 3 both load end-to-end from sanctuary without crash.
2. Skywatcher ships with at least one attack and dies to both weapons.
3. All 0.2 tests remain green; at least three new tests added.
4. 0.3 PRD's sprint-1 line items are checked off in the parent spec.
5. One devlog draft exists for the eventual 0.3 tag post — not published,
   just written so 0.3 doesn't start from a blank page.

---

*Written 2026-04-18 alongside the 0.2 review-pass work. Supersede on
sprint-1 completion.*
