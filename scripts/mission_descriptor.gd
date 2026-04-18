extends RefCounted
## MissionDescriptor — 0.3 Skyline Shift sprint-1 Day 1
##
## Tiny, data-only descriptor for runnable missions. `_reset_run()` in main.gd
## reads this to decide starting region, spawn point, and opening copy so a
## second mission can ship without forking the whole run flow.
##
## Intentionally minimal. More fields (enemy remix, timer contract, remix
## rules) get added as sprint-1 days 3-5 demand them. Day 1 only needs to
## prove the dispatch lifts cleanly.
##
## Usage from main.gd:
##     var desc := MissionDescriptor.get("skyline_shift")
##     _current_mission_key = desc.key
##     _active_region_id = desc.starting_region
##     spawn_point = desc.spawn_point(default_spawn)

const KEY_DOCK_BREACH := "dock_breach"
const KEY_SKYLINE_SHIFT := "skyline_shift"
const KEY_ROOFTOP_RUSH := "rooftop_rush"

const REGION_HIVE := "hive_shaft"
const REGION_SKYLINE := "sunset_ruin_skyline"

## Backdrop mode enum mirrored from main.gd so the registry reads cleanly.
## Keep these two in sync with `main.gd` BACKDROP_* constants.
const BACKDROP_HIVE_SHAFT := 1
const BACKDROP_SUNSET_RUIN := 2

## Flow identifies the mission's structure: `full` runs Hive then Skyline
## then the region boss; `skyline_only` skips the Hive half and starts the
## player directly at the mountain slice. Add new flows here — do not
## duplicate the branch in main.gd.
const FLOW_FULL := "full"
const FLOW_SKYLINE_ONLY := "skyline_only"

## Static registry. Fields match the subset of main.gd behaviour we need to
## parametrise.
##   starting_region       — REGION_* string, drives geometry + anchors
##   backdrop_mode         — BACKDROP_* enum; main.gd reads it directly
##   spawn_override        — Vector2 or null; null means "use main.gd default"
##   opening_message       — null means "fall back to BountyFeed opener"
##   flow                  — run structure (see FLOW_* constants)
##   music_track           — MusicEngine.set_track() key on run start
##   target_time_seconds   — null for no timer; float for Rush remixes.
##                           HUD shows a countdown instead of altitude when set.
const MISSIONS := {
	KEY_DOCK_BREACH: {
		"key": KEY_DOCK_BREACH,
		"display_name": "Dock Breach",
		"starting_region": REGION_HIVE,
		"backdrop_mode": BACKDROP_HIVE_SHAFT,
		"spawn_override": null,
		"opening_message": null,     # keep BountyFeed weapon-aware opener
		"flow": FLOW_FULL,
		"music_track": "dock_breach",
		"target_time_seconds": null,
	},
	KEY_SKYLINE_SHIFT: {
		"key": KEY_SKYLINE_SHIFT,
		"display_name": "Skyline Shift",
		"starting_region": REGION_SKYLINE,
		"backdrop_mode": BACKDROP_SUNSET_RUIN,
		"spawn_override": Vector2(1002.0, 500.0),  # SKYLINE_ENTRY_POSITION
		"opening_message": "Lift crest confirmed. Skyline's own hunters don't care that the hive is dying.",
		"flow": FLOW_SKYLINE_ONLY,
		"music_track": "skyline",
		"target_time_seconds": null,
	},
	KEY_ROOFTOP_RUSH: {
		"key": KEY_ROOFTOP_RUSH,
		"display_name": "Rooftop Rush",
		"starting_region": REGION_SKYLINE,
		"backdrop_mode": BACKDROP_SUNSET_RUIN,
		"spawn_override": Vector2(1002.0, 500.0),
		"opening_message": "Rush mode. Clock's on, Matriarch's in. Cut the skyline inside the window.",
		"flow": FLOW_SKYLINE_ONLY,
		"music_track": "skyline",
		# 120s tight-timer remix of Skyline Shift. Same geometry, Rush pressure.
		"target_time_seconds": 120.0,
	},
}


## Lookup a descriptor by key. Returns empty Dictionary for unknown keys
## so call sites can defensively branch.
static func get_descriptor(key: String) -> Dictionary:
	return MISSIONS.get(key, {})


## Default mission. Callers without an explicit mission selection get this.
static func default_key() -> String:
	return KEY_DOCK_BREACH


## All runnable mission keys, in intended play order.
static func known_keys() -> PackedStringArray:
	var out := PackedStringArray()
	out.append(KEY_DOCK_BREACH)
	out.append(KEY_SKYLINE_SHIFT)
	out.append(KEY_ROOFTOP_RUSH)
	return out


## Convenience: missions with a Rush-style deadline return > 0; others 0.
static func target_time_for(key: String) -> float:
	var v: Variant = field(key, "target_time_seconds", null)
	if v is float:
		return float(v)
	return 0.0


## True iff the mission enforces a Rush-style time limit.
static func is_rush(key: String) -> bool:
	return target_time_for(key) > 0.0


## Resolve a descriptor and field, with fallback. Lets main.gd stay compact:
##     var region := MissionDescriptor.field(key, "starting_region", REGION_HIVE)
static func field(key: String, field_name: String, fallback: Variant = null) -> Variant:
	var desc: Dictionary = get_descriptor(key)
	if desc.is_empty():
		return fallback
	return desc.get(field_name, fallback)


## Returns true if the key refers to a known mission. Useful for guarded
## dispatch paths that want to silently no-op on bad input.
static func exists(key: String) -> bool:
	return MISSIONS.has(key)
