extends SceneTree

const EXPORT_DIR := "res://art/export"
const BG_SIZE := Vector2i(320, 180)
const HERO_SIZE := Vector2i(128, 164)
const EMBLEM_SIZE := Vector2i(64, 64)
const CURSOR_SIZE := Vector2i(18, 14)
const ICON_SIZE := Vector2i(32, 32)
const SHOWCASE_SIZE := Vector2i(96, 44)

const COLOR_SKY_TOP := Color("06101d")
const COLOR_SKY_MID := Color("18294b")
const COLOR_SKY_GLOW := Color("5d3f6d")
const COLOR_HORIZON := Color("d07358")
const COLOR_STAR := Color("f2f7ff")
const COLOR_MOUNTAIN_FAR := Color("1b2640")
const COLOR_MOUNTAIN_NEAR := Color("24324e")
const COLOR_CITY := Color("263c5f")
const COLOR_FOREGROUND := Color("0a111b")
const COLOR_PLATFORM := Color("1d2637")
const COLOR_PANEL := Color("ffcd6a")
const COLOR_PANEL_DARK := Color("946536")
const COLOR_ACCENT := Color("89f4ff")
const COLOR_CREAM := Color("f2ead0")
const COLOR_ARMOR := Color("d8c7a2")
const COLOR_ARMOR_SHADE := Color("8d6b45")
const COLOR_TRIM := Color("4bd0e5")
const COLOR_DARK_METAL := Color("101726")
const COLOR_MID_METAL := Color("273247")
const COLOR_GLOW_HOT := Color("ffd577")


func _init() -> void:
	var export_path := ProjectSettings.globalize_path(EXPORT_DIR)
	DirAccess.make_dir_recursive_absolute(export_path)
	_write_image("title_menu_bg.png", _make_background())
	_write_image("title_menu_hero.png", _make_title_hero())
	_write_image("title_menu_emblem.png", _make_emblem())
	_write_image("title_menu_cursor.png", _make_cursor())
	_write_image("weapon_icon_fang.png", _make_weapon_icon_fang())
	_write_image("weapon_icon_blaster.png", _make_weapon_icon_blaster())
	_write_image("weapon_showcase_fang.png", _make_weapon_showcase_fang())
	_write_image("weapon_showcase_blaster.png", _make_weapon_showcase_blaster())
	print("GENERATED presentation sprites")
	quit()


func _write_image(file_name: String, image: Image) -> void:
	var path := ProjectSettings.globalize_path("%s/%s" % [EXPORT_DIR, file_name])
	var error := image.save_png(path)
	if error != OK:
		push_error("Failed to write %s" % path)
		quit(error)


