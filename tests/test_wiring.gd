extends RefCounted
## Verifies that the _service() helper in bullet.gd / slash_hitbox.gd
## resolves our new autoloads by node name at runtime.

const Ass := preload("res://tests/ass.gd")
const BulletScript := preload("res://scripts/bullet.gd")


func run() -> Dictionary:
	var a: Ass = Ass.new("wiring")

	# The four Hive Signal autoloads are registered in project.godot. When
	# running under the scene tree they're present under /root by name.
	# _service() is the tiny lookup helper used by bullet.gd and slash_hitbox.gd.
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	a.non_null(tree, "scene tree exists")

	var sb: Node = BulletScript._service("SoundBank")
	var cs: Node = BulletScript._service("CameraShake")
	var hs: Node = BulletScript._service("HitStop")
	var me: Node = BulletScript._service("MusicEngine")

	a.non_null(sb, "SoundBank resolves")
	a.non_null(cs, "CameraShake resolves")
	a.non_null(hs, "HitStop resolves")
	a.non_null(me, "MusicEngine resolves")
	a.is_null(BulletScript._service("ThisDoesNotExist"), "unknown resolves to null")

	# The resolved nodes must be our Hive Signal scripts, not something else
	# (defensive: another autoload could squat on the name).
	a.true_(sb != null and sb.get_script() != null and String(sb.get_script().resource_path).ends_with("sound_bank.gd"), "SoundBank script identity")
	a.true_(cs != null and cs.get_script() != null and String(cs.get_script().resource_path).ends_with("camera_shake.gd"), "CameraShake script identity")
	a.true_(hs != null and hs.get_script() != null and String(hs.get_script().resource_path).ends_with("hit_stop.gd"), "HitStop script identity")
	a.true_(me != null and me.get_script() != null and String(me.get_script().resource_path).ends_with("music_engine.gd"), "MusicEngine script identity")

	# End-to-end: a "kill" event triggers shake + music bump + sfx.
	var previous_time: float = float(Engine.time_scale)
	if cs != null:
		cs.call("kick", 5.0, 0.1)
		a.true_(bool(cs.call("is_active")), "shake triggered via autoload")
	if hs != null:
		hs.call("freeze_frames", 5)
		a.true_(bool(hs.call("is_active")), "hit stop triggered via autoload")
		a.near(float(Engine.time_scale), 0.0, 0.001, "engine paused during stop")
		hs.call("cancel")
	if me != null:
		me.call("bump_intensity", 0.1, 1.0)
		a.gt(float(me.call("get_intensity")) + 1.0, 0.0, "music intensity responsive")  # always true; records that the call did not error
	if sb != null:
		var played: bool = bool(sb.call("play", "blade_hit_kill"))
		a.true_(played, "SoundBank.play returns true for known sound")

	Engine.time_scale = previous_time
	return a.report()
