extends RefCounted
class_name PixelUI

const COLOR_INK := Color("03060b")
const COLOR_PANEL_DEEP := Color("08131d")
const COLOR_PANEL_MID := Color("22567c")
const COLOR_PANEL_EDGE := Color("7ef2ff")
const COLOR_AMBER := Color("ffd15f")
const COLOR_TEAL := Color("a6fbff")
const COLOR_RUST := Color("ff7f6a")
const COLOR_BONE := Color("f4fbff")
const COLOR_SHADOW_BLUE := Color("040a12")
const COLOR_DISABLED := Color("60728d")
const COLOR_CRIMSON := Color("17253b")
const COLOR_ASH := Color("a5bbd4")
const COLOR_GLASS := Color(0.035294, 0.082353, 0.12549, 0.10)
const COLOR_STEEL := Color(0.039216, 0.070588, 0.113725, 0.05)
const COLOR_BLACK := Color(0.0, 0.0, 0.0, 1.0)


static func create_theme() -> Theme:
	var theme := Theme.new()
	var body_font := _create_font()
	var display_font := _create_font(true)

	theme.set_font("font", "Label", body_font)
	theme.set_font("font", "Button", body_font)
	theme.set_font("font", "LinkButton", body_font)
	theme.set_font("font", "CheckButton", body_font)
	theme.set_font("font", "OptionButton", body_font)
	theme.set_font("font", "PanelContainer", body_font)
	theme.set_font("font", "RichTextLabel", body_font)
	theme.set_font_size("font_size", "Label", 13)
	theme.set_font_size("font_size", "Button", 13)
	theme.set_font_size("font_size", "RichTextLabel", 13)
	theme.set_color("font_color", "Label", COLOR_BONE)
	theme.set_color("font_color", "Button", COLOR_BONE)
	theme.set_color("font_hover_color", "Button", COLOR_BONE)
	theme.set_color("font_pressed_color", "Button", COLOR_AMBER)
	theme.set_color("font_focus_color", "Button", COLOR_AMBER)
	theme.set_color("font_disabled_color", "Button", COLOR_DISABLED)
	theme.set_constant("outline_size", "Label", 1)
	theme.set_color("font_outline_color", "Label", COLOR_BLACK)
	theme.set_constant("outline_size", "Button", 1)
	theme.set_color("font_outline_color", "Button", COLOR_BLACK)
	theme.set_stylebox("panel", "PanelContainer", make_panel_style("window"))
	theme.set_stylebox("normal", "Button", make_panel_style("item"))
	theme.set_stylebox("hover", "Button", make_panel_style("item_selected"))
	theme.set_stylebox("pressed", "Button", make_panel_style("item_selected"))
	theme.set_stylebox("focus", "Button", make_panel_style("item_selected"))
	theme.set_stylebox("disabled", "Button", make_panel_style("item_disabled"))
	theme.set_stylebox("normal", "LinkButton", make_panel_style("clear"))
	theme.set_stylebox("hover", "LinkButton", make_panel_style("clear"))
	theme.set_stylebox("pressed", "LinkButton", make_panel_style("clear"))
	theme.set_stylebox("focus", "LinkButton", make_panel_style("clear"))
	theme.set_constant("h_separation", "HBoxContainer", 8)
	theme.set_constant("v_separation", "VBoxContainer", 8)
	return theme


