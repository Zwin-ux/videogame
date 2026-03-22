extends SceneTree

const FRAME_SIZE := Vector2i(32, 32)
const OUTPUT_PATH := "res://art/export/player_sheet.png"
const DATA_PATH := "res://art/export/player_sheet.json"
const PREVIEW_PATH := "res://art/export/player_sheet_preview.png"

const INK := Color8(17, 23, 33, 255)
const OUTLINE := Color8(26, 38, 51, 255)
const SHADOW := Color8(52, 74, 94, 255)
const PANEL_DARK := Color8(38, 52, 68, 255)
const BODY := Color8(216, 199, 162, 255)
const HIGHLIGHT := Color8(245, 241, 214, 255)
const NOZZLE := Color8(50, 72, 90, 255)
const BOOT := Color8(36, 48, 60, 255)
const TRIM := Color8(73, 212, 229, 255)
const TRIM_LIGHT := Color8(170, 244, 248, 255)
const ORANGE := Color8(243, 164, 87, 255)
const ORANGE_DARK := Color8(217, 120, 59, 255)
const BONE := Color8(241, 237, 209, 255)
const DAMAGE := Color8(230, 90, 74, 255)

const BASE_MODEL := {
	"head": Vector2i(11, 3),
	"head_size": Vector2i(10, 8),
	"visor": Vector2i(13, 6),
	"visor_size": Vector2i(6, 2),
	"torso": Vector2i(11, 10),
	"torso_size": Vector2i(10, 10),
	"left_leg": Vector2i(9, 20),
	"right_leg": Vector2i(18, 20),
	"left_arm": Vector2i(8, 12),
	"right_arm": Vector2i(20, 11),
	"left_pack": Vector2i(8, 10),
	"right_pack": Vector2i(21, 10),
	"module": Vector2i(22, 12),
	"lean": 0,
	"left_arm_pose": "down",
	"right_arm_pose": "ready",
	"module_pose": "ready",
}


func _init() -> void:
	var frames := _build_frame_defs()
	var image := Image.create(FRAME_SIZE.x * frames.size(), FRAME_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))

	for frame_index in range(frames.size()):
		_draw_frame(image, frame_index, frames[frame_index])

	var sheet_error := image.save_png(ProjectSettings.globalize_path(OUTPUT_PATH))
	if sheet_error != OK:
		push_error("Failed to save %s (%s)" % [OUTPUT_PATH, sheet_error])
	else:
		print("Generated %s" % OUTPUT_PATH)

	var data_error := _write_json(frames)
	if data_error != OK:
		push_error("Failed to save %s (%s)" % [DATA_PATH, data_error])
	else:
		print("Generated %s" % DATA_PATH)

	var preview := image.duplicate()
	preview.resize(image.get_width() * 6, image.get_height() * 6, Image.INTERPOLATE_NEAREST)
	var preview_error: Error = preview.save_png(ProjectSettings.globalize_path(PREVIEW_PATH))
	if preview_error != OK:
		push_error("Failed to save %s (%s)" % [PREVIEW_PATH, preview_error])
	else:
		print("Generated %s" % PREVIEW_PATH)
	quit()


