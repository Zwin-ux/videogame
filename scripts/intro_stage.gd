extends Node2D

const ExportArt = preload("res://scripts/export_art.gd")
const CLAIM_ACTION := "shoot"

@export var deck_width := 980.0
@export var deck_height := 92.0
@export var sky_top_color := Color(0.098039, 0.070588, 0.160784, 1.0)
@export var sky_horizon_color := Color(0.623529, 0.262745, 0.298039, 1.0)
@export var sun_color := Color(0.964706, 0.670588, 0.337255, 1.0)
@export var deck_top_color := Color(0.109804, 0.133333, 0.156863, 1.0)
@export var deck_side_color := Color(0.054902, 0.066667, 0.078431, 1.0)
@export var hull_color := Color(0.027451, 0.035294, 0.047059, 1.0)
@export var accent_color := Color(0.270588, 0.901961, 0.92549, 1.0)
@export var warning_color := Color(0.94902, 0.662745, 0.278431, 1.0)

var _landing_marker: Marker2D
var _player_drop_marker: Marker2D
var _run_start_marker: Marker2D
var _title_hero_marker: Marker2D
var _blade_stand: Marker2D
var _gun_stand: Marker2D
var _camera_anchor: Marker2D
var _title_camera_anchor: Marker2D
var _ship_open_factor := 0.0
var _rack_focus := ""
var _choice_guide_visible := false
var _claim_flash_mode := ""
var _claim_flash_timer := 0.0
var _blade_showcase_texture: Texture2D
var _gun_showcase_texture: Texture2D


func _ready() -> void:
	_landing_marker = get_node_or_null("LandingMarker") as Marker2D
	_player_drop_marker = get_node_or_null("PlayerDropMarker") as Marker2D
	_run_start_marker = get_node_or_null("RunStartMarker") as Marker2D
	_title_hero_marker = get_node_or_null("TitleHeroMarker") as Marker2D
	_blade_stand = get_node_or_null("BladeStand") as Marker2D
	_gun_stand = get_node_or_null("GunStand") as Marker2D
	_camera_anchor = get_node_or_null("IntroCameraAnchor") as Marker2D
	_title_camera_anchor = get_node_or_null("TitleCameraAnchor") as Marker2D
	_blade_showcase_texture = ExportArt.get_weapon_showcase("blade")
	_gun_showcase_texture = ExportArt.get_weapon_showcase("gun")
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	if _claim_flash_timer > 0.0:
		_claim_flash_timer = maxf(_claim_flash_timer - delta, 0.0)
		if _claim_flash_timer <= 0.0:
			_claim_flash_mode = ""
	queue_redraw()


func _draw() -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var sky_rect := Rect2(Vector2(-560.0, -320.0), Vector2(deck_width + 1120.0, 540.0))

	_draw_gradient_band(sky_rect, sky_top_color, Color(0.231373, 0.160784, 0.227451, 1.0), sky_horizon_color)
	draw_circle(Vector2(-172.0, -96.0), 132.0, Color(sun_color.r, sun_color.g, sun_color.b, 0.18))
	draw_circle(Vector2(-172.0, -96.0), 72.0, Color(sun_color.r, sun_color.g, sun_color.b, 0.28))

	_draw_ruin_skyline()
	_draw_moored_ship(t)
	_draw_bay_hardware(t)
	_draw_deck(t)
	_draw_service_platforms(t)
	_draw_signage(t)
	_draw_weapon_stand(_blade_marker(), true, t)
	_draw_weapon_stand(_gun_marker(), false, t)
	_draw_choice_guide(t)


func _landing_marker_pos() -> Vector2:
	return _marker_pos(_landing_marker, Vector2(-28.0, -6.0))


func _player_drop_pos() -> Vector2:
	return _marker_pos(_player_drop_marker, Vector2(-180.0, -74.0))


func _run_start_pos() -> Vector2:
	return _marker_pos(_run_start_marker, Vector2(-360.0, -6.0))


func _title_hero_pos() -> Vector2:
	return _marker_pos(_title_hero_marker, Vector2(-232.0, -78.0))


func _blade_marker() -> Vector2:
	return _marker_pos(_blade_stand, Vector2(150.0, -6.0))


func _gun_marker() -> Vector2:
	return _marker_pos(_gun_stand, Vector2(342.0, -6.0))


func _camera_anchor_pos() -> Vector2:
	return _marker_pos(_camera_anchor, Vector2(-92.0, -42.0))


func _title_camera_anchor_pos() -> Vector2:
	return _marker_pos(_title_camera_anchor, Vector2(-198.0, -94.0))


func set_ship_open_factor(value: float) -> void:
	_ship_open_factor = clampf(value, 0.0, 1.0)


