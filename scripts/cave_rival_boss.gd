extends Area2D

const ExportArt = preload("res://scripts/export_art.gd")
signal health_changed(current: int, maximum: int)
signal vulnerability_changed(active: bool, label: String)
signal telegraph_started(label: String)
signal defeated(drop_position: Vector2)

const WEAPON_GUN := "gun"
const WEAPON_BLADE := "blade"
const BULLET_SCENE := preload("res://scenes/rival_boss_bullet.tscn")
const BOSS_FRAME_SIZE := Vector2(48, 48)
const GRAVITY := 1320.0
const FLOOR_ACCEL := 1600.0
const AIR_ACCEL := 860.0

@export var max_health := 12
@export var arena_bounds := Rect2(1096.0, 90.0, 386.0, 178.0)
@export var floor_y := 238.0

var weapon_mode := WEAPON_GUN
var player: Node2D = null
var projectile_parent: Node = null
var boss_name := "BROOD WARDEN"
var guard_label := "BROOD ARMOR SEALED"
var broken_label := "APEX CORE BROKEN"
var burst_telegraph_label := "BROOD WARDEN: SPINE BURST"
var fan_telegraph_label := "BROOD WARDEN: SUNLANCE SPRAY"
var dash_telegraph_label := "BROOD WARDEN: CHITIN DASH"
var cleave_telegraph_label := "BROOD WARDEN: SKY MAUL"
var burst_vulnerable_label := "VENT CORE EXPOSED"
var fan_vulnerable_label := "SPINE SACK EXPOSED"
var dash_vulnerable_label := "MOTOR JOINT EXPOSED"
var cleave_vulnerable_label := "DRIVE CORE OVERLOAD"

var _health := 12
var _state := "intro"
var _state_timer := 0.0
var _anim_time := 0.0
var _velocity := Vector2.ZERO
var _facing := -1
var _vulnerable := false
var _attack_index := 0
var _flash_timer := 0.0
var _contact_disabled_timer := 0.0
var _burst_shots_left := 0
var _shot_timer := 0.0
var _dive_target_x := 0.0
var _defeated := false
var _weapon_flourish_timer := 0.0

@onready var visual: Sprite2D = $Visual
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("hazard")
	z_index = 10
	body_entered.connect(_on_body_entered)
	_update_collision_shape()
	_ensure_visual_texture()
	_update_visual()
	queue_redraw()


func configure(config: Dictionary) -> void:
	weapon_mode = String(config.get("weapon_mode", weapon_mode))
	player = config.get("player", player)
	projectile_parent = config.get("projectile_parent", projectile_parent)
	max_health = int(config.get("health", max_health))
	arena_bounds = config.get("arena_bounds", arena_bounds)
	floor_y = float(config.get("floor_y", floor_y))
	global_position = config.get("pos", global_position)
	boss_name = String(config.get("boss_name", boss_name))
	guard_label = String(config.get("guard_label", guard_label))
	broken_label = String(config.get("broken_label", broken_label))
	burst_telegraph_label = String(config.get("burst_telegraph_label", burst_telegraph_label))
	fan_telegraph_label = String(config.get("fan_telegraph_label", fan_telegraph_label))
	dash_telegraph_label = String(config.get("dash_telegraph_label", dash_telegraph_label))
	cleave_telegraph_label = String(config.get("cleave_telegraph_label", cleave_telegraph_label))
	burst_vulnerable_label = String(config.get("burst_vulnerable_label", burst_vulnerable_label))
	fan_vulnerable_label = String(config.get("fan_vulnerable_label", fan_vulnerable_label))
	dash_vulnerable_label = String(config.get("dash_vulnerable_label", dash_vulnerable_label))
	cleave_vulnerable_label = String(config.get("cleave_vulnerable_label", cleave_vulnerable_label))
	_reset_combat_state()


