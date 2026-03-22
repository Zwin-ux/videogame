extends Node2D

enum RegionMode {
	ESCAPE_BLEND,
	HIVE_SHAFT,
	SUNSET_RUIN,
	MOUNTAIN_PASS,
}

@export var region_mode := RegionMode.ESCAPE_BLEND
@export var world_width := 960.0
@export var world_height := 2240.0
@export var kill_floor_y := 2150.0
@export var show_kill_floor := true

var _stars: Array[Dictionary] = []
var _hive_cells: Array[Dictionary] = []
var _pods: Array[Dictionary] = []
var _mites: Array[Dictionary] = []
var _distant_ruins: Array[Dictionary] = []
var _ruin_columns: Array[Dictionary] = []
var _sky_bridges: Array[Dictionary] = []
var _light_shafts: Array[Dictionary] = []
var _mountain_ridges: Array[Dictionary] = []
var _pine_stands: Array[Dictionary] = []
var _cable_posts: Array[Dictionary] = []


func _ready() -> void:
	set_process(true)
	_rebuild()


func _process(_delta: float) -> void:
	queue_redraw()


func configure(width: float, height: float, kill_floor: float) -> void:
	world_width = width
	world_height = height
	kill_floor_y = kill_floor
	_rebuild()


func set_region_mode(value: int) -> void:
	if region_mode == value:
		return

	region_mode = value
	_rebuild()


func set_kill_floor(value: float) -> void:
	if is_equal_approx(kill_floor_y, value):
		return

	kill_floor_y = value
	queue_redraw()


func set_kill_floor_visible(value: bool) -> void:
	if show_kill_floor == value:
		return

	show_kill_floor = value
	queue_redraw()


func _rebuild() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 19870715

	_stars.clear()
	_hive_cells.clear()
	_pods.clear()
	_mites.clear()
	_distant_ruins.clear()
	_ruin_columns.clear()
	_sky_bridges.clear()
	_light_shafts.clear()
	_mountain_ridges.clear()
	_pine_stands.clear()
	_cable_posts.clear()

	var skyline_bottom := _get_skyline_bottom()
	var breach_y := _get_breach_y()

	for _index in range(72):
		_stars.append(
			{
				"pos": Vector2(
					rng.randf_range(-140.0, world_width + 140.0),
					rng.randf_range(-40.0, skyline_bottom * 0.78)
				),
				"radius": rng.randf_range(1.0, 2.3),
				"alpha": rng.randf_range(0.18, 0.74),
			}
		)

	for index in range(12):
		_hive_cells.append(
			{
				"pos": Vector2(
					158.0 + float(index % 3) * 214.0 + rng.randf_range(-22.0, 22.0),
					breach_y + 180.0 + float(index / 3) * 260.0 + rng.randf_range(-20.0, 20.0)
				),
				"radius": rng.randf_range(20.0, 36.0),
				"alpha": rng.randf_range(0.05, 0.13),
			}
		)

	for index in range(7):
		_pods.append(
			{
				"anchor": Vector2(
					154.0 + float(index % 2) * (world_width - 308.0),
					breach_y + 80.0 + float(index) * 182.0
				),
				"offset": rng.randf_range(30.0, 78.0),
				"radius": rng.randf_range(13.0, 24.0),
				"glow": rng.randf_range(0.12, 0.22),
			}
		)

	for index in range(5):
		_mites.append(
			{
				"pos": Vector2(
					216.0 + float(index % 2) * 408.0 + rng.randf_range(-34.0, 34.0),
					breach_y + 260.0 + float(index) * 240.0 + rng.randf_range(-24.0, 24.0)
				),
				"scale": rng.randf_range(0.72, 1.18),
				"alpha": rng.randf_range(0.08, 0.16),
				"phase": rng.randf_range(0.0, TAU),
			}
		)

	for index in range(14):
		_distant_ruins.append(
			{
				"x": -110.0 + float(index) * 94.0 + rng.randf_range(-18.0, 18.0),
				"width": rng.randf_range(58.0, 116.0),
				"height": rng.randf_range(110.0, 280.0),
				"top": skyline_bottom - rng.randf_range(120.0, 220.0),
				"notch": rng.randf_range(10.0, 32.0),
			}
		)

	for index in range(6):
		_ruin_columns.append(
			{
				"x": 36.0 + float(index) * 164.0 + rng.randf_range(-14.0, 14.0),
				"width": rng.randf_range(52.0, 74.0),
				"top": rng.randf_range(36.0, 120.0),
				"base": skyline_bottom + rng.randf_range(120.0, 230.0),
				"break_y": rng.randf_range(168.0, skyline_bottom - 80.0),
				"trim": rng.randf_range(10.0, 22.0),
			}
		)

	for index in range(4):
		var start_x := 90.0 + float(index) * 198.0 + rng.randf_range(-20.0, 20.0)
		_sky_bridges.append(
			{
				"start": Vector2(start_x, skyline_bottom - 136.0 - float(index % 2) * 40.0),
				"end": Vector2(start_x + 132.0 + rng.randf_range(-18.0, 18.0), skyline_bottom - 132.0 + float(index % 2) * 26.0),
				"thickness": rng.randf_range(10.0, 16.0),
			}
		)

	for index in range(4):
		_light_shafts.append(
			{
				"x": 130.0 + float(index) * 160.0 + rng.randf_range(-20.0, 20.0),
				"width": rng.randf_range(46.0, 74.0),
				"alpha": rng.randf_range(0.06, 0.12),
				"flare": rng.randf_range(120.0, 200.0),
			}
		)

	for index in range(4):
		_mountain_ridges.append(
			{
				"y": skyline_bottom + 56.0 + float(index) * 74.0,
				"peak": 220.0 + float(index) * 54.0,
				"alpha": 0.32 - float(index) * 0.05,
				"shade": 0.17 + float(index) * 0.04,
			}
		)

	for index in range(18):
		_pine_stands.append(
			{
				"x": -90.0 + float(index) * 108.0 + rng.randf_range(-18.0, 18.0),
				"base": skyline_bottom + 188.0 + rng.randf_range(-18.0, 22.0),
				"height": rng.randf_range(42.0, 88.0),
			}
		)

	for index in range(4):
		_cable_posts.append(
			{
				"x": 170.0 + float(index) * 360.0 + rng.randf_range(-18.0, 18.0),
				"base": skyline_bottom + 144.0 + rng.randf_range(-10.0, 16.0),
				"height": rng.randf_range(132.0, 184.0),
			}
		)

	queue_redraw()


