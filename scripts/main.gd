extends Node2D

const ExportArt = preload("res://scripts/export_art.gd")
const PLAYER_SCENE := preload("res://scenes/player.tscn")
const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const SLASH_SCENE := preload("res://scenes/slash_hitbox.tscn")
const SLASH_FX_SCENE := preload("res://scenes/slash_fx.tscn")
const ENEMY_SCENE := preload("res://scenes/enemy.tscn")
const MINE_SCENE := preload("res://scenes/mine.tscn")
const SHELLBACK_SCENE := preload("res://scenes/shellback_crawler.tscn")
const BROOD_POD_SCENE := preload("res://scenes/brood_pod.tscn")
const INFESTATION_ANCHOR_SCENE := preload("res://scenes/infestation_anchor.tscn")
const PLATFORM_SCENE := preload("res://scenes/platform_piece.tscn")
const GOAL_SCENE := preload("res://scenes/goal.tscn")
const CAVE_ARENA_SCENE := preload("res://scenes/cave_arena.tscn")
const RIVAL_BOSS_SCENE := preload("res://scenes/cave_rival_boss.tscn")
const WEAPON_SALVAGE_SCENE := preload("res://scenes/weapon_salvage.tscn")

const WORLD_SIZE := Vector2(1680.0, 3200.0)
const DEFAULT_SPAWN_POINT := Vector2(188.0, 2930.0)
const TOP_CLEAR_Y := 86.0
const PIXELS_PER_METER := 8.0
const KILL_FLOOR_OFFSET := 700.0
const KILL_FLOOR_RISE_SPEED := 220.0
const COMBO_TIMEOUT := 2.4
const THREAT_FUEL_REWARD := 14.0
const FLOW_REWARD_STEP := 3
const FLOW_REWARD_FUEL := 10.0
const WALL_KICK_FUEL_REWARD := 3.0
const BURST_CHAIN_FUEL_REWARD := 4.0
const BURST_SAVE_FUEL_REWARD := 6.0
const WALL_BURST_FUEL_REWARD := 8.0
const SHOT_UP_SPREAD := 0.18
const SHOT_DOWN_SPREAD := 0.12
const INTRO_LANDING_DURATION := 0.95
const STARTER_SELECT_RANGE := 92.0
const TITLE_CAMERA_ZOOM := Vector2(0.94, 0.94)
const DROP_CAMERA_ZOOM := Vector2(1.1, 1.1)
const STARTER_CAMERA_ZOOM := Vector2(1.0, 1.0)
const CLAIM_CAMERA_ZOOM := Vector2(0.95, 0.95)
const INTRO_CAMERA_LERP := 8.0
const FRONT_LAYOUT_NARROW_WIDTH := 1024.0
const FRONT_LAYOUT_STACK_WIDTH := 820.0
const FRONT_LAYOUT_SHORT_HEIGHT := 680.0
const HUD_COMPACT_WIDTH := 1100.0
const HUD_STACK_WIDTH := 860.0
const HUD_PROMPT_ICON_DEFAULT := Vector2(28.0, 28.0)
const HUD_PROMPT_ICON_COMPACT := Vector2(24.0, 24.0)
const STATE_TITLE := "title"
const STATE_LANDING := "landing"
const STATE_STARTER_CHOICE := "starter_choice"
const STATE_TRANSFER := "transfer"
const STATE_PLAYING := "playing"
const STATE_FAILED := "failed"
const STATE_CLEARED := "cleared"
const STARTER_BLADE := "blade"
const STARTER_GUN := "gun"
const BACKDROP_ESCAPE_BLEND := 0
const BACKDROP_HIVE_SHAFT := 1
const BACKDROP_SUNSET_RUIN := 2
const BACKDROP_MOUNTAIN_PASS := 3
const FRONT_MAIN := "main"
const FRONT_CUSTOMIZE := "customize"
const FRONT_SETTINGS := "settings"
const PHASE_SHAFT := "shaft"
const PHASE_CAVE := "cave"
const PHASE_BOSS := "boss"
const PHASE_REWARD := "reward"
const PHASE_MOUNTAIN := "mountain"
const REGION_STATE_LOCKED := "locked"
const REGION_STATE_ACTIVE := "active"
const REGION_STATE_CLEANSED := "cleansed"
const REGION_HIVE := "hive_shaft"
const REGION_SKYLINE := "sunset_ruin_skyline"
const REGION_FOUNDRY := "overgrown_foundry"
const REGION_TRANSIT := "flooded_transit"
const REGION_ARMORY := "royal_armory"
const REGION_CORE := "queens_core"
const TRANSFER_DURATION := 1.2
const TRANSFER_KIND_CAVE := "cave"
const TRANSFER_KIND_MOUNTAIN := "mountain"
const MOUNTAIN_TOP_CLEAR_X := 1542.0
const CAVE_TRANSFER_GOAL_POSITION := Vector2(844.0, 168.0)
const SKYLINE_ENTRY_POSITION := Vector2(1002.0, 500.0)
const SKYLINE_BOSS_GOAL_POSITION := Vector2(1576.0, 188.0)
const SKYLINE_BOSS_SPAWN_POSITION := Vector2(1466.0, 218.0)
const SKYLINE_ARENA_BOUNDS := Rect2(1186.0, 138.0, 404.0, 124.0)
const SKYLINE_FLOOR_Y := 218.0
const RUN_CAMERA_BLEND := 6.5
const DEFAULT_TOWER_CAMERA_PROFILE := {"label": "endurance", "zoom": 1.36, "camera_y": -72.0}
const TOWER_CAMERA_ZONES := [
	{"label": "transfer", "rect": Rect2(0.0, 0.0, 1680.0, 470.0), "zoom": 1.42, "camera_y": -38.0},
	{"label": "gauntlet", "rect": Rect2(0.0, 520.0, 1680.0, 620.0), "zoom": 1.48, "camera_y": -54.0},
	{"label": "cross_route", "rect": Rect2(0.0, 1140.0, 1680.0, 620.0), "zoom": 1.42, "camera_y": -60.0},
	{"label": "pressure", "rect": Rect2(470.0, 1760.0, 960.0, 820.0), "zoom": 1.48, "camera_y": -54.0},
	{"label": "launch", "rect": Rect2(0.0, 2500.0, 980.0, 700.0), "zoom": 1.36, "camera_y": -74.0},
]
const CAVE_CAMERA_PROFILE := {"label": "cave", "zoom": 1.42, "camera_y": -38.0}
const BOSS_CAMERA_PROFILE := {"label": "boss", "zoom": 1.58, "camera_y": -26.0}
const REWARD_CAMERA_PROFILE := {"label": "reward", "zoom": 1.46, "camera_y": -34.0}
const MOUNTAIN_CAMERA_PROFILE := {"label": "mountain", "zoom": 1.34, "camera_y": -70.0}

const MENU_ENTRIES := [
	{"id": "start", "title": "TAKE CONTRACT", "subtitle": "Open the extermination order and start the first purge.", "tag": "DROP", "icon": "[T]"},
	{"id": "customize", "title": "DOSSIER", "subtitle": "Stage shell colors, weapon flare, and hunter identity.", "tag": "FILE", "icon": "[D]"},
	{"id": "settings", "title": "SYSTEMS", "subtitle": "Audio, glass, prompts, and bindings.", "tag": "CAL", "icon": "[S]"},
	{"id": "quit", "title": "QUIT", "subtitle": "Cut the board and return to desktop.", "tag": "CUT", "icon": "[X]"},
]

const SKIN_ORDER := [
	SkinPalette.SKIN_HIVE_RUNNER,
	SkinPalette.SKIN_LEGION,
	SkinPalette.SKIN_NIGHT_QUEEN,
]

const SKIN_META := {
	SkinPalette.SKIN_HIVE_RUNNER: {
		"title": "HIVE RUNNER",
		"subtitle": "Dock-standard amber/teal worker shell.",
	},
	SkinPalette.SKIN_LEGION: {
		"title": "LEGION",
		"subtitle": "White-blue trooper shell. Red blaster lasers.",
	},
	SkinPalette.SKIN_NIGHT_QUEEN: {
		"title": "NIGHT QUEEN",
		"subtitle": "Black endgame shell. Beat the full game.",
	},
}

const SETTING_ROWS := [
	{"type": "setting", "id": "master", "label": "MASTER", "options": [0.0, 0.25, 0.5, 0.75, 1.0]},
	{"type": "setting", "id": "music", "label": "MUSIC", "options": [0.0, 0.25, 0.5, 0.75, 1.0]},
	{"type": "setting", "id": "sfx", "label": "SFX", "options": [0.0, 0.25, 0.5, 0.75, 1.0]},
	{"type": "setting", "id": "window_mode", "label": "WINDOW MODE", "options": ["windowed", "fullscreen", "borderless"]},
	{"type": "setting", "id": "pixel_scale", "label": "PIXEL SCALE", "options": [1, 2, 3, 4]},
	{"type": "setting", "id": "ui_scale", "label": "UI SCALE", "options": [0.75, 1.0, 1.25, 1.5]},
	{"type": "setting", "id": "prompt_style", "label": "PROMPTS", "options": ["pixel", "1-bit", "default"]},
	{"type": "input", "action": "move_left", "label": "MOVE LEFT"},
	{"type": "input", "action": "move_right", "label": "MOVE RIGHT"},
	{"type": "input", "action": "jump", "label": "JUMP"},
	{"type": "input", "action": "jetpack", "label": "SHIFT"},
	{"type": "input", "action": "shoot", "label": "ATTACK"},
	{"type": "input", "action": "swap_weapon", "label": "SWAP"},
	{"type": "input", "action": "restart", "label": "RERUN"},
]

const PLATFORM_DATA := [
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(-160.0, 3020.0), "size": Vector2(1320.0, 180.0)},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(32.0, 2868.0), "size": Vector2(344.0, 24.0)},
	{"kind": "spring", "archetype": "spring", "pos": Vector2(412.0, 2802.0), "size": Vector2(164.0, 18.0), "spring_velocity": -790.0},
	{"kind": "fuel", "archetype": "fuel", "pos": Vector2(184.0, 2738.0), "size": Vector2(142.0, 18.0), "fuel_amount": 40.0},
	{"kind": "stable", "archetype": "kick_wall", "pos": Vector2(590.0, 2664.0), "size": Vector2(40.0, 212.0)},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(666.0, 2688.0), "size": Vector2(224.0, 20.0)},
	{"kind": "stable", "archetype": "recovery", "pos": Vector2(280.0, 2628.0), "size": Vector2(188.0, 20.0)},
	{"kind": "spring", "archetype": "spring", "pos": Vector2(922.0, 2618.0), "size": Vector2(156.0, 18.0), "spring_velocity": -764.0},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(1124.0, 2550.0), "size": Vector2(214.0, 20.0)},
	{"kind": "stable", "archetype": "recovery", "pos": Vector2(772.0, 2506.0), "size": Vector2(170.0, 18.0)},
	{"kind": "stable", "archetype": "kick_wall", "pos": Vector2(1036.0, 2364.0), "size": Vector2(36.0, 234.0)},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(1116.0, 2326.0), "size": Vector2(232.0, 20.0)},
	{"kind": "fuel", "archetype": "fuel", "pos": Vector2(846.0, 2280.0), "size": Vector2(152.0, 18.0), "fuel_amount": 36.0},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(602.0, 2248.0), "size": Vector2(240.0, 22.0)},
	{"kind": "stable", "archetype": "recovery", "pos": Vector2(352.0, 2172.0), "size": Vector2(194.0, 20.0)},
	{"kind": "spring", "archetype": "spring", "pos": Vector2(184.0, 2210.0), "size": Vector2(154.0, 18.0), "spring_velocity": -780.0},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(112.0, 2058.0), "size": Vector2(236.0, 20.0)},
	{"kind": "stable", "archetype": "relay", "pos": Vector2(438.0, 2012.0), "size": Vector2(128.0, 18.0)},
	{"kind": "stable", "archetype": "kick_wall", "pos": Vector2(608.0, 1894.0), "size": Vector2(36.0, 214.0)},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(680.0, 1908.0), "size": Vector2(242.0, 20.0)},
	{"kind": "fuel", "archetype": "fuel", "pos": Vector2(1018.0, 1848.0), "size": Vector2(154.0, 18.0), "fuel_amount": 34.0},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(1112.0, 1714.0), "size": Vector2(222.0, 22.0)},
	{"kind": "stable", "archetype": "recovery", "pos": Vector2(822.0, 1666.0), "size": Vector2(166.0, 18.0)},
	{"kind": "spring", "archetype": "spring", "pos": Vector2(560.0, 1710.0), "size": Vector2(150.0, 18.0), "spring_velocity": -770.0},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(340.0, 1588.0), "size": Vector2(244.0, 20.0)},
	{"kind": "stable", "archetype": "kick_wall", "pos": Vector2(304.0, 1402.0), "size": Vector2(36.0, 222.0)},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(112.0, 1418.0), "size": Vector2(180.0, 20.0)},
	{"kind": "fuel", "archetype": "fuel", "pos": Vector2(404.0, 1350.0), "size": Vector2(148.0, 18.0), "fuel_amount": 34.0},
	{"kind": "stable", "archetype": "relay", "pos": Vector2(628.0, 1300.0), "size": Vector2(132.0, 18.0)},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(830.0, 1228.0), "size": Vector2(240.0, 20.0)},
	{"kind": "spring", "archetype": "spring", "pos": Vector2(1118.0, 1158.0), "size": Vector2(148.0, 18.0), "spring_velocity": -758.0},
	{"kind": "stable", "archetype": "recovery", "pos": Vector2(656.0, 1102.0), "size": Vector2(180.0, 18.0)},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(350.0, 1032.0), "size": Vector2(220.0, 20.0)},
	{"kind": "stable", "archetype": "kick_wall", "pos": Vector2(910.0, 862.0), "size": Vector2(36.0, 230.0)},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(980.0, 920.0), "size": Vector2(212.0, 20.0)},
	{"kind": "fuel", "archetype": "fuel", "pos": Vector2(1204.0, 848.0), "size": Vector2(154.0, 18.0), "fuel_amount": 36.0},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(1306.0, 730.0), "size": Vector2(180.0, 22.0)},
	{"kind": "stable", "archetype": "recovery", "pos": Vector2(1040.0, 684.0), "size": Vector2(170.0, 18.0)},
	{"kind": "spring", "archetype": "spring", "pos": Vector2(788.0, 726.0), "size": Vector2(150.0, 18.0), "spring_velocity": -746.0},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(560.0, 612.0), "size": Vector2(212.0, 20.0)},
	{"kind": "stable", "archetype": "relay", "pos": Vector2(344.0, 560.0), "size": Vector2(128.0, 18.0)},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(148.0, 470.0), "size": Vector2(182.0, 20.0)},
	{"kind": "stable", "archetype": "kick_wall", "pos": Vector2(486.0, 346.0), "size": Vector2(36.0, 214.0)},
	{"kind": "stable", "archetype": "recovery", "pos": Vector2(528.0, 258.0), "size": Vector2(140.0, 18.0)},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(568.0, 408.0), "size": Vector2(220.0, 20.0)},
	{"kind": "fuel", "archetype": "fuel", "pos": Vector2(842.0, 332.0), "size": Vector2(148.0, 18.0), "fuel_amount": 34.0},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(1024.0, 282.0), "size": Vector2(212.0, 20.0)},
	{"kind": "stable", "archetype": "relay", "pos": Vector2(1280.0, 236.0), "size": Vector2(136.0, 18.0)},
	{"kind": "stable", "archetype": "gate", "pos": Vector2(728.0, 208.0), "size": Vector2(228.0, 28.0)},
]

const MOUNTAIN_PLATFORM_DATA := [
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(920.0, 522.0), "size": Vector2(230.0, 36.0)},
	{"kind": "stable", "archetype": "relay", "pos": Vector2(1106.0, 456.0), "size": Vector2(212.0, 24.0)},
	{"kind": "fuel", "archetype": "fuel", "pos": Vector2(1278.0, 406.0), "size": Vector2(174.0, 18.0), "fuel_amount": 40.0},
	{"kind": "spring", "archetype": "spring", "pos": Vector2(1450.0, 430.0), "size": Vector2(164.0, 18.0), "spring_velocity": -712.0},
	{"kind": "stable", "archetype": "recovery", "pos": Vector2(1018.0, 350.0), "size": Vector2(190.0, 24.0)},
	{"kind": "stable", "archetype": "relay", "pos": Vector2(1208.0, 296.0), "size": Vector2(182.0, 24.0)},
	{"kind": "fuel", "archetype": "fuel", "pos": Vector2(1402.0, 252.0), "size": Vector2(160.0, 18.0), "fuel_amount": 36.0},
	{"kind": "stable", "archetype": "gate", "pos": Vector2(1548.0, 246.0), "size": Vector2(120.0, 38.0)},
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(1320.0, 538.0), "size": Vector2(246.0, 28.0)},
]

const MITE_DATA := [
	{"kind": "mite", "pos": Vector2(802.0, 2626.0), "travel": 56.0, "speed": 102.0, "hover": 7.0},
	{"kind": "mite", "pos": Vector2(1206.0, 2466.0), "travel": 66.0, "speed": 104.0, "hover": 9.0},
	{"kind": "mite", "pos": Vector2(442.0, 2144.0), "travel": 62.0, "speed": 108.0, "hover": 8.0},
	{"kind": "mite", "pos": Vector2(1098.0, 1788.0), "travel": 64.0, "speed": 104.0, "hover": 8.0},
	{"kind": "mite", "pos": Vector2(428.0, 1540.0), "travel": 58.0, "speed": 108.0, "hover": 8.0},
	{"kind": "mite", "pos": Vector2(932.0, 1184.0), "travel": 68.0, "speed": 110.0, "hover": 8.0},
	{"kind": "mite", "pos": Vector2(1182.0, 760.0), "travel": 62.0, "speed": 116.0, "hover": 8.0},
]

const CRAWLER_DATA := [
	{"pos": Vector2(730.0, 2230.0), "patrol": 88.0, "speed": 66.0, "health": 3},
	{"pos": Vector2(402.0, 1568.0), "patrol": 86.0, "speed": 70.0, "health": 3},
	{"pos": Vector2(632.0, 388.0), "patrol": 74.0, "speed": 72.0, "health": 3},
]