func _build_frame_defs() -> Array[Dictionary]:
	return [
		_frame("idle_0", "idle", 120, {"left_leg": Vector2i(9, 20), "right_leg": Vector2i(18, 20), "module": Vector2i(22, 12), "module_pose": "blaster_ready", "right_arm_pose": "gun_aim"}),
		_frame("idle_1", "idle", 180, {"torso": Vector2i(11, 11), "head": Vector2i(11, 4), "left_leg": Vector2i(10, 20), "right_leg": Vector2i(18, 19), "module": Vector2i(22, 13), "module_pose": "blaster_ready", "right_arm_pose": "ready"}),
		_frame("idle_blade_0", "idle_blade", 110, {"torso": Vector2i(10, 10), "head": Vector2i(10, 3), "left_leg": Vector2i(8, 20), "right_leg": Vector2i(18, 19), "left_arm": Vector2i(7, 13), "right_arm": Vector2i(19, 10), "module": Vector2i(20, 9), "lean": 2, "left_arm_pose": "guard", "right_arm_pose": "blade_ready", "module_pose": "blade_ready"}),
		_frame("idle_blade_1", "idle_blade", 160, {"torso": Vector2i(11, 11), "head": Vector2i(11, 4), "left_leg": Vector2i(9, 20), "right_leg": Vector2i(18, 20), "left_arm": Vector2i(8, 13), "right_arm": Vector2i(20, 10), "module": Vector2i(21, 10), "lean": 1, "left_arm_pose": "guard", "right_arm_pose": "blade_ready", "module_pose": "blade_ready"}),
		_frame("run_0", "run", 55, {"torso": Vector2i(10, 10), "head": Vector2i(10, 3), "left_leg": Vector2i(8, 20), "right_leg": Vector2i(18, 18), "left_arm": Vector2i(7, 13), "right_arm": Vector2i(21, 10), "module": Vector2i(22, 10), "lean": 2, "left_arm_pose": "back", "right_arm_pose": "gun_aim", "module_pose": "blaster_ready"}),
		_frame("run_1", "run", 70, {"torso": Vector2i(11, 10), "head": Vector2i(11, 3), "left_leg": Vector2i(11, 19), "right_leg": Vector2i(18, 20), "left_arm": Vector2i(8, 12), "right_arm": Vector2i(20, 12), "module": Vector2i(22, 12), "lean": 1, "left_arm_pose": "down", "right_arm_pose": "ready", "module_pose": "blaster_ready"}),
		_frame("run_2", "run", 55, {"torso": Vector2i(12, 10), "head": Vector2i(12, 3), "left_leg": Vector2i(10, 18), "right_leg": Vector2i(19, 20), "left_arm": Vector2i(8, 10), "right_arm": Vector2i(19, 13), "module": Vector2i(21, 13), "lean": -1, "left_arm_pose": "forward", "right_arm_pose": "back", "module_pose": "blaster_ready"}),
		_frame("run_3", "run", 70, {"torso": Vector2i(11, 10), "head": Vector2i(11, 3), "left_leg": Vector2i(9, 20), "right_leg": Vector2i(18, 19), "left_arm": Vector2i(8, 11), "right_arm": Vector2i(20, 11), "module": Vector2i(22, 11), "lean": 0, "left_arm_pose": "down", "right_arm_pose": "ready", "module_pose": "blaster_ready"}),
		_frame("jump_up_0", "jump_up", 45, {"torso": Vector2i(11, 10), "head": Vector2i(11, 3), "left_leg": Vector2i(8, 19), "right_leg": Vector2i(18, 18), "left_arm": Vector2i(8, 11), "right_arm": Vector2i(20, 10), "left_pack": Vector2i(8, 9), "right_pack": Vector2i(21, 9), "module": Vector2i(22, 10), "left_arm_pose": "up", "right_arm_pose": "ready", "module_pose": "blaster_ready"}),
		_frame("jump_up_1", "jump_up", 65, {"torso": Vector2i(11, 8), "head": Vector2i(11, 1), "left_leg": Vector2i(10, 17), "right_leg": Vector2i(17, 16), "left_arm": Vector2i(9, 8), "right_arm": Vector2i(20, 8), "left_pack": Vector2i(8, 7), "right_pack": Vector2i(21, 7), "module": Vector2i(22, 8), "left_arm_pose": "up", "right_arm_pose": "gun_aim", "module_pose": "blaster_ready"}),
		_frame("fall_0", "fall", 55, {"torso": Vector2i(11, 10), "head": Vector2i(11, 3), "left_leg": Vector2i(9, 20), "right_leg": Vector2i(18, 20), "left_arm": Vector2i(7, 11), "right_arm": Vector2i(21, 11), "module": Vector2i(22, 12), "left_arm_pose": "spread", "right_arm_pose": "spread", "module_pose": "blaster_ready"}),
		_frame("fall_1", "fall", 70, {"torso": Vector2i(11, 11), "head": Vector2i(11, 4), "left_leg": Vector2i(8, 22), "right_leg": Vector2i(18, 22), "left_arm": Vector2i(7, 13), "right_arm": Vector2i(21, 13), "module": Vector2i(22, 14), "left_arm_pose": "fall_reach", "right_arm_pose": "fall_reach", "module_pose": "blaster_ready"}),
		_frame("land_0", "land", 55, {"torso": Vector2i(11, 13), "head": Vector2i(11, 6), "left_leg": Vector2i(7, 22), "right_leg": Vector2i(18, 22), "left_arm": Vector2i(8, 15), "right_arm": Vector2i(19, 14), "module": Vector2i(21, 15), "left_arm_pose": "guard", "right_arm_pose": "guard", "module_pose": "blaster_ready"}),
		_frame("land_1", "land", 60, {"torso": Vector2i(11, 10), "head": Vector2i(11, 3), "left_leg": Vector2i(9, 20), "right_leg": Vector2i(18, 20), "left_arm": Vector2i(8, 12), "right_arm": Vector2i(20, 11), "module": Vector2i(22, 12), "left_arm_pose": "down", "right_arm_pose": "ready", "module_pose": "blaster_ready"}),
		_frame("wall_slide_0", "wall_slide", 70, {"torso": Vector2i(12, 10), "torso_size": Vector2i(9, 10), "head": Vector2i(12, 3), "head_size": Vector2i(9, 8), "visor": Vector2i(14, 6), "visor_size": Vector2i(5, 2), "left_leg": Vector2i(12, 20), "right_leg": Vector2i(17, 22), "left_arm": Vector2i(10, 12), "right_arm": Vector2i(20, 13), "left_pack": Vector2i(10, 10), "right_pack": Vector2i(21, 10), "module": Vector2i(21, 14), "lean": 1, "left_arm_pose": "braced", "right_arm_pose": "ready", "module_pose": "blaster_ready", "sparks": true}),
		_frame("wall_slide_1", "wall_slide", 90, {"torso": Vector2i(12, 11), "torso_size": Vector2i(9, 10), "head": Vector2i(12, 4), "head_size": Vector2i(9, 8), "visor": Vector2i(14, 7), "visor_size": Vector2i(5, 2), "left_leg": Vector2i(13, 21), "right_leg": Vector2i(17, 20), "left_arm": Vector2i(10, 13), "right_arm": Vector2i(20, 12), "left_pack": Vector2i(10, 11), "right_pack": Vector2i(21, 11), "module": Vector2i(21, 13), "lean": 1, "left_arm_pose": "braced", "right_arm_pose": "ready", "module_pose": "blaster_ready", "sparks": true}),
		_frame("wall_kick_0", "wall_kick", 35, {"torso": Vector2i(10, 9), "head": Vector2i(10, 2), "left_leg": Vector2i(6, 17), "right_leg": Vector2i(18, 17), "left_arm": Vector2i(8, 10), "right_arm": Vector2i(20, 10), "left_pack": Vector2i(8, 8), "right_pack": Vector2i(21, 8), "module": Vector2i(22, 10), "lean": 2, "left_arm_pose": "kick", "right_arm_pose": "gun_aim", "module_pose": "blaster_ready", "sparks": true}),
		_frame("wall_kick_1", "wall_kick", 65, {"torso": Vector2i(11, 8), "head": Vector2i(11, 1), "left_leg": Vector2i(9, 17), "right_leg": Vector2i(18, 16), "left_arm": Vector2i(8, 9), "right_arm": Vector2i(20, 9), "left_pack": Vector2i(8, 7), "right_pack": Vector2i(21, 7), "module": Vector2i(22, 9), "lean": 1, "left_arm_pose": "up", "right_arm_pose": "ready", "module_pose": "blaster_ready"}),
		_frame("burst_start_0", "burst_start", 28, {"torso": Vector2i(11, 11), "head": Vector2i(11, 4), "left_leg": Vector2i(8, 18), "right_leg": Vector2i(18, 18), "left_arm": Vector2i(8, 13), "right_arm": Vector2i(20, 12), "module": Vector2i(22, 12), "left_arm_pose": "guard", "right_arm_pose": "guard", "module_pose": "blaster_ready", "flames": true, "flame_kind": "short"}),
		_frame("burst_start_1", "burst_start", 24, {"torso": Vector2i(11, 9), "head": Vector2i(11, 2), "left_leg": Vector2i(10, 17), "right_leg": Vector2i(17, 17), "left_arm": Vector2i(9, 9), "right_arm": Vector2i(20, 9), "left_pack": Vector2i(8, 8), "right_pack": Vector2i(21, 8), "module": Vector2i(22, 9), "left_arm_pose": "burst_tuck", "right_arm_pose": "burst_tuck", "module_pose": "blaster_ready", "flames": true, "flame_kind": "long"}),
		_frame("burst_loop_0", "burst_loop", 30, {"torso": Vector2i(11, 8), "head": Vector2i(11, 1), "left_leg": Vector2i(10, 17), "right_leg": Vector2i(17, 17), "left_arm": Vector2i(8, 8), "right_arm": Vector2i(20, 9), "left_pack": Vector2i(8, 7), "right_pack": Vector2i(21, 7), "module": Vector2i(22, 8), "left_arm_pose": "up", "right_arm_pose": "gun_aim", "module_pose": "blaster_ready", "flames": true, "flame_kind": "long"}),
		_frame("burst_loop_1", "burst_loop", 30, {"torso": Vector2i(11, 8), "head": Vector2i(11, 1), "left_leg": Vector2i(9, 17), "right_leg": Vector2i(18, 17), "left_arm": Vector2i(8, 8), "right_arm": Vector2i(20, 8), "left_pack": Vector2i(8, 7), "right_pack": Vector2i(21, 7), "module": Vector2i(22, 8), "left_arm_pose": "up", "right_arm_pose": "forward", "module_pose": "blaster_ready", "flames": true, "flame_kind": "long"}),
		_frame("burst_end_0", "burst_end", 28, {"torso": Vector2i(11, 9), "head": Vector2i(11, 2), "left_leg": Vector2i(9, 18), "right_leg": Vector2i(18, 18), "left_arm": Vector2i(8, 10), "right_arm": Vector2i(20, 10), "module": Vector2i(22, 10), "left_arm_pose": "down", "right_arm_pose": "ready", "module_pose": "blaster_ready", "flames": true, "flame_kind": "short"}),
		_frame("burst_end_1", "burst_end", 35, {"torso": Vector2i(11, 10), "head": Vector2i(11, 3), "left_leg": Vector2i(9, 19), "right_leg": Vector2i(18, 19), "left_arm": Vector2i(8, 11), "right_arm": Vector2i(20, 11), "module": Vector2i(22, 11), "left_arm_pose": "down", "right_arm_pose": "ready", "module_pose": "blaster_ready"}),
		_frame("gun_ground_0", "gun_ground", 45, {"torso": Vector2i(10, 10), "head": Vector2i(10, 3), "left_leg": Vector2i(8, 20), "right_leg": Vector2i(18, 19), "left_arm": Vector2i(7, 14), "right_arm": Vector2i(20, 10), "module": Vector2i(22, 10), "lean": 2, "left_arm_pose": "guard", "right_arm_pose": "gun_aim", "module_pose": "blaster_ready"}),
		_frame("gun_ground_1", "gun_ground", 20, {"torso": Vector2i(12, 10), "head": Vector2i(12, 3), "left_leg": Vector2i(9, 20), "right_leg": Vector2i(18, 20), "left_arm": Vector2i(8, 12), "right_arm": Vector2i(21, 9), "module": Vector2i(23, 9), "lean": -1, "left_arm_pose": "back", "right_arm_pose": "gun_recoil", "module_pose": "blaster_fire"}),
		_frame("gun_ground_2", "gun_ground", 55, {"torso": Vector2i(11, 10), "head": Vector2i(11, 3), "left_leg": Vector2i(10, 20), "right_leg": Vector2i(18, 19), "left_arm": Vector2i(9, 12), "right_arm": Vector2i(20, 11), "module": Vector2i(22, 11), "lean": 1, "left_arm_pose": "forward", "right_arm_pose": "ready", "module_pose": "blaster_ready"}),
		_frame("gun_air_0", "gun_air", 45, {"torso": Vector2i(10, 9), "head": Vector2i(10, 2), "left_leg": Vector2i(8, 18), "right_leg": Vector2i(17, 17), "left_arm": Vector2i(8, 10), "right_arm": Vector2i(20, 9), "module": Vector2i(22, 8), "lean": 1, "left_arm_pose": "up", "right_arm_pose": "gun_aim", "module_pose": "blaster_ready"}),
		_frame("gun_air_1", "gun_air", 20, {"torso": Vector2i(12, 9), "head": Vector2i(12, 2), "left_leg": Vector2i(9, 17), "right_leg": Vector2i(18, 18), "left_arm": Vector2i(8, 10), "right_arm": Vector2i(21, 8), "module": Vector2i(23, 7), "lean": -1, "left_arm_pose": "back", "right_arm_pose": "gun_recoil", "module_pose": "blaster_fire"}),
		_frame("gun_air_2", "gun_air", 50, {"torso": Vector2i(11, 9), "head": Vector2i(11, 2), "left_leg": Vector2i(10, 18), "right_leg": Vector2i(17, 18), "left_arm": Vector2i(8, 10), "right_arm": Vector2i(20, 9), "module": Vector2i(22, 9), "lean": 1, "left_arm_pose": "down", "right_arm_pose": "ready", "module_pose": "blaster_ready"}),
		_frame("blade_ground_0", "blade_ground", 70, {"torso": Vector2i(9, 10), "head": Vector2i(9, 3), "left_leg": Vector2i(8, 21), "right_leg": Vector2i(18, 18), "left_arm": Vector2i(6, 14), "right_arm": Vector2i(18, 8), "module": Vector2i(19, 6), "lean": 3, "left_arm_pose": "blade_guard_low", "right_arm_pose": "slash_windup", "module_pose": "windup"}),
		_frame("blade_ground_1", "blade_ground", 25, {"torso": Vector2i(13, 9), "head": Vector2i(13, 2), "left_leg": Vector2i(9, 21), "right_leg": Vector2i(18, 21), "left_arm": Vector2i(7, 11), "right_arm": Vector2i(22, 8), "module": Vector2i(23, 7), "lean": -2, "left_arm_pose": "back", "right_arm_pose": "slash_contact", "module_pose": "slash_contact", "blade_flash": true}),
		_frame("blade_ground_2", "blade_ground", 70, {"torso": Vector2i(11, 10), "head": Vector2i(11, 3), "left_leg": Vector2i(11, 20), "right_leg": Vector2i(18, 19), "left_arm": Vector2i(9, 12), "right_arm": Vector2i(20, 11), "module": Vector2i(22, 10), "lean": 1, "left_arm_pose": "forward", "right_arm_pose": "blade_ready", "module_pose": "recover"}),
		_frame("blade_air_0", "blade_air", 55, {"torso": Vector2i(9, 9), "head": Vector2i(9, 2), "left_leg": Vector2i(8, 18), "right_leg": Vector2i(17, 17), "left_arm": Vector2i(8, 9), "right_arm": Vector2i(18, 7), "module": Vector2i(19, 6), "lean": 2, "left_arm_pose": "up", "right_arm_pose": "slash_windup", "module_pose": "windup"}),
		_frame("blade_air_1", "blade_air", 25, {"torso": Vector2i(13, 8), "head": Vector2i(13, 1), "left_leg": Vector2i(10, 17), "right_leg": Vector2i(18, 19), "left_arm": Vector2i(8, 9), "right_arm": Vector2i(22, 7), "module": Vector2i(23, 6), "lean": -3, "left_arm_pose": "back", "right_arm_pose": "slash_contact", "module_pose": "slash_air", "blade_flash": true}),
		_frame("blade_air_2", "blade_air", 60, {"torso": Vector2i(11, 9), "head": Vector2i(11, 2), "left_leg": Vector2i(10, 18), "right_leg": Vector2i(17, 19), "left_arm": Vector2i(8, 10), "right_arm": Vector2i(20, 10), "module": Vector2i(22, 9), "lean": 1, "left_arm_pose": "down", "right_arm_pose": "blade_ready", "module_pose": "recover"}),
		_frame("hurt_0", "hurt", 45, {"torso": Vector2i(10, 10), "head": Vector2i(10, 3), "left_leg": Vector2i(8, 20), "right_leg": Vector2i(18, 21), "left_arm": Vector2i(7, 12), "right_arm": Vector2i(21, 14), "module": Vector2i(22, 15), "lean": -2, "damage": true, "left_arm_pose": "back", "right_arm_pose": "flinch", "module_pose": "blaster_ready"}),
		_frame("hurt_1", "hurt", 65, {"torso": Vector2i(12, 10), "head": Vector2i(12, 3), "left_leg": Vector2i(10, 20), "right_leg": Vector2i(18, 19), "left_arm": Vector2i(8, 13), "right_arm": Vector2i(20, 13), "module": Vector2i(22, 13), "lean": -1, "damage": true, "left_arm_pose": "guard", "right_arm_pose": "guard", "module_pose": "blaster_ready"}),
		_frame("hurt_blade_0", "hurt_blade", 45, {"torso": Vector2i(10, 10), "head": Vector2i(10, 3), "left_leg": Vector2i(8, 20), "right_leg": Vector2i(18, 21), "left_arm": Vector2i(7, 12), "right_arm": Vector2i(19, 13), "module": Vector2i(20, 12), "lean": -2, "damage": true, "left_arm_pose": "blade_guard_low", "right_arm_pose": "flinch", "module_pose": "blade_ready"}),
		_frame("hurt_blade_1", "hurt_blade", 65, {"torso": Vector2i(12, 10), "head": Vector2i(12, 3), "left_leg": Vector2i(10, 20), "right_leg": Vector2i(18, 19), "left_arm": Vector2i(8, 13), "right_arm": Vector2i(19, 12), "module": Vector2i(20, 11), "lean": -1, "damage": true, "left_arm_pose": "guard", "right_arm_pose": "blade_ready", "module_pose": "blade_ready"}),
	]