func _draw() -> void:
	var full_rect := Rect2(-240.0, -180.0, world_width + 480.0, world_height + 360.0)
	var shaft_left := 118.0
	var shaft_width := world_width - 236.0
	var skyline_bottom := _get_skyline_bottom()
	var breach_y := _get_breach_y()
	var t := Time.get_ticks_msec() / 1000.0

	draw_rect(full_rect, Color(0.015686, 0.019608, 0.031373, 1.0))

	match region_mode:
		RegionMode.HIVE_SHAFT:
			_draw_hive_ambience(full_rect)
			_draw_hive_shaft(shaft_left, shaft_width, -80.0, false, t)
		RegionMode.SUNSET_RUIN:
			_draw_sunset_sky(full_rect, skyline_bottom, t)
			_draw_sunset_ruin_layers(skyline_bottom, t, 1.0)
		RegionMode.MOUNTAIN_PASS:
			_draw_mountain_pass(full_rect, skyline_bottom, t)
		_:
			_draw_sunset_sky(full_rect, skyline_bottom, t)
			_draw_sunset_ruin_layers(skyline_bottom, t, 0.92)
			_draw_breach_light(shaft_left, shaft_width, breach_y, t)
			_draw_hive_ambience(full_rect)
			_draw_hive_shaft(shaft_left, shaft_width, breach_y, true, t)

	if show_kill_floor:
		_draw_kill_floor(full_rect, t)


func _draw_hive_ambience(full_rect: Rect2) -> void:
	draw_rect(full_rect, Color(0.015686, 0.019608, 0.031373, 0.88))
	draw_rect(
		Rect2(-240.0, world_height * 0.46, world_width + 480.0, world_height * 0.72),
		Color(0.019608, 0.023529, 0.035294, 0.84)
	)
	draw_circle(Vector2(world_width * 0.18, 182.0), 220.0, Color(0.482353, 0.184314, 0.090196, 0.05))
	draw_circle(Vector2(world_width * 0.82, 280.0), 170.0, Color(0.964706, 0.65098, 0.333333, 0.03))
	draw_circle(Vector2(world_width * 0.52, 420.0), 300.0, Color(0.254902, 0.568627, 0.603922, 0.018))


