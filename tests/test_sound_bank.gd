extends RefCounted

const SoundBankScript := preload("res://scripts/sound_bank.gd")
const Ass := preload("res://tests/ass.gd")


func run() -> Dictionary:
	var a: Ass = Ass.new("sound_bank")
	var sb: Node = SoundBankScript.new()
	# Manually bootstrap since we're not attached to the scene tree.
	sb._ready()

	# Manifest completeness.
	var expected: Array = ["gun_fire", "gun_fire_pressure", "gun_fire_breaker", "gun_hit",
		"blade_swing", "blade_hit", "blade_hit_kill", "enemy_death", "player_hit",
		"pickup", "pickup_major", "upgrade_stinger", "rival_phase_change", "combo_milestone"]
	var known: PackedStringArray = sb.call("known_sounds")
	for name in expected:
		a.true_(known.has(String(name)), "manifest contains %s" % String(name))

	# Each manifest entry prebakes to a non-null stream.
	for name in expected:
		var stream: AudioStream = sb._get_stream(String(name))
		a.non_null(stream, "stream for %s" % String(name))
		if stream is AudioStreamWAV:
			var wav: AudioStreamWAV = stream as AudioStreamWAV
			a.gt(float(wav.data.size()), 0.0, "wav data bytes for %s" % String(name))

	# Pool is sized correctly.
	a.eq(sb._pool.size(), sb.POOL_SIZE, "pool size")

	# Voice stealing: play more than POOL_SIZE sounds in a row; call returns true.
	for i in range(sb.POOL_SIZE + 4):
		a.true_(sb.play("gun_fire"), "play %d returns true" % i)

	# Unknown sound returns false and does not crash.
	a.false_(sb.play("does_not_exist"), "unknown sound returns false")

	# Mute.
	sb.set_muted(true)
	a.true_(sb.is_muted(), "muted flag set")
	a.false_(sb.play("gun_fire"), "muted play returns false")
	sb.set_muted(false)

	# Register: hot-swap in an arbitrary stream.
	var swap := AudioStreamWAV.new()
	swap.data = PackedByteArray([0, 0, 0, 0])
	sb.register("gun_fire", swap)
	a.eq(sb._get_stream("gun_fire"), swap, "register swaps stream")

	# Reset reverts to procedural.
	sb.reset_to_procedural()
	a.ne(sb._get_stream("gun_fire"), swap, "reset reverts stream")

	sb.free()
	return a.report()
