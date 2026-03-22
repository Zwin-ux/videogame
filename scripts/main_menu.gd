extends Control

const MenuArtRef = preload("res://scripts/menu_art.gd")
const SkinPreviewRef = preload("res://scripts/skin_preview.gd")

const MENU_MODE_ATTRACT := "attract"
const MENU_MODE_TERMINAL := "terminal"

const VIEW_HOME := "home"
const VIEW_DOSSIER := "dossier"
const VIEW_SYSTEMS := "systems"

const VIEW_TITLE := VIEW_HOME
const VIEW_CUSTOMIZE := VIEW_DOSSIER
const VIEW_OPTIONS := VIEW_SYSTEMS

const ICON_FRAME_SIZE := Vector2i(16, 16)
const SWARM_FRAME_SIZE := Vector2i(32, 32)
const QUEEN_FRAME_SIZE := Vector2i(96, 96)

const INFESTATION_NAMES := [
	"SCARRED",
	"HIVE BLOOM",
	"BROOD STORM",
	"COLLAPSE",
]

const MAIN_ENTRIES := [
	{"id": "start", "title": "TAKE CONTRACT", "tag": "DROP", "icon": 0, "summary": "Open kill credit is still live over Khepri-9."},
	{"id": "dossier", "title": "DOSSIER", "tag": "FILE", "icon": 1, "summary": "Hunter shell, weapon proof, and claim history."},
	{"id": "systems", "title": "SYSTEMS", "tag": "CAL", "icon": 2, "summary": "The few ship fields that matter before re-entry."},
	{"id": "quit", "title": "QUIT", "tag": "CUT", "icon": 3, "summary": "Break the broker link and leave the queue behind."},
]

const DOSSIER_ROWS := [
	{"id": "skin", "label": "SHELL", "icon": 4, "summary": "Cycle the live hunter shell."},
	{"id": "weapon", "label": "WEAPON", "icon": 5, "summary": "Proof the current shell with Fang or Blaster."},
	{"id": "back", "label": "BACK", "icon": 6, "summary": "Return to the command rail."},
]

const SYSTEM_ROWS := [
	{"id": "master", "label": "MASTER VOL", "icon": 7, "summary": "Overall ship mix."},
	{"id": "window_mode", "label": "WINDOW", "icon": 2, "summary": "How the board sits on screen."},
	{"id": "prompt_style", "label": "PROMPTS", "icon": 1, "summary": "Input icon treatment."},
	{"id": "ui_scale", "label": "UI SCALE", "icon": 4, "summary": "Cockpit frame and HUD sizing."},
	{"id": "back", "label": "BACK", "icon": 6, "summary": "Return to the command rail."},
]

const CUSTOMIZE_SKINS := [
	{"profile_id": SkinPalette.SKIN_HIVE_RUNNER, "preview_id": SkinPalette.SKIN_HIVE_RUNNER, "title": "HIVE RUNNER", "summary": "Amber salvage shell. Fast, dirty, and standard issue."},
	{"profile_id": SkinPalette.SKIN_BLUE_SQUADRON, "preview_id": SkinPalette.SKIN_LEGION, "title": "LEGION", "summary": "White escort shell. Cleaner lines and colder trim."},
	{"profile_id": SkinPalette.SKIN_NIGHT_QUEEN, "preview_id": SkinPalette.SKIN_NIGHT_QUEEN, "title": "NIGHT QUEEN", "summary": "Black premium shell. Released by full clear."},
]

const ORBIT_TRAFFIC := [
	{"radius": Vector2(0.33, 0.13), "speed": 0.12, "phase": 0.06, "scale": 1.0, "color": Color(1.0, 1.0, 1.0, 0.95)},
	{"radius": Vector2(0.28, 0.10), "speed": -0.09, "phase": 0.34, "scale": 0.92, "color": Color(0.72, 0.96, 1.0, 0.85)},
	{"radius": Vector2(0.24, 0.08), "speed": 0.16, "phase": 0.58, "scale": 0.82, "color": Color(1.0, 0.82, 0.52, 0.8)},
]

const SWARM_TRAILS := [
	{"tier": 0, "anchor": Vector2(0.68, 0.55), "swing": Vector2(0.03, 0.02), "speed": 0.46, "phase": 0.08, "scale": 0.65, "alpha": 0.22},
	{"tier": 1, "anchor": Vector2(0.74, 0.47), "swing": Vector2(0.04, 0.03), "speed": 0.54, "phase": 0.22, "scale": 0.82, "alpha": 0.32},
	{"tier": 1, "anchor": Vector2(0.80, 0.62), "swing": Vector2(0.05, 0.04), "speed": 0.44, "phase": 0.38, "scale": 0.76, "alpha": 0.28},
	{"tier": 2, "anchor": Vector2(0.73, 0.34), "swing": Vector2(0.07, 0.05), "speed": 0.62, "phase": 0.54, "scale": 1.08, "alpha": 0.42},
	{"tier": 2, "anchor": Vector2(0.88, 0.52), "swing": Vector2(0.04, 0.05), "speed": 0.58, "phase": 0.71, "scale": 0.94, "alpha": 0.4},
	{"tier": 3, "anchor": Vector2(0.66, 0.27), "swing": Vector2(0.09, 0.06), "speed": 0.7, "phase": 0.12, "scale": 1.25, "alpha": 0.55},
	{"tier": 3, "anchor": Vector2(0.92, 0.41), "swing": Vector2(0.06, 0.08), "speed": 0.79, "phase": 0.48, "scale": 1.1, "alpha": 0.48},
]

const GLASS_SPECKS := [
	Vector2(0.12, 0.11),
	Vector2(0.18, 0.29),
	Vector2(0.24, 0.18),
	Vector2(0.36, 0.08),
	Vector2(0.44, 0.21),
	Vector2(0.58, 0.12),
	Vector2(0.63, 0.32),
	Vector2(0.74, 0.17),
	Vector2(0.83, 0.09),
	Vector2(0.9, 0.28),
]

@onready var _profile_store: Node = get_node_or_null("/root/ProfileStore")
@onready var _game_flow: Node = get_node_or_null("/root/GameFlow")

var _menu_art := MenuArtRef.new()
var _ui_theme: Theme
var _menu_mode := MENU_MODE_ATTRACT
var _view := VIEW_HOME
var _main_index := 0
var _dossier_index := 0
var _systems_index := 0
var _anim_time := 0.0
var _preview_weapon_mode := "blade"
var _infestation_tier := 0

var _logo_texture: Texture2D
var _planet_base_texture: Texture2D
var _infestation_textures: Array[Texture2D] = []
var _swarm_sheet_texture: Texture2D
var _queen_sheet_texture: Texture2D
var _cockpit_overlay_texture: Texture2D
var _atlas_texture: Texture2D
var _cursor_texture: Texture2D

var _cockpit_overlay_rect: TextureRect
var _ui_root: Control
var _top_status_right_panel: PanelContainer
var _status_left_title: Label
var _status_left_meta: Label
var _status_right_title: Label
var _status_right_meta: Label
var _logo_rect: TextureRect
var _rail_panel: PanelContainer
var _console_panel: PanelContainer
var _console_body: HBoxContainer
var _rail_title: Label
var _main_list: VBoxContainer
var _dossier_list: VBoxContainer
var _systems_list: VBoxContainer
var _help_label: Label
var _monitor_title: Label
var _monitor_eyebrow: Label
var _monitor_chip: Label
var _monitor_body: Label
var _monitor_meta: Label
var _monitor_aux: Label
var _preview_panel: PanelContainer
var _skin_preview: SkinPreview
var _traffic_icon_rect: TextureRect
var _signal_icon_rect: TextureRect
var _traffic_icon_atlas: AtlasTexture
var _signal_icon_atlas: AtlasTexture

