class_name GameModeFactory
extends RefCounted


const GRID_MODE_CONTROLLER_SCENE := preload("res://src/modes/grid/base/grid_mode_controller.gd")
const GRID_FRENZY_MODE_SCENE := preload("res://src/modes/grid/modes/frenzy_mode.gd")
const CLASSIC_MODE_CONTROLLER_SCENE := preload("res://src/modes/classic/base/classic_mode_controller.gd")


# --------------------------------------------------------------------------------------------------

func create(config: ModeConfig) -> BaseGameMode:
	if config == null:
		push_error("GameModeFactory.create: config is null")
		return null

	if config is GridModeConfig:
		var grid_cfg: GridModeConfig = config
		match grid_cfg.GAME_MODE:
			Globals.GameMode.FRENZY:
				return GRID_FRENZY_MODE_SCENE.new()
			Globals.GameMode.KEYBOARD:
				return GRID_MODE_CONTROLLER_SCENE.new()
			Globals.GameMode.NUMPAD:
				return GRID_MODE_CONTROLLER_SCENE.new()
			_:
				return GRID_MODE_CONTROLLER_SCENE.new()

	if config is ClassicModeConfig:
		push_warning("GameModeFactory: Classic mode support is not implemented yet")
		return CLASSIC_MODE_CONTROLLER_SCENE.new()

	return BaseGameMode.new()
