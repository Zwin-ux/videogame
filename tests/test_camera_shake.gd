extends RefCounted

const CameraShakeScript := preload("res://scripts/camera_shake.gd")
const Ass := preload("res://tests/ass.gd")


func run() -> Dictionary:
	var a: Ass = Ass.new("camera_shake")
	var cs: Node = CameraShakeScript.new()
	cs._ready()

	# No kick active out of the box.
	a.false_(cs.is_active(), "no shake on init")
	a.eq(cs.current_amplitude(), 0.0, "amplitude 0 on init")

	# kick with no camera registered is safe.
	cs.kick(5.0, 0.1)
	a.true_(cs.is_active(), "kick activates without camera")
	cs.cancel() if cs.has_method("cancel") else null

	# Register a throwaway camera.
	var cam := Camera2D.new()
	cam.offset = Vector2(10.0, 20.0)
	cs.register_camera(cam)
	a.eq(cs._base_offset, Vector2(10.0, 20.0), "base offset captured")

	# kick sets amplitude and duration within clamps.
	cs.kick(7.0, 0.14)
	a.true_(cs.is_active(), "active after kick")
	a.near(cs._amp, 7.0, 0.001, "amplitude set")
	a.near(cs._dur, 0.14, 0.001, "duration set")

	# kick clamps extreme values.
	cs.kick(100.0, 10.0)
	a.lt(cs._amp, cs.MAX_AMPLITUDE + 0.001, "amplitude clamped")
	a.lt(cs._dur, cs.MAX_DURATION + 0.001, "duration clamped")

	# Zero-input kick ignored.
	var amp_before: float = float(cs._amp)
	cs.kick(0.0, 0.0)
	a.near(float(cs._amp), amp_before, 0.0001, "zero kick ignored")

	# Preset lookup.
	cs.kick(0.0, 0.0) # reset state
	cs._active = false
	cs.preset("huge")
	a.true_(cs.is_active(), "preset huge activates")
	a.near(cs._amp, 9.0, 0.001, "huge amplitude")

	# Reduce motion halves amplitude.
	cs._active = false
	cs.set_reduce_motion(true)
	cs.kick(8.0, 0.1)
	a.near(cs._amp, 4.0, 0.001, "reduce-motion halves amplitude")
	cs.set_reduce_motion(false)

	# Trauma decays toward zero as time progresses.
	cs._active = false
	cs.kick(6.0, 0.1)
	var amp_start: float = float(cs.current_amplitude())
	cs._elapsed = 0.05 # halfway
	var amp_half: float = float(cs.current_amplitude())
	a.lt(amp_half, amp_start, "amplitude decays with time")

	# Unregister restores offset.
	cs.unregister_camera(cam)
	a.eq(cam.offset, Vector2(10.0, 20.0), "unregister restores offset")
	a.false_(cs.is_active(), "shake cleared on unregister")

	cam.free()
	cs.free()
	return a.report()
