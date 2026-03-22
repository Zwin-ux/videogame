extends Control
class_name SkinPreview

const ExportArt = preload("res://scripts/export_art.gd")
const SpriteSheetLibrary = preload("res://scripts/sprite_sheet_library.gd")

const PREVIEW_LOOP_DURATION := 4.4

var _current_texture: Texture2D
var _sheet_data := {}
var _skin_id := SkinPalette.SKIN_HIVE_RUNNER
var _weapon_mode := "blade"
var _anim_time := 0.0
var _blade_showcase_texture: Texture2D
var _gun_showcase_texture: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)
	_load_sheet()
	_rebuild_texture()


func _process(delta: float) -> void:
	_anim_time += delta
	queue_redraw()


func set_skin_id(skin_id: String) -> void:
	_skin_id = SkinPalette.normalize_skin_id(skin_id)
	_rebuild_texture()


func set_weapon_mode(mode: String) -> void:
	_weapon_mode = mode
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, PixelUI.COLOR_INK)
	draw_rect(Rect2(1.0, 1.0, size.x - 2.0, size.y - 2.0), PixelUI.COLOR_SHADOW_BLUE)

	var pedestal := Rect2(18.0, size.y - 34.0, size.x - 36.0, 14.0)
	draw_rect(pedestal, PixelUI.COLOR_PANEL_DEEP)
	draw_rect(Rect2(pedestal.position.x, pedestal.position.y, pedestal.size.x, 2.0), PixelUI.COLOR_AMBER)
	draw_rect(Rect2(pedestal.position.x, pedestal.position.y + pedestal.size.y - 2.0, pedestal.size.x, 2.0), PixelUI.COLOR_BLACK)

	for index in range(5):
		var x := 24.0 + float(index) * 18.0
		draw_rect(Rect2(x, size.y - 18.0, 10.0, 3.0), Color(PixelUI.COLOR_TEAL.r, PixelUI.COLOR_TEAL.g, PixelUI.COLOR_TEAL.b, 0.18))

	if _current_texture == null:
		return

	var frame := _get_frame()
	var source_rect := SpriteSheetLibrary.get_frame_rect(_sheet_data, frame)
	var draw_scale := 5.0
	var destination := Rect2(Vector2(size.x * 0.5 - 80.0, size.y * 0.5 - 94.0), Vector2(32.0, 32.0) * draw_scale)
	draw_texture_rect_region(_current_texture, destination, source_rect, Color.WHITE)
	_draw_weapon_overlay(destination)


func _draw_weapon_overlay(destination: Rect2) -> void:
	var center := destination.position + destination.size * 0.5
	var facing := 1.0
	var showcase_texture := _gun_showcase_texture if _weapon_mode == "gun" else _blade_showcase_texture
	if showcase_texture != null:
		var source_size := showcase_texture.get_size()
		if source_size.x > 0.0 and source_size.y > 0.0:
			var scale_multiplier := 2.6 if _weapon_mode == "gun" else 2.3
			var draw_size := source_size * scale_multiplier
			var anchor := center + Vector2(54.0 * facing, -18.0 if _weapon_mode == "gun" else -20.0)
			var draw_rect_target := Rect2(anchor - Vector2(draw_size.x * 0.18, draw_size.y * 0.5), draw_size)
			draw_texture_rect(showcase_texture, draw_rect_target, false, Color(1.0, 1.0, 1.0, 0.98))
			return

	var fx_profile := SkinPalette.get_fx_profile(_skin_id)
	if _weapon_mode == "gun":
		var projectile_core: Color = fx_profile.get("projectile_core", PixelUI.COLOR_AMBER)
		var projectile_trail: Color = fx_profile.get("projectile_trail", PixelUI.COLOR_BONE)
		var muzzle_flash: Color = fx_profile.get("muzzle_flash", PixelUI.COLOR_AMBER)
		draw_rect(Rect2(center + Vector2(18.0 * facing, -10.0), Vector2(20.0, 6.0)), projectile_core)
		draw_rect(Rect2(center + Vector2(38.0 * facing, -8.0), Vector2(8.0, 4.0)), PixelUI.COLOR_BONE)
		var beam_start := center + Vector2(46.0 * facing, -7.0)
		var beam_end := beam_start + Vector2(78.0 * facing, -4.0)
		draw_line(beam_start, beam_end, projectile_trail, 5.0)
		draw_line(beam_start, beam_end + Vector2(8.0 * facing, 0.0), projectile_core, 2.0)
		draw_circle(beam_end + Vector2(4.0 * facing, -1.0), 5.0, Color(projectile_core.r, projectile_core.g, projectile_core.b, 0.86))
		draw_arc(beam_start, 12.0, -0.55, 0.4, 7, Color(muzzle_flash.r, muzzle_flash.g, muzzle_flash.b, 0.36), 3.0)
	else:
		var start := center + Vector2(14.0 * facing, -6.0)
		var mid := center + Vector2(38.0 * facing, -18.0)
		var tip := center + Vector2(58.0 * facing, -28.0)
		draw_line(start, mid, PixelUI.COLOR_BONE, 5.0)
		draw_line(mid, tip, PixelUI.COLOR_TEAL, 3.0)
		draw_arc(center + Vector2(8.0, -6.0), 36.0, -1.1, 0.55, 12, Color(PixelUI.COLOR_AMBER.r, PixelUI.COLOR_AMBER.g, PixelUI.COLOR_AMBER.b, 0.32), 4.0)


func _get_frame() -> int:
	var phase := fposmod(_anim_time, PREVIEW_LOOP_DURATION)
	if phase < 1.3:
		return SpriteSheetLibrary.get_frame_for_time(_sheet_data, "idle", _anim_time)
	if phase < 2.35:
		return SpriteSheetLibrary.get_frame_for_time(_sheet_data, "run", _anim_time)
	if phase < 3.05:
		return SpriteSheetLibrary.get_frame_for_time(_sheet_data, "idle", _anim_time)
	if phase < 3.75:
		return SpriteSheetLibrary.get_frame_for_time(_sheet_data, "burst_loop", _anim_time)
	return SpriteSheetLibrary.get_frame_for_time(_sheet_data, "idle", _anim_time)


func _load_sheet() -> void:
	if not _sheet_data.is_empty() and _blade_showcase_texture != null and _gun_showcase_texture != null:
		return
	_sheet_data = ExportArt.get_player_sheet_data()
	_blade_showcase_texture = ExportArt.get_weapon_showcase("blade")
	_gun_showcase_texture = ExportArt.get_weapon_showcase("gun")


func _rebuild_texture() -> void:
	_load_sheet()
	_current_texture = ExportArt.get_player_skin_texture(_skin_id)
	queue_redraw()