func set_rack_focus(mode: String) -> void:
	_rack_focus = mode
	queue_redraw()


func set_choice_guide_visible(value: bool) -> void:
	_choice_guide_visible = value
	queue_redraw()


func flash_claim(mode: String) -> void:
	_claim_flash_mode = mode
	_claim_flash_timer = 0.22
	queue_redraw()


func _marker_pos(marker: Marker2D, fallback: Vector2) -> Vector2:
	if marker == null:
		return fallback
	return marker.position


func _draw_gradient_band(rect: Rect2, top_color: Color, mid_color: Color, bottom_color: Color) -> void:
	var steps := 42
	for i in range(steps):
		var ratio := float(i) / float(steps - 1)
		var color: Color
		if ratio < 0.55:
			color = top_color.lerp(mid_color, ratio / 0.55)
		else:
			color = mid_color.lerp(bottom_color, (ratio - 0.55) / 0.45)

		var y0 := rect.position.y + rect.size.y * ratio
		var band_height := rect.size.y / float(steps) + 1.0
		draw_rect(Rect2(rect.position.x, y0, rect.size.x, band_height), color)


func _draw_ruin_skyline() -> void:
	var base_y := -130.0
	var glow_y := -42.0
	draw_rect(Rect2(-560.0, base_y, deck_width + 1120.0, 220.0), Color(0.05098, 0.039216, 0.054902, 0.26))
	draw_circle(Vector2(188.0, glow_y), 118.0, Color(0.698039, 0.321569, 0.231373, 0.09))
	draw_circle(Vector2(354.0, glow_y - 18.0), 168.0, Color(0.945098, 0.647059, 0.286275, 0.05))

	var blocks := [
		Rect2(-470.0, -184.0, 92.0, 54.0),
		Rect2(-352.0, -214.0, 120.0, 84.0),
		Rect2(-188.0, -170.0, 80.0, 44.0),
		Rect2(54.0, -204.0, 96.0, 74.0),
		Rect2(214.0, -178.0, 110.0, 52.0),
		Rect2(368.0, -198.0, 152.0, 70.0),
	]

	for block in blocks:
		draw_rect(block, Color(0.039216, 0.047059, 0.062745, 0.96))
		draw_rect(Rect2(block.position.x, block.position.y - 8.0, block.size.x, 8.0), Color(0.227451, 0.180392, 0.145098, 0.22))
		draw_rect(Rect2(block.position.x + 8.0, block.position.y + block.size.y - 6.0, block.size.x - 16.0, 6.0), Color(0.137255, 0.160784, 0.180392, 0.84))

	draw_line(Vector2(-520.0, base_y + 4.0), Vector2(520.0, base_y + 4.0), Color(0.843137, 0.568627, 0.32549, 0.16), 2.0)


func _draw_moored_ship(t: float) -> void:
	var anchor := _player_drop_pos()
	var ship_origin := anchor + Vector2(-96.0, -38.0)
	var body := PackedVector2Array([
		ship_origin + Vector2(-198.0, -18.0),
		ship_origin + Vector2(-150.0, -54.0),
		ship_origin + Vector2(-36.0, -60.0),
		ship_origin + Vector2(78.0, -28.0),
		ship_origin + Vector2(136.0, 8.0),
		ship_origin + Vector2(110.0, 28.0),
		ship_origin + Vector2(8.0, 34.0),
		ship_origin + Vector2(-112.0, 28.0),
		ship_origin + Vector2(-184.0, 6.0),
	])
	draw_colored_polygon(body, hull_color)

	draw_rect(Rect2(ship_origin + Vector2(-134.0, -44.0), Vector2(78.0, 18.0)), Color(0.066667, 0.082353, 0.101961, 1.0))
	draw_rect(Rect2(ship_origin + Vector2(-44.0, -52.0), Vector2(56.0, 16.0)), Color(0.086275, 0.105882, 0.12549, 1.0))
	draw_rect(Rect2(ship_origin + Vector2(22.0, -26.0), Vector2(68.0, 12.0)), Color(0.07451, 0.090196, 0.109804, 1.0))
	draw_rect(Rect2(ship_origin + Vector2(86.0, 4.0), Vector2(40.0, 10.0)), Color(0.094118, 0.117647, 0.137255, 1.0))

	draw_line(ship_origin + Vector2(120.0, 14.0), ship_origin + Vector2(184.0, 32.0), Color(0.6, 0.662745, 0.682353, 0.35), 3.0)
	draw_line(ship_origin + Vector2(184.0, 32.0), ship_origin + Vector2(198.0, 56.0), Color(0.6, 0.662745, 0.682353, 0.25), 2.0)
	draw_circle(ship_origin + Vector2(200.0, 58.0), 8.0, Color(0.431373, 0.882353, 0.917647, 0.34 + sin(t * 3.2) * 0.05))
	draw_circle(ship_origin + Vector2(202.0, 58.0), 18.0, Color(accent_color.r, accent_color.g, accent_color.b, 0.06))

	draw_rect(Rect2(ship_origin + Vector2(-72.0, -20.0), Vector2(24.0, 8.0)), Color(sun_color.r, sun_color.g, sun_color.b, 0.7))
	draw_rect(Rect2(ship_origin + Vector2(-38.0, -16.0), Vector2(14.0, 6.0)), Color(0.964706, 0.670588, 0.337255, 0.4))

	var bay_rect := Rect2(ship_origin + Vector2(-12.0, -8.0), Vector2(56.0, 34.0))
	draw_rect(bay_rect, Color(0.015686, 0.019608, 0.027451, 0.96))
	if _ship_open_factor < 0.98:
		var hatch_width := lerpf(52.0, 4.0, _ship_open_factor)
		draw_rect(Rect2(bay_rect.position.x + 2.0, bay_rect.position.y + 2.0, hatch_width, bay_rect.size.y - 4.0), Color(0.078431, 0.090196, 0.109804, 1.0))
	else:
		draw_rect(Rect2(bay_rect.position + Vector2(0.0, bay_rect.size.y - 4.0), Vector2(60.0, 4.0)), Color(0.184314, 0.196078, 0.219608, 1.0))
	var door_glow := 0.18 + _ship_open_factor * 0.22 + sin(t * 5.4) * 0.05
	draw_rect(Rect2(bay_rect.position + Vector2(4.0, 4.0), Vector2(44.0, 4.0)), Color(accent_color.r, accent_color.g, accent_color.b, door_glow))
	draw_circle(bay_rect.position + Vector2(48.0, 17.0), 4.0, Color(warning_color.r, warning_color.g, warning_color.b, 0.26 + _ship_open_factor * 0.24))