func _frame(name: String, tag_name: String, duration: int, overrides: Dictionary) -> Dictionary:
	var frame := BASE_MODEL.duplicate(true)
	for key in overrides.keys():
		frame[key] = overrides[key]
	frame["name"] = name
	frame["tag"] = tag_name
	frame["duration"] = duration
	return frame


func _draw_frame(image: Image, frame_index: int, frame: Dictionary) -> void:
	var offset := Vector2i(frame_index * FRAME_SIZE.x, 0)
	_draw_pack(image, offset + frame["left_pack"], true)
	_draw_pack(image, offset + frame["right_pack"], false)
	_draw_head(image, offset + frame["head"], frame["head_size"], frame["visor"], frame["visor_size"], frame.get("damage", false))
	_draw_torso(image, offset + frame["torso"], frame["torso_size"], int(frame.get("lean", 0)), frame.get("damage", false))
	_draw_arm(image, offset + frame["left_arm"], String(frame.get("left_arm_pose", "down")), true, frame.get("damage", false))
	_draw_arm(image, offset + frame["right_arm"], String(frame.get("right_arm_pose", "ready")), false, frame.get("damage", false))
	_draw_module(image, offset + frame["module"], String(frame.get("module_pose", "ready")), frame.get("damage", false))
	_draw_leg(image, offset + frame["left_leg"], true)
	_draw_leg(image, offset + frame["right_leg"], false)
	if frame.get("flames", false):
		_draw_flames(image, offset + Vector2i(10, 23), String(frame.get("flame_kind", "short")))
	if frame.get("sparks", false):
		_draw_sparks(image, offset + Vector2i(6, 21))
	if frame.get("blade_flash", false):
		_draw_blade_flash(image, offset + Vector2i(22, 5))