func take_hit(amount: int, hit_position: Vector2, hit_kind: String = "gun") -> bool:
	if _defeated:
		return false

	if not _vulnerable:
		_flash_timer = 0.08
		if hit_kind == "blade":
			_velocity.x += signf(global_position.x - hit_position.x) * 34.0
			_velocity.y = minf(_velocity.y, -46.0)
		queue_redraw()
		return false

	var damage := amount + (2 if hit_kind == "blade" else 0)
	_health = maxi(0, _health - damage)
	_flash_timer = 0.18
	_velocity.x += signf(global_position.x - hit_position.x) * (72.0 if hit_kind == "blade" else 34.0)
	_velocity.y = minf(_velocity.y, -110.0 if hit_kind == "blade" else -52.0)
	emit_signal("health_changed", _health, max_health)
	queue_redraw()

	if _health <= 0:
		_enter_defeated_state()
		return true

	return true


func _process(delta: float) -> void:
	_anim_time += delta
	_state_timer = maxf(_state_timer - delta, 0.0)
	_flash_timer = maxf(_flash_timer - delta, 0.0)
	_contact_disabled_timer = maxf(_contact_disabled_timer - delta, 0.0)

	match _state:
		"standoff":
			_update_standoff(delta)
		"weapon_flourish":
			_update_weapon_flourish(delta)
		"intro":
			_update_intro(delta)
		"idle":
			_update_idle(delta)
		"gun_burst_telegraph":
			_update_gun_burst_telegraph(delta)
		"gun_burst_fire":
			_update_gun_burst_fire(delta)
		"gun_fan_telegraph":
			_update_gun_fan_telegraph(delta)
		"blade_dash_telegraph":
			_update_blade_dash_telegraph(delta)
		"blade_dash":
			_update_blade_dash(delta)
		"blade_cleave_telegraph":
			_update_blade_cleave_telegraph(delta)
		"blade_cleave_rise":
			_update_blade_cleave_rise(delta)
		"blade_cleave_dive":
			_update_blade_cleave_dive(delta)
		"vulnerable":
			_update_vulnerable(delta)
		"defeated":
			_update_defeated(delta)

	var landed := _apply_movement(delta)
	if _state == "blade_cleave_dive" and landed:
		_on_blade_cleave_landed()

	_update_visual()
	queue_redraw()


func _reset_combat_state() -> void:
	_health = max_health
	_state = "standoff"
	_state_timer = 0.0
	_velocity = Vector2.ZERO
	_attack_index = 0
	_burst_shots_left = 0
	_shot_timer = 0.0
	_dive_target_x = global_position.x
	_defeated = false
	_vulnerable = false
	_flash_timer = 0.0
	_contact_disabled_timer = 0.0
	_weapon_flourish_timer = 0.0
	_facing = -1 if _get_player_position().x < global_position.x else 1
	collision_layer = 4
	collision_mask = 1
	monitoring = true
	monitorable = true
	emit_signal("health_changed", _health, max_health)
	emit_signal("vulnerability_changed", false, _get_guard_label())
	_update_visual()


func play_weapon_flourish(duration: float = 0.55) -> void:
	if _defeated:
		return
	_state = "weapon_flourish"
	_state_timer = duration
	_weapon_flourish_timer = duration
	_velocity = Vector2.ZERO
	emit_signal("vulnerability_changed", false, _get_guard_label())


func begin_duel() -> void:
	if _defeated:
		return
	_state = "intro"
	_state_timer = 0.55
	_weapon_flourish_timer = 0.0


func _update_standoff(delta: float) -> void:
	_face_player()
	_velocity.x = move_toward(_velocity.x, 0.0, FLOOR_ACCEL * delta)


func _update_weapon_flourish(delta: float) -> void:
	_face_player()
	_velocity.x = move_toward(_velocity.x, 0.0, FLOOR_ACCEL * delta)
	if _state_timer <= 0.0:
		_state = "standoff"
		_weapon_flourish_timer = 0.0


