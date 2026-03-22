extends RefCounted
class_name SpriteSheetLibrary

static var _cache := {}


static func load_sheet(data_path: String) -> Dictionary:
	if _cache.has(data_path):
		return _cache[data_path]

	var result := {
		"frames": [],
		"tags": {},
		"size": Vector2i.ZERO,
	}

	var absolute_path := ProjectSettings.globalize_path(data_path)
	if not FileAccess.file_exists(absolute_path):
		_cache[data_path] = result
		return result

	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(absolute_path))
	if typeof(parsed) != TYPE_DICTIONARY:
		_cache[data_path] = result
		return result

	var source: Dictionary = parsed
	var frames_source: Variant = source.get("frames", [])
	var frame_entries: Array = []

	if typeof(frames_source) == TYPE_ARRAY:
		frame_entries = frames_source
	elif typeof(frames_source) == TYPE_DICTIONARY:
		for key in frames_source.keys():
			var frame_entry: Dictionary = frames_source[key]
			frame_entry["filename"] = key
			frame_entries.append(frame_entry)

	for index in range(frame_entries.size()):
		var frame_entry: Dictionary = frame_entries[index]
		var rect_data: Dictionary = frame_entry.get("frame", {})
		result["frames"].append(
			{
				"index": index,
				"filename": String(frame_entry.get("filename", "")),
				"duration": maxf(float(frame_entry.get("duration", 100.0)) / 1000.0, 0.001),
				"rect": Rect2i(
					int(rect_data.get("x", 0)),
					int(rect_data.get("y", 0)),
					int(rect_data.get("w", 0)),
					int(rect_data.get("h", 0))
				),
			}
		)

	var meta: Dictionary = source.get("meta", {})
	var size_data: Dictionary = meta.get("size", {})
	result["size"] = Vector2i(int(size_data.get("w", 0)), int(size_data.get("h", 0)))

	for tag_entry in meta.get("frameTags", []):
		var tag_data: Dictionary = tag_entry
		var tag_name := String(tag_data.get("name", ""))
		if tag_name.is_empty():
			continue

		var start := int(tag_data.get("from", 0))
		var finish := int(tag_data.get("to", start))
		var direction := String(tag_data.get("direction", "forward"))
		var frame_ids: Array[int] = _build_frame_id_sequence(start, finish, direction)
		var durations: Array[float] = []
		var total_duration := 0.0

		for frame_id in frame_ids:
			var frame_info := get_frame(result, frame_id)
			var duration := maxf(float(frame_info.get("duration", 0.08)), 0.001)
			durations.append(duration)
			total_duration += duration

		result["tags"][tag_name] = {
			"frames": frame_ids,
			"durations": durations,
			"total_duration": total_duration,
			"direction": direction,
		}

	_cache[data_path] = result
	return result


static func clear_cache(data_path: String = "") -> void:
	if data_path.is_empty():
		_cache.clear()
		return
	_cache.erase(data_path)


static func has_tag(sheet_data: Dictionary, tag_name: String) -> bool:
	return sheet_data.get("tags", {}).has(tag_name)


static func get_frame(sheet_data: Dictionary, frame_index: int) -> Dictionary:
	var frames: Array = sheet_data.get("frames", [])
	if frames.is_empty():
		return {"index": 0, "duration": 0.08, "rect": Rect2i(0, 0, 32, 32)}
	var safe_index := clampi(frame_index, 0, frames.size() - 1)
	return frames[safe_index]


static func get_frame_rect(sheet_data: Dictionary, frame_index: int) -> Rect2:
	var frame := get_frame(sheet_data, frame_index)
	return Rect2(frame.get("rect", Rect2i(0, 0, 32, 32)))


static func get_tag_total_duration(sheet_data: Dictionary, tag_name: String, fallback: float = 0.12) -> float:
	var tags: Dictionary = sheet_data.get("tags", {})
	if not tags.has(tag_name):
		return fallback
	return maxf(float(tags[tag_name].get("total_duration", fallback)), 0.001)


static func get_frame_for_time(sheet_data: Dictionary, tag_name: String, elapsed: float, hold_on_last: bool = false) -> int:
	var tags: Dictionary = sheet_data.get("tags", {})
	if not tags.has(tag_name):
		return 0

	var tag: Dictionary = tags[tag_name]
	var frames: Array = tag.get("frames", [])
	var durations: Array = tag.get("durations", [])
	if frames.is_empty():
		return 0

	if hold_on_last:
		var remaining := maxf(elapsed, 0.0)
		for index in range(frames.size()):
			var duration := float(durations[index])
			if remaining <= duration or index == frames.size() - 1:
				return int(frames[index])
			remaining -= duration
		return int(frames[-1])

	var total_duration := maxf(float(tag.get("total_duration", 0.001)), 0.001)
	var wrapped := fposmod(elapsed, total_duration)
	for index in range(frames.size()):
		var duration := float(durations[index])
		if wrapped <= duration or index == frames.size() - 1:
			return int(frames[index])
		wrapped -= duration
	return int(frames[0])


static func get_tag_frame_position(sheet_data: Dictionary, tag_name: String, elapsed: float, hold_on_last: bool = false) -> int:
	var tags: Dictionary = sheet_data.get("tags", {})
	if not tags.has(tag_name):
		return 0

	var tag: Dictionary = tags[tag_name]
	var frames: Array = tag.get("frames", [])
	var durations: Array = tag.get("durations", [])
	if frames.is_empty():
		return 0

	if hold_on_last:
		var remaining := maxf(elapsed, 0.0)
		for index in range(frames.size()):
			var duration := float(durations[index])
			if remaining <= duration or index == frames.size() - 1:
				return index
			remaining -= duration
		return frames.size() - 1

	var total_duration := maxf(float(tag.get("total_duration", 0.001)), 0.001)
	var wrapped := fposmod(elapsed, total_duration)
	for index in range(frames.size()):
		var duration := float(durations[index])
		if wrapped <= duration or index == frames.size() - 1:
			return index
		wrapped -= duration
	return 0


static func _build_frame_id_sequence(start: int, finish: int, direction: String) -> Array[int]:
	var ids: Array[int] = []
	if finish < start:
		var swap := start
		start = finish
		finish = swap

	match direction:
		"reverse":
			for index in range(finish, start - 1, -1):
				ids.append(index)
		"pingpong":
			for index in range(start, finish + 1):
				ids.append(index)
			for index in range(finish - 1, start, -1):
				ids.append(index)
		"pingpong_reverse":
			for index in range(finish, start - 1, -1):
				ids.append(index)
			for index in range(start + 1, finish, 1):
				ids.append(index)
		_:
			for index in range(start, finish + 1):
				ids.append(index)
	return ids