const POD_DATA := [
	{
		"pos": Vector2(1190.0, 2296.0),
		"health": 4,
		"interval": 2.05,
		"brood_limit": 2,
		"spawn_offsets": [Vector2(-24.0, -10.0), Vector2(24.0, -10.0)],
	},
	{
		"pos": Vector2(1028.0, 956.0),
		"health": 4,
		"interval": 1.9,
		"brood_limit": 2,
		"spawn_offsets": [Vector2(-26.0, -8.0), Vector2(26.0, -8.0)],
	},
]

const MINE_POSITIONS := [
	Vector2(494.0, 2012.0),
	Vector2(1184.0, 1800.0),
	Vector2(690.0, 1296.0),
	Vector2(1090.0, 658.0),
]

const MOUNTAIN_MITE_DATA := [
	{"kind": "mite", "pos": Vector2(1162.0, 386.0), "travel": 62.0, "speed": 118.0, "hover": 8.0},
	{"kind": "mite", "pos": Vector2(1366.0, 328.0), "travel": 66.0, "speed": 122.0, "hover": 8.0},
]

const MOUNTAIN_CRAWLER_DATA := [
	{"pos": Vector2(1468.0, 406.0), "patrol": 70.0, "speed": 68.0, "health": 3},
]

const MOUNTAIN_POD_DATA := [
	{
		"pos": Vector2(1560.0, 176.0),
		"health": 4,
		"interval": 2.1,
		"brood_limit": 2,
		"spawn_offsets": [Vector2(-18.0, -10.0), Vector2(18.0, -10.0)],
	},
]

const MOUNTAIN_MINE_POSITIONS := [
	Vector2(1244.0, 374.0),
	Vector2(1488.0, 212.0),
]

const HIVE_ANCHOR_DATA := [
	{"anchor_id": "lower_brood", "anchor_name": "Lower Brood Organ", "pos": Vector2(786.0, 2284.0), "health": 6},
	{"anchor_id": "mid_artery", "anchor_name": "Mid Artery Nest", "pos": Vector2(428.0, 1486.0), "health": 7},
	{"anchor_id": "upper_crown", "anchor_name": "Upper Crown Organ", "pos": Vector2(1180.0, 778.0), "health": 8},
]

const SKYLINE_ANCHOR_DATA := [
	{"anchor_id": "west_spire", "anchor_name": "West Spire Core", "pos": Vector2(1298.0, 354.0), "health": 7},
	{"anchor_id": "east_bridge", "anchor_name": "Bridge Root Mass", "pos": Vector2(1488.0, 218.0), "health": 8},
]

const HIVE_BOSS_PROFILE := {
	"region_id": REGION_HIVE,
	"boss_name": "BROOD WARDEN",
	"weapon_mode": STARTER_BLADE,
	"health": 12,
	"guard_label": "BROOD ARMOR SEALED",
	"broken_label": "WARDEN CORE BROKEN",
	"burst_telegraph_label": "BROOD WARDEN: SPINE BURST",
	"fan_telegraph_label": "BROOD WARDEN: SUNLANCE SPRAY",
	"dash_telegraph_label": "BROOD WARDEN: CHITIN DASH",
	"cleave_telegraph_label": "BROOD WARDEN: SKY MAUL",
	"burst_vulnerable_label": "VENT CORE EXPOSED",
	"fan_vulnerable_label": "BROOD SACK EXPOSED",
	"dash_vulnerable_label": "JOINT PLATE CRACKED",
	"cleave_vulnerable_label": "DRIVE CORE OVERLOAD",
	"intro_message": "Brood Warden detected. Kill the chamber heart and cut the shaft loose.",
	"start_message": "Brood Warden live. Break the shell and finish the first purge.",
}

const SKYLINE_BOSS_PROFILE := {
	"region_id": REGION_SKYLINE,
	"boss_name": "SPIRE MATRIARCH",
	"weapon_mode": STARTER_GUN,
	"health": 14,
	"guard_label": "SOLAR CARAPACE SEALED",
	"broken_label": "MATRIARCH CORE BROKEN",
	"burst_telegraph_label": "SPIRE MATRIARCH: LANCE BURST",
	"fan_telegraph_label": "SPIRE MATRIARCH: SUNLANCE SWEEP",
	"dash_telegraph_label": "SPIRE MATRIARCH: TALON DRIVE",
	"cleave_telegraph_label": "SPIRE MATRIARCH: SKY DROP",
	"burst_vulnerable_label": "CHEST VEINS OPEN",
	"fan_vulnerable_label": "SOLAR SACK EXPOSED",
	"dash_vulnerable_label": "SPUR MOTOR STALLED",
	"cleave_vulnerable_label": "CROWN CORE EXPOSED",
	"intro_message": "Spire Matriarch detected. Kill the skyline apex and prove the planet can die above ground.",
	"start_message": "Spire Matriarch live. Cut the ruin loose and expose the remaining purge zones.",
}

const CAVE_PLATFORM_DATA := [
	{"kind": "stable", "archetype": "anchor", "pos": Vector2(760.0, 112.0), "size": Vector2(150.0, 22.0)},
	{"kind": "stable", "archetype": "recovery", "pos": Vector2(916.0, 146.0), "size": Vector2(132.0, 20.0)},
	{"kind": "stable", "pos": Vector2(1048.0, 272.0), "size": Vector2(522.0, 34.0), "draw_visual": false},
	{"kind": "stable", "pos": Vector2(956.0, 224.0), "size": Vector2(94.0, 16.0), "draw_visual": false},
	{"kind": "stable", "pos": Vector2(1098.0, 198.0), "size": Vector2(100.0, 18.0), "draw_visual": false},
	{"kind": "stable", "pos": Vector2(1148.0, 116.0), "size": Vector2(96.0, 16.0), "draw_visual": false},
	{"kind": "stable", "pos": Vector2(1236.0, 156.0), "size": Vector2(120.0, 18.0), "draw_visual": false},
	{"kind": "stable", "pos": Vector2(1336.0, 112.0), "size": Vector2(96.0, 16.0), "draw_visual": false},
	{"kind": "stable", "pos": Vector2(1376.0, 198.0), "size": Vector2(100.0, 18.0), "draw_visual": false},
	{"kind": "stable", "pos": Vector2(1422.0, 224.0), "size": Vector2(94.0, 16.0), "draw_visual": false},
]

const CAVE_LEFT_GATE_DATA := {
	"kind": "stable",
	"archetype": "gate",
	"pos": Vector2(1058.0, 92.0),
	"size": Vector2(30.0, 196.0),
	"draw_visual": false,
}

const CAVE_RIGHT_GATE_DATA := {
	"kind": "stable",
	"archetype": "gate",
	"pos": Vector2(1488.0, 92.0),
	"size": Vector2(30.0, 196.0),
	"draw_visual": false,
}

var _player
var _player_camera: Camera2D
var _state := "boot"
var _front_mode := FRONT_MAIN
var _menu_index := 0
var _skin_index := 0
var _settings_index := 0
var _settings_draft: Dictionary = {}
var _settings_snapshot: Dictionary = {}
var _input_bindings_draft: Dictionary = {}
var _input_bindings_snapshot: Dictionary = {}
var _remap_action := ""
var _preview_weapon_mode := STARTER_BLADE
var _run_time := 0.0
var _best_altitude := 0
var _highest_player_y := DEFAULT_SPAWN_POINT.y
var _kill_floor_y := DEFAULT_SPAWN_POINT.y + KILL_FLOOR_OFFSET
var _combo := 0
var _combo_timer := 0.0
var _flow_reward_tier := 0
var _threats_cleared := 0
var _total_threats := 0
var _kill_floor_line: Line2D
var _weapon_mode := STARTER_BLADE
var _starter_weapon := STARTER_BLADE
var _alternate_weapon_unlocked := false
var _route_phase := PHASE_SHAFT
var _active_region_id := REGION_HIVE
var _active_boss_region_id := ""
var _region_states: Dictionary = {}
var _region_anchor_totals: Dictionary = {}
var _region_anchor_cleared: Dictionary = {}
var _kill_floor_active := true
var _blade_icon_texture: Texture2D
var _gun_icon_texture: Texture2D
var _blade_showcase_texture: Texture2D
var _gun_showcase_texture: Texture2D
var _landing_timer := 0.0
var _current_choice_target := ""
var _transfer_timer := 0.0
var _transfer_kind := ""
var _transfer_start := Vector2.ZERO
var _transfer_end := Vector2.ZERO
var _transfer_line: Line2D
var _ui_theme: Theme
var _claim_sequence_active := false
var _cave_arena: Node2D
var _rival_boss: Area2D
var _cave_exit_goal: Area2D
var _tower_transfer_goal: Area2D
var _skyline_boss_goal: Area2D
var _weapon_salvage: Area2D
var _left_gate_platform: StaticBody2D
var _right_gate_platform: StaticBody2D
var _boss_panel: PanelContainer
var _boss_name_label: Label
var _boss_window_label: Label
var _boss_meter: PixelMeter
var _duel_dialogue_panel: PanelContainer
var _duel_speaker_label: Label
var _duel_line_label: Label
var _receipt_panel: PanelContainer
var _receipt_title_label: Label
var _receipt_body_label: Label
var _receipt_hint_label: Label
var _boss_intro_running := false
var _run_bug_kills := 0
var _run_rival_clears := 0
var _run_records_committed := false

@onready var backdrop: Node2D = $Backdrop
@onready var intro_stage: Node2D = $IntroStage
@onready var intro_camera: Camera2D = $IntroCamera2D
@onready var platforms: Node2D = $Platforms
@onready var pickups: Node2D = $Pickups
@onready var enemies: Node2D = $Enemies
@onready var projectiles: Node2D = $Projectiles
@onready var goal_anchor: Node2D = $GoalAnchor
@onready var hud: Control = $CanvasLayer/HUD
@onready var hud_margin: MarginContainer = $CanvasLayer/HUD/Margin
@onready var hud_layout: VBoxContainer = $CanvasLayer/HUD/Margin/Layout
@onready var top_panel: PanelContainer = $CanvasLayer/HUD/Margin/Layout/TopPanel
@onready var top_padding: MarginContainer = $CanvasLayer/HUD/Margin/Layout/TopPanel/TopPadding
@onready var stats_row: HFlowContainer = $CanvasLayer/HUD/Margin/Layout/TopPanel/TopPadding/TopStack/StatsRow
@onready var prompt_dock: PanelContainer = $CanvasLayer/HUD/Margin/Layout/PromptDock
@onready var prompt_padding: MarginContainer = $CanvasLayer/HUD/Margin/Layout/PromptDock/PromptPadding
@onready var prompt_row: HFlowContainer = $CanvasLayer/HUD/Margin/Layout/PromptDock/PromptPadding/PromptRow
@onready var front_door: Control = $CanvasLayer/FrontDoor
@onready var front_margin: MarginContainer = $CanvasLayer/FrontDoor/Margin
@onready var front_layout: VBoxContainer = $CanvasLayer/FrontDoor/Margin/Layout
@onready var console_row: GridContainer = %ConsoleRow
@onready var choice_spacer: Control = %ChoiceSpacer
@onready var starter_choice_wrap: HBoxContainer = %StarterChoiceWrap
@onready var left_gutter: Control = $CanvasLayer/FrontDoor/Margin/Layout/StarterChoiceWrap/LeftGutter
@onready var right_gutter: Control = $CanvasLayer/FrontDoor/Margin/Layout/StarterChoiceWrap/RightGutter
@onready var title_overlay: PanelContainer = %TitleOverlay
@onready var game_title_label: Label = $CanvasLayer/FrontDoor/Margin/Layout/ConsoleRow/TitleOverlay/Padding/Stack/GameTitle
@onready var readout_row: GridContainer = $CanvasLayer/FrontDoor/Margin/Layout/ConsoleRow/TitleOverlay/Padding/Stack/ReadoutRow
@onready var front_mode_label: Label = %FrontModeLabel
@onready var title_tagline_label: Label = %Tagline
@onready var title_status_label: Label = %TitleStatusLabel
@onready var title_loadout_label: Label = %TitleLoadoutLabel
@onready var menu_window: PanelContainer = %MenuWindow
@onready var menu_badge_label: Label = $CanvasLayer/FrontDoor/Margin/Layout/ConsoleRow/MenuWindow/Padding/Stack/MenuBadge
@onready var menu_legend_label: Label = $CanvasLayer/FrontDoor/Margin/Layout/ConsoleRow/MenuWindow/Padding/Stack/MenuLegend
@onready var menu_legend_b_label: Label = $CanvasLayer/FrontDoor/Margin/Layout/ConsoleRow/MenuWindow/Padding/Stack/MenuLegendB
@onready var menu_list: VBoxContainer = %MenuList
@onready var customize_window: PanelContainer = %CustomizeWindow
@onready var preview_frame: PanelContainer = $CanvasLayer/FrontDoor/Margin/Layout/ConsoleRow/CustomizeWindow/Padding/Stack/PreviewFrame
@onready var skin_list: VBoxContainer = %SkinList
@onready var skin_preview: SkinPreview = %SkinPreview
@onready var skin_status_label: Label = %SkinStatusLabel
@onready var skin_hint_label: Label = %SkinHintLabel
@onready var settings_window: PanelContainer = %SettingsWindow
@onready var settings_row: GridContainer = $CanvasLayer/FrontDoor/Margin/Layout/ConsoleRow/SettingsWindow/Padding/Row
@onready var settings_scroll: ScrollContainer = $CanvasLayer/FrontDoor/Margin/Layout/ConsoleRow/SettingsWindow/Padding/Row/ListColumn/SettingsScroll
@onready var settings_list: VBoxContainer = %SettingsList
@onready var settings_section_label: Label = %SettingsSectionLabel
@onready var settings_summary_label: Label = %SettingsSummaryLabel
@onready var settings_footer_label: Label = %SettingsFooterLabel
@onready var remap_prompt_label: Label = %RemapPromptLabel
@onready var start_prompt_label: Label = %StartPromptLabel
@onready var intro_caption_label: Label = %IntroCaptionLabel
@onready var starter_choice_panel: PanelContainer = %StarterChoice
@onready var racks_grid: GridContainer = $CanvasLayer/FrontDoor/Margin/Layout/StarterChoiceWrap/StarterChoice/ChoicePadding/ChoiceStack/Racks
@onready var starter_hint_label: Label = %StarterHintLabel
@onready var blade_card: PanelContainer = %BladeCard
@onready var gun_card: PanelContainer = %GunCard
@onready var blade_art: TextureRect = %BladeArt
@onready var gun_art: TextureRect = %GunArt
@onready var blade_status_label: Label = %BladeStatusLabel
@onready var gun_status_label: Label = %GunStatusLabel
@onready var footer_bar: PanelContainer = %FooterBar
@onready var footer_hint_label: Label = %FooterHint
@onready var timer_label: Label = %TimerLabel
@onready var message_label: Label = %MessageLabel
@onready var objective_label: Label = %ObjectiveLabel
@onready var fuel_bar: PixelMeter = %FuelBar
@onready var health_bar: PixelMeter = %HealthBar
@onready var weapon_icon: TextureRect = %WeaponIcon
@onready var weapon_label: Label = %WeaponLabel
@onready var stats_label: Label = %StatsLabel
@onready var swap_prompt: Control = $CanvasLayer/HUD/Margin/Layout/PromptDock/PromptPadding/PromptRow/SwapPrompt
@onready var landing_marker: Marker2D = $IntroStage/LandingMarker
@onready var player_drop_marker: Marker2D = $IntroStage/PlayerDropMarker
@onready var run_start_marker: Marker2D = $IntroStage/RunStartMarker
@onready var title_hero_marker: Marker2D = $IntroStage/TitleHeroMarker
@onready var blade_stand: Marker2D = $IntroStage/BladeStand
@onready var gun_stand: Marker2D = $IntroStage/GunStand
@onready var intro_camera_anchor: Marker2D = $IntroStage/IntroCameraAnchor
@onready var title_camera_anchor: Marker2D = $IntroStage/TitleCameraAnchor
@onready var profile_store: Node = get_node_or_null("/root/ProfileStore")
@onready var game_flow: Node = get_node_or_null("/root/GameFlow")


func _ready() -> void:
	DisplayServer.window_set_title("Killer Queen")
	_ensure_weapon_art()
	_ui_theme = PixelUI.create_theme()
	_apply_static_ui_theme()
	_ensure_boss_ui()
	_apply_profile_runtime_state()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_apply_responsive_layout()
	backdrop.call("configure", WORLD_SIZE.x, WORLD_SIZE.y, _kill_floor_y)
	_ensure_kill_floor_visual()
	_ensure_transfer_line()
	_spawn_player()
	_apply_selected_skin()
	_enter_title()
	var boot_mode := String(game_flow.call("consume_boot_mode", "contract")) if game_flow != null else "contract"
	if boot_mode == "contract":
		_start_landing_intro()


func _process(delta: float) -> void:
	if _is_restart_requested() and _state in [STATE_PLAYING, STATE_FAILED, STATE_CLEARED]:
		if _state == STATE_PLAYING:
			_commit_run_records(false)
		_reset_run()
		return

	match _state:
		STATE_TITLE:
			_update_intro_presentation(delta)
			_update_title_state()
		STATE_LANDING:
			_update_intro_presentation(delta)
			_update_landing_state(delta)
		STATE_STARTER_CHOICE:
			_update_intro_presentation(delta)
			_update_starter_choice_state()
		STATE_TRANSFER:
			_update_transfer_state(delta)
		STATE_PLAYING:
			_run_time += delta
			_update_play_state(delta)
		_:
			if _kill_floor_line != null and _kill_floor_line.visible:
				_update_kill_floor_visual()


func _is_restart_requested() -> bool:
	if not Input.is_action_just_pressed("restart"):
		return false
	if Input.is_action_just_pressed("jump"):
		return false
	if Input.is_action_just_pressed("shoot"):
		return false
	if Input.is_action_just_pressed("swap_weapon"):
		return false
	if Input.is_action_just_pressed("jetpack"):
		return false
	return true


func _unhandled_input(event: InputEvent) -> void:
	if _state != STATE_TITLE or _front_mode != FRONT_SETTINGS or _remap_action.is_empty():
		return

	if event is InputEventMouseMotion:
		return
	if event is InputEventJoypadMotion and absf(event.axis_value) < 0.4:
		return

	var pressed := false
	if event is InputEventKey:
		pressed = event.pressed and not event.echo
	elif event is InputEventMouseButton or event is InputEventJoypadButton:
		pressed = event.pressed
	elif event is InputEventJoypadMotion:
		pressed = true

	if not pressed:
		return

	_bind_action_event(_remap_action, event)
	_remap_action = ""
	remap_prompt_label.visible = false
	_rebuild_settings_list()
	get_viewport().set_input_as_handled()


