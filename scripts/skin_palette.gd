extends RefCounted
class_name SkinPalette

const SKIN_HIVE_RUNNER := "hive_runner"
const SKIN_LEGION := "legion"
const SKIN_BLUE_SQUADRON := "blue_squadron"
const SKIN_NIGHT_QUEEN := "night_queen"

const COLOR_BODY := Color8(216, 199, 162)
const COLOR_HIGHLIGHT := Color8(245, 241, 214)
const COLOR_NOZZLE := Color8(50, 72, 90)
const COLOR_BOOT := Color8(36, 48, 60)
const COLOR_TRIM := Color8(73, 212, 229)
const DEFAULT_PROJECTILE_CORE := Color8(245, 178, 86)
const DEFAULT_PROJECTILE_TRAIL := Color8(255, 225, 154)
const DEFAULT_PROJECTILE_GLOW := Color8(255, 206, 120)
const DEFAULT_MUZZLE_FLASH := Color8(255, 233, 138)
const BLUE_PROJECTILE_CORE := Color8(255, 92, 92)
const BLUE_PROJECTILE_TRAIL := Color8(255, 160, 150)
const BLUE_PROJECTILE_GLOW := Color8(255, 118, 118)
const BLUE_MUZZLE_FLASH := Color8(255, 196, 182)

const BASE_PALETTES := {
	SKIN_HIVE_RUNNER: {
		"body": Color8(216, 199, 162),
		"highlight": Color8(245, 241, 214),
		"nozzle": Color8(50, 72, 90),
		"boot": Color8(36, 48, 60),
		"trim": Color8(73, 212, 229),
	},
	SKIN_LEGION: {
		"body": Color8(229, 234, 242),
		"highlight": Color8(252, 253, 255),
		"nozzle": Color8(74, 102, 148),
		"boot": Color8(31, 47, 73),
		"trim": Color8(83, 138, 236),
	},
	SKIN_NIGHT_QUEEN: {
		"body": Color8(92, 89, 110),
		"highlight": Color8(216, 226, 232),
		"nozzle": Color8(29, 24, 42),
		"boot": Color8(13, 13, 22),
		"trim": Color8(115, 239, 211),
	},
}

const FX_PROFILES := {
	SKIN_HIVE_RUNNER: {
		"projectile_core": DEFAULT_PROJECTILE_CORE,
		"projectile_trail": DEFAULT_PROJECTILE_TRAIL,
		"projectile_glow": DEFAULT_PROJECTILE_GLOW,
		"muzzle_flash": DEFAULT_MUZZLE_FLASH,
	},
	SKIN_LEGION: {
		"projectile_core": BLUE_PROJECTILE_CORE,
		"projectile_trail": BLUE_PROJECTILE_TRAIL,
		"projectile_glow": BLUE_PROJECTILE_GLOW,
		"muzzle_flash": BLUE_MUZZLE_FLASH,
	},
	SKIN_NIGHT_QUEEN: {
		"projectile_core": DEFAULT_PROJECTILE_CORE,
		"projectile_trail": DEFAULT_PROJECTILE_TRAIL,
		"projectile_glow": DEFAULT_PROJECTILE_GLOW,
		"muzzle_flash": DEFAULT_MUZZLE_FLASH,
	},
}


static func normalize_skin_id(skin_id: String) -> String:
	if skin_id == SKIN_BLUE_SQUADRON:
		return SKIN_LEGION
	if BASE_PALETTES.has(skin_id):
		return skin_id
	return SKIN_HIVE_RUNNER


static func get_palette(skin_id: String) -> Dictionary:
	return BASE_PALETTES[normalize_skin_id(skin_id)]


static func get_fx_profile(skin_id: String) -> Dictionary:
	return FX_PROFILES[normalize_skin_id(skin_id)].duplicate(true)


static func apply_to_image(source_image: Image, skin_id: String) -> Image:
	var image := source_image.duplicate()
	var palette := get_palette(skin_id)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color: Color = image.get_pixel(x, y)
			if color.a <= 0.0:
				continue
			var mapped := map_color(color, palette)
			if mapped != color:
				image.set_pixel(x, y, mapped)
	return image


static func map_color(color: Color, palette: Dictionary) -> Color:
	if color.is_equal_approx(COLOR_BODY):
		return palette["body"]
	if color.is_equal_approx(COLOR_HIGHLIGHT):
		return palette["highlight"]
	if color.is_equal_approx(COLOR_NOZZLE):
		return palette["nozzle"]
	if color.is_equal_approx(COLOR_BOOT):
		return palette["boot"]
	if color.is_equal_approx(COLOR_TRIM):
		return palette["trim"]
	return color
