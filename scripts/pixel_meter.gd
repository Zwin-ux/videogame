extends Control
class_name PixelMeter

@export var value := 100.0:
	set(new_value):
		value = clampf(new_value, 0.0, max_value)
		queue_redraw()

@export var max_value := 100.0:
	set(new_value):
		max_value = maxf(new_value, 1.0)
		value = minf(value, max_value)
		queue_redraw()

@export var segments := 12:
	set(new_value):
		segments = maxi(new_value, 4)
		queue_redraw()

@export var fill_color := Color("4fd0c8"):
	set(new_value):
		fill_color = new_value
		queue_redraw()

@export var low_color := Color("c96a3a"):
	set(new_value):
		low_color = new_value
		queue_redraw()

@export var frame_color := Color("50657a"):
	set(new_value):
		frame_color = new_value
		queue_redraw()

@export var background_color := Color("0b0c12"):
	set(new_value):
		background_color = new_value
		queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size).grow_individual(-1.0, -1.0, -1.0, -1.0)
	draw_rect(rect, background_color)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, 1.0)), frame_color)
	draw_rect(Rect2(rect.position, Vector2(1.0, rect.size.y)), frame_color)
	draw_rect(Rect2(Vector2(rect.end.x - 1.0, rect.position.y), Vector2(1.0, rect.size.y)), Color(0, 0, 0, 1))
	draw_rect(Rect2(Vector2(rect.position.x, rect.end.y - 1.0), Vector2(rect.size.x, 1.0)), Color(0, 0, 0, 1))

	var inner := rect.grow_individual(-2.0, -2.0, -2.0, -2.0)
	draw_rect(inner, background_color.lightened(0.08))
	var segment_gap := 2.0
	var segment_width := maxf(2.0, (inner.size.x - segment_gap * float(segments - 1)) / float(segments))
	var fill_ratio := clampf(value / max_value, 0.0, 1.0)
	var filled_segments := int(round(fill_ratio * float(segments)))
	var active_color := fill_color if fill_ratio > 0.3 else low_color

	for index in range(segments):
		var x := inner.position.x + float(index) * (segment_width + segment_gap)
		var seg_rect := Rect2(Vector2(x, inner.position.y), Vector2(segment_width, inner.size.y))
		var seg_color := active_color if index < filled_segments else background_color.darkened(0.2)
		draw_rect(seg_rect, seg_color)
