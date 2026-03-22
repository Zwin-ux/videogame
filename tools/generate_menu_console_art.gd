extends SceneTree

const EXPORT_DIR := "res://art/export"

const LOGO_PATH := "res://art/export/menu_console_logo.png"
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
const ATLAS_PATH := "res://art/export/menu_console_atlas.png"
const CURSOR_PATH := "res://art/export/menu_console_cursor.png"

const SCENE_SIZE := Vector2i(320, 180)
const LOGO_SIZE := Vector2i(208, 56)
const SWARM_FRAME_SIZE := Vector2i(32, 32)
const SWARM_FRAME_COUNT := 4
const QUEEN_FRAME_SIZE := Vector2i(96, 96)
const QUEEN_FRAME_COUNT := 4
const ICON_FRAME_SIZE := Vector2i(16, 16)
const ICON_ROWS := 4
const CURSOR_SIZE := Vector2i(24, 24)
const QUEEN_WING_LIFTS := [0, -2, 1, -1]
const QUEEN_PULSES := [0, 2, 4, 1]

const SPACE_DEEP := Color8(3, 7, 15, 255)
const SPACE_MID := Color8(7, 18, 34, 255)
const SPACE_BLUE := Color8(20, 42, 64, 255)
const STAR := Color8(237, 246, 255, 255)
const CYAN := Color8(112, 243, 255, 255)
const CYAN_SOFT := Color8(112, 243, 255, 126)
const GOLD := Color8(255, 208, 112, 255)
const GOLD_DARK := Color8(219, 136, 53, 255)
const CREAM := Color8(245, 238, 206, 255)
const RED := Color8(255, 97, 83, 255)
const BUG_PURPLE := Color8(96, 40, 78, 255)
const BUG_FLESH := Color8(161, 75, 103, 255)
const BUG_DARK := Color8(27, 10, 21, 255)
const PLANET_BASE := Color8(45, 98, 112, 255)
const PLANET_LIGHT := Color8(111, 193, 201, 255)
const PLANET_DARK := Color8(18, 54, 68, 255)
const PLANET_RIM := Color8(182, 247, 255, 160)
const CLOUD := Color8(181, 234, 230, 72)
const METAL := Color8(17, 31, 53, 255)
const METAL_LIGHT := Color8(35, 61, 91, 255)
const METAL_SHADOW := Color8(9, 16, 29, 255)
const GLASS := Color8(140, 240, 255, 80)
const BLACK := Color8(0, 0, 0, 255)

const PIXEL_FONT := {
	"A": ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
	"E": ["11111", "10000", "10000", "11110", "10000", "10000", "11111"],
	"I": ["11111", "00100", "00100", "00100", "00100", "00100", "11111"],
	"K": ["10001", "10010", "10100", "11000", "10100", "10010", "10001"],
	"L": ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
	"N": ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
	"Q": ["01110", "10001", "10001", "10001", "10101", "10010", "01101"],
	"R": ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
	"U": ["10001", "10001", "10001", "10001", "10001", "10001", "01110"],
	" ": ["000", "000", "000", "000", "000", "000", "000"],
}


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EXPORT_DIR))
	_write_image(LOGO_PATH, _make_logo())
	_write_image(PLANET_BASE_PATH, _make_planet_base())
	for tier in range(INFESTATION_PATHS.size()):
		_write_image(String(INFESTATION_PATHS[tier]), _make_infestation_overlay(tier))
	_write_image(SWARM_SHEET_PATH, _make_swarm_sheet())
	_write_image(QUEEN_SHEET_PATH, _make_queen_sheet())
	_write_image(COCKPIT_OVERLAY_PATH, _make_cockpit_overlay())
	_write_image(ATLAS_PATH, _make_console_atlas())
	_write_image(CURSOR_PATH, _make_cursor())
	print("GENERATED menu console sprite pack")
	quit()


func _write_image(path: String, image: Image) -> void:
	var absolute_path := ProjectSettings.globalize_path(path)
	var error := image.save_png(absolute_path)
	if error != OK:
		push_error("Failed to write %s (%s)" % [path, error])
		quit(error)


