extends CharacterBody2D

const ExportArt = preload("res://scripts/export_art.gd")
const SpriteSheetLibrary = preload("res://scripts/sprite_sheet_library.gd")

signal shot_fired(origin: Vector2, shot_data: Dictionary)
signal slash_fired(origin: Vector2, attack_data: Dictionary)
signal fuel_changed(current: float, maximum: float)
signal health_changed(current: int, maximum: int)
signal damaged(current: int, maximum: int)
signal movement_event(kind: String)
signal weapon_mode_changed(mode: String)
signal died

const RUN_SPEED := 288.0
const GROUND_ACCEL := 2200.0
const AIR_ACCEL := 1520.0
const GROUND_FRICTION := 1800.0
const JUMP_SPEED := -440.0
const AIR_JUMP_SPEED := -306.0
const AIR_JUMP_X_SPEED := 186.0
const GRAVITY_RISE := 1080.0
const GRAVITY_FALL := 1500.0
const COYOTE_TIME := 0.12
const JUMP_BUFFER := 0.16
const BURST_BUFFER := 0.12
const GUN_FIRE_INTERVAL := 0.16
const BLADE_INTERVAL := 0.19
const MAX_HEALTH := 3
const MAX_FUEL := 100.0
const GROUND_FUEL_RECHARGE := 18.0
const GUN_SHELL_CAPACITY := 2
const GUN_GROUNDED_RELOAD_DELAY := 0.14
const GUN_RECOIL_CONTROL_WINDOW := 0.18
const WALL_SLIDE_SPEED := 124.0
const WALL_KICK_X := 324.0
const WALL_KICK_Y := -434.0
const WALL_CONTACT_GRACE := 0.16
const SPRING_CHAIN_WINDOW := 0.18
const BURST_COST := 20.0
const BURST_DURATION := 0.12
const BURST_COOLDOWN := 0.08
const BURST_ACCEL := 4200.0
const BURST_NEUTRAL_X := 206.0
const BURST_NEUTRAL_Y := -414.0
const BURST_CHAIN_X := 228.0
const BURST_CHAIN_Y := -446.0
const BURST_WALL_X := 266.0
const BURST_WALL_Y := -468.0
const BURST_FALL_SAVE_Y := -456.0
const BURST_FALL_SPEED_THRESHOLD := 310.0
const BLADE_GUARD_TIME := 0.12
const BLADE_HIT_REBOUND_X := 26.0
const BLADE_HIT_REBOUND_Y := -124.0
const BLADE_KILL_REBOUND_Y := -236.0
const FANG_FORWARD_CARRY_X := 86.0
const FANG_FORWARD_CARRY_Y := -52.0
const FANG_RISE_X := 56.0
const FANG_RISE_Y := -276.0
const FANG_DIVE_X := 64.0
const FANG_DIVE_Y := 286.0
const FANG_RISE_REBOUND_Y := -188.0
const FANG_DIVE_REBOUND_Y := -268.0
const WEAPON_GUN := "gun"
const WEAPON_BLADE := "blade"
const DEFAULT_SKIN_ID := SkinPalette.SKIN_HIVE_RUNNER

const DEFAULT_WEAPON_UPGRADES := {
	WEAPON_BLADE: 0,
	WEAPON_GUN: 0,
}

var health := MAX_HEALTH
var fuel := MAX_FUEL
var facing := 1

var _controls_enabled := true
var _jump_buffer_timer := 0.0
var _burst_buffer_timer := 0.0
var _coyote_timer := 0.0
var _fire_cooldown := 0.0
var _invulnerability_timer := 0.0
var _burst_timer := 0.0
var _burst_cooldown := 0.0
var _burst_target := Vector2.ZERO
var _wall_normal := Vector2.ZERO
var _wall_contact_normal := Vector2.ZERO
var _wall_contact_timer := 0.0
var _wall_slide_active := false
var _attack_pose_timer := 0.0
var _attack_pose_duration := 0.0
var _attack_tag_name := "blade_ground"
var _wall_kick_pose_timer := 0.0
var _wall_kick_pose_duration := 0.0
var _spring_chain_timer := 0.0
var _visual_anim_time := 0.0
var _air_jump_available := true
var _weapon_mode := WEAPON_BLADE
var _blade_guard_timer := 0.0
var _swap_enabled := true
var _skin_id := DEFAULT_SKIN_ID
var _sheet_data := {}
var _landing_pose_timer := 0.0
var _landing_pose_duration := 0.0
var _burst_recover_pose_timer := 0.0
var _burst_recover_pose_duration := 0.0
var _hurt_pose_timer := 0.0
var _hurt_pose_duration := 0.0
var _gun_shells := GUN_SHELL_CAPACITY
var _gun_reload_timer := 0.0
var _gun_recoil_timer := 0.0
var _gun_attack_variant := "forward"
var _gun_attack_direction := Vector2.RIGHT
var _blade_attack_variant := "neutral"
var _weapon_upgrade_levels := DEFAULT_WEAPON_UPGRADES.duplicate(true)

@onready var visual: Sprite2D = $Visual


func _ready() -> void:
	add_to_group("player")
	_load_sheet_data()
	_ensure_visual_texture()
	_update_visual()
	emit_signal("health_changed", health, MAX_HEALTH)
	emit_signal("fuel_changed", fuel, MAX_FUEL)
	emit_signal("weapon_mode_changed", _weapon_mode)


