extends Node

const MENU_SCENE := preload("res://scenes/main_menu.tscn")
const GAMEPLAY_SCENE := preload("res://scenes/main.tscn")
const TEST_SIZES := [
	Vector2i(1280, 720),
	Vector2i(1024, 576),
	Vector2i(800, 450),
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")


func _run() -> void:
	for viewport_size in TEST_SIZES:
		await _audit_menu(viewport_size, false)
		await _audit_menu(viewport_size, true)
		await _audit_gameplay(viewport_size, "title")
		await _audit_gameplay(viewport_size, "starter")
		await _audit_gameplay(viewport_size, "playing")
	print("UI_AUDIT_DONE")
	get_tree().quit()


func _audit_menu(viewport_size: Vector2i, terminal_mode: bool) -> void:
	get_window().size = viewport_size
	await get_tree().process_frame
	await get_tree().process_frame

	var menu: Node = MENU_SCENE.instantiate()
	add_child(menu)
	await get_tree().process_frame
	if terminal_mode:
		menu.set("_menu_mode", "terminal")
		menu.call("_refresh_terminal")
		await get_tree().process_frame

	_report_control_bounds(
		"main_menu:%s:%dx%d" % ["terminal" if terminal_mode else "attract", viewport_size.x, viewport_size.y],
		menu,
		menu.get_viewport().get_visible_rect().size
	)
	menu.queue_free()
	await get_tree().process_frame


func _audit_gameplay(viewport_size: Vector2i, mode: String) -> void:
	get_window().size = viewport_size
	await get_tree().process_frame
	await get_tree().process_frame

	var gameplay: Node = GAMEPLAY_SCENE.instantiate()
	add_child(gameplay)
	await get_tree().process_frame
	gameplay.set("game_flow", null)

	match mode:
		"title":
			gameplay.call("_enter_title")
		"starter":
			gameplay.call("_enter_starter_choice")
		"playing":
			gameplay.call("_enter_starter_choice")
			await get_tree().process_frame
			gameplay.set("_starter_weapon", "blade")
			gameplay.set("_preview_weapon_mode", "blade")
			gameplay.call("_begin_playable_slice")
			await get_tree().create_timer(0.15).timeout

	await get_tree().process_frame
	_report_control_bounds(
		"gameplay:%s:%dx%d" % [mode, viewport_size.x, viewport_size.y],
		gameplay,
		gameplay.get_viewport().get_visible_rect().size
	)
	gameplay.queue_free()
	await get_tree().process_frame


func _report_control_bounds(tag: String, root: Node, viewport_size: Vector2) -> void:
	var offenders: Array[String] = []
	_collect_offenders(root, viewport_size, offenders)
	if offenders.is_empty():
		print("%s OK" % tag)
		return
	print("%s OVERFLOW %d" % [tag, offenders.size()])
	for offender in offenders:
		print("  %s" % offender)


func _collect_offenders(node: Node, viewport_size: Vector2, offenders: Array[String]) -> void:
	if node is Control:
		var control := node as Control
		if control.is_visible_in_tree() and not _is_clipped_descendant(control):
			var rect := control.get_global_rect()
			if rect.size.x > 0.0 and rect.size.y > 0.0:
				var overflow_left := rect.position.x < -2.0
				var overflow_top := rect.position.y < -2.0
				var overflow_right := rect.end.x > viewport_size.x + 2.0
				var overflow_bottom := rect.end.y > viewport_size.y + 2.0
				if overflow_left or overflow_top or overflow_right or overflow_bottom:
					offenders.append("%s rect=%s viewport=%s" % [control.get_path(), rect, Rect2(Vector2.ZERO, viewport_size)])
	for child in node.get_children():
		_collect_offenders(child, viewport_size, offenders)


func _is_clipped_descendant(control: Control) -> bool:
	var current: Node = control.get_parent()
	while current != null:
		if current is Control and (current as Control).clip_contents:
			return true
		current = current.get_parent()
	return false
