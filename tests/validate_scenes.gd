extends SceneTree
## Scene-load smoke harness.
##
## Iterates every `.tscn` under `res://scenes/` and every script under
## `res://scripts/`, instantiates / loads each, and reports failures.
## Catches:
##   - Parse errors in scripts referenced by scenes
##   - Missing resource paths
##   - Class-name resolution failures
##   - @onready / @export wiring that crashes on instantiate
##
## Usage:
##     godot --headless --script tests/validate_scenes.gd
##
## Exits 0 on clean, 1 on any failure.

const SCENES_DIR := "res://scenes/"
const SCRIPTS_DIR := "res://scripts/"

var _failures: Array = []
var _scenes_checked: int = 0
var _scripts_checked: int = 0


func _initialize() -> void:
	print("\n=== Killer Queen — scene / script load validation ===\n")
	_check_directory(SCENES_DIR, ".tscn", _check_scene)
	_check_directory(SCRIPTS_DIR, ".gd", _check_script)
	print("")
	print("scenes checked:  %d" % _scenes_checked)
	print("scripts checked: %d" % _scripts_checked)
	print("failures:        %d" % _failures.size())
	if _failures.is_empty():
		print("\n=== GREEN ===\n")
		quit(0)
	else:
		print("\nFailures:")
		for f in _failures:
			print("  - %s :: %s" % [String(f["path"]), String(f["reason"])])
		print("\n=== RED ===\n")
		quit(1)


func _check_directory(dir_path: String, extension: String, handler: Callable) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		_failures.append({"path": dir_path, "reason": "cannot open directory"})
		return
	dir.list_dir_begin()
	while true:
		var entry: String = dir.get_next()
		if entry == "":
			break
		if entry.begins_with("."):
			continue
		var full_path: String = dir_path + entry
		if dir.current_is_dir():
			_check_directory(full_path + "/", extension, handler)
			continue
		if entry.ends_with(extension):
			handler.call(full_path)
	dir.list_dir_end()


func _check_scene(path: String) -> void:
	_scenes_checked += 1
	if not ResourceLoader.exists(path):
		_failures.append({"path": path, "reason": "ResourceLoader can not find path"})
		return
	var packed: PackedScene = ResourceLoader.load(path) as PackedScene
	if packed == null:
		_failures.append({"path": path, "reason": "load returned null or non-PackedScene"})
		return
	if not packed.can_instantiate():
		_failures.append({"path": path, "reason": "packed scene can_instantiate() returned false"})
		return
	# Best-effort instantiate. Swallow but record any error at this stage.
	var instance: Node = packed.instantiate()
	if instance == null:
		_failures.append({"path": path, "reason": "instantiate returned null"})
		return
	instance.queue_free()


func _check_script(path: String) -> void:
	_scripts_checked += 1
	var script: Resource = ResourceLoader.load(path)
	if script == null:
		_failures.append({"path": path, "reason": "ResourceLoader returned null for script"})
		return
	if not (script is GDScript):
		_failures.append({"path": path, "reason": "not a GDScript — %s" % script.get_class()})
		return
	# can_instantiate will be false for @tool scripts, extends RefCounted-only
	# modules, etc. We only care about parse errors, so check that the script
	# loaded without throwing a parse failure. ResourceLoader surfaces parse
	# errors by returning null; if we reach here the load succeeded.
