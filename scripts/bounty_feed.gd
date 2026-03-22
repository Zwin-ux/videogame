extends RefCounted
class_name BountyFeed

const TERMINAL_ENTRIES := [
	{"id": "contract", "title": "BEGIN PURGE", "subtitle": "Open the extermination order."},
	{"id": "dossier", "title": "DOSSIER", "subtitle": "Shell rack and purge notes."},
	{"id": "ledger", "title": "LEDGER", "subtitle": "Region status and kill totals."},
	{"id": "systems", "title": "SYSTEMS", "subtitle": "Audio, glass, prompts, and input."},
	{"id": "credits", "title": "CREDITS", "subtitle": "Crew and fabrication."},
	{"id": "quit", "title": "QUIT", "subtitle": "Power down the board."},
]

const ATTRACT_REPORTS := [
	{
		"eyebrow": "ORBIT LANE 04",
		"title": "KHEPRI-9 is a wound now.",
		"body": "The dock only survived because the upper shelf is still holding against the infestation.",
		"tag": "Surface still visible.",
	},
	{
		"eyebrow": "PURGE ORDER",
		"title": "Every region stays alive until its anchor nests die.",
		"body": "Breaking loose enemies is not enough. Each major zone has to be gutted at the root.",
		"tag": "Anchor kills matter.",
	},
	{
		"eyebrow": "SURFACE FEED",
		"title": "The skyline still stands above the breach.",
		"body": "If the shaft is purged, the old ruin bridges and spires can be reached from the sanctuary shelf.",
		"tag": "Second region confirmed.",
	},
	{
		"eyebrow": "FIELD ADVISORY",
		"title": "Close cuts still open routes faster than safe fire.",
		"body": "The planet only dies if you keep moving and kill the core tissue, not the noise around it.",
		"tag": "Mobility is survival.",
	},
]

const TICKER_LINES := [
	"PURGE THE ANCHORS // THE REGION ONLY DIES WHEN THE CORE DIES",
	"SANCTUARY STILL HOLDS // THE PLANET DOES NOT",
	"BLADE KILLS OPEN SPACE // RANGE KEEPS LANES CLEAN",
	"THE SHAFT IS ONLY THE FIRST WOUND",
	"CORE ACCESS STAYS SEALED UNTIL THE OUTER REGIONS ARE CLEANSED",
]

const CREDIT_RATES := {
	"bug": 35,
	"rival": 1100,
	"clear_bonus": 2400,
}

const BOSS_DUEL_LINES := [
	{"speaker": "BROOD WARDEN", "line": "The shaft still feeds. Cut deeper if you want it dead."},
	{"speaker": "KILLER QUEEN", "line": "I am not climbing. I am gutting the planet."},
	{"speaker": "SPIRE MATRIARCH", "line": "The surface still belongs to the swarm above you."},
	{"speaker": "KILLER QUEEN", "line": "Then I kill the height and everything under it."},
]


static func get_terminal_entries() -> Array:
	return TERMINAL_ENTRIES.duplicate(true)


static func get_attract_reports() -> Array:
	return ATTRACT_REPORTS.duplicate(true)


static func get_ticker_lines() -> Array:
	return TICKER_LINES.duplicate()


static func get_credit_rates() -> Dictionary:
	return CREDIT_RATES.duplicate(true)


static func get_contract_fields() -> Array:
	return [
		{"label": "WORLD", "value": "KHEPRI-9 // breach sanctuary"},
		{"label": "PURGE", "value": "Hive Shaft first // skyline next"},
		{"label": "GOAL", "value": "Kill anchors // kill apex"},
		{"label": "RISK", "value": "Pod surge // planetary spread"},
	]


static func get_market_board(records: Dictionary) -> Array[String]:
	var bugs := int(records.get("bugs_liquidated", 0))
	var rivals := int(records.get("rival_clears", 0))
	var gross := format_credits(calculate_gross_claim(bugs, rivals, bool(records.get("full_clear", false))))
	return [
		"PURGE BOARD // LIVE",
		"TISSUE CUT // %sc" % CREDIT_RATES["bug"],
		"APEX BONUS // %sc" % CREDIT_RATES["rival"],
		"KILL LEDGER // %s" % gross,
	]


