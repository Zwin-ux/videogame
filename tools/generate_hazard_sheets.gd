extends SceneTree

const FRAME_SIZE := Vector2i(32, 32)
const DRONE_FRAME_COUNT := 7
const DRONE_ROW_COUNT := 2
const MINE_FRAME_COUNT := 6
const PREVIEW_SCALE := 6

const DRONE_OUTPUT_PATH := "res://art/export/hazard_drone_sheet.png"
const DRONE_PREVIEW_PATH := "res://art/export/hazard_drone_sheet_preview.png"
const MINE_OUTPUT_PATH := "res://art/export/hazard_mine_sheet.png"
const MINE_PREVIEW_PATH := "res://art/export/hazard_mine_sheet_preview.png"

const OUTLINE := Color8(26, 38, 51, 255)
const SHADOW := Color8(50, 72, 90, 255)
const ARMOR := Color8(216, 199, 162, 255)
const ARMOR_LIGHT := Color8(245, 241, 214, 255)
const TEAL := Color8(73, 212, 229, 255)
const TEAL_LIGHT := Color8(170, 244, 248, 255)
const ORANGE := Color8(243, 164, 87, 255)
const ORANGE_DARK := Color8(217, 120, 59, 255)
const BOOT := Color8(36, 48, 60, 255)
const METAL := Color8(50, 72, 90, 255)
const DAMAGE := Color8(230, 90, 74, 255)
const DAMAGE_DARK := Color8(164, 44, 39, 255)
const ARC_CORE := Color8(241, 237, 209, 255)
const ARC_EDGE := Color8(73, 212, 229, 255)

const DRONE_STATES := [
	{"wing": -2, "bob": 0, "leg": 0, "eye": "teal"},
	{"wing": -1, "bob": -1, "leg": -1, "eye": "teal"},
	{"wing": 1, "bob": 0, "leg": 1, "eye": "teal"},
	{"wing": 2, "bob": 1, "leg": 0, "eye": "teal"},
	{"wing": 0, "bob": 0, "leg": -1, "eye": "charge", "charge": true},
	{"wing": 2, "bob": 1, "leg": 1, "eye": "hurt", "hurt": true},
	{"wing": 1, "bob": 0, "leg": -2, "eye": "charge", "stagger": true},
]

const MITE_STATES := [
	{"wing": -1, "bob": 1, "leg": 0, "eye": "teal"},
	{"wing": 0, "bob": 0, "leg": -1, "eye": "teal"},
	{"wing": 2, "bob": 0, "leg": 1, "eye": "teal"},
	{"wing": 1, "bob": -1, "leg": 0, "eye": "teal"},
	{"wing": 0, "bob": 0, "leg": -1, "eye": "charge", "charge": true},
	{"wing": 2, "bob": 1, "leg": 1, "eye": "hurt", "hurt": true},
	{"wing": 1, "bob": 0, "leg": -2, "eye": "charge", "stagger": true},
]

const MINE_STATES := [
	{"open": 0, "core": "teal", "jaw": 0},
	{"open": 1, "core": "teal", "jaw": 0},
	{"open": 2, "core": "orange", "jaw": 1},
	{"open": 3, "core": "orange", "jaw": 1},
	{"open": 4, "core": "white", "jaw": 2, "charge": true},
	{"open": 0, "core": "dark", "jaw": -1, "disabled": true},
]


func _init() -> void:
	_generate_drone_sheet()
	_generate_mine_sheet()
	quit()


func _generate_drone_sheet() -> void:
	var image := Image.create(FRAME_SIZE.x * DRONE_FRAME_COUNT, FRAME_SIZE.y * DRONE_ROW_COUNT, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))

	for frame_index in range(DRONE_FRAME_COUNT):
		_draw_bug_frame(image, frame_index, 0, DRONE_STATES[frame_index], false)
		_draw_bug_frame(image, frame_index, 1, MITE_STATES[frame_index], true)

	_save_sheet(image, DRONE_OUTPUT_PATH, DRONE_PREVIEW_PATH)


func _generate_mine_sheet() -> void:
	var image := Image.create(FRAME_SIZE.x * MINE_FRAME_COUNT, FRAME_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))

	for frame_index in range(MINE_FRAME_COUNT):
		_draw_mine_frame(image, frame_index, MINE_STATES[frame_index])

	_save_sheet(image, MINE_OUTPUT_PATH, MINE_PREVIEW_PATH)