var _main_rows: Array[PanelContainer] = []
var _main_cursors: Array[TextureRect] = []
var _main_labels: Array[Label] = []
var _main_tags: Array[Label] = []
var _main_icons: Array[TextureRect] = []

var _dossier_rows: Array[PanelContainer] = []
var _dossier_cursors: Array[TextureRect] = []
var _dossier_labels: Array[Label] = []
var _dossier_values: Array[Label] = []
var _dossier_icons: Array[TextureRect] = []

var _system_rows: Array[PanelContainer] = []
var _system_cursors: Array[TextureRect] = []
var _system_labels: Array[Label] = []
var _system_values: Array[Label] = []
var _system_icons: Array[TextureRect] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	focus_mode = Control.FOCUS_NONE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	DisplayServer.window_set_title("Killer Queen")
	_ui_theme = PixelUI.create_theme()
	theme = _ui_theme
	_load_art()
	if _cursor_texture != null:
		Input.set_custom_mouse_cursor(_cursor_texture, Input.CURSOR_ARROW, Vector2(2.0, 2.0))
	_build_ui()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_apply_ui_scale_setting(_get_setting_float("ui_scale", 1.0))
	_on_viewport_size_changed()
	_refresh_terminal()
	set_process(true)


func _exit_tree() -> void:
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)


func _process(delta: float) -> void:
	_anim_time += delta
	_update_selection_fx()
	_update_animated_icons()
	queue_redraw()


func _draw() -> void:
	var viewport_rect := Rect2(Vector2.ZERO, size)
	_draw_spacebackdrop(viewport_rect)
	_draw_glass_specks(viewport_rect)
	draw_rect(Rect2(0.0, viewport_rect.size.y * 0.7, viewport_rect.size.x, viewport_rect.size.y * 0.3), Color(0.0, 0.0, 0.0, 0.2))


func _unhandled_input(event: InputEvent) -> void:
	if _pressed(event, ["ui_up", "move_up"]):
		_shift_selection(-1)
		get_viewport().set_input_as_handled()
		return
	if _pressed(event, ["ui_down", "move_down"]):
		_shift_selection(1)
		get_viewport().set_input_as_handled()
		return
	if _pressed(event, ["ui_accept", "jump", "shoot"]):
		_activate_current()
		get_viewport().set_input_as_handled()
		return
	if _view == VIEW_DOSSIER and _pressed(event, ["ui_left", "move_left"]):
		_change_current_dossier(-1)
		get_viewport().set_input_as_handled()
		return
	if _view == VIEW_DOSSIER and _pressed(event, ["ui_right", "move_right"]):
		_change_current_dossier(1)
		get_viewport().set_input_as_handled()
		return
	if _view == VIEW_SYSTEMS and _pressed(event, ["ui_left", "move_left"]):
		_change_current_system(-1)
		get_viewport().set_input_as_handled()
		return
	if _view == VIEW_SYSTEMS and _pressed(event, ["ui_right", "move_right"]):
		_change_current_system(1)
		get_viewport().set_input_as_handled()
		return
	if _pressed(event, ["ui_cancel", "jetpack"]):
		if _view == VIEW_DOSSIER or _view == VIEW_SYSTEMS:
			_open_home()
			get_viewport().set_input_as_handled()


func _load_art() -> void:
	_logo_texture = _menu_art.load_console_logo()
	_planet_base_texture = _menu_art.load_planet_base()
	_infestation_textures = _menu_art.load_infestation_overlays()
	_swarm_sheet_texture = _menu_art.load_swarm_sheet()
	_queen_sheet_texture = _menu_art.load_queen_sheet()
	_cockpit_overlay_texture = _menu_art.load_cockpit_overlay()
	_atlas_texture = _menu_art.load_console_atlas()
	_cursor_texture = _menu_art.load_cursor()