static func make_panel_style(variant: String = "window") -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.expand_margin_left = 1.0
	style.expand_margin_top = 1.0
	style.expand_margin_right = 1.0
	style.expand_margin_bottom = 1.0
	style.shadow_size = 0
	style.shadow_offset = Vector2.ZERO
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.0)
	style.draw_center = true

	match variant:
		"window":
			style.bg_color = Color(COLOR_GLASS.r, COLOR_GLASS.g, COLOR_GLASS.b, 0.08)
			style.border_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.68)
			style.border_width_top = 2
			style.shadow_size = 8
			style.shadow_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.08)
			style.content_margin_left = 0
			style.content_margin_top = 0
			style.content_margin_right = 0
			style.content_margin_bottom = 0
		"hero":
			style.bg_color = Color(COLOR_INK.r, COLOR_INK.g, COLOR_INK.b, 0.18)
			style.border_color = Color(COLOR_AMBER.r, COLOR_AMBER.g, COLOR_AMBER.b, 0.92)
			style.border_width_top = 2
			style.border_width_bottom = 2
			style.border_width_left = 2
			style.border_width_right = 2
			style.shadow_size = 12
			style.shadow_color = Color(COLOR_AMBER.r, COLOR_AMBER.g, COLOR_AMBER.b, 0.10)
		"glass":
			style.bg_color = COLOR_GLASS
			style.border_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.58)
			style.border_width_top = 2
			style.border_width_bottom = 2
			style.shadow_size = 8
			style.shadow_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.08)
		"display":
			style.bg_color = Color(COLOR_INK.r, COLOR_INK.g, COLOR_INK.b, 0.22)
			style.border_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.74)
			style.border_width_top = 2
			style.shadow_size = 10
			style.shadow_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.07)
		"console":
			style.bg_color = Color(COLOR_STEEL.r, COLOR_STEEL.g, COLOR_STEEL.b, 0.05)
			style.border_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.44)
			style.border_width_top = 2
			style.shadow_size = 6
			style.shadow_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.05)
		"rail":
			style.bg_color = Color(COLOR_STEEL.r, COLOR_STEEL.g, COLOR_STEEL.b, 0.08)
			style.border_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.62)
			style.border_width_top = 2
			style.border_width_left = 2
			style.shadow_size = 8
			style.shadow_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.06)
		"dock":
			style.bg_color = Color(COLOR_STEEL.r, COLOR_STEEL.g, COLOR_STEEL.b, 0.06)
			style.border_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.54)
			style.shadow_size = 6
			style.shadow_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.05)
		"terminal":
			style.bg_color = Color(COLOR_INK.r, COLOR_INK.g, COLOR_INK.b, 0.14)
			style.border_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.52)
			style.border_width_top = 2
			style.shadow_size = 10
			style.shadow_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.08)
		"chip":
			style.bg_color = Color(COLOR_PANEL_MID.r, COLOR_PANEL_MID.g, COLOR_PANEL_MID.b, 0.18)
			style.border_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.62)
			style.border_width_top = 1
			style.border_width_bottom = 1
			style.shadow_size = 5
			style.shadow_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.05)
		"chip_selected":
			style.bg_color = Color(COLOR_AMBER.r, COLOR_AMBER.g, COLOR_AMBER.b, 0.18)
			style.border_color = Color(COLOR_AMBER.r, COLOR_AMBER.g, COLOR_AMBER.b, 0.96)
			style.border_width_left = 2
			style.border_width_top = 2
			style.border_width_right = 2
			style.border_width_bottom = 2
			style.shadow_size = 8
			style.shadow_color = Color(COLOR_AMBER.r, COLOR_AMBER.g, COLOR_AMBER.b, 0.10)
		"item":
			style.bg_color = Color(COLOR_STEEL.r, COLOR_STEEL.g, COLOR_STEEL.b, 0.10)
			style.border_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.38)
			style.shadow_size = 6
			style.shadow_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.04)
		"item_selected":
			style.bg_color = Color(COLOR_AMBER.r, COLOR_AMBER.g, COLOR_AMBER.b, 0.14)
			style.border_color = Color(COLOR_AMBER.r, COLOR_AMBER.g, COLOR_AMBER.b, 0.94)
			style.border_width_left = 4
			style.border_width_top = 2
			style.border_width_bottom = 2
			style.shadow_size = 12
			style.shadow_color = Color(COLOR_AMBER.r, COLOR_AMBER.g, COLOR_AMBER.b, 0.10)
		"item_disabled":
			style.bg_color = Color(COLOR_PANEL_DEEP.r, COLOR_PANEL_DEEP.g, COLOR_PANEL_DEEP.b, 0.04)
			style.border_color = Color(COLOR_DISABLED.r, COLOR_DISABLED.g, COLOR_DISABLED.b, 0.26)
		"warning":
			style.bg_color = Color(COLOR_INK.r, COLOR_INK.g, COLOR_INK.b, 0.16)
			style.border_color = Color(COLOR_RUST.r, COLOR_RUST.g, COLOR_RUST.b, 0.92)
			style.shadow_size = 10
			style.shadow_color = Color(COLOR_RUST.r, COLOR_RUST.g, COLOR_RUST.b, 0.10)
		"inset":
			style.bg_color = Color(COLOR_INK.r, COLOR_INK.g, COLOR_INK.b, 0.18)
			style.border_color = Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.28)
		"clear":
			style.bg_color = Color(0, 0, 0, 0)
			style.border_width_left = 0
			style.border_width_top = 0
			style.border_width_right = 0
			style.border_width_bottom = 0
		_:
			style.bg_color = COLOR_PANEL_DEEP
			style.border_color = COLOR_PANEL_EDGE

	return style