func _save_sheet(image: Image, output_path: String, preview_path: String) -> void:
	var absolute_output := ProjectSettings.globalize_path(output_path)
	var save_error := image.save_png(absolute_output)
	if save_error != OK:
		push_error("Failed to save %s (%s)" % [output_path, save_error])
		return

	print("Generated %s" % output_path)
	var preview := image.duplicate()
	preview.resize(image.get_width() * PREVIEW_SCALE, image.get_height() * PREVIEW_SCALE, Image.INTERPOLATE_NEAREST)
	var preview_error: Error = preview.save_png(ProjectSettings.globalize_path(preview_path))
	if preview_error != OK:
		push_error("Failed to save %s (%s)" % [preview_path, preview_error])
		return

	print("Generated %s" % preview_path)


func _draw_bug_frame(image: Image, frame_index: int, row: int, state: Dictionary, compact: bool) -> void:
	var offset := Vector2i(frame_index * FRAME_SIZE.x, row * FRAME_SIZE.y)
	var bob := int(state.get("bob", 0))
	var wing_offset := int(state.get("wing", 0))
	var leg_offset := int(state.get("leg", 0))
	var charging := bool(state.get("charge", false))
	var hurt := bool(state.get("hurt", false))
	var stagger := bool(state.get("stagger", false))

	var head_pos := offset + Vector2i(20, 11 + bob)
	var head_size := Vector2i(7, 6)
	var thorax_pos := offset + Vector2i(11, 10 + bob)
	var thorax_size := Vector2i(10, 8)
	var abdomen_pos := offset + Vector2i(6, 12 + bob)
	var abdomen_size := Vector2i(7, 6)
	var wing_anchor := offset + Vector2i(10, 6 + wing_offset + bob)
	var leg_base := offset + Vector2i(12, 19 + bob)
	var wing_length := 8
	var compact_shift := 0

	if compact:
		head_pos += Vector2i(-1, 1)
		head_size = Vector2i(6, 5)
		thorax_pos += Vector2i(0, 1)
		thorax_size = Vector2i(8, 7)
		abdomen_pos += Vector2i(1, 2)
		abdomen_size = Vector2i(6, 5)
		wing_anchor += Vector2i(1, 3)
		wing_length = 6
		compact_shift = 1

	_draw_wing(image, wing_anchor + Vector2i(0, 1), wing_length - 1, false, charging, hurt)
	_draw_body_segment(image, abdomen_pos, abdomen_size, BOOT, compact)
	_draw_body_segment(image, thorax_pos, thorax_size, METAL, compact)
	_draw_head(image, head_pos, head_size, String(state.get("eye", "teal")), hurt)
	_draw_wing(image, wing_anchor, wing_length, true, charging, hurt)
	_draw_bug_legs(image, leg_base + Vector2i(compact_shift, 0), leg_offset, compact, stagger)
	_draw_stinger(image, abdomen_pos + Vector2i(-3 + compact_shift, 3), charging, compact)

	if charging:
		_px(image, head_pos + Vector2i(head_size.x + 1, 2), ARC_CORE)
		_px(image, head_pos + Vector2i(head_size.x + 2, 2), ARC_EDGE)
		_px(image, thorax_pos + Vector2i(-1, thorax_size.y - 2), ORANGE)

	if hurt:
		_fill(image, thorax_pos + Vector2i(2, 2), Vector2i(3, 2), DAMAGE)
		_fill(image, head_pos + Vector2i(1, 2), Vector2i(2, 1), DAMAGE_DARK)

	if stagger:
		_fill(image, thorax_pos + Vector2i(3, 3), Vector2i(3, 2), ARMOR_LIGHT)
		_px(image, thorax_pos + Vector2i(1, thorax_size.y + 1), ORANGE)
		_px(image, thorax_pos + Vector2i(7, thorax_size.y + 2), ARC_CORE)
		_px(image, abdomen_pos + Vector2i(1, abdomen_size.y + 1), ARC_EDGE)