func _make_background() -> Image:
	var image := _new_image(BG_SIZE)
	_fill_rect(image, Rect2i(0, 0, BG_SIZE.x, 34), COLOR_SKY_TOP)
	_fill_rect(image, Rect2i(0, 34, BG_SIZE.x, 38), COLOR_SKY_MID)
	_fill_rect(image, Rect2i(0, 72, BG_SIZE.x, 28), COLOR_SKY_GLOW)
	_fill_rect(image, Rect2i(0, 100, BG_SIZE.x, 18), COLOR_HORIZON)
	_fill_rect(image, Rect2i(0, 118, BG_SIZE.x, BG_SIZE.y - 118), COLOR_FOREGROUND)

	for y in range(0, 110, 3):
		_fill_rect(image, Rect2i(0, y, BG_SIZE.x, 1), Color(1.0, 1.0, 1.0, 0.025))

	for point in [
		Vector2i(20, 18), Vector2i(48, 28), Vector2i(66, 14), Vector2i(84, 32),
		Vector2i(108, 20), Vector2i(134, 12), Vector2i(166, 30), Vector2i(202, 18),
		Vector2i(236, 26), Vector2i(272, 16), Vector2i(296, 12)
	]:
		_set_pixel_safe(image, point, COLOR_STAR)
		_set_pixel_safe(image, point + Vector2i(1, 0), COLOR_STAR.darkened(0.12))

	_draw_ridge(
		image,
		[
			Vector2i(0, 108),
			Vector2i(28, 98),
			Vector2i(64, 112),
			Vector2i(108, 92),
			Vector2i(156, 110),
			Vector2i(206, 86),
			Vector2i(246, 102),
			Vector2i(286, 84),
			Vector2i(319, 98),
		],
		122,
		COLOR_MOUNTAIN_FAR
	)
	_draw_ridge(
		image,
		[
			Vector2i(0, 118),
			Vector2i(38, 108),
			Vector2i(74, 124),
			Vector2i(122, 102),
			Vector2i(168, 118),
			Vector2i(214, 96),
			Vector2i(256, 114),
			Vector2i(319, 100),
		],
		132,
		COLOR_MOUNTAIN_NEAR
	)

	for tower_rect in [
		Rect2i(206, 78, 12, 44),
		Rect2i(226, 70, 14, 52),
		Rect2i(250, 82, 12, 40),
		Rect2i(272, 66, 18, 56),
		Rect2i(298, 76, 12, 46),
	]:
		_draw_tower(image, tower_rect)

	_fill_rect(image, Rect2i(0, 120, BG_SIZE.x, 10), COLOR_PLATFORM)
	_fill_rect(image, Rect2i(0, 130, BG_SIZE.x, 2), COLOR_PANEL_DARK.darkened(0.5))
	_fill_rect(image, Rect2i(0, 160, BG_SIZE.x, 4), COLOR_PANEL_DARK)
	for x in range(18, BG_SIZE.x, 28):
		_fill_rect(image, Rect2i(x, 164, 18, 3), COLOR_PANEL_DARK)
		_fill_rect(image, Rect2i(x + 3, 167, 12, 1), COLOR_ACCENT.darkened(0.5))

	_fill_rect(image, Rect2i(214, 120, 34, 44), Color("121c2d"))
	_fill_rect(image, Rect2i(254, 120, 30, 44), Color("10192a"))
	_fill_rect(image, Rect2i(282, 118, 20, 46), Color("0c1523"))
	_fill_rect(image, Rect2i(250, 118, 50, 6), COLOR_PLATFORM.lightened(0.1))

	return image