func _draw_sunset_sky(full_rect: Rect2, skyline_bottom: float, t: float) -> void:
	var sky_rect := Rect2(full_rect.position.x, full_rect.position.y, full_rect.size.x, skyline_bottom + 260.0)
	_draw_vertical_gradient(
		sky_rect,
		Color(0.203922, 0.145098, 0.345098, 1.0),
		Color(0.588235, 0.262745, 0.356863, 1.0),
		Color(0.952941, 0.705882, 0.317647, 1.0),
		0.56,
		34
	)
	draw_circle(Vector2(world_width * 0.24, skyline_bottom - 58.0), 210.0, Color(0.972549, 0.745098, 0.403922, 0.18))
	draw_circle(Vector2(world_width * 0.74, skyline_bottom - 160.0), 280.0, Color(0.796078, 0.360784, 0.368627, 0.11))
	draw_rect(Rect2(full_rect.position.x, skyline_bottom - 20.0, full_rect.size.x, 180.0), Color(0.427451, 0.196078, 0.235294, 0.2))

	for star in _stars:
		var star_pos: Vector2 = star["pos"]
		var star_radius: float = star["radius"]
		var star_alpha: float = star["alpha"]
		var flicker: float = star_alpha + sin(t * 1.8 + star_pos.x * 0.02) * 0.04
		draw_circle(star_pos, star_radius, Color(0.984314, 0.945098, 0.827451, clampf(flicker, 0.08, 0.72)))


func _draw_sunset_ruin_layers(skyline_bottom: float, t: float, alpha_mod: float) -> void:
	var horizon_band := skyline_bottom - 26.0 + sin(t * 0.35) * 4.0
	draw_rect(Rect2(-240.0, horizon_band, world_width + 480.0, 18.0), Color(0.980392, 0.827451, 0.509804, 0.12 * alpha_mod))

	for ruin in _distant_ruins:
		_draw_distant_ruin(ruin, alpha_mod)

	for bridge in _sky_bridges:
		_draw_sky_bridge(bridge, alpha_mod)

	for column in _ruin_columns:
		_draw_ruin_column(column, alpha_mod)

	var sigil_pos := Vector2(world_width * 0.78, skyline_bottom - 196.0)
	draw_circle(sigil_pos, 18.0, Color(0.952941, 0.780392, 0.470588, 0.1 * alpha_mod))
	draw_line(sigil_pos + Vector2(-34.0, 0.0), sigil_pos + Vector2(34.0, 0.0), Color(0.952941, 0.780392, 0.470588, 0.09 * alpha_mod), 3.0)
	draw_line(sigil_pos + Vector2(0.0, -28.0), sigil_pos + Vector2(0.0, 28.0), Color(0.317647, 0.541176, 0.564706, 0.1 * alpha_mod), 2.0)


func _draw_mountain_pass(full_rect: Rect2, skyline_bottom: float, t: float) -> void:
	_draw_vertical_gradient(
		Rect2(full_rect.position.x, full_rect.position.y, full_rect.size.x, skyline_bottom + 300.0),
		Color(0.129412, 0.141176, 0.254902, 1.0),
		Color(0.356863, 0.278431, 0.439216, 1.0),
		Color(0.937255, 0.611765, 0.352941, 1.0),
		0.58,
		36
	)
	draw_circle(Vector2(world_width * 0.72, skyline_bottom - 134.0), 190.0, Color(0.972549, 0.776471, 0.45098, 0.18))
	draw_circle(Vector2(world_width * 0.3, skyline_bottom - 102.0), 240.0, Color(0.847059, 0.380392, 0.34902, 0.08))

	for star in _stars:
		var star_pos: Vector2 = star["pos"]
		if star_pos.y > skyline_bottom - 60.0:
			continue
		var flicker: float = float(star["alpha"]) + sin(t * 1.4 + star_pos.x * 0.018) * 0.03
		draw_circle(star_pos, float(star["radius"]), Color(0.984314, 0.945098, 0.827451, clampf(flicker, 0.04, 0.52)))

	for ridge in _mountain_ridges:
		_draw_mountain_ridge(ridge)

	for post in _cable_posts:
		_draw_cable_post(post)

	var cable_start := Vector2(-80.0, skyline_bottom - 36.0)
	var cable_end := Vector2(world_width + 120.0, skyline_bottom + 132.0)
	draw_line(cable_start, cable_end, Color(0.835294, 0.737255, 0.541176, 0.54), 3.0)
	draw_line(cable_start + Vector2(0.0, 10.0), cable_end + Vector2(0.0, 14.0), Color(0.227451, 0.258824, 0.309804, 0.45), 2.0)
	draw_rect(Rect2(world_width - 238.0, skyline_bottom + 54.0, 112.0, 66.0), Color(0.047059, 0.054902, 0.070588, 0.96))
	draw_circle(Vector2(world_width - 182.0, skyline_bottom + 90.0), 24.0, Color(0.011765, 0.011765, 0.019608, 1.0))
	draw_arc(Vector2(world_width - 182.0, skyline_bottom + 90.0), 28.0, -1.8, 1.8, 22, Color(0.94902, 0.694118, 0.356863, 0.34), 4.0)

	for stand in _pine_stands:
		_draw_pine(stand)

	draw_rect(Rect2(-240.0, skyline_bottom + 148.0, world_width + 480.0, 320.0), Color(0.07451, 0.090196, 0.117647, 0.84))


