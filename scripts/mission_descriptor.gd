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

const REGION_HIVE := "hive_shaft"
const REGION_SKYLINE := "sunset_ruin_skyline"

## Static registry. Fields match the subset of main.gd behaviour we need to
## parametrise for Day 1.
const MISSIONS := {
	KEY_DOCK_BREACH: {
		"key": KEY_DOCK_BREACH,
		"display_name": "Dock Breach",
		"starting_region": REGION_HIVE,
		"backdrop_mode": 1,          # BACKDROP_HIVE_SHAFT
		"spawn_override": null,      # use main.gd default spawn
		"opening_message": "Sanctuary drop confirmed. Burn the Hive Shaft anchors and expose the Brood Warden.",
		"flow": "full",              # hive shaft -> transfer -> skyline -> boss
		"music_track": "dock_breach",
	},
	KEY_SKYLINE_SHIFT: {
		"key": KEY_SKYLINE_SHIFT,
		"display_name": "Skyline Shift",
		"starting_region": REGION_SKYLINE,
		"backdrop_mode": 2,          # BACKDROP_SUNSET_RUIN
		"spawn_override": Vector2(1002.0, 500.0),  # SKYLINE_ENTRY_POSITION
		"opening_message": "Lift crest confirmed. Skyline's own hunters don't care that the hive is dying.",
		"flow": "skyline_only",      # skip hive, start at mountain slice
		"music_track": "skyline",
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
	return out


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