func _make_logo() -> Image:
	var image := _new_image(LOGO_SIZE)
	_fill_rect(image, Rect2i(0, 10, LOGO_SIZE.x, 34), Color(METAL.r, METAL.g, METAL.b, 0.84))
	_fill_rect(image, Rect2i(4, 14, LOGO_SIZE.x - 8, 26), Color(METAL_SHADOW.r, METAL_SHADOW.g, METAL_SHADOW.b, 0.94))
	_rect_outline(image, Rect2i(0, 10, LOGO_SIZE.x, 34), GOLD)
	_rect_outline(image, Rect2i(4, 14, LOGO_SIZE.x - 8, 26), CYAN)
	_fill_rect(image, Rect2i(10, 18, 54, 2), CYAN)
	_fill_rect(image, Rect2i(LOGO_SIZE.x - 64, 18, 54, 2), CYAN)
	_fill_rect(image, Rect2i(10, 34, 54, 2), CYAN)
	_fill_rect(image, Rect2i(LOGO_SIZE.x - 64, 34, 54, 2), CYAN)
	_draw_word(image, "KILLER", Vector2i(16, 18), 2, CREAM, GOLD_DARK)
	_draw_word(image, "QUEEN", Vector2i(108, 18), 2, GOLD, GOLD_DARK)
	_draw_queen_crest(image, Vector2i(94, 18))
	return image


func _make_planet_base() -> Image:
	var image := _new_image(SCENE_SIZE)
	for y in range(SCENE_SIZE.y):
		var ratio := float(y) / float(SCENE_SIZE.y - 1)
		var row_color := SPACE_DEEP.lerp(SPACE_MID, minf(1.0, ratio * 1.2))
		_fill_rect(image, Rect2i(0, y, SCENE_SIZE.x, 1), row_color)
	for x in range(SCENE_SIZE.x):
		var haze := sin(float(x) * 0.032) * 0.02
		_fill_rect(image, Rect2i(x, 0, 1, 100), Color(SPACE_BLUE.r, SPACE_BLUE.g, SPACE_BLUE.b, 0.04 + haze))

	var rng := RandomNumberGenerator.new()
	rng.seed = 913778
	for index in range(168):
		var point := Vector2i(rng.randi_range(2, SCENE_SIZE.x - 3), rng.randi_range(2, 90))
		var color := STAR if index % 7 != 0 else CYAN
		_set_pixel_safe(image, point, color)
		if index % 5 == 0:
			_set_pixel_safe(image, point + Vector2i(1, 0), Color(color.r, color.g, color.b, 0.75))
		if index % 11 == 0:
			_set_pixel_safe(image, point + Vector2i(0, 1), Color(color.r, color.g, color.b, 0.45))

	var planet_center := Vector2i(236, 94)
	_fill_ellipse(image, Rect2i(162, 18, 148, 148), PLANET_RIM)
	_fill_ellipse(image, Rect2i(170, 24, 132, 132), PLANET_LIGHT)
	_fill_ellipse(image, Rect2i(176, 28, 120, 120), PLANET_BASE)
	_fill_ellipse(image, Rect2i(186, 36, 104, 104), PLANET_DARK)
	for band in range(5):
		var band_y := 54 + band * 14
		var band_width := 98 - band * 5
		_fill_rect(
			image,
			Rect2i(planet_center.x - band_width / 2, band_y, band_width, 6),
			Color(PLANET_BASE.r, PLANET_BASE.g, PLANET_BASE.b, 0.82)
		)
	_draw_planet_highlight(image, planet_center)
	_draw_space_station(image, Vector2i(22, 84))
	_draw_orbit_halo(image, planet_center)
	_circle_fill(image, Vector2i(118, 52), 8, Color(CREAM.r, CREAM.g, CREAM.b, 0.22))
	_circle_fill(image, Vector2i(118, 52), 5, Color(CREAM.r, CREAM.g, CREAM.b, 0.45))
	for scan_y in range(0, SCENE_SIZE.y, 4):
		_fill_rect(image, Rect2i(0, scan_y, SCENE_SIZE.x, 1), Color(CYAN.r, CYAN.g, CYAN.b, 0.035))
	return image


func _make_infestation_overlay(tier: int) -> Image:
	var image := _new_image(SCENE_SIZE)
	var planet_center := Vector2i(236, 94)
	match tier:
		0:
			_draw_surface_scars(image, planet_center, 6, 0.18)
			_draw_brood_ribbons(image, planet_center, 4, 0.16, false)
		1:
			_draw_surface_scars(image, planet_center, 10, 0.26)
			_draw_brood_ribbons(image, planet_center, 8, 0.28, false)
			_draw_orbit_clutter(image, planet_center, 6)
		2:
			_draw_surface_scars(image, planet_center, 16, 0.36)
			_draw_brood_ribbons(image, planet_center, 14, 0.4, true)
			_draw_orbit_clutter(image, planet_center, 10)
			_draw_surface_blooms(image, planet_center, 8)
		_:
			_draw_surface_scars(image, planet_center, 22, 0.52)
			_draw_brood_ribbons(image, planet_center, 20, 0.6, true)
			_draw_orbit_clutter(image, planet_center, 16)
			_draw_surface_blooms(image, planet_center, 14)
			_draw_sky_collapse(image)
	return image