func reset_to(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	health = MAX_HEALTH
	fuel = MAX_FUEL
	facing = 1
	_controls_enabled = true
	_jump_buffer_timer = 0.0
	_burst_buffer_timer = 0.0
	_coyote_timer = 0.0
	_fire_cooldown = 0.0
	_invulnerability_timer = 0.0
	_burst_timer = 0.0
	_burst_cooldown = 0.0
	_burst_target = Vector2.ZERO
	_wall_normal = Vector2.ZERO
	_wall_contact_normal = Vector2.ZERO
	_wall_contact_timer = 0.0
	_wall_slide_active = false
	_attack_pose_timer = 0.0
	_attack_pose_duration = 0.0
	_attack_tag_name = "blade_ground"
	_wall_kick_pose_timer = 0.0
	_wall_kick_pose_duration = 0.0
	_spring_chain_timer = 0.0
	_visual_anim_time = 0.0
	_air_jump_available = true
	_blade_guard_timer = 0.0
	_landing_pose_timer = 0.0
	_landing_pose_duration = 0.0
	_burst_recover_pose_timer = 0.0
	_burst_recover_pose_duration = 0.0
	_hurt_pose_timer = 0.0
	_hurt_pose_duration = 0.0
	_weapon_upgrade_levels = DEFAULT_WEAPON_UPGRADES.duplicate(true)
	_gun_shells = get_gun_shell_capacity()
	_gun_reload_timer = 0.0
	_gun_recoil_timer = 0.0
	_gun_attack_variant = "forward"
	_gun_attack_direction = Vector2.RIGHT
	_blade_attack_variant = "neutral"
	_update_visual()
	emit_signal("health_changed", health, MAX_HEALTH)
	emit_signal("fuel_changed", fuel, MAX_FUEL)
	queue_redraw()


func set_controls_enabled(value: bool) -> void:
	_controls_enabled = value
	if not value:
		_burst_buffer_timer = 0.0
		_burst_timer = 0.0
		_burst_recover_pose_timer = 0.0
		_hurt_pose_timer = 0.0
		_wall_slide_active = false
	_update_visual()


func set_facing_direction(value: int) -> void:
	if value == 0:
		return
	facing = 1 if value > 0 else -1
	_update_visual()
	queue_redraw()


func play_weapon_flourish(duration: float = 0.45) -> void:
	velocity = Vector2.ZERO
	_attack_tag_name = _get_optional_tag("gun_ground" if _weapon_mode == WEAPON_GUN else "blade_ground")
	_attack_pose_duration = maxf(duration, SpriteSheetLibrary.get_tag_total_duration(_sheet_data, _attack_tag_name, duration))
	_attack_pose_timer = maxf(_attack_pose_timer, _attack_pose_duration)
	_wall_kick_pose_timer = 0.0
	_burst_timer = 0.0
	_burst_cooldown = 0.0
	_burst_recover_pose_timer = 0.0
	_landing_pose_timer = 0.0
	_hurt_pose_timer = 0.0
	_wall_slide_active = false
	_update_visual()
	queue_redraw()


func get_weapon_mode() -> String:
	return _weapon_mode


func get_skin_id() -> String:
	return _skin_id


func get_fx_profile() -> Dictionary:
	return SkinPalette.get_fx_profile(_skin_id)


func apply_skin(skin_id: String) -> void:
	var normalized := SkinPalette.normalize_skin_id(skin_id)
	if _skin_id == normalized and visual != null and visual.texture != null:
		return
	_skin_id = normalized
	_rebuild_visual_texture()
	queue_redraw()


func set_weapon_mode(mode: String) -> void:
	if mode != WEAPON_BLADE and mode != WEAPON_GUN:
		return
	if _weapon_mode == mode:
		return
	_weapon_mode = mode
	_blade_guard_timer = 0.0
	_attack_pose_timer = 0.0
	_attack_pose_duration = 0.0
	emit_signal("weapon_mode_changed", _weapon_mode)
	_update_visual()
	queue_redraw()


func set_swap_enabled(value: bool) -> void:
	_swap_enabled = value


func is_swap_enabled() -> bool:
	return _swap_enabled


func reset_weapon_upgrades() -> void:
	_weapon_upgrade_levels = DEFAULT_WEAPON_UPGRADES.duplicate(true)
	_gun_shells = get_gun_shell_capacity()
	_gun_reload_timer = 0.0
	queue_redraw()


func upgrade_weapon(mode: String) -> int:
	if not _weapon_upgrade_levels.has(mode):
		return 0
	_weapon_upgrade_levels[mode] = int(_weapon_upgrade_levels[mode]) + 1
	if mode == WEAPON_GUN:
		_gun_shells = get_gun_shell_capacity()
		_gun_reload_timer = 0.0
	queue_redraw()
	return int(_weapon_upgrade_levels[mode])


func get_weapon_upgrade_level(mode: String) -> int:
	return int(_weapon_upgrade_levels.get(mode, 0))


func get_gun_shells() -> int:
	return _gun_shells


func get_gun_shell_capacity() -> int:
	return GUN_SHELL_CAPACITY + get_weapon_upgrade_level(WEAPON_GUN)


func is_gun_reloading() -> bool:
	return _gun_shells < get_gun_shell_capacity() and _gun_reload_timer > 0.0 and is_on_floor()


func apply_refill(amount: float) -> void:
	var previous_fuel := fuel
	fuel = minf(MAX_FUEL, fuel + amount)
	if absf(previous_fuel - fuel) > 0.01:
		emit_signal("fuel_changed", fuel, MAX_FUEL)


func apply_spring(vertical_speed: float) -> void:
	velocity.y = minf(velocity.y, vertical_speed)
	_spring_chain_timer = SPRING_CHAIN_WINDOW
	_burst_timer = 0.0
	_burst_recover_pose_timer = 0.0
	_wall_slide_active = false
	_air_jump_available = true
	queue_redraw()


func apply_spring_boost(vertical_speed: float) -> void:
	apply_spring(vertical_speed)


func take_damage(source_position: Vector2) -> void:
	if _invulnerability_timer > 0.0 or not _controls_enabled:
		return

	if _weapon_mode == WEAPON_BLADE and _blade_guard_timer > 0.0:
		return

	health -= 1
	_invulnerability_timer = 0.85
	_burst_buffer_timer = 0.0
	_burst_timer = 0.0
	_burst_recover_pose_timer = 0.0
	_landing_pose_timer = 0.0
	_spring_chain_timer = 0.0
	_wall_slide_active = false
	_hurt_pose_duration = SpriteSheetLibrary.get_tag_total_duration(_sheet_data, _get_optional_tag("hurt"), 0.11)
	_hurt_pose_timer = _hurt_pose_duration
	velocity = Vector2(signf(global_position.x - source_position.x) * 250.0, -290.0)
	emit_signal("damaged", health, MAX_HEALTH)
	emit_signal("health_changed", health, MAX_HEALTH)
	queue_redraw()

	if health <= 0:
		force_fail()


func force_fail() -> void:
	if not _controls_enabled:
		return

	_controls_enabled = false
	_burst_buffer_timer = 0.0
	_burst_timer = 0.0
	_burst_recover_pose_timer = 0.0
	_wall_slide_active = false
	emit_signal("died")


func _physics_process(delta: float) -> void:
	var previous_fuel := fuel
	var was_on_floor := is_on_floor()
	var previous_burst_timer := _burst_timer

	if _fire_cooldown > 0.0:
		_fire_cooldown = maxf(_fire_cooldown - delta, 0.0)
	if _invulnerability_timer > 0.0:
		_invulnerability_timer = maxf(_invulnerability_timer - delta, 0.0)
	if _jump_buffer_timer > 0.0:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)
	if _burst_buffer_timer > 0.0:
		_burst_buffer_timer = maxf(_burst_buffer_timer - delta, 0.0)
	if _burst_timer > 0.0:
		_burst_timer = maxf(_burst_timer - delta, 0.0)
	if _burst_cooldown > 0.0:
		_burst_cooldown = maxf(_burst_cooldown - delta, 0.0)
	if _attack_pose_timer > 0.0:
		_attack_pose_timer = maxf(_attack_pose_timer - delta, 0.0)
	if _landing_pose_timer > 0.0:
		_landing_pose_timer = maxf(_landing_pose_timer - delta, 0.0)
	if _wall_kick_pose_timer > 0.0:
		_wall_kick_pose_timer = maxf(_wall_kick_pose_timer - delta, 0.0)
	if _burst_recover_pose_timer > 0.0:
		_burst_recover_pose_timer = maxf(_burst_recover_pose_timer - delta, 0.0)
	if _hurt_pose_timer > 0.0:
		_hurt_pose_timer = maxf(_hurt_pose_timer - delta, 0.0)
	if _spring_chain_timer > 0.0:
		_spring_chain_timer = maxf(_spring_chain_timer - delta, 0.0)
	if _gun_recoil_timer > 0.0:
		_gun_recoil_timer = maxf(_gun_recoil_timer - delta, 0.0)
	if _wall_contact_timer > 0.0:
		_wall_contact_timer = maxf(_wall_contact_timer - delta, 0.0)
		if _wall_contact_timer <= 0.0:
			_wall_contact_normal = Vector2.ZERO
	if _blade_guard_timer > 0.0:
		_blade_guard_timer = maxf(_blade_guard_timer - delta, 0.0)

	var move_input := 0.0
	var jump_pressed := false
	var burst_pressed := false
	var shoot_pressed := false
	var swap_pressed := false
	var vertical_attack_input := 0.0

	if _controls_enabled:
		move_input = Input.get_axis("move_left", "move_right")
		jump_pressed = Input.is_action_just_pressed("jump")
		burst_pressed = Input.is_action_just_pressed("jetpack")
		shoot_pressed = Input.is_action_pressed("shoot")
		swap_pressed = Input.is_action_just_pressed("swap_weapon")
		vertical_attack_input = _get_vertical_attack_input()

	if move_input != 0.0:
		facing = int(signf(move_input))

	var active_wall_normal := _wall_normal if _wall_normal != Vector2.ZERO else _wall_contact_normal
	var has_wall_contact := active_wall_normal != Vector2.ZERO and _wall_contact_timer > 0.0
	var wall_slide_intent := _controls_enabled and not is_on_floor() and has_wall_contact and velocity.y > -30.0
	wall_slide_intent = wall_slide_intent and (move_input * active_wall_normal.x < -0.15 or absf(move_input) < 0.12)

	if jump_pressed:
		if has_wall_contact:
			_do_wall_kick(active_wall_normal)
		elif _controls_enabled and _coyote_timer <= 0.0 and not is_on_floor() and _air_jump_available and _burst_timer <= 0.0:
			_do_air_jump(move_input)
		else:
			_jump_buffer_timer = JUMP_BUFFER

	if burst_pressed:
		_burst_buffer_timer = BURST_BUFFER

	if swap_pressed and _swap_enabled:
		_toggle_weapon_mode()

	if is_on_floor():
		_coyote_timer = COYOTE_TIME
		_air_jump_available = true
		fuel = move_toward(fuel, MAX_FUEL, GROUND_FUEL_RECHARGE * delta)
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	if _controls_enabled and _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = JUMP_SPEED
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0

	if _controls_enabled:
		_try_start_burst(move_input, active_wall_normal)

	if _controls_enabled and shoot_pressed and _fire_cooldown <= 0.0:
		if _weapon_mode == WEAPON_GUN:
			_do_gun_attack(vertical_attack_input)
		else:
			_fire_cooldown = BLADE_INTERVAL
			_do_blade_attack(move_input, vertical_attack_input)

	var target_speed := move_input * RUN_SPEED
	var acceleration := GROUND_ACCEL if is_on_floor() else AIR_ACCEL
	if _gun_recoil_timer > 0.0 and not is_on_floor():
		acceleration *= 0.35
		if absf(move_input) < 0.12:
			target_speed = velocity.x
	velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
	if move_input == 0.0 and is_on_floor() and _gun_recoil_timer <= 0.0:
		velocity.x = move_toward(velocity.x, 0.0, GROUND_FRICTION * delta)

	var gravity_strength := GRAVITY_RISE if velocity.y < 0.0 else GRAVITY_FALL
	if _burst_timer > 0.0:
		gravity_strength *= 0.28
	velocity.y += gravity_strength * delta

	_wall_slide_active = wall_slide_intent
	if _wall_slide_active:
		velocity.y = minf(velocity.y, WALL_SLIDE_SPEED)

	if _burst_timer > 0.0:
		velocity.x = move_toward(velocity.x, _burst_target.x, BURST_ACCEL * delta)
		velocity.y = move_toward(velocity.y, _burst_target.y, BURST_ACCEL * delta)

	move_and_slide()
	var landed := not was_on_floor and is_on_floor() and previous_burst_timer <= 0.0
	_update_wall_cache()
	active_wall_normal = _wall_normal if _wall_normal != Vector2.ZERO else _wall_contact_normal
	if _controls_enabled:
		_try_start_burst(move_input, active_wall_normal)
	if _controls_enabled and _jump_buffer_timer > 0.0 and not is_on_floor() and active_wall_normal != Vector2.ZERO and _wall_contact_timer > 0.0:
		_do_wall_kick(active_wall_normal)
	_notify_platform_contacts()

	if previous_burst_timer > 0.0 and _burst_timer <= 0.0:
		_start_burst_recover_pose()
	if landed:
		_start_landing_pose()
	_update_gun_reload(delta)

	if absf(previous_fuel - fuel) > 0.01:
		emit_signal("fuel_changed", fuel, MAX_FUEL)

	_visual_anim_time += delta
	_update_visual()
	queue_redraw()


