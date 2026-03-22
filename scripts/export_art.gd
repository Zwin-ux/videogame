extends RefCounted
class_name ExportArt

const SpriteSheetLibrary = preload("res://scripts/sprite_sheet_library.gd")

const TITLE_MENU_BG_PATH := "res://art/export/title_menu_bg.png"
const TITLE_MENU_HERO_PATH := "res://art/export/title_menu_hero.png"
const TITLE_MENU_EMBLEM_PATH := "res://art/export/title_menu_emblem.png"
const TITLE_MENU_CURSOR_PATH := "res://art/export/title_menu_cursor.png"
const WEAPON_ICON_BLADE_PATH := "res://art/export/weapon_icon_fang.png"
const WEAPON_ICON_GUN_PATH := "res://art/export/weapon_icon_blaster.png"
const WEAPON_SHOWCASE_BLADE_PATH := "res://art/export/weapon_showcase_fang.png"
const WEAPON_SHOWCASE_GUN_PATH := "res://art/export/weapon_showcase_blaster.png"
const WEAPON_SALVAGE_BLADE_PATH := "res://art/export/weapon_salvage_blade.png"
const WEAPON_SALVAGE_GUN_PATH := "res://art/export/weapon_salvage_blaster.png"
const PLAYER_SHEET_PATH := "res://art/export/player_sheet.png"
const PLAYER_SHEET_DATA_PATH := "res://art/export/player_sheet.json"
const COMBAT_FX_SHEET_PATH := "res://art/export/combat_fx_sheet.png"
const COMBAT_FX_DATA_PATH := "res://art/export/combat_fx_sheet.json"
const RIVAL_BOSS_SHEET_PATH := "res://art/export/rival_boss_sheet.png"
const HAZARD_DRONE_SHEET_PATH := "res://art/export/hazard_drone_sheet.png"
const HAZARD_MINE_SHEET_PATH := "res://art/export/hazard_mine_sheet.png"

const WEAPON_BLADE := "blade"
const WEAPON_GUN := "gun"

static var _texture_cache: Dictionary = {}
static var _image_cache: Dictionary = {}
static var _player_skin_texture_cache: Dictionary = {}


static func get_title_background() -> Texture2D:
	return load_texture(TITLE_MENU_BG_PATH)


static func get_title_hero() -> Texture2D:
	return load_texture(TITLE_MENU_HERO_PATH)


static func get_title_emblem() -> Texture2D:
	return load_texture(TITLE_MENU_EMBLEM_PATH)


static func get_title_cursor() -> Texture2D:
	return load_texture(TITLE_MENU_CURSOR_PATH)


static func get_weapon_icon(mode: String) -> Texture2D:
	return load_texture(WEAPON_ICON_BLADE_PATH if _normalize_weapon_mode(mode) == WEAPON_BLADE else WEAPON_ICON_GUN_PATH)


static func get_weapon_showcase(mode: String) -> Texture2D:
	return load_texture(WEAPON_SHOWCASE_BLADE_PATH if _normalize_weapon_mode(mode) == WEAPON_BLADE else WEAPON_SHOWCASE_GUN_PATH)


static func get_weapon_salvage(mode: String) -> Texture2D:
	return load_texture(WEAPON_SALVAGE_BLADE_PATH if _normalize_weapon_mode(mode) == WEAPON_BLADE else WEAPON_SALVAGE_GUN_PATH)


static func get_player_sheet_image() -> Image:
	return load_image(PLAYER_SHEET_PATH)


static func get_player_skin_texture(skin_id: String) -> Texture2D:
	var normalized_skin := SkinPalette.normalize_skin_id(skin_id)
	var cache_key := "player_skin:%s" % normalized_skin
	if _player_skin_texture_cache.has(cache_key):
		return _player_skin_texture_cache[cache_key] as Texture2D

	var source_image := get_player_sheet_image()
	if source_image == null:
		return null

	var recolored := SkinPalette.apply_to_image(source_image, normalized_skin)
	var texture := ImageTexture.create_from_image(recolored)
	_player_skin_texture_cache[cache_key] = texture
	return texture


static func get_player_sheet_data() -> Dictionary:
	return SpriteSheetLibrary.load_sheet(PLAYER_SHEET_DATA_PATH)


static func get_combat_fx_texture() -> Texture2D:
	return load_texture(COMBAT_FX_SHEET_PATH)


static func get_combat_fx_data() -> Dictionary:
	return SpriteSheetLibrary.load_sheet(COMBAT_FX_DATA_PATH)


static func get_rival_boss_texture() -> Texture2D:
	return load_texture(RIVAL_BOSS_SHEET_PATH)


static func get_hazard_drone_texture() -> Texture2D:
	return load_texture(HAZARD_DRONE_SHEET_PATH)


static func get_hazard_mine_texture() -> Texture2D:
	return load_texture(HAZARD_MINE_SHEET_PATH)


static func load_texture(path: String) -> Texture2D:
	if _texture_cache.has(path):
		return _texture_cache[path] as Texture2D

	var texture: Texture2D = null
	if ResourceLoader.exists(path):
		texture = load(path) as Texture2D
	if texture == null:
		var image := load_image(path)
		if image != null:
			texture = ImageTexture.create_from_image(image)

	_texture_cache[path] = texture
	return texture


static func load_image(path: String) -> Image:
	if _image_cache.has(path):
		var cached: Variant = _image_cache[path]
		return (cached as Image).duplicate() if cached is Image else null

	var image: Image = null
	var absolute_path := ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(absolute_path):
		image = Image.load_from_file(absolute_path)
		if image != null and image.is_empty():
			image = null
	elif ResourceLoader.exists(path):
		var texture := load(path) as Texture2D
		if texture != null:
			image = texture.get_image()
			if image != null and image.is_empty():
				image = null

	_image_cache[path] = image
	return image.duplicate() if image != null else null


static func clear_cache() -> void:
	_texture_cache.clear()
	_image_cache.clear()
	_player_skin_texture_cache.clear()
	SpriteSheetLibrary.clear_cache()


static func _normalize_weapon_mode(mode: String) -> String:
	return WEAPON_BLADE if mode == WEAPON_BLADE else WEAPON_GUN
