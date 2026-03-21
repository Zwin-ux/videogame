extends Node2D

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const ENEMY_SCENE := preload("res://scenes/enemy.tscn")
const PICKUP_SCENE := preload("res://scenes/pickup.tscn")
const GOAL_SCENE := preload("res://scenes/goal.tscn")

const WORLD_SIZE := Vector2(2240.0, 760.0)
const SPAWN_POINT := Vector2(140.0, 540.0)
const GOAL_POSITION := Vector2(2070.0, 190.0)

const PLATFORM_DATA := [
	{
		"pos": Vector2(-180.0, 620.0),
		"size": Vector2(2520.0, 140.0),
		"fill": Color(0.145098, 0.164706, 0.192157, 1.0),
		"trim": Color(0.811765, 0.482353, 0.266667, 1.0),
	},
	{
		"pos": Vector2(40.0, 520.0),
		"size": Vector2(220.0, 26.0),
		"fill": Color(0.156863, 0.196078, 0.243137, 1.0),
		"trim": Color(0.52549, 0.74902, 0.780392, 1.0),
	},
	{
		"pos": Vector2(320.0, 470.0),
		"size": Vector2(180.0, 24.0),
		"fill": Color(0.160784, 0.203922, 0.25098, 1.0),
		"trim": Color(0.533333, 0.756863, 0.792157, 1.0),
	},
	{
		"pos": Vector2(590.0, 415.0),
		"size": Vector2(220.0, 24.0),
		"fill": Color(0.160784, 0.203922, 0.25098, 1.0),
		"trim": Color(0.533333, 0.756863, 0.792157, 1.0),
	},
	{
		"pos": Vector2(900.0, 355.0),
		"size": Vector2(230.0, 24.0),
		"fill": Color(0.160784, 0.203922, 0.25098, 1.0),
		"trim": Color(0.533333, 0.756863, 0.792157, 1.0),
	},
	{
		"pos": Vector2(1190.0, 430.0),
		"size": Vector2(190.0, 24.0),
		"fill": Color(0.160784, 0.203922, 0.25098, 1.0),
		"trim": Color(0.533333, 0.756863, 0.792157, 1.0),
	},
	{
		"pos": Vector2(1460.0, 310.0),
		"size": Vector2(170.0, 24.0),
		"fill": Color(0.160784, 0.203922, 0.25098, 1.0),
		"trim": Color(0.533333, 0.756863, 0.792157, 1.0),
	},
	{
		"pos": Vector2(1730.0, 255.0),
		"size": Vector2(180.0, 24.0),
		"fill": Color(0.160784, 0.203922, 0.25098, 1.0),
		"trim": Color(0.533333, 0.756863, 0.792157, 1.0),
	},
	{
		"pos": Vector2(1960.0, 210.0),
		"size": Vector2(150.0, 24.0),
		"fill": Color(0.160784, 0.203922, 0.25098, 1.0),
		"trim": Color(0.952941, 0.694118, 0.356863, 1.0),
	},
]

const PICKUP_POSITIONS := [
	Vector2(220.0, 472.0),
	Vector2(470.0, 408.0),
	Vector2(760.0, 352.0),
	Vector2(1300.0, 370.0),
	Vector2(1560.0, 248.0),
]

const ENEMY_DATA := [
	{"pos": Vector2(430.0, 430.0), "travel": 58.0},
	{"pos": Vector2(1000.0, 312.0), "travel": 72.0},
	{"pos": Vector2(1510.0, 266.0), "travel": 66.0},
	{"pos": Vector2(1840.0, 210.0), "travel": 70.0},
]

var _player
var _goal
var _collected_pickups := 0
var _destroyed_enemies := 0
var _run_time := 0.0
var _state := "boot"

@onready var backdrop: Node2D = $Backdrop
@onready var platforms: Node2D = $Platforms
@onready var pickups: Node2D = $Pickups
@onready var enemies: Node2D = $Enemies
@onready var projectiles: Node2D = $Projectiles
@onready var goal_anchor: Node2D = $GoalAnchor
@onready var timer_label: Label = %TimerLabel
@onready var message_label: Label = %MessageLabel
@onready var objective_label: Label = %ObjectiveLabel
@onready var fuel_bar: ProgressBar = %FuelBar
@onready var health_bar: ProgressBar = %HealthBar
@onready var stats_label: Label = %StatsLabel


func _ready() -> void:
	DisplayServer.window_set_title("Scrapyard Comet")
	backdrop.set("world_width", WORLD_SIZE.x)
	backdrop.set("world_height", WORLD_SIZE.y)
	_build_platforms()
	_spawn_player()
	_reset_run()


func _process(delta: float) -> void:
	if _state == "playing":
		_run_time += delta
	_update_timer()

	if Input.is_action_just_pressed("restart"):
		_reset_run()


func _build_platforms() -> void:
	for child in platforms.get_children():
		child.free()

	for platform in PLATFORM_DATA:
		_spawn_platform(
			platform["pos"],
			platform["size"],
			platform["fill"],
			platform["trim"]
		)