func _do_wall_kick(kick_normal: Vector2) -> void:
	velocity.x = kick_normal.x * WALL_KICK_X
	velocity.y = WALL_KICK_Y
	facing = int(signf(velocity.x))
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	_burst_timer = 0.0
	_wall_contact_timer = 0.0
	_wall_contact_normal = Vector2.ZERO
	_wall_slide_active = false
	_wall_kick_pose_duration = SpriteSheetLibrary.get_tag_total_duration(_sheet_data, "wall_kick", 0.12)
	_wall_kick_pose_timer = _wall_kick_pose_duration
	_landing_pose_timer = 0.0
	_burst_recover_pose_timer = 0.0
	emit_signal("movement_event", "wall_kick")


func _do_air_jump(move_input: float) -> void:
	var jump_dir := move_input if absf(move_input) > 0.1 else float(facing)
	velocity.x = jump_dir * AIR_JUMP_X_SPEED
	velocity.y = AIR_JUMP_SPEED
	facing = int(signf(jump_dir))
	_air_jump_available = false
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	_wall_slide_active = false
	_wall_contact_timer = 0.0
	_wall_contact_normal = Vector2.ZERO
	emit_signal("movement_event", "air_jump")


func _do_gun_attack(vertical_input: float) -> void:
	if _gun_shells <= 0:
		return

	var shot_data := _build_gun_attack_profile(vertical_input)
	_gun_shells = maxi(_gun_shells - 1, 0)
	_gun_reload_timer = 0.0
	_gun_recoil_timer = GUN_RECOIL_CONTROL_WINDOW
	_gun_attack_variant = String(shot_data.get("variant", "forward"))
	_gun_attack_direction = shot_data.get("direction", Vector2(float(facing), 0.0))
	_blade_attack_variant = "neutral"
	_start_attack_pose("gun_air" if _is_effectively_airborne() else "gun_ground", GUN_FIRE_INTERVAL)
	_fire_cooldown = GUN_FIRE_INTERVAL
	_landing_pose_timer = 0.0
	_burst_recover_pose_timer = 0.0
	_hurt_pose_timer = 0.0
	_apply_impulse(shot_data.get("recoil", Vector2.ZERO))
	emit_signal("shot_fired", _get_muzzle_position(_gun_attack_direction), shot_data)


