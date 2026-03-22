extends Node

const ACTIONS_TO_PERSIST: Array[String] = [
	"move_left",
	"move_right",
	"jump",
	"jetpack",
	"shoot",
	"swap_weapon",
	"restart",
]

var _profile: PlayerProfile


func _ready() -> void:
	load_profile()


func load_profile() -> void:
	_profile = PlayerProfile.load_profile()
	if _profile != null:
		var default_bindings := _profile.export_input_bindings(ACTIONS_TO_PERSIST)
		if _profile.sanitize_input_bindings(ACTIONS_TO_PERSIST, default_bindings):
			_profile.save_profile()
	_apply_all()


func save_profile() -> bool:
	if _profile == null:
		return false
	_profile.capture_current_input_bindings(ACTIONS_TO_PERSIST)
	return _profile.save_profile()


func get_setting(key: String) -> Variant:
	return _profile.get_setting(key) if _profile != null else null


func set_setting(key: String, value: Variant) -> void:
	if _profile == null:
		return
	_profile.set_setting(key, value)
	_apply_setting(key)


func get_selected_skin() -> String:
	return _profile.get_selected_skin() if _profile != null else SkinPalette.SKIN_HIVE_RUNNER


func set_selected_skin(id: String) -> bool:
	if _profile == null:
		return false
	var changed := _profile.set_selected_skin(id)
	return changed


func is_skin_unlocked(id: String) -> bool:
	return _profile != null and _profile.is_skin_unlocked(id)


func unlock_skin(id: String) -> bool:
	return _profile != null and _profile.unlock_skin(id)


func has_full_clear() -> bool:
	return _profile != null and _profile.has_full_clear()


func mark_full_clear() -> void:
	if _profile == null:
		return
	_profile.mark_full_clear()


func get_input_bindings() -> Dictionary:
	if _profile == null:
		return {}
	return _profile.get_input_bindings()


func set_input_bindings(bindings: Dictionary, apply_now: bool = true) -> void:
	if _profile == null:
		return
	_profile.set_input_bindings(bindings)
	if apply_now:
		_profile.apply_saved_input_bindings(ACTIONS_TO_PERSIST, true)
		_refresh_prompts()


func apply_input_bindings(bindings: Dictionary, clear_existing: bool = true) -> void:
	if _profile == null:
		return
	_profile.apply_input_bindings(bindings, clear_existing)
	_refresh_prompts()


func restore_saved_input_bindings() -> void:
	if _profile == null:
		return
	_profile.apply_saved_input_bindings(ACTIONS_TO_PERSIST, true)
	_refresh_prompts()


func get_default_settings() -> Dictionary:
	return PlayerProfile.DEFAULT_SETTINGS.duplicate(true)


func capture_current_input_bindings(action_names: Array[String] = ACTIONS_TO_PERSIST) -> void:
	if _profile == null:
		return
	_profile.capture_current_input_bindings(action_names)


func get_record(key: String) -> int:
	if _profile == null:
		return 0
	return _profile.get_record(key)


func get_records() -> Dictionary:
	if _profile == null:
		return PlayerProfile.DEFAULT_RECORDS.duplicate(true)
	return _profile.get_records()


func set_record(key: String, value: int) -> void:
	if _profile == null:
		return
	_profile.set_record(key, value)


func increment_record(key: String, amount: int = 1) -> void:
	if _profile == null:
		return
	_profile.increment_record(key, amount)


func set_record_max(key: String, value: int) -> void:
	if _profile == null:
		return
	_profile.set_record_max(key, value)


func _apply_all() -> void:
	if _profile == null:
		return
	_profile.apply_saved_input_bindings(ACTIONS_TO_PERSIST, true)
	for key_variant in PlayerProfile.DEFAULT_SETTINGS.keys():
		_apply_setting(String(key_variant))
	_refresh_prompts()


func _apply_setting(key: String) -> void:
	if _profile == null:
		return
	match key:
		"master":
			_set_bus_volume("Master", float(_profile.get_setting(key)))
		"music":
			_set_bus_volume("Music", float(_profile.get_setting(key)))
		"sfx":
			_set_bus_volume("SFX", float(_profile.get_setting(key)))
		"window_mode":
			_apply_window_mode(String(_profile.get_setting(key)))
		"prompt_style":
			_apply_prompt_style(String(_profile.get_setting(key)))


func _set_bus_volume(bus_name: String, scalar: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return
	var safe_scalar := clampf(scalar, 0.0, 1.0)
	var db := linear_to_db(safe_scalar) if safe_scalar > 0.0 else -80.0
	AudioServer.set_bus_volume_db(bus_index, db)


func _apply_window_mode(mode_name: String) -> void:
	match mode_name:
		"fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		"borderless":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _apply_prompt_style(style_name: String) -> void:
	var style := "Pixel"
	match style_name:
		"default":
			style = "Default"
		"1-bit":
			style = "1-bit"
		_:
			style = "Pixel"
	ProjectSettings.set_setting("addons/input_prompts/icons/style", style)
	if has_node("/root/PromptManager"):
		var prompt_manager := get_node("/root/PromptManager")
		if prompt_manager.has_method("_reload_textures"):
			prompt_manager.call("_reload_textures")
		elif prompt_manager.has_method("refresh"):
			prompt_manager.call("refresh")


func _refresh_prompts() -> void:
	if has_node("/root/PromptManager"):
		var prompt_manager := get_node("/root/PromptManager")
		if prompt_manager.has_method("refresh"):
			prompt_manager.call("refresh")
