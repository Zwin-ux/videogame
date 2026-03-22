extends SceneTree

const BOSS_FRAME_SIZE := Vector2i(48, 48)
const BOSS_SHEET_PATH := "res://art/export/rival_boss_sheet.png"
const BOSS_PREVIEW_PATH := "res://art/export/rival_boss_sheet_preview.png"
const SALVAGE_SIZE := Vector2i(32, 32)
const SALVAGE_BLADE_PATH := "res://art/export/weapon_salvage_blade.png"
const SALVAGE_GUN_PATH := "res://art/export/weapon_salvage_blaster.png"

const OUTLINE := Color8(20, 24, 31, 255)
const ARMOR := Color8(214, 201, 184, 255)
const ARMOR_LIGHT := Color8(246, 239, 219, 255)
const ARMOR_SHADE := Color8(140, 112, 82, 255)
const TRIM := Color8(229, 124, 57, 255)
const TRIM_LIGHT := Color8(255, 191, 104, 255)
const UNDERSUIT := Color8(58, 42, 40, 255)
const BOOT := Color8(33, 40, 54, 255)
const VISOR := Color8(112, 217, 234, 255)
const VISOR_LIGHT := Color8(228, 250, 255, 255)
const SPARK := Color8(255, 214, 136, 255)


func _init() -> void:
	var frames := [
		{"name": "gun_idle_a", "weapon": "gun", "pose": "idle", "step": 0},
		{"name": "gun_idle_b", "weapon": "gun", "pose": "idle", "step": 1},
		{"name": "gun_fire", "weapon": "gun", "pose": "fire", "step": 0},
		{"name": "gun_open", "weapon": "gun", "pose": "open", "step": 0},
		{"name": "blade_idle_a", "weapon": "blade", "pose": "idle", "step": 0},
		{"name": "blade_idle_b", "weapon": "blade", "pose": "idle", "step": 1},
		{"name": "blade_swing", "weapon": "blade", "pose": "swing", "step": 0},
		{"name": "blade_open", "weapon": "blade", "pose": "open", "step": 0},
		{"name": "flourish", "weapon": "blade", "pose": "flourish", "step": 0},
		{"name": "defeated", "weapon": "gun", "pose": "defeated", "step": 0},
	]

	var boss_sheet := Image.create(BOSS_FRAME_SIZE.x * frames.size(), BOSS_FRAME_SIZE.y, false, Image.FORMAT_RGBA8)
	boss_sheet.fill(Color(0.0, 0.0, 0.0, 0.0))
	for frame_index in range(frames.size()):
		_draw_boss_frame(boss_sheet, Vector2i(frame_index * BOSS_FRAME_SIZE.x, 0), frames[frame_index])

	_write_image(BOSS_SHEET_PATH, boss_sheet)
	var preview := boss_sheet.duplicate()
	preview.resize(preview.get_width() * 5, preview.get_height() * 5, Image.INTERPOLATE_NEAREST)
	_write_image(BOSS_PREVIEW_PATH, preview)
	_write_image(SALVAGE_BLADE_PATH, _make_salvage_texture(true))
	_write_image(SALVAGE_GUN_PATH, _make_salvage_texture(false))
	print("Generated rival boss and salvage sprites")
	quit()


func _write_image(path: String, image: Image) -> void:
	var error := image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Failed to save %s (%s)" % [path, error])
		quit(error)


func _draw_boss_frame(image: Image, offset: Vector2i, frame: Dictionary) -> void:
	var center_x := offset.x + 24
	var head_y := offset.y + 6
	var torso_y := offset.y + 17
	var pose := String(frame["pose"])
	var weapon := String(frame["weapon"])
	var gait := -2 if int(frame.get("step", 0)) == 0 else 2
	if pose == "fire" or pose == "swing":
		gait = 3
	if pose == "defeated":
		head_y += 10
		torso_y += 12
		gait = 8

	_fill_ellipse(image, Rect2i(offset.x + 10, offset.y + 40, 28, 6), Color(0.0, 0.0, 0.0, 0.18))
	_draw_leg(image, Vector2i(center_x - 11 + gait, torso_y + 12), true, pose == "defeated")
	_draw_leg(image, Vector2i(center_x + 2 - gait, torso_y + 12), false, pose == "defeated")
	_draw_torso(image, Vector2i(center_x - 13, torso_y), pose)
	_draw_head(image, Vector2i(center_x - 9, head_y), pose)
	_draw_arm(image, Vector2i(center_x - 17, torso_y + 1), true, pose)
	_draw_arm(image, Vector2i(center_x + 12, torso_y + 1), false, pose)
	if weapon == "gun":
		_draw_blaster(image, Vector2i(center_x + 11, torso_y + 4), pose)
	else:
		_draw_fang(image, Vector2i(center_x + 9, torso_y - 2), pose)
	if pose == "open":
		_fill_ellipse(image, Rect2i(center_x - 9, torso_y + 2, 18, 14), Color(TRIM.r, TRIM.g, TRIM.b, 0.36))
		_fill_ellipse(image, Rect2i(center_x - 4, torso_y + 6, 8, 6), Color(SPARK.r, SPARK.g, SPARK.b, 0.85))
	if pose == "flourish":
		_arc_ring(image, Vector2i(center_x, torso_y + 1), 18, TRIM)
	if pose == "defeated":
		_fill(image, Vector2i(center_x - 16, torso_y + 16), Vector2i(32, 4), Color(TRIM.r, TRIM.g, TRIM.b, 0.35))