func _draw_hive_shaft(shaft_left: float, shaft_width: float, shaft_top_y: float, has_breach: bool, t: float) -> void:
	var wall_y := shaft_top_y
	var wall_height := world_height - wall_y + 160.0
	var breach_reference_y := shaft_top_y if has_breach else 180.0

	draw_rect(Rect2(shaft_left - 82.0, wall_y, 66.0, wall_height), Color(0.031373, 0.039216, 0.054902, 0.97))
	draw_rect(Rect2(shaft_left + shaft_width + 16.0, wall_y, 66.0, wall_height), Color(0.031373, 0.039216, 0.054902, 0.97))
	draw_rect(Rect2(shaft_left - 16.0, wall_y, 16.0, wall_height), Color(0.309804, 0.415686, 0.47451, 0.42))
	draw_rect(Rect2(shaft_left + shaft_width, wall_y, 16.0, wall_height), Color(0.309804, 0.415686, 0.47451, 0.42))
	draw_rect(Rect2(shaft_left + 16.0, wall_y, shaft_width - 32.0, wall_height), Color(0.023529, 0.031373, 0.047059, 0.86))

	if has_breach:
		_draw_breach_shell(shaft_left, shaft_width, shaft_top_y)

	var rib_start := maxf(shaft_top_y + 138.0, 140.0)
	for index in range(10):
		var rib_y := rib_start + float(index) * 248.0
		if rib_y > world_height + 80.0:
			break
		var pulse := 0.1 + sin(t * 1.8 + float(index) * 0.5) * 0.03
		draw_rect(Rect2(shaft_left + 38.0, rib_y, shaft_width - 76.0, 3.0), Color(0.305882, 0.196078, 0.12549, 0.22))
		draw_line(
			Vector2(shaft_left + 24.0, rib_y + 16.0),
			Vector2(shaft_left + 124.0, rib_y - 30.0),
			Color(0.317647, 0.392157, 0.447059, 0.25),
			5.0
		)
		draw_line(
			Vector2(shaft_left + shaft_width - 24.0, rib_y + 16.0),
			Vector2(shaft_left + shaft_width - 124.0, rib_y - 30.0),
			Color(0.317647, 0.392157, 0.447059, 0.25),
			5.0
		)
		draw_line(
			Vector2(shaft_left + 72.0, rib_y + 2.0),
			Vector2(shaft_left + shaft_width - 72.0, rib_y + 2.0),
			Color(0.952941, 0.643137, 0.341176, pulse),
			2.0
		)

	for cell in _hive_cells:
		var cell_pos: Vector2 = cell["pos"]
		if cell_pos.y < shaft_top_y + 24.0:
			continue
		_draw_cell(cell_pos, float(cell["radius"]), float(cell["alpha"]))

	for pod in _pods:
		var pod_anchor: Vector2 = pod["anchor"]
		var pod_offset: float = pod["offset"]
		if pod_anchor.y < shaft_top_y - 10.0:
			continue
		var swing: float = sin(t * 1.35 + pod_offset * 0.12) * 8.0
		var pod_pos := Vector2(pod_anchor.x + swing, pod_anchor.y + pod_offset)
		draw_line(pod_anchor, pod_pos, Color(0.356863, 0.462745, 0.529412, 0.28), 2.0)
		_draw_pod(pod_pos, float(pod["radius"]), float(pod["glow"]))

	var service_structures := [
		{"rect": Rect2(shaft_left + 24.0, world_height - 326.0, 154.0, 236.0), "top_lit": true, "hot_band": false},
		{"rect": Rect2(shaft_left + 264.0, world_height - 1232.0, 132.0, 322.0), "top_lit": false, "hot_band": true},
		{"rect": Rect2(shaft_left + shaft_width - 294.0, world_height - 1108.0, 178.0, 278.0), "top_lit": true, "hot_band": false},
		{"rect": Rect2(shaft_left + 162.0, breach_reference_y + 332.0, 196.0, 246.0), "top_lit": false, "hot_band": true},
		{"rect": Rect2(shaft_left + shaft_width - 330.0, breach_reference_y + 176.0, 210.0, 308.0), "top_lit": true, "hot_band": true},
	]
	for structure in service_structures:
		var structure_rect: Rect2 = structure["rect"]
		if structure_rect.position.y < shaft_top_y + 22.0:
			continue
		_draw_service_structure(structure_rect, bool(structure["top_lit"]), bool(structure["hot_band"]))

	for mite in _mites:
		var mite_pos: Vector2 = mite["pos"]
		if mite_pos.y < shaft_top_y + 40.0:
			continue
		_draw_mite(mite_pos, float(mite["scale"]), float(mite["alpha"]), float(mite["phase"]), t)

	if has_breach:
		var queen_glow := 0.1 + sin(t * 1.9) * 0.03
		_draw_top_cave_mouth(Vector2(world_width * 0.53, shaft_top_y + 82.0))
		_draw_queen_sigil(Vector2(world_width * 0.5, shaft_top_y + 104.0), 1.0, queen_glow)