static func get_run_opening_message(mode: String) -> String:
	if mode == "gun":
		return "Sky dock clear. Dock Blaster live. Keep lanes open and burn the anchor tissue."
	return "Sky dock clear. Arc Cutter live. Climb hard and cut straight into the nests."


static func get_cave_transfer_message() -> String:
	return "Brood breach exposed. The first apex core is deeper in the chamber."


static func get_cave_entry_message() -> String:
	return "Apex chamber hot. Break the Warden and the shaft will start to die."


static func get_outro_transfer_message() -> String:
	return "Skyline route exposed. Push east and prove the planet is bigger than the shaft."


static func get_rival_down_message() -> String:
	return "Apex tissue broken. The region is finally starting to open."


static func get_salvage_unlock_message(mode: String) -> String:
	if mode == "gun":
		return "Pressure Chamber installed. Dock Blaster now carries harder through the lane."
	return "Edge Drive installed. Arc Cutter cuts deeper and hits harder."


static func get_failure_message() -> String:
	return "Purge failed. Sanctuary can still throw you back in."


static func get_failure_receipt() -> Dictionary:
	return {
		"title": "PURGE FAILED",
		"body": "The region kept breathing. Reset at sanctuary and cut back in.",
		"footer": "Auto redeploy in 0.3 seconds.",
	}


static func get_clear_receipt(best_altitude: int, bugs: int, rivals: int, full_clear: bool) -> Dictionary:
	var gross := format_credits(calculate_gross_claim(bugs, rivals, full_clear))
	return {
		"title": "ALPHA COMPLETE",
		"body": "Hive Shaft and Sunset Ruin Skyline are down. The rest of KHEPRI-9 is now on the glass.",
		"footer": "Kills %s // best climb %dm" % [gross, best_altitude],
	}


static func get_boss_duel_lines() -> Array:
	return BOSS_DUEL_LINES.duplicate(true)


static func get_dossier_note(runs_started: int, best_altitude: int) -> String:
	if runs_started < 3:
		return "Fresh frame. Sanctuary still barely knows your pattern."
	if best_altitude < 180:
		return "Short-burn hunter. Still learning the wound."
	if best_altitude < 320:
		return "Cuts through live tissue and keeps climbing."
	return "Sanctuary knows the frame. The planet does too."


static func get_ledger_callout(records: Dictionary) -> String:
	if bool(records.get("full_clear", false)):
		return "Full clear on file. Night Queen released."
	var skyline_clears := int(records.get("skyline_regions_cleansed", 0))
	if skyline_clears > 0:
		return "Alpha purge logged. More regions are now visible from sanctuary."
	var hive_clears := int(records.get("hive_regions_cleansed", 0))
	if hive_clears > 0:
		return "Hive Shaft marked cleansed. Skyline route now matters."
	return "Night Queen still sealed."


static func get_region_anchor_message(region_name: String, remaining: int) -> String:
	if remaining <= 0:
		return "%s anchors broken. Apex core is now exposed." % region_name
	return "%s anchor down. %d core nests still feeding." % [region_name, remaining]


static func get_region_unlock_message(region_name: String) -> String:
	return "%s is exposed. Push to the apex and kill it clean." % region_name


static func get_region_cleansed_message(region_name: String) -> String:
	return "%s cleansed. The planet just lost one more wound." % region_name


static func get_alpha_promise_lines() -> Array[String]:
	return [
		"HIVE SHAFT // CLEANSED",
		"SUNSET RUIN SKYLINE // CLEANSED",
		"OVERGROWN FOUNDRY // INFESTED",
		"FLOODED TRANSIT // INFESTED",
		"ROYAL ARMORY // INFESTED",
		"QUEEN'S CORE // SEALED",
	]


static func calculate_gross_claim(bugs_liquidated: int, rival_clears: int, full_clear: bool) -> int:
	var gross: int = maxi(0, bugs_liquidated) * int(CREDIT_RATES["bug"])
	gross += maxi(0, rival_clears) * int(CREDIT_RATES["rival"])
	if full_clear:
		gross += int(CREDIT_RATES["clear_bonus"])
	return gross


static func format_credits(value: int) -> String:
	var remaining := str(max(0, value))
	var parts: Array[String] = []
	while remaining.length() > 3:
		parts.push_front(remaining.substr(remaining.length() - 3, 3))
		remaining = remaining.substr(0, remaining.length() - 3)
	parts.push_front(remaining)
	return "%sc" % ",".join(parts)