func _make_swarm_sheet() -> Image:
	var image := _new_image(Vector2i(SWARM_FRAME_SIZE.x * SWARM_FRAME_COUNT, SWARM_FRAME_SIZE.y))
	for frame in range(SWARM_FRAME_COUNT):
		_draw_swarm_frame(image, frame)
	return image


func _make_queen_sheet() -> Image:
	var image := _new_image(Vector2i(QUEEN_FRAME_SIZE.x * QUEEN_FRAME_COUNT, QUEEN_FRAME_SIZE.y))
	for frame in range(QUEEN_FRAME_COUNT):
		_draw_queen_frame(image, frame)
	return image


func _make_cockpit_overlay() -> Image:
	var image := _new_image(SCENE_SIZE)
	_fill_rect(image, Rect2i(0, 0, SCENE_SIZE.x, 10), Color(BLACK.r, BLACK.g, BLACK.b, 0.7))
	_fill_rect(image, Rect2i(0, 0, 18, SCENE_SIZE.y), Color(BLACK.r, BLACK.g, BLACK.b, 0.62))
	_fill_rect(image, Rect2i(SCENE_SIZE.x - 18, 0, 18, SCENE_SIZE.y), Color(BLACK.r, BLACK.g, BLACK.b, 0.62))
	_fill_rect(image, Rect2i(0, 0, 72, 40), Color(BLACK.r, BLACK.g, BLACK.b, 0.44))
	_fill_rect(image, Rect2i(SCENE_SIZE.x - 72, 0, 72, 40), Color(BLACK.r, BLACK.g, BLACK.b, 0.44))
	_stroke_line(image, Vector2i(0, 36), Vector2i(54, 0), 3, Color(METAL_LIGHT.r, METAL_LIGHT.g, METAL_LIGHT.b, 0.85))
	_stroke_line(image, Vector2i(SCENE_SIZE.x, 36), Vector2i(SCENE_SIZE.x - 54, 0), 3, Color(METAL_LIGHT.r, METAL_LIGHT.g, METAL_LIGHT.b, 0.85))
	_stroke_line(image, Vector2i(20, 0), Vector2i(20, SCENE_SIZE.y), 2, Color(GLASS.r, GLASS.g, GLASS.b, 0.24))
	_stroke_line(image, Vector2i(SCENE_SIZE.x - 20, 0), Vector2i(SCENE_SIZE.x - 20, SCENE_SIZE.y), 2, Color(GLASS.r, GLASS.g, GLASS.b, 0.24))
	_fill_rect(image, Rect2i(26, 12, 82, 1), Color(GLASS.r, GLASS.g, GLASS.b, 0.38))
	_fill_rect(image, Rect2i(216, 18, 88, 1), Color(GLASS.r, GLASS.g, GLASS.b, 0.32))
	_stroke_line(image, Vector2i(54, 0), Vector2i(134, 54), 1, Color(CREAM.r, CREAM.g, CREAM.b, 0.15))
	_stroke_line(image, Vector2i(266, 0), Vector2i(184, 58), 1, Color(CREAM.r, CREAM.g, CREAM.b, 0.12))
	for x in [34, 116, 204, 286]:
		_fill_rect(image, Rect2i(x, 0, 5, 4), METAL_LIGHT)
		_fill_rect(image, Rect2i(x + 1, 1, 3, 2), GOLD)
	return image


func _make_console_atlas() -> Image:
	var image := _new_image(Vector2i(ICON_FRAME_SIZE.x * 8, ICON_FRAME_SIZE.y * ICON_ROWS))
	_draw_icon_contract(image, Vector2i(0, 0))
	_draw_icon_dossier(image, Vector2i(16, 0))
	_draw_icon_systems(image, Vector2i(32, 0))
	_draw_icon_quit(image, Vector2i(48, 0))
	_draw_icon_shell(image, Vector2i(64, 0))
	_draw_icon_weapon(image, Vector2i(80, 0))
	_draw_icon_back(image, Vector2i(96, 0))
	_draw_icon_signal(image, Vector2i(112, 0))
	for frame in range(4):
		_draw_shuttle(image, Vector2i(frame * 16, 16), frame)
		_draw_radar(image, Vector2i(frame * 16 + 64, 16), frame)
		_draw_beacon(image, Vector2i(frame * 16, 32), frame)
		_draw_brood_blight(image, Vector2i(frame * 16 + 64, 32), frame)
		_draw_queen_ping(image, Vector2i(frame * 16, 48), frame)
		_draw_bug_cluster(image, Vector2i(frame * 16 + 64, 48), frame)
	return image


