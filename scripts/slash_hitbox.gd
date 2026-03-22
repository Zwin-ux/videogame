extends Area2D

const HIT_POP_SCENE := preload("res://scenes/hit_pop.tscn")
const DEBUG_DRAW_FALLBACK := false

@export var lifetime := 0.1
@export var startup_delay := 0.0

var damage := 2
var facing := 1
var airborne := false
var source: Node = null
var _hit_targets := {}
var _initial_lifetime := 0.1
var _active := false
var _shape_size := Vector2.ZERO
var _shape_offset := Vector2.ZERO
var _hit_kind := "blade"
var _attack_variant := "neutral"

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	monitoring = false


func setup(start_position: Vector2, facing_dir: int, is_airborne: bool, config: Dictionary = {}) -> void:
	global_position = start_position
	facing = 1 if facing_dir >= 0 else -1
	airborne = is_airborne
	lifetime = float(config.get("lifetime", lifetime))
	startup_delay = float(config.get("startup_delay", startup_delay))
	_initial_lifetime = lifetime
	damage = int(config.get("damage", damage))
	source = config.get("source", null)
	_shape_size = config.get("shape_size", Vector2.ZERO)
	_shape_offset = config.get("shape_offset", Vector2.ZERO)
	_hit_kind = String(config.get("hit_kind", "blade"))
	_attack_variant = String(config.get("variant", "neutral"))
	scale = Vector2.ONE
	_active = startup_delay <= 0.0
	monitoring = _active
	_apply_profile()
	if _active:
		call_deferred("_flush_overlaps")


func _process(delta: float) -> void:
	if not _active:
		startup_delay -= delta
		if startup_delay <= 0.0:
			_activate()
	else:
		lifetime -= delta
		if lifetime <= 0.0:
			queue_free()
		elif DEBUG_DRAW_FALLBACK:
			queue_redraw()


func _on_area_entered(area: Area2D) -> void:
	if not _active:
		return
	_try_hit(area)


func _activate() -> void:
	_active = true
	monitoring = true
	call_deferred("_flush_overlaps")
	if DEBUG_DRAW_FALLBACK:
		queue_redraw()


func _flush_overlaps() -> void:
	for area in get_overlapping_areas():
		_try_hit(area)


func _try_hit(area: Area2D) -> void:
	if not area.has_method("take_hit"):
		return

	var key := area.get_instance_id()
	if _hit_targets.has(key):
		return

	_hit_targets[key] = true
	var destroyed := bool(area.call("take_hit", damage, global_position, _hit_kind))
	_spawn_hit_pop(area.global_position, destroyed)
	if source != null and is_instance_valid(source) and source.has_method("on_blade_hit"):
		source.call("on_blade_hit", destroyed, area.global_position, {"variant": _attack_variant})


func _apply_profile() -> void:
	var shape := collision_shape.shape as RectangleShape2D
	if shape == null:
		return

	if _shape_size != Vector2.ZERO:
		shape.size = _shape_size
	else:
		shape.size = Vector2(42.0, 24.0) if airborne else Vector2(38.0, 22.0)

	if _shape_offset != Vector2.ZERO:
		collision_shape.position = Vector2(_shape_offset.x * float(facing), _shape_offset.y)
	else:
		collision_shape.position = Vector2(18.0 * float(facing), -10.0 if airborne else -4.0)

	if DEBUG_DRAW_FALLBACK:
		queue_redraw()


func _draw() -> void:
	if not DEBUG_DRAW_FALLBACK:
		return
	var shape := collision_shape.shape as RectangleShape2D
	if shape == null:
		return
	var rect := Rect2(collision_shape.position - shape.size * 0.5, shape.size)
	draw_rect(rect, Color(0.956863, 0.74902, 0.392157, 0.12), true)
	draw_rect(rect, Color(0.521569, 0.92549, 0.968627, 0.75), false, 2.0)


func _spawn_hit_pop(position: Vector2, heavy: bool) -> void:
	var pop := HIT_POP_SCENE.instantiate()
	if pop == null:
		return
	get_parent().add_child(pop)
	pop.call("setup", position, heavy)