func _update_intro(delta: float) -> void:
	_face_player()
	_move_toward_x(_get_center_x(), delta, 140.0)
	if _state_timer <= 0.0:
		_begin_idle(0.45)


func _update_idle(delta: float) -> void:
	_face_player()
	_pace_for_pressure(delta)
	if _state_timer <= 0.0:
		_choose_next_attack()


func _update_gun_burst_telegraph(delta: float) -> void:
	_face_player()
	_hold_ranged_lane(delta)
	if _state_timer <= 0.0:
		_state = "gun_burst_fire"
		_burst_shots_left = 3
		_shot_timer = 0.05
		_velocity.x = 0.0


func _update_gun_burst_fire(delta: float) -> void:
	_face_player()
	_velocity.x = move_toward(_velocity.x, 0.0, FLOOR_ACCEL * delta)
	_shot_timer -= delta
	if _burst_shots_left > 0 and _shot_timer <= 0.0:
		_fire_gun_burst()
		_burst_shots_left -= 1
		_shot_timer = 0.22
	elif _burst_shots_left <= 0 and _shot_timer <= 0.0:
		_enter_vulnerable(1.0, burst_vulnerable_label)


func _update_gun_fan_telegraph(delta: float) -> void:
	_face_player()
	_move_toward_x(clampf(_get_player_position().x, arena_bounds.position.x + 64.0, arena_bounds.end.x - 64.0), delta, 90.0)
	if _state_timer <= 0.0:
		_fire_gun_fan()
		_enter_vulnerable(1.15, fan_vulnerable_label)


func _update_blade_dash_telegraph(delta: float) -> void:
	_face_player()
	_move_toward_x(_get_opposite_edge_x(), delta, 130.0)
	if _state_timer <= 0.0:
		_state = "blade_dash"
		_state_timer = 0.34
		_velocity.x = float(_facing) * 428.0
		_velocity.y = 0.0


func _update_blade_dash(delta: float) -> void:
	if _state_timer <= 0.0 or global_position.x <= arena_bounds.position.x + 10.0 or global_position.x >= arena_bounds.end.x - 10.0:
		_velocity.x = 0.0
		_enter_vulnerable(0.95, dash_vulnerable_label)
		return
	_velocity.x = move_toward(_velocity.x, float(_facing) * 428.0, AIR_ACCEL * delta)


func _update_blade_cleave_telegraph(delta: float) -> void:
	_face_player()
	_move_toward_x(_get_center_x(), delta, 120.0)
	if _state_timer <= 0.0:
		_state = "blade_cleave_rise"
		_state_timer = 0.95
		_velocity.x = float(_facing) * 110.0
		_velocity.y = -438.0
		_dive_target_x = clampf(_get_player_position().x, arena_bounds.position.x + 40.0, arena_bounds.end.x - 40.0)


func _update_blade_cleave_rise(_delta: float) -> void:
	if _state_timer <= 0.0 or _velocity.y >= -24.0 or global_position.y <= arena_bounds.position.y + 18.0:
		_state = "blade_cleave_dive"
		var dive_dir := signf(_dive_target_x - global_position.x)
		if is_zero_approx(dive_dir):
			dive_dir = float(_facing)
		_velocity.x = dive_dir * 176.0
		_velocity.y = 560.0


func _update_blade_cleave_dive(_delta: float) -> void:
	_facing = 1 if _velocity.x >= 0.0 else -1


func _update_vulnerable(delta: float) -> void:
	_face_player()
	_velocity.x = move_toward(_velocity.x, 0.0, FLOOR_ACCEL * delta * 0.8)
	if _state_timer <= 0.0:
		_begin_idle(0.42)


func _update_defeated(delta: float) -> void:
	_velocity.x = move_toward(_velocity.x, 0.0, FLOOR_ACCEL * delta)
	if _state_timer <= 0.0:
		queue_free()


