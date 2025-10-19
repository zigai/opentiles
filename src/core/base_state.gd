class_name BaseState
extends RefCounted

var config: ModeConfig
var last_black_tile_press_time: float = 0.0
var delays: Array[float] = []

# --------------------------------------------------------------------------------------------------

func record_timestamp(current_time: float) -> void:
	if last_black_tile_press_time > 0.0:
		var delay := current_time - last_black_tile_press_time
		delays.append(delay)
	last_black_tile_press_time = current_time

func get_average_delay() -> float:
	if delays.is_empty():
		return 0.0
	
	var total: float = 0.0
	for delay in delays:
		total += delay
	
	return total / delays.size()

func reset() -> void:
	last_black_tile_press_time = 0.0
	delays.clear()
