extends RefCounted
## Skywatcher tests — 0.3 Sprint-1 Day 4.
## Validates the new rooftop mercenary's hit contract, weak-zone doubling,
## patrol drift, and dive state machine.

const SkywatcherScript := preload("res://scripts/skywatcher.gd")
const Ass := preload("res://tests/ass.gd")


func run() -> Dictionary:
	var a: Ass = Ass.new("skywatcher")

	# --- hit contract ------------------------------------------------
	var sky: Area2D = SkywatcherScript.new()
	sky.global_position = Vector2(0.0, 0.0)
	sky.max_health = 3
	sky._health = 3

	# A front hit (above the cowl) deals the raw amount. Two 1-damage hits
	# leave the skywatcher alive; a third kills.
	var killed_front: bool = sky.take_hit(1, Vector2(0.0, -10.0), "gun")
	a.false_(killed_front, "front gun hit does not kill on turn 1")
	a.eq(int(sky._health), 2, "front hit deals 1 damage")

	killed_front = sky.take_hit(1, Vector2(0.0, -10.0), "gun")
	a.eq(int(sky._health), 1, "front hit deals 1 damage (again)")

	killed_front = sky.take_hit(1, Vector2(0.0, -10.0), "gun")
	a.true_(killed_front, "front gun hits 3 times = dead")

	# --- destroyed signal carries the right payload ------------------
	sky = SkywatcherScript.new()
	sky.global_position = Vector2(0.0, 0.0)
	sky.max_health = 1
	sky._health = 1
	sky.point_value = 180
	var signal_log: Array = []
	var recorder := SignalCapture.new(signal_log)
	sky.connect("destroyed", Callable(recorder, "_on_destroyed"))
	var _died: bool = sky.take_hit(5, Vector2(0.0, -10.0), "gun")
	a.eq(int(signal_log.size()), 1, "destroyed emits exactly once")
	if signal_log.size() >= 1:
		var payload: Dictionary = signal_log[0]
		a.eq(int(payload["points"]), 180, "destroyed carries point_value")
		a.eq(String(payload["hit_kind"]), "gun", "destroyed carries hit_kind")

	# --- weak-zone contract ------------------------------------------
	sky = SkywatcherScript.new()
	sky.global_position = Vector2(0.0, 0.0)
	sky.max_health = 4
	sky._health = 4

	# Gun weak-zone: 2x damage (bottom of the body).
	var hit_at_belly: Vector2 = Vector2(0.0, 12.0)
	a.true_(sky.is_weak_zone_for(hit_at_belly), "weak zone recognises belly hit")
	a.false_(sky.is_weak_zone_for(Vector2(0.0, -12.0)), "weak zone rejects top hit")

	sky.take_hit(1, hit_at_belly, "gun")
	a.eq(int(sky._health), 2, "gun weak-zone deals 2x damage")

	# Blade weak-zone: 3x damage — one cut cleans a 3-health target.
	sky = SkywatcherScript.new()
	sky.global_position = Vector2(0.0, 0.0)
	sky.max_health = 3
	sky._health = 3
	var killed_by_blade_cut: bool = sky.take_hit(1, Vector2(0.0, 12.0), "blade")
	a.true_(killed_by_blade_cut, "blade weak-zone cuts the cowl in one hit")

	# --- state machine / patrol --------------------------------------
	sky = SkywatcherScript.new()
	sky.global_position = Vector2(100.0, 100.0)
	sky.patrol_distance = 50.0
	sky.patrol_speed = 200.0
	sky.dive_cooldown = 999.0  # no dive for patrol test
	sky._origin = sky.global_position
	sky._direction = 1.0
	sky._health = sky.max_health
	a.eq(sky.get_state_name(), "hover", "boots in hover")

	# One small step drifts the body rightward.
	sky._update_hover(0.05)
	a.gt(float(sky.global_position.x), 100.0, "drifts right during hover")

	# Reset state, jump past the bound, assert direction flipped on that update.
	sky.global_position = Vector2(100.0 + sky.patrol_distance + 10.0, 100.0)
	sky._direction = 1.0
	sky._update_hover(0.01)
	a.lt(float(sky._direction), 0.0, "direction flips at patrol bound")
	a.near(float(sky.global_position.x), sky._origin.x + sky.patrol_distance, 0.5, "position clamped at bound")

	# --- dive gating -------------------------------------------------
	sky = SkywatcherScript.new()
	sky.global_position = Vector2(0.0, 0.0)
	sky.dive_cooldown = 0.01
	sky.dive_range = 400.0
	sky._origin = Vector2.ZERO
	sky._health = sky.max_health
	# No player bound — should NOT dive even when cooldown elapses.
	sky._update_hover(0.5)
	a.eq(sky.get_state_name(), "hover", "no dive without a player")

	# Bind a far-away player — also no dive (out of range).
	var player: Node2D = Node2D.new()
	player.global_position = Vector2(9999.0, 0.0)
	sky.bind_player(player)
	sky._state_timer = 99.0
	sky._update_hover(0.01)
	a.eq(sky.get_state_name(), "hover", "no dive when player out of range")

	# Close the distance — dive_telegraph should fire.
	player.global_position = Vector2(50.0, 40.0)
	sky._state_timer = 99.0
	sky._update_hover(0.01)
	a.eq(sky.get_state_name(), "dive_telegraph", "dive_telegraph fires when close + cooldown ready")

	# Dive telegraph → dive transition.
	sky._update_dive_telegraph(sky.dive_telegraph + 0.01)
	a.eq(sky.get_state_name(), "dive", "dive_telegraph transitions to dive")

	# Dive lands → recover state.
	sky._dive_target = sky.global_position + Vector2(10.0, 10.0)
	sky._update_dive(1.0)
	a.eq(sky.get_state_name(), "recover", "dive transitions to recover when target reached")

	# Recover → hover when near origin.
	sky._origin = sky.global_position
	sky._update_recover(0.5)
	a.eq(sky.get_state_name(), "hover", "recover returns to hover when home")

	player.free()
	return a.report()


## Tiny RefCounted sink so the `destroyed` signal can be captured without a
## connected Callable going out of scope between connect and emit.
class SignalCapture:
	var sink: Array
	func _init(into: Array) -> void:
		sink = into
	func _on_destroyed(points: int, hit_kind: String) -> void:
		sink.append({"points": points, "hit_kind": hit_kind})