func _build_ui() -> void:
	_cockpit_overlay_rect = TextureRect.new()
	_cockpit_overlay_rect.anchor_right = 1.0
	_cockpit_overlay_rect.anchor_bottom = 1.0
	_cockpit_overlay_rect.texture = _cockpit_overlay_texture
	_cockpit_overlay_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_cockpit_overlay_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cockpit_overlay_rect.stretch_mode = TextureRect.STRETCH_SCALE
	_cockpit_overlay_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cockpit_overlay_rect)

	_ui_root = Control.new()
	_ui_root.anchor_right = 1.0
	_ui_root.anchor_bottom = 1.0
	_ui_root.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_ui_root)

	var overlay_margin := MarginContainer.new()
	overlay_margin.anchor_right = 1.0
	overlay_margin.anchor_bottom = 1.0
	overlay_margin.add_theme_constant_override("margin_left", 18)
	overlay_margin.add_theme_constant_override("margin_top", 14)
	overlay_margin.add_theme_constant_override("margin_right", 18)
	overlay_margin.add_theme_constant_override("margin_bottom", 18)
	_ui_root.add_child(overlay_margin)

	var overlay_stack := VBoxContainer.new()
	overlay_stack.anchor_right = 1.0
	overlay_stack.anchor_bottom = 1.0
	overlay_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	overlay_stack.add_theme_constant_override("separation", 10)
	overlay_margin.add_child(overlay_stack)

	var status_row := HBoxContainer.new()
	status_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_row.add_theme_constant_override("separation", 12)
	overlay_stack.add_child(status_row)

	var status_left_panel := PanelContainer.new()
	status_left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	PixelUI.style_panel(status_left_panel, "glass")
	status_row.add_child(status_left_panel)

	var status_left_margin := MarginContainer.new()
	status_left_margin.add_theme_constant_override("margin_left", 10)
	status_left_margin.add_theme_constant_override("margin_top", 8)
	status_left_margin.add_theme_constant_override("margin_right", 10)
	status_left_margin.add_theme_constant_override("margin_bottom", 8)
	status_left_panel.add_child(status_left_margin)

	var status_left_stack := VBoxContainer.new()
	status_left_stack.add_theme_constant_override("separation", 2)
	status_left_margin.add_child(status_left_stack)

	_status_left_title = Label.new()
	PixelUI.style_label(_status_left_title, "eyebrow")
	status_left_stack.add_child(_status_left_title)

	_status_left_meta = Label.new()
	_status_left_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	PixelUI.style_label(_status_left_meta, "small")
	status_left_stack.add_child(_status_left_meta)

	_top_status_right_panel = PanelContainer.new()
	_top_status_right_panel.custom_minimum_size = Vector2(246.0, 0.0)
	PixelUI.style_panel(_top_status_right_panel, "glass")
	status_row.add_child(_top_status_right_panel)

	var status_right_margin := MarginContainer.new()
	status_right_margin.add_theme_constant_override("margin_left", 10)
	status_right_margin.add_theme_constant_override("margin_top", 8)
	status_right_margin.add_theme_constant_override("margin_right", 10)
	status_right_margin.add_theme_constant_override("margin_bottom", 8)
	_top_status_right_panel.add_child(status_right_margin)

	var status_right_row := HBoxContainer.new()
	status_right_row.add_theme_constant_override("separation", 8)
	status_right_margin.add_child(status_right_row)

	_traffic_icon_rect = TextureRect.new()
	_traffic_icon_rect.custom_minimum_size = Vector2(16.0, 16.0)
	_traffic_icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_traffic_icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_traffic_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	status_right_row.add_child(_traffic_icon_rect)

	var status_right_stack := VBoxContainer.new()
	status_right_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_right_stack.add_theme_constant_override("separation", 2)
	status_right_row.add_child(status_right_stack)

	_status_right_title = Label.new()
	PixelUI.style_label(_status_right_title, "eyebrow")
	status_right_stack.add_child(_status_right_title)

	_status_right_meta = Label.new()
	_status_right_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	PixelUI.style_label(_status_right_meta, "small")
	status_right_stack.add_child(_status_right_meta)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	overlay_stack.add_child(spacer)

	_console_panel = PanelContainer.new()
	_console_panel.anchor_left = 0.0
	_console_panel.anchor_right = 1.0
	_console_panel.size_flags_vertical = Control.SIZE_SHRINK_END
	_console_panel.custom_minimum_size = Vector2(0.0, 278.0)
	_console_panel.clip_contents = true
	PixelUI.style_panel(_console_panel, "console")
	overlay_stack.add_child(_console_panel)

	var console_margin := MarginContainer.new()
	console_margin.add_theme_constant_override("margin_left", 12)
	console_margin.add_theme_constant_override("margin_top", 12)
	console_margin.add_theme_constant_override("margin_right", 12)
	console_margin.add_theme_constant_override("margin_bottom", 12)
	_console_panel.add_child(console_margin)

	var console_stack := VBoxContainer.new()
	console_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	console_stack.add_theme_constant_override("separation", 10)
	console_margin.add_child(console_stack)

	var header_row := HBoxContainer.new()
	header_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_theme_constant_override("separation", 12)
	console_stack.add_child(header_row)

	_logo_rect = TextureRect.new()
	_logo_rect.texture = _logo_texture
	_logo_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_logo_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_logo_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_logo_rect.custom_minimum_size = Vector2(208.0, 56.0)
	header_row.add_child(_logo_rect)

	var header_spacer := Control.new()
	header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(header_spacer)

	var signal_panel := PanelContainer.new()
	PixelUI.style_panel(signal_panel, "terminal")
	header_row.add_child(signal_panel)

	var signal_margin := MarginContainer.new()
	signal_margin.add_theme_constant_override("margin_left", 10)
	signal_margin.add_theme_constant_override("margin_top", 8)
	signal_margin.add_theme_constant_override("margin_right", 10)
	signal_margin.add_theme_constant_override("margin_bottom", 8)
	signal_panel.add_child(signal_margin)

	var signal_row := HBoxContainer.new()
	signal_row.add_theme_constant_override("separation", 8)
	signal_margin.add_child(signal_row)

	_signal_icon_rect = TextureRect.new()
	_signal_icon_rect.custom_minimum_size = Vector2(16.0, 16.0)
	_signal_icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_signal_icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_signal_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	signal_row.add_child(_signal_icon_rect)

	_monitor_chip = Label.new()
	PixelUI.style_label(_monitor_chip, "accent")
	signal_row.add_child(_monitor_chip)

	_console_body = HBoxContainer.new()
	_console_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_console_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_console_body.add_theme_constant_override("separation", 12)
	console_stack.add_child(_console_body)

	_rail_panel = PanelContainer.new()
	_rail_panel.custom_minimum_size = Vector2(248.0, 0.0)
	PixelUI.style_panel(_rail_panel, "rail")
	_console_body.add_child(_rail_panel)

	var rail_margin := MarginContainer.new()
	rail_margin.add_theme_constant_override("margin_left", 10)
	rail_margin.add_theme_constant_override("margin_top", 10)
	rail_margin.add_theme_constant_override("margin_right", 10)
	rail_margin.add_theme_constant_override("margin_bottom", 10)
	_rail_panel.add_child(rail_margin)

	var rail_stack := VBoxContainer.new()
	rail_stack.add_theme_constant_override("separation", 8)
	rail_margin.add_child(rail_stack)

	_rail_title = Label.new()
	PixelUI.style_label(_rail_title, "eyebrow")
	rail_stack.add_child(_rail_title)

	_main_list = VBoxContainer.new()
	_main_list.add_theme_constant_override("separation", 8)
	rail_stack.add_child(_main_list)
	_build_main_rows()

	_dossier_list = VBoxContainer.new()
	_dossier_list.visible = false
	_dossier_list.add_theme_constant_override("separation", 8)
	rail_stack.add_child(_dossier_list)
	_build_dossier_rows()

	_systems_list = VBoxContainer.new()
	_systems_list.visible = false
	_systems_list.add_theme_constant_override("separation", 8)
	rail_stack.add_child(_systems_list)
	_build_system_rows()

	var monitor_panel := PanelContainer.new()
	monitor_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	monitor_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	monitor_panel.clip_contents = true
	PixelUI.style_panel(monitor_panel, "display")
	_console_body.add_child(monitor_panel)

	var monitor_margin := MarginContainer.new()
	monitor_margin.add_theme_constant_override("margin_left", 14)
	monitor_margin.add_theme_constant_override("margin_top", 12)
	monitor_margin.add_theme_constant_override("margin_right", 14)
	monitor_margin.add_theme_constant_override("margin_bottom", 12)
	monitor_panel.add_child(monitor_margin)

	var monitor_stack := VBoxContainer.new()
	monitor_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	monitor_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	monitor_stack.add_theme_constant_override("separation", 8)
	monitor_margin.add_child(monitor_stack)

	_monitor_eyebrow = Label.new()
	PixelUI.style_label(_monitor_eyebrow, "eyebrow")
	monitor_stack.add_child(_monitor_eyebrow)

	_monitor_title = Label.new()
	PixelUI.style_label(_monitor_title, "display")
	_monitor_title.add_theme_font_size_override("font_size", 24)
	monitor_stack.add_child(_monitor_title)

	var monitor_body_row := HBoxContainer.new()
	monitor_body_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	monitor_body_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	monitor_body_row.add_theme_constant_override("separation", 12)
	monitor_stack.add_child(monitor_body_row)

	_preview_panel = PanelContainer.new()
	_preview_panel.visible = false
	_preview_panel.custom_minimum_size = Vector2(224.0, 0.0)
	PixelUI.style_panel(_preview_panel, "inset")
	monitor_body_row.add_child(_preview_panel)

	var preview_margin := MarginContainer.new()
	preview_margin.add_theme_constant_override("margin_left", 8)
	preview_margin.add_theme_constant_override("margin_top", 8)
	preview_margin.add_theme_constant_override("margin_right", 8)
	preview_margin.add_theme_constant_override("margin_bottom", 8)
	_preview_panel.add_child(preview_margin)

	_skin_preview = SkinPreviewRef.new()
	_skin_preview.custom_minimum_size = Vector2(180.0, 172.0)
	preview_margin.add_child(_skin_preview)

	var monitor_text_stack := VBoxContainer.new()
	monitor_text_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	monitor_text_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	monitor_text_stack.add_theme_constant_override("separation", 8)
	monitor_body_row.add_child(monitor_text_stack)

	_monitor_body = Label.new()
	_monitor_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	PixelUI.style_label(_monitor_body, "title")
	_monitor_body.add_theme_font_size_override("font_size", 15)
	monitor_text_stack.add_child(_monitor_body)

	_monitor_meta = Label.new()
	_monitor_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	PixelUI.style_label(_monitor_meta, "small")
	monitor_text_stack.add_child(_monitor_meta)

	_monitor_aux = Label.new()
	_monitor_aux.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	PixelUI.style_label(_monitor_aux, "accent")
	monitor_text_stack.add_child(_monitor_aux)

	var help_panel := PanelContainer.new()
	PixelUI.style_panel(help_panel, "glass")
	console_stack.add_child(help_panel)

	var help_margin := MarginContainer.new()
	help_margin.add_theme_constant_override("margin_left", 10)
	help_margin.add_theme_constant_override("margin_top", 6)
	help_margin.add_theme_constant_override("margin_right", 10)
	help_margin.add_theme_constant_override("margin_bottom", 6)
	help_panel.add_child(help_margin)

	_help_label = Label.new()
	PixelUI.style_label(_help_label, "small")
	_help_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help_margin.add_child(_help_label)

	_traffic_icon_atlas = _make_atlas_texture(0, 1)
	_signal_icon_atlas = _make_atlas_texture(4, 1)
	_traffic_icon_rect.texture = _traffic_icon_atlas
	_signal_icon_rect.texture = _signal_icon_atlas