func _choose_next_attack() -> void:
	var attack_slot := _attack_index % 2
	_attack_index += 1
	if weapon_mode == WEAPON_GUN:
		if attack_slot == 0:
			_state = "gun_burst_telegraph"
			_state_timer = 0.65
			emit_signal("telegraph_started", burst_telegraph_label)
		else:
			_state = "gun_fan_telegraph"
			_state_timer = 0.72
			_velocity.y = -236.0
			emit_signal("telegraph_started", fan_telegraph_label)
	else:
		if attack_slot == 0:
			_state = "blade_dash_telegraph"
			_state_timer = 0.55
			emit_signal("telegraph_started", dash_telegraph_label)
		else:
			_state = "blade_cleave_telegraph"
			_state_timer = 0.62
			emit_signal("telegraph_started", cleave_telegraph_label)
	emit_signal("vulnerability_changed", false, _get_guard_label())


func _begin_idle(duration: float) -> void:
	_state = "idle"
	_state_timer = duration
	_vulnerable = false
	emit_signal("vulnerability_changed", false, _get_guard_label())


func _enter_vulnerable(duration: float, label: String) -> void:
	_state = "vulnerable"
	_state_timer = duration
	_vulnerable = true
	_velocity.x = 0.0
	emit_signal("vulnerability_changed", true, label)


func _enter_defeated_state() -> void:
	_state = "defeated"
	_state_timer = 0.8
	_defeated = true
	_vulnerable = false
	collision_layer = 0
	collision_mask = 0
	monitoring = false
	monitorable = false
	emit_signal("vulnerability_changed", false, broken_label)
	emit_signal("health_changed", 0, max_health)
	emit_signal("defeated", global_position)


func _on_blade_cleave_landed() -> void:
	_spawn_enemy_bullet(Vector2(-1.0, 0.0), {"profile": "wave", "speed": 248.0, "lifetime": 1.1, "damage": 1}, Vector2(-20.0, -4.0))
	_spawn_enemy_bullet(Vector2(1.0, 0.0), {"profile": "wave", "speed": 248.0, "lifetime": 1.1, "damage": 1}, Vector2(20.0, -4.0))
	_velocity = Vector2.ZERO
	_enter_vulnerable(1.15, cleave_vulnerable_label)


func _fire_gun_burst() -> void:
	var muzzle := global_position + Vector2(22.0 * float(_facing), -28.0)
	var to_player := (_get_player_position() + Vector2(0.0, -18.0) - muzzle).normalized()
	if to_player == Vector2.ZERO:
		to_player = Vector2(float(_facing), 0.0)
	var spread := 0.14 if _burst_shots_left % 2 == 0 else -0.14
	_spawn_enemy_bullet(to_player, {"profile": "gun", "speed": 500.0, "lifetime": 1.3, "damage": 1}, muzzle - global_position)
	_spawn_enemy_bullet(to_player.rotated(spread), {"profile": "gun", "speed": 472.0, "lifetime": 1.2, "damage": 1}, muzzle - global_position)


func _fire_gun_fan() -> void:
	var base_dir := (_get_player_position() - global_position).normalized()
	if base_dir == Vector2.ZERO:
		base_dir = Vector2(float(_facing), 0.0)
	var muzzle := Vector2(20.0 * float(_facing), -30.0)
	for angle in [-0.42, -0.18, 0.0, 0.18, 0.42]:
		_spawn_enemy_bullet(base_dir.rotated(angle), {"profile": "gun", "speed": 430.0, "lifetime": 1.25, "damage": 1}, muzzle)


func _spawn_enemy_bullet(direction: Vector2, config: Dictionary, local_offset: Vector2) -> void:
	var parent_node := projectile_parent if projectile_parent != null else get_parent()
	if parent_node == null:
		return
	var bullet := BULLET_SCENE.instantiate()
	parent_node.add_child(bullet)
	bullet.call("setup", global_position + local_offset, direction, config)


