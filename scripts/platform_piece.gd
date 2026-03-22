extends StaticBody2D

class_name PlatformPiece

signal triggered(kind: String)
signal activated(kind: String)

const CRUMBLE_DELAY := 0.38
const SPRING_BOOST := -650.0
const ARCHETYPE_DEFAULTS := {
	"stable": "anchor",
	"crumble": "relay",
	"spring": "spring",
	"fuel": "fuel",
}

var kind := "stable"
var archetype := "anchor"
var size := Vector2(160.0, 24.0)
var refill_amount := 44.0
var spring_boost := SPRING_BOOST
var draw_visual := true

var _collision_shape: CollisionShape2D
var _crumble_timer := 0.0
var _broken := false
var _pulse_time := 0.0
var _fuel_cooldown := 0.0
var _spring_cooldown := 0.0
var _fuel_spent := false


func setup(config: Dictionary) -> void:
	kind = String(config.get("kind", "stable"))
	archetype = String(config.get("archetype", _get_default_archetype_for_kind(kind)))
	size = config.get("size", Vector2(160.0, 24.0))
	refill_amount = float(config.get("fuel_amount", config.get("refill", refill_amount)))
	spring_boost = float(config.get("spring_velocity", SPRING_BOOST))
	draw_visual = bool(config.get("draw_visual", true))
	position = config.get("pos", Vector2.ZERO) + size * 0.5
	collision_layer = 2
	collision_mask = 0
	_ensure_collision_shape()
	var shape := RectangleShape2D.new()
	shape.size = size
	_collision_shape.shape = shape
	_fuel_spent = false
	set_process(kind != "stable")
	queue_redraw()


func configure(config: Dictionary) -> void:
	setup(config)


func on_player_contact(player: Node, landing: bool) -> void:
	if _broken:
		return

	match kind:
		"crumble":
			if landing and _crumble_timer <= 0.0:
				_crumble_timer = CRUMBLE_DELAY
				emit_signal("triggered", kind)
				emit_signal("activated", kind)
				queue_redraw()
		"spring":
			if landing and _spring_cooldown <= 0.0:
				_spring_cooldown = 0.18
				player.call("apply_spring_boost", spring_boost)
				emit_signal("triggered", kind)
				emit_signal("activated", kind)
				queue_redraw()
		"fuel":
			if landing and not _fuel_spent and _fuel_cooldown <= 0.0:
				_fuel_spent = true
				_fuel_cooldown = 0.34
				player.call("apply_refill", refill_amount)
				emit_signal("triggered", kind)
				emit_signal("activated", kind)
				queue_redraw()


func _process(delta: float) -> void:
	_pulse_time += delta
	if _fuel_cooldown > 0.0:
		_fuel_cooldown = maxf(_fuel_cooldown - delta, 0.0)
	if _spring_cooldown > 0.0:
		_spring_cooldown = maxf(_spring_cooldown - delta, 0.0)

	if _crumble_timer > 0.0:
		_crumble_timer = maxf(_crumble_timer - delta, 0.0)
		if _crumble_timer <= 0.0:
			_broken = true
			_collision_shape.disabled = true
			collision_layer = 0
			queue_redraw()
		else:
			queue_redraw()
	elif kind == "spring" or (kind == "fuel" and not _fuel_spent):
		queue_redraw()


func _ensure_collision_shape() -> void:
	if _collision_shape != null:
		return

	_collision_shape = CollisionShape2D.new()
	add_child(_collision_shape)


func _get_default_archetype_for_kind(kind_name: String) -> String:
	return String(ARCHETYPE_DEFAULTS.get(kind_name, "anchor"))


