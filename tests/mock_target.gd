extends Area2D
## Minimal take_hit target for integration tests. Dies on first hit, records
## the hit so the test can inspect afterwards.

var times_hit: int = 0
var last_hit_kind: String = ""
var last_hit_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	var shape := CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	(shape.shape as CircleShape2D).radius = 16.0
	add_child(shape)


func take_hit(damage: int, hit_position: Vector2, hit_kind: String = "gun") -> bool:
	times_hit += 1
	last_hit_kind = hit_kind
	last_hit_position = hit_position
	# Die on first hit for deterministic test behavior.
	return true