func _spawn_player() -> void:
	if is_instance_valid(_player):
		return

	_player = PLAYER_SCENE.instantiate()
	add_child(_player)
	_player.connect("shot_fired", Callable(self, "_on_player_shot_fired"))
	_player.connect("slash_fired", Callable(self, "_on_player_slash_fired"))
	_player.connect("fuel_changed", Callable(self, "_on_player_fuel_changed"))
	_player.connect("health_changed", Callable(self, "_on_player_health_changed"))
	_player.connect("damaged", Callable(self, "_on_player_damaged"))
	_player.connect("movement_event", Callable(self, "_on_player_movement_event"))
	_player.connect("weapon_mode_changed", Callable(self, "_on_player_weapon_mode_changed"))
	_player.connect("died", Callable(self, "_on_player_died"))

	_player_camera = _player.get_node("Camera2D") as Camera2D
	_player_camera.limit_left = 0
	_player_camera.limit_top = 0
	_player_camera.limit_right = int(WORLD_SIZE.x)
	_player_camera.limit_bottom = int(WORLD_SIZE.y)
	_player_camera.enabled = false
	_player.visible = false

	_on_player_weapon_mode_changed(String(_player.call("get_weapon_mode")), false)


func _on_viewport_size_changed() -> void:
	_apply_responsive_layout()


func _get_frontdoor_usable_size() -> Vector2:
	return Vector2(get_window().size) if get_window() != null else get_viewport_rect().size


func _apply_responsive_layout() -> void:
	var usable_size := _get_frontdoor_usable_size()
	var front_narrow := usable_size.x < FRONT_LAYOUT_NARROW_WIDTH or usable_size.y < FRONT_LAYOUT_SHORT_HEIGHT
	var front_stack := usable_size.x < FRONT_LAYOUT_STACK_WIDTH
	var hud_compact := usable_size.x < HUD_COMPACT_WIDTH
	var hud_stack := usable_size.x < HUD_STACK_WIDTH

	front_margin.add_theme_constant_override("margin_left", 12 if front_narrow else 18)
	front_margin.add_theme_constant_override("margin_top", 0 if front_narrow else 16)
	front_margin.add_theme_constant_override("margin_right", 12 if front_narrow else 18)
	front_margin.add_theme_constant_override("margin_bottom", 0 if front_narrow else 16)
	front_layout.add_theme_constant_override("separation", 8 if front_narrow else 10 if front_stack else 16)
	console_row.columns = 1 if front_narrow else 2
	console_row.add_theme_constant_override("h_separation", 12 if front_narrow else 18)
	console_row.add_theme_constant_override("v_separation", 8 if front_narrow else 12 if front_stack else 14)
	console_row.move_child(title_overlay, 0)
	console_row.move_child(menu_window, 1)
	title_overlay.custom_minimum_size = Vector2(0.0 if front_narrow else 560.0, 0.0)
	menu_window.custom_minimum_size = Vector2(0.0 if front_narrow else 316.0, 0.0)
	readout_row.columns = 1 if front_stack else 2
	menu_list.add_theme_constant_override("separation", 4 if front_stack else 6)
	skin_list.add_theme_constant_override("separation", 4 if front_stack else 6)
	settings_list.add_theme_constant_override("separation", 4 if front_stack else 6)
	settings_row.columns = 1 if front_narrow else 2
	settings_scroll.custom_minimum_size = Vector2(0.0, 228.0 if front_stack else 292.0)
	preview_frame.custom_minimum_size = Vector2(0.0, 244.0 if front_stack else 304.0)
	skin_preview.custom_minimum_size = Vector2(0.0, 220.0 if front_stack else 284.0)
	racks_grid.columns = 1 if front_stack else 2
	left_gutter.visible = not front_stack
	right_gutter.visible = not front_stack
	starter_choice_wrap.add_theme_constant_override("separation", 0 if front_stack else 12)

	game_title_label.add_theme_font_size_override("font_size", 18 if front_narrow else 20 if front_stack else 24)
	front_mode_label.add_theme_font_size_override("font_size", 10 if front_narrow or front_stack else 11)
	title_tagline_label.add_theme_font_size_override("font_size", 18 if front_narrow else 20 if front_stack else 24)
	title_status_label.add_theme_font_size_override("font_size", 11 if front_narrow else 12 if front_stack else 13)
	title_loadout_label.add_theme_font_size_override("font_size", 11 if front_narrow else 12 if front_stack else 13)
	start_prompt_label.add_theme_font_size_override("font_size", 11 if front_narrow else 12 if front_stack else 13)
	menu_badge_label.add_theme_font_size_override("font_size", 10 if front_stack else 11)

	hud_margin.add_theme_constant_override("margin_left", 10 if hud_compact else 18)
	hud_margin.add_theme_constant_override("margin_top", 10 if hud_compact else 14)
	hud_margin.add_theme_constant_override("margin_right", 10 if hud_compact else 18)
	hud_margin.add_theme_constant_override("margin_bottom", 10 if hud_compact else 14)
	top_padding.add_theme_constant_override("margin_left", 10 if hud_compact else 12)
	top_padding.add_theme_constant_override("margin_top", 8 if hud_compact else 10)
	top_padding.add_theme_constant_override("margin_right", 10 if hud_compact else 12)
	top_padding.add_theme_constant_override("margin_bottom", 8 if hud_compact else 10)
	stats_row.add_theme_constant_override("h_separation", 8 if hud_compact else 10)
	stats_row.add_theme_constant_override("v_separation", 6)
	fuel_bar.custom_minimum_size = Vector2(160.0 if hud_stack else 204.0, 14.0 if hud_compact else 16.0)
	health_bar.custom_minimum_size = Vector2(148.0 if hud_stack else 188.0, 14.0 if hud_compact else 16.0)
	weapon_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if hud_stack else TextServer.AUTOWRAP_OFF
	weapon_label.custom_minimum_size = Vector2(124.0 if hud_stack else 0.0, 0.0)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if hud_stack else HORIZONTAL_ALIGNMENT_RIGHT
	stats_label.add_theme_font_size_override("font_size", 12 if hud_compact else 13)
	prompt_padding.add_theme_constant_override("margin_left", 8 if hud_compact else 10)
	prompt_padding.add_theme_constant_override("margin_top", 6 if hud_compact else 8)
	prompt_padding.add_theme_constant_override("margin_right", 8 if hud_compact else 10)
	prompt_padding.add_theme_constant_override("margin_bottom", 6 if hud_compact else 8)
	prompt_row.add_theme_constant_override("h_separation", 8 if hud_compact else 10)
	prompt_row.add_theme_constant_override("v_separation", 6)
	_set_prompt_icon_size(HUD_PROMPT_ICON_COMPACT if hud_compact else HUD_PROMPT_ICON_DEFAULT)


func _set_prompt_icon_size(icon_size: Vector2) -> void:
	for prompt in prompt_row.get_children():
		for child in prompt.get_children():
			if child is TextureRect:
				(child as TextureRect).custom_minimum_size = icon_size


func _apply_static_ui_theme() -> void:
	hud.theme = _ui_theme
	front_door.theme = _ui_theme
	PixelUI.style_panel($CanvasLayer/HUD/Margin/Layout/TopPanel, "glass")
	PixelUI.style_panel($CanvasLayer/HUD/Margin/Layout/PromptDock, "glass")
	PixelUI.style_panel(title_overlay, "hero")
	PixelUI.style_panel(menu_window, "rail")
	PixelUI.style_panel(customize_window, "glass")
	PixelUI.style_panel(settings_window, "glass")
	PixelUI.style_panel(starter_choice_panel, "hero")
	PixelUI.style_panel($CanvasLayer/FrontDoor/Margin/Layout/FooterBar, "glass")
	PixelUI.style_panel($CanvasLayer/FrontDoor/Margin/Layout/ConsoleRow/CustomizeWindow/Padding/Stack/PreviewFrame, "display")
	PixelUI.style_panel($CanvasLayer/FrontDoor/Margin/Layout/ConsoleRow/TitleOverlay/Padding/Stack/ReadoutRow/SectorFrame, "display")
	PixelUI.style_panel($CanvasLayer/FrontDoor/Margin/Layout/ConsoleRow/TitleOverlay/Padding/Stack/ReadoutRow/LoadoutFrame, "display")
	PixelUI.style_panel(blade_card, "item")
	PixelUI.style_panel(gun_card, "item")

	PixelUI.style_label(game_title_label, "brand")
	PixelUI.style_label(front_mode_label, "eyebrow")
	PixelUI.style_label(title_tagline_label, "hero_title")
	PixelUI.style_label(title_status_label, "body")
	PixelUI.style_label(title_loadout_label, "accent")
	PixelUI.style_label(menu_badge_label, "eyebrow")
	PixelUI.style_label($CanvasLayer/FrontDoor/Margin/Layout/ConsoleRow/MenuWindow/Padding/Stack/MenuLegend, "muted")
	PixelUI.style_label($CanvasLayer/FrontDoor/Margin/Layout/ConsoleRow/MenuWindow/Padding/Stack/MenuLegendB, "muted")
	PixelUI.style_label($CanvasLayer/FrontDoor/Margin/Layout/ConsoleRow/CustomizeWindow/Padding/Stack/CustomizeTitle, "title")
	PixelUI.style_label($CanvasLayer/FrontDoor/Margin/Layout/ConsoleRow/SettingsWindow/Padding/Row/Readout/SettingsConsoleTitle, "title")
	PixelUI.style_label($CanvasLayer/FrontDoor/Margin/Layout/ConsoleRow/SettingsWindow/Padding/Row/ListColumn/SettingsTitle, "title")
	PixelUI.style_label(settings_section_label, "eyebrow")
	PixelUI.style_label(settings_summary_label, "small")
	PixelUI.style_label($CanvasLayer/FrontDoor/Margin/Layout/StarterChoiceWrap/StarterChoice/ChoicePadding/ChoiceStack/ChoiceTitle, "title")
	PixelUI.style_label($CanvasLayer/HUD/Margin/Layout/TopPanel/TopPadding/TopStack/HeaderRow/Title, "title")
	PixelUI.style_label(timer_label, "metric")
	PixelUI.style_label(objective_label, "accent")
	PixelUI.style_label(message_label, "small")
	PixelUI.style_label(stats_label, "small")
	PixelUI.style_label(start_prompt_label, "accent")
	PixelUI.style_label(intro_caption_label, "small")
	PixelUI.style_label(skin_status_label, "accent")
	PixelUI.style_label(skin_hint_label, "small")
	PixelUI.style_label(settings_footer_label, "small")
	PixelUI.style_label(remap_prompt_label, "warning")
	PixelUI.style_label(starter_hint_label, "accent")
	PixelUI.style_label(weapon_label, "small")
	PixelUI.style_label($CanvasLayer/FrontDoor/Margin/Layout/StarterChoiceWrap/StarterChoice/ChoicePadding/ChoiceStack/Racks/BladeCard/Padding/Stack/BladeName, "title")
	PixelUI.style_label($CanvasLayer/FrontDoor/Margin/Layout/StarterChoiceWrap/StarterChoice/ChoicePadding/ChoiceStack/Racks/BladeCard/Padding/Stack/BladeDesc, "small")
	PixelUI.style_label(blade_status_label, "accent")
	PixelUI.style_label($CanvasLayer/FrontDoor/Margin/Layout/StarterChoiceWrap/StarterChoice/ChoicePadding/ChoiceStack/Racks/GunCard/Padding/Stack/GunName, "title")
	PixelUI.style_label($CanvasLayer/FrontDoor/Margin/Layout/StarterChoiceWrap/StarterChoice/ChoicePadding/ChoiceStack/Racks/GunCard/Padding/Stack/GunDesc, "small")
	PixelUI.style_label(gun_status_label, "accent")
	PixelUI.style_label($CanvasLayer/HUD/Margin/Layout/TopPanel/TopPadding/TopStack/StatsRow/FuelStack/FuelLabel, "small")
	PixelUI.style_label($CanvasLayer/HUD/Margin/Layout/TopPanel/TopPadding/TopStack/StatsRow/HealthStack/HealthLabel, "small")

	game_title_label.text = "KILLER QUEEN"
	menu_badge_label.text = "COMMAND RAIL"
	menu_legend_label.text = "UP / DOWN SELECT"
	menu_legend_b_label.text = "ATTACK CONFIRM"

	fuel_bar.fill_color = PixelUI.COLOR_TEAL
	fuel_bar.low_color = PixelUI.COLOR_RUST
	fuel_bar.frame_color = PixelUI.COLOR_PANEL_EDGE
	fuel_bar.background_color = PixelUI.COLOR_INK
	health_bar.fill_color = PixelUI.COLOR_AMBER
	health_bar.low_color = PixelUI.COLOR_RUST
	health_bar.frame_color = PixelUI.COLOR_PANEL_EDGE
	health_bar.background_color = PixelUI.COLOR_INK


func _ensure_boss_ui() -> void:
	if _boss_panel != null:
		return

	_boss_panel = PanelContainer.new()
	_boss_panel.visible = false
	_boss_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_boss_panel.theme = _ui_theme
	PixelUI.style_panel(_boss_panel, "warning")

	var padding := MarginContainer.new()
	padding.add_theme_constant_override("margin_left", 10)
	padding.add_theme_constant_override("margin_top", 6)
	padding.add_theme_constant_override("margin_right", 10)
	padding.add_theme_constant_override("margin_bottom", 6)
	_boss_panel.add_child(padding)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	padding.add_child(row)

	_boss_name_label = Label.new()
	_boss_name_label.text = "APEX"
	PixelUI.style_label(_boss_name_label, "title")
	row.add_child(_boss_name_label)

	_boss_meter = PixelMeter.new()
	_boss_meter.custom_minimum_size = Vector2(0.0, 12.0)
	_boss_meter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_boss_meter.max_value = 12.0
	_boss_meter.value = 12.0
	_boss_meter.fill_color = PixelUI.COLOR_AMBER
	_boss_meter.low_color = PixelUI.COLOR_RUST
	_boss_meter.frame_color = PixelUI.COLOR_PANEL_EDGE
	_boss_meter.background_color = PixelUI.COLOR_INK
	row.add_child(_boss_meter)

	_boss_window_label = Label.new()
	_boss_window_label.text = "ARMOR SEALED"
	_boss_window_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	PixelUI.style_label(_boss_window_label, "accent")
	row.add_child(_boss_window_label)

	hud_layout.add_child(_boss_panel)
	hud_layout.move_child(_boss_panel, 1)

	_duel_dialogue_panel = PanelContainer.new()
	_duel_dialogue_panel.visible = false
	_duel_dialogue_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_duel_dialogue_panel.theme = _ui_theme
	PixelUI.style_panel(_duel_dialogue_panel, "window")

	var dialogue_padding := MarginContainer.new()
	dialogue_padding.add_theme_constant_override("margin_left", 12)
	dialogue_padding.add_theme_constant_override("margin_top", 10)
	dialogue_padding.add_theme_constant_override("margin_right", 12)
	dialogue_padding.add_theme_constant_override("margin_bottom", 10)
	_duel_dialogue_panel.add_child(dialogue_padding)

	var dialogue_stack := VBoxContainer.new()
	dialogue_stack.add_theme_constant_override("separation", 4)
	dialogue_padding.add_child(dialogue_stack)

	_duel_speaker_label = Label.new()
	_duel_speaker_label.text = "APEX"
	PixelUI.style_label(_duel_speaker_label, "eyebrow")
	dialogue_stack.add_child(_duel_speaker_label)

	_duel_line_label = Label.new()
	_duel_line_label.text = "This plane is only big for one of us."
	_duel_line_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	PixelUI.style_label(_duel_line_label, "body")
	dialogue_stack.add_child(_duel_line_label)

	hud_layout.add_child(_duel_dialogue_panel)
	hud_layout.move_child(_duel_dialogue_panel, 1)

	_receipt_panel = PanelContainer.new()
	_receipt_panel.visible = false
	_receipt_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_receipt_panel.theme = _ui_theme
	PixelUI.style_panel(_receipt_panel, "dock")

	var receipt_padding := MarginContainer.new()
	receipt_padding.add_theme_constant_override("margin_left", 12)
	receipt_padding.add_theme_constant_override("margin_top", 10)
	receipt_padding.add_theme_constant_override("margin_right", 12)
	receipt_padding.add_theme_constant_override("margin_bottom", 10)
	_receipt_panel.add_child(receipt_padding)

	var receipt_stack := VBoxContainer.new()
	receipt_stack.add_theme_constant_override("separation", 4)
	receipt_padding.add_child(receipt_stack)

	_receipt_title_label = Label.new()
	_receipt_title_label.text = "PURGE LOGGED"
	PixelUI.style_label(_receipt_title_label, "title")
	receipt_stack.add_child(_receipt_title_label)

	_receipt_body_label = Label.new()
	_receipt_body_label.text = ""
	_receipt_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	PixelUI.style_label(_receipt_body_label, "body")
	receipt_stack.add_child(_receipt_body_label)

	_receipt_hint_label = Label.new()
	_receipt_hint_label.text = ""
	_receipt_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	PixelUI.style_label(_receipt_hint_label, "small")
	receipt_stack.add_child(_receipt_hint_label)

	hud_layout.add_child(_receipt_panel)
	hud_layout.move_child(_receipt_panel, 1)


func _apply_profile_runtime_state() -> void:
	if profile_store == null:
		_apply_ui_scale_setting(1.0)
		return
	_best_altitude = int(profile_store.call("get_record", "best_altitude_m"))
	var ui_scale := float(profile_store.call("get_setting", "ui_scale"))
	_apply_ui_scale_setting(ui_scale)


func _apply_selected_skin() -> void:
	var skin_id := SkinPalette.SKIN_HIVE_RUNNER
	if profile_store != null:
		skin_id = String(profile_store.call("get_selected_skin"))
	if is_instance_valid(_player):
		_player.call("apply_skin", skin_id)
		_player.call("set_weapon_mode", _preview_weapon_mode)
	if skin_preview != null:
		skin_preview.set_skin_id(skin_id)
		skin_preview.set_weapon_mode(_preview_weapon_mode)


