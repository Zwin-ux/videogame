extends Area2D

@export var speed := 460.0
@export var lifetime := 1.4
@export var damage := 1

var direction := Vector2.RIGHT
var profile := "gun"
var _anim_time := 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func setup(start_position: Vector2, heading: Vector2, config: Dictionary = {}) -> void:
	global_position = start_position
	direction = heading.normalized()
	speed = float(config.get("speed", speed))
	lifetime = float(config.get("lifetime", lifetime))
	damage = int(config.get("damage", damage))
	profile = String(config.get("profile", profile))
	rotation = direction.angle()
	queue_redraw()


func _process(delta: float) -> void:
	_anim_time += delta
	position += direction * speed * delta
	lifetime -= delta
	rotation = direction.angle()
	queue_redraw()
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.call("take_damage", global_position)
		queue_free()
		return
	if body is PhysicsBody2D:
		queue_free()


func _draw() -> void:
	if profile == "wave":
		var pulse := 0.74 + sin(_anim_time * 10.0) * 0.14
		draw_colored_polygon(
			PackedVector2Array(
				[
					Vector2(-16.0, 0.0),
					Vector2(-4.0, -7.0),
					Vector2(10.0, -5.0),
					Vector2(18.0, 0.0),
					Vector2(10.0, 5.0),
					Vector2(-4.0, 7.0),
				]
			),
			Color(0.952941, 0.643137, 0.341176, 0.66)
		)
		draw_line(Vector2(-14.0, 0.0), Vector2(16.0, 0.0), Color(0.984314, 0.898039, 0.627451, pulse), 3.0)
		draw_circle(Vector2(2.0, 0.0), 4.0, Color(0.286275, 0.831373, 0.898039, 0.92))
		return

	draw_circle(Vector2.ZERO, 7.0, Color(0.952941, 0.643137, 0.341176, 1.0))
	draw_rect(Rect2(-18.0, -2.0, 18.0, 4.0), Color(1.0, 0.882353, 0.603922, 0.78))
	draw_circle(Vector2(-8.0, 0.0), 3.0, Color(1.0, 0.882353, 0.603922, 0.9))
	draw_circle(Vector2.ZERO, 3.0, Color(0.286275, 0.831373, 0.898039, 0.88))