func _draw_breach_light(shaft_left: float, shaft_width: float, breach_y: float, t: float) -> void:
	for beam in _light_shafts:
		var beam_x: float = beam["x"]
		var beam_width: float = beam["width"]
		var beam_alpha: float = beam["alpha"]
		var beam_flare: float = beam["flare"]
		var alpha: float = beam_alpha + sin(t * 0.9 + beam_x * 0.01) * 0.015
		var beam_points := PackedVector2Array(
			[
				Vector2(beam_x - beam_width * 0.22, -120.0),
				Vector2(beam_x + beam_width * 0.22, -120.0),
				Vector2(beam_x + beam_flare, breach_y + 200.0),
				Vector2(beam_x - beam_flare * 0.4, breach_y + 200.0),
			]
		)
		draw_colored_polygon(beam_points, Color(0.996078, 0.870588, 0.572549, clampf(alpha, 0.02, 0.14)))

	var breach_band := Rect2(shaft_left + 72.0, breach_y - 18.0, shaft_width - 144.0, 26.0)
	draw_rect(breach_band, Color(0.984314, 0.819608, 0.45098, 0.16))
	draw_rect(Rect2(shaft_left + 120.0, breach_y + 16.0, shaft_width - 240.0, 8.0), Color(0.286275, 0.831373, 0.898039, 0.14))


func _draw_breach_shell(shaft_left: float, shaft_width: float, breach_y: float) -> void:
	var left_shell := PackedVector2Array(
		[
			Vector2(shaft_left - 86.0, breach_y + 164.0),
			Vector2(shaft_left - 86.0, breach_y - 26.0),
			Vector2(shaft_left - 38.0, breach_y - 56.0),
			Vector2(shaft_left + 24.0, breach_y - 124.0),
			Vector2(shaft_left + 76.0, breach_y - 28.0),
			Vector2(shaft_left + 52.0, breach_y + 72.0),
			Vector2(shaft_left + 18.0, breach_y + 160.0),
		]
	)
	var right_shell := PackedVector2Array(
		[
			Vector2(shaft_left + shaft_width + 86.0, breach_y + 164.0),
			Vector2(shaft_left + shaft_width + 86.0, breach_y - 26.0),
			Vector2(shaft_left + shaft_width + 38.0, breach_y - 56.0),
			Vector2(shaft_left + shaft_width - 24.0, breach_y - 124.0),
			Vector2(shaft_left + shaft_width - 76.0, breach_y - 28.0),
			Vector2(shaft_left + shaft_width - 52.0, breach_y + 72.0),
			Vector2(shaft_left + shaft_width - 18.0, breach_y + 160.0),
		]
	)
	draw_colored_polygon(left_shell, Color(0.039216, 0.047059, 0.066667, 0.94))
	draw_colored_polygon(right_shell, Color(0.039216, 0.047059, 0.066667, 0.94))
	draw_polyline(left_shell + PackedVector2Array([left_shell[0]]), Color(0.364706, 0.447059, 0.509804, 0.34), 3.0)
	draw_polyline(right_shell + PackedVector2Array([right_shell[0]]), Color(0.364706, 0.447059, 0.509804, 0.34), 3.0)
	draw_rect(Rect2(shaft_left + 74.0, breach_y - 10.0, shaft_width - 148.0, 5.0), Color(0.984314, 0.729412, 0.364706, 0.22))


func _draw_distant_ruin(ruin: Dictionary, alpha_mod: float) -> void:
	var ruin_x: float = ruin["x"]
	var ruin_top: float = ruin["top"]
	var ruin_width: float = ruin["width"]
	var ruin_height: float = ruin["height"]
	var trim_height: float = maxf(12.0, float(ruin["notch"]))
	var body_rect := Rect2(ruin_x, ruin_top, ruin_width, ruin_height)
	draw_rect(body_rect, Color(0.227451, 0.192157, 0.309804, 0.74 * alpha_mod))
	draw_rect(Rect2(body_rect.position.x, body_rect.position.y, body_rect.size.x, 5.0), Color(0.670588, 0.662745, 0.537255, 0.1 * alpha_mod))
	draw_rect(
		Rect2(body_rect.position.x + body_rect.size.x * 0.18, body_rect.position.y + 26.0, body_rect.size.x * 0.2, trim_height),
		Color(0.701961, 0.713725, 0.592157, 0.08 * alpha_mod)
	)
	draw_rect(
		Rect2(body_rect.position.x + body_rect.size.x * 0.56, body_rect.position.y + 42.0, body_rect.size.x * 0.16, trim_height * 0.86),
		Color(0.701961, 0.713725, 0.592157, 0.08 * alpha_mod)
	)


