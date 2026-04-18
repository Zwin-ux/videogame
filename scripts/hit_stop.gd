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
var _freeze_start_usec := 0


func _ready() -> void:
	# Hit stop must keep counting real time while the world is frozen.
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	if not _active:
		return
	# Wallclock-based countdown so hit-stop always ends on time, regardless of
	# current Engine.time_scale. Time.get_ticks_usec() keeps counting at full
	# speed even while the world is frozen.
	var now_usec: int = Time.get_ticks_usec()
	_elapsed = float(now_usec - _freeze_start_usec) / 1_000_000.0
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
		# Accept the stronger freeze. Longer duration wins, but we keep the
		# original _previous_scale — if another system set time_scale while we
		# were frozen, restoring our captured 1.0 would smash their work.
		if duration > (_duration - _elapsed):
			_duration = duration
			_elapsed = 0.0
			_freeze_scale = scale
			_freeze_start_usec = Time.get_ticks_usec()
			Engine.time_scale = _freeze_scale
		return
	_previous_scale = Engine.time_scale
	_freeze_scale = scale
	_duration = duration
	_elapsed = 0.0
	_freeze_start_usec = Time.get_ticks_usec()
	_active = true
	Engine.time_scale = _freeze_scale
	emit_signal("frozen", duration)


func _restore() -> void:
	# Only restore if we still own time_scale. If another system changed it
	# during our freeze, it has newer authority — don't clobber.
	if is_equal_approx(Engine.time_scale, _freeze_scale):
		Engine.time_scale = _previous_scale
	_active = false
	_duration = 0.0
	_elapsed = 0.0
	emit_signal("restored")


func _exit_tree() -> void:
	# Safety: never leak a frozen time_scale across scene teardown.
	if _active:
		_restore()
