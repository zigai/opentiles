class_name GridRunState
extends BaseState

var score: int = 0
var multiplier: int = 1

# --------------------------------------------------------------------------------------------------

func add_score(points: int) -> void:
	score += points * multiplier

func record_black_tile_press() -> void:
	var current_time := Time.get_ticks_msec() / 1000.0
	record_timestamp(current_time)
	multiplier = get_multiplier()
	add_score(1)

func get_multiplier() -> int:
	if delays.is_empty():
		return 1
	var avg_delay: float = get_average_delay()
	var thresholds := [
		[0.1, 10],
		[0.15, 8],
		[0.2, 5],
		[0.25, 4],
		[0.3, 3],
		[0.4, 2],
	]
	for threshold in thresholds:
		if avg_delay <= threshold[0]:
			return threshold[1]
	return 1

func reset() -> void:
	super.reset()
	score = 0
	multiplier = 1
