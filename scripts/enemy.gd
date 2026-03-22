extends Area2D

const ExportArt = preload("res://scripts/export_art.gd")
signal destroyed(points: int, hit_kind: String)

const SHEET_FRAME_SIZE := Vector2(32, 32)
const DRONE_ROW := 0
const MITE_ROW := 1
const DRONE_ANIM_SEQUENCE := [0, 1, 2, 3, 1, 2, 4, 2]
const MITE_ANIM_SEQUENCE := [0, 1, 2, 3, 4, 3, 2, 1]

@export var travel_distance := 80.0
@export var speed := 70.0
@export var hover_amount := 10.0
@export var max_health := 2

var hazard_kind := "mite"

var _origin := Vector2.ZERO
var _direction := 1.0
var _health := 2
var _phase := 0.0
var _hurt_pose_timer := 0.0
var _anim_time := 0.0
var _stagger_timer := 0.0
var _stagger_velocity := Vector2.ZERO
var _last_hit_kind := "gun"
var _contact_radius := 16.0
var _point_value := 120

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Sprite2D = $Visual


func _ready() -> void:
	add_to_group("hazard")
	_phase = randf() * TAU
	body_entered.connect(_on_body_entered)
	_ensure_visual_texture()
	_reset_from_config()


func configure(config: Dictionary) -> void:
	hazard_kind = String(config.get("kind", "mite"))
	global_position = config.get("pos", Vector2.ZERO)
	_origin = global_position
	match hazard_kind:
		"drone":
			travel_distance = float(config.get("travel", 72.0))
			speed = float(config.get("speed", 76.0))
			hover_amount = float(config.get("hover", 10.0))
			max_health = int(config.get("health", 2))
			_contact_radius = float(config.get("radius", 16.0))
			_point_value = int(config.get("points", 120))
		"mite":
			travel_distance = float(config.get("travel", 54.0))
			speed = float(config.get("speed", 114.0))
			hover_amount = float(config.get("hover", 7.0))
			max_health = int(config.get("health", 1))
			_contact_radius = float(config.get("radius", 12.0))
			_point_value = int(config.get("points", 80))
		_:
			travel_distance = float(config.get("travel", 64.0))
			speed = float(config.get("speed", 84.0))
			hover_amount = float(config.get("hover", 8.0))
			max_health = int(config.get("health", 1))
			_contact_radius = float(config.get("radius", 14.0))
			_point_value = int(config.get("points", 90))
	_reset_from_config()


func take_hit(amount: int, hit_position: Vector2, hit_kind: String = "gun") -> bool:
	_last_hit_kind = hit_kind
	_health -= amount
	_hurt_pose_timer = 0.22
	if hit_kind == "blade":
		_stagger_timer = 0.28
		_stagger_velocity = Vector2(signf(global_position.x - hit_position.x) * 120.0, -52.0)
	elif hit_kind == "blast":
		_stagger_timer = 0.22
		_stagger_velocity = Vector2(signf(global_position.x - hit_position.x) * 154.0, -82.0)
	_update_visual()
	queue_redraw()
	if _health <= 0:
		emit_signal("destroyed", _point_value, _last_hit_kind)
		queue_free()
		return true
	return false


func _reset_from_config() -> void:
	_health = max_health
	_stagger_timer = 0.0
	_stagger_velocity = Vector2.ZERO
	_last_hit_kind = "gun"
	if collision_shape == null:
		return

	var shape := CircleShape2D.new()
	shape.radius = _contact_radius
	collision_shape.shape = shape
	if visual != null:
		visual.centered = true
	_update_visual()
	queue_redraw()


func _process(delta: float) -> void:
	_anim_time += delta
	if _hurt_pose_timer > 0.0:
		_hurt_pose_timer = maxf(_hurt_pose_timer - delta, 0.0)
	if _stagger_timer > 0.0:
		_stagger_timer = maxf(_stagger_timer - delta, 0.0)
		global_position += _stagger_velocity * delta
		_stagger_velocity = _stagger_velocity.move_toward(Vector2.ZERO, 520.0 * delta)
		_update_visual()
		queue_redraw()
		return

	global_position.x += _direction * speed * delta
	if absf(global_position.x - _origin.x) > travel_distance:
		_direction *= -1.0
		global_position.x = _origin.x + clampf(global_position.x - _origin.x, -travel_distance, travel_distance)

	var hover_speed := 4.8 if hazard_kind == "mite" else 3.2
	global_position.y = _origin.y + sin(_anim_time * hover_speed + _phase) * hover_amount
	_update_visual()
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if _hurt_pose_timer > 0.0 or _stagger_timer > 0.0:
		return
	if body.has_method("take_damage"):
		body.call("take_damage", global_position)


