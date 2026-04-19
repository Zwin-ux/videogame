extends RefCounted

const HitStopScript := preload("res://scripts/hit_stop.gd")
const Ass := preload("res://tests/ass.gd")


func run() -> Dictionary:
	var a: Ass = Ass.new("hit_stop")
	var previous_scale := Engine.time_scale
	var hs: Node = HitStopScript.new()
	hs._ready()

	a.false_(hs.is_active(), "no freeze on init")

	# Default freeze sets time_scale to the freeze scale.
	hs.freeze()
	a.true_(hs.is_active(), "active after freeze")
	a.near(Engine.time_scale, 0.0, 0.001, "engine time scale = 0 during freeze")
	a.near(hs.time_remaining(), hs.DEFAULT_DURATION, 0.001, "default duration")

	# Simulate the timer expiring by backdating the wallclock start anchor.
	# HitStop now countdowns via Time.get_ticks_usec() so the test must touch
	# the anchor, not the elapsed field that _process overwrites.
	hs._freeze_start_usec = Time.get_ticks_usec() - int((hs._duration + 0.01) * 1_000_000)
	hs._process(0.0)
	a.false_(hs.is_active(), "inactive after timer expires")
	a.near(float(Engine.time_scale), float(previous_scale), 0.001, "time scale restored")

	# freeze_frames — 6 frames at 60Hz = 0.1s.
	hs.freeze_frames(6)
	a.near(hs._duration, 0.1, 0.001, "6 frames at 60Hz = 0.1s")
	a.near(Engine.time_scale, 0.0, 0.001, "engine paused for frames-mode")
	hs.cancel()
	a.near(Engine.time_scale, previous_scale, 0.001, "cancel restores scale")

	# freeze_custom preserves a partial scale.
	hs.freeze_custom(0.08, 0.25)
	a.near(Engine.time_scale, 0.25, 0.001, "custom scale applied")
	hs.cancel()

	# Stacking: a stronger freeze replaces.
	hs.freeze_custom(0.05, 0.0)
	var expiring: float = float(hs._duration)
	hs.freeze_custom(0.15, 0.0)
	a.gt(float(hs._duration), expiring, "stronger freeze replaces weaker")
	hs.cancel()

	# Clamp: over-max duration is clipped.
	hs.freeze(10.0)
	a.lt(hs._duration, hs.MAX_DURATION + 0.001, "over-max freeze clamped")
	hs.cancel()

	# Disabled mode drops freezes silently.
	hs.set_disabled(true)
	hs.freeze(0.1)
	a.false_(hs.is_active(), "disabled freezes ignored")
	hs.set_disabled(false)

	# Cleanup — ensure we never leave time_scale broken even if tests error mid-run.
	Engine.time_scale = previous_scale
	hs.free()
	return a.report()
