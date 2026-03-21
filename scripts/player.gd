extends CharacterBody2D

signal shot_fired(origin: Vector2, direction: Vector2)
signal fuel_changed(current: float, maximum: float)
signal health_changed(current: int, maximum: int)
signal died

const RUN_SPEED := 270.0
const GROUND_ACCEL := 2100.0
const AIR_ACCEL := 1450.0
const GROUND_FRICTION := 1800.0
const JUMP_SPEED := -430.0
const GRAVITY_RISE := 1050.0
const GRAVITY_FALL := 1450.0
const COYOTE_TIME := 0.12
const JUMP_BUFFER := 0.16
const FIRE_INTERVAL := 0.16
const MAX_HEALTH := 3
const MAX_FUEL := 100.0
const GROUND_FUEL_RECHARGE := 34.0
const JETPACK_BURN := 38.0
const JETPACK_ACCEL := 1500.0
const JETPACK_MAX_RISE := 250.0
const JETPACK_STRAFE_ACCEL := 1750.0

var health := MAX_HEALTH
var fuel := MAX_FUEL
var facing := 1
var _controls_enabled := true
var _jump_buffer_timer := 0.0
var _coyote_timer := 0.0
var _fire_cooldown := 0.0
var _invulnerability_timer := 0.0
var _jetpack_active := false


func _ready() -> void:
	add_to_group("player")
	emit_signal("health_changed", health, MAX_HEALTH)
	emit_signal("fuel_changed", fuel, MAX_FUEL)


func reset_to(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	health = MAX_HEALTH
	fuel = MAX_FUEL
	facing = 1
	_controls_enabled = true
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	_fire_cooldown = 0.0
	_invulnerability_timer = 0.0
	_jetpack_active = false
	emit_signal("health_changed", health, MAX_HEALTH)
	emit_signal("fuel_changed", fuel, MAX_FUEL)
	queue_redraw()


func set_controls_enabled(value: bool) -> void:
	_controls_enabled = value


func apply_refill(amount: float) -> void:
	var previous_fuel := fuel
	fuel = minf(MAX_FUEL, fuel + amount)
	if absf(previous_fuel - fuel) > 0.01:
		emit_signal("fuel_changed", fuel, MAX_FUEL)


func take_damage(source_position: Vector2) -> void:
	if _invulnerability_timer > 0.0 or not _controls_enabled:
		return

	health -= 1
	_invulnerability_timer = 0.9
	velocity = Vector2(signf(global_position.x - source_position.x) * 240.0, -280.0)
	emit_signal("health_changed", health, MAX_HEALTH)
	queue_redraw()

	if health <= 0:
		_controls_enabled = false
		emit_signal("died")


func _physics_process(delta: float) -> void:
	var previous_fuel := fuel

	if _fire_cooldown > 0.0:
		_fire_cooldown = maxf(_fire_cooldown - delta, 0.0)
	if _invulnerability_timer > 0.0:
		_invulnerability_timer = maxf(_invulnerability_timer - delta, 0.0)
	if _jump_buffer_timer > 0.0:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)

	var move_input := 0.0
	if _controls_enabled:
		move_input = Input.get_axis("move_left", "move_right")
		if Input.is_action_just_pressed("jump"):
			_jump_buffer_timer = JUMP_BUFFER
		if Input.is_action_pressed("shoot") and _fire_cooldown <= 0.0:
			_fire_cooldown = FIRE_INTERVAL
			velocity.x -= float(facing) * 24.0
			emit_signal("shot_fired", _get_muzzle_position(), Vector2(float(facing), 0.0))

	if move_input != 0.0:
		facing = int(signf(move_input))

	if is_on_floor():
		_coyote_timer = COYOTE_TIME
		fuel = move_toward(fuel, MAX_FUEL, GROUND_FUEL_RECHARGE * delta)
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	if _controls_enabled and _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = JUMP_SPEED
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0

	var target_speed := move_input * RUN_SPEED
	var acceleration := GROUND_ACCEL if is_on_floor() else AIR_ACCEL
	velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
	if move_input == 0.0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, GROUND_FRICTION * delta)

	var gravity_strength := GRAVITY_RISE if velocity.y < 0.0 else GRAVITY_FALL
	velocity.y += gravity_strength * delta

	_jetpack_active = false
	if _controls_enabled and not is_on_floor() and Input.is_action_pressed("jetpack") and fuel > 0.0:
		_jetpack_active = true
		fuel = maxf(0.0, fuel - JETPACK_BURN * delta)
		velocity.y = maxf(velocity.y - JETPACK_ACCEL * delta, -JETPACK_MAX_RISE)
		if move_input != 0.0:
			velocity.x = move_toward(velocity.x, target_speed, JETPACK_STRAFE_ACCEL * delta)

	move_and_slide()

	if _controls_enabled and global_position.y > 860.0:
		_controls_enabled = false
		emit_signal("died")

	if absf(previous_fuel - fuel) > 0.01:
		emit_signal("fuel_changed", fuel, MAX_FUEL)

	queue_redraw()