func _draw_head(image: Image, pos: Vector2i, size: Vector2i, visor_pos: Vector2i, visor_size: Vector2i, damaged: bool) -> void:
	_panel(image, pos, size, OUTLINE, BODY)
	_fill(image, pos + Vector2i(2, 0), Vector2i(size.x - 4, 1), HIGHLIGHT)
	_fill(image, pos + Vector2i(1, 1), Vector2i(size.x - 2, 2), HIGHLIGHT)
	_fill(image, pos + Vector2i(0, size.y - 2), Vector2i(size.x, 2), NOZZLE)
	_fill(image, pos + Vector2i(0, 2), Vector2i(1, size.y - 4), PANEL_DARK)
	_fill(image, pos + Vector2i(size.x - 1, 2), Vector2i(1, size.y - 4), PANEL_DARK)
	_fill(image, pos + Vector2i(2, -1), Vector2i(size.x - 4, 1), ORANGE_DARK)
	_px(image, pos + Vector2i(1, 0), BONE)
	_px(image, pos + Vector2i(size.x - 2, 0), BONE)
	_px(image, pos + Vector2i(-1, 3), NOZZLE)
	_px(image, pos + Vector2i(size.x, 3), NOZZLE)
	_px(image, pos + Vector2i(-1, 5), BOOT)
	_px(image, pos + Vector2i(size.x, 5), BOOT)
	_fill(image, visor_pos, visor_size, DAMAGE if damaged else TRIM)
	_fill(image, visor_pos + Vector2i(0, 1), Vector2i(visor_size.x, 1), ORANGE if damaged else TRIM_LIGHT)
	_fill(image, visor_pos + Vector2i(1, 0), Vector2i(maxi(1, visor_size.x - 2), 1), BONE if not damaged else ORANGE_DARK)
	_px(image, pos + Vector2i(size.x - 2, 1), ORANGE)
	_px(image, pos + Vector2i(1, size.y - 1), SHADOW)
	_px(image, pos + Vector2i(size.x - 2, size.y - 1), SHADOW)


