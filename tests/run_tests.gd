extends SceneTree
## Hive Signal test runner.
##
## Discovers test scripts under `tests/`, instantiates each, runs `run()`,
## tallies pass / fail, exits with status code.
##
## Usage:
##     godot --headless --script tests/run_tests.gd

const TESTS := [
	"res://tests/test_sound_bank.gd",
	"res://tests/test_camera_shake.gd",
	"res://tests/test_hit_stop.gd",
	"res://tests/test_music_engine.gd",
	"res://tests/test_wiring.gd",
]


func _initialize() -> void:
	print("\n=== Killer Queen — Hive Signal test run ===\n")
	var passed := 0
	var failed := 0
	var total_asserts := 0
	var failures: Array = []
	var start := Time.get_ticks_msec()

	for path in TESTS:
		var script: Script = load(path) as Script
		if script == null or not script.can_instantiate():
			printerr("[!] Cannot load or instantiate %s" % path)
			failed += 1
			failures.append({"name": path, "reason": "load or parse failure"})
			continue
		var instance: Object = script.new()
		if instance == null or not instance.has_method("run"):
			printerr("[!] %s has no run() method" % path)
			failed += 1
			failures.append({"name": path, "reason": "missing run()"})
			continue
		var report: Dictionary = instance.call("run")
		var name := String(report.get("name", path))
		var passed_count := int(report.get("passed", 0))
		var failed_list: Array = report.get("failed", [])
		total_asserts += passed_count + failed_list.size()
		if failed_list.is_empty():
			print("  [OK]   %s  (%d checks)" % [name, passed_count])
			passed += 1
		else:
			print("  [FAIL] %s  (%d / %d passed)" % [name, passed_count, passed_count + failed_list.size()])
			for msg in failed_list:
				print("         · %s" % String(msg))
				failures.append({"name": name, "reason": String(msg)})
			failed += 1

	var duration_ms := Time.get_ticks_msec() - start
	print("\n-------------------------------------------")
	print("%d / %d suites passed · %d assertions · %d ms" % [passed, passed + failed, total_asserts, duration_ms])
	if failed > 0:
		print("\nFailures:")
		for f in failures:
			print("  - %s :: %s" % [String(f["name"]), String(f["reason"])])
		print("\n=== RED ===\n")
		quit(1)
	else:
		print("\n=== GREEN ===\n")
		quit(0)
