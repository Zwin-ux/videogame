extends Node
## MusicEngine — Update 0.2 Hive Signal
##
## Intensity-driven adaptive music. Five stems crossfaded against a single
## `intensity` value in [0, 1]. Stem thresholds come straight from the Hive
## Signal spec:
##   0.0  ambient     — always present
##   0.2  bass        — low pulse joins the loop
##   0.4  drums       — combat engage
##   0.6  lead        — boss or concentrated fight
##   0.8  chaos       — low-health boss phases
##
## Stems default to procedurally synthesized looping buffers so the engine
## makes sound on day one without shipping audio files. Authored `.ogg`
## files in `res://art/audio/music/` override the procedural stems on load.
##
## Usage:
##     MusicEngine.set_intensity(0.3)
##     MusicEngine.bump_intensity(0.1, 2.0)   # +0.1 target, decays after 2s
##     MusicEngine.set_track("dock_breach")

const BUS_NAME := "Music"
const AUDIO_DIR := "res://art/audio/music/"

const STEMS := ["ambient", "bass", "drums", "lead", "chaos"]
const THRESHOLDS := {"ambient": 0.0, "bass": 0.2, "drums": 0.4, "lead": 0.6, "chaos": 0.8}
const FADE_RANGE := 0.12

signal intensity_changed(value: float)
signal track_changed(name: String)

var _players: Dictionary = {}      # stem name -> AudioStreamPlayer
var _intensity := 0.0
var _target := 0.0
var _bump_decay := 0.0
var _bump_amount := 0.0
var _track := "dock_breach"
var _muted := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_players()
	_load_stems(_track)
	set_intensity(0.0)


func _process(delta: float) -> void:
	if _bump_amount > 0.0:
		if _bump_decay > 0.0:
			_bump_decay = maxf(_bump_decay - delta, 0.0)
		if _bump_decay <= 0.0:
			_bump_amount = 0.0
	# Smooth interp toward target.
	var goal: float = clampf(_target + _bump_amount, 0.0, 1.0)
	if absf(_intensity - goal) > 0.001:
		var rate: float = 1.6 * delta
		_intensity = move_toward(_intensity, goal, rate)
		_apply_mix()
		emit_signal("intensity_changed", _intensity)


## Hard-set the base intensity target. Smooth crossfade.
func set_intensity(value: float) -> void:
	_target = clampf(value, 0.0, 1.0)


## Temporarily push intensity higher. `decay_seconds` controls how long
## the bump lasts before dropping back to the base target.
func bump_intensity(amount: float, decay_seconds: float = 2.0) -> void:
	_bump_amount = maxf(_bump_amount, clampf(amount, 0.0, 1.0))
	_bump_decay = maxf(_bump_decay, decay_seconds)


## Swap track (reloads stems).
func set_track(name: String) -> void:
	if _track == name:
		return
	_track = name
	_load_stems(name)
	emit_signal("track_changed", name)


func set_muted(flag: bool) -> void:
	_muted = flag
	for p in _players.values():
		p.stream_paused = flag


## Testing / debug.
func get_intensity() -> float:
	return _intensity


func get_stem_volume(name: String) -> float:
	if not _players.has(name):
		return -80.0
	return (_players[name] as AudioStreamPlayer).volume_db


# --- internal ---------------------------------------------------------------

func _ensure_players() -> void:
	for stem in STEMS:
		var p := AudioStreamPlayer.new()
		p.bus = BUS_NAME
		p.volume_db = -80.0
		p.autoplay = false
		p.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(p)
		_players[stem] = p


func _load_stems(track: String) -> void:
	for stem in STEMS:
		var player: AudioStreamPlayer = _players[stem]
		var authored_path: String = "%s%s_%s.ogg" % [AUDIO_DIR, track, stem]
		var stream: AudioStream = null
		if ResourceLoader.exists(authored_path):
			var loaded: Resource = ResourceLoader.load(authored_path)
			if loaded is AudioStream:
				stream = loaded
		if stream == null:
			stream = _synthesize_stem(stem)
		player.stream = stream
		# Guarded for headless / not-yet-in-tree use.
		if player.stream != null and player.is_inside_tree():
			player.play()


func _apply_mix() -> void:
	for stem in STEMS:
		var player: AudioStreamPlayer = _players[stem]
		if player == null:
			continue
		var target_db := _stem_db_for(stem, _intensity)
		if _muted:
			target_db = -80.0
		player.volume_db = target_db


func _stem_db_for(stem: String, intensity: float) -> float:
	var threshold: float = THRESHOLDS.get(stem, 0.0)
	# Linear ramp across FADE_RANGE from silent at threshold to 0 dB at threshold+fade.
	if intensity <= threshold:
		return -80.0
	var ramp := clampf((intensity - threshold) / FADE_RANGE, 0.0, 1.0)
	# Gentle curve so stems do not pop in.
	var gain := ramp * ramp
	return lerp(-24.0, -6.0, gain)


