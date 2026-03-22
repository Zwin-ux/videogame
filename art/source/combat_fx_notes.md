# Combat FX Notes

Current exports:
- `art/export/combat_fx_sheet.png`
- `art/export/combat_fx_sheet.json`

Authoring source:
- `art/source/combat_fx_sheet.aseprite`

Bootstrap tools:
- `tools/generate_combat_fx_sheet.gd`
- `tools/import_sheet_to_aseprite.lua`

Required tags:
- `ground_slash(3)`
- `air_slash(3)`
- `hit_confirm(2)`

Runtime hookup:
- `scripts/main.gd` spawns `scenes/slash_fx.tscn` for authored slash visuals.
- `scripts/slash_hitbox.gd` now owns hit timing and collision only.
- `scripts/hit_pop.gd` reuses `hit_confirm` for kill and hit confirmation.
- Aseprite is now the live source of truth for slash FX export.
- Keep `tools/generate_combat_fx_sheet.gd` as bootstrap/reference art, not the shipping authority.

Art rules:
- Slash arcs should be clean lane shapes, not smeared anime noise.
- Warm outer edge, cool inner core.
- Contact frame should peak in contrast.
- The hit confirm should read in one glance even over bright backgrounds.

Debug fallback:
- `scripts/slash_hitbox.gd` still has a disabled debug draw path for collision verification.
- Keep it off in normal play.