func _ensure_kill_floor_visual() -> void:
	if _kill_floor_line != null:
		return

	_kill_floor_line = Line2D.new()
	_kill_floor_line.width = 6.0
	_kill_floor_line.default_color = Color(0.886275, 0.419608, 0.301961, 0.92)
	_kill_floor_line.points = PackedVector2Array([Vector2(-80.0, _kill_floor_y), Vector2(WORLD_SIZE.x + 80.0, _kill_floor_y)])
	add_child(_kill_floor_line)
	move_child(_kill_floor_line, 1)


func _ensure_transfer_line() -> void:
	if _transfer_line != null:
		return

	_transfer_line = Line2D.new()
	_transfer_line.width = 6.0
	_transfer_line.default_color = Color(0.913725, 0.835294, 0.545098, 0.92)
	_transfer_line.visible = false
	add_child(_transfer_line)
	move_child(_transfer_line, 2)


func _enter_title() -> void:
	_state = STATE_TITLE
	_front_mode = FRONT_MAIN
	_landing_timer = 0.0
	_transfer_timer = 0.0
	_current_choice_target = ""
	_claim_sequence_active = false
	_starter_weapon = STARTER_BLADE
	_alternate_weapon_unlocked = false
	_route_phase = PHASE_SHAFT
	_active_region_id = REGION_HIVE
	_active_boss_region_id = ""
	_initialize_region_states()
	_kill_floor_active = false
	_cave_arena = null
	_rival_boss = null
	_cave_exit_goal = null
	_weapon_salvage = null
	_left_gate_platform = null
	_right_gate_platform = null
	_boss_intro_running = false
	_menu_index = 0
	_skin_index = _get_skin_index_from_id(_get_selected_skin_id())
	_settings_index = 0
	_remap_action = ""
	_preview_weapon_mode = STARTER_BLADE

	_clear_runtime_nodes(platforms)
	_clear_runtime_nodes(pickups)
	_clear_runtime_nodes(enemies)
	_clear_runtime_nodes(projectiles)
	_clear_runtime_nodes(goal_anchor)
	_build_intro_dock()

	_player.call("reset_to", _get_title_hero_point())
	_player.global_position = _get_title_hero_point()
	_player.set_physics_process(false)
	_player.call("set_weapon_mode", _preview_weapon_mode)
	_player.call("set_swap_enabled", false)
	_player.call("set_controls_enabled", false)
	_player.call("set_facing_direction", 1)
	_player.visible = true
	_apply_selected_skin()

	_set_intro_camera_active(true)
	_set_run_hud_visible(false)
	_set_front_door_visible(true)
	_set_kill_floor_visible(false)
	_transfer_line.visible = false
	backdrop.call("set_region_mode", BACKDROP_SUNSET_RUIN)
	_set_boss_ui_visible(false)
	_set_duel_dialogue_visible(false)
	_hide_receipt()

	start_prompt_label.text = "UP / DOWN SELECT    ATTACK CONFIRM"
	intro_caption_label.text = "Sanctuary is still holding above the breach. Start the first purge when ready."
	_set_front_mode(FRONT_MAIN)
	_refresh_front_door_readout()
	_update_choice_cards("")


func _update_title_state() -> void:
	match _front_mode:
		FRONT_MAIN:
			_update_main_menu_input()
		FRONT_CUSTOMIZE:
			_update_customize_input()
		FRONT_SETTINGS:
			_update_settings_input()


func _set_front_door_layout(show_console: bool, show_choice: bool, show_footer: bool) -> void:
	if console_row != null:
		console_row.visible = show_console
	if choice_spacer != null:
		choice_spacer.visible = false
	if starter_choice_wrap != null:
		starter_choice_wrap.visible = show_choice
	if footer_bar != null:
		footer_bar.visible = show_footer


func _set_front_mode(mode: String) -> void:
	_front_mode = mode
	_set_front_door_layout(true, false, true)
	title_overlay.visible = mode == FRONT_MAIN
	menu_window.visible = mode == FRONT_MAIN
	customize_window.visible = mode == FRONT_CUSTOMIZE
	settings_window.visible = mode == FRONT_SETTINGS
	starter_choice_wrap.visible = false
	starter_choice_panel.visible = false
	if is_instance_valid(_player):
		_player.call("set_weapon_mode", _preview_weapon_mode)
		_player.call("set_controls_enabled", false)
		_player.visible = mode == FRONT_MAIN

	match mode:
		FRONT_MAIN:
			start_prompt_label.text = "ATTACK START DROP"
			intro_caption_label.text = "Sanctuary still holds above the breach. Pick steel and start the first purge."
			footer_hint_label.text = "UP / DOWN NAV   ATTACK CONFIRM"
			_rebuild_menu_list()
		FRONT_CUSTOMIZE:
			start_prompt_label.text = ""
			intro_caption_label.text = "Read shell color and weapon flare on the live dock."
			footer_hint_label.text = "ATTACK EQUIP   CANCEL BACK"
			_rebuild_customize_list()
		FRONT_SETTINGS:
			start_prompt_label.text = ""
			intro_caption_label.text = "Tune the board, keep it readable, then move."
			footer_hint_label.text = "ATTACK / LEFT / RIGHT   CANCEL BACK"
			_begin_settings_edit()
			_rebuild_settings_list()

	_refresh_front_door_readout()


func _update_main_menu_input() -> void:
	var entries := _get_visible_menu_entries()
	if _menu_move_up_pressed():
		_menu_index = wrapi(_menu_index - 1, 0, entries.size())
		_rebuild_menu_list()
	if _menu_move_down_pressed():
		_menu_index = wrapi(_menu_index + 1, 0, entries.size())
		_rebuild_menu_list()
	if _menu_accept_pressed():
		_activate_menu_entry(String(entries[_menu_index]["id"]))


func _activate_menu_entry(entry_id: String) -> void:
	match entry_id:
		"start":
			_start_landing_intro()
		"customize":
			_set_front_mode(FRONT_CUSTOMIZE)
		"settings":
			_set_front_mode(FRONT_SETTINGS)
		"quit":
			get_tree().quit()


func _update_customize_input() -> void:
	if _menu_move_up_pressed():
		_skin_index = wrapi(_skin_index - 1, 0, SKIN_ORDER.size())
		_rebuild_customize_list()
	if _menu_move_down_pressed():
		_skin_index = wrapi(_skin_index + 1, 0, SKIN_ORDER.size())
		_rebuild_customize_list()
	if _menu_move_left_pressed() or _menu_move_right_pressed():
		_preview_weapon_mode = STARTER_GUN if _preview_weapon_mode == STARTER_BLADE else STARTER_BLADE
		skin_preview.set_weapon_mode(_preview_weapon_mode)
		if is_instance_valid(_player):
			_player.call("set_weapon_mode", _preview_weapon_mode)
		_rebuild_customize_list()
	if _menu_cancel_pressed():
		_set_front_mode(FRONT_MAIN)
		return
	if _menu_accept_pressed():
		_commit_skin_choice()


func _commit_skin_choice() -> void:
	var skin_id: String = SKIN_ORDER[_skin_index]
	if profile_store != null and not bool(profile_store.call("is_skin_unlocked", skin_id)):
		skin_status_label.text = "Locked. Beat the full game for Night Queen."
		_refresh_front_door_readout()
		return
	if profile_store != null:
		profile_store.call("set_selected_skin", skin_id)
		profile_store.call("save_profile")
	_apply_selected_skin()
	skin_status_label.text = "%s equipped." % String(SKIN_META[skin_id]["title"])
	_rebuild_customize_list()
	_refresh_front_door_readout()


func _start_landing_intro() -> void:
	_state = STATE_LANDING
	_landing_timer = 0.0
	_claim_sequence_active = false
	_set_front_door_layout(false, false, true)
	title_overlay.visible = false
	menu_window.visible = false
	customize_window.visible = false
	settings_window.visible = false
	starter_choice_wrap.visible = false
	starter_choice_panel.visible = false
	intro_caption_label.text = "Purge order stamped. Dock clamps are cutting loose."
	footer_hint_label.text = "PURGE ORDER LIVE"
	_player.call("reset_to", _get_intro_drop_point())
	_player.set_physics_process(false)
	_player.call("set_controls_enabled", false)
	_player.call("set_swap_enabled", false)
	_player.visible = true
	_hide_receipt()
	_refresh_front_door_readout()


func _update_landing_state(delta: float) -> void:
	_landing_timer = minf(_landing_timer + delta, INTRO_LANDING_DURATION)
	var t := clampf(_landing_timer / INTRO_LANDING_DURATION, 0.0, 1.0)
	var eased := 1.0 - pow(1.0 - t, 3.0)
	var drop_point := _get_intro_drop_point()
	var landing_point := _get_intro_landing_point()
	var landing_arc := sin(t * PI) * 14.0
	_player.global_position = Vector2(
		lerpf(drop_point.x, landing_point.x, eased),
		lerpf(drop_point.y, landing_point.y, eased) - landing_arc
	)
	if t >= 1.0:
		_enter_starter_choice()


func _enter_starter_choice() -> void:
	_state = STATE_STARTER_CHOICE
	_current_choice_target = ""
	_claim_sequence_active = false
	_player.global_position = _get_intro_landing_point()
	_player.set_physics_process(true)
	_player.call("set_controls_enabled", true)
	_player.call("set_swap_enabled", false)
	_player.visible = true
	_set_front_door_layout(false, true, true)
	title_overlay.visible = false
	menu_window.visible = false
	customize_window.visible = false
	settings_window.visible = false
	starter_choice_wrap.visible = true
	starter_choice_panel.visible = true
	start_prompt_label.text = ""
	intro_caption_label.text = "Choose one rack for the drop. The second weapon stays sealed until deeper in the purge."
	footer_hint_label.text = ""
	_refresh_front_door_readout()
	_update_choice_cards("")
	_update_starter_choice_state()


func _update_starter_choice_state() -> void:
	var target := _get_choice_target()
	if target != _current_choice_target:
		_current_choice_target = target
		_update_choice_cards(target)

	if _claim_sequence_active:
		return

	if target != "" and Input.is_action_just_pressed("shoot"):
		_commit_starter_choice(target)


func _commit_starter_choice(mode: String) -> void:
	if _claim_sequence_active:
		return
	_claim_sequence_active = true
	_starter_weapon = mode
	_preview_weapon_mode = mode
	_alternate_weapon_unlocked = false
	_player.call("set_weapon_mode", mode)
	_player.call("set_swap_enabled", false)
	_player.call("set_controls_enabled", false)
	_player.call("play_weapon_flourish", 0.36)
	if intro_stage != null:
		intro_stage.call("set_rack_focus", mode)
		intro_stage.call("flash_claim", mode)
	intro_caption_label.text = "%s locked for this alpha. The second rack stays sealed." % _get_weapon_display_name_for(mode)
	starter_hint_label.text = "%s staged. The other rack opens later in the campaign." % _get_weapon_display_name_for(mode)
	footer_hint_label.text = "SECOND RACK SEALED"
	_update_choice_cards(mode)
	await get_tree().create_timer(0.18).timeout
	if _state != STATE_STARTER_CHOICE:
		return
	intro_caption_label.text = "%s locked. Sanctuary drop lane is live." % _get_weapon_display_name_for(mode)
	await get_tree().create_timer(0.26).timeout
	if _state != STATE_STARTER_CHOICE:
		return
	starter_choice_panel.visible = false
	_claim_sequence_active = false
	_begin_playable_slice()


func _begin_playable_slice() -> void:
	_reset_run()
	_set_message("Sanctuary drop confirmed. Burn the Hive Shaft anchors and expose the Brood Warden.")


func _reset_run() -> void:
	var spawn_point := _get_spawn_point()
	_state = "boot"
	_run_time = 0.0
	_transfer_timer = 0.0
	_transfer_kind = ""
	_combo = 0
	_combo_timer = 0.0
	_flow_reward_tier = 0
	_threats_cleared = 0
	_total_threats = 0
	_route_phase = PHASE_SHAFT
	_active_region_id = REGION_HIVE
	_active_boss_region_id = ""
	_initialize_region_states()
	_kill_floor_active = true
	_highest_player_y = spawn_point.y
	_kill_floor_y = spawn_point.y + KILL_FLOOR_OFFSET
	_run_bug_kills = 0
	_run_rival_clears = 0
	_run_records_committed = false
	_cave_arena = null
	_rival_boss = null
	_cave_exit_goal = null
	_tower_transfer_goal = null
	_weapon_salvage = null
	_left_gate_platform = null
	_right_gate_platform = null
	_boss_intro_running = false

	_disable_runtime_triggers()
	_clear_runtime_nodes(platforms)
	_clear_runtime_nodes(pickups)
	_clear_runtime_nodes(enemies)
	_clear_runtime_nodes(projectiles)
	_clear_runtime_nodes(goal_anchor)
	await get_tree().process_frame
	if _state != "boot":
		return

	_state = STATE_PLAYING
	_build_tower()
	_spawn_hazards()
	_spawn_region_anchors(REGION_HIVE)

	_player.set_physics_process(true)
	_player.visible = true
	_player.call("reset_to", spawn_point)
	_player.call("reset_weapon_upgrades")
	_player.call("apply_skin", _get_selected_skin_id())
	_player.call("set_weapon_mode", _starter_weapon)
	_player.call("set_swap_enabled", false)
	_on_player_health_changed(3, 3)
	_on_player_fuel_changed(100.0, 100.0)
	_on_player_weapon_mode_changed(_starter_weapon, false)

	_set_intro_camera_active(false)
	_set_front_door_visible(false)
	_set_run_hud_visible(true)
	_set_kill_floor_visible(true)
	_ensure_transfer_line()
	_transfer_line.visible = false
	backdrop.call("set_region_mode", BACKDROP_HIVE_SHAFT)
	_set_boss_ui_visible(false)
	_set_duel_dialogue_visible(false)
	_hide_receipt()
	_apply_run_camera(0.2)

	if profile_store != null:
		profile_store.call("increment_record", "runs_started", 1)
		profile_store.call("save_profile")

	_set_message(BountyFeed.get_run_opening_message(_weapon_mode))
	_update_hud()
	_update_kill_floor_visual()


func _start_transfer_outro() -> void:
	_state = STATE_TRANSFER
	_route_phase = PHASE_MOUNTAIN
	_transfer_kind = TRANSFER_KIND_MOUNTAIN
	_transfer_timer = 0.0
	_transfer_start = _player.global_position
	_kill_floor_active = false
	_player.set_physics_process(false)
	_player.call("set_controls_enabled", false)
	_disable_runtime_triggers()
	_clear_runtime_nodes(platforms)
	_clear_runtime_nodes(pickups)
	_clear_runtime_nodes(enemies)
	_clear_runtime_nodes(projectiles)
	_clear_runtime_nodes(goal_anchor)
	_cave_arena = null
	_rival_boss = null
	_cave_exit_goal = null
	_tower_transfer_goal = null
	_skyline_boss_goal = null
	_weapon_salvage = null
	_left_gate_platform = null
	_right_gate_platform = null
	_set_kill_floor_visible(false)
	_set_boss_ui_visible(false)
	_set_duel_dialogue_visible(false)
	await get_tree().process_frame
	if _state != STATE_TRANSFER or _transfer_kind != TRANSFER_KIND_MOUNTAIN:
		return
	_build_mountain_slice()
	_spawn_mountain_hazards()
	_spawn_region_anchors(REGION_SKYLINE)
	_active_region_id = REGION_SKYLINE
	_set_region_state(REGION_SKYLINE, REGION_STATE_ACTIVE)
	_transfer_end = SKYLINE_ENTRY_POSITION
	_ensure_transfer_line()
	_transfer_line.points = PackedVector2Array([_transfer_start, _transfer_end])
	_transfer_line.visible = true
	backdrop.call("set_region_mode", BACKDROP_MOUNTAIN_PASS)
	_set_message(BountyFeed.get_outro_transfer_message())
	_update_hud()
	_apply_run_camera(0.2)


func _start_cave_transfer() -> void:
	if _state != STATE_PLAYING or _route_phase != PHASE_SHAFT:
		return
	_state = STATE_TRANSFER
	_route_phase = PHASE_CAVE
	_transfer_kind = TRANSFER_KIND_CAVE
	_transfer_timer = 0.0
	_transfer_start = _player.global_position
	_kill_floor_active = false
	_set_kill_floor_visible(false)
	_player.set_physics_process(false)
	_player.call("set_controls_enabled", false)
	if _tower_transfer_goal != null and is_instance_valid(_tower_transfer_goal):
		_tower_transfer_goal.call("set_active", false)
	_disable_runtime_triggers()
	_clear_runtime_nodes(platforms)
	_clear_runtime_nodes(pickups)
	_clear_runtime_nodes(enemies)
	_clear_runtime_nodes(projectiles)
	_clear_runtime_nodes(goal_anchor)
	await get_tree().process_frame
	if _state != STATE_TRANSFER or _transfer_kind != TRANSFER_KIND_CAVE:
		return

	_build_cave_slice()
	_transfer_end = _cave_arena.call("get_entry_position")
	_ensure_transfer_line()
	_transfer_line.points = PackedVector2Array([_transfer_start, _transfer_end])
	_transfer_line.visible = true
	backdrop.call("set_region_mode", BACKDROP_HIVE_SHAFT)
	_set_message(BountyFeed.get_cave_transfer_message())
	_update_hud()
	_apply_run_camera(0.2)


func _update_transfer_state(delta: float) -> void:
	_transfer_timer = minf(_transfer_timer + delta, TRANSFER_DURATION)
	var t := clampf(_transfer_timer / TRANSFER_DURATION, 0.0, 1.0)
	var eased := 1.0 - pow(1.0 - t, 2.8)
	_player.global_position = _transfer_start.lerp(_transfer_end, eased)
	_apply_run_camera(delta)
	if _transfer_line != null:
		_transfer_line.visible = true
	if t >= 1.0:
		_finish_transfer_outro()


func _finish_transfer_outro() -> void:
	if _transfer_kind == TRANSFER_KIND_CAVE:
		_finish_cave_transfer()
		return
	if _transfer_kind == TRANSFER_KIND_MOUNTAIN:
		_finish_mountain_transfer()


func _finish_cave_transfer() -> void:
	_state = STATE_PLAYING
	_transfer_kind = ""
	_player.global_position = _transfer_end
	_player.set_physics_process(true)
	_player.call("set_controls_enabled", true)
	if _transfer_line != null:
		_transfer_line.visible = false
	_set_message(BountyFeed.get_cave_entry_message())
	_update_hud()