func _draw_bay_hardware(t: float) -> void:
	var run_start := _run_start_pos()
	var camera_anchor := _camera_anchor_pos()
	var blade_pos := _blade_marker()
	var gun_pos := _gun_marker()

	draw_rect(Rect2(run_start + Vector2(-66.0, -88.0), Vector2(20.0, 88.0)), Color(0.039216, 0.05098, 0.062745, 1.0))
	draw_rect(Rect2(run_start + Vector2(-72.0, -88.0), Vector2(72.0, 16.0)), Color(0.070588, 0.082353, 0.094118, 1.0))
	draw_rect(Rect2(run_start + Vector2(-52.0, -72.0), Vector2(36.0, 12.0)), Color(0.164706, 0.188235, 0.211765, 1.0))

	draw_line(camera_anchor + Vector2(-220.0, -18.0), camera_anchor + Vector2(-108.0, -4.0), Color(0.74902, 0.458824, 0.239216, 0.25), 4.0)
	draw_line(camera_anchor + Vector2(-108.0, -4.0), camera_anchor + Vector2(-70.0, 30.0), Color(0.74902, 0.458824, 0.239216, 0.18), 3.0)
	draw_circle(camera_anchor + Vector2(-62.0, 30.0), 9.0, Color(0.968627, 0.666667, 0.286275, 0.14))

	draw_rect(Rect2(Vector2(-12.0, -116.0), Vector2(120.0, 16.0)), Color(0.098039, 0.117647, 0.137255, 1.0))
	draw_rect(Rect2(Vector2(8.0, -112.0), Vector2(20.0, 8.0)), Color(accent_color.r, accent_color.g, accent_color.b, 0.82))
	draw_rect(Rect2(Vector2(38.0, -112.0), Vector2(18.0, 8.0)), Color(warning_color.r, warning_color.g, warning_color.b, 0.76))
	draw_rect(Rect2(Vector2(64.0, -112.0), Vector2(16.0, 8.0)), Color(accent_color.r, accent_color.g, accent_color.b, 0.5))

	for rack_x in [blade_pos.x, gun_pos.x]:
		var mast_top := Vector2(rack_x, -124.0)
		draw_rect(Rect2(mast_top + Vector2(-6.0, 0.0), Vector2(12.0, 118.0)), Color(0.05098, 0.058824, 0.07451, 0.96))
		draw_rect(Rect2(mast_top + Vector2(-40.0, 12.0), Vector2(80.0, 10.0)), Color(0.086275, 0.101961, 0.117647, 0.98))
		draw_rect(Rect2(mast_top + Vector2(-28.0, 28.0), Vector2(56.0, 6.0)), Color(0.239216, 0.301961, 0.360784, 0.78))
		draw_line(mast_top + Vector2(0.0, 18.0), mast_top + Vector2(0.0, 122.0), Color(0.180392, 0.211765, 0.25098, 0.9), 2.0)
		draw_line(mast_top + Vector2(-30.0, 16.0), mast_top + Vector2(-48.0, -12.0), Color(0.760784, 0.470588, 0.243137, 0.16), 3.0)
		draw_line(mast_top + Vector2(30.0, 16.0), mast_top + Vector2(48.0, -12.0), Color(0.760784, 0.470588, 0.243137, 0.16), 3.0)

	var rail_y := -140.0
	draw_line(Vector2(blade_pos.x - 52.0, rail_y), Vector2(gun_pos.x + 52.0, rail_y), Color(0.188235, 0.211765, 0.25098, 0.92), 4.0)
	draw_line(Vector2(blade_pos.x - 38.0, rail_y + 8.0), Vector2(gun_pos.x + 38.0, rail_y + 8.0), Color(0.94902, 0.662745, 0.278431, 0.18 + sin(t * 4.6) * 0.04), 2.0)


