extends Node2D

const ExportArt = preload("res://scripts/export_art.gd")
const SpriteSheetLibrary = preload("res://scripts/sprite_sheet_library.gd")

@export var lifetime := 0.16

var heavy := false
var _time := 0.0
var _sheet_data := {}
var _duration := 0.16

@onready var visual: Sprite2D = $Visual


func setup(start_position: Vector2, is_heavy: bool) -> void:
	global_position = start_position
	heavy = is_heavy
	lifetime = 0.2 if heavy else 0.14
	_duration = lifetime
	_sheet_data = ExportArt.get_combat_fx_data()
	_ensure_texture()
	_update_visual()
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return
	_update_visual()
	queue_redraw()


func _draw() -> void:
	if visual != null and visual.texture != null:
		return
	var progress := clampf(_time / 0.2, 0.0, 1.0)
	var outer := lerpf(10.0, 28.0 if heavy else 20.0, progress)
	var inner := outer * 0.42
	var alpha := 1.0 - progress

	for index in range(6):
		var angle := TAU * float(index) / 6.0
		var start := Vector2(cos(angle), sin(angle)) * inner
		var finish := Vector2(cos(angle), sin(angle)) * outer
		draw_line(start, finish, Color(0.984314, 0.898039, 0.627451, alpha), 3.0 if heavy else 2.0)

	draw_circle(Vector2.ZERO, inner, Color(0.952941, 0.694118, 0.356863, alpha * 0.35))
	draw_circle(Vector2.ZERO, inner * 0.38, Color(0.286275, 0.831373, 0.898039, alpha * 0.8))


func _ensure_texture() -> void:
	if visual == null or visual.texture != null:
		return
	visual.texture = ExportArt.get_combat_fx_texture()


func _update_visual() -> void:
	if visual == null or visual.texture == null:
		return
	var tag_time := _time * (0.75 if heavy else 1.0)
	var frame := SpriteSheetLibrary.get_frame_for_time(_sheet_data, "hit_confirm", tag_time, true)
	visual.region_rect = SpriteSheetLibrary.get_frame_rect(_sheet_data, frame)
	var pulse := sin(_time * 24.0) * 0.06
	var scale_multiplier := (1.45 if heavy else 1.2) + pulse
	visual.scale = Vector2.ONE * scale_multiplier
	var alpha := 1.0 - clampf(_time / maxf(_duration, 0.001), 0.0, 1.0) * 0.3
	visual.self_modulate = Color(1.0, 1.0, 1.0, alpha)