func _finish_mountain_transfer() -> void:
	_state = STATE_PLAYING
	_transfer_kind = ""
	_route_phase = PHASE_MOUNTAIN
	_player.global_position = _transfer_end
	_player.set_physics_process(true)
	_player.call("set_controls_enabled", true)
	if _transfer_line != null:
		_transfer_line.visible = false
	backdrop.call("set_region_mode", BACKDROP_SUNSET_RUIN)
	_set_message("Sunset Ruin Skyline live. Break the surface anchors and expose the Spire Matriarch.")
	_update_hud()


func _begin_settings_edit() -> void:
	if profile_store != null:
		_settings_snapshot = profile_store.call("get_default_settings")
		for key_variant in PlayerProfile.DEFAULT_SETTINGS.keys():
			var key := String(key_variant)
			_settings_snapshot[key] = profile_store.call("get_setting", key)
		_settings_draft = _settings_snapshot.duplicate(true)
		_input_bindings_snapshot = _duplicate_binding_dictionary(profile_store.call("get_input_bindings"))
		if _input_bindings_snapshot.is_empty():
			profile_store.call("capture_current_input_bindings")
			_input_bindings_snapshot = _duplicate_binding_dictionary(profile_store.call("get_input_bindings"))
		_input_bindings_draft = _duplicate_binding_dictionary(_input_bindings_snapshot)
	else:
		_settings_snapshot = PlayerProfile.DEFAULT_SETTINGS.duplicate(true)
		_settings_draft = _settings_snapshot.duplicate(true)
		_input_bindings_snapshot = {}
		_input_bindings_draft = {}
	_settings_index = 0
	_remap_action = ""
	remap_prompt_label.visible = false
	_apply_settings_draft_preview()


func _update_settings_input() -> void:
	if _remap_action.is_empty():
		if _menu_move_up_pressed():
			_settings_index = wrapi(_settings_index - 1, 0, SETTING_ROWS.size())
			_rebuild_settings_list()
		if _menu_move_down_pressed():
			_settings_index = wrapi(_settings_index + 1, 0, SETTING_ROWS.size())
			_rebuild_settings_list()
		if _menu_move_left_pressed():
			_adjust_current_setting(-1)
		if _menu_move_right_pressed() or Input.is_action_just_pressed("shoot"):
			_adjust_current_setting(1)
		if _menu_accept_pressed():
			var row: Dictionary = SETTING_ROWS[_settings_index]
			if String(row["type"]) == "input":
				_remap_action = String(row["action"])
				remap_prompt_label.visible = true
				remap_prompt_label.text = "Press a key or button for %s." % String(row["label"])
				_rebuild_settings_list()
			else:
				_adjust_current_setting(1)
		if Input.is_action_just_pressed("swap_weapon"):
			_reset_settings_to_defaults()
		if Input.is_action_just_pressed("jump"):
			_apply_settings_commit()
			return
		if _menu_cancel_pressed():
			_restore_settings_snapshot()
			_set_front_mode(FRONT_MAIN)
			return


func _adjust_current_setting(direction: int) -> void:
	var row: Dictionary = SETTING_ROWS[_settings_index]
	if String(row["type"]) != "setting":
		return
	var setting_id := String(row["id"])
	var options: Array = row["options"]
	var current: Variant = _settings_draft.get(setting_id, options[0])
	var current_index := options.find(current)
	if current_index == -1:
		current_index = 0
	current_index = wrapi(current_index + direction, 0, options.size())
	_settings_draft[setting_id] = options[current_index]
	_apply_settings_draft_preview()
	_rebuild_settings_list()


func _apply_settings_commit() -> void:
	if profile_store != null:
		for key_variant in _settings_draft.keys():
			var key := String(key_variant)
			profile_store.call("set_setting", key, _settings_draft[key])
		profile_store.call("set_input_bindings", _input_bindings_draft, true)
		profile_store.call("save_profile")
	_apply_settings_draft_preview()
	_set_front_mode(FRONT_MAIN)


func _restore_settings_snapshot() -> void:
	_settings_draft = _settings_snapshot.duplicate(true)
	_input_bindings_draft = _duplicate_binding_dictionary(_input_bindings_snapshot)
	if profile_store != null:
		profile_store.call("set_input_bindings", _input_bindings_snapshot, true)
	_apply_settings_draft_preview()


func _reset_settings_to_defaults() -> void:
	_settings_draft = PlayerProfile.DEFAULT_SETTINGS.duplicate(true)
	if profile_store != null:
		profile_store.call("capture_current_input_bindings")
		_input_bindings_draft = _duplicate_binding_dictionary(profile_store.call("get_input_bindings"))
	_apply_settings_draft_preview()
	_rebuild_settings_list()


func _apply_settings_draft_preview() -> void:
	_apply_ui_scale_setting(float(_settings_draft.get("ui_scale", 1.0)))
	_apply_audio_setting("Master", float(_settings_draft.get("master", 1.0)))
	_apply_audio_setting("Music", float(_settings_draft.get("music", 1.0)))
	_apply_audio_setting("SFX", float(_settings_draft.get("sfx", 1.0)))
	_apply_window_mode_local(String(_settings_draft.get("window_mode", "windowed")))
	_apply_prompt_style_local(String(_settings_draft.get("prompt_style", "pixel")))


func _rebuild_menu_list() -> void:
	_clear_container(menu_list)
	var entries := _get_visible_menu_entries()
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		menu_list.add_child(
			_build_list_item(
				String(entry["title"]),
				String(entry.get("tag", "")),
				String(entry["subtitle"]),
				index == _menu_index,
				false,
				String(entry.get("icon", ""))
			)
		)
	_refresh_front_door_readout()


func _rebuild_customize_list() -> void:
	_clear_container(skin_list)
	for index in range(SKIN_ORDER.size()):
		var skin_id: String = SKIN_ORDER[index]
		var unlocked := profile_store == null or bool(profile_store.call("is_skin_unlocked", skin_id))
		var meta: Dictionary = SKIN_META[skin_id]
		var badge := "READY" if unlocked else "LOCKED"
		skin_list.add_child(
			_build_list_item(
				String(meta["title"]),
				badge,
				String(meta["subtitle"]),
				index == _skin_index,
				not unlocked,
				"[S]"
			)
		)

	var selected_skin: String = SKIN_ORDER[_skin_index]
	var is_unlocked := profile_store == null or bool(profile_store.call("is_skin_unlocked", selected_skin))
	skin_preview.set_skin_id(selected_skin)
	skin_preview.set_weapon_mode(_preview_weapon_mode)
	if is_unlocked:
		var fx_note := " Legion fires red dock lasers." if selected_skin == SkinPalette.SKIN_LEGION and _preview_weapon_mode == STARTER_GUN else ""
		skin_status_label.text = "%s ready. Previewing %s stance.%s" % [String(SKIN_META[selected_skin]["title"]), _get_weapon_display_name_for(_preview_weapon_mode), fx_note]
	else:
		skin_status_label.text = "Night Queen stays sealed until full clear."
	skin_hint_label.text = "ATTACK EQUIP    LEFT / RIGHT FX PREVIEW    CANCEL BACK"
	_refresh_front_door_readout()


func _rebuild_settings_list() -> void:
	_clear_container(settings_list)
	var last_category := ""
	for index in range(SETTING_ROWS.size()):
		var row: Dictionary = SETTING_ROWS[index]
		var category := _get_settings_category(row)
		if category != last_category:
			settings_list.add_child(_build_section_item(category, _get_settings_category_blurb(category)))
			last_category = category
		var title := String(row["label"])
		var value := ""
		var subtitle := _get_setting_row_help(row)
		if String(row["type"]) == "setting":
			value = _format_setting_value(String(row["id"]), _settings_draft.get(String(row["id"])))
		else:
			var action_name := String(row["action"])
			value = _get_binding_display(action_name)
			if _remap_action == action_name:
				value = "PRESS INPUT"
				subtitle = "Waiting for key or button."
		settings_list.add_child(_build_list_item(title, value, subtitle, index == _settings_index, false, "[#]"))
	if _remap_action.is_empty():
		settings_footer_label.text = "ATTACK CHANGE    JUMP APPLY    SWAP DEFAULTS    CANCEL BACK"
	else:
		settings_footer_label.text = "PRESS INPUT NOW    CANCEL KEEPS CURRENT BIND"
	_refresh_settings_console()
	_refresh_front_door_readout()


func _build_list_item(title: String, value: String, subtitle: String, selected: bool, disabled: bool, icon_text: String = "") -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(0.0, 68.0 if selected and not disabled else 62.0)
	PixelUI.style_panel(panel, "item_disabled" if disabled else ("item_selected" if selected else "item"))
	var padding := MarginContainer.new()
	padding.add_theme_constant_override("margin_left", 8)
	padding.add_theme_constant_override("margin_top", 7)
	padding.add_theme_constant_override("margin_right", 8)
	padding.add_theme_constant_override("margin_bottom", 7)
	panel.add_child(padding)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	padding.add_child(header)
	if not icon_text.is_empty():
		var icon_chip := PanelContainer.new()
		icon_chip.custom_minimum_size = Vector2(38.0, 24.0)
		PixelUI.style_panel(icon_chip, "item_disabled" if disabled else ("chip_selected" if selected else "chip"))
		header.add_child(icon_chip)
		var icon_padding := MarginContainer.new()
		icon_padding.add_theme_constant_override("margin_left", 4)
		icon_padding.add_theme_constant_override("margin_right", 4)
		icon_padding.add_theme_constant_override("margin_top", 2)
		icon_padding.add_theme_constant_override("margin_bottom", 2)
		icon_chip.add_child(icon_padding)
		var icon_label := Label.new()
		icon_label.text = icon_text
		icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		PixelUI.style_label(icon_label, "eyebrow" if not selected else "warning")
		if disabled:
			icon_label.add_theme_color_override("font_color", PixelUI.COLOR_DISABLED)
		icon_padding.add_child(icon_label)
	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_theme_constant_override("separation", 2)
	header.add_child(stack)
	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 6)
	stack.add_child(title_row)
	var title_label := Label.new()
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.text = title
	PixelUI.style_label(title_label, "title")
	if selected and not disabled:
		title_label.add_theme_color_override("font_color", PixelUI.COLOR_AMBER)
	if disabled:
		title_label.add_theme_color_override("font_color", PixelUI.COLOR_DISABLED)
	title_row.add_child(title_label)
	if not value.is_empty():
		var value_label := Label.new()
		value_label.text = value
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		PixelUI.style_label(value_label, "warning" if selected and not disabled else "accent")
		if disabled:
			value_label.add_theme_color_override("font_color", PixelUI.COLOR_DISABLED)
		title_row.add_child(value_label)
	if not subtitle.is_empty():
		var sub_label := Label.new()
		sub_label.text = subtitle
		PixelUI.style_label(sub_label, "accent" if selected and not disabled else "muted")
		if disabled:
			sub_label.add_theme_color_override("font_color", PixelUI.COLOR_DISABLED.darkened(0.1))
		stack.add_child(sub_label)
	var underline := ColorRect.new()
	underline.custom_minimum_size = Vector2(0.0, 2.0)
	underline.color = PixelUI.pulse_underline_color(selected and not disabled, float(Time.get_ticks_msec()) / 1000.0)
	stack.add_child(underline)
	return panel


func _build_section_item(title: String, subtitle: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	PixelUI.style_panel(panel, "terminal")
	var padding := MarginContainer.new()
	padding.add_theme_constant_override("margin_left", 8)
	padding.add_theme_constant_override("margin_top", 6)
	padding.add_theme_constant_override("margin_right", 8)
	padding.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(padding)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 2)
	padding.add_child(stack)
	var title_label := Label.new()
	title_label.text = title
	PixelUI.style_label(title_label, "eyebrow")
	stack.add_child(title_label)
	if not subtitle.is_empty():
		var subtitle_label := Label.new()
		subtitle_label.text = subtitle
		PixelUI.style_label(subtitle_label, "muted")
		stack.add_child(subtitle_label)
	return panel


func _refresh_front_door_readout() -> void:
	if front_mode_label == null:
		return

	if _state == STATE_STARTER_CHOICE:
		front_mode_label.text = "ARMORY // LOCK"
		title_tagline_label.text = "Pick the weapon for this purge run. The second rack stays sealed for alpha."
		title_status_label.text = "Arc Cutter climbs harder. Blaster keeps lanes clean."
		match _current_choice_target:
			STARTER_BLADE:
				title_loadout_label.text = "Arc Cutter primed. Best for rebound, rise, and close pressure."
			STARTER_GUN:
				title_loadout_label.text = "Dock Blaster primed. Two shells, strong recoil, safer approach."
			_:
				title_loadout_label.text = "Move into a lit rack. The dock sprite marks the starter lock."
		return

	match _front_mode:
		FRONT_CUSTOMIZE:
			var skin_id: String = SKIN_ORDER[_skin_index]
			front_mode_label.text = "DOSSIER // SHELL BAY"
			title_tagline_label.text = "STAGE THE HUNTER FRAME"
			title_status_label.text = String(SKIN_META[skin_id]["subtitle"])
			title_loadout_label.text = "FIELD NOTE // %s staged with %s live." % [String(SKIN_META[skin_id]["title"]), _get_weapon_display_name_for(_preview_weapon_mode)]
		FRONT_SETTINGS:
			var row: Dictionary = SETTING_ROWS[_settings_index]
			front_mode_label.text = "SYSTEM BUS // LIVE"
			title_tagline_label.text = "KEEP THE GLASS CLEAN"
			title_status_label.text = "%s / %s" % [_get_settings_category(row), _get_setting_row_help(row)]
			if String(row["type"]) == "setting":
				title_loadout_label.text = "FIELD NOTE // %s = %s" % [String(row["label"]), _format_setting_value(String(row["id"]), _settings_draft.get(String(row["id"])))]
			else:
				title_loadout_label.text = "FIELD NOTE // %s bound to %s." % [String(row["label"]), _get_binding_display(String(row["action"]))]
		_:
			var entries := _get_visible_menu_entries()
			var selected_entry: Dictionary = entries[min(_menu_index, entries.size() - 1)]
			var skin_title := String(SKIN_META[_get_selected_skin_id()]["title"])
			var selected_id := String(selected_entry["id"])
			var hive_cleansed := int(profile_store.call("get_record", "hive_regions_cleansed")) > 0 if profile_store != null else false
			var skyline_cleansed := int(profile_store.call("get_record", "skyline_regions_cleansed")) > 0 if profile_store != null else false
			var alpha_clears := int(profile_store.call("get_record", "alpha_demo_clears")) if profile_store != null else 0
			match selected_id:
				"start":
					front_mode_label.text = "WINDOW FEED // LIVE"
					if alpha_clears > 0 or skyline_cleansed:
						title_tagline_label.text = "PLANETARY PURGE EXPOSED"
						title_status_label.text = "Hive Shaft and Sunset Ruin Skyline are down. Foundry, Transit, Armory, and the Core remain infested."
						title_loadout_label.text = "FIELD NOTE // %s shell staged. The next purge should push beyond the skyline." % skin_title
					elif hive_cleansed:
						title_tagline_label.text = "SKYLINE ROUTE EXPOSED"
						title_status_label.text = "Hive Shaft is cleansed. Push east into the ruin bridges and kill the next apex."
						title_loadout_label.text = "FIELD NOTE // First purge proven. The surface route is finally live."
					else:
						title_tagline_label.text = "OPEN EXTERMINATION LICENSE"
						title_status_label.text = "Khepri-9 is still taking cold drop claims. Start with Hive Shaft and cut the planet open from the wound."
						title_loadout_label.text = "FIELD NOTE // %s shell staged. Arc Cutter climbs hard. Blaster controls space." % skin_title
				"customize":
					front_mode_label.text = "DOSSIER // HUNTER FRAME"
					title_tagline_label.text = "SHELL READOUT READY"
					title_status_label.text = "Stage the silhouette before the drop. The hunter should read before the weapon flash does."
					title_loadout_label.text = "FIELD NOTE // %s shell staged on the live dock glass." % skin_title
				"settings":
					front_mode_label.text = "SYSTEM BUS // CALIBRATE"
					title_tagline_label.text = "KEEP THE BOARD MEAN"
					title_status_label.text = "Audio, prompts, and scale should read like a command console, not a clean dashboard."
					title_loadout_label.text = "FIELD NOTE // %s" % String(selected_entry["subtitle"])
				"quit":
					front_mode_label.text = "POWER CUT // CONFIRM"
					title_tagline_label.text = "DROP THE BOARD COLD"
					title_status_label.text = "Kill the feed and leave sanctuary orbit."
					title_loadout_label.text = "FIELD NOTE // The planet stays alive while you are gone."
				_:
					front_mode_label.text = "SANCTUARY // HOLD"
					title_tagline_label.text = "OPEN EXTERMINATION LICENSE"
					title_status_label.text = String(selected_entry["subtitle"])
					title_loadout_label.text = "FIELD NOTE // %s shell staged." % skin_title


func _refresh_settings_console() -> void:
	if settings_section_label == null or settings_summary_label == null:
		return
	var row: Dictionary = SETTING_ROWS[_settings_index]
	settings_section_label.text = _get_settings_category(row)
	if String(row["type"]) == "setting":
		settings_summary_label.text = "%s\nCurrent %s" % [_get_setting_row_help(row), _format_setting_value(String(row["id"]), _settings_draft.get(String(row["id"])))]
	else:
		settings_summary_label.text = "%s\nCurrent %s" % [_get_setting_row_help(row), _get_binding_display(String(row["action"]))]


func _initialize_region_states() -> void:
	_region_states = {
		REGION_HIVE: REGION_STATE_ACTIVE,
		REGION_SKYLINE: REGION_STATE_LOCKED,
		REGION_FOUNDRY: REGION_STATE_LOCKED,
		REGION_TRANSIT: REGION_STATE_LOCKED,
		REGION_ARMORY: REGION_STATE_LOCKED,
		REGION_CORE: REGION_STATE_LOCKED,
	}
	_region_anchor_totals = {
		REGION_HIVE: HIVE_ANCHOR_DATA.size(),
		REGION_SKYLINE: SKYLINE_ANCHOR_DATA.size(),
		REGION_FOUNDRY: 0,
		REGION_TRANSIT: 0,
		REGION_ARMORY: 0,
		REGION_CORE: 0,
	}
	_region_anchor_cleared = {}
	for region_id_variant in _region_anchor_totals.keys():
		_region_anchor_cleared[String(region_id_variant)] = 0