func _get_visual_profile() -> Dictionary:
	match archetype:
		"relay":
			return {
				"base": Color(0.160784, 0.2, 0.243137, 1.0),
				"lip": Color(0.490196, 0.619608, 0.643137, 1.0),
				"edge": Color(0.286275, 0.384314, 0.431373, 1.0),
				"panel": Color(0.25098, 0.321569, 0.368627, 0.55),
				"marker": Color(0.733333, 0.807843, 0.756863, 0.9),
				"shadow": Color(0.05098, 0.070588, 0.086275, 0.55),
			}
		"recovery":
			return {
				"base": Color(0.192157, 0.207843, 0.231373, 1.0),
				"lip": Color(0.917647, 0.807843, 0.580392, 1.0),
				"edge": Color(0.458824, 0.454902, 0.376471, 1.0),
				"panel": Color(0.313726, 0.301961, 0.258824, 0.55),
				"marker": Color(0.972549, 0.905882, 0.745098, 0.95),
				"shadow": Color(0.058824, 0.058824, 0.070588, 0.58),
			}
		"kick_wall":
			return {
				"base": Color(0.133333, 0.156863, 0.188235, 1.0),
				"lip": Color(0.823529, 0.717647, 0.447059, 1.0),
				"edge": Color(0.294118, 0.32549, 0.360784, 1.0),
				"panel": Color(0.466667, 0.403922, 0.235294, 0.3),
				"marker": Color(0.968627, 0.835294, 0.462745, 0.95),
				"shadow": Color(0.043137, 0.05098, 0.066667, 0.62),
			}
		"spring":
			return {
				"base": Color(0.172549, 0.231373, 0.286275, 1.0),
				"lip": Color(0.952941, 0.643137, 0.341176, 1.0),
				"edge": Color(0.262745, 0.333333, 0.384314, 1.0),
				"panel": Color(0.086275, 0.121569, 0.145098, 1.0),
				"marker": Color(0.976471, 0.827451, 0.466667, 0.95),
				"shadow": Color(0.047059, 0.066667, 0.082353, 0.62),
			}
		"fuel":
			return {
				"base": Color(0.105882, 0.141176, 0.180392, 1.0),
				"lip": Color(0.341176, 0.572549, 0.603922, 1.0),
				"edge": Color(0.180392, 0.258824, 0.294118, 1.0),
				"panel": Color(0.066667, 0.098039, 0.12549, 1.0),
				"marker": Color(0.929412, 0.643137, 0.341176, 0.95),
				"shadow": Color(0.035294, 0.05098, 0.070588, 0.62),
			}
		"gate":
			return {
				"base": Color(0.223529, 0.188235, 0.145098, 1.0),
				"lip": Color(0.929412, 0.701961, 0.356863, 1.0),
				"edge": Color(0.470588, 0.313726, 0.164706, 1.0),
				"panel": Color(0.333333, 0.243137, 0.152941, 0.42),
				"marker": Color(0.984314, 0.854902, 0.596078, 0.95),
				"shadow": Color(0.070588, 0.05098, 0.039216, 0.62),
			}
		_:
			return {
				"base": Color(0.180392, 0.227451, 0.278431, 1.0),
				"lip": Color(0.870588, 0.831373, 0.678431, 1.0),
				"edge": Color(0.290196, 0.388235, 0.439216, 1.0),
				"panel": Color(0.337255, 0.403922, 0.447059, 0.2),
				"marker": Color(0.960784, 0.894118, 0.737255, 0.9),
				"shadow": Color(0.05098, 0.070588, 0.086275, 0.55),
			}