func _draw_deck(t: float) -> void:
	var top_y := -6.0
	var front_y := top_y + 10.0
	var left := -deck_width * 0.5

	draw_rect(Rect2(left, top_y, deck_width, deck_height), deck_side_color)
	draw_rect(Rect2(left, top_y, deck_width, 12.0), deck_top_color)
	draw_rect(Rect2(left, top_y + 12.0, deck_width, 4.0), Color(0.184314, 0.211765, 0.235294, 0.9))
	draw_rect(Rect2(left, front_y, deck_width, 2.0), Color(0.839216, 0.643137, 0.317647, 0.16))

	var inset := 26.0
	draw_rect(Rect2(left + inset, top_y + 14.0, deck_width - inset * 2.0, 2.0), Color(0.803922, 0.466667, 0.211765, 0.35))
	draw_rect(Rect2(left + inset, top_y + 20.0, deck_width - inset * 2.0, 6.0), Color(0.094118, 0.109804, 0.12549, 1.0))

	for i in range(9):
		var x: float = lerpf(left + 34.0, -34.0, float(i) / 8.0)
		draw_rect(Rect2(x, top_y + 26.0, 16.0, 4.0), Color(0.180392, 0.203922, 0.227451, 1.0))

	for side in [-1.0, 1.0]:
		for i in range(5):
			var side_scalar: float = side
			var px: float = side_scalar * (deck_width * 0.31 + float(i) * 66.0)
			var pulse: float = 0.56 + sin(t * 3.0 + float(i) * 0.7 + side_scalar) * 0.12
			draw_circle(Vector2(px, top_y + 42.0), 3.8, Color(accent_color.r, accent_color.g, accent_color.b, pulse))
			draw_circle(Vector2(px, top_y + 42.0), 8.0, Color(accent_color.r, accent_color.g, accent_color.b, 0.05))

	draw_rect(Rect2(Vector2(-deck_width * 0.5 + 22.0, top_y + 48.0), Vector2(deck_width - 44.0, 18.0)), Color(0.043137, 0.054902, 0.062745, 1.0))
	draw_rect(Rect2(Vector2(-deck_width * 0.5 + 26.0, top_y + 50.0), Vector2(deck_width - 52.0, 4.0)), Color(0.129412, 0.14902, 0.168627, 1.0))
	draw_rect(Rect2(Vector2(-deck_width * 0.5 + 26.0, top_y + 60.0), Vector2(deck_width - 52.0, 2.0)), Color(0.152941, 0.168627, 0.184314, 1.0))

	draw_line(Vector2(-deck_width * 0.5 + 34.0, top_y + 8.0), Vector2(deck_width * 0.5 - 34.0, top_y + 8.0), Color(0.94902, 0.662745, 0.278431, 0.25), 2.0)
	draw_line(Vector2(-deck_width * 0.5 + 34.0, top_y + 66.0), Vector2(deck_width * 0.5 - 34.0, top_y + 66.0), Color(0.270588, 0.901961, 0.92549, 0.2), 1.0)


func _draw_service_platforms(t: float) -> void:
	_draw_hanging_platform(Vector2(-286.0, 104.0), Vector2(172.0, 14.0), 0.22 + sin(t * 2.8) * 0.03)
	_draw_hanging_platform(Vector2(286.0, 104.0), Vector2(172.0, 14.0), 0.22 + sin(t * 2.8 + 0.7) * 0.03)
	_draw_hanging_platform(Vector2(-102.0, 138.0), Vector2(110.0, 12.0), 0.18 + sin(t * 3.6 + 1.0) * 0.03)
	_draw_hanging_platform(Vector2(118.0, 138.0), Vector2(118.0, 12.0), 0.18 + sin(t * 3.6 + 1.4) * 0.03)
	_draw_hanging_platform(Vector2(12.0, 164.0), Vector2(216.0, 14.0), 0.16 + sin(t * 2.4 + 2.2) * 0.03)


