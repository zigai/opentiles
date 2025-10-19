class_name GridModeConfig
extends ModeConfig

var PENALTY_TYPE: Globals.PenaltyType = Globals.PenaltyType.INSTANT_DEATH
var OBJECTIVE_TYPE: Globals.ObjectiveType = Globals.ObjectiveType.TIMER
var TILE_PLACER_TYPE: Globals.TilePlacerType = Globals.TilePlacerType.INSTANT

var GRID_SIZE: int = 4
var BLACK_TILE_COUNT: int = 4
var TIME_LIMIT: float = -1
var POINTS_GOAL: int = -1


func _init() -> void:
	GAME_MODE = Globals.GameMode.FRENZY
	PENALTY_TYPE = Globals.PenaltyType.INSTANT_DEATH
	OBJECTIVE_TYPE = Globals.ObjectiveType.TIMER

# --------------------------------------------------------------------------------------------------

func is_valid() -> bool:
	if GRID_SIZE < 2 or GRID_SIZE > 12:
		return false
	if BLACK_TILE_COUNT >= (GRID_SIZE * GRID_SIZE):
		return false
	return true

func get_key() -> String:
	return "%s.%s.%s.%s.%d.%d.%d.%d" % [
		Globals.GameMode.keys()[GAME_MODE],
		Globals.PenaltyType.keys()[PENALTY_TYPE],
		Globals.ObjectiveType.keys()[OBJECTIVE_TYPE],
		Globals.TilePlacerType.keys()[TILE_PLACER_TYPE],
		GRID_SIZE,
		BLACK_TILE_COUNT,
		TIME_LIMIT,
		POINTS_GOAL,
	]

func copy() -> GridModeConfig:
	var cfg = GridModeConfig.new()
	cfg.GAME_MODE = GAME_MODE
	cfg.PENALTY_TYPE = PENALTY_TYPE
	cfg.OBJECTIVE_TYPE = OBJECTIVE_TYPE
	cfg.TILE_PLACER_TYPE = TILE_PLACER_TYPE
	cfg.GRID_SIZE = GRID_SIZE
	cfg.BLACK_TILE_COUNT = BLACK_TILE_COUNT
	cfg.TIME_LIMIT = TIME_LIMIT
	cfg.POINTS_GOAL = POINTS_GOAL
	return cfg
