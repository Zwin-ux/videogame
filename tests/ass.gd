extends RefCounted
## Tiny assertion helper. `Ass.new()` → collect failures, return report.

var passed := 0
var failed: Array = []
var _suite := ""


func _init(suite_name: String = "") -> void:
	_suite = suite_name


func true_(condition: bool, label: String) -> void:
	if condition:
		passed += 1
	else:
		failed.append("%s: expected true" % label)


func false_(condition: bool, label: String) -> void:
	if not condition:
		passed += 1
	else:
		failed.append("%s: expected false" % label)


func eq(actual, expected, label: String) -> void:
	if actual == expected:
		passed += 1
	else:
		failed.append("%s: expected %s, got %s" % [label, str(expected), str(actual)])


func ne(actual, expected, label: String) -> void:
	if actual != expected:
		passed += 1
	else:
		failed.append("%s: expected NOT %s, got %s" % [label, str(expected), str(actual)])


func near(actual: float, expected: float, tolerance: float, label: String) -> void:
	if absf(actual - expected) <= tolerance:
		passed += 1
	else:
		failed.append("%s: expected ~%f (±%f), got %f" % [label, expected, tolerance, actual])


func gt(actual: float, threshold: float, label: String) -> void:
	if actual > threshold:
		passed += 1
	else:
		failed.append("%s: expected > %f, got %f" % [label, threshold, actual])


func lt(actual: float, threshold: float, label: String) -> void:
	if actual < threshold:
		passed += 1
	else:
		failed.append("%s: expected < %f, got %f" % [label, threshold, actual])


func non_null(value, label: String) -> void:
	if value != null:
		passed += 1
	else:
		failed.append("%s: expected non-null" % label)


func is_null(value, label: String) -> void:
	if value == null:
		passed += 1
	else:
		failed.append("%s: expected null, got %s" % [label, str(value)])


func report(suite: String = "") -> Dictionary:
	return {"name": (suite if suite != "" else _suite), "passed": passed, "failed": failed}