func _draw_hanging_platform(center: Vector2, platform_size: Vector2, glow: float) -> void:
	var platform_rect := Rect2(center - platform_size * 0.5, platform_size)
	draw_rect(platform_rect, Color(0.043137, 0.054902, 0.070588, 0.98))
	draw_rect(Rect2(platform_rect.position.x, platform_rect.position.y, platform_rect.size.x, 4.0), Color(0.270588, 0.901961, 0.92549, glow))
	draw_rect(Rect2(platform_rect.position.x + 10.0, platform_rect.position.y + platform_rect.size.y - 4.0, platform_rect.size.x - 20.0, 4.0), Color(0.14902, 0.176471, 0.207843, 0.98))
	var support_xs := [
		platform_rect.position.x + 18.0,
		platform_rect.position.x + platform_rect.size.x * 0.5,
		platform_rect.position.x + platform_rect.size.x - 18.0,
	]
	for support_x in support_xs:
		draw_line(Vector2(support_x, platform_rect.position.y), Vector2(support_x + signf(center.x) * 20.0, platform_rect.position.y - 46.0), Color(0.184314, 0.203922, 0.239216, 0.82), 2.0)
	draw_rect(Rect2(platform_rect.position.x + 16.0, platform_rect.position.y + 5.0, platform_rect.size.x - 32.0, 2.0), Color(0.94902, 0.662745, 0.278431, 0.16))


func _draw_signage(t: float) -> void:
	var landing := _landing_marker_pos()
	var sign_pos := landing + Vector2(12.0, -84.0)
	draw_rect(Rect2(sign_pos + Vector2(-12.0, -14.0), Vector2(126.0, 22.0)), Color(0.05098, 0.062745, 0.07451, 1.0))
	draw_rect(Rect2(sign_pos + Vector2(-4.0, -10.0), Vector2(24.0, 6.0)), Color(accent_color.r, accent_color.g, accent_color.b, 0.82))
	draw_rect(Rect2(sign_pos + Vector2(26.0, -10.0), Vector2(18.0, 6.0)), Color(warning_color.r, warning_color.g, warning_color.b, 0.78))
	draw_rect(Rect2(sign_pos + Vector2(50.0, -10.0), Vector2(34.0, 6.0)), Color(accent_color.r, accent_color.g, accent_color.b, 0.48 + sin(t * 4.0) * 0.08))
	draw_line(sign_pos + Vector2(0.0, 8.0), sign_pos + Vector2(96.0, 8.0), Color(0.839216, 0.643137, 0.317647, 0.22), 2.0)

	draw_rect(Rect2(landing + Vector2(-10.0, -14.0), Vector2(4.0, 12.0)), Color(0.094118, 0.117647, 0.137255, 1.0))
	draw_rect(Rect2(landing + Vector2(6.0, -18.0), Vector2(4.0, 16.0)), Color(0.094118, 0.117647, 0.137255, 1.0))