func _draw_head(image: Image, pos: Vector2i, pose: String) -> void:
	_panel(image, pos, Vector2i(18, 12), OUTLINE, ARMOR)
	_fill(image, pos + Vector2i(2, 1), Vector2i(14, 2), ARMOR_LIGHT)
	_fill(image, pos + Vector2i(1, 9), Vector2i(16, 2), ARMOR_SHADE)
	_fill(image, pos + Vector2i(4, 4), Vector2i(10, 4), VISOR)
	_fill(image, pos + Vector2i(5, 4), Vector2i(8, 1), VISOR_LIGHT)
	_fill(image, pos + Vector2i(0, 3), Vector2i(2, 6), TRIM)
	_fill(image, pos + Vector2i(16, 3), Vector2i(2, 6), TRIM)
	_fill(image, pos + Vector2i(5, -1), Vector2i(8, 2), ARMOR_SHADE)
	if pose == "defeated":
		_fill(image, pos + Vector2i(4, 6), Vector2i(10, 2), TRIM)


func _draw_torso(image: Image, pos: Vector2i, pose: String) -> void:
	_panel(image, pos, Vector2i(26, 16), OUTLINE, ARMOR)
	_fill(image, pos + Vector2i(2, 1), Vector2i(22, 3), ARMOR_LIGHT)
	_fill(image, pos + Vector2i(3, 5), Vector2i(20, 5), TRIM)
	_fill(image, pos + Vector2i(5, 7), Vector2i(16, 1), TRIM_LIGHT)
	_fill(image, pos + Vector2i(4, 11), Vector2i(18, 3), ARMOR_SHADE)
	_fill(image, pos + Vector2i(-2, 3), Vector2i(4, 10), TRIM)
	_fill(image, pos + Vector2i(24, 3), Vector2i(4, 10), TRIM)
	_fill(image, pos + Vector2i(5, 13), Vector2i(16, 2), BOOT)
	if pose == "open":
		_fill(image, pos + Vector2i(9, 5), Vector2i(8, 6), Color(VISOR.r, VISOR.g, VISOR.b, 0.92))
		_fill(image, pos + Vector2i(10, 6), Vector2i(6, 1), VISOR_LIGHT)


func _draw_arm(image: Image, pos: Vector2i, left_side: bool, pose: String) -> void:
	var dir := -1 if left_side else 1
	_panel(image, pos, Vector2i(5, 10), OUTLINE, ARMOR)
	_fill(image, pos + Vector2i(1, 1), Vector2i(3, 2), ARMOR_LIGHT)
	_fill(image, pos + Vector2i(1, 6), Vector2i(3, 3), UNDERSUIT)
	var elbow := pos + Vector2i(2, 8)
	var wrist := elbow + Vector2i(dir * 3, 3)
	match pose:
		"fire":
			wrist = pos + Vector2i(4 if not left_side else 0, 4)
		"swing":
			wrist = pos + Vector2i(7 if not left_side else -3, 1)
		"flourish":
			wrist = pos + Vector2i(5 if not left_side else -1, 0)
		"defeated":
			wrist = pos + Vector2i(1, 12)
	_line(image, elbow, wrist, ARMOR)
	_px(image, wrist, TRIM_LIGHT)


func _draw_leg(image: Image, pos: Vector2i, left_side: bool, fallen: bool) -> void:
	var size := Vector2i(7, 12)
	_panel(image, pos, size, OUTLINE, UNDERSUIT)
	_fill(image, pos + Vector2i(1, 1), Vector2i(5, 3), ARMOR)
	_fill(image, pos + Vector2i(1, 2), Vector2i(5, 1), ARMOR_LIGHT)
	_fill(image, pos + Vector2i(1, 5), Vector2i(5, 3), ARMOR_SHADE)
	_fill(image, pos + Vector2i(0, 9), Vector2i(7, 3), BOOT)
	if fallen:
		_fill(image, pos + Vector2i(6 if left_side else -1, 10), Vector2i(3, 1), BOOT)


func _draw_blaster(image: Image, origin: Vector2i, pose: String) -> void:
	_panel(image, origin, Vector2i(12, 5), OUTLINE, ARMOR_SHADE)
	_fill(image, origin + Vector2i(1, 1), Vector2i(6, 1), ARMOR_LIGHT)
	_fill(image, origin + Vector2i(3, 2), Vector2i(4, 1), VISOR)
	_fill(image, origin + Vector2i(11, 1), Vector2i(4, 3), BOOT)
	_fill(image, origin + Vector2i(2, 5), Vector2i(3, 4), OUTLINE)
	_fill(image, origin + Vector2i(4, 0), Vector2i(3, 1), TRIM)
	if pose == "fire":
		_fill(image, origin + Vector2i(15, 1), Vector2i(3, 2), SPARK)
		_px(image, origin + Vector2i(18, 1), TRIM_LIGHT)
		_px(image, origin + Vector2i(18, 2), SPARK)


