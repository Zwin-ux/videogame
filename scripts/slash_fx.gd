extends Node2D

const ExportArt = preload("res://scripts/export_art.gd")
const SpriteSheetLibrary = preload("res://scripts/sprite_sheet_library.gd")

var _sheet_data := {}
var _elapsed := 0.0
var _tag_name := "ground_slash"
var _facing := 1
var _hold_on_last := true

@onready var visual: Sprite2D = $Visual


func _ready() -> void:
	_sheet_data = ExportArt.get_combat_fx_data()
	_ensure_texture()
	_update_visual()


func setup(start_position: Vector2, facing_dir: int, tag_name: String) -> void:
	global_position = start_position
	_facing = 1 if facing_dir >= 0 else -1
	_tag_name = tag_name
	_elapsed = 0.0
	_hold_on_last = true
	if visual != null:
		visual.flip_h = _facing < 0
	_update_visual()


func _process(delta: float) -> void:
	_elapsed += delta
	var total_duration := SpriteSheetLibrary.get_tag_total_duration(_sheet_data, _tag_name, 0.12)
	if _elapsed >= total_duration:
		queue_free()
		return
	_update_visual()


func _ensure_texture() -> void:
	if visual == null or visual.texture != null:
		return
	visual.texture = ExportArt.get_combat_fx_texture()


func _update_visual() -> void:
	if visual == null or visual.texture == null:
		queue_redraw()
		return
	if not SpriteSheetLibrary.has_tag(_sheet_data, _tag_name):
		return
	var frame_index := SpriteSheetLibrary.get_frame_for_time(_sheet_data, _tag_name, _elapsed, _hold_on_last)
	visual.region_rect = SpriteSheetLibrary.get_frame_rect(_sheet_data, frame_index)
	visual.flip_h = _facing < 0


func _draw() -> void:
	if visual != null and visual.texture != null:
		return
	var warm := Color(0.956863, 0.74902, 0.392157, 0.24)
	var cool := Color(0.521569, 0.92549, 0.968627, 0.5)
	if _tag_name == "air_slash":
		draw_arc(Vector2(8.0 * float(_facing), -10.0), 24.0, -1.8 if _facing > 0 else PI - 0.4, 0.2 if _facing > 0 else PI + 1.8, 10, warm, 4.0)
		draw_arc(Vector2(10.0 * float(_facing), -10.0), 18.0, -1.7 if _facing > 0 else PI - 0.3, 0.15 if _facing > 0 else PI + 1.7, 10, cool, 2.0)
	else:
		draw_arc(Vector2(8.0 * float(_facing), -2.0), 22.0, -1.2 if _facing > 0 else PI - 0.1, 0.7 if _facing > 0 else PI + 1.2, 10, warm, 4.0)
		draw_arc(Vector2(9.0 * float(_facing), -2.0), 17.0, -1.1 if _facing > 0 else PI - 0.05, 0.6 if _facing > 0 else PI + 1.1, 10, cool, 2.0)
