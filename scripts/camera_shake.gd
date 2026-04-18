extends Node
## CameraShake — Update 0.2 Hive Signal
##
## Single-camera shake broker. The active gameplay camera registers itself
## on `_ready()`; anyone can call `CameraShake.kick(amplitude, duration)`
## to add trauma without needing a direct node path.
##
## Amplitudes use the Hive Signal spec:
##   gun_fire             : 2px  / 0.06s
##   blade_hit_kill       : 5px  / 0.10s
##   player_hit           : 7px  / 0.14s
##   boss_phase_change    : 9px  / 0.25s
## Hard cap: MAX_AMPLITUDE. A single bad call can not kick the screen
## further than that, no matter what callers pass.

const MAX_AMPLITUDE := 9.0
const MAX_DURATION := 0.40

## Amplitude presets for readable call sites.
const PRESETS := {
	"tiny":   {"amp": 2.0, "dur": 0.06},
	"small":  {"amp": 3.0, "dur": 0.08},
	"medium": {"amp": 5.0, "dur": 0.10},
	"big":    {"amp": 7.0, "dur": 0.14},
	"huge":   {"amp": 9.0, "dur": 0.25},
}

signal kicked(amplitude: float, duration: float)

var _camera: Camera2D = null
var _base_offset: Vector2 = Vector2.ZERO
var _active := false
var _amp := 0.0
var _dur := 0.0
var _elapsed := 0.0
var _reduce_motion := false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()


func _process(delta: float) -> void:
	if not _active:
		return
	_elapsed += delta
	if _camera == null or not is_instance_valid(_camera):
		_active = false
		return
	if _elapsed >= _dur:
		_camera.offset = _base_offset
		_active = false
		return
	var t := 1.0 - (_elapsed / maxf(_dur, 0.001))
	var amp := _amp * t
	_camera.offset = _base_offset + Vector2(
		_rng.randf_range(-amp, amp),
		_rng.randf_range(-amp, amp))


## Register the active gameplay camera. Call from the camera's `_ready()`.
func register_camera(camera: Camera2D) -> void:
	_camera = camera
	_base_offset = camera.offset if camera != null else Vector2.ZERO


func unregister_camera(camera: Camera2D) -> void:
	if _camera == camera:
		if _camera != null and is_instance_valid(_camera):
			_camera.offset = _base_offset
		_camera = null
		_active = false


## Shake by amplitude and duration directly. Values are clamped.
func kick(amplitude: float, duration: float) -> void:
	if _reduce_motion:
		amplitude *= 0.5
	var amp := clampf(amplitude, 0.0, MAX_AMPLITUDE)
	var dur := clampf(duration, 0.0, MAX_DURATION)
	if amp <= 0.0 or dur <= 0.0:
		return
	# Additive trauma: a new kick during a live shake replaces if stronger,
	# otherwise extends duration modestly to keep hits chaining on fast combat.
	if _active and _amp > amp:
		_dur = maxf(_dur - _elapsed, dur)
		_elapsed = 0.0
	else:
		_amp = amp
		_dur = dur
		_elapsed = 0.0
		_active = true
	emit_signal("kicked", amp, dur)


## Named preset. `CameraShake.preset("big")`.
func preset(name: String) -> void:
	var p: Dictionary = PRESETS.get(name, {})
	if p.is_empty():
		push_warning("[CameraShake] Unknown preset: %s" % name)
		return
	kick(float(p.get("amp", 0.0)), float(p.get("dur", 0.0)))


func set_reduce_motion(flag: bool) -> void:
	_reduce_motion = flag


func is_active() -> bool:
	return _active


func current_amplitude() -> float:
	if not _active:
		return 0.0
	var t := 1.0 - (_elapsed / maxf(_dur, 0.001))
	return _amp * t
