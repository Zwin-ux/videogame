extends RefCounted
## MissionManifest — 0.3 Sprint-1 Day 5 (data layer).
##
## Pure-data accessor for the sanctuary mission select. Iterates the
## MissionDescriptor registry and decorates each entry with an unlock state
## drawn from the ProfileStore cleanse records.
##
## The diegetic manifest-board UI (the "pinned slips on the corkboard" from
## the kickoff spec) is authored in the Godot editor on top of this data.
## This module owns the rules; the UI only renders what it receives.
##
## Usage from a sanctuary control:
##     var slips := MissionManifest.list(profile_store)
##     for slip in slips:
##         render_slip(slip.display_name, slip.stamp, slip.is_unlocked)

const MissionDescriptor := preload("res://scripts/mission_descriptor.gd")

const STAMP_UNLOCKED := "unlocked"   # draw in gold
const STAMP_LOCKED := "locked"       # draw in red
const STAMP_CLEARED := "cleared"     # draw in cyan (cleansed record)


## Build the manifest slip list. `profile_store` may be null in tests or
## headless; unknown records default to zero, so dock_breach stays unlocked.
static func list(profile_store: Object) -> Array:
	var slips: Array = []
	for key in MissionDescriptor.known_keys():
		slips.append(_build_slip(String(key), profile_store))
	return slips


## Convenience: true if the given mission is unlocked on this profile.
static func is_unlocked(mission_key: String, profile_store: Object) -> bool:
	var slip: Dictionary = _build_slip(mission_key, profile_store)
	return bool(slip.get("is_unlocked", false))


## Convenience: `unlocked` / `locked` / `cleared` for a single mission.
static func stamp_for(mission_key: String, profile_store: Object) -> String:
	var slip: Dictionary = _build_slip(mission_key, profile_store)
	return String(slip.get("stamp", STAMP_LOCKED))


# --- internal ---------------------------------------------------------------

static func _build_slip(mission_key: String, profile_store: Object) -> Dictionary:
	var descriptor: Dictionary = MissionDescriptor.get_descriptor(mission_key)
	var unlocked: bool = _is_mission_unlocked(mission_key, profile_store)
	var cleared: bool = _is_mission_cleared(mission_key, profile_store)
	var stamp: String = STAMP_LOCKED
	if cleared:
		stamp = STAMP_CLEARED
	elif unlocked:
		stamp = STAMP_UNLOCKED
	return {
		"key": mission_key,
		"display_name": String(descriptor.get("display_name", mission_key)),
		"starting_region": String(descriptor.get("starting_region", "")),
		"flow": String(descriptor.get("flow", "")),
		"target_time_seconds": descriptor.get("target_time_seconds", null),
		"is_unlocked": unlocked,
		"is_cleared": cleared,
		"stamp": stamp,
	}


static func _is_mission_unlocked(mission_key: String, profile_store: Object) -> bool:
	# Dock Breach is the training mission — always available on a fresh profile.
	if mission_key == MissionDescriptor.KEY_DOCK_BREACH:
		return true
	var hive_cleansed: bool = _record_gt(profile_store, "hive_regions_cleansed", 0)
	var skyline_cleansed: bool = _record_gt(profile_store, "skyline_regions_cleansed", 0)
	var alpha_clears: bool = _record_gt(profile_store, "alpha_demo_clears", 0)
	# Skyline Shift unlocks once the Hive or alpha flow has been cleared once.
	if mission_key == MissionDescriptor.KEY_SKYLINE_SHIFT:
		return hive_cleansed or alpha_clears
	# Rooftop Rush is the Rush remix of Skyline — must have cleared Skyline
	# at least once before it appears as a playable slip.
	if mission_key == MissionDescriptor.KEY_ROOFTOP_RUSH:
		return skyline_cleansed
	return false


static func _is_mission_cleared(mission_key: String, profile_store: Object) -> bool:
	# A mission is "cleared" if the region it clears has a cleanse record.
	# Rush remixes don't have their own cleanse record yet — that lands with
	# the 0.4 save system. For now they inherit Skyline's state.
	if mission_key == MissionDescriptor.KEY_DOCK_BREACH:
		return _record_gt(profile_store, "hive_regions_cleansed", 0)
	if mission_key == MissionDescriptor.KEY_SKYLINE_SHIFT:
		return _record_gt(profile_store, "skyline_regions_cleansed", 0)
	if mission_key == MissionDescriptor.KEY_ROOFTOP_RUSH:
		return _record_gt(profile_store, "skyline_regions_cleansed", 0)
	return false


static func _record_gt(profile_store: Object, record_key: String, threshold: int) -> bool:
	if profile_store == null:
		return false
	if not profile_store.has_method("get_record"):
		return false
	var value: int = int(profile_store.call("get_record", record_key))
	return value > threshold