func _do_blade_attack(move_input: float, vertical_input: float) -> void:
	var attack_data := _build_blade_attack_profile(move_input, vertical_input)
	facing = int(attack_data.get("facing", facing))
	_blade_attack_variant = String(attack_data.get("variant", "neutral"))
	_blade_guard_timer = maxf(BLADE_GUARD_TIME, float(attack_data.get("guard_time", BLADE_GUARD_TIME)))
	_start_attack_pose(String(attack_data.get("attack_tag", "blade_ground")), BLADE_INTERVAL)
	_landing_pose_timer = 0.0
	_burst_recover_pose_timer = 0.0
	_hurt_pose_timer = 0.0
	_apply_impulse(attack_data.get("impulse", Vector2.ZERO))
	emit_signal("slash_fired", _get_slash_origin(_blade_attack_variant), attack_data)


func _build_gun_attack_profile(vertical_input: float) -> Dictionary:
	var aim_direction := Vector2(float(facing), 0.0)
	var recoil := Vector2(-332.0 * float(facing), -82.0)
	var variant := "forward"
	var spread := PackedFloat32Array([-0.18, 0.0, 0.18])
	var speed := 760.0
	var lifetime := 0.34
	var damage := 1 + get_weapon_upgrade_level(WEAPON_GUN)
	var reload_bonus := float(get_weapon_upgrade_level(WEAPON_GUN))
	if vertical_input < -0.35:
		variant = "up"
		aim_direction = Vector2(0.66 * float(facing), -0.76).normalized()
		recoil = Vector2(-286.0 * float(facing), 92.0)
		spread = PackedFloat32Array([-0.12, 0.0, 0.12])
		speed = 700.0 + reload_bonus * 16.0
		lifetime = 0.4
	elif vertical_input > 0.35:
		variant = "down"
		aim_direction = Vector2(0.46 * float(facing), 1.0).normalized()
		recoil = Vector2(-188.0 * float(facing), -422.0)
		spread = PackedFloat32Array([-0.1, 0.0, 0.1])
		speed = 688.0 + reload_bonus * 12.0
		lifetime = 0.42
	else:
		speed += reload_bonus * 22.0

	return {
		"variant": variant,
		"direction": aim_direction,
		"recoil": recoil,
		"spread": spread,
		"speed": speed,
		"damage": damage,
		"lifetime": lifetime,
		"hit_kind": "blast",
		"radius": 4.8 if variant == "forward" else 4.4,
		"trail_length": 16.0 if variant == "forward" else 14.0,
		"trail_width": 3.2,
		"fx_profile": get_fx_profile(),
	}


func _build_blade_attack_profile(move_input: float, vertical_input: float) -> Dictionary:
	var airborne := _is_effectively_airborne()
	var attack_facing := facing
	var blade_level := get_weapon_upgrade_level(WEAPON_BLADE)
	var bonus_damage := blade_level
	if absf(move_input) > 0.1:
		attack_facing = int(signf(move_input))

	if vertical_input < -0.35:
		return {
			"variant": "rise",
			"facing": attack_facing,
			"airborne": airborne,
			"attack_tag": "blade_air" if airborne else "blade_ground",
			"impulse": Vector2(FANG_RISE_X * float(attack_facing), FANG_RISE_Y if airborne else FANG_RISE_Y * 0.9),
			"damage": 2 + bonus_damage,
			"startup_delay": maxf(0.028, 0.04 - blade_level * 0.004),
			"lifetime": 0.055,
			"shape_size": Vector2(34.0, 46.0),
			"shape_offset": Vector2(16.0, -24.0),
			"fx_tag": "air_slash",
			"fx_offset": Vector2(3.0 * float(attack_facing), -14.0),
			"guard_time": 0.16,
		}

	if airborne and vertical_input > 0.35:
		return {
			"variant": "dive",
			"facing": attack_facing,
			"airborne": true,
			"attack_tag": "blade_air",
			"impulse": Vector2(FANG_DIVE_X * float(attack_facing), FANG_DIVE_Y),
			"damage": 3 + bonus_damage,
			"startup_delay": maxf(0.02, 0.03 - blade_level * 0.004),
			"lifetime": 0.05,
			"shape_size": Vector2(46.0, 36.0),
			"shape_offset": Vector2(22.0, 12.0),
			"fx_tag": "air_slash",
			"fx_offset": Vector2(10.0 * float(attack_facing), 12.0),
			"guard_time": 0.18,
		}

	return {
		"variant": "neutral",
		"facing": attack_facing,
		"airborne": airborne,
		"attack_tag": "blade_air" if airborne else "blade_ground",
		"impulse": Vector2(FANG_FORWARD_CARRY_X * float(attack_facing), FANG_FORWARD_CARRY_Y if airborne else -18.0),
		"damage": 2 + bonus_damage,
		"startup_delay": maxf(0.03, (0.045 if airborne else 0.055) - blade_level * 0.004),
		"lifetime": 0.05,
		"shape_size": Vector2(48.0, 28.0) if airborne else Vector2(44.0, 24.0),
		"shape_offset": Vector2(22.0, -11.0) if airborne else Vector2(20.0, -6.0),
		"fx_tag": "air_slash" if airborne else "ground_slash",
		"fx_offset": Vector2(6.0 * float(attack_facing), -4.0 if not airborne else -10.0),
		"guard_time": 0.14,
	}