func _build_main_rows() -> void:
	for index in range(MAIN_ENTRIES.size()):
		var entry: Dictionary = MAIN_ENTRIES[index]
		var row := PanelContainer.new()
		row.custom_minimum_size = Vector2(0.0, 50.0 if String(entry["id"]) != "start" else 58.0)
		row.mouse_filter = Control.MOUSE_FILTER_STOP
		row.mouse_entered.connect(_on_main_hover.bind(index))
		row.gui_input.connect(_on_main_input.bind(index))
		_main_list.add_child(row)
		_main_rows.append(row)

		var padding := MarginContainer.new()
		padding.add_theme_constant_override("margin_left", 10)
		padding.add_theme_constant_override("margin_top", 6)
		padding.add_theme_constant_override("margin_right", 10)
		padding.add_theme_constant_override("margin_bottom", 6)
		row.add_child(padding)

		var row_box := HBoxContainer.new()
		row_box.add_theme_constant_override("separation", 8)
		padding.add_child(row_box)

		var cursor := _make_cursor_rect()
		row_box.add_child(cursor)
		_main_cursors.append(cursor)

		var icon_rect := _make_icon_rect(int(entry["icon"]))
		row_box.add_child(icon_rect)
		_main_icons.append(icon_rect)

		var label := Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text = String(entry["title"])
		PixelUI.style_label(label, "title")
		label.add_theme_font_size_override("font_size", 18 if String(entry["id"]) == "start" else 16)
		row_box.add_child(label)
		_main_labels.append(label)

		var tag := Label.new()
		tag.text = String(entry["tag"])
		PixelUI.style_label(tag, "accent")
		row_box.add_child(tag)
		_main_tags.append(tag)


func _build_dossier_rows() -> void:
	for index in range(DOSSIER_ROWS.size()):
		var row_def: Dictionary = DOSSIER_ROWS[index]
		var row := PanelContainer.new()
		row.custom_minimum_size = Vector2(0.0, 46.0)
		row.mouse_filter = Control.MOUSE_FILTER_STOP
		row.mouse_entered.connect(_on_dossier_hover.bind(index))
		row.gui_input.connect(_on_dossier_input.bind(index))
		_dossier_list.add_child(row)
		_dossier_rows.append(row)

		var padding := MarginContainer.new()
		padding.add_theme_constant_override("margin_left", 10)
		padding.add_theme_constant_override("margin_top", 5)
		padding.add_theme_constant_override("margin_right", 10)
		padding.add_theme_constant_override("margin_bottom", 5)
		row.add_child(padding)

		var row_box := HBoxContainer.new()
		row_box.add_theme_constant_override("separation", 8)
		padding.add_child(row_box)

		var cursor := _make_cursor_rect()
		row_box.add_child(cursor)
		_dossier_cursors.append(cursor)

		var icon_rect := _make_icon_rect(int(row_def["icon"]))
		row_box.add_child(icon_rect)
		_dossier_icons.append(icon_rect)

		var label := Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text = String(row_def["label"])
		PixelUI.style_label(label, "title")
		row_box.add_child(label)
		_dossier_labels.append(label)

		var value_label := Label.new()
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		PixelUI.style_label(value_label, "accent")
		row_box.add_child(value_label)
		_dossier_values.append(value_label)


func _build_system_rows() -> void:
	for index in range(SYSTEM_ROWS.size()):
		var row_def: Dictionary = SYSTEM_ROWS[index]
		var row := PanelContainer.new()
		row.custom_minimum_size = Vector2(0.0, 46.0)
		row.mouse_filter = Control.MOUSE_FILTER_STOP
		row.mouse_entered.connect(_on_system_hover.bind(index))
		row.gui_input.connect(_on_system_input.bind(index))
		_systems_list.add_child(row)
		_system_rows.append(row)

		var padding := MarginContainer.new()
		padding.add_theme_constant_override("margin_left", 10)
		padding.add_theme_constant_override("margin_top", 5)
		padding.add_theme_constant_override("margin_right", 10)
		padding.add_theme_constant_override("margin_bottom", 5)
		row.add_child(padding)

		var row_box := HBoxContainer.new()
		row_box.add_theme_constant_override("separation", 8)
		padding.add_child(row_box)

		var cursor := _make_cursor_rect()
		row_box.add_child(cursor)
		_system_cursors.append(cursor)

		var icon_rect := _make_icon_rect(int(row_def["icon"]))
		row_box.add_child(icon_rect)
		_system_icons.append(icon_rect)

		var label := Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text = String(row_def["label"])
		PixelUI.style_label(label, "title")
		row_box.add_child(label)
		_system_labels.append(label)

		var value_label := Label.new()
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		PixelUI.style_label(value_label, "accent")
		row_box.add_child(value_label)
		_system_values.append(value_label)


func _make_cursor_rect() -> TextureRect:
	var cursor := TextureRect.new()
	cursor.texture = _cursor_texture
	cursor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	cursor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cursor.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	cursor.custom_minimum_size = Vector2(18.0, 14.0)
	cursor.visible = false
	return cursor


func _make_icon_rect(frame_column: int, row: int = 0) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = _make_atlas_texture(frame_column, row)
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	icon.custom_minimum_size = Vector2(16.0, 16.0)
	return icon


func _make_atlas_texture(frame_column: int, row: int = 0) -> AtlasTexture:
	if _atlas_texture == null:
		return null
	var atlas := AtlasTexture.new()
	atlas.atlas = _atlas_texture
	atlas.region = _atlas_region(frame_column, row)
	return atlas


func _atlas_region(frame_column: int, row: int = 0) -> Rect2:
	return Rect2(
		Vector2(float(frame_column * ICON_FRAME_SIZE.x), float(row * ICON_FRAME_SIZE.y)),
		Vector2(float(ICON_FRAME_SIZE.x), float(ICON_FRAME_SIZE.y))
	)