func _draw_sky_bridge(bridge: Dictionary, alpha_mod: float) -> void:
	var bridge_start: Vector2 = bridge["start"]
	var bridge_end: Vector2 = bridge["end"]
	var bridge_thickness: float = bridge["thickness"]
	var delta: Vector2 = bridge_end - bridge_start
	var length: float = delta.length()
	var angle: float = delta.angle()
	draw_set_transform(bridge_start, angle, Vector2.ONE)
	draw_rect(
		Rect2(0.0, -bridge_thickness * 0.5, length, bridge_thickness),
		Color(0.25098, 0.321569, 0.356863, 0.28 * alpha_mod)
	)
	draw_rect(
		Rect2(6.0, -bridge_thickness * 0.5 + 2.0, length - 12.0, 2.0),
		Color(0.964706, 0.729412, 0.372549, 0.14 * alpha_mod)
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_ruin_column(column: Dictionary, alpha_mod: float) -> void:
	var column_x: float = column["x"]
	var column_top: float = column["top"]
	var column_width: float = column["width"]
	var column_base: float = column["base"]
	var column_break_y: float = column["break_y"]
	var column_trim: float = column["trim"]
	var body_rect := Rect2(column_x, column_top, column_width, column_base - column_top)
	draw_rect(body_rect, Color(0.286275, 0.313725, 0.337255, 0.72 * alpha_mod))
	draw_rect(Rect2(body_rect.position.x, body_rect.position.y, body_rect.size.x, 7.0), Color(0.752941, 0.733333, 0.533333, 0.18 * alpha_mod))
	draw_rect(Rect2(body_rect.position.x + 4.0, body_rect.position.y + 18.0, body_rect.size.x - 8.0, 6.0), Color(0.188235, 0.231373, 0.262745, 0.52 * alpha_mod))
	draw_rect(Rect2(body_rect.position.x + 6.0, body_rect.position.y + column_trim, body_rect.size.x - 12.0, 4.0), Color(0.596078, 0.713725, 0.623529, 0.12 * alpha_mod))
	draw_rect(Rect2(body_rect.position.x + 10.0, column_break_y, body_rect.size.x - 20.0, 12.0), Color(0.160784, 0.188235, 0.219608, 0.64 * alpha_mod))
	draw_rect(Rect2(body_rect.position.x + 4.0, column_base - 26.0, body_rect.size.x - 8.0, 10.0), Color(0.160784, 0.184314, 0.227451, 0.62 * alpha_mod))
	draw_rect(Rect2(body_rect.position.x + body_rect.size.x * 0.18, body_rect.position.y + 46.0, 8.0, body_rect.size.y - 82.0), Color(0.917647, 0.701961, 0.360784, 0.05 * alpha_mod))

	var cap := PackedVector2Array(
		[
			Vector2(body_rect.position.x - 12.0, body_rect.position.y + 12.0),
			Vector2(body_rect.position.x + body_rect.size.x + 10.0, body_rect.position.y + 12.0),
			Vector2(body_rect.position.x + body_rect.size.x + 18.0, body_rect.position.y + 34.0),
			Vector2(body_rect.position.x - 18.0, body_rect.position.y + 34.0),
		]
	)
	draw_colored_polygon(cap, Color(0.403922, 0.423529, 0.380392, 0.3 * alpha_mod))


func _draw_kill_floor(full_rect: Rect2, t: float) -> void:
	var floor_glow := 0.72 + sin(t * 4.4) * 0.08
	draw_rect(Rect2(full_rect.position.x, kill_floor_y - 26.0, full_rect.size.x, world_height - kill_floor_y + 240.0), Color(0.121569, 0.027451, 0.019608, 0.86))
	draw_rect(Rect2(full_rect.position.x, kill_floor_y - 14.0, full_rect.size.x, 14.0), Color(0.952941, 0.643137, 0.341176, floor_glow))
	draw_rect(Rect2(full_rect.position.x, kill_floor_y - 46.0, full_rect.size.x, 16.0), Color(0.364706, 0.117647, 0.070588, 0.58))
	draw_rect(Rect2(full_rect.position.x, kill_floor_y - 90.0, full_rect.size.x, 28.0), Color(0.952941, 0.643137, 0.341176, 0.08))


func _draw_vertical_gradient(rect: Rect2, top_color: Color, mid_color: Color, bottom_color: Color, split: float, steps: int) -> void:
	for index in range(steps):
		var start_t := float(index) / float(steps)
		var end_t := float(index + 1) / float(steps)
		var sample := (start_t + end_t) * 0.5
		var color := top_color
		if sample < split:
			color = top_color.lerp(mid_color, sample / split)
		else:
			color = mid_color.lerp(bottom_color, (sample - split) / (1.0 - split))
		var band_y := rect.position.y + rect.size.y * start_t
		var band_h := rect.size.y * (end_t - start_t) + 1.0
		draw_rect(Rect2(rect.position.x, band_y, rect.size.x, band_h), color)


func _draw_cell(center: Vector2, radius: float, alpha: float) -> void:
	var points := PackedVector2Array()
	for index in range(6):
		var angle := TAU * float(index) / 6.0 + PI / 6.0
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, Color(0.278431, 0.34902, 0.403922, alpha))
	draw_polyline(points + PackedVector2Array([points[0]]), Color(0.952941, 0.643137, 0.341176, alpha * 0.7), 2.0)


