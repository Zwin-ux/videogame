extends Area2D

signal destroyed(points: int, hit_kind: String)
signal spawned_mite(mite: Area2D)

@export var max_health := 4
@export var spawn_interval := 1.8
@export var brood_limit := 2

var _health := 4
var _spawn_timer := 0.6
var _quiet_timer := 0.0
var _hurt_timer := 0.0
var _pulse_time := 0.0
var _last_hit_kind := "gun"
var _active_mites := 0
var _spawn_index := 0
var _spawn_scene: PackedScene
var _spawn_parent: Node
var _spawn_offsets: Array[Vector2] = [Vector2(-28.0, -8.0), Vector2(28.0, -8.0)]
var _spawn_config: Dictionary = {}
var _spawn_bloom_timer := 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("hazard")
	body_entered.connect(_on_body_entered)
	_health = max_health
	_update_collision_shape()
	queue_redraw()


func configure(config: Dictionary) -> void:
	global_position = config.get("pos", global_position)
	max_health = int(config.get("health", max_health))
	spawn_interval = float(config.get("interval", spawn_interval))
	brood_limit = int(config.get("brood_limit", brood_limit))
	_spawn_scene = config.get("spawn_scene", null)
	_spawn_parent = config.get("spawn_parent", null)
	var incoming_offsets: Array = config.get("spawn_offsets", _spawn_offsets)
	_spawn_offsets = []
	for offset in incoming_offsets:
		_spawn_offsets.append(offset)
	_spawn_config = config.get("mite_config", {})
	_health = max_health
	_spawn_timer = float(config.get("initial_spawn_delay", 0.8))
	_quiet_timer = 0.0
	_hurt_timer = 0.0
	_pulse_time = 0.0
	_active_mites = 0
	_spawn_index = 0
	_spawn_bloom_timer = 0.0
	_update_collision_shape()
	queue_redraw()


func take_hit(amount: int, _hit_position: Vector2, hit_kind: String = "gun") -> bool:
	_last_hit_kind = hit_kind
	_hurt_timer = 0.18
	if hit_kind == "gun" or hit_kind == "blast":
		_quiet_timer = maxf(_quiet_timer, 1.3)
	elif hit_kind == "blade":
		amount += 1
	_health -= amount
	queue_redraw()
	if _health <= 0:
		if hit_kind == "blade":
			_burst_brood()
		emit_signal("destroyed", 150, _last_hit_kind)
		queue_free()
		return true
	return false


func _process(delta: float) -> void:
	_pulse_time += delta
	if _quiet_timer > 0.0:
		_quiet_timer = maxf(_quiet_timer - delta, 0.0)
	if _hurt_timer > 0.0:
		_hurt_timer = maxf(_hurt_timer - delta, 0.0)
	if _spawn_timer > 0.0:
		_spawn_timer = maxf(_spawn_timer - delta, 0.0)
	if _spawn_bloom_timer > 0.0:
		_spawn_bloom_timer = maxf(_spawn_bloom_timer - delta, 0.0)

	if _spawn_timer <= 0.0 and _quiet_timer <= 0.0 and _active_mites < brood_limit:
		_spawn_mite()
		_spawn_timer = spawn_interval

	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if _hurt_timer > 0.0:
		return
	if body.has_method("take_damage"):
		body.call("take_damage", global_position)


func _spawn_mite() -> void:
	if _spawn_scene == null or _spawn_parent == null or not is_instance_valid(_spawn_parent) or _spawn_offsets.is_empty():
		return

	var mite := _spawn_scene.instantiate() as Area2D
	if mite == null:
		return

	var offset := _spawn_offsets[_spawn_index % _spawn_offsets.size()]
	_spawn_index += 1
	_spawn_parent.add_child(mite)
	var config := _spawn_config.duplicate(true)
	config["kind"] = "mite"
	config["pos"] = global_position + offset
	mite.call("configure", config)
	mite.tree_exited.connect(Callable(self, "_on_mite_exited").bind(mite.get_instance_id()))
	_active_mites += 1
	_spawn_bloom_timer = 0.26
	emit_signal("spawned_mite", mite)


func _on_mite_exited(_mite_id: int) -> void:
	_active_mites = maxi(0, _active_mites - 1)


func _update_collision_shape() -> void:
	if collision_shape == null:
		return
	var shape := CircleShape2D.new()
	shape.radius = 18.0
	collision_shape.shape = shape