func _get_region_state(region_id: String) -> String:
	return String(_region_states.get(region_id, REGION_STATE_LOCKED))


func _set_region_state(region_id: String, state: String) -> void:
	_region_states[region_id] = state


func _get_region_anchor_data(region_id: String) -> Array:
	match region_id:
		REGION_HIVE:
			return HIVE_ANCHOR_DATA
		REGION_SKYLINE:
			return SKYLINE_ANCHOR_DATA
		_:
			return []


func _get_region_display_name(region_id: String) -> String:
	match region_id:
		REGION_HIVE:
			return "Hive Shaft"
		REGION_SKYLINE:
			return "Sunset Ruin Skyline"
		REGION_FOUNDRY:
			return "Overgrown Foundry"
		REGION_TRANSIT:
			return "Flooded Transit"
		REGION_ARMORY:
			return "Royal Armory"
		REGION_CORE:
			return "Queen's Core"
		_:
			return "Unknown Region"


func _get_region_anchor_remaining(region_id: String) -> int:
	return maxi(0, int(_region_anchor_totals.get(region_id, 0)) - int(_region_anchor_cleared.get(region_id, 0)))


func _is_region_boss_unlocked(region_id: String) -> bool:
	return _get_region_state(region_id) == REGION_STATE_ACTIVE and _get_region_anchor_remaining(region_id) <= 0


func _persist_region_cleansed_record(region_id: String) -> void:
	if profile_store == null:
		return
	match region_id:
		REGION_HIVE:
			profile_store.call("set_record_max", "hive_regions_cleansed", 1)
		REGION_SKYLINE:
			profile_store.call("set_record_max", "skyline_regions_cleansed", 1)
		_:
			return
	profile_store.call("save_profile")


func _spawn_region_anchors(region_id: String) -> void:
	for anchor_data_variant in _get_region_anchor_data(region_id):
		var anchor_data: Dictionary = anchor_data_variant
		var anchor := INFESTATION_ANCHOR_SCENE.instantiate()
		enemies.add_child(anchor)
		var config := anchor_data.duplicate(true)
		config["region_id"] = region_id
		anchor.call("configure", config)
		anchor.connect("destroyed", Callable(self, "_on_infestation_anchor_destroyed"))
		_total_threats += 1


func _on_infestation_anchor_destroyed(region_id: String, _anchor_id: String, hit_kind: String) -> void:
	if _state != STATE_PLAYING:
		return
	_region_anchor_cleared[region_id] = int(_region_anchor_cleared.get(region_id, 0)) + 1
	_threats_cleared += 1
	_run_bug_kills += 1
	if is_instance_valid(_player):
		var reward := THREAT_FUEL_REWARD + (6.0 if hit_kind == "blade" else 2.0)
		_player.call("apply_refill", reward)
	if hit_kind == "blade":
		_push_combo(5, "Anchor core cleaved.")
	else:
		_push_combo(4, "Anchor core shattered.")
	var remaining := _get_region_anchor_remaining(region_id)
	_set_message(BountyFeed.get_region_anchor_message(_get_region_display_name(region_id), remaining))
	if remaining <= 0:
		_unlock_region_boss(region_id)
	_update_hud()


func _unlock_region_boss(region_id: String) -> void:
	if region_id == REGION_HIVE:
		if _tower_transfer_goal != null and is_instance_valid(_tower_transfer_goal):
			_tower_transfer_goal.call("set_active", true)
	elif region_id == REGION_SKYLINE:
		if _skyline_boss_goal != null and is_instance_valid(_skyline_boss_goal):
			_skyline_boss_goal.call("set_active", true)
	_set_message(BountyFeed.get_region_unlock_message(_get_region_display_name(region_id)))


func _mark_region_cleansed(region_id: String) -> void:
	_set_region_state(region_id, REGION_STATE_CLEANSED)
	_persist_region_cleansed_record(region_id)
	if region_id == REGION_HIVE:
		_set_region_state(REGION_SKYLINE, REGION_STATE_ACTIVE)


func _disable_runtime_triggers() -> void:
	if _tower_transfer_goal != null and is_instance_valid(_tower_transfer_goal):
		_tower_transfer_goal.call("set_active", false)
	if _cave_exit_goal != null and is_instance_valid(_cave_exit_goal):
		_cave_exit_goal.call("set_active", false)
	if _skyline_boss_goal != null and is_instance_valid(_skyline_boss_goal):
		_skyline_boss_goal.call("set_active", false)
	if _cave_arena != null and is_instance_valid(_cave_arena):
		_cave_arena.call("set_boss_trigger_enabled", false)
	if _weapon_salvage != null and is_instance_valid(_weapon_salvage):
		_weapon_salvage.monitoring = false


func _clear_runtime_nodes(parent: Node) -> void:
	for child in parent.get_children():
		child.queue_free()


func _build_intro_dock() -> void:
	var dock_platform := PLATFORM_SCENE.instantiate()
	platforms.add_child(dock_platform)
	dock_platform.call(
		"configure",
		{
			"kind": "stable",
			"pos": Vector2(40.0, _get_intro_landing_point().y + 6.0),
			"size": Vector2(880.0, 26.0),
			"draw_visual": false,
		}
	)
	dock_platform.connect("activated", Callable(self, "_on_platform_activated"))


func _build_tower() -> void:
	for platform_data in PLATFORM_DATA:
		var platform := PLATFORM_SCENE.instantiate()
		platforms.add_child(platform)
		platform.call("configure", platform_data)
		platform.connect("activated", Callable(self, "_on_platform_activated"))

	_tower_transfer_goal = GOAL_SCENE.instantiate()
	goal_anchor.add_child(_tower_transfer_goal)
	_tower_transfer_goal.global_position = CAVE_TRANSFER_GOAL_POSITION
	_tower_transfer_goal.call("set_active", false)
	_tower_transfer_goal.connect("reached", Callable(self, "_on_tower_transfer_goal_reached"))


func _build_cave_slice() -> void:
	_cave_arena = CAVE_ARENA_SCENE.instantiate()
	goal_anchor.add_child(_cave_arena)
	_cave_arena.connect("boss_trigger_entered", Callable(self, "_on_cave_boss_trigger_entered"))
	_cave_arena.call("set_gate_states", false, true)

	for platform_data in CAVE_PLATFORM_DATA:
		var platform := PLATFORM_SCENE.instantiate()
		platforms.add_child(platform)
		platform.call("configure", platform_data)
		platform.connect("activated", Callable(self, "_on_platform_activated"))

	_left_gate_platform = PLATFORM_SCENE.instantiate()
	platforms.add_child(_left_gate_platform)
	_left_gate_platform.call("configure", CAVE_LEFT_GATE_DATA)
	_set_gate_platform_active(_left_gate_platform, false)

	_right_gate_platform = PLATFORM_SCENE.instantiate()
	platforms.add_child(_right_gate_platform)
	_right_gate_platform.call("configure", CAVE_RIGHT_GATE_DATA)
	_set_gate_platform_active(_right_gate_platform, true)

	_cave_exit_goal = GOAL_SCENE.instantiate()
	goal_anchor.add_child(_cave_exit_goal)
	_cave_exit_goal.global_position = _cave_arena.call("get_exit_position")
	_cave_exit_goal.call("set_active", false)
	_cave_exit_goal.connect("reached", Callable(self, "_on_cave_exit_reached"))


func _build_mountain_slice() -> void:
	_cave_arena = null
	_cave_exit_goal = null
	for platform_data in MOUNTAIN_PLATFORM_DATA:
		var platform := PLATFORM_SCENE.instantiate()
		platforms.add_child(platform)
		platform.call("configure", platform_data)
		platform.connect("activated", Callable(self, "_on_platform_activated"))

	var skyline_floor := PLATFORM_SCENE.instantiate()
	platforms.add_child(skyline_floor)
	skyline_floor.call(
		"configure",
		{
			"kind": "stable",
			"pos": Vector2(SKYLINE_ARENA_BOUNDS.position.x, SKYLINE_FLOOR_Y + 18.0),
			"size": Vector2(SKYLINE_ARENA_BOUNDS.size.x, 34.0),
			"draw_visual": false,
		}
	)

	for skyline_platform_data in [
		{"kind": "stable", "archetype": "recovery", "pos": Vector2(1262.0, 184.0), "size": Vector2(116.0, 18.0)},
		{"kind": "stable", "archetype": "relay", "pos": Vector2(1442.0, 166.0), "size": Vector2(98.0, 18.0)},
	]:
		var skyline_platform := PLATFORM_SCENE.instantiate()
		platforms.add_child(skyline_platform)
		skyline_platform.call("configure", skyline_platform_data)
		skyline_platform.connect("activated", Callable(self, "_on_platform_activated"))

	_left_gate_platform = PLATFORM_SCENE.instantiate()
	platforms.add_child(_left_gate_platform)
	_left_gate_platform.call(
		"configure",
		{
			"kind": "stable",
			"archetype": "gate",
			"pos": Vector2(SKYLINE_ARENA_BOUNDS.position.x - 18.0, SKYLINE_ARENA_BOUNDS.position.y - 12.0),
			"size": Vector2(18.0, SKYLINE_ARENA_BOUNDS.size.y + 44.0),
			"draw_visual": false,
		}
	)
	_set_gate_platform_active(_left_gate_platform, false)

	_right_gate_platform = PLATFORM_SCENE.instantiate()
	platforms.add_child(_right_gate_platform)
	_right_gate_platform.call(
		"configure",
		{
			"kind": "stable",
			"archetype": "gate",
			"pos": Vector2(SKYLINE_ARENA_BOUNDS.end.x, SKYLINE_ARENA_BOUNDS.position.y - 12.0),
			"size": Vector2(18.0, SKYLINE_ARENA_BOUNDS.size.y + 44.0),
			"draw_visual": false,
		}
	)
	_set_gate_platform_active(_right_gate_platform, false)

	_skyline_boss_goal = GOAL_SCENE.instantiate()
	goal_anchor.add_child(_skyline_boss_goal)
	_skyline_boss_goal.global_position = SKYLINE_BOSS_GOAL_POSITION
	_skyline_boss_goal.call("set_active", false)
	_skyline_boss_goal.connect("reached", Callable(self, "_on_skyline_boss_goal_reached"))


func _set_gate_platform_active(platform: StaticBody2D, active: bool) -> void:
	if platform == null or not is_instance_valid(platform):
		return
	platform.visible = active
	platform.collision_layer = 2 if active else 0
	var gate_shape := platform.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if gate_shape != null:
		gate_shape.disabled = not active


func _spawn_hazards() -> void:
	_total_threats += MITE_DATA.size() + CRAWLER_DATA.size() + POD_DATA.size() + MINE_POSITIONS.size()

	for mite_data in MITE_DATA:
		var mite := ENEMY_SCENE.instantiate()
		enemies.add_child(mite)
		mite.call("configure", mite_data)
		mite.connect("destroyed", Callable(self, "_on_hazard_destroyed"))

	for crawler_data in CRAWLER_DATA:
		var crawler := SHELLBACK_SCENE.instantiate()
		enemies.add_child(crawler)
		crawler.call("configure", crawler_data)
		crawler.connect("destroyed", Callable(self, "_on_hazard_destroyed"))

	for pod_data in POD_DATA:
		var pod := BROOD_POD_SCENE.instantiate()
		enemies.add_child(pod)
		var config: Dictionary = pod_data.duplicate(true)
		config["spawn_scene"] = ENEMY_SCENE
		config["spawn_parent"] = enemies
		config["mite_config"] = {
			"kind": "mite",
			"travel": 42.0,
			"speed": 126.0,
			"hover": 6.0,
			"health": 1,
			"points": 70,
		}
		pod.call("configure", config)
		pod.connect("destroyed", Callable(self, "_on_hazard_destroyed"))
		pod.connect("spawned_mite", Callable(self, "_on_pod_spawned_mite"))

	for mine_position in MINE_POSITIONS:
		var mine := MINE_SCENE.instantiate()
		enemies.add_child(mine)
		mine.global_position = mine_position
		mine.connect("destroyed", Callable(self, "_on_hazard_destroyed"))


func _spawn_mountain_hazards() -> void:
	_total_threats += MOUNTAIN_MITE_DATA.size() + MOUNTAIN_CRAWLER_DATA.size() + MOUNTAIN_POD_DATA.size() + MOUNTAIN_MINE_POSITIONS.size()

	for mite_data in MOUNTAIN_MITE_DATA:
		var mite := ENEMY_SCENE.instantiate()
		enemies.add_child(mite)
		mite.call("configure", mite_data)
		mite.connect("destroyed", Callable(self, "_on_hazard_destroyed"))

	for crawler_data in MOUNTAIN_CRAWLER_DATA:
		var crawler := SHELLBACK_SCENE.instantiate()
		enemies.add_child(crawler)
		crawler.call("configure", crawler_data)
		crawler.connect("destroyed", Callable(self, "_on_hazard_destroyed"))

	for pod_data in MOUNTAIN_POD_DATA:
		var pod := BROOD_POD_SCENE.instantiate()
		enemies.add_child(pod)
		var config: Dictionary = pod_data.duplicate(true)
		config["spawn_scene"] = ENEMY_SCENE
		config["spawn_parent"] = enemies
		config["mite_config"] = {
			"kind": "mite",
			"travel": 38.0,
			"speed": 134.0,
			"hover": 7.0,
			"health": 1,
			"points": 80,
		}
		pod.call("configure", config)
		pod.connect("destroyed", Callable(self, "_on_hazard_destroyed"))
		pod.connect("spawned_mite", Callable(self, "_on_pod_spawned_mite"))

	for mine_position in MOUNTAIN_MINE_POSITIONS:
		var mine := MINE_SCENE.instantiate()
		enemies.add_child(mine)
		mine.global_position = mine_position
		mine.connect("destroyed", Callable(self, "_on_hazard_destroyed"))


func _update_play_state(delta: float) -> void:
	var player_position: Vector2 = _player.global_position
	_highest_player_y = minf(_highest_player_y, player_position.y)
	_best_altitude = maxi(_best_altitude, _get_altitude_meters())

	if _combo_timer > 0.0:
		_combo_timer = maxf(_combo_timer - delta, 0.0)
		if _combo_timer <= 0.0:
			_combo = 0
			_flow_reward_tier = 0

	if _kill_floor_active:
		var target_floor := _highest_player_y + KILL_FLOOR_OFFSET
		_kill_floor_y = move_toward(_kill_floor_y, target_floor, KILL_FLOOR_RISE_SPEED * delta)
		_update_kill_floor_visual()
		if player_position.y > _kill_floor_y:
			_player.call("force_fail")
			return

	_apply_run_camera(delta)
	_update_hud()


func _update_kill_floor_visual() -> void:
	if _kill_floor_line == null:
		return

	_kill_floor_line.points = PackedVector2Array(
		[
			Vector2(-80.0, _kill_floor_y),
			Vector2(WORLD_SIZE.x + 80.0, _kill_floor_y),
		]
	)
	if backdrop != null and backdrop.has_method("set_kill_floor"):
		backdrop.call("set_kill_floor", _kill_floor_y)


func _get_run_camera_profile() -> Dictionary:
	if _state == STATE_TRANSFER:
		if _transfer_kind == TRANSFER_KIND_CAVE:
			return CAVE_CAMERA_PROFILE
		if _transfer_kind == TRANSFER_KIND_MOUNTAIN:
			return MOUNTAIN_CAMERA_PROFILE
	if _route_phase == PHASE_BOSS:
		return BOSS_CAMERA_PROFILE
	if _route_phase == PHASE_REWARD:
		return REWARD_CAMERA_PROFILE
	if _route_phase == PHASE_MOUNTAIN:
		return MOUNTAIN_CAMERA_PROFILE
	if _route_phase == PHASE_CAVE:
		return CAVE_CAMERA_PROFILE
	if not is_instance_valid(_player):
		return DEFAULT_TOWER_CAMERA_PROFILE

	var player_position: Vector2 = _player.global_position
	for zone in TOWER_CAMERA_ZONES:
		var zone_rect: Rect2 = zone["rect"]
		if zone_rect.has_point(player_position):
			return zone
	return DEFAULT_TOWER_CAMERA_PROFILE


func _apply_run_camera(delta: float) -> void:
	if _player_camera == null:
		return

	var profile := _get_run_camera_profile()
	var blend := clampf(delta * RUN_CAMERA_BLEND, 0.0, 1.0)
	var target_zoom_value := float(profile.get("zoom", DEFAULT_TOWER_CAMERA_PROFILE["zoom"]))
	var target_y := float(profile.get("camera_y", DEFAULT_TOWER_CAMERA_PROFILE["camera_y"]))
	_player_camera.zoom = _player_camera.zoom.lerp(Vector2(target_zoom_value, target_zoom_value), blend)
	_player_camera.position = _player_camera.position.lerp(Vector2(0.0, target_y), blend)


func _get_altitude_meters() -> int:
	return maxi(0, int(round((_get_spawn_point().y - _highest_player_y) / PIXELS_PER_METER)))


func _get_shaft_sector_name() -> String:
	if not is_instance_valid(_player):
		return "DOCK RISE"

	var y: float = _player.global_position.y
	if y > 2460.0:
		return "DOCK RISE"
	if y > 1840.0:
		return "SWITCHBACK SPAN"
	if y > 1120.0:
		return "BROOD RAILS"
	if y > 500.0:
		return "BREACH LEDGES"
	return "TRANSFER SHELF"


func _push_combo(amount: int, text: String) -> void:
	var previous_tier := _flow_reward_tier
	_combo = maxi(0, _combo + amount)
	_combo_timer = COMBO_TIMEOUT
	_flow_reward_tier = int(_combo / FLOW_REWARD_STEP)
	if _flow_reward_tier > previous_tier and is_instance_valid(_player):
		var fuel_bonus := FLOW_REWARD_FUEL * float(_flow_reward_tier - previous_tier)
		_player.call("apply_refill", fuel_bonus)
		text = "%s Flow bonus +%d fuel." % [text, int(fuel_bonus)] if text != "" else "Flow bonus +%d fuel." % int(fuel_bonus)
	if text != "":
		_set_message(text)
	_update_hud()