func _apply_movement(delta: float) -> bool:
	var was_airborne := global_position.y < floor_y - 0.5
	var gravity_active := was_airborne or _state in ["gun_fan_telegraph", "blade_cleave_rise", "blade_cleave_dive", "defeated"]
	if gravity_active:
		_velocity.y += GRAVITY * delta
	else:
		_velocity.y = move_toward(_velocity.y, 0.0, GRAVITY * delta)

	global_position += _velocity * delta
	global_position.x = clampf(global_position.x, arena_bounds.position.x, arena_bounds.end.x)
	if is_equal_approx(global_position.x, arena_bounds.position.x) or is_equal_approx(global_position.x, arena_bounds.end.x):
		_velocity.x = 0.0

	var landed := false
	if global_position.y >= floor_y:
		if was_airborne and _velocity.y > 0.0:
			landed = true
		global_position.y = floor_y
		_velocity.y = 0.0

	return landed


func _pace_for_pressure(delta: float) -> void:
	if weapon_mode == WEAPON_GUN:
		_hold_ranged_lane(delta)
		return
	var player_pos := _get_player_position()
	var chase_x := clampf(player_pos.x - float(signf(player_pos.x - global_position.x)) * 86.0, arena_bounds.position.x + 36.0, arena_bounds.end.x - 36.0)
	_move_toward_x(chase_x, delta, 176.0)


func _hold_ranged_lane(delta: float) -> void:
	var target_x := _get_opposite_edge_x()
	_move_toward_x(target_x, delta, 188.0)


func _move_toward_x(target_x: float, delta: float, desired_speed: float) -> void:
	var direction := signf(target_x - global_position.x)
	if absf(target_x - global_position.x) < 6.0:
		direction = 0.0
	_velocity.x = move_toward(_velocity.x, direction * desired_speed, FLOOR_ACCEL * delta)


func _face_player() -> void:
	var player_x := _get_player_position().x
	if absf(player_x - global_position.x) < 4.0:
		return
	_facing = 1 if player_x > global_position.x else -1


func _get_player_position() -> Vector2:
	if player != null and is_instance_valid(player):
		return player.global_position
	return Vector2(_get_center_x(), floor_y)


func _get_center_x() -> float:
	return arena_bounds.position.x + arena_bounds.size.x * 0.5


func _get_opposite_edge_x() -> float:
	var player_x := _get_player_position().x
	if player_x > _get_center_x():
		return arena_bounds.position.x + 52.0
	return arena_bounds.end.x - 52.0


func _get_guard_label() -> String:
	return guard_label


func _on_body_entered(body: Node) -> void:
	if _defeated or _contact_disabled_timer > 0.0:
		return
	if body.has_method("take_damage"):
		body.call("take_damage", global_position)
		_contact_disabled_timer = 0.3


func _update_collision_shape() -> void:
	if collision_shape == null:
		return
	var shape := RectangleShape2D.new()
	shape.size = Vector2(28.0, 46.0)
	collision_shape.shape = shape
	collision_shape.position = Vector2.ZERO


func _ensure_visual_texture() -> void:
	if visual == null or visual.texture != null:
		return
	visual.texture = ExportArt.get_rival_boss_texture()
	visual.region_enabled = true
	visual.centered = true
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _update_visual() -> void:
	if visual == null or visual.texture == null:
		return
	var frame_index := _get_visual_frame_index()
	visual.region_rect = Rect2(frame_index * BOSS_FRAME_SIZE.x, 0, BOSS_FRAME_SIZE.x, BOSS_FRAME_SIZE.y)
	visual.flip_h = _facing < 0
	var idle_bob := 0.0
	if _state in ["idle", "standoff", "intro"]:
		idle_bob = sin(_anim_time * 5.2) * 1.2
	elif _state == "defeated":
		idle_bob = 4.0
	visual.position = Vector2(0.0, -5.0 + idle_bob)
	if _flash_timer > 0.0:
		visual.self_modulate = Color(1.0, 0.95, 0.88, 1.0)
	elif _vulnerable:
		visual.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		visual.self_modulate = Color(1.0, 1.0, 1.0, 0.98)