func _draw() -> void:
	if _using_sheet_visual():
		var shadow_radius := 11.0 if hazard_kind == "mite" else 15.0
		var glow_alpha := 0.08 + 0.04 * absf(sin((_anim_time + _phase) * (10.0 if hazard_kind == "mite" else 7.0)))
		draw_circle(Vector2(0.0, 14.0), shadow_radius, Color(0.0, 0.0, 0.0, 0.16))
		draw_circle(Vector2(0.0, 13.0), shadow_radius - 4.0, Color(0.286275, 0.831373, 0.898039, glow_alpha))
		if _stagger_timer > 0.0:
			draw_circle(Vector2(0.0, -1.0), 6.0, Color(0.952941, 0.694118, 0.356863, 0.18 + _stagger_timer * 2.0))
			draw_circle(Vector2(0.0, -1.0), 3.0, Color(0.984314, 0.898039, 0.627451, 0.4 + _stagger_timer * 1.6))
		elif _hurt_pose_timer > 0.0:
			draw_circle(Vector2(0.0, -1.0), 5.0, Color(0.984314, 0.898039, 0.627451, 0.08 + _hurt_pose_timer * 0.4))
		return

	if hazard_kind == "mite":
		_draw_mite()
	else:
		_draw_drone()


func _update_visual() -> void:
	if not _using_sheet_visual():
		return

	visual.flip_h = _direction < 0.0
	visual.region_rect = Rect2(
		_get_visual_frame() * SHEET_FRAME_SIZE.x,
		_get_visual_row() * SHEET_FRAME_SIZE.y,
		SHEET_FRAME_SIZE.x,
		SHEET_FRAME_SIZE.y
	)

	var bob_speed := 18.0 if hazard_kind == "mite" else 11.0
	var bob_amount := 0.9 if hazard_kind == "mite" else 0.6
	var bob := sin((_anim_time + _phase) * bob_speed) * bob_amount
	var base_scale := 0.9 if hazard_kind == "mite" else 1.0
	var x_scale := base_scale
	var y_scale := base_scale
	if _stagger_timer > 0.0:
		x_scale *= 1.06
		y_scale *= 0.94
	elif _hurt_pose_timer > 0.0:
		x_scale *= 0.92
		y_scale *= 1.08
	else:
		var squash := sin((_anim_time + _phase) * bob_speed) * 0.04
		x_scale *= 1.0 - squash
		y_scale *= 1.0 + squash

	var tilt := 0.0
	if _stagger_timer > 0.0:
		tilt = clampf(_stagger_velocity.x / 260.0, -0.46, 0.46)
	elif _hurt_pose_timer > 0.0:
		tilt = sin(_hurt_pose_timer * 38.0) * 0.12
	else:
		var base_tilt := 0.05 if hazard_kind == "mite" else 0.035
		tilt = (_direction * base_tilt) + sin((_anim_time + _phase) * (7.0 if hazard_kind == "mite" else 5.4)) * 0.025

	visual.position = Vector2(0.0, -1.0 + bob - (1.0 if _stagger_timer > 0.0 else 0.0))
	visual.scale = Vector2(x_scale, y_scale)
	visual.rotation = tilt
	if _stagger_timer > 0.0:
		visual.self_modulate = Color(1.0, 0.95, 0.84, 1.0)
	elif _hurt_pose_timer > 0.0:
		visual.self_modulate = Color(1.0, 0.86, 0.84, 1.0)
	else:
		visual.self_modulate = Color(1.0, 1.0, 1.0, 1.0)


func _get_visual_frame() -> int:
	if _stagger_timer > 0.0:
		return 6
	if _hurt_pose_timer > 0.0:
		return 5

	var sequence: Array = MITE_ANIM_SEQUENCE if hazard_kind == "mite" else DRONE_ANIM_SEQUENCE
	var cycle_speed := 18.0 if hazard_kind == "mite" else 12.0
	var cycle_index := int(floor((_anim_time + _phase) * cycle_speed)) % sequence.size()
	return int(sequence[cycle_index])


func _get_visual_row() -> int:
	return MITE_ROW if hazard_kind == "mite" else DRONE_ROW


func _using_sheet_visual() -> bool:
	return visual != null and visual.texture != null


func _ensure_visual_texture() -> void:
	if visual == null or visual.texture != null:
		return
	visual.texture = ExportArt.get_hazard_drone_texture()