const _SAMPLE_RATE := 22050
const _LOOP_SECONDS := 4.0


func _synthesize_stem(stem: String) -> AudioStreamWAV:
	match stem:
		"ambient": return _bake_ambient()
		"bass":    return _bake_bass()
		"drums":   return _bake_drums()
		"lead":    return _bake_lead()
		"chaos":   return _bake_chaos()
	return null


func _new_loop_wav(data: PackedByteArray) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = _SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = int(data.size() / 2)
	return stream


func _bake_ambient() -> AudioStreamWAV:
	# Slow pulsing pad — fifth interval, tremolo, heavy low-pass feel.
	var n := int(_LOOP_SECONDS * _SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(n * 2)
	var base := 110.0
	for i in range(n):
		var t := float(i) / float(_SAMPLE_RATE)
		var tremolo := 0.75 + 0.25 * sin(TAU * 0.25 * t)
		var a := sin(TAU * base * t)
		var b := sin(TAU * base * 1.5 * t) * 0.6
		var c := sin(TAU * base * 2.0 * t) * 0.3
		var sample_f: float = (a + b + c) * 0.22 * tremolo
		var sample: int = clampi(int(sample_f * 20000.0), -32767, 32767)
		data.encode_s16(i * 2, sample)
	return _new_loop_wav(data)


func _bake_bass() -> AudioStreamWAV:
	# Pulse on the quarter note at ~120 BPM.
	var n := int(_LOOP_SECONDS * _SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(n * 2)
	var bpm := 120.0
	var beat := 60.0 / bpm
	for i in range(n):
		var t := float(i) / float(_SAMPLE_RATE)
		var beat_pos := fmod(t, beat) / beat
		var env := exp(-beat_pos * 6.0)
		var freq := 55.0
		var saw := fmod(freq * t, 1.0) * 2.0 - 1.0
		var sub := sin(TAU * freq * 0.5 * t) * 0.6
		var sample_f: float = (saw * 0.5 + sub) * env * 0.55
		var sample: int = clampi(int(sample_f * 22000.0), -32767, 32767)
		data.encode_s16(i * 2, sample)
	return _new_loop_wav(data)


func _bake_drums() -> AudioStreamWAV:
	# Four-on-the-floor kick + off-beat hat. Pure synthesis.
	var n := int(_LOOP_SECONDS * _SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(n * 2)
	var bpm := 120.0
	var beat := 60.0 / bpm
	var half_beat := beat * 0.5
	var rng := RandomNumberGenerator.new()
	rng.seed = 17
	for i in range(n):
		var t := float(i) / float(_SAMPLE_RATE)
		var beat_pos := fmod(t, beat)
		var half_pos := fmod(t + half_beat * 0.5, beat)
		var kick_env := exp(-beat_pos * 30.0)
		var kick_freq := 80.0 * exp(-beat_pos * 20.0)
		var kick := sin(TAU * kick_freq * beat_pos) * kick_env
		var hat_env := exp(-half_pos * 40.0) * 0.35
		var hat := rng.randf_range(-1.0, 1.0) * hat_env
		var sample_f: float = (kick + hat) * 0.6
		var sample: int = clampi(int(sample_f * 22000.0), -32767, 32767)
		data.encode_s16(i * 2, sample)
	return _new_loop_wav(data)


func _bake_lead() -> AudioStreamWAV:
	# Arpeggio riff, signals active combat.
	var n := int(_LOOP_SECONDS * _SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(n * 2)
	var notes := [220.0, 261.63, 329.63, 261.63, 220.0, 329.63, 392.0, 329.63]
	var note_length := _LOOP_SECONDS / float(notes.size())
	for i in range(n):
		var t := float(i) / float(_SAMPLE_RATE)
		var idx := int(floor(t / note_length)) % notes.size()
		var note_t := fmod(t, note_length)
		var freq := notes[idx] as float
		var env := exp(-note_t * 4.0) * (1.0 - note_t / note_length) * 0.7
		var wave := sin(TAU * freq * t) * 0.55
		var sample_f: float = wave * env
		var sample: int = clampi(int(sample_f * 21000.0), -32767, 32767)
		data.encode_s16(i * 2, sample)
	return _new_loop_wav(data)


func _bake_chaos() -> AudioStreamWAV:
	# Detuned dissonant pad — only plays when intensity exceeds 0.8.
	var n := int(_LOOP_SECONDS * _SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in range(n):
		var t := float(i) / float(_SAMPLE_RATE)
		var a := sin(TAU * 196.0 * t)
		var b := sin(TAU * 207.65 * t)   # minor second, crunchy
		var c := sin(TAU * 293.66 * t) * 0.7
		var warble := 0.85 + 0.15 * sin(TAU * 0.6 * t)
		var sample_f: float = (a + b + c) * 0.15 * warble
		var sample: int = clampi(int(sample_f * 21000.0), -32767, 32767)
		data.encode_s16(i * 2, sample)
	return _new_loop_wav(data)
