extends Node

const MAIN_MENU_SCENE := "res://scenes/main_menu.tscn"
const GAMEPLAY_SCENE := "res://scenes/main.tscn"
const BOOT_CONTRACT := "contract"

var _pending_boot_mode := ""


func launch_contract() -> void:
	_pending_boot_mode = BOOT_CONTRACT
	get_tree().change_scene_to_file(GAMEPLAY_SCENE)


func return_to_menu() -> void:
	_pending_boot_mode = ""
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func consume_boot_mode(default_mode: String = "") -> String:
	var mode := _pending_boot_mode if not _pending_boot_mode.is_empty() else default_mode
	_pending_boot_mode = ""
	return mode