func _draw_drone() -> void:
	var frame := _get_visual_frame()
	var wing_lift := -6.0
	var body_bob := -1.0
	var leg_shift := 0.0
	var charge := frame == 4
	var hurt := frame == 5
	var stagger := frame == 6

	match frame:
		1:
			wing_lift = -2.0
			body_bob = -2.0
			leg_shift = -1.0
		2:
			wing_lift = 2.0
			body_bob = 0.0
			leg_shift = 1.0
		3:
			wing_lift = 4.0
			body_bob = 1.0
		4:
			wing_lift = 0.0
			body_bob = -1.0
			leg_shift = -1.0
		5:
			wing_lift = 3.0
			body_bob = 1.0
			leg_shift = 1.0
		6:
			wing_lift = 2.0
			body_bob = 0.0
			leg_shift = -2.0

	draw_circle(Vector2(0.0, 14.0), 15.0, Color(0.0, 0.0, 0.0, 0.16))
	draw_colored_polygon(
		PackedVector2Array(
			[
				Vector2(-10.0, -3.0 + body_bob),
				Vector2(-20.0, -10.0 + wing_lift),
				Vector2(-6.0, -1.0 + body_bob),
			]
		),
		Color(0.423529, 0.505882, 0.560784, 0.3)
	)
	draw_colored_polygon(
		PackedVector2Array(
			[
				Vector2(-8.0, -5.0 + wing_lift),
				Vector2(2.0, -8.0 + wing_lift),
				Vector2(13.0, -6.0 + body_bob),
				Vector2(17.0, -4.0 + body_bob),
				Vector2(10.0, -1.0 + body_bob),
				Vector2(-4.0, -1.0 + body_bob),
			]
		),
		Color(0.956863, 0.945098, 0.870588, 1.0)
	)
	draw_colored_polygon(
		PackedVector2Array(
			[
				Vector2(-7.0, 7.0 + body_bob),
				Vector2(-1.0, 0.0 + body_bob),
				Vector2(9.0, 0.0 + body_bob),
				Vector2(12.0, 7.0 + body_bob),
				Vector2(6.0, 13.0 + body_bob),
				Vector2(-4.0, 13.0 + body_bob),
			]
		),
		Color(0.196078, 0.25098, 0.313725, 1.0)
	)
	draw_colored_polygon(
		PackedVector2Array(
			[
				Vector2(-13.0, 8.0 + body_bob),
				Vector2(-7.0, 4.0 + body_bob),
				Vector2(-2.0, 6.0 + body_bob),
				Vector2(-2.0, 12.0 + body_bob),
				Vector2(-7.0, 16.0 + body_bob),
				Vector2(-14.0, 13.0 + body_bob),
			]
		),
		Color(0.113725, 0.160784, 0.203922, 1.0)
	)
	draw_rect(Rect2(-4.0, 2.0 + body_bob, 9.0, 2.0), Color(0.286275, 0.831373, 0.898039, 0.95))
	draw_rect(Rect2(-12.0, 10.0 + body_bob, 6.0, 2.0), Color(0.952941, 0.643137, 0.341176, 0.95))
	draw_rect(Rect2(2.0, 3.0 + body_bob, 9.0, 7.0), Color(0.780392, 0.713725, 0.572549, 1.0))
	draw_rect(Rect2(4.0, 5.0 + body_bob, 4.0, 2.0), Color(0.286275, 0.831373, 0.898039, 1.0) if not charge else Color(0.952941, 0.694118, 0.356863, 1.0))
	draw_line(Vector2(-3.0, 13.0 + body_bob), Vector2(-1.0, 18.0 + body_bob + leg_shift), Color(0.952941, 0.694118, 0.356863, 0.9), 2.0)
	draw_line(Vector2(2.0, 13.0 + body_bob), Vector2(4.0, 18.0 + body_bob - leg_shift), Color(0.952941, 0.694118, 0.356863, 0.9), 2.0)
	draw_line(Vector2(7.0, 13.0 + body_bob), Vector2(9.0, 19.0 + body_bob + leg_shift), Color(0.952941, 0.694118, 0.356863, 0.9), 2.0)
	draw_line(Vector2(-14.0, 10.0 + body_bob), Vector2(-18.0, 10.0 + body_bob), Color(0.952941, 0.694118, 0.356863, 0.95), 2.0)

	if charge:
		draw_circle(Vector2(10.0, 6.0 + body_bob), 2.5, Color(0.984314, 0.898039, 0.627451, 0.75))
		draw_line(Vector2(12.0, 6.0 + body_bob), Vector2(16.0, 6.0 + body_bob), Color(0.984314, 0.898039, 0.627451, 0.95), 2.0)
	if hurt:
		draw_rect(Rect2(-2.0, 4.0 + body_bob, 5.0, 3.0), Color(0.968627, 0.45098, 0.34902, 0.95))
	if stagger:
		draw_circle(Vector2(0.0, 8.0 + body_bob), 3.0, Color(0.984314, 0.898039, 0.627451, 0.85))
		draw_line(Vector2(-7.0, 6.0 + body_bob), Vector2(-11.0, 2.0 + body_bob), Color(0.286275, 0.831373, 0.898039, 0.95), 2.0)