func _draw_mine_frame(image: Image, frame_index: int, state: Dictionary) -> void:
	var offset := Vector2i(frame_index * FRAME_SIZE.x, 0)
	var open_level := int(state.get("open", 0))
	var jaw_offset := int(state.get("jaw", 0))
	var charging := bool(state.get("charge", false))
	var disabled := bool(state.get("disabled", false))
	var shell_color := BOOT if disabled else METAL
	var shell_light := SHADOW if disabled else ARMOR

	_fill(image, offset + Vector2i(9, 12), Vector2i(14, 8), OUTLINE)
	_fill(image, offset + Vector2i(10, 13), Vector2i(12, 6), shell_color)
	_fill(image, offset + Vector2i(11, 14), Vector2i(10, 2), shell_light)
	_fill(image, offset + Vector2i(12, 17), Vector2i(8, 1), SHADOW)

	_draw_shell_plate(image, offset + Vector2i(6 - open_level, 11), true, open_level, disabled)
	_draw_shell_plate(image, offset + Vector2i(21 + open_level, 11), false, open_level, disabled)
	_draw_mine_legs(image, offset + Vector2i(16, 18), jaw_offset, disabled)
	_draw_mine_core(image, offset + Vector2i(16, 15), String(state.get("core", "teal")), charging, disabled)

	if charging:
		_px(image, offset + Vector2i(16, 8), ARC_CORE)
		_px(image, offset + Vector2i(17, 8), ARC_EDGE)
		_px(image, offset + Vector2i(14, 7), ARC_EDGE)


func _draw_body_segment(image: Image, pos: Vector2i, size: Vector2i, fill_color: Color, compact: bool) -> void:
	_panel(image, pos, size, OUTLINE, fill_color)
	_fill(image, pos + Vector2i(1, 1), Vector2i(size.x - 2, 2), ARMOR if fill_color == METAL else SHADOW)
	_fill(image, pos + Vector2i(1, size.y - 2), Vector2i(size.x - 2, 1), SHADOW)
	if compact:
		_px(image, pos + Vector2i(size.x - 1, 2), OUTLINE)
	else:
		_fill(image, pos + Vector2i(2, 3), Vector2i(size.x - 4, 1), TEAL)


func _draw_head(image: Image, pos: Vector2i, size: Vector2i, eye_state: String, hurt: bool) -> void:
	_panel(image, pos, size, OUTLINE, ARMOR)
	_fill(image, pos + Vector2i(1, 1), Vector2i(size.x - 2, 2), ARMOR_LIGHT)
	_fill(image, pos + Vector2i(1, size.y - 2), Vector2i(size.x - 2, 1), SHADOW)
	_fill(image, pos + Vector2i(size.x - 1, 2), Vector2i(2, 2), OUTLINE)
	var eye_color := TEAL
	var eye_glint := TEAL_LIGHT
	match eye_state:
		"charge":
			eye_color = ORANGE
			eye_glint = ARC_CORE
		"hurt":
			eye_color = DAMAGE
			eye_glint = ORANGE
		_:
			eye_color = TEAL
			eye_glint = TEAL_LIGHT
	_fill(image, pos + Vector2i(2, 2), Vector2i(size.x - 4, 2), eye_color)
	_fill(image, pos + Vector2i(2, 3), Vector2i(size.x - 4, 1), eye_glint)
	if hurt:
		_px(image, pos + Vector2i(1, 1), DAMAGE)


func _draw_wing(image: Image, pos: Vector2i, length: int, front: bool, charging: bool, hurt: bool) -> void:
	var wing_color := ARMOR_LIGHT if front else SHADOW
	if hurt and front:
		wing_color = DAMAGE_DARK
	_fill(image, pos, Vector2i(length, 2), wing_color)
	_fill(image, pos + Vector2i(length, 1), Vector2i(2, 1), wing_color)
	_px(image, pos + Vector2i(length + 2, 0), ARC_CORE if charging and front else wing_color)
	_px(image, pos + Vector2i(length + 1, -1), ARC_EDGE if charging and front else wing_color)
	if front:
		_px(image, pos + Vector2i(1, -1), ARMOR_LIGHT)
		_px(image, pos + Vector2i(2, -1), ARMOR_LIGHT)


func _draw_bug_legs(image: Image, pos: Vector2i, offset: int, compact: bool, stagger: bool) -> void:
	var x_positions := [0, 4, 8]
	for index in range(x_positions.size()):
		var leg_x := int(x_positions[index])
		var leg_height: int = 3 + abs(index - 1)
		var y_offset := offset if index % 2 == 0 else -offset
		_fill(image, pos + Vector2i(leg_x, y_offset), Vector2i(1, leg_height), ORANGE_DARK)
		_fill(image, pos + Vector2i(leg_x + 1, y_offset + leg_height - 1), Vector2i(1, 2), ORANGE)
		if compact:
			_px(image, pos + Vector2i(leg_x, y_offset + leg_height + 1), ORANGE)
	if stagger:
		_px(image, pos + Vector2i(3, -2), ARC_CORE)
		_px(image, pos + Vector2i(7, 5), ARC_EDGE)