func _draw() -> void:
	var pulse := 0.72 + sin(_pulse_time * 4.8) * 0.16
	var bloom := _spawn_bloom_timer * 4.0
	var quiet := _quiet_timer > 0.0
	var shell_color := Color(0.172549, 0.145098, 0.172549, 1.0)
	var pod_color := Color(0.431373, 0.192157, 0.156863, 1.0)
	var flesh_color := Color(0.780392, 0.713725, 0.572549, 1.0)
	var core_color := Color(0.952941, 0.643137, 0.341176, pulse if not quiet else 0.28)
	var quiet_color := Color(0.286275, 0.831373, 0.898039, 0.65)
	var petal_lift := sin(_pulse_time * 5.2) * 1.6 + bloom
	var side_swell := sin(_pulse_time * 4.1 + 0.6) * 1.2

	draw_circle(Vector2(0.0, 16.0), 14.0, Color(0.0, 0.0, 0.0, 0.16))
	draw_colored_polygon(
		PackedVector2Array(
			[
				Vector2(0.0, -24.0 - bloom * 0.6),
				Vector2(18.0 + bloom, -11.0 - petal_lift),
				Vector2(22.0 + bloom * 0.8, 7.0),
				Vector2(10.0, 21.0 + bloom * 0.2),
				Vector2(-10.0, 21.0 + bloom * 0.2),
				Vector2(-22.0 - bloom * 0.8, 7.0),
				Vector2(-18.0 - bloom, -11.0 - petal_lift),
			]
		),
		shell_color
	)
	draw_colored_polygon(
		PackedVector2Array(
			[
				Vector2(0.0, -17.0 - bloom * 0.4),
				Vector2(14.0 + bloom * 0.5, -8.0 - petal_lift * 0.5),
				Vector2(17.0 + bloom * 0.4, 5.0),
				Vector2(7.0, 16.0),
				Vector2(-7.0, 16.0),
				Vector2(-17.0 - bloom * 0.4, 5.0),
				Vector2(-14.0 - bloom * 0.5, -8.0 - petal_lift * 0.5),
			]
		),
		pod_color
	)
	draw_circle(Vector2(0.0, 1.0), 8.0, flesh_color)
	draw_circle(Vector2(0.0, 1.0), 4.0, core_color)
	draw_circle(Vector2(-8.0, 8.0 + side_swell), 3.0, pod_color.lightened(0.12))
	draw_circle(Vector2(8.0, 8.0 - side_swell), 3.0, pod_color.lightened(0.12))
	draw_line(Vector2(-10.0, -9.0), Vector2(-18.0 - bloom * 0.6, -16.0 - petal_lift), Color(0.952941, 0.694118, 0.356863, 0.85), 2.0)
	draw_line(Vector2(10.0, -9.0), Vector2(18.0 + bloom * 0.6, -16.0 - petal_lift), Color(0.952941, 0.694118, 0.356863, 0.85), 2.0)
	draw_line(Vector2(-6.0, 16.0), Vector2(-10.0, 22.0 + bloom), Color(0.952941, 0.694118, 0.356863, 0.78), 2.0)
	draw_line(Vector2(6.0, 16.0), Vector2(10.0, 22.0 + bloom), Color(0.952941, 0.694118, 0.356863, 0.78), 2.0)

	if quiet:
		draw_arc(Vector2.ZERO, 18.0, 0.0, TAU, 24, quiet_color, 2.0)
	if _spawn_bloom_timer > 0.0:
		draw_circle(Vector2.ZERO, 12.0 + bloom * 2.0, Color(0.984314, 0.898039, 0.627451, 0.08 + _spawn_bloom_timer * 0.22))
	if _hurt_timer > 0.0:
		draw_circle(Vector2(0.0, 1.0), 11.0, Color(0.984314, 0.898039, 0.627451, 0.16 + _hurt_timer * 0.6))


func _burst_brood() -> void:
	for node in get_tree().get_nodes_in_group("hazard"):
		if node == self or not is_instance_valid(node):
			continue
		if not node.has_method("take_hit"):
			continue
		if global_position.distance_to(node.global_position) > 86.0:
			continue
		if String(node.get("hazard_kind")) != "mite":
			continue
		node.call("take_hit", 2, global_position, "blade")
