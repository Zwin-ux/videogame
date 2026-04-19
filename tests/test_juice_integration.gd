extends RefCounted
## End-to-end integration test for the juice pass.
##
## Drives a real blade kill and a real gun kill through slash_hitbox / bullet
## and the four autoloads, asserting the full feedback chain fired in the
## right shape. This is the "does the Hive Signal actually feel right" gate —
## unit tests validate the autoloads in isolation, this one validates they
## work together.

const Ass := preload("res://tests/ass.gd")

# A minimal target. Returns `destroyed` on the first hit so callers see the
# kill branch. Records hits for post-hoc inspection.
const _MockTarget := preload("res://tests/mock_target.gd")
const SlashHitboxScene := preload("res://scenes/slash_hitbox.tscn")
const BulletScene := preload("res://scenes/bullet.tscn")


func run() -> Dictionary:
	var a: Ass = Ass.new("juice_integration")
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	a.non_null(tree, "scene tree exists")

	var root: Node = tree.root
	var cs: Node = root.get_node_or_null("CameraShake")
	var hs: Node = root.get_node_or_null("HitStop")
	var sb: Node = root.get_node_or_null("SoundBank")
	var me: Node = root.get_node_or_null("MusicEngine")
	a.non_null(cs, "CameraShake autoload present")
	a.non_null(hs, "HitStop autoload present")
	a.non_null(sb, "SoundBank autoload present")
	a.non_null(me, "MusicEngine autoload present")

	# --- BLADE KILL PATH ------------------------------------------------
	_ensure_clean_state(cs, hs, me)

	var stage: Node2D = Node2D.new()
	stage.name = "IntegrationStage_Blade"
	root.add_child(stage)

	var cam: Camera2D = Camera2D.new()
	cam.offset = Vector2(12.0, 34.0)
	stage.add_child(cam)
	cs.call("register_camera", cam)

	var mock: Node = _MockTarget.new()
	mock.name = "BladeTarget"
	mock.add_to_group("hazard")
	mock.position = Vector2.ZERO
	stage.add_child(mock)

	var kicks: Array = []
	var recorder: _KickRecorder = _KickRecorder.new(kicks)
	# Hold a strong reference on the scene tree so the RefCounted doesn't
	# die between connect() and the signal firing.
	stage.set_meta("_kick_recorder", recorder)
	var kick_callable: Callable = Callable(recorder, "_on_kick")
	cs.connect("kicked", kick_callable)

	# Snapshot the SoundBank stream dictionary so we can detect new plays.
	var streams_before: Array = sb.call("known_sounds")
	var streams_dict_before: Dictionary = (sb._streams as Dictionary).duplicate()

	var slash: Area2D = SlashHitboxScene.instantiate() as Area2D
	slash.global_position = mock.global_position
	stage.add_child(slash)
	slash.call("setup", mock.global_position, 1, false, {
		"damage": 3,
		"hit_kind": "blade",
		"variant": "neutral",
		"source": null,
	})

	# Force the hit manually so we don't depend on physics frames inside tests.
	slash.call("_try_hit", mock)

	a.true_(bool(mock.last_hit_kind == "blade"), "mock received blade hit")
	a.true_(bool(mock.times_hit == 1), "mock hit exactly once")
	a.true_(bool(cs.call("is_active")), "camera shake fired on blade kill")
	a.true_(bool(hs.call("is_active")), "hit stop fired on blade kill")
	a.near(float(Engine.time_scale), 0.0, 0.001, "engine frozen during blade-kill stop")
	a.gt(float(kicks.size()), 0.0, "kicked signal emitted at least once")
	if kicks.size() > 0:
		var first: Dictionary = kicks[0]
		a.near(float(first["amplitude"]), 5.0, 0.01, "blade kill amplitude = 5 px")
		a.near(float(first["duration"]), 0.10, 0.01, "blade kill duration = 0.10 s")

	# SoundBank should have lazy-baked at least blade_hit_kill + enemy_death.
	var streams_after_blade: Dictionary = sb._streams as Dictionary
	a.true_(streams_after_blade.has("blade_hit_kill"), "blade_hit_kill stream cached")
	a.true_(streams_after_blade.has("enemy_death"), "enemy_death stream cached")

	# Cleanup blade stage.
	cs.disconnect("kicked", kick_callable)
	hs.call("cancel")
	cs.call("unregister_camera", cam)
	stage.queue_free()

	# --- GUN KILL PATH — must NOT trigger hit-stop ----------------------
	_ensure_clean_state(cs, hs, me)

	var stage2: Node2D = Node2D.new()
	stage2.name = "IntegrationStage_Gun"
	root.add_child(stage2)

	var cam2: Camera2D = Camera2D.new()
	stage2.add_child(cam2)
	cs.call("register_camera", cam2)

	var mock2: Node = _MockTarget.new()
	mock2.name = "GunTarget"
	mock2.add_to_group("hazard")
	stage2.add_child(mock2)

	var bullet: Area2D = BulletScene.instantiate() as Area2D
	stage2.add_child(bullet)
	bullet.call("setup", Vector2.ZERO, Vector2.RIGHT, {"damage": 2, "hit_kind": "gun"})
	bullet.call("_on_area_entered", mock2)

	a.true_(bool(mock2.last_hit_kind == "gun"), "mock received gun hit")
	a.true_(bool(cs.call("is_active")), "camera shake fired on gun kill")
	a.false_(bool(hs.call("is_active")), "hit stop did NOT fire on gun kill (doctrine)")
	a.near(float(Engine.time_scale), 1.0, 0.001, "engine not frozen after gun kill")

	# Cleanup gun stage.
	cs.call("unregister_camera", cam2)
	stage2.queue_free()

	return a.report()


func _ensure_clean_state(cs: Node, hs: Node, me: Node) -> void:
	if hs != null and bool(hs.call("is_active")):
		hs.call("cancel")
	Engine.time_scale = 1.0
	# Force the camera shake state back to clean.
	if cs != null:
		(cs as Object).set("_active", false)
		(cs as Object).set("_amp", 0.0)
	if me != null:
		me.call("set_intensity", 0.0)


# Tiny helper class — inline Object that records `kicked` signal payloads.
class _KickRecorder:
	var _sink: Array
	func _init(sink: Array) -> void:
		_sink = sink
	func _on_kick(amplitude: float, duration: float) -> void:
		_sink.append({"amplitude": amplitude, "duration": duration})
