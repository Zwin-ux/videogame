extends RefCounted
class_name PlayerProfile

const DEFAULT_PROFILE_PATH := "user://player_profile.cfg"

const SETTINGS_SECTION := "settings"
const PROGRESS_SECTION := "progress"
const SKINS_SECTION := "skins"
const INPUTS_SECTION := "inputs"
const RECORDS_SECTION := "records"

const SKIN_HIVE_RUNNER := "hive_runner"
const SKIN_BLUE_SQUADRON := "blue_squadron"
const SKIN_NIGHT_QUEEN := "night_queen"

const DEFAULT_SETTINGS := {
	"master": 1.0,
	"music": 1.0,
	"sfx": 1.0,
	"window_mode": "windowed",
	"pixel_scale": 2,
	"ui_scale": 1.0,
	"prompt_style": "pixel",
}

const DEFAULT_RECORDS := {
	"best_altitude_m": 0,
	"runs_started": 0,
	"bugs_liquidated": 0,
	"rival_clears": 0,
	"hive_regions_cleansed": 0,
	"skyline_regions_cleansed": 0,
	"alpha_demo_clears": 0,
}

const DEFAULT_UNLOCKED_SKINS := [SKIN_HIVE_RUNNER, SKIN_BLUE_SQUADRON]
const DEFAULT_SELECTED_SKIN := SKIN_HIVE_RUNNER

var _profile_path: String = DEFAULT_PROFILE_PATH
var _settings: Dictionary = {}
var _unlocked_skins: Dictionary = {}
var _selected_skin: String = DEFAULT_SELECTED_SKIN
var _full_clear: bool = false
var _input_bindings: Dictionary = {}
var _records: Dictionary = {}


func _init(profile_path: String = DEFAULT_PROFILE_PATH) -> void:
	_profile_path = profile_path
	_reset_defaults()


static func load_profile(profile_path: String = DEFAULT_PROFILE_PATH) -> PlayerProfile:
	var profile := PlayerProfile.new(profile_path)
	profile._load_from_disk()
	return profile


func save_profile() -> bool:
	var config := ConfigFile.new()

	for key_variant in _settings.keys():
		var key := String(key_variant)
		config.set_value(SETTINGS_SECTION, key, _settings[key])

	config.set_value(PROGRESS_SECTION, "selected_skin", _selected_skin)
	config.set_value(PROGRESS_SECTION, "full_clear", _full_clear)
	config.set_value(SKINS_SECTION, "unlocked", _get_unlocked_skin_ids())
	config.set_value(INPUTS_SECTION, "bindings", _serialize_input_bindings())
	for key_variant in _records.keys():
		var key := String(key_variant)
		config.set_value(RECORDS_SECTION, key, int(_records[key]))

	var directory := _profile_path.get_base_dir()
	if not directory.is_empty():
		DirAccess.make_dir_recursive_absolute(directory)

	return config.save(_profile_path) == OK


func get_setting(key: String) -> Variant:
	if _settings.has(key):
		return _settings[key]
	return null


func set_setting(key: String, value: Variant) -> void:
	_settings[key] = _coerce_setting_value(key, value)


func get_selected_skin() -> String:
	return _selected_skin


func set_selected_skin(id: String) -> bool:
	if id.is_empty():
		return false
	if not is_skin_unlocked(id):
		return false

	_selected_skin = id
	return true


func is_skin_unlocked(id: String) -> bool:
	return bool(_unlocked_skins.get(id, false))


func unlock_skin(id: String) -> bool:
	if id.is_empty():
		return false
	if id == SKIN_NIGHT_QUEEN and not _full_clear:
		return false

	var was_unlocked := is_skin_unlocked(id)
	_unlocked_skins[id] = true
	return not was_unlocked


func has_full_clear() -> bool:
	return _full_clear


func mark_full_clear() -> void:
	_full_clear = true
	_unlocked_skins[SKIN_NIGHT_QUEEN] = true


func get_input_bindings() -> Dictionary:
	return _duplicate_bindings(_input_bindings)


func set_input_bindings(bindings: Dictionary) -> void:
	_input_bindings = _duplicate_bindings(bindings)


func get_record(key: String) -> int:
	return int(_records.get(key, DEFAULT_RECORDS.get(key, 0)))


func get_records() -> Dictionary:
	return _records.duplicate(true)


func set_record(key: String, value: int) -> void:
	if not DEFAULT_RECORDS.has(key):
		return
	_records[key] = maxi(0, int(value))


func increment_record(key: String, amount: int = 1) -> void:
	set_record(key, get_record(key) + amount)


func set_record_max(key: String, value: int) -> void:
	set_record(key, maxi(get_record(key), value))


func capture_current_input_bindings(action_names: Array = []) -> void:
	_input_bindings = export_input_bindings(action_names)


func apply_saved_input_bindings(action_names: Array = [], clear_existing: bool = true) -> void:
	var bindings := get_input_bindings()
	if bindings.is_empty():
		return
	if action_names.is_empty():
		apply_input_bindings(bindings, clear_existing)
		return

	var filtered: Dictionary = {}
	for action_name in action_names:
		if bindings.has(action_name):
			filtered[action_name] = bindings[action_name]
	apply_input_bindings(filtered, clear_existing)


