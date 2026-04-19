extends Area2D
## Skywatcher — 0.3 Sprint-1 Day 4
##
## A rooftop mercenary drone. Hovers, drifts laterally, telegraphs a dive,
## dives at the player, recovers. Weak zone is the underside exhaust cowl —
## hits from below deal double damage (the "read the belly" lesson for
## skyline combat).
##
## Mimics `enemy.gd` contract (Area2D + take_hit + destroyed signal) so the
## juice-pass feedback chain fires automatically. Not an extends because the
## movement state machine is different enough to be its own script.

signal destroyed(points: int, hit_kind: String)

enum State { HOVER, DIVE_TELEGRAPH, DIVE, RECOVER }

@export var max_health: int = 3
@export var patrol_distance: float = 96.0
@export var patrol_speed: float = 88.0
@export var dive_cooldown: float = 2.6
@export var dive_telegraph: float = 0.5
@export var dive_speed: float = 260.0
@export var dive_range: float = 240.0
@export var contact_radius: float = 18.0
@export var point_value: int = 180
@export var weak_zone_offset: float = 4.0  ## world-y offset below the body that counts as the cowl

var _state: State = State.HOVER
var _state_timer: float = 0.0
var _origin: Vector2 = Vector2.ZERO
var _direction: float = 1.0
var _phase: float = 0.0
var _anim_time: float = 0.0
var _health: int = 3
var _hurt_pose_timer: float = 0.0
var _dive_target: Vector2 = Vector2.ZERO
var _player_ref: Node2D = null

@onready var collision_shape: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null


func _ready() -> void:
	add_to_group("hazard")
	_origin = global_position
	_phase = randf() * TAU
	_health = max_health
	_apply_collision_radius()
	body_entered.connect(_on_body_entered)


func configure(config: Dictionary) -> void:
	global_position = config.get("pos", Vector2.ZERO)
	_origin = global_position
	patrol_distance = float(config.get("patrol", patrol_distance))
	patrol_speed = float(config.get("speed", patrol_speed))
	max_health = int(config.get("health", max_health))
	_health = max_health
	contact_radius = float(config.get("radius", contact_radius))
	point_value = int(config.get("points", point_value))
	dive_cooldown = float(config.get("dive_cooldown", dive_cooldown))
	dive_range = float(config.get("dive_range", dive_range))
	_apply_collision_radius()


## Wire the player so Skywatcher can aim its dive. Optional: without a target
## ref the drone stays on patrol forever (useful for tests).
func bind_player(player: Node2D) -> void:
	_player_ref = player


## Matches the `enemy.gd` contract. Returns true if destroyed.
func take_hit(amount: int, hit_position: Vector2, hit_kind: String = "gun") -> bool:
	var damage: int = amount
	# Weak-zone read: a hit landing below the belly line cashes extra damage.
	# Blade cuts score 3x, everything else 2x. Parenthesized so the
	# precedence is obvious.
	if _is_weak_zone_hit(hit_position):
		damage *= (3 if hit_kind == "blade" else 2)
	_health -= damage
	_hurt_pose_timer = 0.22
	if _health <= 0:
		emit_signal("destroyed", point_value, hit_kind)
		queue_free()
		return true
	return false


## Test / debug convenience — expose the current state as a string.
func get_state_name() -> String:
	match _state:
		State.HOVER: return "hover"
		State.DIVE_TELEGRAPH: return "dive_telegraph"
		State.DIVE: return "dive"
		State.RECOVER: return "recover"
	return "unknown"


func is_weak_zone_for(hit_position: Vector2) -> bool:
	return _is_weak_zone_hit(hit_position)


func _is_weak_zone_hit(hit_position: Vector2) -> bool:
	return hit_position.y > global_position.y + weak_zone_offset


func _process(delta: float) -> void:
	_anim_time += delta
	if _hurt_pose_timer > 0.0:
		_hurt_pose_timer = maxf(_hurt_pose_timer - delta, 0.0)
	match _state:
		State.HOVER:
			_update_hover(delta)
		State.DIVE_TELEGRAPH:
			_update_dive_telegraph(delta)
		State.DIVE:
			_update_dive(delta)
		State.RECOVER:
			_update_recover(delta)
	queue_redraw()