func _draw() -> void:
	if not draw_visual:
		return

	var half := size * 0.5
	var body_rect := Rect2(-half.x, -half.y, size.x, size.y)
	var is_wall := size.y > size.x * 1.8

	if _broken:
		draw_rect(
			Rect2(-half.x, half.y - 4.0, size.x, 4.0),
			Color(0.090196, 0.121569, 0.14902, 0.45)
		)
		return

	var profile := _get_visual_profile()
	var base_color: Color = profile["base"]
	var lip_color: Color = profile["lip"]
	var edge_color: Color = profile["edge"]
	var panel_color: Color = profile["panel"]
	var marker_color: Color = profile["marker"]
	var shadow_color: Color = profile["shadow"]
	var warning_color := Color(0.952941, 0.643137, 0.341176, 1.0)

	draw_rect(body_rect, base_color)

	if is_wall:
		draw_rect(
			Rect2(-half.x, -half.y, 6.0, size.y),
			edge_color.darkened(0.28)
		)
		draw_rect(
			Rect2(half.x - 6.0, -half.y, 6.0, size.y),
			edge_color
		)
		for index in range(1, int(size.y / 42.0)):
			draw_rect(
				Rect2(-half.x + 8.0, -half.y + float(index) * 36.0, size.x - 16.0, 3.0),
				panel_color
			)
		if archetype == "kick_wall":
			for index in range(int(size.y / 44.0)):
				var y := -half.y + 14.0 + float(index) * 36.0
				draw_line(Vector2(-half.x + 10.0, y), Vector2(half.x - 10.0, y + 10.0), marker_color, 2.0)
		elif archetype == "gate":
			for index in range(int(size.y / 26.0)):
				var y := -half.y + 10.0 + float(index) * 22.0
				draw_rect(Rect2(-half.x + 8.0, y, size.x - 16.0, 5.0), lip_color)
	else:
		draw_rect(
			Rect2(-half.x, -half.y, size.x, 6.0),
			lip_color
		)
		draw_rect(
			Rect2(-half.x, half.y - 7.0, size.x, 7.0),
			shadow_color
		)
		draw_rect(
			Rect2(-half.x + 8.0, -half.y + 8.0, size.x - 16.0, maxf(size.y - 16.0, 4.0)),
			panel_color
		)
		match archetype:
			"anchor":
				draw_rect(Rect2(-half.x + 16.0, -half.y + 11.0, 16.0, 4.0), marker_color)
				draw_rect(Rect2(half.x - 32.0, -half.y + 11.0, 16.0, 4.0), marker_color)
			"relay":
				draw_rect(Rect2(-12.0, -half.y + 7.0, 24.0, size.y - 14.0), marker_color.darkened(0.18))
			"recovery":
				draw_rect(Rect2(-half.x + 14.0, -half.y + 8.0, 16.0, size.y - 16.0), marker_color)
				draw_rect(Rect2(half.x - 30.0, -half.y + 8.0, 16.0, size.y - 16.0), marker_color)
			"gate":
				for index in range(maxi(2, int(size.x / 56.0))):
					var x := -half.x + 14.0 + float(index) * 42.0
					draw_rect(Rect2(x, -half.y + 8.0, 10.0, size.y - 16.0), edge_color)

	match kind:
		"crumble":
			draw_line(
				Vector2(-half.x + 16.0, -half.y + 7.0),
				Vector2(-6.0, half.y - 5.0),
				warning_color.lightened(0.1),
				2.0
			)
			draw_line(
				Vector2(4.0, -half.y + 7.0),
				Vector2(half.x - 18.0, half.y - 5.0),
				warning_color.lightened(0.1),
				2.0
			)
		"spring":
			var spring_glow := 0.74 + sin(_pulse_time * 7.2) * 0.12
			draw_rect(
				Rect2(-half.x + 8.0, -half.y + 8.0, size.x - 16.0, size.y - 14.0),
				panel_color
			)
			for index in range(3):
				var x := -half.x + 18.0 + float(index) * ((size.x - 36.0) / 2.0)
				draw_rect(
					Rect2(x, half.y - 14.0, 8.0, 8.0),
					Color(0.94902, 0.862745, 0.611765, spring_glow)
				)
			draw_rect(
				Rect2(-half.x + 14.0, -half.y + 5.0, size.x - 28.0, 5.0),
				Color(marker_color.r, marker_color.g, marker_color.b, spring_glow)
			)
		"fuel":
			var fuel_glow := 0.76 + sin(_pulse_time * 5.8) * 0.16
			if _fuel_spent:
				fuel_glow = 0.18
			draw_rect(
				Rect2(-half.x + 10.0, -half.y + 8.0, size.x - 20.0, size.y - 14.0),
				panel_color
			)
			draw_rect(
				Rect2(-half.x + 16.0, -half.y + 10.0, size.x - 32.0, size.y - 18.0),
				Color(0.243137, 0.741176, 0.694118, fuel_glow)
			)
			draw_rect(
				Rect2(-half.x + 8.0, -half.y + 5.0, 10.0, 5.0),
				marker_color
			)
			draw_rect(
				Rect2(half.x - 18.0, -half.y + 5.0, 10.0, 5.0),
				marker_color
			)
