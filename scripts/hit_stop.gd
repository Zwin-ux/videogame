extends Node
## HitStop — Update 0.2 Hive Signal
##
## Brief `Engine.time_scale` freeze on blade kills and boss phase hits.
## Gun kills do not call this. The point of hit-stop is to MEAN something.
##
## Usage:
##     HitStop.freeze()                 # default 0.08s
##     HitStop.freeze_frames(5)         # by frames at 60Hz
##     HitStop.freeze_custom(0.12, 0.0) # time + post-scale (0 = full stop)

const DEFAULT_DURATION := 0.08
const MAX_DURATION := 0.18
const TARGET_FPS := 60.0

signal frozen(duration: float)
signal restored()

var _active := false
var _elapsed := 0.0
var _duration := 0.0
var _previous_scale := 1.0
var _freeze_scale := 0.0
var _disabled := false


func _ready() -> void:
	# Hit stop must keep counting real time while the world is frozen.
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	if not _active:
		return
	# Use real-world delta (not the scaled engine delta) so we can count down
	# while the rest of the game is paused.
	var real_delta := _real_delta()
	_elapsed += real_delta
	if _elapsed >= _duration:
		_restore()


## Default freeze. 0.08s of near-zero time_scale.
func freeze(duration: float = DEFAULT_DURATION) -> void:
	if _disabled:
		return
	_begin(clampf(duration, 0.0, MAX_DURATION), 0.0)


## Freeze for N frames at 60Hz.
func freeze_frames(frames: int) -> void:
	freeze(float(frames) / TARGET_FPS)


## Freeze with a custom post-scale (0.0 = full stop, 0.25 = quarter speed bullet-time).
func freeze_custom(duration: float, scale: float) -> void:
	if _disabled:
		return
	_begin(clampf(duration, 0.0, MAX_DURATION), clampf(scale, 0.0, 1.0))


## Cancel an in-flight freeze immediately.
func cancel() -> void:
	if _active:
		_restore()


func set_disabled(flag: bool) -> void:
	_disabled = flag
	if flag and _active:
		_restore()


func is_active() -> bool:
	return _active


func time_remaining() -> float:
	if not _active:
		return 0.0
	return maxf(_duration - _elapsed, 0.0)


# --- internal ---------------------------------------------------------------

func _begin(duration: float, scale: float) -> void:
	if duration <= 0.0:
		return
	if _active:
		# Accept the stronger freeze. Longer duration wins.
		if duration > (_duration - _elapsed):
			_duration = duration
			_elapsed = 0.0
			_freeze_scale = scale
			Engine.time_scale = _freeze_scale
		return
	_previous_scale = Engine.time_scale
	_freeze_scale = scale
	_duration = duration
	_elapsed = 0.0
	_active = true
	Engine.time_scale = _freeze_scale
	emit_signal("frozen", duration)


func _restore() -> void:
	Engine.time_scale = _previous_scale
	_active = false
	_duration = 0.0
	_elapsed = 0.0
	emit_signal("restored")


func _real_delta() -> float:
	# `Engine.time_scale` modifies `get_process_delta_time()`. To count real
	# seconds, use the physics ticks-per-second basis.
	var ts := Engine.time_scale
	if ts <= 0.0001:
		# Approximate real time from the project's physics fps setting.
		return 1.0 / float(Engine.physics_ticks_per_second)
	return get_process_delta_time() / ts