func _apply_impulse(impulse: Vector2) -> void:
	velocity.x += impulse.x
	if impulse.y < 0.0:
		velocity.y = minf(velocity.y + impulse.y, impulse.y)
	elif impulse.y > 0.0:
		velocity.y = maxf(velocity.y + impulse.y, impulse.y)


func _update_gun_reload(delta: float) -> void:
	if _gun_shells >= get_gun_shell_capacity():
		_gun_reload_timer = 0.0
		return
	if not is_on_floor():
		_gun_reload_timer = 0.0
		return
	if _gun_reload_timer <= 0.0:
		_gun_reload_timer = maxf(0.08, GUN_GROUNDED_RELOAD_DELAY - get_weapon_upgrade_level(WEAPON_GUN) * 0.025)
		return
	_gun_reload_timer = maxf(_gun_reload_timer - delta, 0.0)
	if _gun_reload_timer <= 0.0:
		_gun_shells = get_gun_shell_capacity()
		queue_redraw()


func _get_vertical_attack_input() -> float:
	var up_strength := maxf(Input.get_action_strength("ui_up"), Input.get_action_strength("jump"))
	var down_strength := maxf(Input.get_action_strength("move_down"), Input.get_action_strength("ui_down"))
	return clampf(down_strength - up_strength, -1.0, 1.0)


func _is_effectively_airborne() -> bool:
	return not is_on_floor() or velocity.y < -24.0


func _start_attack_pose(tag_name: String, fallback_duration: float) -> void:
	_attack_tag_name = _get_optional_tag(tag_name)
	_attack_pose_duration = SpriteSheetLibrary.get_tag_total_duration(_sheet_data, _attack_tag_name, fallback_duration)
	_attack_pose_timer = _attack_pose_duration
	_landing_pose_timer = 0.0
	_burst_recover_pose_timer = 0.0
	_hurt_pose_timer = 0.0


func _start_landing_pose() -> void:
	_landing_pose_duration = SpriteSheetLibrary.get_tag_total_duration(_sheet_data, "land", 0.12)
	_landing_pose_timer = _landing_pose_duration


func _start_burst_recover_pose() -> void:
	_burst_recover_pose_duration = SpriteSheetLibrary.get_tag_total_duration(_sheet_data, "burst_end", 0.08)
	_burst_recover_pose_timer = _burst_recover_pose_duration


func _toggle_weapon_mode() -> void:
	_weapon_mode = WEAPON_GUN if _weapon_mode == WEAPON_BLADE else WEAPON_BLADE
	_blade_guard_timer = 0.0
	_attack_pose_timer = 0.0
	_attack_pose_duration = 0.0
	emit_signal("weapon_mode_changed", _weapon_mode)
	_update_visual()
	queue_redraw()


func on_blade_hit(destroyed: bool, _hit_position: Vector2, attack_data: Dictionary = {}) -> void:
	var variant := String(attack_data.get("variant", _blade_attack_variant))
	_blade_guard_timer = maxf(_blade_guard_timer, 0.1)
	var rebound_y := BLADE_HIT_REBOUND_Y
	var rebound_x := BLADE_HIT_REBOUND_X
	match variant:
		"rise":
			rebound_y = FANG_RISE_REBOUND_Y
			rebound_x = 20.0
		"dive":
			rebound_y = FANG_DIVE_REBOUND_Y
			rebound_x = 32.0
	if destroyed:
		rebound_y = minf(rebound_y - 58.0, BLADE_KILL_REBOUND_Y if variant != "dive" else -312.0)
	velocity.y = minf(velocity.y, rebound_y)
	velocity.x += float(facing) * rebound_x


func _try_start_burst(move_input: float, active_wall_normal: Vector2) -> void:
	if _burst_buffer_timer <= 0.0 or _burst_cooldown > 0.0 or is_on_floor() or fuel < BURST_COST:
		return

	var burst_kind := "burst"
	var burst_velocity := Vector2(
		(move_input if absf(move_input) > 0.1 else float(facing)) * BURST_NEUTRAL_X,
		BURST_NEUTRAL_Y
	)

	if active_wall_normal != Vector2.ZERO and _wall_contact_timer > 0.0:
		burst_velocity = Vector2(active_wall_normal.x * BURST_WALL_X, BURST_WALL_Y)
		burst_kind = "wall_burst"
	elif velocity.y > BURST_FALL_SPEED_THRESHOLD:
		burst_velocity.y = BURST_FALL_SAVE_Y
		burst_kind = "burst_save"
	elif _spring_chain_timer > 0.0 or _wall_kick_pose_timer > 0.0:
		burst_velocity = Vector2(
			(move_input if absf(move_input) > 0.1 else float(facing)) * BURST_CHAIN_X,
			BURST_CHAIN_Y
		)
		burst_kind = "burst_chain"

	_burst_buffer_timer = 0.0
	_burst_timer = BURST_DURATION
	_burst_cooldown = BURST_COOLDOWN
	_burst_target = burst_velocity
	fuel = maxf(0.0, fuel - BURST_COST)
	velocity.x = burst_velocity.x
	velocity.y = minf(velocity.y, burst_velocity.y)
	_wall_slide_active = false
	_wall_contact_timer = 0.0
	_wall_contact_normal = Vector2.ZERO
	_landing_pose_timer = 0.0
	_burst_recover_pose_timer = 0.0
	emit_signal("movement_event", burst_kind)


func _update_wall_cache() -> void:
	_wall_normal = Vector2.ZERO
	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		if absf(collision.get_normal().x) > 0.7:
			_wall_normal = collision.get_normal()
			break

	if _wall_normal != Vector2.ZERO:
		_wall_contact_normal = _wall_normal
		_wall_contact_timer = WALL_CONTACT_GRACE

	_wall_slide_active = not is_on_floor() and (_wall_normal != Vector2.ZERO or _wall_contact_timer > 0.0) and velocity.y > 0.0


func _notify_platform_contacts() -> void:
	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		var collider := collision.get_collider()
		if collider != null and collider.has_method("on_player_contact"):
			var landing := collision.get_normal().y < -0.6
			collider.call("on_player_contact", self, landing)


func _get_muzzle_position(aim_direction: Vector2 = Vector2.RIGHT) -> Vector2:
	var aim := aim_direction.normalized()
	if aim == Vector2.ZERO:
		aim = Vector2(float(facing), 0.0)
	var perpendicular := Vector2(-aim.y, aim.x)
	return global_position + aim * 18.0 + perpendicular * 2.0 + Vector2(0.0, -8.0)


func _get_slash_origin(variant: String = "neutral") -> Vector2:
	match variant:
		"rise":
			return global_position + Vector2(12.0 * float(facing), -24.0)
		"dive":
			return global_position + Vector2(16.0 * float(facing), 6.0)
		_:
			return global_position + Vector2(20.0 * float(facing), -7.0)