func _get_muzzle_position() -> Vector2:
	return global_position + Vector2(18.0 * float(facing), -6.0)


func _draw() -> void:
	if _invulnerability_timer > 0.0 and int(Time.get_ticks_msec() / 70.0) % 2 == 0:
		return

	draw_circle(Vector2(0.0, 20.0), 12.0, Color(0.0, 0.0, 0.0, 0.18))
	draw_rect(Rect2(-12.0, -22.0, 24.0, 28.0), Color(0.819608, 0.733333, 0.580392, 1.0))
	draw_rect(Rect2(-14.0, -12.0, 6.0, 14.0), Color(0.290196, 0.372549, 0.45098, 1.0))
	draw_rect(Rect2(8.0, -12.0, 6.0, 14.0), Color(0.290196, 0.372549, 0.45098, 1.0))
	draw_rect(Rect2(-8.0, -16.0, 16.0, 8.0), Color(0.25098, 0.87451, 0.952941, 1.0))
	draw_rect(Rect2(-10.0, 6.0, 8.0, 10.0), Color(0.239216, 0.301961, 0.360784, 1.0))
	draw_rect(Rect2(2.0, 6.0, 8.0, 10.0), Color(0.239216, 0.301961, 0.360784, 1.0))

	var gun_x := 10.0 if facing > 0 else -24.0
	draw_rect(Rect2(gun_x, -10.0, 14.0, 5.0), Color(0.952941, 0.694118, 0.356863, 1.0))
	draw_rect(Rect2(gun_x + 10.0, -9.0, 6.0, 3.0), Color(0.94902, 0.862745, 0.611765, 1.0))

	if _jetpack_active:
		var left_flame := PackedVector2Array(
			[
				Vector2(-12.0, 4.0),
				Vector2(-6.0, 4.0),
				Vector2(-9.0, 22.0),
			]
		)
		var right_flame := PackedVector2Array(
			[
				Vector2(6.0, 4.0),
				Vector2(12.0, 4.0),
				Vector2(9.0, 24.0),
			]
		)
		draw_colored_polygon(left_flame, Color(0.94902, 0.65098, 0.258824, 1.0))
		draw_colored_polygon(right_flame, Color(0.94902, 0.65098, 0.258824, 1.0))
		draw_colored_polygon(
			PackedVector2Array([Vector2(-10.0, 6.0), Vector2(-8.0, 6.0), Vector2(-9.0, 14.0)]),
			Color(1.0, 0.894118, 0.478431, 1.0)
		)
		draw_colored_polygon(
			PackedVector2Array([Vector2(8.0, 6.0), Vector2(10.0, 6.0), Vector2(9.0, 16.0)]),
			Color(1.0, 0.894118, 0.478431, 1.0)
		)