func sanitize_input_bindings(action_names: Array = [], fallback_bindings: Dictionary = {}) -> bool:
	var changed := false
	var working_bindings := _duplicate_bindings(_input_bindings)
	var target_actions: Array[String] = []

	if action_names.is_empty():
		for action_variant in working_bindings.keys():
			target_actions.append(String(action_variant))
	else:
		for action_variant in action_names:
			target_actions.append(String(action_variant))

	for action_name in target_actions:
		var events_variant: Variant = working_bindings.get(action_name, [])
		if not (events_variant is Array):
			continue
		var seen: Dictionary = {}
		var deduped: Array = []
		for event_variant in events_variant:
			if not (event_variant is InputEvent):
				continue
			var event := event_variant as InputEvent
			var fingerprint := _event_fingerprint(event)
			if seen.has(fingerprint):
				changed = true
				continue
			seen[fingerprint] = true
			deduped.append(event.duplicate())
		working_bindings[action_name] = deduped

	changed = _sanitize_exclusive_actions(
		working_bindings,
		["jump", "shoot", "swap_weapon", "restart"],
		fallback_bindings
	) or changed

	if changed:
		_input_bindings = _duplicate_bindings(working_bindings)
	return changed


func export_input_bindings(action_names: Array = []) -> Dictionary:
	var exported: Dictionary = {}
	var source_actions: Array = action_names

	if source_actions.is_empty():
		source_actions = InputMap.get_actions()

	for action_name_variant in source_actions:
		var action_name := String(action_name_variant)
		var events: Array = []
		for event in InputMap.action_get_events(action_name):
			if event is InputEvent:
				events.append((event as InputEvent).duplicate())
		exported[action_name] = events

	return exported


func apply_input_bindings(bindings: Dictionary, clear_existing: bool = true) -> void:
	for action_name_variant in bindings.keys():
		var action_name := String(action_name_variant)
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		if clear_existing:
			InputMap.action_erase_events(action_name)

		var events_variant: Variant = bindings[action_name_variant]
		if events_variant is Array:
			for event_variant in events_variant:
				if event_variant is InputEvent:
					InputMap.action_add_event(action_name, (event_variant as InputEvent).duplicate())


func get_profile_path() -> String:
	return _profile_path


func _load_from_disk() -> void:
	_reset_defaults()

	var config := ConfigFile.new()
	if config.load(_profile_path) != OK:
		return

	_read_settings(config)
	_read_progress(config)
	_read_unlocked_skins(config)
	_read_input_bindings(config)
	_read_records(config)
	_normalize_state()


func _reset_defaults() -> void:
	_settings = DEFAULT_SETTINGS.duplicate(true)
	_unlocked_skins = {}
	_input_bindings = {}
	_records = DEFAULT_RECORDS.duplicate(true)

	for skin_id in DEFAULT_UNLOCKED_SKINS:
		_unlocked_skins[skin_id] = true

	_selected_skin = DEFAULT_SELECTED_SKIN
	_full_clear = false


func _read_settings(config: ConfigFile) -> void:
	for key_variant in config.get_section_keys(SETTINGS_SECTION):
		var key := String(key_variant)
		var fallback: Variant = _settings.get(key, null)
		_settings[key] = _coerce_setting_value(key, config.get_value(SETTINGS_SECTION, key, fallback))


func _read_progress(config: ConfigFile) -> void:
	_selected_skin = String(config.get_value(PROGRESS_SECTION, "selected_skin", _selected_skin))
	_full_clear = bool(config.get_value(PROGRESS_SECTION, "full_clear", _full_clear))


func _read_unlocked_skins(config: ConfigFile) -> void:
	var unlocked_value: Variant = config.get_value(SKINS_SECTION, "unlocked", null)
	if unlocked_value is Array or unlocked_value is PackedStringArray:
		for skin_variant in unlocked_value:
			var skin_id := String(skin_variant)
			if not skin_id.is_empty():
				_unlocked_skins[skin_id] = true


func _read_records(config: ConfigFile) -> void:
	for key_variant in DEFAULT_RECORDS.keys():
		var key := String(key_variant)
		_records[key] = _coerce_record_value(config.get_value(RECORDS_SECTION, key, DEFAULT_RECORDS[key]), int(DEFAULT_RECORDS[key]))


func _normalize_state() -> void:
	for skin_id in DEFAULT_UNLOCKED_SKINS:
		_unlocked_skins[skin_id] = true

	if _full_clear:
		_unlocked_skins[SKIN_NIGHT_QUEEN] = true
	else:
		_unlocked_skins.erase(SKIN_NIGHT_QUEEN)

	if _selected_skin.is_empty() or not is_skin_unlocked(_selected_skin):
		_selected_skin = _first_available_skin()

	for key_variant in DEFAULT_RECORDS.keys():
		var key := String(key_variant)
		_records[key] = _coerce_record_value(_records.get(key, DEFAULT_RECORDS[key]), int(DEFAULT_RECORDS[key]))