func _refresh_terminal() -> void:
	_infestation_tier = _compute_infestation_tier()
	_main_list.visible = _view == VIEW_HOME
	_dossier_list.visible = _view == VIEW_DOSSIER
	_systems_list.visible = _view == VIEW_SYSTEMS
	_preview_panel.visible = _view == VIEW_DOSSIER
	_rail_title.text = "COMMAND RAIL" if _view == VIEW_HOME else ("DOSSIER" if _view == VIEW_DOSSIER else "SYSTEMS")
	_refresh_status_panels()
	_refresh_main_rows()
	_refresh_dossier_rows()
	_refresh_system_rows()
	_refresh_monitor()
	_refresh_help()
	_refresh_skin_preview()
	queue_redraw()


func _refresh_status_panels() -> void:
	var queue := _estimate_dock_queue()
	var claim_rate := _estimate_claim_rate()
	var state_name: String = String(INFESTATION_NAMES[_infestation_tier])
	var left_title := "APPROACH VECTOR // KHEPRI-9"
	if _menu_mode == MENU_MODE_TERMINAL:
		left_title = "LICENSE TERMINAL // KHEPRI-9"
	_status_left_title.text = left_title
	_status_left_meta.text = "BROOD STATE // %s\nWINDOW // %s" % [state_name, "LIVE FEED" if _menu_mode == MENU_MODE_TERMINAL else "SCOUT GLASS"]
	_status_right_title.text = "BOARD // %d DOCKED" % queue
	_status_right_meta.text = "CLAIM RATE // %dc\nBROKER CUT // %d%%" % [claim_rate, 14 + _infestation_tier * 2]
	_monitor_chip.text = "BROOD INDEX // %s" % state_name


func _refresh_main_rows() -> void:
	for index in range(_main_rows.size()):
		var selected := _view == VIEW_HOME and index == _main_index
		var row := _main_rows[index]
		var label := _main_labels[index]
		var tag := _main_tags[index]
		if selected and index == 0:
			PixelUI.style_panel(row, "hero")
		elif selected:
			PixelUI.style_panel(row, "item_selected")
		else:
			PixelUI.style_panel(row, "item")
		label.add_theme_color_override("font_color", PixelUI.COLOR_AMBER if selected else PixelUI.COLOR_BONE)
		tag.add_theme_color_override("font_color", PixelUI.COLOR_AMBER if selected else PixelUI.COLOR_TEAL)
		_main_cursors[index].visible = selected
		if _main_icons[index] != null:
			_main_icons[index].modulate = Color(1.0, 1.0, 1.0, 1.0 if selected else 0.86)


func _refresh_dossier_rows() -> void:
	for index in range(_dossier_rows.size()):
		var row_def: Dictionary = DOSSIER_ROWS[index]
		var selected := _view == VIEW_DOSSIER and index == _dossier_index
		var row := _dossier_rows[index]
		var label := _dossier_labels[index]
		var value_label := _dossier_values[index]
		PixelUI.style_panel(row, "item_selected" if selected else "item")
		label.add_theme_color_override("font_color", PixelUI.COLOR_AMBER if selected else PixelUI.COLOR_BONE)
		_dossier_cursors[index].visible = selected
		if String(row_def["id"]) == "back":
			value_label.text = ""
		else:
			value_label.text = _get_dossier_value_text(String(row_def["id"]))


func _refresh_system_rows() -> void:
	for index in range(_system_rows.size()):
		var row_def: Dictionary = SYSTEM_ROWS[index]
		var selected := _view == VIEW_SYSTEMS and index == _systems_index
		var row := _system_rows[index]
		var label := _system_labels[index]
		var value_label := _system_values[index]
		PixelUI.style_panel(row, "item_selected" if selected else "item")
		label.add_theme_color_override("font_color", PixelUI.COLOR_AMBER if selected else PixelUI.COLOR_BONE)
		_system_cursors[index].visible = selected
		if String(row_def["id"]) == "back":
			value_label.text = ""
		else:
			value_label.text = _get_option_value_text(String(row_def["id"]))


func _refresh_monitor() -> void:
	match _view:
		VIEW_HOME:
			_refresh_home_monitor()
		VIEW_DOSSIER:
			_refresh_dossier_monitor()
		_:
			_refresh_system_monitor()


func _refresh_home_monitor() -> void:
	var entry: Dictionary = MAIN_ENTRIES[_main_index]
	var entry_id := String(entry["id"])
	_monitor_eyebrow.text = "WINDOW FEED"
	match entry_id:
		"start":
			_monitor_title.text = "OPEN EXTERMINATION LICENSE"
			_monitor_body.text = "Khepri-9 is still taking cold drop claims. Every hunter in orbit wants the same cut."
			_monitor_meta.text = "DOCK QUEUE // %d\nBROOD SHELF // %dm\nRIVAL FRAMES // %d" % [
				_estimate_dock_queue(),
				_get_record("best_altitude_m"),
				_get_record("rival_clears"),
			]
			_monitor_aux.text = "FIELD NOTE // The planet is not getting cleaner. It is getting louder."
		"dossier":
			_monitor_title.text = "HUNTER FILE"
			_monitor_body.text = "Proof the shell, stage the weapon, and keep the license looking expensive."
			_monitor_meta.text = "ACTIVE SHELL // %s\nACTIVE WEAPON // %s\nBUGS CUT // %d" % [
				_get_dossier_value_text("skin"),
				_get_dossier_value_text("weapon"),
				_get_record("bugs_liquidated"),
			]
			_monitor_aux.text = "DOCKET // %s" % ("Night Queen released." if _has_full_clear() else "Night Queen sealed behind full clear.")
		"systems":
			_monitor_title.text = "SHIP CALIBRATION"
			_monitor_body.text = "No dead utility here. Just the board fit, the mix, and the prompt set."
			_monitor_meta.text = "MASTER // %s\nWINDOW // %s\nPROMPTS // %s" % [
				_get_option_value_text("master"),
				_get_option_value_text("window_mode"),
				_get_option_value_text("prompt_style"),
			]
			_monitor_aux.text = "UI SCALE // %s" % _get_option_value_text("ui_scale")
		_:
			_monitor_title.text = "DISCONNECT FEED"
			_monitor_body.text = "The queue keeps climbing without you. The board will not wait."
			_monitor_meta.text = "CURRENT CLAIM RATE // %dc\nRELAY STATE // HOT" % [_estimate_claim_rate()]
			_monitor_aux.text = "QUIT // Close the terminal and leave orbit."


func _refresh_dossier_monitor() -> void:
	var skins := _get_available_skins()
	var skin_entry: Dictionary = skins[_get_current_skin_index(skins)] if not skins.is_empty() else {}
	var row_def: Dictionary = DOSSIER_ROWS[_dossier_index]
	_monitor_eyebrow.text = "HUNTER FILE"
	_monitor_title.text = "%s // %s" % [String(row_def["label"]), _get_dossier_value_text(String(row_def["id"]))]
	_monitor_body.text = String(row_def["summary"])
	_monitor_meta.text = "SHELL // %s\nWEAPON // %s\nBEST SHELF // %dm" % [
		String(skin_entry.get("title", "HIVE RUNNER")),
		_preview_weapon_mode.to_upper(),
		_get_record("best_altitude_m"),
	]
	_monitor_aux.text = "BUGS CUT // %d\nRIVALS DOWN // %d\nSTATUS // %s" % [
		_get_record("bugs_liquidated"),
		_get_record("rival_clears"),
		"Night Queen released." if _has_full_clear() else "Night Queen sealed.",
	]
	if String(row_def["id"]) == "back":
		_monitor_title.text = "RETURN TO COMMAND RAIL"
		_monitor_body.text = String(row_def["summary"])