func _update_hud() -> void:
	timer_label.text = "%03dm" % _get_current_altitude_meters()
	if _state == STATE_TRANSFER:
		objective_label.text = "TRANSFER // brood breach" if _transfer_kind == TRANSFER_KIND_CAVE else "TRANSFER // skyline route"
		stats_label.text = "CHAIN x%02d   VERIFIED %d/%d" % [_combo, _threats_cleared, _total_threats]
	elif _route_phase == PHASE_BOSS:
		objective_label.text = "APEX // %s" % _get_active_boss_name()
		if _boss_meter != null:
			stats_label.text = "CHAIN x%02d   CORE %d/%d" % [_combo, int(round(_boss_meter.value)), int(round(_boss_meter.max_value))]
		else:
			stats_label.text = "CHAIN x%02d   CORE ACTIVE" % _combo
	elif _route_phase == PHASE_REWARD:
		var upgrade_level := int(_player.call("get_weapon_upgrade_level", _starter_weapon)) if is_instance_valid(_player) else 0
		objective_label.text = "HIVE SHAFT // cleansed"
		stats_label.text = "CHAIN x%02d   %s +%d" % [_combo, _get_weapon_display_name_for(_starter_weapon), max(1, upgrade_level)]
	elif _route_phase == PHASE_CAVE:
		objective_label.text = "BROOD CHAMBER // apex ahead"
		stats_label.text = "CHAIN x%02d   FLOOR CUT" % _combo
	elif _route_phase == PHASE_MOUNTAIN:
		var skyline_total := int(_region_anchor_totals.get(REGION_SKYLINE, 0))
		var skyline_cleared := int(_region_anchor_cleared.get(REGION_SKYLINE, 0))
		objective_label.text = "SUNSET RUIN // apex exposed" if _is_region_boss_unlocked(REGION_SKYLINE) else "SUNSET RUIN // purge anchors"
		stats_label.text = "CHAIN x%02d   ANCHORS %d/%d" % [_combo, skyline_cleared, skyline_total]
	else:
		var hive_total := int(_region_anchor_totals.get(REGION_HIVE, 0))
		var hive_cleared := int(_region_anchor_cleared.get(REGION_HIVE, 0))
		objective_label.text = "%s // purge anchors" % _get_shaft_sector_name()
		stats_label.text = "CHAIN x%02d   ANCHORS %d/%d" % [_combo, hive_cleared, hive_total]
	_update_weapon_hud()
	_update_prompt_dock_visibility()


func _set_message(text: String) -> void:
	message_label.text = text


func _commit_run_records(full_clear: bool) -> void:
	if profile_store == null or _run_records_committed:
		return
	profile_store.call("set_record_max", "best_altitude_m", _best_altitude)
	if _run_bug_kills > 0:
		profile_store.call("increment_record", "bugs_liquidated", _run_bug_kills)
	if _run_rival_clears > 0:
		profile_store.call("increment_record", "rival_clears", _run_rival_clears)
	if full_clear:
		profile_store.call("mark_full_clear")
	profile_store.call("save_profile")
	_run_records_committed = true


func _on_player_shot_fired(origin: Vector2, shot_data: Dictionary) -> void:
	if _state != STATE_PLAYING:
		return

	var direction: Vector2 = shot_data.get("direction", Vector2.RIGHT)
	var spread: PackedFloat32Array = shot_data.get("spread", PackedFloat32Array([0.0]))
	var fx_profile: Dictionary = shot_data.get("fx_profile", {})
	for angle in spread:
		var pellet_direction := direction.rotated(float(angle))
		var config := {
			"speed": float(shot_data.get("speed", 720.0)) - absf(float(angle)) * 36.0,
			"damage": int(shot_data.get("damage", 1)),
			"lifetime": float(shot_data.get("lifetime", 0.34)),
			"hit_kind": String(shot_data.get("hit_kind", "blast")),
			"radius": float(shot_data.get("radius", 4.8)),
			"trail_length": float(shot_data.get("trail_length", 14.0)),
			"trail_width": float(shot_data.get("trail_width", 3.0)),
			"max_hits": 1,
			"core_color": fx_profile.get("projectile_core"),
			"trail_color": fx_profile.get("projectile_trail"),
			"glow_color": fx_profile.get("projectile_glow"),
		}
		_spawn_player_bullet(origin + pellet_direction * 2.0, pellet_direction, config)


func _on_player_slash_fired(origin: Vector2, attack_data: Dictionary) -> void:
	if _state != STATE_PLAYING:
		return

	var facing_dir := int(attack_data.get("facing", 1))
	var airborne := bool(attack_data.get("airborne", false))
	var slash_fx := SLASH_FX_SCENE.instantiate()
	projectiles.add_child(slash_fx)
	slash_fx.call(
		"setup",
		origin + attack_data.get("fx_offset", Vector2.ZERO),
		facing_dir,
		String(attack_data.get("fx_tag", "air_slash" if airborne else "ground_slash"))
	)

	var slash := SLASH_SCENE.instantiate()
	projectiles.add_child(slash)
	var slash_config := attack_data.duplicate(true)
	slash_config["source"] = _player
	slash.call(
		"setup",
		origin,
		facing_dir,
		airborne,
		slash_config
	)


func _on_player_fuel_changed(current: float, maximum: float) -> void:
	fuel_bar.value = clampf((current / maximum) * 100.0, 0.0, 100.0)


func _on_player_health_changed(current: int, maximum: int) -> void:
	health_bar.value = clampf((float(current) / float(maximum)) * 100.0, 0.0, 100.0)


func _on_player_damaged(_current: int, _maximum: int) -> void:
	_combo = 0
	_combo_timer = 0.0
	_flow_reward_tier = 0
	_set_message("Plating hit. Keep the purge line alive.")
	_update_hud()


func _on_player_weapon_mode_changed(mode: String, show_message: bool = true) -> void:
	_weapon_mode = mode
	if show_message and _state == STATE_PLAYING:
		_set_message(_get_weapon_ready_message())
	_update_hud()


func _on_player_movement_event(kind: String) -> void:
	if _state != STATE_PLAYING:
		return

	match kind:
		"wall_kick":
			_player.call("apply_refill", WALL_KICK_FUEL_REWARD)
			_push_combo(2, "Wall kick chained.")
		"wall_burst":
			_player.call("apply_refill", WALL_BURST_FUEL_REWARD)
			_push_combo(3, "Wall burst snapped.")
		"burst_chain":
			_player.call("apply_refill", BURST_CHAIN_FUEL_REWARD)
			_push_combo(2, "Burst link held.")
		"burst_save":
			_player.call("apply_refill", BURST_SAVE_FUEL_REWARD)
			_push_combo(2, "Clutch burst.")
		"burst":
			_push_combo(1, "Burst save.")
		"air_jump":
			_push_combo(1, "Keep the line moving.")


func _on_platform_activated(kind: String) -> void:
	if _state != STATE_PLAYING:
		return

	match kind:
		"spring":
			_push_combo(2, "Spring line.")
		"fuel":
			_push_combo(1, "Burst tank topped off.")
		"crumble":
			_push_combo(1, "Keep moving.")


func _on_pod_spawned_mite(mite: Area2D) -> void:
	if mite == null or not is_instance_valid(mite):
		return
	mite.connect("destroyed", Callable(self, "_on_hazard_destroyed"))
	_total_threats += 1
	_update_hud()


func _on_hazard_destroyed(_points: int, hit_kind: String = "gun") -> void:
	if _state != STATE_PLAYING:
		return

	_threats_cleared += 1
	_run_bug_kills += 1
	if is_instance_valid(_player):
		var reward := THREAT_FUEL_REWARD + (4.0 if hit_kind == "blade" else 0.0)
		_player.call("apply_refill", reward)
	if hit_kind == "blade":
		_push_combo(4, "Threat cleaved.")
	else:
		_push_combo(3, "Threat shredded.")


func _on_tower_transfer_goal_reached() -> void:
	if _state != STATE_PLAYING or _route_phase != PHASE_SHAFT:
		return
	_start_cave_transfer()


func _on_cave_boss_trigger_entered(_body: Node) -> void:
	if _state != STATE_PLAYING or _route_phase not in [PHASE_CAVE, PHASE_SHAFT] or _boss_intro_running:
		return
	_boss_intro_running = true
	_start_region_boss(HIVE_BOSS_PROFILE)


func _on_skyline_boss_goal_reached() -> void:
	if _state != STATE_PLAYING or _route_phase != PHASE_MOUNTAIN or _boss_intro_running:
		return
	_boss_intro_running = true
	_start_region_boss(SKYLINE_BOSS_PROFILE)


func _start_region_boss(profile: Dictionary) -> void:
	if _rival_boss != null and is_instance_valid(_rival_boss):
		_boss_intro_running = false
		return
	var region_id := String(profile.get("region_id", REGION_HIVE))
	if region_id == REGION_HIVE and (_cave_arena == null or not is_instance_valid(_cave_arena)):
		_boss_intro_running = false
		return

	var arena_bounds: Rect2 = SKYLINE_ARENA_BOUNDS
	var floor_y := SKYLINE_FLOOR_Y
	var boss_spawn := SKYLINE_BOSS_SPAWN_POSITION
	if region_id == REGION_HIVE:
		arena_bounds = _cave_arena.call("get_boss_bounds")
		floor_y = float(_cave_arena.call("get_floor_y"))
		boss_spawn = _cave_arena.call("get_boss_spawn_position")

	_active_boss_region_id = region_id
	_route_phase = PHASE_BOSS
	_kill_floor_active = false
	_set_kill_floor_visible(false)
	_set_gate_platform_active(_left_gate_platform, true)
	_set_gate_platform_active(_right_gate_platform, true)
	if region_id == REGION_HIVE and _cave_arena != null and is_instance_valid(_cave_arena):
		_cave_arena.call("set_gate_states", true, true)
		_cave_arena.call("set_boss_trigger_enabled", false)
	if region_id == REGION_SKYLINE and _skyline_boss_goal != null and is_instance_valid(_skyline_boss_goal):
		_skyline_boss_goal.call("set_active", false)
	_clear_runtime_nodes(projectiles)
	_player.call("set_controls_enabled", false)

	_rival_boss = RIVAL_BOSS_SCENE.instantiate()
	enemies.add_child(_rival_boss)
	_rival_boss.call(
		"configure",
		{
			"weapon_mode": String(profile.get("weapon_mode", STARTER_BLADE)),
			"player": _player,
			"projectile_parent": projectiles,
			"arena_bounds": arena_bounds,
			"floor_y": floor_y,
			"pos": boss_spawn,
			"health": int(profile.get("health", 12)),
			"boss_name": String(profile.get("boss_name", "APEX")),
			"guard_label": String(profile.get("guard_label", "GUARD SEALED")),
			"broken_label": String(profile.get("broken_label", "CORE BROKEN")),
			"burst_telegraph_label": String(profile.get("burst_telegraph_label", "BURST")),
			"fan_telegraph_label": String(profile.get("fan_telegraph_label", "FAN")),
			"dash_telegraph_label": String(profile.get("dash_telegraph_label", "DASH")),
			"cleave_telegraph_label": String(profile.get("cleave_telegraph_label", "CLEAVE")),
			"burst_vulnerable_label": String(profile.get("burst_vulnerable_label", "CORE EXPOSED")),
			"fan_vulnerable_label": String(profile.get("fan_vulnerable_label", "CORE EXPOSED")),
			"dash_vulnerable_label": String(profile.get("dash_vulnerable_label", "CORE EXPOSED")),
			"cleave_vulnerable_label": String(profile.get("cleave_vulnerable_label", "CORE EXPOSED")),
		}
	)
	_rival_boss.connect("health_changed", Callable(self, "_on_rival_boss_health_changed"))
	_rival_boss.connect("vulnerability_changed", Callable(self, "_on_rival_boss_vulnerability_changed"))
	_rival_boss.connect("telegraph_started", Callable(self, "_on_rival_boss_telegraph_started"))
	_rival_boss.connect("defeated", Callable(self, "_on_rival_boss_defeated"))

	var player_facing := 1 if _rival_boss.global_position.x > _player.global_position.x else -1
	_player.call("set_facing_direction", player_facing)
	_set_boss_ui_visible(false)
	_boss_name_label.text = String(profile.get("boss_name", "APEX"))
	_boss_window_label.text = String(profile.get("guard_label", "GUARD SEALED"))
	_boss_meter.max_value = float(int(profile.get("health", 12)))
	_boss_meter.value = float(int(profile.get("health", 12)))
	_set_duel_dialogue_visible(true)
	_set_duel_dialogue(String(profile.get("boss_name", "APEX")), String(profile.get("intro_message", "Apex detected.")))
	_set_message(String(profile.get("intro_message", "Apex detected.")))
	_update_hud()
	await get_tree().create_timer(0.9).timeout
	if not _boss_intro_still_valid():
		return

	_player.call("set_facing_direction", player_facing)
	var queen_reply := "Then the shaft dies with you." if region_id == REGION_HIVE else "Then the skyline dies with you."
	_set_duel_dialogue("KILLER QUEEN", queen_reply)
	await get_tree().create_timer(0.85).timeout
	if not _boss_intro_still_valid():
		return

	_player.call("play_weapon_flourish", 0.62)
	_rival_boss.call("play_weapon_flourish", 0.62)
	await get_tree().create_timer(0.68).timeout
	if not _boss_intro_still_valid():
		return

	_set_duel_dialogue_visible(false)
	_set_boss_ui_visible(true)
	_player.call("set_controls_enabled", true)
	_rival_boss.call("begin_duel")
	_boss_intro_running = false
	_set_message(String(profile.get("start_message", "Apex live. Kill it clean.")))
	_update_hud()


func _boss_intro_still_valid() -> bool:
	if _state != STATE_PLAYING or _route_phase != PHASE_BOSS:
		_boss_intro_running = false
		return false
	if _rival_boss == null or not is_instance_valid(_rival_boss):
		_boss_intro_running = false
		return false
	return true


func _on_rival_boss_health_changed(current: int, maximum: int) -> void:
	if _boss_meter != null:
		_boss_meter.max_value = float(maximum)
		_boss_meter.value = float(current)


func _on_rival_boss_vulnerability_changed(active: bool, label: String) -> void:
	if _boss_window_label != null:
		_boss_window_label.text = label
	if _state == STATE_PLAYING and _route_phase == PHASE_BOSS and not _boss_intro_running:
		_set_message("Core exposed. Burn it now." if active else "Guard sealed. Wait for the next opening.")
	_update_hud()


func _on_rival_boss_telegraph_started(label: String) -> void:
	if _boss_window_label != null:
		_boss_window_label.text = label
	if _state == STATE_PLAYING and _route_phase == PHASE_BOSS and not _boss_intro_running:
		_set_message(label)
	_update_hud()


func _on_rival_boss_defeated(_drop_position: Vector2) -> void:
	if _state != STATE_PLAYING:
		return
	_boss_intro_running = false
	_run_rival_clears += 1
	_set_boss_ui_visible(false)
	_set_duel_dialogue_visible(false)
	if _active_boss_region_id == REGION_HIVE:
		_route_phase = PHASE_REWARD
		_mark_region_cleansed(REGION_HIVE)
		_set_gate_platform_active(_right_gate_platform, false)
		if _cave_arena != null and is_instance_valid(_cave_arena):
			_cave_arena.call("set_gate_states", true, false)
		if _cave_exit_goal != null and is_instance_valid(_cave_exit_goal):
			_cave_exit_goal.call("set_active", true)
		_player.call("upgrade_weapon", _starter_weapon)
		_set_message("%s %s" % [BountyFeed.get_region_cleansed_message(_get_region_display_name(REGION_HIVE)), BountyFeed.get_salvage_unlock_message(_starter_weapon)])
		_active_boss_region_id = ""
		_update_hud()
		return
	if _active_boss_region_id == REGION_SKYLINE:
		_mark_region_cleansed(REGION_SKYLINE)
		_active_boss_region_id = ""
		_complete_alpha_demo()
		return
	_active_boss_region_id = ""
	_update_hud()


func _spawn_weapon_salvage(drop_position: Vector2) -> void:
	_weapon_salvage = WEAPON_SALVAGE_SCENE.instantiate()
	pickups.add_child(_weapon_salvage)
	_weapon_salvage.call(
		"configure",
		{
			"weapon_mode": _get_rival_weapon_mode(),
			"pos": drop_position + Vector2(0.0, -14.0),
		}
	)
	_weapon_salvage.connect("collected", Callable(self, "_on_weapon_salvage_collected"))


func _on_weapon_salvage_collected(mode: String) -> void:
	_alternate_weapon_unlocked = true
	_player.call("set_swap_enabled", true)
	_player.call("set_weapon_mode", mode)
	if _cave_exit_goal != null and is_instance_valid(_cave_exit_goal):
		_cave_exit_goal.call("set_active", true)
	_route_phase = PHASE_REWARD
	_set_message(BountyFeed.get_salvage_unlock_message(mode))
	_update_hud()


func _on_cave_exit_reached() -> void:
	if _state != STATE_PLAYING or _get_region_state(REGION_HIVE) != REGION_STATE_CLEANSED:
		return
	_start_transfer_outro()


func _get_active_boss_profile() -> Dictionary:
	match _active_boss_region_id:
		REGION_HIVE:
			return HIVE_BOSS_PROFILE
		REGION_SKYLINE:
			return SKYLINE_BOSS_PROFILE
		_:
			return {}


func _get_active_boss_name() -> String:
	var boss_profile := _get_active_boss_profile()
	return String(boss_profile.get("boss_name", "APEX"))


func _complete_alpha_demo() -> void:
	_state = STATE_CLEARED
	_route_phase = PHASE_REWARD
	_best_altitude = maxi(_best_altitude, _get_altitude_meters())
	_player.call("set_controls_enabled", false)
	_player.set_physics_process(false)
	_commit_run_records(false)
	if profile_store != null:
		profile_store.call("increment_record", "alpha_demo_clears", 1)
		profile_store.call("save_profile")
	var receipt := BountyFeed.get_clear_receipt(_best_altitude, _run_bug_kills, _run_rival_clears, false)
	var promise_lines := PackedStringArray(BountyFeed.get_alpha_promise_lines())
	var receipt_body := "%s\n\n%s" % [String(receipt["body"]), "\n".join(promise_lines)]
	_show_receipt(String(receipt["title"]), receipt_body, String(receipt["footer"]))
	_set_message("Spire Matriarch dead. Sanctuary has the rest of the planet on glass now.")
	if _transfer_line != null:
		_transfer_line.visible = false
	await get_tree().create_timer(3.0).timeout
	if _state == STATE_CLEARED:
		if game_flow != null:
			game_flow.call("return_to_menu")
		else:
			_enter_title()


