extends Node2D

const ExportArt = preload("res://scripts/export_art.gd")
const SpriteSheetLibrary = preload("res://scripts/sprite_sheet_library.gd")

const DRONE_ANIM_SEQUENCE := [0, 1, 2, 3, 1, 2, 4, 2]
const MINE_ANIM_SEQUENCE := [0, 1, 2, 3, 4, 3, 2, 1]

var _player_sheet := {}
var _fx_sheet := {}
var _time := 0.0

@onready var dark_player: Sprite2D = $DarkPlayer
@onready var light_player: Sprite2D = $LightPlayer
@onready var slash_fx: Sprite2D = $SlashFx
@onready var drone_preview: Sprite2D = $DronePreview
@onready var mine_preview: Sprite2D = $MinePreview


func _ready() -> void:
	_player_sheet = ExportArt.get_player_sheet_data()
	_fx_sheet = ExportArt.get_combat_fx_data()
	_assign_texture(dark_player, ExportArt.get_player_skin_texture(SkinPalette.SKIN_NIGHT_QUEEN))
	_assign_texture(light_player, ExportArt.get_player_skin_texture(SkinPalette.SKIN_HIVE_RUNNER))
	_assign_texture(slash_fx, ExportArt.get_combat_fx_texture())
	_assign_texture(drone_preview, ExportArt.get_hazard_drone_texture())
	_assign_texture(mine_preview, ExportArt.get_hazard_mine_texture())
	_update_previews()


func _process(delta: float) -> void:
	_time += delta
	_update_previews()
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, 640.0, 360.0), Color8(13, 16, 22))
	draw_rect(Rect2(24.0, 32.0, 276.0, 260.0), Color8(21, 29, 41))
	draw_rect(Rect2(340.0, 32.0, 276.0, 260.0), Color8(66, 64, 88))
	draw_rect(Rect2(24.0, 228.0, 276.0, 18.0), Color8(48, 66, 86))
	draw_rect(Rect2(340.0, 228.0, 276.0, 18.0), Color8(110, 104, 124))
	draw_rect(Rect2(24.0, 228.0, 276.0, 3.0), Color8(244, 164, 87))
	draw_rect(Rect2(340.0, 228.0, 276.0, 3.0), Color8(245, 214, 176))
	draw_rect(Rect2(56.0, 84.0, 40.0, 104.0), Color8(31, 44, 58))
	draw_rect(Rect2(94.0, 64.0, 18.0, 124.0), Color8(25, 34, 45))
	draw_rect(Rect2(510.0, 74.0, 28.0, 120.0), Color8(138, 130, 154))
	draw_rect(Rect2(466.0, 92.0, 22.0, 102.0), Color8(119, 112, 136))


func _update_previews() -> void:
	_apply_player_preview(dark_player, _resolve_player_tag(_time), _time)
	_apply_player_preview(light_player, "blade_ground", fposmod(_time, SpriteSheetLibrary.get_tag_total_duration(_player_sheet, "blade_ground", 0.16)))
	var fx_time := fposmod(_time, SpriteSheetLibrary.get_tag_total_duration(_fx_sheet, "ground_slash", 0.12))
	var fx_frame := SpriteSheetLibrary.get_frame_for_time(_fx_sheet, "ground_slash", fx_time)
	slash_fx.region_rect = SpriteSheetLibrary.get_frame_rect(_fx_sheet, fx_frame)
	var drone_index := int(floor(_time * 10.0)) % DRONE_ANIM_SEQUENCE.size()
	drone_preview.region_rect = Rect2(float(DRONE_ANIM_SEQUENCE[drone_index]) * 32.0, 0.0, 32.0, 32.0)
	var mine_index := int(floor(_time * 7.0)) % MINE_ANIM_SEQUENCE.size()
	mine_preview.region_rect = Rect2(float(MINE_ANIM_SEQUENCE[mine_index]) * 32.0, 0.0, 32.0, 32.0)


func _apply_player_preview(sprite: Sprite2D, tag_name: String, elapsed: float) -> void:
	var frame := SpriteSheetLibrary.get_frame_for_time(_player_sheet, tag_name, elapsed, tag_name in ["blade_ground", "blade_air"])
	sprite.region_rect = SpriteSheetLibrary.get_frame_rect(_player_sheet, frame)


func _resolve_player_tag(time_value: float) -> String:
	var phase := fposmod(time_value, 3.8)
	if phase < 0.8:
		return "idle"
	if phase < 1.8:
		return "run"
	if phase < 2.3:
		return "burst_loop"
	if phase < 2.9:
		return "wall_slide"
	return "blade_air"


func _assign_texture(sprite: Sprite2D, texture: Texture2D) -> void:
	if sprite == null:
		return
	sprite.texture = texture