func _draw_weapon_stand(pos: Vector2, is_blade: bool, t: float) -> void:
	var mode := "blade" if is_blade else "gun"
	var selected := _rack_focus == mode
	var dimmed := _rack_focus != "" and not selected
	var flash_active := _claim_flash_mode == mode and _claim_flash_timer > 0.0
	var accent := accent_color if is_blade else Color(warning_color.r, warning_color.g * 0.94, warning_color.b, 1.0)
	var bone := Color(0.956863, 0.937255, 0.819608, 1.0)
	var base_alpha := 0.36 if dimmed else 1.0
	var pulse := 0.72 + sin(t * 5.2 + (0.0 if is_blade else 1.2)) * 0.16
	if selected:
		pulse += 0.16
	if flash_active:
		pulse += _claim_flash_timer * 1.8

	var base := pos + Vector2(0.0, 36.0)
	var cradle_glow := (0.10 if dimmed else 0.18) + pulse * 0.10

	draw_rect(Rect2(base + Vector2(-28.0, -2.0), Vector2(56.0, 14.0)), Color(0.054902, 0.066667, 0.078431, base_alpha))
	draw_rect(Rect2(base + Vector2(-22.0, -44.0), Vector2(44.0, 40.0)), Color(0.078431, 0.094118, 0.113725, base_alpha))
	draw_rect(Rect2(base + Vector2(-28.0, -110.0), Vector2(56.0, 62.0)), Color(0.043137, 0.054902, 0.070588, 0.96 * base_alpha))
	draw_rect(Rect2(base + Vector2(-20.0, -102.0), Vector2(40.0, 46.0)), Color(0.094118, 0.113725, 0.133333, 0.96 * base_alpha))
	draw_rect(Rect2(base + Vector2(-12.0, -56.0), Vector2(24.0, 52.0)), Color(0.121569, 0.145098, 0.172549, base_alpha))
	draw_rect(Rect2(base + Vector2(-18.0, -118.0), Vector2(36.0, 8.0)), Color(0.184314, 0.211765, 0.243137, base_alpha))
	draw_rect(Rect2(base + Vector2(-24.0, -122.0), Vector2(48.0, 4.0)), Color(accent.r, accent.g, accent.b, 0.18 + pulse * 0.10))
	draw_rect(Rect2(base + Vector2(-14.0, -74.0), Vector2(28.0, 6.0)), Color(accent.r, accent.g, accent.b, cradle_glow))
	draw_arc(base + Vector2(0.0, -74.0), 24.0, PI * 0.18, PI * 0.82, 16, Color(accent.r, accent.g, accent.b, 0.18 + pulse * 0.10), 3.0)
	draw_arc(base + Vector2(0.0, -74.0), 24.0, PI * 1.18, PI * 1.82, 16, Color(accent.r, accent.g, accent.b, 0.18 + pulse * 0.10), 3.0)

	if selected or flash_active:
		draw_rect(Rect2(base + Vector2(-36.0, -122.0), Vector2(72.0, 74.0)), Color(accent.r, accent.g, accent.b, 0.08 + pulse * 0.08))
	if flash_active:
		draw_circle(base + Vector2(0.0, -80.0), 26.0, Color(1.0, 0.945098, 0.756863, 0.16 + _claim_flash_timer * 0.48))

	_draw_display_weapon(base + Vector2(0.0, -78.0), is_blade, accent, bone, base_alpha, pulse)
	draw_circle(base + Vector2(0.0, -8.0), 10.0, Color(accent.r, accent.g, accent.b, 0.06 + pulse * 0.05))


func _draw_display_weapon(center: Vector2, is_blade: bool, accent: Color, bone: Color, alpha_scale: float, pulse: float) -> void:
	var showcase_texture := _blade_showcase_texture if is_blade else _gun_showcase_texture
	if showcase_texture != null:
		var showcase_rect := Rect2(center + Vector2(-42.0, -20.0), Vector2(84.0, 38.0))
		draw_rect(Rect2(showcase_rect.position + Vector2(8.0, 18.0), Vector2(showcase_rect.size.x - 16.0, 4.0)), Color(0.05098, 0.058824, 0.07451, 0.54 * alpha_scale))
		draw_texture_rect(showcase_texture, showcase_rect, false, Color(1.0, 1.0, 1.0, alpha_scale))
		draw_rect(Rect2(showcase_rect.position.x + 10.0, showcase_rect.position.y + showcase_rect.size.y - 8.0, showcase_rect.size.x - 20.0, 2.0), Color(accent.r, accent.g, accent.b, (0.18 + pulse * 0.10) * alpha_scale))
		draw_circle(showcase_rect.position + Vector2(showcase_rect.size.x - 10.0, 8.0), 4.0, Color(accent.r, accent.g, accent.b, (0.16 + pulse * 0.12) * alpha_scale))
		return

	if is_blade:
		var grip := center + Vector2(-6.0, 18.0)
		var spine_mid := center + Vector2(4.0, -2.0)
		var tip := center + Vector2(26.0, -28.0)
		var inner_tip := center + Vector2(14.0, -18.0)
		draw_rect(Rect2(center + Vector2(-12.0, 10.0), Vector2(10.0, 12.0)), Color(accent.r, accent.g, accent.b, 0.94 * alpha_scale))
		draw_line(grip, spine_mid, bone.darkened(0.08), 8.0)
		draw_line(spine_mid, tip, bone.darkened(0.08), 7.0)
		draw_line(grip + Vector2(-10.0, 6.0), grip + Vector2(12.0, 10.0), Color(0.160784, 0.188235, 0.211765, 0.98 * alpha_scale), 4.0)
		draw_line(grip + Vector2(-2.0, 2.0), spine_mid + Vector2(2.0, 0.0), Color(accent.r, accent.g, accent.b, (0.44 + pulse * 0.18) * alpha_scale), 2.0)
		draw_line(spine_mid + Vector2(0.0, 1.0), inner_tip, Color(accent.r, accent.g, accent.b, (0.56 + pulse * 0.20) * alpha_scale), 3.0)
		draw_line(spine_mid + Vector2(-3.0, -8.0), tip, Color(0.984314, 0.894118, 0.627451, (0.38 + pulse * 0.16) * alpha_scale), 2.0)
		draw_circle(tip, 4.0, Color(accent.r, accent.g, accent.b, (0.20 + pulse * 0.12) * alpha_scale))
	else:
		var body_rect := Rect2(center + Vector2(-28.0, -6.0), Vector2(44.0, 16.0))
		var muzzle_rect := Rect2(center + Vector2(14.0, -3.0), Vector2(18.0, 10.0))
		var stock_rect := Rect2(center + Vector2(-36.0, -2.0), Vector2(10.0, 8.0))
		var canister_rect := Rect2(center + Vector2(-10.0, -16.0), Vector2(16.0, 12.0))
		draw_rect(body_rect, Color(0.12549, 0.14902, 0.176471, 0.98 * alpha_scale))
		draw_rect(Rect2(body_rect.position.x, body_rect.position.y, body_rect.size.x, 4.0), Color(accent.r, accent.g, accent.b, (0.42 + pulse * 0.18) * alpha_scale))
		draw_rect(muzzle_rect, Color(0.07451, 0.086275, 0.105882, 0.98 * alpha_scale))
		draw_rect(stock_rect, Color(0.090196, 0.105882, 0.129412, 0.98 * alpha_scale))
		draw_rect(canister_rect, Color(0.184314, 0.211765, 0.243137, 0.98 * alpha_scale))
		draw_rect(Rect2(canister_rect.position + Vector2(3.0, 3.0), Vector2(10.0, 6.0)), Color(0.984314, 0.894118, 0.627451, (0.24 + pulse * 0.12) * alpha_scale))
		draw_line(center + Vector2(-20.0, 0.0), center + Vector2(24.0, 0.0), Color(0.239216, 0.301961, 0.360784, 0.98 * alpha_scale), 2.0)
		draw_line(center + Vector2(24.0, 0.0), center + Vector2(36.0, -4.0), Color(accent.r, accent.g, accent.b, (0.52 + pulse * 0.20) * alpha_scale), 3.0)
		draw_rect(Rect2(center + Vector2(-2.0, 8.0), Vector2(12.0, 8.0)), Color(0.113725, 0.129412, 0.152941, 0.98 * alpha_scale))


