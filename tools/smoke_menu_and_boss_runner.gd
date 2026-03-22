extends Node

const MENU_SCENE := preload("res://scenes/main_menu.tscn")
const GAMEPLAY_SCENE := preload("res://scenes/main.tscn")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")


func _run() -> void:
	var menu: Node = MENU_SCENE.instantiate()
	add_child(menu)
	await get_tree().process_frame
	_assert(is_instance_valid(menu), "Main menu failed to instantiate.")
	menu.queue_free()
	await get_tree().process_frame

	var gameplay: Node = GAMEPLAY_SCENE.instantiate()
	add_child(gameplay)
	await get_tree().process_frame
	gameplay.set("game_flow", null)
	gameplay.call("_enter_starter_choice")
	await get_tree().process_frame
	gameplay.set("_starter_weapon", "blade")
	gameplay.set("_preview_weapon_mode", "blade")
	gameplay.call("_begin_playable_slice")
	await get_tree().create_timer(0.2).timeout
	_assert(String(gameplay.get("_state")) == "playing", "Gameplay never reached active run state. Current state: %s" % String(gameplay.get("_state")))

	gameplay.call("_start_cave_transfer")
	await get_tree().process_frame
	await get_tree().process_frame
	gameplay.call("_finish_cave_transfer")
	await get_tree().process_frame
	_assert(String(gameplay.get("_route_phase")) == "cave", "Cave transfer did not finish cleanly.")

	gameplay.call("_start_cave_boss")
	await get_tree().create_timer(0.1).timeout
	_assert(String(gameplay.get("_route_phase")) == "boss", "Boss phase did not start.")

	gameplay.call("_on_rival_boss_defeated", Vector2(1240.0, 188.0))
	await get_tree().process_frame
	_assert(String(gameplay.get("_route_phase")) == "reward", "Boss defeat did not advance into reward state.")

	gameplay.call("_on_weapon_salvage_collected", "gun")
	await get_tree().process_frame
	gameplay.call("_start_transfer_outro")
	await get_tree().process_frame
	gameplay.call("_finish_transfer_outro")
	await get_tree().create_timer(2.1).timeout
	_assert(String(gameplay.get("_state")) == "title", "Clear flow did not resolve back to title state.")

	print("SMOKE_OK menu -> contract -> cave -> boss -> clear")
	get_tree().quit()


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	get_tree().quit(1)