func _draw_torso(image: Image, pos: Vector2i, size: Vector2i, lean: int, damaged: bool) -> void:
	var chest_width := size.x
	_fill(image, pos + Vector2i(1, 0), Vector2i(chest_width - 2, 1), OUTLINE)
	_fill(image, pos, Vector2i(chest_width, 2), BODY)
	_fill(image, pos + Vector2i(-1, 2), Vector2i(chest_width + 2, 2), BODY)
	_fill(image, pos + Vector2i(-1, 4), Vector2i(chest_width + 2, size.y - 6), BODY)
	_fill(image, pos + Vector2i(1, size.y - 2), Vector2i(chest_width - 2, 2), BODY)
	_fill(image, pos + Vector2i(1, 1), Vector2i(chest_width - 2, 2), HIGHLIGHT)
	_fill(image, pos + Vector2i(1 + maxi(lean, 0), 3), Vector2i(chest_width - 2, 3), DAMAGE if damaged else TRIM)
	_fill(image, pos + Vector2i(2 + maxi(lean, 0), 4), Vector2i(chest_width - 4, 1), ORANGE if damaged else TRIM_LIGHT)
	_fill(image, pos + Vector2i(2, 6), Vector2i(chest_width - 4, 2), PANEL_DARK)
	_fill(image, pos + Vector2i(3, size.y - 4), Vector2i(chest_width - 6, 2), NOZZLE)
	_fill(image, pos + Vector2i(0, 2), Vector2i(1, size.y - 4), OUTLINE)
	_fill(image, pos + Vector2i(chest_width - 1, 2), Vector2i(1, size.y - 4), OUTLINE)
	_fill(image, pos + Vector2i(-1, 2), Vector2i(1, 3), PANEL_DARK)
	_fill(image, pos + Vector2i(chest_width, 2), Vector2i(1, 3), PANEL_DARK)
	_px(image, pos + Vector2i(2, size.y - 2), SHADOW)
	_px(image, pos + Vector2i(chest_width - 3, size.y - 2), SHADOW)
	_px(image, pos + Vector2i(chest_width - 2, 1), ORANGE_DARK)


