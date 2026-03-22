# Player Sheet Notes

Current exported sheet:
- `art/export/player_sheet.png`
- `art/export/player_sheet.json`

Authoring source:
- `art/source/player_sheet.aseprite`

Bootstrap tools:
- `tools/generate_player_sheet.gd`
- `tools/import_sheet_to_aseprite.lua`
- `tools/export_aseprite.ps1`

Runtime contract:
- The player no longer relies on hard-coded frame indices.
- `scripts/player.gd` reads `art/export/player_sheet.json` and plays Aseprite-style frame tags.
- Aseprite is now the live source of truth. Export from `art/source/player_sheet.aseprite`.
- Keep `tools/generate_player_sheet.gd` as bootstrap/reference art, not the shipping authority.
- Replace or redraw frames freely as long as these tags remain present and ordered.

Required shipped tags:
- `idle(2)`
- `idle_blade(2)` optional but now used when present
- `run(4)`
- `jump_up(2)`
- `fall(2)`
- `land(2)`
- `wall_slide(2)`
- `wall_kick(2)`
- `burst_start(2)`
- `burst_loop(2)`
- `burst_end(2)`
- `gun_ground(3)`
- `gun_air(3)`
- `blade_ground(3)`
- `blade_air(3)`
- `hurt(2)`
- `hurt_blade(2)` optional but now used when present

Reserved for later melee expansion:
- `slash_string_2`
- `slash_string_3`
- `rising_slash`
- `dive_cleave`
- `dash_slash`

Weapon badges exported alongside the sheet:
- `art/export/weapon_icon_fang.png`
- `art/export/weapon_icon_blaster.png`

Current runtime hookup:
- `scenes/player.tscn` owns the `Sprite2D` visual node.
- `scripts/player.gd` selects regions through tag metadata and keeps gameplay logic separate from sheet layout.
- The controller still owns gameplay; the sprite sheet is the visual layer plus tag timing data.
- Blade and gun mode share the same body frames, then add a mode-specific runtime overlay for the weapon read.

Intent:
- This pass raises the body animation budget to support anticipation, contact, and recovery without changing movement tuning.
- Final Aseprite work should preserve the tag names, readable silhouette, canvas occupancy, and state separation established here.
- Use `art/source/PLAYER_ANIMATION_BIBLE.md` as the pose and timing brief before polishing pixels.
- `tools/export_aseprite.ps1` now also honors `ASEPRITE_PATH` for local installs that are not on system PATH.