func _draw_pod(center: Vector2, radius: float, glow: float) -> void:
	draw_circle(center + Vector2(0.0, radius + 4.0), radius * 0.82, Color(0.0, 0.0, 0.0, 0.16))
	draw_circle(center, radius, Color(0.160784, 0.168627, 0.231373, 0.96))
	draw_circle(center + Vector2(0.0, 1.0), radius * 0.72, Color(0.462745, 0.156863, 0.086275, glow + 0.2))
	draw_circle(center + Vector2(0.0, 1.0), radius * 0.42, Color(0.952941, 0.643137, 0.341176, glow + 0.18))
	draw_rect(Rect2(center.x - radius * 0.8, center.y - 2.0, radius * 1.6, 3.0), Color(0.94902, 0.862745, 0.611765, glow * 0.7))
	draw_rect(Rect2(center.x - 2.0, center.y - radius * 0.85, 4.0, radius * 1.7), Color(0.286275, 0.831373, 0.898039, glow * 0.5))


func _draw_mite(center: Vector2, scale: float, alpha: float, phase: float, t: float) -> void:
	var flap := sin(t * 5.2 + phase) * 5.0 * scale
	var color := Color(0.145098, 0.160784, 0.211765, alpha)
	var body := PackedVector2Array(
		[
			center + Vector2(-8.0, 0.0) * scale,
			center + Vector2(-2.0, -8.0) * scale,
			center + Vector2(7.0, -5.0) * scale,
			center + Vector2(10.0, 0.0) * scale,
			center + Vector2(7.0, 5.0) * scale,
			center + Vector2(-2.0, 8.0) * scale,
		]
	)
	var wing_a := PackedVector2Array(
		[
			center + Vector2(-3.0, -2.0) * scale,
			center + Vector2(-18.0, -10.0 - flap) * scale,
			center + Vector2(-10.0, 4.0) * scale,
		]
	)
	var wing_b := PackedVector2Array(
		[
			center + Vector2(2.0, -2.0) * scale,
			center + Vector2(18.0, -10.0 + flap) * scale,
			center + Vector2(10.0, 4.0) * scale,
		]
	)
	draw_colored_polygon(wing_a, Color(0.227451, 0.278431, 0.321569, alpha * 0.75))
	draw_colored_polygon(wing_b, Color(0.227451, 0.278431, 0.321569, alpha * 0.75))
	draw_colored_polygon(body, color)
	draw_circle(center + Vector2(8.0, 0.0) * scale, 1.8 * scale, Color(0.952941, 0.643137, 0.341176, alpha * 0.8))


func _draw_service_structure(rect: Rect2, top_lit: bool, hot_band: bool) -> void:
	draw_rect(rect, Color(0.043137, 0.054902, 0.07451, 0.88))
	draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 5.0), Color(0.160784, 0.188235, 0.223529, 0.94))
	draw_rect(Rect2(rect.position.x + 10.0, rect.position.y + rect.size.y - 16.0, rect.size.x - 20.0, 8.0), Color(0.05098, 0.062745, 0.078431, 0.7))
	if top_lit:
		draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 5.0), Color(0.286275, 0.831373, 0.898039, 0.16))
	if hot_band:
		draw_rect(Rect2(rect.position.x + 12.0, rect.position.y + rect.size.y * 0.36, rect.size.x - 24.0, 6.0), Color(0.952941, 0.643137, 0.341176, 0.1))


