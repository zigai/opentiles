class_name ClassicModeConfig
extends ModeConfig

var LANE_COUNT: int = 4
var SCROLL_SPEED: float = 300.0
var SPAWN_RATE: float = 1.0
var PLACER_TYPE: Globals.MovingPlacerType = Globals.MovingPlacerType.SIMPLE
var SCORE_TYPE: Globals.MovingScoreType = Globals.MovingScoreType.TIME

# --------------------------------------------------------------------------------------------------

func is_valid() -> bool:
	if LANE_COUNT < 1 or LANE_COUNT > 10:
		return false
	if SCROLL_SPEED <= 0.0:
		return false
	if SPAWN_RATE <= 0.0:
		return false
	return true


func get_key() -> String:
	return "%s.%d.%f.%f.%d.%d" % [
		Globals.GameMode.keys()[GAME_MODE],
		LANE_COUNT,
		SCROLL_SPEED,
		SPAWN_RATE,
		PLACER_TYPE,
		SCORE_TYPE,
	]

func copy() -> ClassicModeConfig:
	var cfg = ClassicModeConfig.new()
	cfg.GAME_MODE = GAME_MODE
	cfg.LANE_COUNT = LANE_COUNT
	cfg.SCROLL_SPEED = SCROLL_SPEED
	cfg.SPAWN_RATE = SPAWN_RATE
	cfg.PLACER_TYPE = PLACER_TYPE
	cfg.SCORE_TYPE = SCORE_TYPE
	return cfg