func _draw_mite() -> void:
	var frame := _get_visual_frame()
	var wing_lift := -3.0
	var body_bob := 0.0
	var leg_shift := 0.0
	var charge := frame == 4
	var hurt := frame == 5
	var stagger := frame == 6

	match frame:
		1:
			wing_lift = -1.0
			body_bob = -1.0
			leg_shift = -1.0
		2:
			wing_lift = 2.0
			leg_shift = 1.0
		3:
			wing_lift = 1.0
			body_bob = -2.0
		4:
			wing_lift = 0.0
			body_bob = -1.0
			leg_shift = -1.0
		5:
			wing_lift = 2.0
			body_bob = 1.0
		6:
			wing_lift = 1.0
			leg_shift = -2.0

	draw_circle(Vector2(0.0, 12.0), 11.0, Color(0.0, 0.0, 0.0, 0.14))
	draw_colored_polygon(
		PackedVector2Array([Vector2(-6.0, -1.0 + body_bob), Vector2(-13.0, -6.0 + wing_lift), Vector2(-4.0, 1.0 + body_bob)]),
		Color(0.423529, 0.505882, 0.560784, 0.26)
	)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-4.0, -4.0 + wing_lift), Vector2(3.0, -6.0 + wing_lift), Vector2(10.0, -3.0 + body_bob), Vector2(4.0, 0.0 + body_bob)]),
		Color(0.956863, 0.945098, 0.870588, 1.0)
	)
	draw_colored_polygon(
		PackedVector2Array(
			[
				Vector2(-3.0, 3.0 + body_bob),
				Vector2(2.0, -1.0 + body_bob),
				Vector2(8.0, 0.0 + body_bob),
				Vector2(10.0, 5.0 + body_bob),
				Vector2(5.0, 9.0 + body_bob),
				Vector2(-1.0, 9.0 + body_bob),
			]
		),
		Color(0.196078, 0.25098, 0.313725, 1.0)
	)
	draw_colored_polygon(
		PackedVector2Array(
			[
				Vector2(-8.0, 6.0 + body_bob),
				Vector2(-4.0, 4.0 + body_bob),
				Vector2(0.0, 5.0 + body_bob),
				Vector2(0.0, 10.0 + body_bob),
				Vector2(-4.0, 12.0 + body_bob),
				Vector2(-9.0, 10.0 + body_bob),
			]
		),
		Color(0.113725, 0.160784, 0.203922, 1.0)
	)
	draw_rect(Rect2(-2.0, 4.0 + body_bob, 6.0, 2.0), Color(0.286275, 0.831373, 0.898039, 0.95))
	draw_rect(Rect2(4.0, 2.0 + body_bob, 6.0, 5.0), Color(0.780392, 0.713725, 0.572549, 1.0))
	draw_rect(Rect2(5.0, 4.0 + body_bob, 3.0, 1.0), Color(0.286275, 0.831373, 0.898039, 1.0) if not charge else Color(0.952941, 0.694118, 0.356863, 1.0))
	draw_line(Vector2(-1.0, 9.0 + body_bob), Vector2(1.0, 14.0 + body_bob + leg_shift), Color(0.952941, 0.694118, 0.356863, 0.9), 1.5)
	draw_line(Vector2(3.0, 9.0 + body_bob), Vector2(5.0, 14.0 + body_bob - leg_shift), Color(0.952941, 0.694118, 0.356863, 0.9), 1.5)
	draw_line(Vector2(7.0, 9.0 + body_bob), Vector2(9.0, 15.0 + body_bob + leg_shift), Color(0.952941, 0.694118, 0.356863, 0.9), 1.5)
	draw_line(Vector2(-9.0, 7.0 + body_bob), Vector2(-12.0, 7.0 + body_bob), Color(0.952941, 0.694118, 0.356863, 0.95), 1.5)

	if charge:
		draw_circle(Vector2(10.0, 4.0 + body_bob), 2.0, Color(0.984314, 0.898039, 0.627451, 0.75))
	if hurt:
		draw_rect(Rect2(0.0, 4.0 + body_bob, 3.0, 2.0), Color(0.968627, 0.45098, 0.34902, 0.95))
	if stagger:
		draw_circle(Vector2(0.0, 6.0 + body_bob), 2.5, Color(0.984314, 0.898039, 0.627451, 0.85))