func _make_title_hero() -> Image:
	var image := _new_image(HERO_SIZE)
	var base := Vector2i(18, 20)

	_fill_ellipse(image, Rect2i(18, 134, 92, 18), Color(0.0, 0.0, 0.0, 0.18))

	_fill_rect(image, Rect2i(base.x + 28, base.y + 90, 18, 40), COLOR_DARK_METAL)
	_fill_rect(image, Rect2i(base.x + 54, base.y + 86, 20, 44), COLOR_DARK_METAL)
	_fill_rect(image, Rect2i(base.x + 28, base.y + 124, 24, 8), COLOR_PANEL_DARK)
	_fill_rect(image, Rect2i(base.x + 52, base.y + 124, 24, 8), COLOR_PANEL_DARK)
	_fill_rect(image, Rect2i(base.x + 28, base.y + 132, 28, 8), COLOR_MID_METAL)
	_fill_rect(image, Rect2i(base.x + 50, base.y + 132, 28, 8), COLOR_MID_METAL)

	_fill_rect(image, Rect2i(base.x + 24, base.y + 48, 54, 48), COLOR_ARMOR)
	_fill_rect(image, Rect2i(base.x + 20, base.y + 54, 10, 18), COLOR_ARMOR_SHADE)
	_fill_rect(image, Rect2i(base.x + 72, base.y + 56, 12, 22), COLOR_ARMOR_SHADE)
	_fill_rect(image, Rect2i(base.x + 32, base.y + 56, 38, 18), COLOR_CREAM)
	_fill_rect(image, Rect2i(base.x + 44, base.y + 70, 10, 16), COLOR_TRIM.darkened(0.18))
	_fill_rect(image, Rect2i(base.x + 38, base.y + 84, 28, 10), COLOR_ARMOR_SHADE)

	_fill_rect(image, Rect2i(base.x + 34, base.y + 24, 30, 26), COLOR_ARMOR)
	_fill_rect(image, Rect2i(base.x + 30, base.y + 28, 38, 10), COLOR_ARMOR_SHADE)
	_fill_rect(image, Rect2i(base.x + 40, base.y + 34, 18, 8), COLOR_CREAM)
	_fill_rect(image, Rect2i(base.x + 36, base.y + 40, 26, 8), COLOR_DARK_METAL)
	_fill_rect(image, Rect2i(base.x + 40, base.y + 42, 18, 4), COLOR_TRIM)

	_fill_rect(image, Rect2i(base.x + 16, base.y + 64, 14, 38), COLOR_DARK_METAL)
	_fill_rect(image, Rect2i(base.x + 72, base.y + 64, 12, 30), COLOR_DARK_METAL)
	_fill_rect(image, Rect2i(base.x + 80, base.y + 64, 20, 12), COLOR_MID_METAL)
	_fill_rect(image, Rect2i(base.x + 94, base.y + 60, 18, 8), COLOR_DARK_METAL)
	_fill_rect(image, Rect2i(base.x + 78, base.y + 60, 22, 4), COLOR_TRIM.darkened(0.22))
	_fill_rect(image, Rect2i(base.x + 88, base.y + 78, 14, 16), COLOR_MID_METAL)
	_fill_rect(image, Rect2i(base.x + 40, base.y + 92, 14, 20), COLOR_DARK_METAL)
	_fill_rect(image, Rect2i(base.x + 34, base.y + 106, 24, 8), COLOR_PANEL_DARK)

	_stroke_line(image, Vector2i(base.x + 30, base.y + 92), Vector2i(base.x + 16, base.y + 58), 8, COLOR_DARK_METAL)
	_stroke_line(image, Vector2i(base.x + 14, base.y + 54), Vector2i(base.x + 6, base.y + 24), 5, COLOR_DARK_METAL)
	_stroke_line(image, Vector2i(base.x + 32, base.y + 88), Vector2i(base.x + 18, base.y + 54), 3, COLOR_TRIM)
	_stroke_line(image, Vector2i(base.x + 10, base.y + 28), Vector2i(base.x - 8, base.y + 8), 2, COLOR_GLOW_HOT)

	_fill_rect(image, Rect2i(base.x + 14, base.y + 22, 6, 10), COLOR_PANEL_DARK)
	_fill_rect(image, Rect2i(base.x + 10, base.y + 18, 14, 6), COLOR_MID_METAL)

	_fill_rect(image, Rect2i(base.x + 18, base.y + 100, 8, 18), COLOR_TRIM.darkened(0.25))
	_fill_rect(image, Rect2i(base.x + 74, base.y + 96, 8, 18), COLOR_TRIM.darkened(0.25))
	_fill_rect(image, Rect2i(base.x + 20, base.y + 118, 8, 6), COLOR_GLOW_HOT)
	_fill_rect(image, Rect2i(base.x + 76, base.y + 114, 8, 6), COLOR_GLOW_HOT)

	_stroke_line(image, Vector2i(base.x + 60, base.y + 10), Vector2i(base.x + 72, base.y + 2), 2, COLOR_STAR)
	_stroke_line(image, Vector2i(base.x + 74, base.y + 12), Vector2i(base.x + 82, base.y + 8), 2, COLOR_ACCENT.darkened(0.2))

	return image


func _make_emblem() -> Image:
	var image := _new_image(EMBLEM_SIZE)
	_fill_rect(image, Rect2i(26, 6, 12, 6), COLOR_PANEL)
	_fill_rect(image, Rect2i(22, 12, 20, 6), COLOR_PANEL)
	_fill_rect(image, Rect2i(18, 18, 28, 6), COLOR_PANEL)
	_fill_rect(image, Rect2i(16, 24, 32, 8), COLOR_PANEL_DARK)
	_fill_rect(image, Rect2i(12, 32, 40, 10), COLOR_PANEL)
	_fill_rect(image, Rect2i(18, 42, 28, 8), COLOR_PANEL)
	_fill_rect(image, Rect2i(22, 50, 20, 8), COLOR_PANEL_DARK)
	_fill_rect(image, Rect2i(28, 58, 8, 4), COLOR_PANEL)
	_fill_rect(image, Rect2i(6, 28, 10, 6), COLOR_ACCENT.darkened(0.2))
	_fill_rect(image, Rect2i(48, 28, 10, 6), COLOR_ACCENT.darkened(0.2))
	_stroke_line(image, Vector2i(18, 18), Vector2i(45, 18), 1, COLOR_CREAM)
	_stroke_line(image, Vector2i(32, 18), Vector2i(32, 44), 1, COLOR_CREAM)
	return image


