extends Area2D

signal collected(value: float)

@export var fuel_value := 28.0

var _home_position := Vector2.ZERO
var _time := 0.0


func _ready() -> void:
	_home_position = position
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	position.y = _home_position.y + sin(_time * 2.4) * 6.0
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if body.has_method("apply_refill"):
		body.call("apply_refill", fuel_value)
		emit_signal("collected", fuel_value)
		# 0.2 Hive Signal — pickup stinger. Major pickup = larger fuel value.
		var tree := get_tree()
		if tree != null and tree.root != null:
			var sb := tree.root.get_node_or_null("SoundBank")
			if sb != null:
				var name := "pickup_major" if fuel_value >= 40.0 else "pickup"
				sb.call("play", name)
		queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 10.0, Color(0.082353, 0.156863, 0.2, 0.22))
	draw_colored_polygon(
		PackedVector2Array(
			[
				Vector2(0.0, -12.0),
				Vector2(10.0, 0.0),
				Vector2(0.0, 12.0),
				Vector2(-10.0, 0.0),
			]
		),
		Color(0.352941, 0.878431, 0.933333, 1.0)
	)
	draw_colored_polygon(
		PackedVector2Array(
			[
				Vector2(0.0, -6.0),
				Vector2(5.0, 0.0),
				Vector2(0.0, 6.0),
				Vector2(-5.0, 0.0),
			]
		),
		Color(0.941176, 0.976471, 0.854902, 1.0)
	)
