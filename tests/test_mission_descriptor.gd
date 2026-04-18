extends RefCounted
## MissionDescriptor tests — 0.3 Sprint-1 Day 1.
## Validates the descriptor registry the run-loader reads from.

const MissionDescriptor := preload("res://scripts/mission_descriptor.gd")
const Ass := preload("res://tests/ass.gd")


func run() -> Dictionary:
	var a: Ass = Ass.new("mission_descriptor")

	# Registry contains the two missions we committed to for sprint-1.
	var keys: PackedStringArray = MissionDescriptor.known_keys()
	a.true_(keys.has(MissionDescriptor.KEY_DOCK_BREACH), "registry has dock_breach")
	a.true_(keys.has(MissionDescriptor.KEY_SKYLINE_SHIFT), "registry has skyline_shift")

	# Default is Dock Breach.
	a.eq(MissionDescriptor.default_key(), MissionDescriptor.KEY_DOCK_BREACH, "default = dock_breach")

	# Descriptor lookup returns the expected fields.
	var dock: Dictionary = MissionDescriptor.get_descriptor(MissionDescriptor.KEY_DOCK_BREACH)
	a.false_(dock.is_empty(), "dock_breach descriptor non-empty")
	a.eq(dock.get("starting_region"), MissionDescriptor.REGION_HIVE, "dock_breach starts in Hive")
	a.eq(dock.get("flow"), "full", "dock_breach uses full flow")

	var sky: Dictionary = MissionDescriptor.get_descriptor(MissionDescriptor.KEY_SKYLINE_SHIFT)
	a.false_(sky.is_empty(), "skyline_shift descriptor non-empty")
	a.eq(sky.get("starting_region"), MissionDescriptor.REGION_SKYLINE, "skyline_shift starts in Skyline")
	a.eq(sky.get("flow"), "skyline_only", "skyline_shift skips Hive")
	a.true_(sky.get("spawn_override") is Vector2, "skyline_shift has spawn override")

	# Different missions, different descriptors.
	a.ne(dock.get("starting_region"), sky.get("starting_region"), "missions start in different regions")

	# Unknown mission yields empty dict, not a crash.
	var bogus: Dictionary = MissionDescriptor.get_descriptor("does_not_exist")
	a.true_(bogus.is_empty(), "unknown mission returns empty dict")
	a.false_(MissionDescriptor.exists("does_not_exist"), "exists() returns false for unknown")
	a.true_(MissionDescriptor.exists(MissionDescriptor.KEY_DOCK_BREACH), "exists() returns true for known")

	# field() helper returns fallback on miss.
	var fallback_region: Variant = MissionDescriptor.field("unknown", "starting_region", "REGION_FOUNDRY")
	a.eq(fallback_region, "REGION_FOUNDRY", "field() returns fallback on unknown mission")
	var real_region: Variant = MissionDescriptor.field(MissionDescriptor.KEY_SKYLINE_SHIFT, "starting_region", null)
	a.eq(real_region, MissionDescriptor.REGION_SKYLINE, "field() returns real value on known mission")

	# Both missions supply a music track so MusicEngine.set_track is safe.
	a.ne(String(dock.get("music_track", "")), "", "dock_breach has music_track")
	a.ne(String(sky.get("music_track", "")), "", "skyline_shift has music_track")
	a.ne(dock.get("music_track"), sky.get("music_track"), "missions use different tracks")

	# Flow enum is a known value (not a typo), and missions use different flows.
	a.eq(dock.get("flow"), MissionDescriptor.FLOW_FULL, "dock_breach flow = full")
	a.eq(sky.get("flow"), MissionDescriptor.FLOW_SKYLINE_ONLY, "skyline_shift flow = skyline_only")

	# Backdrop uses the constants, not magic ints.
	a.eq(dock.get("backdrop_mode"), MissionDescriptor.BACKDROP_HIVE_SHAFT, "dock_breach backdrop constant")
	a.eq(sky.get("backdrop_mode"), MissionDescriptor.BACKDROP_SUNSET_RUIN, "skyline_shift backdrop constant")

	# Opening copy: dock_breach is null (fall through to BountyFeed opener),
	# skyline_shift supplies its own line.
	a.is_null(dock.get("opening_message"), "dock_breach yields opener to BountyFeed")
	a.ne(sky.get("opening_message"), null, "skyline_shift supplies its own opener")
	a.ne(String(sky.get("opening_message", "")), "", "skyline_shift opener non-empty")

	# Rooftop Rush — Day 3. Same geometry as Skyline Shift, but with a
	# target_time_seconds contract that main.gd should use to swap the HUD
	# readout from altitude to countdown.
	a.true_(MissionDescriptor.exists(MissionDescriptor.KEY_ROOFTOP_RUSH), "rooftop_rush registered")
	var rush: Dictionary = MissionDescriptor.get_descriptor(MissionDescriptor.KEY_ROOFTOP_RUSH)
	a.eq(rush.get("starting_region"), MissionDescriptor.REGION_SKYLINE, "rooftop_rush starts in Skyline")
	a.eq(rush.get("flow"), MissionDescriptor.FLOW_SKYLINE_ONLY, "rooftop_rush flow = skyline_only")
	a.gt(float(rush.get("target_time_seconds", 0.0)), 0.0, "rooftop_rush has target time")
	a.true_(MissionDescriptor.is_rush(MissionDescriptor.KEY_ROOFTOP_RUSH), "is_rush returns true for Rush")
	a.false_(MissionDescriptor.is_rush(MissionDescriptor.KEY_SKYLINE_SHIFT), "is_rush false for Skyline Shift")
	a.false_(MissionDescriptor.is_rush(MissionDescriptor.KEY_DOCK_BREACH), "is_rush false for Dock Breach")
	a.near(MissionDescriptor.target_time_for(MissionDescriptor.KEY_ROOFTOP_RUSH), 120.0, 0.01, "Rooftop Rush target = 120s")
	a.eq(MissionDescriptor.target_time_for("unknown_key"), 0.0, "target_time_for unknown = 0")

	# Known keys now contain three missions; order stable.
	var keys_after: PackedStringArray = MissionDescriptor.known_keys()
	a.eq(int(keys_after.size()), 3, "three missions registered")

	return a.report()