func _read_input_bindings(config: ConfigFile) -> void:
	var serialized: Variant = config.get_value(INPUTS_SECTION, "bindings", {})
	if not (serialized is Dictionary):
		return

	_input_bindings = {}
	for action_variant in serialized.keys():
		var action_name := String(action_variant)
		var serialized_events: Variant = serialized[action_variant]
		if not (serialized_events is Array):
			continue
		var restored_events: Array = []
		for encoded_variant in serialized_events:
			if not (encoded_variant is String):
				continue
			var event: Variant = str_to_var(String(encoded_variant))
			if event is InputEvent:
				restored_events.append((event as InputEvent).duplicate())
		if not restored_events.is_empty():
			_input_bindings[action_name] = restored_events


func _first_available_skin() -> String:
	for skin_id in DEFAULT_UNLOCKED_SKINS:
		if is_skin_unlocked(skin_id):
			return skin_id

	for skin_variant in _unlocked_skins.keys():
		var skin_id := String(skin_variant)
		if is_skin_unlocked(skin_id):
			return skin_id

	return DEFAULT_SELECTED_SKIN


func _get_unlocked_skin_ids() -> Array[String]:
	var ordered_ids: Array[String] = []

	for skin_id in DEFAULT_UNLOCKED_SKINS:
		if is_skin_unlocked(skin_id):
			ordered_ids.append(skin_id)

	var extra_ids: Array[String] = []
	for skin_variant in _unlocked_skins.keys():
		var skin_id := String(skin_variant)
		if ordered_ids.has(skin_id):
			continue
		if is_skin_unlocked(skin_id):
			extra_ids.append(skin_id)

	extra_ids.sort()
	ordered_ids.append_array(extra_ids)
	return ordered_ids


func _serialize_input_bindings() -> Dictionary:
	var serialized: Dictionary = {}
	for action_variant in _input_bindings.keys():
		var action_name := String(action_variant)
		var events_variant: Variant = _input_bindings[action_variant]
		if not (events_variant is Array):
			continue
		var encoded: Array[String] = []
		for event_variant in events_variant:
			if event_variant is InputEvent:
				encoded.append(var_to_str(event_variant))
		if not encoded.is_empty():
			serialized[action_name] = encoded
	return serialized


func _duplicate_bindings(bindings: Dictionary) -> Dictionary:
	var duplicated: Dictionary = {}
	for action_variant in bindings.keys():
		var action_name := String(action_variant)
		var events_variant: Variant = bindings[action_variant]
		if not (events_variant is Array):
			continue
		var copied_events: Array = []
		for event_variant in events_variant:
			if event_variant is InputEvent:
				copied_events.append((event_variant as InputEvent).duplicate())
		duplicated[action_name] = copied_events
	return duplicated


func _sanitize_exclusive_actions(bindings: Dictionary, action_group: Array[String], fallback_bindings: Dictionary) -> bool:
	var changed := false
	var seen: Dictionary = {}

	for action_name in action_group:
		var events_variant: Variant = bindings.get(action_name, [])
		var kept_events: Array = []
		if events_variant is Array:
			for event_variant in events_variant:
				if not (event_variant is InputEvent):
					continue
				var event := event_variant as InputEvent
				var fingerprint := _event_fingerprint(event)
				if seen.has(fingerprint):
					changed = true
					continue
				seen[fingerprint] = action_name
				kept_events.append(event.duplicate())

		if kept_events.is_empty():
			var fallback_variant: Variant = fallback_bindings.get(action_name, [])
			if fallback_variant is Array:
				for event_variant in fallback_variant:
					if not (event_variant is InputEvent):
						continue
					var event := event_variant as InputEvent
					var fingerprint := _event_fingerprint(event)
					if seen.has(fingerprint):
						continue
					seen[fingerprint] = action_name
					kept_events.append(event.duplicate())
			if not kept_events.is_empty():
				changed = true

		bindings[action_name] = kept_events

	return changed


func _event_fingerprint(event: InputEvent) -> String:
	return var_to_str(event)


func _coerce_setting_value(key: String, value: Variant) -> Variant:
	if value == null:
		return DEFAULT_SETTINGS.get(key, null)

	match key:
		"master", "music", "sfx", "ui_scale":
			if value is int or value is float:
				return float(value)
			if value is String and String(value).is_valid_float():
				return float(String(value))
			return float(DEFAULT_SETTINGS.get(key, 0.0))
		"pixel_scale":
			if value is int or value is float:
				return max(1, int(value))
			if value is String and String(value).is_valid_int():
				return max(1, int(value))
			return int(DEFAULT_SETTINGS.get(key, 1))
		"window_mode", "prompt_style":
			return String(value)
		_:
			return value


func _coerce_record_value(value: Variant, fallback: int) -> int:
	if value is int or value is float:
		return maxi(0, int(value))
	if value is String and String(value).is_valid_int():
		return maxi(0, int(value))
	return fallback