func _draw_arm(image: Image, pos: Vector2i, pose: String, left_side: bool, damaged: bool) -> void:
	var dir := -1 if left_side else 1
	_panel(image, pos, Vector2i(4, 5), OUTLINE, BODY)
	_fill(image, pos + Vector2i(1, 1), Vector2i(2, 1), HIGHLIGHT)
	_fill(image, pos + Vector2i(0, 3), Vector2i(4, 2), NOZZLE)
	_fill(image, pos + Vector2i(1, 4), Vector2i(2, 1), BOOT)
	if damaged:
		_fill(image, pos + Vector2i(1, 2), Vector2i(2, 1), DAMAGE)
	var elbow := pos + Vector2i(1 + dir, 5)
	var wrist := elbow + Vector2i(dir, 2)
	match pose:
		"gun_aim":
			wrist = pos + Vector2i(5 if not left_side else -2, 3)
		"gun_recoil":
			wrist = pos + Vector2i(4 if not left_side else -1, 2)
		"forward":
			wrist = pos + Vector2i(4 if not left_side else -1, 4)
		"back":
			wrist = pos + Vector2i(-2 if left_side else 5, 2)
		"up":
			elbow = pos + Vector2i(1, 1)
			wrist = pos + Vector2i(1 + dir, -2)
		"spread":
			wrist = pos + Vector2i(5 if not left_side else -2, 1)
		"fall_reach":
			wrist = pos + Vector2i(5 if not left_side else -2, 0)
		"braced":
			wrist = pos + Vector2i(0 if left_side else 3, 6)
		"guard":
			wrist = pos + Vector2i(1 + dir, 6)
		"blade_guard_low":
			wrist = pos + Vector2i(2 + dir, 7)
		"blade_ready":
			elbow = pos + Vector2i(2, 2)
			wrist = pos + Vector2i(5 if not left_side else -2, 1)
		"burst_tuck":
			elbow = pos + Vector2i(1, 3)
			wrist = pos + Vector2i(2, 1)
		"kick":
			elbow = pos + Vector2i(1, 1)
			wrist = pos + Vector2i(1 + dir, -2)
		"slash_windup":
			elbow = pos + Vector2i(0 if left_side else 3, 2)
			wrist = pos + Vector2i(-2 if left_side else 5, -1)
		"slash_contact":
			elbow = pos + Vector2i(2, 2)
			wrist = pos + Vector2i(6 if not left_side else -3, 1)
		"flinch":
			wrist = pos + Vector2i(0 if left_side else 3, 7)
		_:
			pass
	_line_segment(image, elbow, wrist, BODY)
	_px(image, elbow, HIGHLIGHT)
	_px(image, wrist, ORANGE if pose in ["gun_recoil", "slash_contact", "fall_reach"] else PANEL_DARK)
	if pose in ["gun_aim", "gun_recoil", "blade_ready", "slash_windup", "slash_contact"]:
		_px(image, wrist + Vector2i(dir, 0), HIGHLIGHT)