func _refresh_system_monitor() -> void:
	var row_def: Dictionary = SYSTEM_ROWS[_systems_index]
	var row_id := String(row_def["id"])
	_monitor_eyebrow.text = "SHIP CALIBRATION"
	_monitor_title.text = String(row_def["label"])
	_monitor_body.text = String(row_def["summary"])
	if row_id == "back":
		_monitor_meta.text = "Return to TAKE CONTRACT, DOSSIER, SYSTEMS, or QUIT."
		_monitor_aux.text = "CONFIRM // back out of calibration."
	else:
		_monitor_meta.text = "CURRENT // %s" % _get_option_value_text(row_id)
		_monitor_aux.text = "LEFT / RIGHT changes value. CONFIRM also steps forward."


func _refresh_help() -> void:
	if _view == VIEW_HOME:
		_help_label.text = "UP / DOWN SELECT    CONFIRM TAKE / OPEN    BACK UNUSED ON HOME"
	else:
		_help_label.text = "UP / DOWN SELECT    LEFT / RIGHT CHANGE    CONFIRM STEP    BACK RETURN"


func _refresh_skin_preview() -> void:
	if _skin_preview == null:
		return
	var skins := _get_available_skins()
	if skins.is_empty():
		return
	var skin_entry: Dictionary = skins[_get_current_skin_index(skins)]
	_skin_preview.set_skin_id(String(skin_entry["preview_id"]))
	_skin_preview.set_weapon_mode(_preview_weapon_mode)


func _shift_selection(delta: int) -> void:
	match _view:
		VIEW_HOME:
			_main_index = wrapi(_main_index + delta, 0, MAIN_ENTRIES.size())
		VIEW_DOSSIER:
			_dossier_index = wrapi(_dossier_index + delta, 0, DOSSIER_ROWS.size())
		_:
			_systems_index = wrapi(_systems_index + delta, 0, SYSTEM_ROWS.size())
	_refresh_terminal()


func _activate_current() -> void:
	match _view:
		VIEW_HOME:
			var entry_id := String(MAIN_ENTRIES[_main_index]["id"])
			match entry_id:
				"start":
					_launch_contract()
				"dossier":
					_open_dossier()
				"systems":
					_open_systems()
				"quit":
					get_tree().quit()
		VIEW_DOSSIER:
			var dossier_id := String(DOSSIER_ROWS[_dossier_index]["id"])
			if dossier_id == "back":
				_open_home()
			else:
				_change_current_dossier(1)
		_:
			var row_id := String(SYSTEM_ROWS[_systems_index]["id"])
			if row_id == "back":
				_open_home()
			else:
				_change_current_system(1)


func _change_current_dossier(delta: int) -> void:
	var row_def: Dictionary = DOSSIER_ROWS[_dossier_index]
	var row_id := String(row_def["id"])
	match row_id:
		"skin":
			var skins := _get_available_skins()
			if skins.is_empty():
				return
			var current_index := _get_current_skin_index(skins)
			var new_index := wrapi(current_index + delta, 0, skins.size())
			_set_skin_profile_id(String(skins[new_index]["profile_id"]))
		"weapon":
			_preview_weapon_mode = "gun" if _preview_weapon_mode == "blade" else "blade"
		_:
			return
	_refresh_terminal()


func _change_current_system(delta: int) -> void:
	var row_def: Dictionary = SYSTEM_ROWS[_systems_index]
	var row_id := String(row_def["id"])
	if row_id == "back":
		return
	var options := _get_system_options(row_id)
	if options.is_empty():
		return
	var current: Variant = _get_setting_value(row_id)
	var current_index := options.find(current)
	if current_index == -1:
		current_index = 0
	var new_index := wrapi(current_index + delta, 0, options.size())
	_set_setting_value(row_id, options[new_index])
	_refresh_terminal()


func _get_system_options(row_id: String) -> Array:
	match row_id:
		"master":
			return [0.0, 0.25, 0.5, 0.75, 1.0]
		"window_mode":
			return ["windowed", "fullscreen", "borderless"]
		"prompt_style":
			return ["pixel", "1-bit", "default"]
		"ui_scale":
			return [0.75, 1.0, 1.25]
		_:
			return []


func _open_dossier() -> void:
	_view = VIEW_DOSSIER
	_refresh_terminal()


func _open_systems() -> void:
	_view = VIEW_SYSTEMS
	_refresh_terminal()


func _open_home() -> void:
	_view = VIEW_HOME
	_refresh_terminal()


func _launch_contract() -> void:
	if _game_flow != null and _game_flow.has_method("launch_contract"):
		_game_flow.call("launch_contract")
		return
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _compute_infestation_tier() -> int:
	if _has_full_clear():
		return 3
	var runs := _get_record("runs_started")
	var bugs := _get_record("bugs_liquidated")
	var rivals := _get_record("rival_clears")
	if bugs >= 700 or rivals >= 4 or runs >= 8:
		return 3
	if bugs >= 260 or rivals >= 2 or runs >= 4:
		return 2
	if bugs >= 40 or rivals >= 1 or runs >= 1:
		return 1
	return 0


func _estimate_dock_queue() -> int:
	return int(18 + _get_record("runs_started") * 7 + _get_record("bugs_liquidated") / 22 + _infestation_tier * 14)


func _estimate_claim_rate() -> int:
	return int(1100 + _get_record("bugs_liquidated") * 4 + _get_record("rival_clears") * 350 + _infestation_tier * 180)


func _get_record(key: String) -> int:
	if _profile_store != null and _profile_store.has_method("get_record"):
		return int(_profile_store.call("get_record", key))
	return 0


func _has_full_clear() -> bool:
	return _profile_store != null and _profile_store.has_method("has_full_clear") and bool(_profile_store.call("has_full_clear"))


func _get_setting_value(setting_id: String) -> Variant:
	if _profile_store != null and _profile_store.has_method("get_setting"):
		return _profile_store.call("get_setting", setting_id)
	match setting_id:
		"master":
			return 1.0
		"window_mode":
			return "windowed"
		"prompt_style":
			return "pixel"
		"ui_scale":
			return 1.0
		_:
			return null


func _set_setting_value(setting_id: String, value: Variant) -> void:
	if _profile_store != null and _profile_store.has_method("set_setting"):
		_profile_store.call("set_setting", setting_id, value)
	if setting_id == "ui_scale":
		_apply_ui_scale_setting(float(value))
	if _profile_store != null and _profile_store.has_method("save_profile"):
		_profile_store.call("save_profile")


func _get_setting_float(setting_id: String, fallback: float) -> float:
	var value: Variant = _get_setting_value(setting_id)
	if value == null:
		return fallback
	return float(value)


func _get_dossier_value_text(row_id: String) -> String:
	match row_id:
		"skin":
			var skins := _get_available_skins()
			if skins.is_empty():
				return "NONE"
			return String(skins[_get_current_skin_index(skins)]["title"])
		"weapon":
			return _preview_weapon_mode.to_upper()
		_:
			return ""


