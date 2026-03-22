extends Area2D

signal destroyed(points: int, hit_kind: String)

@export var patrol_distance := 120.0
@export var speed := 68.0
@export var max_health := 3
@export var contact_damage := 1
@export var shell_open_time := 0.52
@export var stun_time := 0.16

var _origin := Vector2.ZERO
var _direction := 1.0
var _health := 3
var _shell_open_timer := 0.0
var _stun_timer := 0.0
var _flash_timer := 0.0
var _last_hit_kind := "gun"
var _anim_time := 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("hazard")
	body_entered.connect(_on_body_entered)
	_origin = global_position
	_health = max_health
	_update_collision_shape()
	queue_redraw()


func configure(config: Dictionary) -> void:
	_origin = config.get("pos", global_position)
	global_position = _origin
	patrol_distance = float(config.get("patrol", patrol_distance))
	speed = float(config.get("speed", speed))
	max_health = int(config.get("health", max_health))
	contact_damage = int(config.get("contact_damage", contact_damage))
	shell_open_time = float(config.get("shell_open_time", shell_open_time))
	stun_time = float(config.get("stun_time", stun_time))
	_health = max_health
	_shell_open_timer = 0.0
	_stun_timer = 0.0
	_flash_timer = 0.0
	_direction = 1.0
	_anim_time = 0.0
	_update_collision_shape()
	queue_redraw()


func take_hit(amount: int, hit_position: Vector2, hit_kind: String = "gun") -> bool:
	_last_hit_kind = hit_kind
	var hit_from_front := (hit_position.x - global_position.x) * _direction >= 0.0
	var shell_open := _shell_open_timer > 0.0

	if hit_from_front and not shell_open:
		_flash_timer = 0.08 if hit_kind == "gun" or hit_kind == "blast" else 0.05
		if hit_kind == "gun" or hit_kind == "blast":
			_shell_open_timer = maxf(_shell_open_timer, shell_open_time)
			_stun_timer = maxf(_stun_timer, stun_time)
		queue_redraw()
		return false

	_flash_timer = 0.12 if hit_kind == "blade" else 0.08
	_health -= amount + (1 if hit_kind == "blade" else 0)
	if hit_kind == "blade":
		_shell_open_timer = maxf(_shell_open_timer, 0.18)

	if _health <= 0:
		emit_signal("destroyed", 140, _last_hit_kind)
		queue_free()
		return true

	queue_redraw()
	return true


func _process(delta: float) -> void:
	_anim_time += delta
	_flash_timer = maxf(_flash_timer - delta, 0.0)
	if _stun_timer > 0.0:
		_stun_timer = maxf(_stun_timer - delta, 0.0)
	if _shell_open_timer > 0.0:
		_shell_open_timer = maxf(_shell_open_timer - delta, 0.0)

	if _stun_timer <= 0.0:
		global_position.x += _direction * speed * delta
		if absf(global_position.x - _origin.x) >= patrol_distance:
			global_position.x = _origin.x + clampf(global_position.x - _origin.x, -patrol_distance, patrol_distance)
			_direction *= -1.0

	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if _stun_timer > 0.0 or _shell_open_timer > 0.0:
		return
	if body.has_method("take_damage"):
		body.call("take_damage", global_position)


func _update_collision_shape() -> void:
	if collision_shape == null:
		return

	var shape := RectangleShape2D.new()
	shape.size = Vector2(42.0, 30.0)
	collision_shape.shape = shape
	collision_shape.position = Vector2(0.0, -1.0)


