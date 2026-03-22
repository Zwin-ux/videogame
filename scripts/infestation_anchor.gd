extends Area2D

signal destroyed(region_id: String, anchor_id: String, hit_kind: String)

@export var max_health := 6

var region_id := ""
var anchor_id := ""
var anchor_name := "Anchor"

var _health := 6
var _pulse_time := 0.0
var _hurt_timer := 0.0
var _last_hit_kind := "gun"

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("hazard")
	body_entered.connect(_on_body_entered)
	_health = max_health
	_update_collision_shape()
	queue_redraw()


func configure(config: Dictionary) -> void:
	region_id = String(config.get("region_id", region_id))
	anchor_id = String(config.get("anchor_id", anchor_id))
	anchor_name = String(config.get("anchor_name", anchor_name))
	max_health = int(config.get("health", max_health))
	global_position = config.get("pos", global_position)
	_health = max_health
	_hurt_timer = 0.0
	_pulse_time = 0.0
	_update_collision_shape()
	queue_redraw()


func take_hit(amount: int, _hit_position: Vector2, hit_kind: String = "gun") -> bool:
	_last_hit_kind = hit_kind
	_hurt_timer = 0.18
	_health -= amount + (1 if hit_kind == "blade" else 0)
	queue_redraw()
	if _health <= 0:
		emit_signal("destroyed", region_id, anchor_id, _last_hit_kind)
		queue_free()
		return true
	return false


func _process(delta: float) -> void:
	_pulse_time += delta
	if _hurt_timer > 0.0:
		_hurt_timer = maxf(_hurt_timer - delta, 0.0)
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if _hurt_timer > 0.0:
		return
	if body.has_method("take_damage"):
		body.call("take_damage", global_position)


func _update_collision_shape() -> void:
	if collision_shape == null:
		return
	var shape := CircleShape2D.new()
	shape.radius = 20.0
	collision_shape.shape = shape


func _draw() -> void:
	var pulse := 0.72 + sin(_pulse_time * 5.1) * 0.16
	var hurt_boost := 0.14 if _hurt_timer > 0.0 else 0.0
	var shell_color := Color(0.145098, 0.113725, 0.160784, 1.0)
	var core_color := Color(0.952941, 0.643137, 0.341176, 0.26 + pulse * 0.18 + hurt_boost)
	var vein_color := Color(0.286275, 0.831373, 0.898039, 0.18 + pulse * 0.08)

	draw_circle(Vector2.ZERO, 24.0, Color(0.0, 0.0, 0.0, 0.16))
	draw_colored_polygon(
		PackedVector2Array(
			[
				Vector2(0.0, -30.0),
				Vector2(22.0, -12.0),
				Vector2(28.0, 12.0),
				Vector2(12.0, 28.0),
				Vector2(-12.0, 28.0),
				Vector2(-28.0, 12.0),
				Vector2(-22.0, -12.0),
			]
		),
		shell_color
	)
	draw_circle(Vector2.ZERO, 14.0, Color(0.721569, 0.639216, 0.521569, 0.94))
	draw_circle(Vector2.ZERO, 7.0, core_color)
	draw_line(Vector2(-18.0, -8.0), Vector2(18.0, 10.0), vein_color, 2.0)
	draw_line(Vector2(-14.0, 14.0), Vector2(12.0, -18.0), vein_color, 2.0)
	draw_arc(Vector2.ZERO, 20.0, 0.0, TAU, 24, Color(0.952941, 0.694118, 0.356863, 0.24 + pulse * 0.08), 2.0)
	if _hurt_timer > 0.0:
		draw_circle(Vector2.ZERO, 17.0, Color(0.984314, 0.898039, 0.627451, 0.08 + _hurt_timer * 0.32))