func _draw_module(image: Image, pos: Vector2i, pose: String, damaged: bool) -> void:
	_panel(image, pos, Vector2i(7, 4), OUTLINE, ORANGE_DARK)
	_fill(image, pos + Vector2i(1, 1), Vector2i(4, 1), HIGHLIGHT)
	_fill(image, pos + Vector2i(1, 2), Vector2i(2, 1), BODY)
	_fill(image, pos + Vector2i(3, 2), Vector2i(2, 1), DAMAGE if damaged else TRIM)
	if damaged:
		_fill(image, pos + Vector2i(5, 1), Vector2i(2, 2), DAMAGE)
		return
	match pose:
		"blaster_ready":
			_fill(image, pos + Vector2i(5, 1), Vector2i(2, 2), NOZZLE)
			_px(image, pos + Vector2i(7, 1), BONE)
			_px(image, pos + Vector2i(8, 1), TRIM_LIGHT)
		"blaster_fire":
			_fill(image, pos + Vector2i(5, 0), Vector2i(2, 3), TRIM)
			_px(image, pos + Vector2i(7, 1), BONE)
			_px(image, pos + Vector2i(8, 0), ORANGE)
			_px(image, pos + Vector2i(8, 1), BONE)
			_px(image, pos + Vector2i(9, 1), TRIM_LIGHT)
		"blade_ready":
			_fill(image, pos + Vector2i(4, -1), Vector2i(1, 4), TRIM)
			_px(image, pos + Vector2i(5, -2), BONE)
			_px(image, pos + Vector2i(6, -2), TRIM_LIGHT)
		"windup":
			_fill(image, pos + Vector2i(-1, 1), Vector2i(2, 2), NOZZLE)
			_px(image, pos + Vector2i(5, 0), ORANGE)
			_px(image, pos + Vector2i(6, 1), BONE)
		"slash_contact":
			_fill(image, pos + Vector2i(5, -1), Vector2i(2, 3), TRIM)
			_px(image, pos + Vector2i(6, -2), BONE)
			_px(image, pos + Vector2i(7, -2), TRIM_LIGHT)
			_px(image, pos + Vector2i(8, -3), BONE)
			_px(image, pos + Vector2i(8, -1), TRIM_LIGHT)
		"slash_air":
			_fill(image, pos + Vector2i(5, -2), Vector2i(2, 3), TRIM)
			_px(image, pos + Vector2i(7, -3), BONE)
			_px(image, pos + Vector2i(8, -4), TRIM_LIGHT)
			_px(image, pos + Vector2i(9, -4), BONE)
		"recover":
			_fill(image, pos + Vector2i(5, 1), Vector2i(2, 2), TRIM)
			_px(image, pos + Vector2i(7, 1), BONE)
		_:
			_px(image, pos + Vector2i(6, 1), BONE)
			_px(image, pos + Vector2i(7, 1), TRIM_LIGHT)


func _draw_leg(image: Image, pos: Vector2i, left_side: bool) -> void:
	_panel(image, pos, Vector2i(5, 8), OUTLINE, NOZZLE)
	_fill(image, pos + Vector2i(1, 1), Vector2i(3, 2), BODY)
	_fill(image, pos + Vector2i(1, 3), Vector2i(3, 2), PANEL_DARK)
	_fill(image, pos + Vector2i(1, 5), Vector2i(3, 1), HIGHLIGHT)
	_fill(image, pos + Vector2i(0, 6), Vector2i(5, 2), BOOT)
	_px(image, pos + Vector2i(4 if not left_side else 0, 7), SHADOW)
	_px(image, pos + Vector2i(5 if not left_side else -1, 7), SHADOW)


func _draw_pack(image: Image, pos: Vector2i, left_side: bool) -> void:
	_panel(image, pos, Vector2i(4, 9), OUTLINE, NOZZLE)
	_fill(image, pos + Vector2i(1, 1), Vector2i(2, 2), TRIM)
	_fill(image, pos + Vector2i(1, 2), Vector2i(1, 1), TRIM_LIGHT)
	_fill(image, pos + Vector2i(0, 4), Vector2i(4, 3), PANEL_DARK)
	_fill(image, pos + Vector2i(0, 7), Vector2i(4, 2), BOOT)
	_px(image, pos + Vector2i(1, 3), HIGHLIGHT)
	_px(image, pos + Vector2i(4 if left_side else -1, 3), OUTLINE)
	_px(image, pos + Vector2i(1, 8), SHADOW)
	_px(image, pos + Vector2i(2, 8), SHADOW)


