extends Area2D

signal reached

var _active := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	set_process(true)


func set_active(value: bool) -> void:
	_active = value
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if _active and body.is_in_group("player"):
		emit_signal("reached")


func _draw() -> void:
	var pulse := 0.6 + sin(Time.get_ticks_msec() / 260.0) * 0.15
	draw_rect(Rect2(-26.0, 18.0, 52.0, 8.0), Color(0.160784, 0.203922, 0.25098, 1.0))
	draw_rect(Rect2(-30.0, 12.0, 60.0, 6.0), Color(0.952941, 0.694118, 0.356863, 1.0))
	draw_rect(Rect2(-4.0, -42.0, 8.0, 54.0), Color(0.329412, 0.454902, 0.505882, 1.0))

	if _active:
		draw_rect(Rect2(-10.0, -84.0, 20.0, 96.0), Color(0.286275, 0.929412, 0.952941, 0.14 + pulse * 0.12))
		draw_circle(Vector2(0.0, -52.0), 12.0, Color(0.286275, 0.929412, 0.952941, 0.34 + pulse * 0.1))
	else:
		draw_circle(Vector2(0.0, -18.0), 9.0, Color(0.529412, 0.239216, 0.188235, 0.75))
