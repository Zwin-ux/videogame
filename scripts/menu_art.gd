extends RefCounted
class_name MenuArt

const ExportArt = preload("res://scripts/export_art.gd")
const CONSOLE_LOGO_PATH := "res://art/export/menu_console_logo.png"
const PLANET_BASE_PATH := "res://art/export/menu_planet_base.png"
const INFESTATION_PATHS := [
	"res://art/export/menu_planet_infest_0.png",
	"res://art/export/menu_planet_infest_1.png",
	"res://art/export/menu_planet_infest_2.png",
	"res://art/export/menu_planet_infest_3.png",
]
const SWARM_SHEET_PATH := "res://art/export/menu_swarm_sheet.png"
const QUEEN_SHEET_PATH := "res://art/export/menu_queen_sheet.png"
const COCKPIT_OVERLAY_PATH := "res://art/export/menu_cockpit_overlay.png"
const CONSOLE_ATLAS_PATH := "res://art/export/menu_console_atlas.png"
const CURSOR_PATH := "res://art/export/menu_console_cursor.png"

var _cache: Dictionary = {}


func load_title_background() -> Texture2D:
	return ExportArt.get_title_background()


func load_title_hero() -> Texture2D:
	return ExportArt.get_title_hero()


func load_title_emblem() -> Texture2D:
	return ExportArt.get_title_emblem()


func load_title_cursor() -> Texture2D:
	return ExportArt.get_title_cursor()


func load_console_logo() -> Texture2D:
	return _load_texture(CONSOLE_LOGO_PATH)


func load_planet_base() -> Texture2D:
	return _load_texture(PLANET_BASE_PATH)


func load_infestation_overlay(tier: int) -> Texture2D:
	var safe_tier := clampi(tier, 0, INFESTATION_PATHS.size() - 1)
	return _load_texture(String(INFESTATION_PATHS[safe_tier]))


func load_infestation_overlays() -> Array[Texture2D]:
	var textures: Array[Texture2D] = []
	for overlay_path in INFESTATION_PATHS:
		textures.append(_load_texture(String(overlay_path)))
	return textures


func load_swarm_sheet() -> Texture2D:
	return _load_texture(SWARM_SHEET_PATH)


func load_queen_sheet() -> Texture2D:
	return _load_texture(QUEEN_SHEET_PATH)


func load_cockpit_overlay() -> Texture2D:
	return _load_texture(COCKPIT_OVERLAY_PATH)


func load_console_atlas() -> Texture2D:
	return _load_texture(CONSOLE_ATLAS_PATH)


func load_cursor() -> Texture2D:
	return _load_texture(CURSOR_PATH)


func _load_texture(path: String) -> Texture2D:
	if _cache.has(path):
		return _cache[path] as Texture2D

	var texture := ExportArt.load_texture(path)
	_cache[path] = texture
	return texture