func _get_option_value_text(setting_id: String) -> String:
	var value: Variant = _get_setting_value(setting_id)
	match setting_id:
		"master":
			return "%d%%" % int(round(float(value) * 100.0))
		"window_mode":
			match String(value):
				"fullscreen":
					return "FULL"
				"borderless":
					return "BORDERLESS"
				_:
					return "WINDOW"
		"prompt_style":
			match String(value):
				"1-bit":
					return "1-BIT"
				"default":
					return "DEFAULT"
				_:
					return "PIXEL"
		"ui_scale":
			return "%d%%" % int(round(float(value) * 100.0))
		_:
			return ""


func _get_selected_skin_profile_id() -> String:
	if _profile_store != null and _profile_store.has_method("get_selected_skin"):
		var selected := String(_profile_store.call("get_selected_skin"))
		if selected == SkinPalette.SKIN_LEGION:
			return SkinPalette.SKIN_BLUE_SQUADRON
		return selected
	return SkinPalette.SKIN_HIVE_RUNNER


func _set_skin_profile_id(profile_id: String) -> void:
	if _profile_store != null and _profile_store.has_method("set_selected_skin"):
		_profile_store.call("set_selected_skin", profile_id)
	if _profile_store != null and _profile_store.has_method("save_profile"):
		_profile_store.call("save_profile")


func _get_available_skins() -> Array:
	var skins: Array = []
	for skin_entry in CUSTOMIZE_SKINS:
		var profile_id := String(skin_entry["profile_id"])
		var unlocked := true
		if _profile_store != null and _profile_store.has_method("is_skin_unlocked"):
			unlocked = bool(_profile_store.call("is_skin_unlocked", profile_id))
		if unlocked:
			skins.append(skin_entry)
	return skins


func _get_current_skin_index(skins: Array) -> int:
	var current_profile_id := _get_selected_skin_profile_id()
	for index in range(skins.size()):
		if String(skins[index]["profile_id"]) == current_profile_id:
			return index
	return 0


func _apply_ui_scale_setting(scale_value: float) -> void:
	if _ui_root == null:
		return
	var viewport := get_viewport_rect().size
	var max_scale := 1.25
	if viewport.x <= 900.0 or viewport.y <= 520.0:
		max_scale = 1.0
	var effective_scale := minf(clampf(scale_value, 0.75, 1.25), max_scale)
	PixelUI.apply_ui_scale(_ui_root, effective_scale)


func _on_viewport_size_changed() -> void:
	if _console_panel == null:
		return
	var viewport := get_viewport_rect().size
	var compact := viewport.x < 900.0 or viewport.y < 520.0
	var medium := viewport.x < 1080.0
	_console_panel.custom_minimum_size = Vector2(0.0, 244.0 if compact else 278.0)
	_rail_panel.custom_minimum_size = Vector2(214.0 if compact else (228.0 if medium else 248.0), 0.0)
	_preview_panel.custom_minimum_size = Vector2(172.0 if compact else 224.0, 0.0)
	_skin_preview.custom_minimum_size = Vector2(154.0 if compact else 180.0, 148.0 if compact else 172.0)
	_logo_rect.custom_minimum_size = Vector2(170.0 if compact else 208.0, 48.0 if compact else 56.0)
	_top_status_right_panel.visible = not compact
	_monitor_aux.visible = not compact or _view != VIEW_HOME
	_console_body.add_theme_constant_override("separation", 8 if compact else 12)
	_apply_ui_scale_setting(_get_setting_float("ui_scale", 1.0))


func _update_selection_fx() -> void:
	var pulse := 0.82 + sin(_anim_time * 6.0) * 0.18
	for cursor in _main_cursors:
		if cursor.visible:
			cursor.modulate = Color(1.0, pulse, 0.54 + pulse * 0.22, 1.0)
	for cursor in _dossier_cursors:
		if cursor.visible:
			cursor.modulate = Color(1.0, pulse, 0.54 + pulse * 0.22, 1.0)
	for cursor in _system_cursors:
		if cursor.visible:
			cursor.modulate = Color(1.0, pulse, 0.54 + pulse * 0.22, 1.0)


func _update_animated_icons() -> void:
	if _traffic_icon_atlas == null or _signal_icon_atlas == null:
		return
	var frame := int(floor(_anim_time * 8.0)) % 4
	_traffic_icon_atlas.region = _atlas_region(frame, 1)
	_signal_icon_atlas.region = _atlas_region(4 + frame, 1)


func _pressed(event: InputEvent, actions: Array[String]) -> bool:
	for action in actions:
		if event.is_action_pressed(action):
			return true
	return false


func _on_main_hover(index: int) -> void:
	if _view != VIEW_HOME:
		return
	_main_index = index
	_refresh_terminal()


func _on_main_input(event: InputEvent, index: int) -> void:
	if not (event is InputEventMouseButton):
		return
	var mouse_event := event as InputEventMouseButton
	if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	_main_index = index
	_refresh_terminal()
	_activate_current()


func _on_dossier_hover(index: int) -> void:
	if _view != VIEW_DOSSIER:
		return
	_dossier_index = index
	_refresh_terminal()


func _on_dossier_input(event: InputEvent, index: int) -> void:
	if not (event is InputEventMouseButton):
		return
	var mouse_event := event as InputEventMouseButton
	if not mouse_event.pressed:
		return
	_dossier_index = index
	_refresh_terminal()
	if mouse_event.button_index == MOUSE_BUTTON_LEFT:
		_activate_current()
	elif mouse_event.button_index == MOUSE_BUTTON_RIGHT:
		_open_home()


func _on_system_hover(index: int) -> void:
	if _view != VIEW_SYSTEMS:
		return
	_systems_index = index
	_refresh_terminal()


func _on_system_input(event: InputEvent, index: int) -> void:
	if not (event is InputEventMouseButton):
		return
	var mouse_event := event as InputEventMouseButton
	if not mouse_event.pressed:
		return
	_systems_index = index
	_refresh_terminal()
	if mouse_event.button_index == MOUSE_BUTTON_LEFT:
		_activate_current()
	elif mouse_event.button_index == MOUSE_BUTTON_RIGHT:
		_open_home()


func _draw_spacebackdrop(viewport_rect: Rect2) -> void:
	draw_rect(viewport_rect, PixelUI.COLOR_INK)
	var art_height := viewport_rect.size.y * 0.72
	var art_rect := Rect2(0.0, 0.0, viewport_rect.size.x, art_height)
	if _planet_base_texture != null:
		var drift := Vector2(
			sin(_anim_time * 0.11) * viewport_rect.size.x * 0.012,
			cos(_anim_time * 0.07) * viewport_rect.size.y * 0.008
		)
		var base_rect := Rect2(
			Vector2(-viewport_rect.size.x * 0.02, -art_height * 0.04) + drift,
			Vector2(viewport_rect.size.x * 1.08, art_height * 1.12)
		)
		draw_texture_rect(_planet_base_texture, base_rect, false)
	for tier in range(mini(_infestation_tier, _infestation_textures.size() - 1) + 1):
		var overlay := _infestation_textures[tier]
		if overlay == null:
			continue
		var alpha := 0.46 + float(tier) * 0.14
		draw_texture_rect(overlay, Rect2(Vector2.ZERO, Vector2(viewport_rect.size.x, art_height)), false, Color(1.0, 1.0, 1.0, alpha))
	_draw_orbit_traffic(art_rect)
	_draw_swarm_layers(art_rect)
	_draw_planet_eruptions(art_rect)
	_draw_queen_tease(art_rect)
	for scan_y in range(0, int(art_rect.size.y), 4):
		draw_rect(Rect2(0.0, float(scan_y), art_rect.size.x, 1.0), Color(0.0, 0.0, 0.0, 0.1))


