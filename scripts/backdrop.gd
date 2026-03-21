extends Node2D

@export var world_width := 2240.0
@export var world_height := 760.0

var _stars: Array[Dictionary] = []


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 19870715
	for _index in range(90):
		_stars.append(
			{
				"pos": Vector2(
					rng.randf_range(-120.0, world_width + 120.0),
					rng.randf_range(-40.0, world_height * 0.56)
				),
				"radius": rng.randf_range(1.0, 2.3),
				"alpha": rng.randf_range(0.3, 0.92),
			}
		)
	queue_redraw()


func _draw() -> void:
	draw_rect(
		Rect2(-240.0, -140.0, world_width + 480.0, world_height + 220.0),
		Color(0.019608, 0.027451, 0.043137, 1.0)
	)
	draw_rect(
		Rect2(-240.0, 260.0, world_width + 480.0, world_height),
		Color(0.031373, 0.043137, 0.062745, 1.0)
	)
	draw_circle(Vector2(world_width * 0.72, 120.0), 74.0, Color(0.964706, 0.839216, 0.627451, 0.11))
	draw_circle(Vector2(world_width * 0.72, 120.0), 52.0, Color(0.956863, 0.894118, 0.74902, 0.2))

	for star in _stars:
		draw_circle(
			star["pos"],
			star["radius"],
			Color(0.960784, 0.960784, 0.921569, star["alpha"])
		)

	for index in range(11):
		var x := -120.0 + float(index) * 230.0
		var width := 120.0 + float(index % 3) * 36.0
		var height := 150.0 + float(index % 4) * 38.0
		draw_rect(
			Rect2(x, 470.0 - height, width, height + 180.0),
			Color(0.039216, 0.058824, 0.078431, 0.9)
		)
		draw_rect(
			Rect2(x, 470.0 - height, width, 6.0),
			Color(0.278431, 0.478431, 0.560784, 0.65)
		)

	for index in range(6):
		var beacon_x := 150.0 + float(index) * 360.0
		draw_rect(
			Rect2(beacon_x, 150.0, 4.0, 420.0),
			Color(0.070588, 0.101961, 0.141176, 0.65)
		)
		draw_rect(
			Rect2(beacon_x - 6.0, 168.0, 16.0, 16.0),
			Color(0.952941, 0.694118, 0.356863, 0.8)
		)
