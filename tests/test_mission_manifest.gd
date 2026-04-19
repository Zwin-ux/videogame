extends RefCounted
## Tests for MissionManifest — 0.3 Sprint-1 Day 5.
## No actual ProfileStore needed — we stub it with a dict-backed mock that
## satisfies the `get_record` interface.

const MissionManifest := preload("res://scripts/mission_manifest.gd")
const MissionDescriptor := preload("res://scripts/mission_descriptor.gd")
const Ass := preload("res://tests/ass.gd")


## Minimal ProfileStore mock. Holds a dict of records, returns 0 for unknown.
class _MockProfile:
	var records: Dictionary = {}
	func get_record(key: String) -> int:
		return int(records.get(key, 0))


func run() -> Dictionary:
	var a: Ass = Ass.new("mission_manifest")

	# --- fresh profile: only Dock Breach is available --------------------
	var fresh: _MockProfile = _MockProfile.new()
	var slips_fresh: Array = MissionManifest.list(fresh)
	a.eq(int(slips_fresh.size()), 3, "manifest lists 3 missions on fresh profile")

	var by_key: Dictionary = {}
	for slip in slips_fresh:
		by_key[String((slip as Dictionary).get("key"))] = slip

	a.true_(bool((by_key[MissionDescriptor.KEY_DOCK_BREACH] as Dictionary).get("is_unlocked")), "dock_breach unlocked on fresh profile")
	a.false_(bool((by_key[MissionDescriptor.KEY_SKYLINE_SHIFT] as Dictionary).get("is_unlocked")), "skyline_shift locked on fresh profile")
	a.false_(bool((by_key[MissionDescriptor.KEY_ROOFTOP_RUSH] as Dictionary).get("is_unlocked")), "rooftop_rush locked on fresh profile")

	a.eq(String((by_key[MissionDescriptor.KEY_DOCK_BREACH] as Dictionary).get("stamp")), MissionManifest.STAMP_UNLOCKED, "dock_breach stamp = unlocked")
	a.eq(String((by_key[MissionDescriptor.KEY_SKYLINE_SHIFT] as Dictionary).get("stamp")), MissionManifest.STAMP_LOCKED, "skyline_shift stamp = locked")
	a.eq(String((by_key[MissionDescriptor.KEY_ROOFTOP_RUSH] as Dictionary).get("stamp")), MissionManifest.STAMP_LOCKED, "rooftop_rush stamp = locked")

	# Display names propagate from the descriptor.
	a.eq(String((by_key[MissionDescriptor.KEY_SKYLINE_SHIFT] as Dictionary).get("display_name")), "Skyline Shift", "display name propagates")
	a.eq(String((by_key[MissionDescriptor.KEY_ROOFTOP_RUSH] as Dictionary).get("display_name")), "Rooftop Rush", "display name propagates (Rush)")

	# --- post-hive clear: Skyline Shift unlocks --------------------------
	var post_hive: _MockProfile = _MockProfile.new()
	post_hive.records["hive_regions_cleansed"] = 1
	a.true_(MissionManifest.is_unlocked(MissionDescriptor.KEY_SKYLINE_SHIFT, post_hive), "skyline_shift unlocks after hive clear")
	a.false_(MissionManifest.is_unlocked(MissionDescriptor.KEY_ROOFTOP_RUSH, post_hive), "rooftop_rush still locked after hive clear")
	a.eq(MissionManifest.stamp_for(MissionDescriptor.KEY_DOCK_BREACH, post_hive), MissionManifest.STAMP_CLEARED, "dock_breach reads cleared after hive clear")

	# --- alpha flag also unlocks Skyline Shift --------------------------
	var alpha: _MockProfile = _MockProfile.new()
	alpha.records["alpha_demo_clears"] = 2
	a.true_(MissionManifest.is_unlocked(MissionDescriptor.KEY_SKYLINE_SHIFT, alpha), "alpha_demo_clears also unlocks skyline_shift")

	# --- post-skyline clear: Rooftop Rush unlocks ------------------------
	var post_sky: _MockProfile = _MockProfile.new()
	post_sky.records["hive_regions_cleansed"] = 1
	post_sky.records["skyline_regions_cleansed"] = 1
	a.true_(MissionManifest.is_unlocked(MissionDescriptor.KEY_ROOFTOP_RUSH, post_sky), "rooftop_rush unlocks after skyline clear")
	a.eq(MissionManifest.stamp_for(MissionDescriptor.KEY_SKYLINE_SHIFT, post_sky), MissionManifest.STAMP_CLEARED, "skyline_shift reads cleared after skyline clear")

	# Rush remix inherits Skyline's clear state (pending 0.4 save system).
	a.eq(MissionManifest.stamp_for(MissionDescriptor.KEY_ROOFTOP_RUSH, post_sky), MissionManifest.STAMP_CLEARED, "rooftop_rush inherits skyline clear state")

	# --- null profile path: dock_breach still unlocked -------------------
	a.true_(MissionManifest.is_unlocked(MissionDescriptor.KEY_DOCK_BREACH, null), "dock_breach unlocked with null profile")
	a.false_(MissionManifest.is_unlocked(MissionDescriptor.KEY_SKYLINE_SHIFT, null), "skyline_shift locked with null profile")

	# --- unknown mission path --------------------------------------------
	a.false_(MissionManifest.is_unlocked("bogus_mission", post_sky), "unknown mission never unlocks")
	a.eq(MissionManifest.stamp_for("bogus_mission", post_sky), MissionManifest.STAMP_LOCKED, "unknown mission stamps locked")

	# --- slip field shape ------------------------------------------------
	var one: Dictionary = slips_fresh[0]
	a.true_(one.has("key"), "slip has key")
	a.true_(one.has("display_name"), "slip has display_name")
	a.true_(one.has("starting_region"), "slip has starting_region")
	a.true_(one.has("flow"), "slip has flow")
	a.true_(one.has("is_unlocked"), "slip has is_unlocked")
	a.true_(one.has("is_cleared"), "slip has is_cleared")
	a.true_(one.has("stamp"), "slip has stamp")
	a.true_(one.has("target_time_seconds"), "slip has target_time_seconds")

	return a.report()