func _update_visual() -> void:
	if not _using_sheet_visual():
		return

	var blink_hidden := _invulnerability_timer > 0.0 and int(Time.get_ticks_msec() / 70.0) % 2 == 0
	var state := _get_visual_state()
	var tag_name := String(state.get("tag", "idle"))
	var elapsed := float(state.get("elapsed", _visual_anim_time))
	var hold_on_last := bool(state.get("hold_on_last", false))
	var frame_index := SpriteSheetLibrary.get_frame_for_time(_sheet_data, tag_name, elapsed, hold_on_last)
	var frame_rect := SpriteSheetLibrary.get_frame_rect(_sheet_data, frame_index)
	visual.visible = not blink_hidden
	visual.flip_h = facing < 0
	visual.region_rect = frame_rect


func _get_visual_state() -> Dictionary:
	if health <= 0:
		return {"tag": _get_optional_tag("hurt"), "elapsed": _visual_anim_time, "hold_on_last": false}
	if _burst_timer > 0.0:
		var burst_start_total := SpriteSheetLibrary.get_tag_total_duration(_sheet_data, "burst_start", 0.04)
		var burst_elapsed := BURST_DURATION - _burst_timer
		if burst_elapsed <= burst_start_total:
			return {"tag": "burst_start", "elapsed": burst_elapsed, "hold_on_last": true}
		return {"tag": "burst_loop", "elapsed": burst_elapsed - burst_start_total, "hold_on_last": false}
	if _burst_recover_pose_timer > 0.0:
		return {
			"tag": "burst_end",
			"elapsed": _burst_recover_pose_duration - _burst_recover_pose_timer,
			"hold_on_last": true,
		}
	if _landing_pose_timer > 0.0 and is_on_floor():
		return {
			"tag": "land",
			"elapsed": _landing_pose_duration - _landing_pose_timer,
			"hold_on_last": true,
		}
	if _wall_kick_pose_timer > 0.0:
		return {
			"tag": "wall_kick",
			"elapsed": _wall_kick_pose_duration - _wall_kick_pose_timer,
			"hold_on_last": true,
		}
	if _attack_pose_timer > 0.0:
		return {
			"tag": _attack_tag_name,
			"elapsed": _attack_pose_duration - _attack_pose_timer,
			"hold_on_last": true,
		}
	if _hurt_pose_timer > 0.0:
		return {
			"tag": _get_optional_tag("hurt"),
			"elapsed": _hurt_pose_duration - _hurt_pose_timer,
			"hold_on_last": true,
		}
	if _wall_slide_active:
		return {"tag": "wall_slide", "elapsed": _visual_anim_time, "hold_on_last": false}
	if not is_on_floor():
		return {"tag": "jump_up" if velocity.y < 0.0 else "fall", "elapsed": _visual_anim_time, "hold_on_last": false}
	if absf(velocity.x) > 36.0:
		return {"tag": _get_optional_tag("run"), "elapsed": _visual_anim_time, "hold_on_last": false}
	return {"tag": _get_optional_tag("idle"), "elapsed": _visual_anim_time, "hold_on_last": false}


func _get_optional_tag(base_tag: String) -> String:
	if _weapon_mode != WEAPON_BLADE:
		return base_tag
	var blade_tag := "%s_blade" % base_tag
	return blade_tag if SpriteSheetLibrary.has_tag(_sheet_data, blade_tag) else base_tag


func _using_sheet_visual() -> bool:
	return visual != null and visual.texture != null


func _ensure_visual_texture() -> void:
	if visual == null:
		return

	_load_sheet_data()
	_rebuild_visual_texture()


func _rebuild_visual_texture() -> void:
	if visual == null:
		return
	visual.texture = ExportArt.get_player_skin_texture(_skin_id)


func _load_sheet_data() -> void:
	if not _sheet_data.is_empty():
		return
	_sheet_data = ExportArt.get_player_sheet_data()