func _make_cursor() -> Image:
	var image := _new_image(CURSOR_SIZE)
	_fill_rect(image, Rect2i(2, 2, 2, 14), CYAN)
	_fill_rect(image, Rect2i(4, 2, 2, 10), CYAN)
	_fill_rect(image, Rect2i(6, 4, 2, 6), CYAN)
	_fill_rect(image, Rect2i(8, 6, 2, 2), CYAN)
	_fill_rect(image, Rect2i(10, 12, 2, 8), GOLD)
	_fill_rect(image, Rect2i(12, 14, 2, 6), GOLD)
	_fill_rect(image, Rect2i(12, 10, 8, 2), CREAM)
	_fill_rect(image, Rect2i(14, 8, 2, 8), CREAM)
	_rect_outline(image, Rect2i(13, 9, 6, 6), CYAN)
	return image


func _draw_planet_highlight(image: Image, center: Vector2i) -> void:
	for offset in [
		Vector2i(-34, -18),
		Vector2i(-28, -10),
		Vector2i(-18, -4),
		Vector2i(-8, 8),
	]:
		_fill_ellipse(image, Rect2i(center.x + offset.x, center.y + offset.y, 18, 10), CLOUD)
	_fill_ellipse(image, Rect2i(center.x - 12, center.y - 44, 26, 14), Color(CLOUD.r, CLOUD.g, CLOUD.b, 0.52))


func _draw_space_station(image: Image, pos: Vector2i) -> void:
	_fill_rect(image, Rect2i(pos.x + 0, pos.y + 36, 142, 18), METAL_SHADOW)
	_fill_rect(image, Rect2i(pos.x + 20, pos.y + 28, 112, 18), METAL)
	_fill_rect(image, Rect2i(pos.x + 34, pos.y + 22, 84, 14), METAL_LIGHT)
	_fill_rect(image, Rect2i(pos.x + 48, pos.y + 14, 56, 10), METAL_SHADOW)
	_fill_rect(image, Rect2i(pos.x + 62, pos.y + 4, 28, 10), METAL)
	for lamp in range(5):
		var lamp_x := pos.x + 26 + lamp * 20
		_fill_rect(image, Rect2i(lamp_x, pos.y + 27, 3, 3), GOLD)
		_fill_rect(image, Rect2i(lamp_x - 1, pos.y + 30, 5, 2), Color(GOLD.r, GOLD.g, GOLD.b, 0.42))
	_fill_rect(image, Rect2i(pos.x + 76, pos.y, 4, 6), CYAN)


func _draw_orbit_halo(image: Image, center: Vector2i) -> void:
	for band in range(4):
		var radius := 54 + band * 10
		_circle_arc(image, center, radius, 2.8, 5.24, Color(CYAN.r, CYAN.g, CYAN.b, 0.14))
	_circle_arc(image, Vector2i(110, 72), 38, 0.3, 2.65, Color(CREAM.r, CREAM.g, CREAM.b, 0.12))


func _draw_surface_scars(image: Image, center: Vector2i, count: int, alpha_scale: float) -> void:
	for index in range(count):
		var x := center.x - 42 + (index * 9) % 80
		var y := center.y - 30 + ((index * 11) % 72)
		var width := 8 + index % 4
		_fill_rect(image, Rect2i(x, y, width, 2), Color(RED.r, RED.g, RED.b, 0.2 + alpha_scale))
		_fill_rect(image, Rect2i(x + 1, y + 2, maxi(3, width - 2), 1), Color(BUG_FLESH.r, BUG_FLESH.g, BUG_FLESH.b, 0.18 + alpha_scale * 0.65))