static func style_panel(panel: PanelContainer, variant: String = "window") -> void:
	if panel == null:
		return
	panel.add_theme_stylebox_override("panel", make_panel_style(variant))


static func style_label(label: Label, role: String = "body") -> void:
	if label == null:
		return
	label.add_theme_font_override("font", _create_font(role == "display"))
	match role:
		"display":
			label.add_theme_font_size_override("font_size", 38)
			label.add_theme_color_override("font_color", COLOR_AMBER)
		"brand":
			label.add_theme_font_size_override("font_size", 24)
			label.add_theme_color_override("font_color", COLOR_AMBER)
		"hero_title":
			label.add_theme_font_size_override("font_size", 28)
			label.add_theme_color_override("font_color", COLOR_AMBER)
		"eyebrow":
			label.add_theme_font_size_override("font_size", 11)
			label.add_theme_color_override("font_color", COLOR_TEAL)
		"title":
			label.add_theme_font_size_override("font_size", 16)
			label.add_theme_color_override("font_color", COLOR_BONE)
		"metric":
			label.add_theme_font_size_override("font_size", 28)
			label.add_theme_color_override("font_color", COLOR_BONE)
		"accent":
			label.add_theme_font_size_override("font_size", 13)
			label.add_theme_color_override("font_color", COLOR_TEAL)
		"warning":
			label.add_theme_font_size_override("font_size", 13)
			label.add_theme_color_override("font_color", COLOR_RUST)
		"muted":
			label.add_theme_font_size_override("font_size", 11)
			label.add_theme_color_override("font_color", COLOR_ASH.darkened(0.08))
		"small":
			label.add_theme_font_size_override("font_size", 12)
			label.add_theme_color_override("font_color", COLOR_ASH)
		_:
			label.add_theme_font_size_override("font_size", 13)
			label.add_theme_color_override("font_color", COLOR_BONE)
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_color_override("font_outline_color", COLOR_BLACK)


static func apply_ui_scale(root: Control, scale_value: float) -> void:
	if root == null:
		return
	root.scale = Vector2.ONE * clampf(scale_value, 0.75, 1.75)
	root.pivot_offset = root.size * 0.5


static func pulse_underline_color(active: bool, time_seconds: float) -> Color:
	if not active:
		return Color(COLOR_PANEL_EDGE.r, COLOR_PANEL_EDGE.g, COLOR_PANEL_EDGE.b, 0.28)
	var pulse := 0.74 + sin(time_seconds * 7.4) * 0.16
	return Color(COLOR_AMBER.r * pulse, COLOR_AMBER.g * pulse, COLOR_AMBER.b * pulse, 0.95)


static func _create_font(display: bool = false) -> SystemFont:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(
		["OCR A Extended", "Lucida Console", "Consolas", "Courier New"] if display
		else ["Consolas", "Lucida Console", "Courier New", "Monaco"]
	)
	font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	font.hinting = TextServer.HINTING_NONE
	font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	font.multichannel_signed_distance_field = false
	font.allow_system_fallback = true
	font.force_autohinter = false
	font.oversampling = 1.0
	return font