func _make_cursor() -> Image:
	var image := _new_image(CURSOR_SIZE)
	for x in range(1, 11):
		_set_pixel_safe(image, Vector2i(x, 7), COLOR_PANEL_DARK)
	for x in range(4, 15):
		_set_pixel_safe(image, Vector2i(x, 6), COLOR_PANEL)
		_set_pixel_safe(image, Vector2i(x, 8), COLOR_PANEL)
	for x in range(8, 17):
		_set_pixel_safe(image, Vector2i(x, 7), COLOR_PANEL)
	_fill_rect(image, Rect2i(2, 5, 5, 5), COLOR_ACCENT.darkened(0.2))
	_fill_rect(image, Rect2i(0, 6, 3, 3), COLOR_CREAM)
	_set_pixel_safe(image, Vector2i(16, 7), COLOR_CREAM)
	_set_pixel_safe(image, Vector2i(15, 6), COLOR_CREAM)
	_set_pixel_safe(image, Vector2i(15, 8), COLOR_CREAM)
	return image


func _make_weapon_icon_fang() -> Image:
	var image := _new_image(ICON_SIZE)
	_draw_fang(image, Vector2i(7, 23), 0.36, 0.85)
	return image


func _make_weapon_icon_blaster() -> Image:
	var image := _new_image(ICON_SIZE)
	_draw_blaster(image, Vector2i(4, 11), 0.8)
	return image


func _make_weapon_showcase_fang() -> Image:
	var image := _new_image(SHOWCASE_SIZE)
	_fill_rect(image, Rect2i(6, 28, 84, 8), Color(COLOR_PANEL_DARK.r, COLOR_PANEL_DARK.g, COLOR_PANEL_DARK.b, 0.44))
	_fill_rect(image, Rect2i(10, 24, 76, 3), Color(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, 0.26))
	_draw_fang(image, Vector2i(18, 30), 0.54, 1.0)
	_fill_rect(image, Rect2i(58, 8, 18, 4), Color(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, 0.45))
	_fill_rect(image, Rect2i(58, 14, 24, 4), Color(COLOR_CREAM.r, COLOR_CREAM.g, COLOR_CREAM.b, 0.34))
	return image


func _make_weapon_showcase_blaster() -> Image:
	var image := _new_image(SHOWCASE_SIZE)
	_fill_rect(image, Rect2i(6, 28, 84, 8), Color(COLOR_PANEL_DARK.r, COLOR_PANEL_DARK.g, COLOR_PANEL_DARK.b, 0.44))
	_fill_rect(image, Rect2i(10, 24, 76, 3), Color(COLOR_PANEL.r, COLOR_PANEL.g, COLOR_PANEL.b, 0.24))
	_draw_blaster(image, Vector2i(14, 12), 1.0)
	_fill_rect(image, Rect2i(60, 8, 14, 4), Color(COLOR_PANEL.r, COLOR_PANEL.g, COLOR_PANEL.b, 0.46))
	_fill_rect(image, Rect2i(60, 14, 22, 4), Color(COLOR_CREAM.r, COLOR_CREAM.g, COLOR_CREAM.b, 0.34))
	return image


func _draw_fang(image: Image, pivot: Vector2i, scale: float, alpha: float) -> void:
	var hilt_color := _with_alpha(COLOR_PANEL_DARK, alpha)
	var guard_color := _with_alpha(COLOR_MID_METAL, alpha)
	var blade_color := _with_alpha(COLOR_CREAM, alpha)
	var edge_color := _with_alpha(COLOR_ACCENT, alpha)
	var glow_color := _with_alpha(COLOR_GLOW_HOT, alpha * 0.58)

	_fill_rect(image, Rect2i(pivot.x - 4, pivot.y - 1, int(round(10 * scale)) + 6, int(round(8 * scale)) + 4), hilt_color)
	_fill_rect(image, Rect2i(pivot.x - 10, pivot.y - 2, int(round(18 * scale)) + 8, int(round(4 * scale)) + 4), guard_color)
	_stroke_line(image, pivot + Vector2i(0, 0), pivot + Vector2i(int(round(34 * scale)), -int(round(34 * scale))), maxi(3, int(round(8 * scale))), blade_color)
	_stroke_line(image, pivot + Vector2i(2, -2), pivot + Vector2i(int(round(28 * scale)), -int(round(30 * scale))), maxi(2, int(round(3 * scale))), edge_color)
	_stroke_line(image, pivot + Vector2i(int(round(6 * scale)), -int(round(6 * scale))), pivot + Vector2i(int(round(38 * scale)), -int(round(36 * scale))), 1, glow_color)
	_stroke_line(image, pivot + Vector2i(-6, 6), pivot + Vector2i(-16, 14), 2, glow_color)
	_fill_rect(image, Rect2i(pivot.x + int(round(24 * scale)), pivot.y - int(round(32 * scale)), 4, 4), _with_alpha(COLOR_STAR, alpha))