func _draw_brood_ribbons(image: Image, center: Vector2i, count: int, alpha_scale: float, dense: bool) -> void:
	for index in range(count):
		var start := Vector2i(center.x - 62 + (index * 7) % 108, center.y - 34 + (index * 13) % 78)
		var finish := start + Vector2i(14 + index % 10, -6 + index % 8)
		_stroke_line(image, start, finish, 2 if dense else 1, Color(BUG_PURPLE.r, BUG_PURPLE.g, BUG_PURPLE.b, 0.24 + alpha_scale))
		_stroke_line(image, start + Vector2i(1, 1), finish + Vector2i(2, 1), 1, Color(BUG_FLESH.r, BUG_FLESH.g, BUG_FLESH.b, 0.22 + alpha_scale * 0.6))
		if dense and index % 2 == 0:
			_draw_bug_sprite(image, start + Vector2i(index % 9, index % 6), 0)


func _draw_orbit_clutter(image: Image, center: Vector2i, count: int) -> void:
	for index in range(count):
		var x := center.x - 100 + (index * 21) % 156
		var y := 26 + (index * 13) % 76
		_fill_rect(image, Rect2i(x, y, 5, 2), CYAN_SOFT)
		_fill_rect(image, Rect2i(x + 1, y - 1, 2, 1), GOLD)
		_fill_rect(image, Rect2i(x - 2, y + 2, 9, 1), Color(CYAN.r, CYAN.g, CYAN.b, 0.18))


func _draw_surface_blooms(image: Image, center: Vector2i, count: int) -> void:
	for index in range(count):
		var x := center.x - 46 + (index * 15) % 88
		var y := center.y - 26 + (index * 9) % 74
		_fill_ellipse(image, Rect2i(x, y, 10 + index % 8, 6 + index % 5), Color(BUG_FLESH.r, BUG_FLESH.g, BUG_FLESH.b, 0.28))
		_fill_rect(image, Rect2i(x + 2, y + 2, 4, 2), Color(RED.r, RED.g, RED.b, 0.4))


func _draw_sky_collapse(image: Image) -> void:
	for index in range(10):
		var x := 120 + index * 16
		_fill_rect(image, Rect2i(x, 12 + index % 5, 6, 28), Color(RED.r, RED.g, RED.b, 0.1 + index * 0.015))
		_stroke_line(image, Vector2i(x + 3, 10), Vector2i(x - 6, 52 + index * 2), 1, Color(CYAN.r, CYAN.g, CYAN.b, 0.08))


func _draw_swarm_frame(image: Image, frame: int) -> void:
	var frame_origin := Vector2i(frame * SWARM_FRAME_SIZE.x, 0)
	for bug_index in range(5):
		var offset := Vector2i(4 + bug_index * 5, 6 + ((bug_index + frame) * 3) % 16)
		_draw_bug_sprite(image, frame_origin + offset, frame + bug_index)
	var ribbon_color := Color(BUG_FLESH.r, BUG_FLESH.g, BUG_FLESH.b, 0.55)
	_stroke_line(image, frame_origin + Vector2i(4, 24 - frame), frame_origin + Vector2i(26, 6 + frame), 1, ribbon_color)


func _draw_queen_frame(image: Image, frame: int) -> void:
	var origin := Vector2i(frame * QUEEN_FRAME_SIZE.x, 0)
	var body := Color(BUG_DARK.r, BUG_DARK.g, BUG_DARK.b, 0.9)
	var rim := Color(BUG_FLESH.r, BUG_FLESH.g, BUG_FLESH.b, 0.24)
	var glow := Color(RED.r, RED.g, RED.b, 0.55)
	var wing_lift: int = QUEEN_WING_LIFTS[frame]
	var pulse: int = QUEEN_PULSES[frame]

	_fill_ellipse(image, Rect2i(origin.x + 32, 50 + pulse / 2, 36, 32 + pulse), body)
	_fill_ellipse(image, Rect2i(origin.x + 40, 34, 20, 24), body)
	_fill_rect(image, Rect2i(origin.x + 44, 18, 12, 16), body)
	_fill_rect(image, Rect2i(origin.x + 36, 14, 8, 10), body)
	_fill_rect(image, Rect2i(origin.x + 56, 14, 8, 10), body)
	_stroke_line(image, Vector2i(origin.x + 40, 24), Vector2i(origin.x + 28, 8), 3, body)
	_stroke_line(image, Vector2i(origin.x + 56, 24), Vector2i(origin.x + 68, 8), 3, body)
	_stroke_line(image, Vector2i(origin.x + 30, 44), Vector2i(origin.x + 10, 32 + wing_lift), 4, body)
	_stroke_line(image, Vector2i(origin.x + 66, 44), Vector2i(origin.x + 86, 30 - wing_lift), 4, body)
	_stroke_line(image, Vector2i(origin.x + 24, 48), Vector2i(origin.x + 6, 60 + wing_lift), 3, body)
	_stroke_line(image, Vector2i(origin.x + 72, 48), Vector2i(origin.x + 90, 58 - wing_lift), 3, body)
	_stroke_line(image, Vector2i(origin.x + 44, 82), Vector2i(origin.x + 36, 94), 2, body)
	_stroke_line(image, Vector2i(origin.x + 56, 82), Vector2i(origin.x + 62, 95), 2, body)
	_stroke_line(image, Vector2i(origin.x + 50, 80), Vector2i(origin.x + 48, 95), 2, body)
	_fill_rect(image, Rect2i(origin.x + 44, 28, 4, 2), glow)
	_fill_rect(image, Rect2i(origin.x + 50, 28, 4, 2), glow)
	_stroke_line(image, Vector2i(origin.x + 30, 44), Vector2i(origin.x + 10, 32 + wing_lift), 1, rim)
	_stroke_line(image, Vector2i(origin.x + 66, 44), Vector2i(origin.x + 86, 30 - wing_lift), 1, rim)
	_fill_ellipse(image, Rect2i(origin.x + 34, 58, 32, 20), rim)
	for bug_index in range(4):
		_draw_bug_sprite(image, origin + Vector2i(12 + bug_index * 18, 84 + (bug_index + frame) % 5), frame + bug_index)