func _draw_shadow_blob(center: Vector2, radius_x: float, radius_y: float, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(12):
		var angle := TAU * float(index) / 12.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	draw_colored_polygon(points, color)


func _draw() -> void:
	if _using_sheet_visual():
		if is_on_floor():
			_draw_shadow_blob(Vector2(0.0, 16.5), 8.5, 2.5, Color(0.0, 0.0, 0.0, 0.16))
		_draw_weapon_overlay()
		if _wall_slide_active:
			var slide_normal := _wall_normal if _wall_normal != Vector2.ZERO else _wall_contact_normal
			var spark_x := 16.0 if slide_normal.x < 0.0 else -16.0
			draw_circle(Vector2(spark_x, 4.0), 3.0, Color(0.952941, 0.694118, 0.356863, 0.85))
			draw_line(
				Vector2(spark_x, 7.0),
				Vector2(spark_x - 8.0 * slide_normal.x, 18.0),
				Color(0.94902, 0.862745, 0.611765, 0.75),
				2.0
			)
		return

	if _invulnerability_timer > 0.0 and int(Time.get_ticks_msec() / 70.0) % 2 == 0:
		return

	var palette := SkinPalette.get_palette(_skin_id)
	var body_color: Color = palette["body"]
	var trim_color: Color = palette["trim"]
	var boot_color: Color = palette["boot"]
	var nozzle_color: Color = palette["nozzle"]

	if is_on_floor():
		_draw_shadow_blob(Vector2(0.0, 18.0), 10.0, 3.0, Color(0.0, 0.0, 0.0, 0.18))
	draw_rect(Rect2(-12.0, -22.0, 24.0, 28.0), body_color)
	draw_rect(Rect2(-14.0, -12.0, 6.0, 14.0), nozzle_color)
	draw_rect(Rect2(8.0, -12.0, 6.0, 14.0), nozzle_color)
	draw_rect(Rect2(-8.0, -16.0, 16.0, 8.0), trim_color)
	draw_rect(Rect2(-10.0, 6.0, 8.0, 10.0), boot_color)
	draw_rect(Rect2(2.0, 6.0, 8.0, 10.0), boot_color)
	_draw_weapon_overlay()

	if _burst_timer > 0.0:
		var left_flame := PackedVector2Array([Vector2(-12.0, 4.0), Vector2(-6.0, 4.0), Vector2(-9.0, 24.0)])
		var right_flame := PackedVector2Array([Vector2(6.0, 4.0), Vector2(12.0, 4.0), Vector2(9.0, 26.0)])
		draw_colored_polygon(left_flame, Color(0.94902, 0.65098, 0.258824, 1.0))
		draw_colored_polygon(right_flame, Color(0.94902, 0.65098, 0.258824, 1.0))
		draw_colored_polygon(
			PackedVector2Array([Vector2(-10.0, 6.0), Vector2(-8.0, 6.0), Vector2(-9.0, 16.0)]),
			Color(1.0, 0.894118, 0.478431, 1.0)
		)
		draw_colored_polygon(
			PackedVector2Array([Vector2(8.0, 6.0), Vector2(10.0, 6.0), Vector2(9.0, 18.0)]),
			Color(1.0, 0.894118, 0.478431, 1.0)
		)

	if _wall_slide_active:
		var slide_normal := _wall_normal if _wall_normal != Vector2.ZERO else _wall_contact_normal
		var spark_x := 16.0 if slide_normal.x < 0.0 else -16.0
		draw_circle(Vector2(spark_x, 4.0), 3.0, Color(0.952941, 0.694118, 0.356863, 0.85))
		draw_line(
			Vector2(spark_x, 7.0),
			Vector2(spark_x - 8.0 * slide_normal.x, 18.0),
			Color(0.94902, 0.862745, 0.611765, 0.75),
			2.0
		)


func _draw_weapon_overlay() -> void:
	if _weapon_mode == WEAPON_GUN:
		_draw_blaster_overlay()
	else:
		_draw_arc_cutter_overlay()


func _draw_blaster_overlay() -> void:
	var fx_profile := get_fx_profile()
	var attack_active := _attack_pose_timer > 0.0
	var attack_elapsed := _attack_pose_duration - _attack_pose_timer
	var attack_phase := SpriteSheetLibrary.get_tag_frame_position(_sheet_data, _attack_tag_name, attack_elapsed, true) if attack_active else 0
	var contact_phase := attack_active and attack_phase == 1
	var recover_phase := attack_active and attack_phase >= 2
	var aim := _gun_attack_direction.normalized()
	if aim == Vector2.ZERO:
		aim = Vector2(float(facing), 0.0)
	var perp := Vector2(-aim.y, aim.x)
	var grip := Vector2(5.0 * float(facing), -7.0)
	var stock := grip - aim * 9.0 + perp * 2.0
	var receiver := grip + aim * 16.0
	var muzzle_tip := receiver + aim * 12.0 + (aim * 5.0 if contact_phase else Vector2.ZERO)
	var shell_color: Color = fx_profile.get("projectile_core", Color(0.952941, 0.694118, 0.356863, 1.0))
	var flash_color: Color = fx_profile.get("muzzle_flash", Color(1.0, 0.913725, 0.541176, 0.95))
	var glow_color: Color = fx_profile.get("projectile_glow", Color(1.0, 0.768627, 0.372549, 0.45))
	var body := PackedVector2Array(
		[
			stock + perp * 4.0,
			receiver + perp * 4.0,
			receiver - perp * 4.0,
			stock - perp * 4.0,
		]
	)
	var barrel := PackedVector2Array(
		[
			receiver + perp * 3.0,
			muzzle_tip + perp * 2.5,
			muzzle_tip - perp * 2.5,
			receiver - perp * 3.0,
		]
	)
	var pump := PackedVector2Array(
		[
			grip + perp * 3.0,
			grip + aim * 10.0 + perp * 3.0,
			grip + aim * 10.0 - perp * 3.0,
			grip - perp * 3.0,
		]
	)
	draw_colored_polygon(body, Color(0.121569, 0.14902, 0.176471, 1.0))
	draw_colored_polygon(barrel, shell_color.darkened(0.34))
	draw_colored_polygon(pump, Color(0.239216, 0.301961, 0.360784, 1.0))
	draw_line(stock + perp * 1.5, receiver + perp * 1.5, flash_color, 2.0)
	draw_line(stock - perp * 1.5, receiver - perp * 1.5, Color(0.07451, 0.086275, 0.105882, 0.95), 2.0)
	draw_rect(Rect2((grip - aim * 4.0 + perp * 6.0) - Vector2(5.0, 2.0), Vector2(10.0, 4.0)), Color(0.07451, 0.086275, 0.105882, 0.92))
	for shell_index in range(get_gun_shell_capacity()):
		var slot_center := grip - aim * 8.0 + perp * (-3.0 + float(shell_index) * 6.0)
		var loaded := shell_index < _gun_shells
		draw_rect(
			Rect2(slot_center - Vector2(2.5, 3.0), Vector2(5.0, 6.0)),
			shell_color if loaded else Color(0.172549, 0.192157, 0.219608, 0.82)
		)
	if attack_active and contact_phase:
		draw_line(muzzle_tip, muzzle_tip + aim * 10.0, flash_color, 4.0)
		draw_arc(muzzle_tip, 10.0, aim.angle() - 0.65, aim.angle() + 0.65, 10, glow_color, 3.0)
	elif attack_active and recover_phase:
		draw_arc(muzzle_tip - aim * 2.0, 8.0, aim.angle() - 0.5, aim.angle() + 0.5, 10, Color(glow_color.r, glow_color.g, glow_color.b, 0.28), 2.0)


func _draw_arc_cutter_overlay() -> void:
	var attack_active := _attack_pose_timer > 0.0
	var attack_elapsed := _attack_pose_duration - _attack_pose_timer
	var attack_phase := SpriteSheetLibrary.get_tag_frame_position(_sheet_data, _attack_tag_name, attack_elapsed, true) if attack_active else -1
	var windup_phase := attack_active and attack_phase == 0
	var contact_phase := attack_active and attack_phase == 1
	var recover_phase := attack_active and attack_phase >= 2
	var grip := Vector2(8.0 * float(facing), -8.0)
	var mid := grip + Vector2(8.0 * float(facing), -2.0)
	var tip := grip + Vector2(17.0 * float(facing), -4.0)
	match _blade_attack_variant:
		"rise":
			grip = Vector2(6.0 * float(facing), -2.0 if windup_phase else -10.0)
			mid = grip + Vector2(5.0 * float(facing), -9.0 if contact_phase else -6.0)
			tip = grip + Vector2(10.0 * float(facing), -19.0 if contact_phase else -15.0)
		"dive":
			grip = Vector2(8.0 * float(facing), -14.0 if windup_phase else -8.0)
			mid = grip + Vector2(9.0 * float(facing), 4.0 if contact_phase else 1.0)
			tip = grip + Vector2(18.0 * float(facing), 15.0 if contact_phase else 9.0)
		_:
			if windup_phase:
				grip = Vector2(8.0 * float(facing), -5.0)
				mid = grip + Vector2(9.0 * float(facing), 1.0)
				tip = grip + Vector2(17.0 * float(facing), 4.0)
			elif contact_phase:
				grip = Vector2(8.0 * float(facing), -10.0)
				mid = grip + Vector2(9.0 * float(facing), -5.0)
				tip = grip + Vector2(17.0 * float(facing), -9.0)
			elif recover_phase:
				grip = Vector2(8.0 * float(facing), -8.0)
				mid = grip + Vector2(12.0 * float(facing), -1.0)
				tip = grip + Vector2(15.0 * float(facing), -2.0)
	var inner_tip := tip + Vector2(2.0 * float(facing), -1.0 if contact_phase and _blade_attack_variant != "dive" else 0.0)
	var hilt_rect := Rect2(grip + Vector2(-2.0 if facing > 0 else -4.0, -2.0), Vector2(4.0, 5.0))
	draw_rect(hilt_rect, Color(0.952941, 0.694118, 0.356863, 1.0))
	draw_polyline(PackedVector2Array([grip, mid, tip]), Color(0.956863, 0.937255, 0.819608, 1.0), 4.0)
	draw_polyline(PackedVector2Array([grip + Vector2(0.0, 1.0), mid + Vector2(0.0, 1.0), inner_tip + Vector2(0.0, 1.0)]), Color(0.286275, 0.831373, 0.898039, 0.92), 2.0)
	draw_line(grip + Vector2(0.0, 2.0), mid + Vector2(-2.0 * float(facing), 3.0), Color(0.94902, 0.862745, 0.611765, 0.7), 2.0)
	if attack_active:
		if contact_phase:
			var contact_center := Vector2(6.0 * float(facing), -2.0)
			if _blade_attack_variant == "rise":
				contact_center = Vector2(5.0 * float(facing), -12.0)
				if facing > 0:
					draw_arc(contact_center, 22.0, -2.12, -0.12, 14, Color(0.956863, 0.74902, 0.392157, 0.42), 4.0)
					draw_arc(contact_center, 18.0, -2.0, -0.22, 14, Color(0.521569, 0.92549, 0.968627, 0.7), 2.0)
				else:
					draw_arc(contact_center, 22.0, PI + 0.12, PI + 2.12, 14, Color(0.956863, 0.74902, 0.392157, 0.42), 4.0)
					draw_arc(contact_center, 18.0, PI + 0.22, PI + 2.0, 14, Color(0.521569, 0.92549, 0.968627, 0.7), 2.0)
			elif _blade_attack_variant == "dive":
				contact_center = Vector2(8.0 * float(facing), 4.0)
				if facing > 0:
					draw_arc(contact_center, 22.0, -0.3, 1.48, 14, Color(0.956863, 0.74902, 0.392157, 0.42), 4.0)
					draw_arc(contact_center, 18.0, -0.18, 1.34, 14, Color(0.521569, 0.92549, 0.968627, 0.7), 2.0)
				else:
					draw_arc(contact_center, 22.0, PI - 1.48, PI + 0.3, 14, Color(0.956863, 0.74902, 0.392157, 0.42), 4.0)
					draw_arc(contact_center, 18.0, PI - 1.34, PI + 0.18, 14, Color(0.521569, 0.92549, 0.968627, 0.7), 2.0)
			elif facing > 0:
				draw_arc(contact_center, 22.0, -1.62, 0.52, 14, Color(0.956863, 0.74902, 0.392157, 0.42), 4.0)
				draw_arc(contact_center, 18.0, -1.5, 0.4, 14, Color(0.521569, 0.92549, 0.968627, 0.7), 2.0)
			else:
				draw_arc(contact_center, 22.0, PI - 0.52, PI + 1.62, 14, Color(0.956863, 0.74902, 0.392157, 0.42), 4.0)
				draw_arc(contact_center, 18.0, PI - 0.4, PI + 1.5, 14, Color(0.521569, 0.92549, 0.968627, 0.7), 2.0)
		elif windup_phase:
			var windup_center := Vector2(5.0 * float(facing), 1.0)
			if _blade_attack_variant == "rise":
				windup_center = Vector2(4.0 * float(facing), -8.0)
				if facing > 0:
					draw_arc(windup_center, 18.0, -1.8, -0.18, 12, Color(0.956863, 0.74902, 0.392157, 0.26), 3.0)
					draw_arc(windup_center, 15.0, -1.72, -0.28, 12, Color(0.521569, 0.92549, 0.968627, 0.44), 2.0)
				else:
					draw_arc(windup_center, 18.0, PI + 0.18, PI + 1.8, 12, Color(0.956863, 0.74902, 0.392157, 0.26), 3.0)
					draw_arc(windup_center, 15.0, PI + 0.28, PI + 1.72, 12, Color(0.521569, 0.92549, 0.968627, 0.44), 2.0)
			elif _blade_attack_variant == "dive":
				windup_center = Vector2(7.0 * float(facing), -6.0)
				if facing > 0:
					draw_arc(windup_center, 18.0, -0.48, 1.08, 12, Color(0.956863, 0.74902, 0.392157, 0.26), 3.0)
					draw_arc(windup_center, 15.0, -0.36, 0.96, 12, Color(0.521569, 0.92549, 0.968627, 0.44), 2.0)
				else:
					draw_arc(windup_center, 18.0, PI - 1.08, PI + 0.48, 12, Color(0.956863, 0.74902, 0.392157, 0.26), 3.0)
					draw_arc(windup_center, 15.0, PI - 0.96, PI + 0.36, 12, Color(0.521569, 0.92549, 0.968627, 0.44), 2.0)
			elif facing > 0:
				draw_arc(windup_center, 18.0, -0.98, 0.92, 12, Color(0.956863, 0.74902, 0.392157, 0.26), 3.0)
				draw_arc(windup_center, 15.0, -0.9, 0.82, 12, Color(0.521569, 0.92549, 0.968627, 0.44), 2.0)
			else:
				draw_arc(windup_center, 18.0, PI - 0.92, PI + 0.98, 12, Color(0.956863, 0.74902, 0.392157, 0.26), 3.0)
				draw_arc(windup_center, 15.0, PI - 0.82, PI + 0.9, 12, Color(0.521569, 0.92549, 0.968627, 0.44), 2.0)
		elif recover_phase:
			var recover_center := Vector2(7.0 * float(facing), -1.0)
			if facing > 0:
				draw_arc(recover_center, 16.0, -1.36, 0.12, 10, Color(0.956863, 0.74902, 0.392157, 0.18), 2.0)
				draw_arc(recover_center, 13.0, -1.24, 0.0, 10, Color(0.521569, 0.92549, 0.968627, 0.32), 2.0)
			else:
				draw_arc(recover_center, 16.0, PI - 0.12, PI + 1.36, 10, Color(0.956863, 0.74902, 0.392157, 0.18), 2.0)
				draw_arc(recover_center, 13.0, PI, PI + 1.24, 10, Color(0.521569, 0.92549, 0.968627, 0.32), 2.0)
