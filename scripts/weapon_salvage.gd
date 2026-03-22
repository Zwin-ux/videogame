extends Area2D

const ExportArt = preload("res://scripts/export_art.gd")
signal collected(mode: String)

const WEAPON_BLADE := "blade"
const WEAPON_GUN := "gun"

var weapon_mode := WEAPON_GUN
var _home_position := Vector2.ZERO
var _time := 0.0
var _velocity := Vector2.ZERO
var _spin_speed := 0.0
var _settled := false
var _blade_texture: Texture2D
var _gun_texture: Texture2D

@onready var visual: Sprite2D = $Visual


func _ready() -> void:
	_home_position = position
	body_entered.connect(_on_body_entered)
	_ensure_visual()
	_update_visual()
	queue_redraw()


func configure(config: Dictionary) -> void:
	weapon_mode = String(config.get("weapon_mode", weapon_mode))
	if config.has("pos"):
		global_position = config["pos"]
	_home_position = position
	_velocity = Vector2(48.0 if weapon_mode == WEAPON_GUN else -48.0, -192.0)
	_spin_speed = 9.2 if weapon_mode == WEAPON_GUN else -9.2
	_settled = false
	rotation = 0.0
	_update_visual()
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	if not _settled:
		_velocity.y += 420.0 * delta
		position += _velocity * delta
		rotation += _spin_speed * delta
		_spin_speed = move_toward(_spin_speed, 0.0, 16.0 * delta)
		if position.y >= _home_position.y and _velocity.y > 0.0:
			position = _home_position
			_velocity = Vector2.ZERO
			_spin_speed = 0.0
			_settled = true
			rotation = 0.0
	else:
		position.y = _home_position.y + sin(_time * 2.6) * 6.0
	_update_visual()
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if body != null and body.is_in_group("player"):
		emit_signal("collected", weapon_mode)
		queue_free()


func _draw() -> void:
	var pulse := 0.72 + sin(_time * 4.8) * 0.12
	draw_circle(Vector2.ZERO, 16.0, Color(0.0, 0.0, 0.0, 0.16))
	draw_circle(Vector2.ZERO, 12.0, Color(0.070588, 0.094118, 0.117647, 1.0))
	draw_circle(Vector2.ZERO, 10.0, Color(0.152941, 0.176471, 0.207843, 1.0))
	draw_circle(Vector2.ZERO, 6.0, Color(0.952941, 0.643137, 0.341176, 0.22 + pulse * 0.16))
	draw_rect(Rect2(-14.0, -2.0, 28.0, 3.0), Color(0.94902, 0.862745, 0.611765, 0.28))

	if visual == null or visual.texture == null:
		if weapon_mode == WEAPON_BLADE:
			draw_rect(Rect2(-3.0, -12.0, 6.0, 15.0), Color(0.952941, 0.694118, 0.356863, 1.0))
			draw_polyline(
				PackedVector2Array([Vector2(-12.0, 6.0), Vector2(0.0, -12.0), Vector2(12.0, -4.0)]),
				Color(0.956863, 0.937255, 0.819608, 1.0),
				4.0
			)
			draw_polyline(
				PackedVector2Array([Vector2(-10.0, 7.0), Vector2(-1.0, -8.0), Vector2(10.0, -2.0)]),
				Color(0.286275, 0.831373, 0.898039, 0.92),
				2.0
			)
		else:
			draw_rect(Rect2(-12.0, -8.0, 24.0, 8.0), Color(0.952941, 0.694118, 0.356863, 1.0))
			draw_rect(Rect2(-16.0, 0.0, 32.0, 6.0), Color(0.239216, 0.301961, 0.360784, 1.0))
			draw_line(Vector2(-15.0, 2.0), Vector2(14.0, -5.0), Color(0.286275, 0.831373, 0.898039, 0.92), 3.0)

	draw_line(Vector2(-10.0, -11.0), Vector2(12.0, 10.0), Color(0.94902, 0.862745, 0.611765, 0.66), 2.0)
	draw_line(Vector2(-14.0, 10.0), Vector2(-3.0, -5.0), Color(0.952941, 0.643137, 0.341176, 0.48), 2.0)


func _ensure_visual() -> void:
	if visual == null:
		return
	if _blade_texture == null:
		_blade_texture = ExportArt.get_weapon_salvage(WEAPON_BLADE)
	if _gun_texture == null:
		_gun_texture = ExportArt.get_weapon_salvage(WEAPON_GUN)
	visual.texture = _blade_texture if weapon_mode == WEAPON_BLADE else _gun_texture
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _update_visual() -> void:
	if visual == null:
		return
	if visual.texture == null:
		_ensure_visual()
	else:
		visual.texture = _blade_texture if weapon_mode == WEAPON_BLADE else _gun_texture
	if visual.texture == null:
		return
	visual.rotation = rotation
	visual.scale = Vector2.ONE * (1.0 + sin(_time * 4.8) * 0.03)
	visual.self_modulate = Color(1.0, 1.0, 1.0, 0.92 + sin(_time * 5.0) * 0.06)
