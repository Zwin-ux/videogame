extends Node2D

signal boss_trigger_entered(body: Node)

var _left_gate_closed := false
var _right_gate_closed := true
var _boss_trigger_enabled := true
var _pulse_time := 0.0

@onready var entry_marker: Marker2D = $EntryMarker
@onready var boss_spawn_marker: Marker2D = $BossSpawnMarker
@onready var reward_marker: Marker2D = $RewardMarker
@onready var exit_marker: Marker2D = $ExitMarker
@onready var left_gate_marker: Marker2D = $LeftGateMarker
@onready var right_gate_marker: Marker2D = $RightGateMarker
@onready var boss_trigger: Area2D = $BossTrigger


func _ready() -> void:
	z_index = -8
	set_process(true)
	boss_trigger.body_entered.connect(_on_boss_trigger_body_entered)
	queue_redraw()


func _process(delta: float) -> void:
	_pulse_time += delta
	queue_redraw()


func get_entry_position() -> Vector2:
	return entry_marker.global_position


func get_boss_spawn_position() -> Vector2:
	return boss_spawn_marker.global_position


func get_reward_position() -> Vector2:
	return reward_marker.global_position


func get_exit_position() -> Vector2:
	return exit_marker.global_position


func get_boss_bounds() -> Rect2:
	return Rect2(Vector2(1096.0, 90.0), Vector2(386.0, 178.0))


func get_floor_y() -> float:
	return boss_spawn_marker.global_position.y


func set_gate_states(left_closed: bool, right_closed: bool) -> void:
	_left_gate_closed = left_closed
	_right_gate_closed = right_closed
	queue_redraw()


func set_boss_trigger_enabled(value: bool) -> void:
	_boss_trigger_enabled = value
	boss_trigger.monitoring = value
	boss_trigger.monitorable = value


func _on_boss_trigger_body_entered(body: Node) -> void:
	if not _boss_trigger_enabled:
		return
	if body != null and body.is_in_group("player"):
		emit_signal("boss_trigger_entered", body)


func _draw() -> void:
	var pulse := 0.66 + sin(_pulse_time * 4.2) * 0.12
	var cave_rect := Rect2(858.0, 18.0, 764.0, 340.0)
	var floor_top := 270.0
	var boss_backlight_center := boss_spawn_marker.position + Vector2(-10.0, -56.0)
	var arch := PackedVector2Array(
		[
			Vector2(836.0, 128.0),
			Vector2(906.0, 76.0),
			Vector2(1016.0, 40.0),
			Vector2(1188.0, 24.0),
			Vector2(1384.0, 36.0),
			Vector2(1512.0, 82.0),
			Vector2(1618.0, 130.0),
			Vector2(1618.0, 344.0),
			Vector2(836.0, 344.0),
		]
	)

	draw_rect(cave_rect, Color(0.062745, 0.070588, 0.094118, 0.84))
	draw_colored_polygon(arch, Color(0.035294, 0.039216, 0.054902, 0.94))
	draw_rect(Rect2(836.0, floor_top, 786.0, 84.0), Color(0.082353, 0.090196, 0.113725, 0.92))
	draw_rect(Rect2(836.0, floor_top, 786.0, 10.0), Color(0.286275, 0.321569, 0.360784, 0.96))
	draw_rect(Rect2(880.0, floor_top + 8.0, 706.0, 4.0), Color(0.952941, 0.643137, 0.341176, 0.16))
	draw_circle(boss_backlight_center, 124.0, Color(0.952941, 0.643137, 0.341176, 0.12))
	draw_circle(boss_backlight_center + Vector2(18.0, -8.0), 76.0, Color(0.286275, 0.831373, 0.898039, 0.08))
	draw_rect(Rect2(boss_backlight_center.x - 20.0, 54.0, 40.0, floor_top - 74.0), Color(0.952941, 0.643137, 0.341176, 0.06))

	draw_rect(Rect2(872.0, 176.0, 104.0, 78.0), Color(0.07451, 0.086275, 0.109804, 0.92))
	draw_rect(Rect2(1482.0, 176.0, 98.0, 78.0), Color(0.07451, 0.086275, 0.109804, 0.92))
	for catwalk in [
		Rect2(958.0, 224.0, 92.0, 16.0),
		Rect2(1150.0, 128.0, 124.0, 16.0),
		Rect2(1382.0, 224.0, 94.0, 16.0),
	]:
		draw_rect(catwalk, Color(0.156863, 0.180392, 0.211765, 0.9))
		draw_rect(Rect2(catwalk.position.x, catwalk.position.y, catwalk.size.x, 4.0), Color(0.94902, 0.862745, 0.611765, 0.18))
		draw_rect(Rect2(catwalk.position.x + 10.0, catwalk.position.y + catwalk.size.y - 3.0, catwalk.size.x - 20.0, 3.0), Color(0.05098, 0.062745, 0.078431, 0.56))

	for brace in [Vector2(1002.0, 240.0), Vector2(1212.0, 144.0), Vector2(1428.0, 240.0)]:
		draw_line(brace, brace + Vector2(0.0, 30.0), Color(0.129412, 0.14902, 0.176471, 0.72), 2.0)

	for light_x in [928.0, 1098.0, 1292.0, 1486.0]:
		draw_rect(Rect2(light_x, 58.0, 12.0, 8.0), Color(0.94902, 0.862745, 0.611765, 0.28))
		draw_rect(Rect2(light_x + 2.0, 66.0, 8.0, 24.0), Color(0.952941, 0.643137, 0.341176, 0.08))

	_draw_gate(left_gate_marker.position, _left_gate_closed, pulse, false)
	_draw_gate(right_gate_marker.position, _right_gate_closed, pulse, true)
	_draw_exit_guides(pulse)


func _draw_gate(center: Vector2, closed: bool, pulse: float, exit_gate: bool) -> void:
	var bar_color := Color(0.952941, 0.643137, 0.341176, 0.92) if closed else Color(0.286275, 0.831373, 0.898039, 0.86)
	var glow_color := Color(0.952941, 0.643137, 0.341176, 0.12 + pulse * 0.08) if closed else Color(0.286275, 0.831373, 0.898039, 0.08 + pulse * 0.06)
	var width := 26.0
	var height := 132.0
	var left := center.x - width * 0.5
	var top := center.y - height * 0.5
	draw_rect(Rect2(left - 8.0, top - 12.0, width + 16.0, height + 24.0), glow_color)
	draw_rect(Rect2(left, top, width, height), Color(0.058824, 0.070588, 0.086275, 0.92))
	for index in range(4):
		var y := top + 10.0 + float(index) * 28.0
		draw_rect(Rect2(left + 4.0, y, width - 8.0, 6.0), bar_color)
	if exit_gate and not closed:
		draw_rect(Rect2(left - 18.0, top + height * 0.5 - 8.0, width + 36.0, 6.0), Color(0.94902, 0.862745, 0.611765, 0.44))


func _draw_exit_guides(pulse: float) -> void:
	if _right_gate_closed:
		return
	var exit_pos := exit_marker.position
	draw_line(exit_pos + Vector2(-68.0, -54.0), exit_pos + Vector2(22.0, -54.0), Color(0.94902, 0.862745, 0.611765, 0.18), 3.0)
	draw_line(exit_pos + Vector2(-68.0, -42.0), exit_pos + Vector2(22.0, -42.0), Color(0.286275, 0.831373, 0.898039, 0.14), 2.0)
	draw_circle(exit_pos + Vector2(-18.0, -48.0), 6.0, Color(0.286275, 0.831373, 0.898039, 0.18 + pulse * 0.08))