func _draw() -> void:
	var shell_open := _shell_open_timer > 0.0
	var stunned := _stun_timer > 0.0
	var flash := _flash_timer > 0.0
	var moving := _stun_timer <= 0.0
	var gait_phase := sin(_anim_time * (9.0 if moving else 3.0))
	var body_bob := gait_phase * 0.9 if moving else 0.0
	var front := 1.0 if _direction > 0.0 else -1.0
	var eye_x := 9.0 * front
	var leg_a := gait_phase * 2.0
	var leg_b := -gait_phase * 2.0
	var shell_color := Color(0.141176, 0.184314, 0.235294, 1.0)
	var shell_trim := Color(0.286275, 0.831373, 0.898039, 1.0)
	var core_color := Color(0.780392, 0.713725, 0.572549, 1.0)
	var heat_color := Color(0.952941, 0.643137, 0.341176, 1.0)

	draw_circle(Vector2(0.0, 16.0), 14.0, Color(0.0, 0.0, 0.0, 0.16))
	draw_colored_polygon(
		PackedVector2Array(
			[
				Vector2(-12.0, 6.0 + body_bob),
				Vector2(-6.0, -4.0 + body_bob),
				Vector2(6.0, -8.0 + body_bob),
				Vector2(16.0, -4.0 + body_bob),
				Vector2(18.0, 6.0 + body_bob),
				Vector2(10.0, 12.0 + body_bob),
				Vector2(-6.0, 12.0 + body_bob),
			]
		),
		Color(0.113725, 0.160784, 0.203922, 1.0)
	)

	draw_line(Vector2(-12.0, 8.0 + body_bob), Vector2(-17.0, 14.0 + leg_a), Color(0.952941, 0.694118, 0.356863, 0.85), 2.0)
	draw_line(Vector2(-5.0, 11.0 + body_bob), Vector2(-9.0, 16.0 + leg_b), Color(0.952941, 0.694118, 0.356863, 0.85), 2.0)
	draw_line(Vector2(3.0, 11.0 + body_bob), Vector2(7.0, 16.0 + leg_a), Color(0.952941, 0.694118, 0.356863, 0.85), 2.0)
	draw_line(Vector2(10.0, 8.0 + body_bob), Vector2(16.0, 14.0 + leg_b), Color(0.952941, 0.694118, 0.356863, 0.85), 2.0)

	if shell_open:
		draw_colored_polygon(
			PackedVector2Array(
				[
					Vector2(-15.0, 3.0 + body_bob),
					Vector2(-6.0, -11.0 + body_bob),
					Vector2(8.0, -13.0 + body_bob),
					Vector2(17.0, -4.0 + body_bob),
					Vector2(11.0, 5.0 + body_bob),
					Vector2(-8.0, 5.0 + body_bob),
				]
			),
			shell_color
		)
		draw_polyline(
			PackedVector2Array(
				[
					Vector2(-15.0, 3.0 + body_bob),
					Vector2(-6.0, -11.0 + body_bob),
					Vector2(8.0, -13.0 + body_bob),
					Vector2(17.0, -4.0 + body_bob),
					Vector2(11.0, 5.0 + body_bob),
					Vector2(-8.0, 5.0 + body_bob),
					Vector2(-15.0, 3.0 + body_bob),
				]
			),
			shell_trim,
			2.0
		)
		draw_rect(Rect2(-8.0, 1.0 + body_bob, 16.0, 9.0), Color(0.192157, 0.282353, 0.352941, 1.0))
		draw_rect(Rect2(-6.0, 3.0 + body_bob, 12.0, 3.0), core_color)
		draw_rect(Rect2(-5.0, 7.0 + body_bob, 10.0, 2.0), heat_color)
		draw_circle(Vector2(eye_x * 0.4, 5.0 + body_bob), 3.0, Color(0.286275, 0.831373, 0.898039, 1.0))
		draw_line(Vector2(eye_x * 0.8, 8.0 + body_bob), Vector2(eye_x * 1.4, 11.0 + body_bob), Color(0.952941, 0.694118, 0.356863, 0.95), 2.0)
	else:
		draw_colored_polygon(
			PackedVector2Array(
				[
					Vector2(-18.0, 2.0 + body_bob),
					Vector2(-10.0, -8.0 + body_bob),
					Vector2(7.0, -12.0 + body_bob),
					Vector2(18.0, -4.0 + body_bob),
					Vector2(14.0, 8.0 + body_bob),
					Vector2(-10.0, 10.0 + body_bob),
				]
			),
			shell_color
		)
		draw_polyline(
			PackedVector2Array(
				[
					Vector2(-18.0, 2.0 + body_bob),
					Vector2(-10.0, -8.0 + body_bob),
					Vector2(7.0, -12.0 + body_bob),
					Vector2(18.0, -4.0 + body_bob),
					Vector2(14.0, 8.0 + body_bob),
					Vector2(-10.0, 10.0 + body_bob),
					Vector2(-18.0, 2.0 + body_bob),
				]
			),
			shell_trim.darkened(0.1),
			2.0
		)
		draw_rect(Rect2(-11.0, -1.0 + body_bob, 18.0, 4.0), core_color.darkened(0.15))
		draw_rect(Rect2(-8.0, -6.0 + body_bob, 10.0, 3.0), shell_trim)
		draw_rect(Rect2(-3.0, -10.0 + body_bob, 5.0, 2.0), shell_trim)
		draw_rect(Rect2(eye_x - 3.0, -3.0 + body_bob, 6.0, 2.0), Color(0.286275, 0.831373, 0.898039, 0.95))
		draw_line(Vector2(16.0 * front, 1.0 + body_bob), Vector2(21.0 * front, 0.0 + body_bob), Color(0.952941, 0.694118, 0.356863, 0.95), 2.0)
		draw_line(Vector2(16.0 * front, 4.0 + body_bob), Vector2(21.0 * front, 7.0 + body_bob), Color(0.952941, 0.694118, 0.356863, 0.95), 2.0)

	if stunned:
		draw_circle(Vector2(eye_x * 0.4, -1.0 + body_bob), 5.0, Color(0.952941, 0.694118, 0.356863, 0.24 + _stun_timer * 1.4))
		draw_circle(Vector2(eye_x * 0.4, -1.0 + body_bob), 2.5, Color(0.984314, 0.898039, 0.627451, 0.42 + _stun_timer))

	if flash:
		draw_line(Vector2(12.0, -5.0 + body_bob), Vector2(20.0, -8.0 + body_bob), Color(1.0, 0.898039, 0.627451, 0.85), 2.0)
		draw_line(Vector2(-12.0, -5.0 + body_bob), Vector2(-20.0, -8.0 + body_bob), Color(1.0, 0.898039, 0.627451, 0.85), 2.0)
