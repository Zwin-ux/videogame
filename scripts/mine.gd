extends Area2D

const ExportArt = preload("res://scripts/export_art.gd")
signal destroyed(points: int, hit_kind: String)

const SHEET_FRAME_SIZE := Vector2(32, 32)
const EXPLOSION_RADIUS := 120.0
const EXPLOSION_DAMAGE := 2
const ACTIVE_SEQUENCE := [0, 1, 2, 3, 4, 3, 2, 1]

@export var max_health := 1

var _health := 1
var _anim_time := 0.0
var _exploded := false
var _contact_disabled_timer := 0.0
var _last_hit_kind := "gun"

@onready var visual: Sprite2D = $Visual


func _ready() -> void:
	add_to_group("hazard")
	_health = max_health
	body_entered.connect(_on_body_entered)
	_ensure_visual_texture()
	_update_visual()


func take_hit(amount: int, _hit_position: Vector2, _hit_kind: String = "gun") -> bool:
	if _exploded:
		return false

	_last_hit_kind = _hit_kind
	if _hit_kind == "blade":
		_contact_disabled_timer = 0.12
	_health -= amount
	if _health <= 0:
		_explode()
		emit_signal("destroyed", 80, _last_hit_kind)
		queue_free()
		return true

	queue_redraw()
	return false


func _process(delta: float) -> void:
	_anim_time += delta
	if _contact_disabled_timer > 0.0:
		_contact_disabled_timer = maxf(_contact_disabled_timer - delta, 0.0)
	_update_visual()
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if _exploded or _contact_disabled_timer > 0.0:
		return
	if body.has_method("take_damage"):
		body.call("take_damage", global_position)


func _draw() -> void:
	if _using_sheet_visual():
		draw_circle(Vector2(0.0, 14.0), 16.0, Color(0.0, 0.0, 0.0, 0.16))
		var pulse_alpha := 0.06 + 0.05 * absf(sin(_anim_time * 6.6))
		draw_circle(Vector2(0.0, 13.0), 9.0, Color(0.952941, 0.643137, 0.341176, pulse_alpha))
		return

	var frame := _get_visual_frame()
	var open_level := 0.0
	if frame == 1:
		open_level = 1.0
	elif frame == 2:
		open_level = 2.0
	elif frame == 3:
		open_level = 3.0
	elif frame == 4:
		open_level = 4.0

	var disabled := frame == 5
	var shell_color := Color(0.12549, 0.14902, 0.203922, 1.0) if not disabled else Color(0.113725, 0.160784, 0.203922, 1.0)
	var plate_color := Color(0.192157, 0.231373, 0.286275, 1.0) if not disabled else Color(0.168627, 0.2, 0.247059, 1.0)
	var core_outer := Color(0.780392, 0.713725, 0.572549, 1.0)
	var core_inner := Color(0.286275, 0.831373, 0.898039, 0.92)
	if frame in [2, 3]:
		core_inner = Color(0.952941, 0.643137, 0.341176, 0.94)
	elif frame == 4:
		core_outer = Color(0.952941, 0.694118, 0.356863, 1.0)
		core_inner = Color(0.984314, 0.898039, 0.627451, 1.0)
	elif disabled:
		core_outer = Color(0.239216, 0.301961, 0.360784, 1.0)
		core_inner = Color(0.141176, 0.184314, 0.235294, 1.0)

	draw_circle(Vector2(0.0, 14.0), 16.0, Color(0.0, 0.0, 0.0, 0.16))
	draw_colored_polygon(
		PackedVector2Array(
			[
				Vector2(-9.0, -8.0),
				Vector2(9.0, -8.0),
				Vector2(15.0, 0.0),
				Vector2(9.0, 10.0),
				Vector2(-9.0, 10.0),
				Vector2(-15.0, 0.0),
			]
		),
		shell_color
	)
	draw_rect(Rect2(-11.0 - open_level, -6.0, 6.0, 10.0), plate_color)
	draw_rect(Rect2(5.0 + open_level, -6.0, 6.0, 10.0), plate_color)
	draw_rect(Rect2(-4.0, -10.0 - open_level * 0.5, 8.0, 6.0), plate_color)
	draw_rect(Rect2(-4.0, 4.0 + open_level * 0.4, 8.0, 6.0), plate_color)
	draw_circle(Vector2.ZERO, 7.0, core_outer)
	draw_circle(Vector2.ZERO, 4.0, core_inner)
	draw_line(Vector2(-4.0, 9.0), Vector2(-9.0, 12.0), Color(0.952941, 0.694118, 0.356863, 0.85), 2.0)
	draw_line(Vector2(4.0, 9.0), Vector2(9.0, 12.0), Color(0.952941, 0.694118, 0.356863, 0.85), 2.0)
	draw_line(Vector2(-4.0, -9.0), Vector2(-5.0, -14.0), Color(0.952941, 0.694118, 0.356863, 0.85), 2.0)
	draw_line(Vector2(4.0, -9.0), Vector2(5.0, -14.0), Color(0.952941, 0.694118, 0.356863, 0.85), 2.0)

	if frame == 4:
		draw_circle(Vector2.ZERO, 10.0, Color(0.984314, 0.898039, 0.627451, 0.16))


func _update_visual() -> void:
	if not _using_sheet_visual():
		return

	visual.region_rect = Rect2(_get_visual_frame() * SHEET_FRAME_SIZE.x, 0.0, SHEET_FRAME_SIZE.x, SHEET_FRAME_SIZE.y)
	var bob := sin(_anim_time * 5.4) * 0.65
	var x_scale := 1.0
	var y_scale := 1.0
	var tilt := sin(_anim_time * 3.7) * 0.04
	if _contact_disabled_timer > 0.0:
		x_scale = 0.92
		y_scale = 1.08
		tilt = sin(_anim_time * 22.0) * 0.12
	else:
		var pulse := sin(_anim_time * 6.4) * 0.04
		x_scale = 1.0 - pulse
		y_scale = 1.0 + pulse

	visual.position = Vector2(0.0, -1.0 + bob)
	visual.scale = Vector2(x_scale, y_scale)
	visual.rotation = tilt
	visual.self_modulate = Color(1.0, 0.94, 0.86, 1.0) if _contact_disabled_timer > 0.0 else Color(1.0, 1.0, 1.0, 1.0)


func _get_visual_frame() -> int:
	if _contact_disabled_timer > 0.0:
		return 5
	var cycle_index := int(floor(_anim_time * 7.0)) % ACTIVE_SEQUENCE.size()
	return int(ACTIVE_SEQUENCE[cycle_index])


func _using_sheet_visual() -> bool:
	return visual != null and visual.texture != null


func _ensure_visual_texture() -> void:
	if visual == null or visual.texture != null:
		return
	visual.texture = ExportArt.get_hazard_mine_texture()


func _explode() -> void:
	_exploded = true
	for node in get_tree().get_nodes_in_group("hazard"):
		if node == self or not is_instance_valid(node):
			continue
		if not node.has_method("take_hit"):
			continue
		if node.global_position.distance_to(global_position) > EXPLOSION_RADIUS:
			continue
		node.call("take_hit", EXPLOSION_DAMAGE, global_position, "blast")