func _draw_word(image: Image, text: String, start: Vector2i, scale: int, fill_color: Color, shadow_color: Color) -> void:
	var cursor := start
	for index in range(text.length()):
		var letter := text[index]
		var glyph: Array = PIXEL_FONT.get(letter, PIXEL_FONT[" "])
		_draw_glyph(image, glyph, cursor + Vector2i(1, 1), scale, shadow_color)
		_draw_glyph(image, glyph, cursor, scale, fill_color)
		cursor.x += (glyph[0].length() + 1) * scale


func _draw_glyph(image: Image, glyph: Array, start: Vector2i, scale: int, color: Color) -> void:
	for row in range(glyph.size()):
		var line: String = glyph[row]
		for column in range(line.length()):
			if line[column] == "1":
				_fill_rect(image, Rect2i(start.x + column * scale, start.y + row * scale, scale, scale), color)


func _draw_queen_crest(image: Image, pos: Vector2i) -> void:
	_fill_rect(image, Rect2i(pos.x + 2, pos.y + 4, 8, 12), GOLD)
	_fill_rect(image, Rect2i(pos.x + 4, pos.y + 6, 4, 8), CREAM)
	_stroke_line(image, Vector2i(pos.x + 4, pos.y + 6), Vector2i(pos.x - 4, pos.y), 2, CYAN)
	_stroke_line(image, Vector2i(pos.x + 8, pos.y + 6), Vector2i(pos.x + 16, pos.y), 2, CYAN)
	_fill_rect(image, Rect2i(pos.x + 4, pos.y + 1, 4, 4), RED)


func _draw_icon_contract(image: Image, origin: Vector2i) -> void:
	_rect_outline(image, Rect2i(origin.x + 2, origin.y + 2, 12, 12), CYAN)
	_fill_rect(image, Rect2i(origin.x + 7, origin.y + 4, 2, 8), GOLD)
	_fill_rect(image, Rect2i(origin.x + 4, origin.y + 7, 8, 2), GOLD)


func _draw_icon_dossier(image: Image, origin: Vector2i) -> void:
	_rect_outline(image, Rect2i(origin.x + 3, origin.y + 2, 10, 12), CYAN)
	_fill_rect(image, Rect2i(origin.x + 6, origin.y + 4, 4, 4), CREAM)
	_fill_rect(image, Rect2i(origin.x + 5, origin.y + 10, 6, 2), GOLD)


func _draw_icon_systems(image: Image, origin: Vector2i) -> void:
	_circle_fill(image, origin + Vector2i(8, 8), 5, CYAN)
	_circle_fill(image, origin + Vector2i(8, 8), 2, METAL)
	for spoke in [Vector2i(8, 1), Vector2i(8, 15), Vector2i(1, 8), Vector2i(15, 8)]:
		_set_pixel_safe(image, origin + spoke, GOLD)


