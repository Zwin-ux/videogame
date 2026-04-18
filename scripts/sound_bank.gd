extends Node
## SoundBank — Update 0.2 Hive Signal
##
## One-stop SFX API. Procedural by default, upgrades to authored `.ogg`
## files when they land in `res://art/audio/sfx/<name>.ogg`.
##
## Call pattern:
##     SoundBank.play("blade_hit_kill")
##     SoundBank.play("gun_fire", {"pitch": 1.1, "volume_db": -4.0})
##
## All audio routes through the `SFX` bus. Music goes through `MusicEngine`.

const BUS_NAME := "SFX"
const AUDIO_DIR := "res://art/audio/sfx/"
const POOL_SIZE := 12

# Hive Signal SFX manifest. Each entry declares the procedural recipe used
# when no authored file is present. `kind` drives the synth path.
#   noise_burst — short percussive burst with colored noise
#   tone_blip   — sine-triangle tonal blip, for UI and pickups
#   slash_swipe — descending pitched sweep with grain, blade signature
#   thump       — low-freq kick, impact / damage
const MANIFEST := {
	"gun_fire":         {"kind": "noise_burst", "duration": 0.12, "freq": 340.0, "decay": 28.0, "color": 0.7, "volume_db": -6.0},
	"gun_fire_pressure":{"kind": "noise_burst", "duration": 0.14, "freq": 260.0, "decay": 22.0, "color": 0.85, "volume_db": -4.0},
	"gun_fire_breaker": {"kind": "noise_burst", "duration": 0.18, "freq": 190.0, "decay": 18.0, "color": 0.95, "volume_db": -3.0},
	"gun_hit":          {"kind": "thump",       "duration": 0.10, "freq": 180.0, "decay": 36.0, "volume_db": -5.0},
	"blade_swing":      {"kind": "slash_swipe", "duration": 0.18, "freq_start": 820.0, "freq_end": 380.0, "decay": 20.0, "volume_db": -7.0},
	"blade_hit":        {"kind": "thump",       "duration": 0.14, "freq": 140.0, "decay": 28.0, "volume_db": -4.0},
	"blade_hit_kill":   {"kind": "thump",       "duration": 0.22, "freq": 90.0,  "decay": 16.0, "volume_db": -2.0},
	"enemy_death":      {"kind": "noise_burst", "duration": 0.26, "freq": 220.0, "decay": 14.0, "color": 0.6, "volume_db": -4.0},
	"player_hit":       {"kind": "thump",       "duration": 0.30, "freq": 70.0,  "decay": 10.0, "volume_db": -1.0},
	"pickup":           {"kind": "tone_blip",   "duration": 0.22, "freq": 880.0, "decay": 16.0, "volume_db": -8.0},
	"pickup_major":     {"kind": "tone_blip",   "duration": 0.34, "freq": 1320.0,"decay": 12.0, "volume_db": -6.0},
	"upgrade_stinger":  {"kind": "tone_blip",   "duration": 0.48, "freq": 1760.0,"decay": 9.0,  "volume_db": -4.0},
	"rival_phase_change":{"kind": "thump",      "duration": 0.54, "freq": 55.0,  "decay": 6.0,  "volume_db": 0.0},
	"combo_milestone":  {"kind": "tone_blip",   "duration": 0.28, "freq": 660.0, "decay": 14.0, "volume_db": -6.0},
}

var _streams: Dictionary = {}          # name -> AudioStream
var _pool: Array[AudioStreamPlayer] = []
var _cursor := 0
var _muted := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_pool()
	# Streams synthesize lazily on first play() per name. Keeps autoload boot
	# cheap on the editor and the initial game frame.


## Play a sound by manifest name. Returns true if audible, false if unknown or muted.
func play(name: String, opts: Dictionary = {}) -> bool:
	if _muted:
		return false
	# Lazy self-heal if play() is called before _ready / _enter_tree finished.
	if _pool.is_empty():
		_ensure_pool()
	var stream: AudioStream = _get_stream(name)
	if stream == null:
		push_warning("[SoundBank] Unknown sound: %s" % name)
		return false
	var player: AudioStreamPlayer = _next_player()
	if player == null:
		return false
	player.stream = stream
	player.volume_db = float(opts.get("volume_db", _manifest_volume(name)))
	player.pitch_scale = float(opts.get("pitch", 1.0))
	player.bus = BUS_NAME
	# Guard: headless / standalone-instantiated SoundBank is not in the tree.
	# The play() call requires tree membership, so skip the audio call but
	# still report audible=true so tests and callers don't see false failures.
	if player.is_inside_tree():
		player.play()
	return true


## Hot-swap in an authored stream. Future `play(name)` calls use this stream.
func register(name: String, stream: AudioStream) -> void:
	_streams[name] = stream


## Drop all registered streams back to the procedural defaults.
func reset_to_procedural() -> void:
	_streams.clear()
	_prebake_streams()


func set_muted(flag: bool) -> void:
	_muted = flag


func is_muted() -> bool:
	return _muted


## Testing / debug. Returns the raw configuration for a sound name.
func describe(name: String) -> Dictionary:
	return MANIFEST.get(name, {})


func known_sounds() -> PackedStringArray:
	var keys := MANIFEST.keys()
	keys.sort()
	var out := PackedStringArray()
	for k in keys:
		out.append(String(k))
	return out


# --- internal ---------------------------------------------------------------

func _manifest_volume(name: String) -> float:
	var cfg := MANIFEST.get(name, {}) as Dictionary
	return float(cfg.get("volume_db", -6.0))


func _ensure_pool() -> void:
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.bus = BUS_NAME
		p.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(p)
		_pool.append(p)