func _draw_blaster(image: Image, origin: Vector2i, alpha: float) -> void:
	var body_color := _with_alpha(COLOR_DARK_METAL, alpha)
	var frame_color := _with_alpha(COLOR_MID_METAL, alpha)
	var barrel_color := _with_alpha(COLOR_ARMOR_SHADE, alpha)
	var glow_color := _with_alpha(COLOR_ACCENT, alpha * 0.72)
	var shell_color := _with_alpha(COLOR_GLOW_HOT, alpha * 0.82)

	_fill_rect(image, Rect2i(origin.x + 10, origin.y + 6, 34, 12), body_color)
	_fill_rect(image, Rect2i(origin.x + 8, origin.y + 8, 8, 8), frame_color)
	_fill_rect(image, Rect2i(origin.x + 40, origin.y + 8, 18, 8), barrel_color)
	_fill_rect(image, Rect2i(origin.x + 0, origin.y + 10, 12, 4), body_color)
	_fill_rect(image, Rect2i(origin.x + 20, origin.y + 2, 10, 8), frame_color)
	_fill_rect(image, Rect2i(origin.x + 22, origin.y + 4, 6, 4), glow_color)
	_fill_rect(image, Rect2i(origin.x + 26, origin.y + 18, 10, 10), body_color)
	_fill_rect(image, Rect2i(origin.x + 6, origin.y + 16, 10, 8), frame_color)
	_fill_rect(image, Rect2i(origin.x + 16, origin.y + 6, 18, 3), glow_color)
	_fill_rect(image, Rect2i(origin.x + 44, origin.y + 10, 14, 4), shell_color)
	_stroke_line(image, origin + Vector2i(58, 12), origin + Vector2i(70, 10), 2, shell_color)
	_stroke_line(image, origin + Vector2i(58, 13), origin + Vector2i(66, 16), 2, glow_color)


func _draw_tower(image: Image, rect: Rect2i) -> void:
	_fill_rect(image, rect, COLOR_CITY)
	_fill_rect(image, Rect2i(rect.position.x + 2, rect.position.y + 4, maxi(2, rect.size.x - 4), 2), COLOR_ACCENT.darkened(0.5))
	_fill_rect(image, Rect2i(rect.position.x + 3, rect.position.y + rect.size.y - 12, maxi(2, rect.size.x - 6), 4), COLOR_CREAM)
	_fill_rect(image, Rect2i(rect.position.x, rect.position.y - 2, rect.size.x, 2), COLOR_PANEL_DARK)


func _draw_ridge(image: Image, points: Array, fill_to: int, color: Color) -> void:
	for index in range(points.size() - 1):
		var start: Vector2i = points[index]
		var finish: Vector2i = points[index + 1]
		var width := maxi(1, finish.x - start.x)
		for step in range(width + 1):
			var t := float(step) / float(width)
			var x := start.x + step
			var y := int(round(lerpf(float(start.y), float(finish.y), t)))
			_fill_rect(image, Rect2i(x, y, 1, fill_to - y), color)


func _new_image(size: Vector2i) -> Image:
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	return image


func _fill_rect(image: Image, rect: Rect2i, color: Color) -> void:
	var clipped := rect.intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	if clipped.size.x <= 0 or clipped.size.y <= 0:
		return
	image.fill_rect(clipped, color)


func _fill_ellipse(image: Image, rect: Rect2i, color: Color) -> void:
	var radius_x := rect.size.x * 0.5
	var radius_y := rect.size.y * 0.5
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


func _set_pixel_safe(image: Image, point: Vector2i, color: Color) -> void:
	if point.x < 0 or point.y < 0 or point.x >= image.get_width() or point.y >= image.get_height():
		return
	image.set_pixelv(point, color)


func _with_alpha(color: Color, alpha: float) -> Color:
	return Color(color.r, color.g, color.b, color.a * alpha)
