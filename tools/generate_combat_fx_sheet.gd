extends SceneTree

const FRAME_SIZE := Vector2i(32, 32)
const OUTPUT_PATH := "res://art/export/combat_fx_sheet.png"
const DATA_PATH := "res://art/export/combat_fx_sheet.json"
const PREVIEW_PATH := "res://art/export/combat_fx_sheet_preview.png"

const WARM_EDGE := Color8(244, 191, 118, 255)
const WARM_FILL := Color8(239, 155, 83, 255)
const COOL_EDGE := Color8(184, 247, 249, 255)
const COOL_FILL := Color8(77, 214, 229, 255)
const BONE := Color8(241, 237, 209, 255)
const INK := Color8(26, 38, 51, 255)


func _init() -> void:
	var frames := [
		{"name": "ground_slash_0", "tag": "ground_slash", "duration": 65},
		{"name": "ground_slash_1", "tag": "ground_slash", "duration": 30},
		{"name": "ground_slash_2", "tag": "ground_slash", "duration": 55},
		{"name": "air_slash_0", "tag": "air_slash", "duration": 60},
		{"name": "air_slash_1", "tag": "air_slash", "duration": 30},
		{"name": "air_slash_2", "tag": "air_slash", "duration": 55},
		{"name": "hit_confirm_0", "tag": "hit_confirm", "duration": 35},
		{"name": "hit_confirm_1", "tag": "hit_confirm", "duration": 75},
	]

	var image := Image.create(FRAME_SIZE.x * frames.size(), FRAME_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for frame_index in range(frames.size()):
		_draw_frame(image, frame_index, frames[frame_index])

	var save_error := image.save_png(ProjectSettings.globalize_path(OUTPUT_PATH))
	if save_error != OK:
		push_error("Failed to save %s (%s)" % [OUTPUT_PATH, save_error])
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


func _draw_frame(image: Image, frame_index: int, frame: Dictionary) -> void:
	var offset := Vector2i(frame_index * FRAME_SIZE.x, 0)
	match String(frame["tag"]):
		"ground_slash":
			_draw_ground_slash(image, offset, frame_index % 3)
		"air_slash":
			_draw_air_slash(image, offset, frame_index % 3)
		"hit_confirm":
			_draw_hit_confirm(image, offset, frame_index % 2)


func _draw_ground_slash(image: Image, offset: Vector2i, phase: int) -> void:
	var arcs := [
		[Vector2i(5, 20), Vector2i(11, 12), Vector2i(20, 6), Vector2i(28, 7), Vector2i(30, 11), Vector2i(25, 19), Vector2i(14, 24)],
		[Vector2i(3, 20), Vector2i(10, 10), Vector2i(21, 3), Vector2i(30, 4), Vector2i(31, 10), Vector2i(28, 20), Vector2i(13, 26)],
		[Vector2i(5, 21), Vector2i(12, 13), Vector2i(22, 8), Vector2i(29, 10), Vector2i(28, 15), Vector2i(23, 21), Vector2i(13, 25)],
	]
	var inner := [
		[Vector2i(8, 19), Vector2i(13, 13), Vector2i(20, 8), Vector2i(26, 9), Vector2i(27, 12), Vector2i(23, 18), Vector2i(15, 22)],
		[Vector2i(7, 19), Vector2i(14, 11), Vector2i(22, 5), Vector2i(28, 6), Vector2i(29, 10), Vector2i(26, 18), Vector2i(15, 23)],
		[Vector2i(8, 20), Vector2i(14, 14), Vector2i(22, 9), Vector2i(27, 10), Vector2i(26, 14), Vector2i(22, 19), Vector2i(15, 22)],
	]
	_fill_polygon(image, _offset_points(arcs[phase], offset), Color(WARM_FILL.r, WARM_FILL.g, WARM_FILL.b, 0.88))
	_fill_polygon(image, _offset_points(inner[phase], offset), Color(COOL_FILL.r, COOL_FILL.g, COOL_FILL.b, 0.92))
	_outline(image, _offset_points(arcs[phase], offset), WARM_EDGE)
	_outline(image, _offset_points(inner[phase], offset), COOL_EDGE)
	_line(image, offset + Vector2i(6, 20), offset + Vector2i(16, 14), Color(BONE.r, BONE.g, BONE.b, 0.84))
	_line(image, offset + Vector2i(10, 22), offset + Vector2i(20, 17), Color(COOL_EDGE.r, COOL_EDGE.g, COOL_EDGE.b, 0.72))
	_draw_trail(image, offset + Vector2i(4, 18), phase, false)


func _draw_air_slash(image: Image, offset: Vector2i, phase: int) -> void:
	var arcs := [
		[Vector2i(9, 26), Vector2i(13, 18), Vector2i(18, 10), Vector2i(24, 4), Vector2i(28, 3), Vector2i(31, 7), Vector2i(29, 14), Vector2i(22, 23), Vector2i(14, 28)],
		[Vector2i(8, 27), Vector2i(12, 17), Vector2i(18, 8), Vector2i(25, 2), Vector2i(30, 2), Vector2i(31, 7), Vector2i(30, 15), Vector2i(23, 25), Vector2i(13, 29)],
		[Vector2i(10, 25), Vector2i(14, 18), Vector2i(19, 12), Vector2i(24, 7), Vector2i(28, 6), Vector2i(30, 9), Vector2i(28, 15), Vector2i(22, 22), Vector2i(15, 27)],
	]
	var inner := [
		[Vector2i(12, 24), Vector2i(15, 18), Vector2i(19, 11), Vector2i(24, 6), Vector2i(28, 5), Vector2i(29, 8), Vector2i(27, 14), Vector2i(22, 21), Vector2i(16, 25)],
		[Vector2i(11, 25), Vector2i(15, 17), Vector2i(20, 10), Vector2i(25, 4), Vector2i(29, 4), Vector2i(30, 8), Vector2i(28, 15), Vector2i(22, 23), Vector2i(15, 26)],
		[Vector2i(12, 24), Vector2i(15, 18), Vector2i(20, 12), Vector2i(24, 8), Vector2i(27, 8), Vector2i(28, 10), Vector2i(26, 15), Vector2i(21, 21), Vector2i(16, 25)],
	]
	_fill_polygon(image, _offset_points(arcs[phase], offset), Color(WARM_FILL.r, WARM_FILL.g, WARM_FILL.b, 0.88))
	_fill_polygon(image, _offset_points(inner[phase], offset), Color(COOL_FILL.r, COOL_FILL.g, COOL_FILL.b, 0.92))
	_outline(image, _offset_points(arcs[phase], offset), WARM_EDGE)
	_outline(image, _offset_points(inner[phase], offset), COOL_EDGE)
	_line(image, offset + Vector2i(13, 24), offset + Vector2i(25, 8), Color(BONE.r, BONE.g, BONE.b, 0.84))
	_line(image, offset + Vector2i(16, 26), offset + Vector2i(26, 13), Color(COOL_EDGE.r, COOL_EDGE.g, COOL_EDGE.b, 0.72))
	_draw_trail(image, offset + Vector2i(8, 24), phase, true)


func _draw_hit_confirm(image: Image, offset: Vector2i, phase: int) -> void:
	var center := offset + Vector2i(16, 16)
	var arm_radius := 6 if phase == 0 else 10
	for x in range(-arm_radius, arm_radius + 1):
		_px(image, center + Vector2i(x, 0), WARM_EDGE if abs(x) > 2 else BONE)
		_px(image, center + Vector2i(0, x), WARM_EDGE if abs(x) > 2 else BONE)
	for point in [Vector2i(4, 4), Vector2i(-4, 4), Vector2i(4, -4), Vector2i(-4, -4)]:
		_px(image, center + point, COOL_EDGE)
		_px(image, center + point * 2, WARM_FILL if phase == 1 else COOL_FILL)
	_fill_polygon(image, _offset_points([Vector2i(16, 9), Vector2i(22, 16), Vector2i(16, 23), Vector2i(10, 16)], offset), Color(COOL_FILL.r, COOL_FILL.g, COOL_FILL.b, 0.9))
	_outline(image, _offset_points([Vector2i(16, 9), Vector2i(22, 16), Vector2i(16, 23), Vector2i(10, 16)], offset), COOL_EDGE)
	_fill_circle(image, center, 2 if phase == 0 else 3, BONE)
	if phase == 1:
		_line(image, center + Vector2i(-7, -1), center + Vector2i(7, -1), Color(BONE.r, BONE.g, BONE.b, 0.82))
		_line(image, center + Vector2i(-5, 3), center + Vector2i(5, 3), Color(COOL_EDGE.r, COOL_EDGE.g, COOL_EDGE.b, 0.72))


func _draw_trail(image: Image, start: Vector2i, phase: int, airborne: bool) -> void:
	var segments := [
		[Vector2i.ZERO, Vector2i(5, -2 if not airborne else -6), Vector2i(10, -4 if not airborne else -11)],
		[Vector2i.ZERO, Vector2i(7, -3 if not airborne else -9), Vector2i(14, -6 if not airborne else -15)],
		[Vector2i.ZERO, Vector2i(4, -2 if not airborne else -5), Vector2i(9, -4 if not airborne else -10)],
	]
	var path: Array = segments[phase]
	for index in range(path.size() - 1):
		_line(image, start + path[index], start + path[index + 1], COOL_FILL)
		_line(image, start + path[index] + Vector2i(1, 0), start + path[index + 1] + Vector2i(1, 0), BONE)
	_px(image, start + path[-1] + Vector2i(1, -1), WARM_FILL)


func _write_json(frames: Array) -> Error:
	var frame_entries: Array = []
	var frame_tags: Array = []
	var current_tag := ""
	var tag_start := 0

	for index in range(frames.size()):
		var frame: Dictionary = frames[index]
		frame_entries.append(
			{
				"filename": frame["name"],
				"frame": {"x": index * FRAME_SIZE.x, "y": 0, "w": FRAME_SIZE.x, "h": FRAME_SIZE.y},
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
			"image": "combat_fx_sheet.png",
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


func _offset_points(points: Array, offset: Vector2i) -> Array:
	var result: Array = []
	for point in points:
		result.append(point + offset)
	return result


func _fill_polygon(image: Image, points: Array, color: Color) -> void:
	var min_x := 9999
	var min_y := 9999
	var max_x := -9999
	var max_y := -9999
	for point in points:
		min_x = mini(min_x, point.x)
		min_y = mini(min_y, point.y)
		max_x = maxi(max_x, point.x)
		max_y = maxi(max_y, point.y)
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			if Geometry2D.is_point_in_polygon(Vector2(x, y), PackedVector2Array(points)):
				_px(image, Vector2i(x, y), color)


func _outline(image: Image, points: Array, color: Color) -> void:
	for index in range(points.size()):
		var start: Vector2i = points[index]
		var finish: Vector2i = points[(index + 1) % points.size()]
		_line(image, start, finish, color)


func _fill_circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for y in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			if x * x + y * y <= radius * radius:
				_px(image, center + Vector2i(x, y), color)


func _line(image: Image, start: Vector2i, finish: Vector2i, color: Color) -> void:
	var delta := finish - start
	var steps := maxi(abs(delta.x), abs(delta.y))
	if steps <= 0:
		_px(image, start, color)
		return
	for step in range(steps + 1):
		var t := float(step) / float(steps)
		_px(image, start + Vector2i(roundi(delta.x * t), roundi(delta.y * t)), color)


func _px(image: Image, pos: Vector2i, color: Color) -> void:
	if pos.x < 0 or pos.y < 0 or pos.x >= image.get_width() or pos.y >= image.get_height():
		return
	image.set_pixelv(pos, color)
