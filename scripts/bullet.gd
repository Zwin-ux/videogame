extends Area2D

@export var speed := 760.0
@export var lifetime := 1.2

var direction := Vector2.RIGHT
var damage := 1
var homing_strength := 0.0
var target_radius := 0.0
var max_hits := 1
var _hits_left := 1
var _hit_kind := "gun"
var _core_radius := 4.5
var _trail_length := 12.0
var _trail_width := 3.0
var _core_color := Color(0.960784, 0.698039, 0.337255, 1.0)
var _trail_color := Color(1.0, 0.882353, 0.603922, 0.78)
var _glow_color := Color(1.0, 0.882353, 0.603922, 0.85)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	_hits_left = max_hits


func setup(start_position: Vector2, heading: Vector2, config: Dictionary = {}) -> void:
	global_position = start_position
	direction = heading.normalized()
	speed = float(config.get("speed", speed))
	lifetime = float(config.get("lifetime", lifetime))
	damage = int(config.get("damage", damage))
	homing_strength = float(config.get("homing_strength", homing_strength))
	target_radius = float(config.get("target_radius", target_radius))
	max_hits = int(config.get("max_hits", max_hits))
	_hit_kind = String(config.get("hit_kind", _hit_kind))
	_core_radius = float(config.get("radius", _core_radius))
	_trail_length = float(config.get("trail_length", _trail_length))
	_trail_width = float(config.get("trail_width", _trail_width))
	_core_color = config.get("core_color", _core_color)
	_trail_color = config.get("trail_color", _trail_color)
	_glow_color = config.get("glow_color", _glow_color)
	_hits_left = max_hits
	rotation = direction.angle()
	queue_redraw()


func _process(delta: float) -> void:
	_apply_targeting(delta)
	position += direction * speed * delta
	rotation = direction.angle()
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body is PhysicsBody2D:
		_play_sound("gun_hit")
		_shake(1.5, 0.05)
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_hit"):
		var destroyed := bool(area.call("take_hit", damage, global_position, _hit_kind))
		# 0.2 Hive Signal — gun feedback. No hit-stop on gun kills; that signature belongs to the blade.
		if destroyed:
			_play_sound("enemy_death")
			_shake(3.0, 0.08)
			_bump_music(0.08, 1.2)
		else:
			_play_sound("gun_hit")
			_shake(1.5, 0.05)
			_bump_music(0.03, 0.6)
		_hits_left -= 1
		if _hits_left <= 0:
			queue_free()


func _play_sound(name: String) -> void:
	var sb := _service("SoundBank")
	if sb != null:
		sb.call("play", name)


func _shake(amp: float, dur: float) -> void:
	var cs := _service("CameraShake")
	if cs != null:
		cs.call("kick", amp, dur)


func _bump_music(amount: float, decay: float) -> void:
	var me := _service("MusicEngine")
	if me != null:
		me.call("bump_intensity", amount, decay)


static func _service(name: String) -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null(name) if tree.root != null else null


func _draw() -> void:
	draw_circle(Vector2.ZERO, _core_radius + 0.8, Color(_glow_color.r, _glow_color.g, _glow_color.b, 0.22))
	draw_rect(Rect2(-_trail_length, -_trail_width * 0.5, _trail_length, _trail_width), _trail_color)
	draw_circle(Vector2.ZERO, _core_radius, _core_color)
	draw_circle(Vector2(-_trail_length * 0.35, 0.0), maxf(1.8, _core_radius * 0.48), _glow_color)


func _apply_targeting(delta: float) -> void:
	if homing_strength <= 0.0 or target_radius <= 0.0:
		return

	var target := _find_target()
	if target == null:
		return

	var target_pos := target.global_position
	var desired := (target_pos - global_position).normalized()
	if desired == Vector2.ZERO:
		return

	var blend := clampf(homing_strength * delta, 0.0, 1.0)
	direction = direction.lerp(desired, blend).normalized()


func _find_target() -> Area2D:
	var best_target: Area2D = null
	var best_score := INF

	for node in get_tree().get_nodes_in_group("hazard"):
		if not (node is Area2D):
			continue
		var hazard := node as Area2D
		if not is_instance_valid(hazard) or hazard == self:
			continue
		var to_target := hazard.global_position - global_position
		var distance := to_target.length()
		if distance > target_radius or distance <= 0.001:
			continue
		var facing_score := direction.normalized().dot(to_target.normalized())
		if facing_score < 0.1:
			continue
		var score := distance - facing_score * 64.0
		if score < best_score:
			best_score = score
			best_target = hazard

	return best_target
