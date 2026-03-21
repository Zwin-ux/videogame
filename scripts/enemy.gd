extends Area2D

signal destroyed(points: int)

@export var travel_distance := 80.0
@export var speed := 62.0
@export var hover_amount := 10.0
@export var max_health := 2

var _origin := Vector2.ZERO
var _direction := 1.0
var _health := 2
var _phase := 0.0


func _ready() -> void:
	_health = max_health
	_origin = global_position
	_phase = randf() * TAU
	body_entered.connect(_on_body_entered)
	queue_redraw()


func configure(start_position: Vector2, patrol_distance: float) -> void:
	global_position = start_position
	_origin = start_position
	travel_distance = patrol_distance


func take_hit(amount: int, _hit_position: Vector2) -> void:
	_health -= amount
	if _health <= 0:
		emit_signal("destroyed", 100)
		queue_free()


func _process(delta: float) -> void:
	global_position.x += _direction * speed * delta
	if absf(global_position.x - _origin.x) > travel_distance:
		_direction *= -1.0

	global_position.y = _origin.y + sin((Time.get_ticks_msec() / 1000.0) * 3.0 + _phase) * hover_amount
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.call("take_damage", global_position)


func _draw() -> void:
	draw_circle(Vector2(0.0, 16.0), 16.0, Color(0.0, 0.0, 0.0, 0.14))
	draw_circle(Vector2.ZERO, 16.0, Color(0.282353, 0.368627, 0.454902, 1.0))
	draw_rect(Rect2(-14.0, -6.0, 28.0, 9.0), Color(0.094118, 0.137255, 0.188235, 1.0))
	draw_circle(Vector2(0.0, -2.0), 5.0, Color(0.968627, 0.45098, 0.34902, 1.0))
	draw_rect(Rect2(-20.0, 0.0, 8.0, 4.0), Color(0.952941, 0.694118, 0.356863, 1.0))
	draw_rect(Rect2(12.0, 0.0, 8.0, 4.0), Color(0.952941, 0.694118, 0.356863, 1.0))