func _on_player_died() -> void:
	if _state != STATE_PLAYING:
		return

	_state = STATE_FAILED
	_combo = 0
	_combo_timer = 0.0
	_flow_reward_tier = 0
	_commit_run_records(false)
	var receipt := BountyFeed.get_failure_receipt()
	_show_receipt(String(receipt["title"]), String(receipt["body"]), String(receipt["footer"]))
	_set_message(BountyFeed.get_failure_message())
	_update_hud()
	await get_tree().create_timer(0.36).timeout
	if _state == STATE_FAILED:
		_reset_run()


func _get_current_altitude_meters() -> int:
	if not is_instance_valid(_player):
		return 0
	return maxi(0, int(round((_get_spawn_point().y - _player.global_position.y) / PIXELS_PER_METER)))


func _get_cave_distance_meters() -> int:
	if not is_instance_valid(_player):
		return 0
	return maxi(0, int(round((_player.global_position.y - TOP_CLEAR_Y) / PIXELS_PER_METER)))


func _get_floor_lead_meters() -> int:
	if not is_instance_valid(_player):
		return 0
	return maxi(0, int(round((_kill_floor_y - _player.global_position.y) / PIXELS_PER_METER)))


func _spawn_player_bullet(origin: Vector2, direction: Vector2, config: Dictionary) -> void:
	var bullet := BULLET_SCENE.instantiate()
	projectiles.add_child(bullet)
	bullet.call("setup", origin, direction, config)


func _update_weapon_hud() -> void:
	if weapon_label != null:
		var label := _get_weapon_display_name()
		if is_instance_valid(_player):
			var upgrade_level := int(_player.call("get_weapon_upgrade_level", _weapon_mode))
			if upgrade_level > 0:
				label = "%s +%d" % [label, upgrade_level]
			if _weapon_mode == STARTER_GUN:
				if bool(_player.call("is_gun_reloading")):
					label = "%s // CHAMBER" % label
				else:
					label = "%s // %d/%d" % [label, int(_player.call("get_gun_shells")), int(_player.call("get_gun_shell_capacity"))]
			else:
				label = "%s // INPUT CUT" % label
		weapon_label.text = label
	if weapon_icon != null:
		weapon_icon.texture = _blade_icon_texture if _weapon_mode == STARTER_BLADE else _gun_icon_texture
	if swap_prompt != null:
		swap_prompt.visible = is_instance_valid(_player) and bool(_player.call("is_swap_enabled"))


func _set_boss_ui_visible(value: bool) -> void:
	if _boss_panel != null:
		_boss_panel.visible = value
	_update_prompt_dock_visibility()


func _set_duel_dialogue_visible(value: bool) -> void:
	if _duel_dialogue_panel != null:
		_duel_dialogue_panel.visible = value
	_update_prompt_dock_visibility()


func _show_receipt(title: String, body: String, hint: String) -> void:
	if _receipt_panel == null:
		return
	_receipt_title_label.text = title
	_receipt_body_label.text = body
	_receipt_hint_label.text = hint
	_receipt_panel.visible = true
	_update_prompt_dock_visibility()


func _hide_receipt() -> void:
	if _receipt_panel != null:
		_receipt_panel.visible = false
	_update_prompt_dock_visibility()


func _set_duel_dialogue(speaker: String, line: String) -> void:
	if _duel_speaker_label != null:
		_duel_speaker_label.text = speaker
	if _duel_line_label != null:
		_duel_line_label.text = line


func _get_rival_weapon_mode() -> String:
	return STARTER_GUN if _starter_weapon == STARTER_BLADE else STARTER_BLADE


func _get_rival_boss_name() -> String:
	return "APEX BLASTER SHELL" if _get_rival_weapon_mode() == STARTER_GUN else "APEX CUTTER SHELL"


func _get_salvage_unlock_message(mode: String) -> String:
	if mode == STARTER_GUN:
		return BountyFeed.get_salvage_unlock_message(mode)
	return BountyFeed.get_salvage_unlock_message(mode)


func _get_weapon_display_name() -> String:
	return _get_weapon_display_name_for(_weapon_mode)


func _get_weapon_display_name_for(mode: String) -> String:
	return "ARC CUTTER" if mode == STARTER_BLADE else "DOCK BLASTER"


func _get_weapon_ready_message() -> String:
	return "Arc Cutter logged. Close cuts still open routes faster than safe fire." if _weapon_mode == STARTER_BLADE else "Dock Blaster logged. Two-shell chamber. Land clean to refill."


func _ensure_weapon_art() -> void:
	if _blade_icon_texture != null and _gun_icon_texture != null and _blade_showcase_texture != null and _gun_showcase_texture != null:
		return
	_blade_icon_texture = ExportArt.get_weapon_icon(STARTER_BLADE)
	_gun_icon_texture = ExportArt.get_weapon_icon(STARTER_GUN)
	_blade_showcase_texture = ExportArt.get_weapon_showcase(STARTER_BLADE)
	_gun_showcase_texture = ExportArt.get_weapon_showcase(STARTER_GUN)
	if blade_art != null:
		blade_art.texture = _blade_showcase_texture
	if gun_art != null:
		gun_art.texture = _gun_showcase_texture


func _set_front_door_visible(value: bool) -> void:
	if front_door != null:
		front_door.visible = value


func _set_run_hud_visible(value: bool) -> void:
	if hud != null:
		hud.visible = value
	if not value:
		_hide_receipt()
	_update_prompt_dock_visibility()


func _update_prompt_dock_visibility() -> void:
	if prompt_dock == null:
		return
	var show_run_prompts := hud != null and hud.visible and _state == STATE_PLAYING and _route_phase != PHASE_BOSS and (_duel_dialogue_panel == null or not _duel_dialogue_panel.visible) and (_receipt_panel == null or not _receipt_panel.visible)
	prompt_dock.visible = show_run_prompts


func _set_intro_camera_active(value: bool) -> void:
	if intro_camera != null:
		intro_camera.enabled = value
		intro_camera.global_position = _get_intro_camera_point() if not value else _get_title_camera_point()
		intro_camera.zoom = TITLE_CAMERA_ZOOM if value else DROP_CAMERA_ZOOM
	if _player_camera != null:
		_player_camera.enabled = not value


func _update_intro_presentation(delta: float) -> void:
	if intro_stage != null:
		intro_stage.call("set_ship_open_factor", _get_intro_ship_open_factor())
		var rack_focus := _current_choice_target if _state == STATE_STARTER_CHOICE else ""
		if _claim_sequence_active:
			rack_focus = _starter_weapon
		intro_stage.call("set_rack_focus", rack_focus)
		intro_stage.call("set_choice_guide_visible", _state == STATE_STARTER_CHOICE)

	if intro_camera == null or not intro_camera.enabled:
		return

	var target_position := _get_title_camera_point()
	var target_zoom := TITLE_CAMERA_ZOOM

	match _state:
		STATE_LANDING:
			target_position = _get_intro_camera_point()
			target_zoom = DROP_CAMERA_ZOOM
		STATE_STARTER_CHOICE:
			target_position = _get_starter_choice_camera_point(_current_choice_target if not _claim_sequence_active else _starter_weapon)
			target_zoom = CLAIM_CAMERA_ZOOM if _claim_sequence_active else STARTER_CAMERA_ZOOM
		_:
			target_position = _get_title_camera_point()
			target_zoom = TITLE_CAMERA_ZOOM

	var blend := clampf(delta * INTRO_CAMERA_LERP, 0.0, 1.0)
	intro_camera.global_position = intro_camera.global_position.lerp(target_position, blend)
	intro_camera.zoom = intro_camera.zoom.lerp(target_zoom, blend)


func _set_kill_floor_visible(value: bool) -> void:
	if _kill_floor_line != null:
		_kill_floor_line.visible = value
	if backdrop != null and backdrop.has_method("set_kill_floor_visible"):
		backdrop.call("set_kill_floor_visible", value)


func _get_spawn_point() -> Vector2:
	if run_start_marker != null:
		return run_start_marker.global_position
	return DEFAULT_SPAWN_POINT


func _get_intro_landing_point() -> Vector2:
	if landing_marker != null:
		return landing_marker.global_position
	return DEFAULT_SPAWN_POINT


func _get_title_hero_point() -> Vector2:
	if title_hero_marker != null:
		return title_hero_marker.global_position
	return _get_intro_landing_point() + Vector2(-144.0, -72.0)


func _get_intro_drop_point() -> Vector2:
	if player_drop_marker != null:
		return player_drop_marker.global_position
	return DEFAULT_SPAWN_POINT + Vector2(-92.0, -132.0)


func _get_intro_camera_point() -> Vector2:
	if intro_camera_anchor != null:
		return intro_camera_anchor.global_position
	return Vector2(WORLD_SIZE.x * 0.34, WORLD_SIZE.y - 296.0)


func _get_title_camera_point() -> Vector2:
	if title_camera_anchor != null:
		return title_camera_anchor.global_position
	return _get_intro_camera_point() + Vector2(-96.0, -44.0)


func _get_starter_choice_camera_point(target: String) -> Vector2:
	var base := _get_intro_camera_point()
	if target == STARTER_BLADE and blade_stand != null:
		return base.lerp(blade_stand.global_position + Vector2(-56.0, -44.0), 0.58)
	if target == STARTER_GUN and gun_stand != null:
		return base.lerp(gun_stand.global_position + Vector2(34.0, -44.0), 0.58)
	return base


func _get_intro_ship_open_factor() -> float:
	match _state:
		STATE_TITLE:
			return 0.2
		STATE_LANDING:
			return 0.35 + 0.65 * clampf(_landing_timer / INTRO_LANDING_DURATION, 0.0, 1.0)
		STATE_STARTER_CHOICE:
			return 1.0
		_:
			return 0.0


func _get_choice_target() -> String:
	if not is_instance_valid(_player):
		return ""

	var blade_distance: float = _player.global_position.distance_to(blade_stand.global_position) if blade_stand != null else INF
	var gun_distance: float = _player.global_position.distance_to(gun_stand.global_position) if gun_stand != null else INF
	var best_mode := ""
	var best_distance := STARTER_SELECT_RANGE

	if blade_distance <= best_distance:
		best_mode = STARTER_BLADE
		best_distance = blade_distance
	if gun_distance <= best_distance:
		best_mode = STARTER_GUN

	return best_mode


func _update_choice_cards(target: String) -> void:
	var blade_active := target == STARTER_BLADE
	var gun_active := target == STARTER_GUN

	PixelUI.style_panel(blade_card, "item_selected" if blade_active else "item")
	PixelUI.style_panel(gun_card, "item_selected" if gun_active else "item")
	if blade_art != null:
		blade_art.texture = _blade_showcase_texture
		blade_art.modulate = Color(1.0, 1.0, 1.0, 1.0) if blade_active else Color(0.76, 0.82, 0.9, 0.96)
	if gun_art != null:
		gun_art.texture = _gun_showcase_texture
		gun_art.modulate = Color(1.0, 1.0, 1.0, 1.0) if gun_active else Color(0.76, 0.82, 0.9, 0.96)
	if intro_stage != null:
		intro_stage.call("set_rack_focus", target)

	if blade_status_label != null:
		blade_status_label.text = "ARC CUTTER   LOCK NOW" if blade_active else "ARC CUTTER   RISE / DIVE"
	if gun_status_label != null:
		gun_status_label.text = "BLASTER   LOCK NOW" if gun_active else "BLASTER   2-SHELL"

	if starter_hint_label == null:
		return

	match target:
		STARTER_BLADE:
			starter_hint_label.text = "Arc Cutter in focus. Input the cut for rise, drive, and rebound."
		STARTER_GUN:
			starter_hint_label.text = "Dock Blaster in focus. Two shells. Big recoil. Landing reload."
		_:
			starter_hint_label.text = "Move in, light a rack, and follow the dock sprite prompt to lock the starter weapon."
	_refresh_front_door_readout()


func _get_visible_menu_entries() -> Array:
	var entries: Array = []
	for entry in MENU_ENTRIES:
		if String(entry["id"]) == "quit" and OS.has_feature("web"):
			continue
		entries.append(entry)
	return entries


func _get_selected_skin_id() -> String:
	if profile_store != null:
		return SkinPalette.normalize_skin_id(String(profile_store.call("get_selected_skin")))
	return SkinPalette.SKIN_HIVE_RUNNER


func _get_skin_index_from_id(skin_id: String) -> int:
	var index := SKIN_ORDER.find(SkinPalette.normalize_skin_id(skin_id))
	return index if index >= 0 else 0


func _menu_move_up_pressed() -> bool:
	return Input.is_action_just_pressed("ui_up")


func _menu_move_down_pressed() -> bool:
	return Input.is_action_just_pressed("ui_down")


func _menu_move_left_pressed() -> bool:
	return Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("move_left")


func _menu_move_right_pressed() -> bool:
	return Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("move_right")


func _menu_accept_pressed() -> bool:
	return Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("shoot") or Input.is_action_just_pressed("jump")


func _menu_cancel_pressed() -> bool:
	return Input.is_action_just_pressed("ui_cancel")


func _get_settings_category(row: Dictionary) -> String:
	if String(row["type"]) == "input":
		return "CONTROLS"
	var setting_id := String(row["id"])
	if setting_id in ["master", "music", "sfx"]:
		return "AUDIO"
	return "DISPLAY"


func _get_settings_category_blurb(category: String) -> String:
	match category:
		"AUDIO":
			return "Master, score, and hit feedback."
		"DISPLAY":
			return "Windowing, scale, and prompt look."
		"CONTROLS":
			return "Live bindings for movement and combat."
		_:
			return ""


func _get_setting_row_help(row: Dictionary) -> String:
	if String(row["type"]) == "input":
		match String(row["action"]):
			"move_left", "move_right":
				return "Primary lane control for air lines and deck movement."
			"jump":
				return "Main launch button."
			"jetpack":
				return "Burst line correction and vertical carry."
			"shoot":
				return "Current attack trigger for the Arc Cutter or Blaster."
			"swap_weapon":
				return "Switches between Arc Cutter and Blaster once both are unlocked."
			"restart":
				return "Immediate rerun for practice."
			_:
				return "Attack to remap this input."
	match String(row["id"]):
		"master":
			return "Whole-game output. Keep hit feedback loud enough to feel the line."
		"music":
			return "Score bus for title, climb, and boss pacing."
		"sfx":
			return "Jet, slash, blaster, and hazard feedback."
		"window_mode":
			return "Dock presentation mode for desktop play."
		"pixel_scale":
			return "Internal scale. Higher values make the screen chunkier."
		"ui_scale":
			return "Scales the dock console and HUD without changing gameplay."
		"prompt_style":
			return "Controller prompt icon family."
		_:
			return "Left and right adjust this setting."


func _format_setting_value(setting_id: String, value: Variant) -> String:
	match setting_id:
		"master", "music", "sfx":
			return "%d%%" % int(round(float(value) * 100.0))
		"ui_scale":
			return "%.2fx" % float(value)
		"pixel_scale":
			return "%dx" % int(value)
		"window_mode", "prompt_style":
			return String(value).to_upper()
		_:
			return String(value)


func _get_binding_display(action_name: String) -> String:
	var bindings: Variant = _input_bindings_draft.get(action_name, [])
	if not (bindings is Array) or bindings.is_empty():
		return "UNBOUND"
	var event: Variant = bindings[0]
	if event is InputEventKey:
		return OS.get_keycode_string(event.keycode).to_upper()
	if event is InputEventMouseButton:
		return "MOUSE %d" % int(event.button_index)
	if event is InputEventJoypadButton:
		return "PAD %d" % int(event.button_index)
	if event is InputEventJoypadMotion:
		return "AXIS %d" % int(event.axis)
	return "BOUND"


func _bind_action_event(action_name: String, event: InputEvent) -> void:
	var existing: Array = _input_bindings_draft.get(action_name, [])
	var family := _event_family(event)
	var filtered: Array = []
	for existing_event in existing:
		if existing_event is InputEvent and _event_family(existing_event) != family:
			filtered.append((existing_event as InputEvent).duplicate())
	filtered.append(event.duplicate())
	_input_bindings_draft[action_name] = filtered
	if profile_store != null:
		profile_store.call("apply_input_bindings", {action_name: filtered}, true)


func _event_family(event: InputEvent) -> String:
	if event is InputEventKey or event is InputEventMouseButton:
		return "keyboard_mouse"
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return "joypad"
	return "other"


func _duplicate_binding_dictionary(bindings: Dictionary) -> Dictionary:
	var duplicate: Dictionary = {}
	for action_variant in bindings.keys():
		var action_name := String(action_variant)
		var events_variant: Variant = bindings[action_variant]
		if not (events_variant is Array):
			continue
		var copied: Array = []
		for event_variant in events_variant:
			if event_variant is InputEvent:
				copied.append((event_variant as InputEvent).duplicate())
		duplicate[action_name] = copied
	return duplicate


func _apply_audio_setting(bus_name: String, scalar: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return
	var safe_scalar := clampf(scalar, 0.0, 1.0)
	var db := linear_to_db(safe_scalar) if safe_scalar > 0.0 else -80.0
	AudioServer.set_bus_volume_db(bus_index, db)


func _apply_window_mode_local(mode_name: String) -> void:
	match mode_name:
		"fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		"borderless":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _apply_prompt_style_local(style_name: String) -> void:
	var style := "Pixel"
	match style_name:
		"default":
			style = "Default"
		"1-bit":
			style = "1-bit"
		_:
			style = "Pixel"
	ProjectSettings.set_setting("addons/input_prompts/icons/style", style)
	if has_node("/root/PromptManager"):
		var prompt_manager := get_node("/root/PromptManager")
		if prompt_manager.has_method("_reload_textures"):
			prompt_manager.call("_reload_textures")
		elif prompt_manager.has_method("refresh"):
			prompt_manager.call("refresh")


func _apply_ui_scale_setting(scale_value: float) -> void:
	PixelUI.apply_ui_scale(front_door, scale_value)
	PixelUI.apply_ui_scale(hud, scale_value)
	_apply_responsive_layout()


func _clear_container(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