func _draw_icon_quit(image: Image, origin: Vector2i) -> void:
	_rect_outline(image, Rect2i(origin.x + 3, origin.y + 2, 7, 12), CYAN)
	_fill_rect(image, Rect2i(origin.x + 8, origin.y + 7, 5, 2), GOLD)
	_set_pixel_safe(image, origin + Vector2i(13, 6), GOLD)
	_set_pixel_safe(image, origin + Vector2i(13, 9), GOLD)


func _draw_icon_shell(image: Image, origin: Vector2i) -> void:
	_fill_rect(image, Rect2i(origin.x + 5, origin.y + 3, 6, 4), GOLD)
	_fill_rect(image, Rect2i(origin.x + 4, origin.y + 7, 8, 5), CREAM)
	_fill_rect(image, Rect2i(origin.x + 3, origin.y + 12, 10, 2), CYAN)


func _draw_icon_weapon(image: Image, origin: Vector2i) -> void:
	_stroke_line(image, origin + Vector2i(3, 12), origin + Vector2i(12, 3), 2, CREAM)
	_fill_rect(image, Rect2i(origin.x + 2, origin.y + 11, 4, 3), GOLD)
	_fill_rect(image, Rect2i(origin.x + 9, origin.y + 4, 4, 2), CYAN)


func _draw_icon_back(image: Image, origin: Vector2i) -> void:
	_stroke_line(image, origin + Vector2i(12, 4), origin + Vector2i(4, 8), 2, CYAN)
	_stroke_line(image, origin + Vector2i(4, 8), origin + Vector2i(12, 12), 2, CYAN)
	_fill_rect(image, Rect2i(origin.x + 2, origin.y + 7, 3, 2), GOLD)


func _draw_icon_signal(image: Image, origin: Vector2i) -> void:
	_circle_arc(image, origin + Vector2i(8, 8), 5, -1.1, 1.1, CYAN)
	_circle_arc(image, origin + Vector2i(8, 8), 2, -1.1, 1.1, GOLD)
	_circle_fill(image, origin + Vector2i(8, 8), 1, CREAM)


func _draw_shuttle(image: Image, origin: Vector2i, frame: int) -> void:
	_fill_rect(image, Rect2i(origin.x + 3, origin.y + 7, 9, 2), CREAM)
	_fill_rect(image, Rect2i(origin.x + 6, origin.y + 5, 3, 2), CYAN)
	var flame := 1 + frame % 3
	_fill_rect(image, Rect2i(origin.x + 1, origin.y + 8 - flame, 2, flame + 1), GOLD_DARK)
	_fill_rect(image, Rect2i(origin.x + 0, origin.y + 8 - flame + 1, 1, flame), GOLD)
	_set_pixel_safe(image, origin + Vector2i(12, 8), CYAN)


func _draw_radar(image: Image, origin: Vector2i, frame: int) -> void:
	var radius := 2 + frame
	_circle_arc(image, origin + Vector2i(8, 8), radius + 1, 0.0, TAU, Color(CYAN.r, CYAN.g, CYAN.b, 0.22))
	_circle_arc(image, origin + Vector2i(8, 8), radius + 4, 0.0, TAU, Color(CYAN.r, CYAN.g, CYAN.b, 0.12))
	_fill_rect(image, Rect2i(origin.x + 7, origin.y + 3, 2, 10), Color(CYAN.r, CYAN.g, CYAN.b, 0.16))
	_fill_rect(image, Rect2i(origin.x + 3, origin.y + 7, 10, 2), Color(CYAN.r, CYAN.g, CYAN.b, 0.16))
	_set_pixel_safe(image, origin + Vector2i(8 + frame, 5), GOLD)


func _draw_beacon(image: Image, origin: Vector2i, frame: int) -> void:
	_fill_rect(image, Rect2i(origin.x + 7, origin.y + 3, 2, 10), CYAN)
	_fill_rect(image, Rect2i(origin.x + 5, origin.y + 11, 6, 2), METAL_LIGHT)
	_fill_rect(image, Rect2i(origin.x + 6 - frame / 2, origin.y + 4, 4 + frame, 2), GOLD)


func _draw_brood_blight(image: Image, origin: Vector2i, frame: int) -> void:
	_fill_ellipse(image, Rect2i(origin.x + 3, origin.y + 4, 10, 8), Color(BUG_PURPLE.r, BUG_PURPLE.g, BUG_PURPLE.b, 0.8))
	_fill_ellipse(image, Rect2i(origin.x + 5 + frame % 2, origin.y + 6, 6, 4), Color(BUG_FLESH.r, BUG_FLESH.g, BUG_FLESH.b, 0.78))
	_set_pixel_safe(image, origin + Vector2i(8, 8), RED)