func _get_visual_frame_index() -> int:
	if _state == "defeated":
		return 9
	if _state == "weapon_flourish":
		return 8
	if weapon_mode == WEAPON_GUN:
		if _vulnerable:
			return 3
		if _state in ["gun_burst_fire", "gun_burst_telegraph", "gun_fan_telegraph"]:
			return 2
		return 0 if int(floor(_anim_time * 4.0)) % 2 == 0 else 1
	if _vulnerable:
		return 7
	if _state in ["blade_dash_telegraph", "blade_dash", "blade_cleave_telegraph", "blade_cleave_rise", "blade_cleave_dive"]:
		return 6
	return 4 if int(floor(_anim_time * 4.0)) % 2 == 0 else 5


func _draw() -> void:
	var flash_alpha := 0.18 + _flash_timer * 2.8
	var pulse := 0.72 + sin(_anim_time * 5.2) * 0.16
	var undersuit_color := Color(0.164706, 0.129412, 0.113725, 1.0)
	var armor_color := Color(0.827451, 0.792157, 0.721569, 1.0)
	var armor_shadow := Color(0.603922, 0.537255, 0.458824, 1.0)
	var trim_color := Color(0.913725, 0.478431, 0.223529, 1.0)
	var trim_bright := Color(0.980392, 0.701961, 0.352941, 1.0)
	var glow_color := Color(0.980392, 0.858824, 0.596078, 0.92)

	draw_circle(Vector2(0.0, 26.0), 18.0, Color(0.0, 0.0, 0.0, 0.18))

	if not _using_sheet_visual():
		var gait := sin(_anim_time * 7.2) * 1.8 if _state == "idle" else 0.0
		var left_foot_x := -8.0 + gait
		var right_foot_x := 8.0 - gait
		draw_rect(Rect2(left_foot_x - 5.0, 4.0, 10.0, 16.0), undersuit_color.darkened(0.35))
		draw_rect(Rect2(right_foot_x - 5.0, 4.0, 10.0, 16.0), undersuit_color.darkened(0.35))
		draw_rect(Rect2(-11.0, -18.0, 22.0, 26.0), armor_shadow)
		draw_rect(Rect2(-14.0, -12.0, 28.0, 18.0), armor_color)
		draw_rect(Rect2(-9.0, -34.0, 18.0, 14.0), armor_color.lightened(0.06))
		draw_rect(Rect2(-6.0, -30.0, 12.0, 5.0), Color(0.239216, 0.270588, 0.313725, 1.0))
		draw_rect(Rect2(-4.0, -29.0, 8.0, 3.0), glow_color)
		draw_rect(Rect2(-8.0, -6.0, 16.0, 6.0), trim_color)
		draw_rect(Rect2(-4.0, -2.0, 8.0, 4.0), trim_bright)
		draw_rect(Rect2(-14.0, -12.0, 5.0, 18.0), trim_color)
		draw_rect(Rect2(9.0, -12.0, 5.0, 18.0), trim_color.darkened(0.12))
		draw_rect(Rect2(-12.0, 4.0, 8.0, 6.0), trim_color)
		draw_rect(Rect2(4.0, 4.0, 8.0, 6.0), trim_color)
		draw_line(Vector2(-11.0, -10.0), Vector2(8.0, 5.0), trim_bright, 2.0)
		draw_rect(Rect2(-16.0, -18.0, 4.0, 12.0), trim_color)
		draw_rect(Rect2(12.0, -18.0, 4.0, 12.0), trim_color)
		draw_rect(Rect2(-16.0, -24.0, 32.0, 3.0), armor_shadow.darkened(0.15))

	if _vulnerable:
		draw_circle(Vector2(0.0, -6.0), 8.0, Color(0.913725, 0.478431, 0.223529, 0.26 + pulse * 0.2))
		draw_circle(Vector2(0.0, -6.0), 4.0, Color(0.984314, 0.898039, 0.627451, 0.72))

	if not _using_sheet_visual():
		_draw_weapon_overlay(trim_color, trim_bright, glow_color, pulse)

	if _state in ["weapon_flourish", "gun_burst_telegraph", "gun_fan_telegraph"]:
		draw_arc(Vector2(0.0, -10.0), 26.0, -1.2, 1.2, 18, Color(0.913725, 0.478431, 0.223529, 0.3 + pulse * 0.18), 3.0)
	if _state in ["weapon_flourish", "blade_dash_telegraph", "blade_dash", "blade_cleave_telegraph", "blade_cleave_dive"]:
		var slash_dir := float(_facing)
		draw_arc(Vector2(8.0 * slash_dir, -10.0), 28.0, -1.48 if _facing > 0 else PI - 0.4, 0.62 if _facing > 0 else PI + 1.4, 16, Color(0.980392, 0.701961, 0.352941, 0.22 + pulse * 0.2), 3.0)

	if _state == "defeated":
		draw_rect(Rect2(-16.0, -6.0, 32.0, 6.0), Color(0.913725, 0.478431, 0.223529, 0.16))

	if _flash_timer > 0.0:
		draw_circle(Vector2.ZERO, 22.0, Color(0.984314, 0.898039, 0.627451, flash_alpha))