func _draw_flames(image: Image, pos: Vector2i, flame_kind: String) -> void:
	var length := 6 if flame_kind == "long" else 4
	_fill(image, pos + Vector2i(0, 0), Vector2i(3, length), ORANGE_DARK)
	_fill(image, pos + Vector2i(8, 0), Vector2i(3, length), ORANGE_DARK)
	_fill(image, pos + Vector2i(1, 1), Vector2i(1, length + 1), ORANGE)
	_fill(image, pos + Vector2i(9, 1), Vector2i(1, length + 1), ORANGE)
	_fill(image, pos + Vector2i(1, length), Vector2i(1, 3), BONE)
	_fill(image, pos + Vector2i(9, length), Vector2i(1, 3), BONE)
	_px(image, pos + Vector2i(2, length + 1), TRIM_LIGHT)
	_px(image, pos + Vector2i(8, length + 1), TRIM_LIGHT)


func _draw_sparks(image: Image, pos: Vector2i) -> void:
	_px(image, pos + Vector2i(0, 1), ORANGE)
	_px(image, pos + Vector2i(2, 0), BONE)
	_px(image, pos + Vector2i(3, 2), TRIM_LIGHT)
	_px(image, pos + Vector2i(5, 1), ORANGE)
	_px(image, pos + Vector2i(6, 3), BONE)
	_px(image, pos + Vector2i(7, 5), ORANGE)
	_px(image, pos + Vector2i(4, 5), TRIM_LIGHT)


func _draw_blade_flash(image: Image, pos: Vector2i) -> void:
	_px(image, pos + Vector2i(0, 0), BONE)
	_px(image, pos + Vector2i(1, -1), TRIM_LIGHT)
	_px(image, pos + Vector2i(2, -2), BONE)
	_px(image, pos + Vector2i(3, -3), TRIM_LIGHT)
	_px(image, pos + Vector2i(4, -2), BONE)
	_px(image, pos + Vector2i(5, -1), TRIM_LIGHT)
	_px(image, pos + Vector2i(6, 0), BONE)


func _write_json(frames: Array[Dictionary]) -> Error:
	var frame_entries: Array = []
	var frame_tags: Array = []
	var current_tag := ""
	var tag_start := 0

	for index in range(frames.size()):
		var frame := frames[index]
		frame_entries.append(
			{
				"filename": frame["name"],
				"frame": {
					"x": index * FRAME_SIZE.x,
					"y": 0,
					"w": FRAME_SIZE.x,
					"h": FRAME_SIZE.y,
				},
				"rotated": false,
				"trimmed": false,
				"spriteSourceSize": {"x": 0, "y": 0, "w": FRAME_SIZE.x, "h": FRAME_SIZE.y},
				"sourceSize": {"w": FRAME_SIZE.x, "h": FRAME_SIZE.y},
				"duration": int(frame["duration"]),
			}
		)
		var tag_name := String(frame["tag"])
		if tag_name != current_tag:
			if not current_tag.is_empty():
				frame_tags.append({"name": current_tag, "from": tag_start, "to": index - 1, "direction": "forward"})
			current_tag = tag_name
			tag_start = index

	if not current_tag.is_empty():
		frame_tags.append({"name": current_tag, "from": tag_start, "to": frames.size() - 1, "direction": "forward"})

	var payload := {
		"frames": frame_entries,
		"meta": {
			"app": "godot-generator",
			"version": "1.0",
			"image": "player_sheet.png",
			"format": "RGBA8888",
			"size": {"w": FRAME_SIZE.x * frames.size(), "h": FRAME_SIZE.y},
			"scale": "1",
			"frameTags": frame_tags,
		},
	}

	var file := FileAccess.open(ProjectSettings.globalize_path(DATA_PATH), FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(payload, "\t"))
	return OK


func _panel(image: Image, pos: Vector2i, size: Vector2i, border: Color, fill_color: Color) -> void:
	_fill(image, pos, size, border)
	_fill(image, pos + Vector2i(1, 1), Vector2i(size.x - 2, size.y - 2), fill_color)


func _line_segment(image: Image, start: Vector2i, finish: Vector2i, color: Color) -> void:
	var delta := finish - start
	var steps := maxi(abs(delta.x), abs(delta.y))
	if steps <= 0:
		_px(image, start, color)
		return
	for step in range(steps + 1):
		var t := float(step) / float(steps)
		_px(image, start + Vector2i(roundi(delta.x * t), roundi(delta.y * t)), color)


func _fill(image: Image, pos: Vector2i, size: Vector2i, color: Color) -> void:
	for y in range(size.y):
		for x in range(size.x):
			_px(image, pos + Vector2i(x, y), color)


func _px(image: Image, pos: Vector2i, color: Color) -> void:
	if pos.x < 0 or pos.y < 0 or pos.x >= image.get_width() or pos.y >= image.get_height():
		return
	image.set_pixelv(pos, color)
