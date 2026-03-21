extends Area2D

@export var speed := 760.0
@export var lifetime := 1.2

var direction := Vector2.RIGHT


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func setup(start_position: Vector2, heading: Vector2) -> void:
	global_position = start_position
	direction = heading.normalized()
	rotation = direction.angle()


func _process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body is PhysicsBody2D:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_hit"):
		area.call("take_hit", 1, global_position)
		queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 4.0, Color(0.960784, 0.698039, 0.337255, 1.0))
	draw_circle(Vector2(-5.0, 0.0), 2.0, Color(1.0, 0.882353, 0.603922, 0.85))