func _draw_queen_sigil(center: Vector2, scale: float, glow: float) -> void:
	var crown := PackedVector2Array(
		[
			center + Vector2(-46.0, 6.0) * scale,
			center + Vector2(-24.0, -28.0) * scale,
			center + Vector2(-4.0, 0.0) * scale,
			center + Vector2(0.0, -42.0) * scale,
			center + Vector2(4.0, 0.0) * scale,
			center + Vector2(24.0, -28.0) * scale,
			center + Vector2(46.0, 6.0) * scale,
			center + Vector2(0.0, 28.0) * scale,
		]
	)
	draw_colored_polygon(crown, Color(0.317647, 0.180392, 0.121569, glow + 0.05))
	draw_polyline(crown + PackedVector2Array([crown[0]]), Color(0.952941, 0.643137, 0.341176, glow + 0.08), 3.0)
	draw_circle(center, 9.0 * scale, Color(0.286275, 0.831373, 0.898039, glow + 0.08))


func _draw_top_cave_mouth(center: Vector2) -> void:
	draw_circle(center, 42.0, Color(0.007843, 0.007843, 0.015686, 1.0))
	draw_arc(center, 54.0, -2.95, -0.2, 26, Color(0.94902, 0.694118, 0.356863, 0.36), 6.0)
	draw_arc(center, 36.0, -2.8, -0.38, 22, Color(0.286275, 0.831373, 0.898039, 0.22), 4.0)


func _draw_mountain_ridge(ridge: Dictionary) -> void:
	var ridge_y: float = ridge["y"]
	var ridge_peak: float = ridge["peak"]
	var ridge_alpha: float = ridge["alpha"]
	var ridge_shade: float = ridge["shade"]
	var points := PackedVector2Array(
		[
			Vector2(-240.0, world_height + 220.0),
			Vector2(-180.0, ridge_y + 54.0),
			Vector2(world_width * 0.12, ridge_y - ridge_peak * 0.42),
			Vector2(world_width * 0.32, ridge_y - ridge_peak),
			Vector2(world_width * 0.56, ridge_y - ridge_peak * 0.55),
			Vector2(world_width * 0.74, ridge_y - ridge_peak * 0.8),
			Vector2(world_width + 120.0, ridge_y + 62.0),
			Vector2(world_width + 240.0, world_height + 220.0),
		]
	)
	draw_colored_polygon(points, Color(ridge_shade, ridge_shade + 0.04, ridge_shade + 0.08, ridge_alpha))


func _draw_pine(stand: Dictionary) -> void:
	var pine_x: float = stand["x"]
	var pine_base: float = stand["base"]
	var pine_height: float = stand["height"]
	draw_rect(Rect2(pine_x - 3.0, pine_base - 18.0, 6.0, 18.0), Color(0.105882, 0.090196, 0.082353, 0.92))
	var crown := PackedVector2Array(
		[
			Vector2(pine_x, pine_base - pine_height),
			Vector2(pine_x - pine_height * 0.26, pine_base - pine_height * 0.42),
			Vector2(pine_x - pine_height * 0.16, pine_base - pine_height * 0.42),
			Vector2(pine_x - pine_height * 0.34, pine_base - pine_height * 0.12),
			Vector2(pine_x + pine_height * 0.34, pine_base - pine_height * 0.12),
			Vector2(pine_x + pine_height * 0.16, pine_base - pine_height * 0.42),
			Vector2(pine_x + pine_height * 0.26, pine_base - pine_height * 0.42),
		]
	)
	draw_colored_polygon(crown, Color(0.07451, 0.109804, 0.121569, 0.92))


func _draw_cable_post(post: Dictionary) -> void:
	var post_x: float = post["x"]
	var post_base: float = post["base"]
	var post_height: float = post["height"]
	draw_rect(Rect2(post_x - 7.0, post_base - post_height, 14.0, post_height), Color(0.207843, 0.223529, 0.25098, 0.86))
	draw_rect(Rect2(post_x - 28.0, post_base - post_height + 16.0, 56.0, 8.0), Color(0.807843, 0.713725, 0.490196, 0.48))
	draw_line(Vector2(post_x - 24.0, post_base - post_height + 20.0), Vector2(post_x + 24.0, post_base - post_height + 20.0), Color(0.196078, 0.203922, 0.239216, 0.86), 3.0)


func _get_skyline_bottom() -> float:
	return clampf(world_height * 0.32, 840.0, 1080.0)


func _get_breach_y() -> float:
	return _get_skyline_bottom() + 112.0