func _update_hover(delta: float) -> void:
	global_position.x += _direction * patrol_speed * delta
	if absf(global_position.x - _origin.x) >= patrol_distance:
		_direction *= -1.0
		global_position.x = _origin.x + clampf(global_position.x - _origin.x, -patrol_distance, patrol_distance)
	global_position.y = _origin.y + sin((_anim_time + _phase) * 4.4) * 6.0

	_state_timer += delta
	if _state_timer >= dive_cooldown and _can_dive_at_player():
		_state_timer = 0.0
		_state = State.DIVE_TELEGRAPH
		# Arcade cue: short "charging" chirp on telegraph so the player
		# doesn't rely on vision alone to read the dive.
		_play_cue("gun_hit", 1.4)


func _can_dive_at_player() -> bool:
	if _player_ref == null or not is_instance_valid(_player_ref):
		return false
	var dist: float = global_position.distance_to(_player_ref.global_position)
	return dist <= dive_range


func _update_dive_telegraph(delta: float) -> void:
	_state_timer += delta
	if _state_timer >= dive_telegraph:
		_state_timer = 0.0
		_state = State.DIVE
		_dive_target = _player_ref.global_position if _player_ref != null and is_instance_valid(_player_ref) else global_position


func _update_dive(delta: float) -> void:
	var to_target: Vector2 = _dive_target - global_position
	var step: float = dive_speed * delta
	if to_target.length() <= step:
		global_position = _dive_target
		_state_timer = 0.0
		_state = State.RECOVER
	else:
		global_position += to_target.normalized() * step


func _update_recover(delta: float) -> void:
	_state_timer += delta
	var back: Vector2 = _origin - global_position
	var step: float = patrol_speed * 1.4 * delta
	if back.length() <= step:
		global_position = _origin
		_state_timer = 0.0
		_state = State.HOVER
	else:
		global_position += back.normalized() * step


func _apply_collision_radius() -> void:
	if collision_shape == null:
		return
	var shape := CircleShape2D.new()
	shape.radius = contact_radius
	collision_shape.shape = shape


## Thin helper — shared so tests can stub SoundBank without patching draws.
func _play_cue(sound_name: String, pitch: float = 1.0) -> void:
	var tree: SceneTree = get_tree() if is_inside_tree() else null
	if tree == null or tree.root == null:
		return
	var sb: Node = tree.root.get_node_or_null("SoundBank")
	if sb != null:
		sb.call("play", sound_name, {"pitch": pitch})


func _on_body_entered(body: Node) -> void:
	if _hurt_pose_timer > 0.0:
		return
	if body.has_method("take_damage"):
		body.call("take_damage", global_position)


func _draw() -> void:
	# Placeholder silhouette until art pass in sprint-2. Matches the
	# readable rooftop-menace shape: body, drop-cowl exhaust, eye line.
	var body_color := Color(0.211765, 0.262745, 0.372549, 1.0)
	# Cowl always renders a dim warning-orange so the weak-zone TELL is
	# proactive, not only readable during telegraph. Telegraph brightens it.
	var cowl_color := Color(0.501961, 0.262745, 0.090196, 1.0)
	if _state == State.DIVE_TELEGRAPH:
		cowl_color = Color(0.968627, 0.498039, 0.219608, 1.0)
	var eye_color := Color(0.286275, 0.831373, 0.898039, 1.0)
	# Body
	draw_circle(Vector2(0.0, -2.0), 14.0, body_color)
	# Wing beats
	var wing_offset: float = sin(_anim_time * 22.0 + _phase) * 3.0
	draw_line(Vector2(-16.0, -6.0 + wing_offset), Vector2(-6.0, -2.0), body_color, 3.0)
	draw_line(Vector2(16.0, -6.0 + wing_offset), Vector2(6.0, -2.0), body_color, 3.0)
	# Eye
	draw_rect(Rect2(-4.0, -4.0, 8.0, 2.0), eye_color)
	# Weak-zone cowl (bottom). Warning-orange at rest, bright during telegraph.
	draw_rect(Rect2(-7.0, 8.0, 14.0, 4.0), cowl_color)
	if _hurt_pose_timer > 0.0:
		draw_circle(Vector2(0.0, 0.0), 18.0, Color(0.984314, 0.898039, 0.627451, 0.25))