func _draw_fang(image: Image, origin: Vector2i, pose: String) -> void:
	_fill(image, origin + Vector2i(0, 8), Vector2i(4, 3), TRIM)
	_fill(image, origin + Vector2i(4, 6), Vector2i(2, 5), ARMOR_SHADE)
	var start := origin + Vector2i(5, 7)
	var finish := origin + Vector2i(15, 1)
	if pose == "swing":
		finish = origin + Vector2i(18, 5)
	elif pose == "flourish":
		finish = origin + Vector2i(13, -2)
	_line(image, start, finish, ARMOR_LIGHT)
	_line(image, start + Vector2i(0, 1), finish + Vector2i(0, 1), VISOR)
	_px(image, finish + Vector2i(1, -1), SPARK)


func _make_salvage_texture(blade_mode: bool) -> Image:
	var image := Image.create(SALVAGE_SIZE.x, SALVAGE_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	_fill_ellipse(image, Rect2i(4, 22, 24, 6), Color(0.0, 0.0, 0.0, 0.18))
	_fill_ellipse(image, Rect2i(7, 8, 18, 18), Color(TRIM.r, TRIM.g, TRIM.b, 0.18))
	_fill_ellipse(image, Rect2i(10, 11, 12, 12), Color(ARMOR_SHADE.r, ARMOR_SHADE.g, ARMOR_SHADE.b, 0.55))
	_fill(image, Vector2i(8, 7), Vector2i(16, 2), OUTLINE)
	_fill(image, Vector2i(10, 9), Vector2i(12, 2), ARMOR)
	if blade_mode:
		_fill(image, Vector2i(11, 17), Vector2i(6, 3), TRIM)
		_line(image, Vector2i(15, 17), Vector2i(22, 9), ARMOR_LIGHT)
		_line(image, Vector2i(15, 18), Vector2i(22, 10), VISOR)
		_px(image, Vector2i(23, 8), SPARK)
	else:
		_panel(image, Vector2i(8, 14), Vector2i(11, 5), OUTLINE, ARMOR_SHADE)
		_fill(image, Vector2i(9, 15), Vector2i(5, 1), ARMOR_LIGHT)
		_fill(image, Vector2i(12, 16), Vector2i(3, 1), VISOR)
		_fill(image, Vector2i(19, 15), Vector2i(4, 3), BOOT)
		_fill(image, Vector2i(10, 19), Vector2i(3, 4), OUTLINE)
		_px(image, Vector2i(23, 15), SPARK)
	_fill(image, Vector2i(5, 20), Vector2i(4, 1), TRIM_LIGHT)
	_fill(image, Vector2i(22, 11), Vector2i(3, 1), TRIM_LIGHT)
	_fill(image, Vector2i(6, 12), Vector2i(2, 1), SPARK)
	return image


func _panel(image: Image, pos: Vector2i, size: Vector2i, border: Color, fill_color: Color) -> void:
	_fill(image, pos, size, border)
	_fill(image, pos + Vector2i(1, 1), Vector2i(maxi(0, size.x - 2), maxi(0, size.y - 2)), fill_color)


func _fill(image: Image, pos: Vector2i, size: Vector2i, color: Color) -> void:
	for y in range(size.y):
		for x in range(size.x):
			_px(image, pos + Vector2i(x, y), color)


func _line(image: Image, start: Vector2i, finish: Vector2i, color: Color) -> void:
	var delta := finish - start
	var steps := maxi(abs(delta.x), abs(delta.y))
	if steps <= 0:
		_px(image, start, color)
		return
	for step in range(steps + 1):
		var t := float(step) / float(steps)
		_px(image, start + Vector2i(roundi(delta.x * t), roundi(delta.y * t)), color)


func _fill_ellipse(image: Image, rect: Rect2i, color: Color) -> void:
	var radius_x := rect.size.x * 0.5
	var radius_y := rect.size.y * 0.5
	var center := Vector2(rect.position.x + radius_x, rect.position.y + radius_y)
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			var nx := (float(x) - center.x) / maxf(radius_x, 1.0)
			var ny := (float(y) - center.y) / maxf(radius_y, 1.0)
			if nx * nx + ny * ny <= 1.0:
				_px(image, Vector2i(x, y), color)


func _arc_ring(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for angle_step in range(20):
		var angle := lerpf(-1.0, 1.0, float(angle_step) / 19.0)
		var point := center + Vector2i(roundi(cos(angle) * radius), roundi(sin(angle) * radius))
		_px(image, point, color)


func _px(image: Image, pos: Vector2i, color: Color) -> void:
	if pos.x < 0 or pos.y < 0 or pos.x >= image.get_width() or pos.y >= image.get_height():
		return
	image.set_pixelv(pos, color)