func _draw_stinger(image: Image, pos: Vector2i, charging: bool, compact: bool) -> void:
	_px(image, pos + Vector2i(0, 0), OUTLINE)
	_px(image, pos + Vector2i(-1, 0), ORANGE_DARK)
	_px(image, pos + Vector2i(-2, 0), ORANGE if charging else OUTLINE)
	if not compact:
		_px(image, pos + Vector2i(-1, 1), ORANGE_DARK)


func _draw_shell_plate(image: Image, pos: Vector2i, left_side: bool, open_level: int, disabled: bool) -> void:
	var plate_color := BOOT if disabled else METAL
	var plate_highlight := SHADOW if disabled else ARMOR
	var width := 6
	var height := 8
	var plate_pos := pos - Vector2i(width if left_side else 0, 0)
	_panel(image, plate_pos, Vector2i(width, height), OUTLINE, plate_color)
	_fill(image, plate_pos + Vector2i(1, 1), Vector2i(width - 2, 2), plate_highlight)
	_fill(image, plate_pos + Vector2i(1, height - 2), Vector2i(width - 2, 1), SHADOW)
	var trim_x := 1 if left_side else width - 2
	_fill(image, plate_pos + Vector2i(trim_x, 2), Vector2i(1, height - 4), TEAL if not disabled else SHADOW)
	if open_level >= 3:
		_px(image, plate_pos + Vector2i(width / 2, -1), ORANGE)


func _draw_mine_legs(image: Image, pos: Vector2i, jaw_offset: int, disabled: bool) -> void:
	var leg_color := SHADOW if disabled else ORANGE_DARK
	_fill(image, pos + Vector2i(-8, 0), Vector2i(2, 1), leg_color)
	_fill(image, pos + Vector2i(6, 0), Vector2i(2, 1), leg_color)
	_fill(image, pos + Vector2i(-10, 2), Vector2i(2, 1), leg_color)
	_fill(image, pos + Vector2i(8, 2), Vector2i(2, 1), leg_color)
	_fill(image, pos + Vector2i(-4, -8 + jaw_offset), Vector2i(1, 4), ORANGE if not disabled else SHADOW)
	_fill(image, pos + Vector2i(3, -8 + jaw_offset), Vector2i(1, 4), ORANGE if not disabled else SHADOW)
	_px(image, pos + Vector2i(-5, -8 + jaw_offset), ORANGE if not disabled else SHADOW)
	_px(image, pos + Vector2i(4, -8 + jaw_offset), ORANGE if not disabled else SHADOW)


func _draw_mine_core(image: Image, pos: Vector2i, core_state: String, charging: bool, disabled: bool) -> void:
	var outer_color := ARMOR
	var inner_color := TEAL
	var glint_color := TEAL_LIGHT
	match core_state:
		"orange":
			inner_color = ORANGE
			glint_color = ARC_CORE
		"white":
			outer_color = ORANGE
			inner_color = ARC_CORE
			glint_color = ARMOR_LIGHT
		"dark":
			outer_color = SHADOW
			inner_color = BOOT
			glint_color = SHADOW
	_fill(image, pos + Vector2i(-4, -3), Vector2i(8, 6), outer_color)
	_fill(image, pos + Vector2i(-3, -2), Vector2i(6, 4), inner_color)
	_fill(image, pos + Vector2i(-1, -1), Vector2i(2, 2), glint_color)
	if charging and not disabled:
		_px(image, pos + Vector2i(0, -4), ARC_CORE)
		_px(image, pos + Vector2i(1, -4), ARC_EDGE)


func _panel(image: Image, pos: Vector2i, size: Vector2i, border: Color, fill_color: Color) -> void:
	_fill(image, pos, size, border)
	_fill(image, pos + Vector2i(1, 1), Vector2i(size.x - 2, size.y - 2), fill_color)


func _fill(image: Image, pos: Vector2i, size: Vector2i, color: Color) -> void:
	for y in range(size.y):
		for x in range(size.x):
			_px(image, pos + Vector2i(x, y), color)


func _px(image: Image, pos: Vector2i, color: Color) -> void:
	if pos.x < 0 or pos.y < 0 or pos.x >= image.get_width() or pos.y >= image.get_height():
		return
	image.set_pixelv(pos, color)
