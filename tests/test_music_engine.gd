extends RefCounted

const MusicEngineScript := preload("res://scripts/music_engine.gd")
const Ass := preload("res://tests/ass.gd")


func run() -> Dictionary:
	var a: Ass = Ass.new("music_engine")
	var me: Node = MusicEngineScript.new()
	me._ready()
	# _ready() call-defers _load_stems; tests need it synchronous.
	me.call("_load_stems", "dock_breach")

	# All five stems exist and have a stream.
	for stem in me.STEMS:
		a.true_(me._players.has(stem), "stem player %s exists" % stem)
		var player: AudioStreamPlayer = me._players[stem]
		a.non_null(player, "stem player %s non-null" % stem)
		a.non_null(player.stream, "stem stream %s non-null" % stem)

	# Intensity clamps.
	me.set_intensity(-1.0)
	a.near(float(me._target), 0.0, 0.001, "intensity floor")
	me.set_intensity(5.0)
	a.near(float(me._target), 1.0, 0.001, "intensity ceiling")

	# Stem doctrine:
	#   ambient is always present — audible floor at intensity 0, full at combat
	#   other stems hard-silent below threshold, then snap to -6 dB
	a.gt(float(me._stem_db_for("ambient", 0.0)), -24.0, "ambient always audible at idle")
	a.near(float(me._stem_db_for("ambient", 1.0)), -6.0, 0.01, "ambient at full during combat")

	a.near(float(me._stem_db_for("bass", 0.15)), -80.0, 0.001, "bass silent below threshold")
	a.near(float(me._stem_db_for("bass", 0.35)), -6.0, 0.01, "bass snaps to -6 dB above threshold")

	a.near(float(me._stem_db_for("drums", 0.3)), -80.0, 0.001, "drums silent below threshold")
	a.near(float(me._stem_db_for("drums", 0.5)), -6.0, 0.01, "drums snap to -6 dB above threshold")

	a.near(float(me._stem_db_for("chaos", 0.5)), -80.0, 0.001, "chaos silent in normal combat")
	a.near(float(me._stem_db_for("chaos", 0.95)), -6.0, 0.01, "chaos at -6 dB at high intensity")

	# bump_intensity accumulates onto the target.
	me.set_intensity(0.3)
	me.bump_intensity(0.2, 2.0)
	a.near(float(me._bump_amount), 0.2, 0.001, "bump amount recorded")

	# Drive the interpolation forward; _intensity should climb toward target+bump.
	for i in range(30):
		me._process(0.05)
	a.gt(float(me._intensity), 0.3, "intensity interp climbs past base")
	a.lt(float(me._intensity), 0.51, "intensity interp bounded by target+bump")

	# Bump decay drops the bump after its window.
	me._bump_decay = 0.0
	me._process(0.1)
	a.near(float(me._bump_amount), 0.0, 0.001, "bump decays after window")

	# Mute sets all stem players volume to -80.
	me.set_muted(true)
	me._apply_mix()
	for stem in me.STEMS:
		a.near(float((me._players[stem] as AudioStreamPlayer).volume_db), -80.0, 0.001, "%s silent when muted" % stem)
	me.set_muted(false)

	me.free()
	return a.report()