func _using_sheet_visual() -> bool:
	return visual != null and visual.texture != null


func _draw_weapon_overlay(trim_color: Color, trim_bright: Color, glow_color: Color, pulse: float) -> void:
	var dir := float(_facing)
	if weapon_mode == WEAPON_GUN:
		var muzzle_origin := Vector2(10.0 * dir, -16.0)
		var muzzle_tip := muzzle_origin + Vector2(18.0 * dir, -2.0)
		draw_line(muzzle_origin, muzzle_tip, trim_color, 5.0)
		draw_line(muzzle_origin, muzzle_tip + Vector2(-3.0 * dir, 0.0), trim_bright, 2.0)
		draw_rect(Rect2(muzzle_origin + Vector2(-2.0 if dir > 0.0 else -4.0, -4.0), Vector2(6.0, 8.0)), Color(0.576471, 0.529412, 0.462745, 1.0))
		if _state == "gun_burst_fire" or _state == "gun_fan_telegraph":
			draw_line(muzzle_tip, muzzle_tip + Vector2(8.0 * dir, 0.0), Color(0.984314, 0.898039, 0.627451, 0.72 + pulse * 0.12), 3.0)
		draw_rect(Rect2(muzzle_origin + Vector2(-12.0 * dir, -3.0), Vector2(8.0, 4.0)), trim_color.darkened(0.08))
	else:
		var grip := Vector2(8.0 * dir, -14.0)
		var mid := grip + Vector2(8.0 * dir, -4.0)
		var tip := grip + Vector2(20.0 * dir, -8.0)
		draw_rect(Rect2(grip + Vector2(-2.0 if dir > 0.0 else -4.0, -3.0), Vector2(4.0, 6.0)), trim_color)
		draw_polyline(PackedVector2Array([grip, mid, tip]), Color(0.956863, 0.937255, 0.819608, 1.0), 5.0)
		draw_polyline(PackedVector2Array([grip + Vector2(0.0, 1.0), mid + Vector2(0.0, 1.0), tip + Vector2(0.0, 1.0)]), trim_bright, 2.0)
		draw_line(grip + Vector2(-4.0 * dir, 4.0), mid + Vector2(-2.0 * dir, 6.0), glow_color, 2.0)
		if _state == "blade_dash":
			draw_line(tip, tip + Vector2(12.0 * dir, 2.0), Color(0.913725, 0.478431, 0.223529, 0.58 + pulse * 0.14), 3.0)
