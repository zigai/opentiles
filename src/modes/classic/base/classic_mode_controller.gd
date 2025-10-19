class_name ClassicModeController
extends BaseGameMode

signal score_changed(value: int)
signal timer_changed(value: float)

var config: ClassicModeConfig

# --------------------------------------------------------------------------------------------------

func initialize(mode_config: ModeConfig) -> void:
	if not (mode_config is ClassicModeConfig):
		push_error("ClassicModeController: Expected ClassicModeConfig")
		return
	config = mode_config
	push_warning("Classic modes are not implemented yet")
	score_changed.emit(0)
	timer_changed.emit(0.0)
