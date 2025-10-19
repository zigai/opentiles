class_name ModeConfig
extends RefCounted


var GAME_MODE: int = -1

# --------------------------------------------------------------------------------------------------

func is_valid() -> bool:
	return true

func get_key() -> String:
	if GAME_MODE < 0 or GAME_MODE >= Globals.GameMode.size():
		return "undefined"
	return Globals.GameMode.keys()[GAME_MODE]

func copy() -> ModeConfig:
	var script = get_script()
	var copy: ModeConfig = script.new()
	copy.GAME_MODE = GAME_MODE
	return copy