func _draw_choice_guide(t: float) -> void:
	if not _choice_guide_visible:
		return

	var prompt_texture := _get_action_prompt_texture(CLAIM_ACTION)
	var neutral_anchor := (_blade_marker() + _gun_marker()) * 0.5 + Vector2(0.0, -134.0)
	var active_anchor := neutral_anchor
	var focused := _rack_focus != ""
	if _rack_focus == "blade":
		active_anchor = _blade_marker() + Vector2(0.0, -140.0)
	elif _rack_focus == "gun":
		active_anchor = _gun_marker() + Vector2(0.0, -140.0)
	active_anchor.y += sin(t * 4.6) * 4.0

	var target_beams: Array[Vector2] = []
	if focused:
		target_beams.append((_blade_marker() if _rack_focus == "blade" else _gun_marker()) + Vector2(0.0, -84.0))
	else:
		target_beams.append(_blade_marker() + Vector2(0.0, -84.0))
		target_beams.append(_gun_marker() + Vector2(0.0, -84.0))

	for beam_target in target_beams:
		draw_line(active_anchor + Vector2(0.0, 12.0), beam_target, Color(0.984314, 0.894118, 0.627451, 0.18 if focused else 0.12), 2.0)
		draw_line(active_anchor + Vector2(0.0, 12.0), beam_target, Color(accent_color.r, accent_color.g, accent_color.b, 0.20 if focused else 0.12), 1.0)
		draw_circle(beam_target, 5.0, Color(accent_color.r, accent_color.g, accent_color.b, 0.10))

	var orb_glow := 0.18 + sin(t * 6.2) * 0.05 + (0.08 if focused else 0.0)
	draw_circle(active_anchor, 20.0, Color(accent_color.r, accent_color.g, accent_color.b, orb_glow))
	draw_circle(active_anchor, 10.0, Color(1.0, 0.929412, 0.721569, 0.88))
	draw_circle(active_anchor + Vector2(-2.0, -2.0), 4.0, Color(0.996078, 0.996078, 0.917647, 0.96))
	draw_colored_polygon(
		PackedVector2Array([active_anchor + Vector2(-14.0, 3.0), active_anchor + Vector2(-28.0, -4.0), active_anchor + Vector2(-20.0, 12.0)]),
		Color(0.984314, 0.894118, 0.627451, 0.62)
	)
	draw_colored_polygon(
		PackedVector2Array([active_anchor + Vector2(14.0, 3.0), active_anchor + Vector2(28.0, -4.0), active_anchor + Vector2(20.0, 12.0)]),
		Color(0.984314, 0.894118, 0.627451, 0.62)
	)
	draw_line(active_anchor + Vector2(-10.0, 10.0), active_anchor + Vector2(-18.0, 22.0), Color(0.984314, 0.894118, 0.627451, 0.54), 2.0)
	draw_line(active_anchor + Vector2(10.0, 10.0), active_anchor + Vector2(18.0, 22.0), Color(0.984314, 0.894118, 0.627451, 0.54), 2.0)

	if not focused:
		draw_line(neutral_anchor + Vector2(-44.0, 0.0), neutral_anchor + Vector2(-24.0, 0.0), Color(0.984314, 0.894118, 0.627451, 0.42), 2.0)
		draw_line(neutral_anchor + Vector2(-44.0, 0.0), neutral_anchor + Vector2(-36.0, -6.0), Color(0.984314, 0.894118, 0.627451, 0.42), 2.0)
		draw_line(neutral_anchor + Vector2(-44.0, 0.0), neutral_anchor + Vector2(-36.0, 6.0), Color(0.984314, 0.894118, 0.627451, 0.42), 2.0)
		draw_line(neutral_anchor + Vector2(44.0, 0.0), neutral_anchor + Vector2(24.0, 0.0), Color(0.984314, 0.894118, 0.627451, 0.42), 2.0)
		draw_line(neutral_anchor + Vector2(44.0, 0.0), neutral_anchor + Vector2(36.0, -6.0), Color(0.984314, 0.894118, 0.627451, 0.42), 2.0)
		draw_line(neutral_anchor + Vector2(44.0, 0.0), neutral_anchor + Vector2(36.0, 6.0), Color(0.984314, 0.894118, 0.627451, 0.42), 2.0)

	_draw_prompt_plate(active_anchor + Vector2(0.0, -32.0), prompt_texture, focused, t)