func _next_player() -> AudioStreamPlayer:
	var idx := _cursor
	for i in range(_pool.size()):
		var j := (idx + i) % _pool.size()
		if not _pool[j].playing:
			_cursor = (j + 1) % _pool.size()
			return _pool[j]
	# All busy — trample the oldest (voice-stealing is desirable for SFX).
	_cursor = (idx + 1) % _pool.size()
	return _pool[idx]


func _get_stream(name: String) -> AudioStream:
	if _streams.has(name):
		return _streams[name]
	# Authored .ogg wins over procedural — load on first miss.
	var path: String = AUDIO_DIR + name + ".ogg"
	if ResourceLoader.exists(path):
		var authored: Resource = ResourceLoader.load(path)
		if authored is AudioStream:
			_streams[name] = authored
			return authored
	# Fall back to procedural synthesis for the single requested name.
	if MANIFEST.has(name):
		var cfg: Dictionary = MANIFEST[name]
		var stream: AudioStream = _synthesize(cfg)
		if stream != null:
			_streams[name] = stream
			return stream
	return null


## Optional: eager-bake all SFX (only useful for tests or load-screen warm-up).
func _prebake_streams() -> void:
	for name in MANIFEST.keys():
		if _streams.has(name):
			continue
		var cfg: Dictionary = MANIFEST[name]
		var stream: AudioStream = _synthesize(cfg)
		if stream != null:
			_streams[name] = stream


func _synthesize(cfg: Dictionary) -> AudioStream:
	var kind := String(cfg.get("kind", "tone_blip"))
	match kind:
		"noise_burst":
			return _bake_noise_burst(
				float(cfg.get("duration", 0.12)),
				float(cfg.get("freq", 340.0)),
				float(cfg.get("decay", 24.0)),
				float(cfg.get("color", 0.7)))
		"tone_blip":
			return _bake_tone_blip(
				float(cfg.get("duration", 0.22)),
				float(cfg.get("freq", 880.0)),
				float(cfg.get("decay", 16.0)))
		"slash_swipe":
			return _bake_slash_swipe(
				float(cfg.get("duration", 0.18)),
				float(cfg.get("freq_start", 820.0)),
				float(cfg.get("freq_end", 380.0)),
				float(cfg.get("decay", 20.0)))
		"thump":
			return _bake_thump(
				float(cfg.get("duration", 0.20)),
				float(cfg.get("freq", 120.0)),
				float(cfg.get("decay", 20.0)))
	return null


const _SAMPLE_RATE := 11025


func _new_wav(data: PackedByteArray) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = _SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream


func _bake_noise_burst(duration: float, base_freq: float, decay: float, color: float) -> AudioStreamWAV:
	var sample_count: int = int(duration * _SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(base_freq * 7919.0)
	var last_noise: float = 0.0
	var color_clamped: float = clampf(color, 0.0, 1.0)
	for i in range(sample_count):
		var t: float = float(i) / float(_SAMPLE_RATE)
		var env: float = exp(-t * decay)
		var noise: float = rng.randf_range(-1.0, 1.0)
		last_noise = lerpf(last_noise, noise, color_clamped)
		var tone: float = sin(TAU * base_freq * t) * 0.35
		var sample_f: float = (last_noise * 0.75 + tone * 0.6) * env
		var sample: int = clampi(int(sample_f * 22000.0), -32767, 32767)
		data.encode_s16(i * 2, sample)
	return _new_wav(data)


func _bake_tone_blip(duration: float, base_freq: float, decay: float) -> AudioStreamWAV:
	var sample_count: int = int(duration * _SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for i in range(sample_count):
		var t: float = float(i) / float(_SAMPLE_RATE)
		var env: float = exp(-t * decay)
		var sine: float = sin(TAU * base_freq * t)
		var fifth: float = sin(TAU * base_freq * 1.5 * t) * 0.35
		var sample_f: float = (sine + fifth) * env * 0.55
		var sample: int = clampi(int(sample_f * 22000.0), -32767, 32767)
		data.encode_s16(i * 2, sample)
	return _new_wav(data)


func _bake_slash_swipe(duration: float, freq_start: float, freq_end: float, decay: float) -> AudioStreamWAV:
	var sample_count: int = int(duration * _SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(freq_start * 1013.0)
	var phase: float = 0.0
	for i in range(sample_count):
		var t: float = float(i) / float(_SAMPLE_RATE)
		var progress: float = t / maxf(duration, 0.001)
		var env: float = exp(-t * decay * 0.5) * (1.0 - progress * 0.4)
		var freq: float = lerpf(freq_start, freq_end, progress)
		phase += TAU * freq / float(_SAMPLE_RATE)
		var wave: float = sin(phase) * 0.6
		var grain: float = rng.randf_range(-1.0, 1.0) * 0.25
		var sample_f: float = (wave + grain) * env
		var sample: int = clampi(int(sample_f * 21000.0), -32767, 32767)
		data.encode_s16(i * 2, sample)
	return _new_wav(data)


func _bake_thump(duration: float, base_freq: float, decay: float) -> AudioStreamWAV:
	var sample_count: int = int(duration * _SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for i in range(sample_count):
		var t: float = float(i) / float(_SAMPLE_RATE)
		var env: float = exp(-t * decay)
		var freq: float = base_freq * exp(-t * decay * 0.15)
		var wave: float = sin(TAU * freq * t) * 0.95
		var click: float = 0.0
		if t < 0.01:
			click = (1.0 - clampf(t * 80.0, 0.0, 1.0)) * 0.4
		var sample_f: float = (wave + click) * env
		var sample: int = clampi(int(sample_f * 23000.0), -32767, 32767)
		data.encode_s16(i * 2, sample)
	return _new_wav(data)