func _draw_orbit_traffic(art_rect: Rect2) -> void:
	var center := art_rect.position + art_rect.size * Vector2(0.74, 0.39)
	var frame := int(floor(_anim_time * 8.0)) % 4
	for track in ORBIT_TRAFFIC:
		var radius_factor: Vector2 = track["radius"]
		var tint: Color = track["color"]
		var angle := _anim_time * float(track["speed"]) * TAU + float(track["phase"]) * TAU
		var radius := Vector2(art_rect.size.x * radius_factor.x, art_rect.size.y * radius_factor.y)
		var point: Vector2 = center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y)
		var scale := float(track["scale"]) * maxf(0.78, art_rect.size.y / 520.0)
		var dest_size := Vector2(16.0, 16.0) * scale
		var dest_rect := Rect2(point - dest_size * 0.5, dest_size)
		if _atlas_texture != null:
			draw_texture_rect_region(_atlas_texture, dest_rect, _atlas_region(frame, 1), tint)
		else:
			draw_rect(dest_rect, tint)


func _draw_swarm_layers(art_rect: Rect2) -> void:
	for trail in SWARM_TRAILS:
		if _infestation_tier < int(trail["tier"]):
			continue
		var anchor_factor: Vector2 = trail["anchor"]
		var swing_factor: Vector2 = trail["swing"]
		var phase := _anim_time * float(trail["speed"]) * TAU + float(trail["phase"]) * TAU
		var anchor := art_rect.position + art_rect.size * anchor_factor
		var swing := Vector2(art_rect.size.x * swing_factor.x, art_rect.size.y * swing_factor.y)
		var position := anchor + Vector2(sin(phase) * swing.x, cos(phase * 1.27) * swing.y)
		var frame := int(floor(_anim_time * 10.0 + float(trail["phase"]) * 9.0)) % 4
		var scale := float(trail["scale"]) * maxf(0.64, art_rect.size.y / 420.0)
		var dest_size := Vector2(float(SWARM_FRAME_SIZE.x), float(SWARM_FRAME_SIZE.y)) * scale
		var modulate := Color(1.0, 1.0, 1.0, float(trail["alpha"]) + float(_infestation_tier) * 0.04)
		if _swarm_sheet_texture != null:
			draw_texture_rect_region(_swarm_sheet_texture, Rect2(position - dest_size * 0.5, dest_size), _swarm_region(frame), modulate)
			var tail_position := position + Vector2(-dest_size.x * 0.3, dest_size.y * 0.2)
			draw_texture_rect_region(
				_swarm_sheet_texture,
				Rect2(tail_position - dest_size * 0.36, dest_size * 0.72),
				_swarm_region((frame + 1) % 4),
				Color(1.0, 1.0, 1.0, modulate.a * 0.52)
			)


func _draw_planet_eruptions(art_rect: Rect2) -> void:
	if _infestation_tier < 2:
		return
	var points: Array[Vector2] = [
		Vector2(0.71, 0.47),
		Vector2(0.79, 0.42),
		Vector2(0.84, 0.53),
	]
	for index in range(points.size()):
		var point: Vector2 = art_rect.position + art_rect.size * Vector2(points[index])
		var pulse := 0.5 + 0.5 * sin(_anim_time * 2.0 + float(index) * 1.7)
		draw_circle(point, 4.0 + pulse * 3.0, Color(1.0, 0.45, 0.35, 0.18 + pulse * 0.16))
		draw_circle(point, 1.5 + pulse, Color(1.0, 0.76, 0.5, 0.78))


func _draw_queen_tease(art_rect: Rect2) -> void:
	if _queen_sheet_texture == null:
		return
	var base_visibility := clampf((sin(_anim_time * 0.23) - 0.58) * 2.4, 0.0, 1.0)
	if _infestation_tier == 0:
		base_visibility *= 0.24
	var visibility := clampf(base_visibility + float(_infestation_tier) * 0.08, 0.0, 0.72)
	if visibility <= 0.01:
		return
	var frame := int(floor(_anim_time * 4.5)) % 4
	var size_scale := maxf(0.8, art_rect.size.y / 320.0)
	var dest_size := Vector2(float(QUEEN_FRAME_SIZE.x), float(QUEEN_FRAME_SIZE.y)) * size_scale * 1.36
	var base_position := art_rect.position + art_rect.size * Vector2(0.63, 0.02)
	var jitter := Vector2(sin(_anim_time * 5.8) * 2.0, cos(_anim_time * 4.4) * 1.4) * visibility
	var dest_rect := Rect2(base_position + jitter, dest_size)
	draw_texture_rect_region(
		_queen_sheet_texture,
		dest_rect,
		_queen_region(frame),
		Color(1.0, 1.0, 1.0, visibility)
	)
	var occlusion := Rect2(
		dest_rect.position.x + dest_rect.size.x * 0.18,
		dest_rect.position.y + dest_rect.size.y * 0.22,
		dest_rect.size.x * 0.92,
		dest_rect.size.y * 0.34
	)
	draw_rect(occlusion, Color(PixelUI.COLOR_INK.r, PixelUI.COLOR_INK.g, PixelUI.COLOR_INK.b, 0.36 + visibility * 0.16))
	for index in range(5):
		var line_y := dest_rect.position.y + 8.0 + float(index) * 9.0 + sin(_anim_time * 3.0 + float(index)) * 2.0
		draw_rect(
			Rect2(dest_rect.position.x + 8.0, line_y, dest_rect.size.x * (0.68 + 0.08 * index), 1.0),
			Color(PixelUI.COLOR_TEAL.r, PixelUI.COLOR_TEAL.g, PixelUI.COLOR_TEAL.b, 0.06 + visibility * 0.08)
		)


func _draw_glass_specks(viewport_rect: Rect2) -> void:
	for index in range(GLASS_SPECKS.size()):
		var point: Vector2 = viewport_rect.position + viewport_rect.size * Vector2(GLASS_SPECKS[index])
		var drift := Vector2(sin(_anim_time * 0.5 + float(index)) * 2.0, cos(_anim_time * 0.4 + float(index) * 1.3) * 1.0)
		draw_circle(point + drift, 1.0 + float(index % 2), Color(1.0, 1.0, 1.0, 0.08))


func _swarm_region(frame: int) -> Rect2:
	return Rect2(
		Vector2(float(frame * SWARM_FRAME_SIZE.x), 0.0),
		Vector2(float(SWARM_FRAME_SIZE.x), float(SWARM_FRAME_SIZE.y))
	)


func _queen_region(frame: int) -> Rect2:
	return Rect2(
		Vector2(float(frame * QUEEN_FRAME_SIZE.x), 0.0),
		Vector2(float(QUEEN_FRAME_SIZE.x), float(QUEEN_FRAME_SIZE.y))
	)