func _draw_prompt_plate(center: Vector2, prompt_texture: Texture2D, focused: bool, t: float) -> void:
	var pulse := 0.70 + sin(t * 5.6) * 0.10 + (0.12 if focused else 0.0)
	var plate_color := Color(0.05098, 0.058824, 0.07451, 0.96)
	draw_circle(center, 22.0, Color(accent_color.r, accent_color.g, accent_color.b, 0.12 + pulse * 0.08))
	draw_circle(center, 17.0, plate_color)
	draw_circle(center, 14.0, Color(0.113725, 0.129412, 0.152941, 1.0))
	draw_arc(center, 18.0, -2.7, 2.7, 18, Color(0.984314, 0.894118, 0.627451, 0.24 + pulse * 0.10), 2.0)
	if prompt_texture != null:
		var icon_rect := Rect2(center - Vector2(12.0, 12.0), Vector2(24.0, 24.0))
		draw_texture_rect(prompt_texture, icon_rect, false, Color(1.0, 1.0, 1.0, 0.98))
	else:
		draw_circle(center, 6.0, Color(0.984314, 0.894118, 0.627451, 0.82))
		draw_line(center + Vector2(-8.0, 0.0), center + Vector2(8.0, 0.0), Color(accent_color.r, accent_color.g, accent_color.b, 0.78), 2.0)
		draw_line(center + Vector2(0.0, -8.0), center + Vector2(0.0, 8.0), Color(accent_color.r, accent_color.g, accent_color.b, 0.78), 2.0)


func _get_action_prompt_texture(action_name: String) -> Texture2D:
	var prompt_manager := get_node_or_null("/root/PromptManager")
	if prompt_manager == null:
		return null

	var events := InputMap.action_get_events(action_name)
	var display_icons := int(prompt_manager.get("icons"))

	if display_icons == InputPrompt.Icons.KEYBOARD:
		var keyboard_event := _find_prompt_event(events, [InputEventKey, InputEventMouseButton])
		if keyboard_event is InputEventKey:
			var keyboard_textures = prompt_manager.call("get_keyboard_textures")
			return keyboard_textures.get_texture(keyboard_event)
		if keyboard_event is InputEventMouseButton:
			var mouse_textures = prompt_manager.call("get_mouse_textures")
			return mouse_textures.get_texture(keyboard_event)

	var joy_event := _find_prompt_event(events, [InputEventJoypadButton, InputEventJoypadMotion])
	if joy_event is InputEventJoypadButton:
		var button_textures = prompt_manager.call("get_joypad_button_textures", display_icons)
		return button_textures.get_texture(joy_event)
	if joy_event is InputEventJoypadMotion:
		var motion_textures = prompt_manager.call("get_joypad_motion_textures", display_icons)
		return motion_textures.get_texture(joy_event)
	return null


func _find_prompt_event(events: Array[InputEvent], event_types: Array) -> InputEvent:
	for candidate in events:
		for event_type in event_types:
			if is_instance_of(candidate, event_type):
				return candidate
	return null