func _draw_queen_ping(image: Image, origin: Vector2i, frame: int) -> void:
	_circle_arc(image, origin + Vector2i(8, 8), 2 + frame, 0.0, TAU, Color(RED.r, RED.g, RED.b, 0.45))
	_circle_fill(image, origin + Vector2i(8, 8), 1, GOLD)
	_fill_rect(image, Rect2i(origin.x + 7, origin.y + 2, 2, 3), RED)


func _draw_bug_cluster(image: Image, origin: Vector2i, frame: int) -> void:
	for index in range(3):
		_draw_bug_sprite(image, origin + Vector2i(2 + index * 4, 5 + (frame + index) % 5), frame + index)


func _draw_bug_sprite(image: Image, origin: Vector2i, phase: int) -> void:
	var wing_offset := 1 if phase % 2 == 0 else 0
	var wing_color := Color(BUG_FLESH.r, BUG_FLESH.g, BUG_FLESH.b, 0.72)
	_fill_rect(image, Rect2i(origin.x + 2, origin.y + 3, 4, 3), BUG_DARK)
	_fill_rect(image, Rect2i(origin.x + 1, origin.y + 2 + wing_offset, 2, 2), wing_color)
	_fill_rect(image, Rect2i(origin.x + 5, origin.y + 2 + (1 - wing_offset), 2, 2), wing_color)
	_fill_rect(image, Rect2i(origin.x + 3, origin.y + 6, 2, 2), BUG_PURPLE)
	_set_pixel_safe(image, origin + Vector2i(5, 4), RED)


func _new_image(size: Vector2i) -> Image:
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	return image


func _fill_rect(image: Image, rect: Rect2i, color: Color) -> void:
	var clipped := rect.intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	if clipped.size.x <= 0 or clipped.size.y <= 0:
		return
	image.fill_rect(clipped, color)


func _fill_ellipse(image: Image, rect: Rect2i, color: Color) -> void:
	var radius_x := rect.size.x * 0.5
	var radius_y := rect.size.y * 0.5
	if radius_x <= 0.0 or radius_y <= 0.0:
		return
	var center := Vector2(rect.position.x + radius_x, rect.position.y + radius_y)
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			var nx := (float(x) - center.x) / radius_x
			var ny := (float(y) - center.y) / radius_y
			if nx * nx + ny * ny <= 1.0:
				_set_pixel_safe(image, Vector2i(x, y), color)


func _stroke_line(image: Image, start: Vector2i, finish: Vector2i, width: int, color: Color) -> void:
	var dx := finish.x - start.x
	var dy := finish.y - start.y
	var steps := maxi(abs(dx), abs(dy))
	if steps <= 0:
		_fill_rect(image, Rect2i(start.x, start.y, width, width), color)
		return
	var offset := width / 2
	for step in range(steps + 1):
		var t := float(step) / float(steps)
		var x := int(round(lerpf(float(start.x), float(finish.x), t)))
		var y := int(round(lerpf(float(start.y), float(finish.y), t)))
		_fill_rect(image, Rect2i(x - offset, y - offset, width, width), color)


func _rect_outline(image: Image, rect: Rect2i, color: Color) -> void:
	_fill_rect(image, Rect2i(rect.position.x, rect.position.y, rect.size.x, 1), color)
	_fill_rect(image, Rect2i(rect.position.x, rect.position.y + rect.size.y - 1, rect.size.x, 1), color)
	_fill_rect(image, Rect2i(rect.position.x, rect.position.y, 1, rect.size.y), color)
	_fill_rect(image, Rect2i(rect.position.x + rect.size.x - 1, rect.position.y, 1, rect.size.y), color)


func _circle_fill(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for y in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			if x * x + y * y <= radius * radius:
				_set_pixel_safe(image, center + Vector2i(x, y), color)


func _circle_arc(image: Image, center: Vector2i, radius: int, start_angle: float, end_angle: float, color: Color) -> void:
	var steps := maxi(24, int(radius * 4))
	for step in range(steps + 1):
		var t := lerpf(start_angle, end_angle, float(step) / float(steps))
		var point := center + Vector2i(int(round(cos(t) * radius)), int(round(sin(t) * radius)))
		_set_pixel_safe(image, point, color)


func _set_pixel_safe(image: Image, point: Vector2i, color: Color) -> void:
	if point.x < 0 or point.y < 0 or point.x >= image.get_width() or point.y >= image.get_height():
		return
	image.set_pixelv(point, color)