func _spawn_platform(
	top_left: Vector2,
	size: Vector2,
	fill_color: Color,
	trim_color: Color
) -> void:
	var body := StaticBody2D.new()
	body.position = top_left + size * 0.5
	body.collision_layer = 2
	body.collision_mask = 0

	var shape := RectangleShape2D.new()
	shape.size = size

	var collider := CollisionShape2D.new()
	collider.shape = shape
	body.add_child(collider)

	var half := size * 0.5
	var points := PackedVector2Array(
		[
			Vector2(-half.x, -half.y),
			Vector2(half.x, -half.y),
			Vector2(half.x, half.y),
			Vector2(-half.x, half.y),
		]
	)
	var fill := Polygon2D.new()
	fill.polygon = points
	fill.color = fill_color
	body.add_child(fill)

	var trim := Polygon2D.new()
	trim.polygon = PackedVector2Array(
		[
			Vector2(-half.x, -half.y),
			Vector2(half.x, -half.y),
			Vector2(half.x, -half.y + 6.0),
			Vector2(-half.x, -half.y + 6.0),
		]
	)
	trim.color = trim_color
	body.add_child(trim)

	var shadow := Polygon2D.new()
	shadow.polygon = PackedVector2Array(
		[
			Vector2(-half.x, half.y - 8.0),
			Vector2(half.x, half.y - 8.0),
			Vector2(half.x, half.y),
			Vector2(-half.x, half.y),
		]
	)
	shadow.color = Color(0.047059, 0.054902, 0.066667, 0.55)
	body.add_child(shadow)

	platforms.add_child(body)


func _spawn_player() -> void:
	if is_instance_valid(_player):
		return

	_player = PLAYER_SCENE.instantiate()
	add_child(_player)
	_player.connect("shot_fired", Callable(self, "_on_player_shot_fired"))
	_player.connect("fuel_changed", Callable(self, "_on_player_fuel_changed"))
	_player.connect("health_changed", Callable(self, "_on_player_health_changed"))
	_player.connect("died", Callable(self, "_on_player_died"))

	var camera := _player.get_node("Camera2D") as Camera2D
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(WORLD_SIZE.x)
	camera.limit_bottom = int(WORLD_SIZE.y)


func _clear_runtime_nodes(parent: Node) -> void:
	for child in parent.get_children():
		child.free()


func _reset_run() -> void:
	_state = "playing"
	_run_time = 0.0
	_collected_pickups = 0
	_destroyed_enemies = 0

	_clear_runtime_nodes(projectiles)
	_clear_runtime_nodes(pickups)
	_clear_runtime_nodes(enemies)
	_clear_runtime_nodes(goal_anchor)

	_spawn_goal()
	_spawn_pickups()
	_spawn_enemies()

	_player.call("reset_to", SPAWN_POINT)
	_on_player_health_changed(3, 3)
	_on_player_fuel_changed(100.0, 100.0)
	_set_message("Collect the fuel cells, keep your thrusters fed, and hit the pad.")
	_update_objective()
	_update_stats()
	_update_timer()


func _spawn_goal() -> void:
	_goal = GOAL_SCENE.instantiate()
	goal_anchor.add_child(_goal)
	_goal.global_position = GOAL_POSITION
	_goal.connect("reached", Callable(self, "_on_goal_reached"))
	_goal.call("set_active", false)


func _spawn_pickups() -> void:
	for point in PICKUP_POSITIONS:
		var pickup := PICKUP_SCENE.instantiate()
		pickups.add_child(pickup)
		pickup.global_position = point
		pickup.connect("collected", Callable(self, "_on_pickup_collected"))


func _spawn_enemies() -> void:
	for enemy_data in ENEMY_DATA:
		var enemy := ENEMY_SCENE.instantiate()
		enemies.add_child(enemy)
		enemy.call("configure", enemy_data["pos"], enemy_data["travel"])
		enemy.connect("destroyed", Callable(self, "_on_enemy_destroyed"))


func _on_player_shot_fired(origin: Vector2, direction: Vector2) -> void:
	if _state != "playing":
		return

	var bullet := BULLET_SCENE.instantiate()
	projectiles.add_child(bullet)
	bullet.call("setup", origin, direction)


func _on_player_fuel_changed(current: float, maximum: float) -> void:
	fuel_bar.value = clampf((current / maximum) * 100.0, 0.0, 100.0)


func _on_player_health_changed(current: int, maximum: int) -> void:
	health_bar.value = clampf((float(current) / float(maximum)) * 100.0, 0.0, 100.0)


func _on_pickup_collected(_value: float) -> void:
	if _state != "playing":
		return

	_collected_pickups += 1
	if _collected_pickups >= PICKUP_POSITIONS.size():
		_goal.call("set_active", true)
		_set_message("Extraction pad is hot. Punch out.")
	else:
		_set_message("Fuel cell secured. Keep moving.")

	_update_objective()
	_update_stats()


func _on_enemy_destroyed(_points: int) -> void:
	if _state != "playing":
		return

	_destroyed_enemies += 1
	_update_stats()


func _on_goal_reached() -> void:
	if _state != "playing":
		return

	_state = "won"
	_player.call("set_controls_enabled", false)
	_set_message("Run clear. Hit restart and shave your time.")
	objective_label.text = "Pad secured. Restart for another pass."


func _on_player_died() -> void:
	if _state != "playing":
		return

	_state = "rebooting"
	_set_message("Suit cracked. Rebooting the run.")
	await get_tree().create_timer(0.9).timeout
	if _state == "rebooting":
		_reset_run()


func _update_objective() -> void:
	var remaining := PICKUP_POSITIONS.size() - _collected_pickups
	if _state == "won":
		objective_label.text = "Pad secured. Restart for another pass."
	elif remaining > 0:
		objective_label.text = "Fuel cells left: %d" % remaining
	else:
		objective_label.text = "Fuel cells loaded. Reach the extraction pad."


func _update_stats() -> void:
	stats_label.text = "Cells %d/%d   Drones %d/%d" % [
		_collected_pickups,
		PICKUP_POSITIONS.size(),
		_destroyed_enemies,
		ENEMY_DATA.size(),
	]


func _update_timer() -> void:
	timer_label.text = "%.1fs" % _run_time


func _set_message(text: String) -> void:
	message_label.text = text
