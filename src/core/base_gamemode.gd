class_name BaseGameMode
extends Node2D

signal game_over(final_score: int, cause: Globals.GameOverCause)

var is_game_over: bool = false

func _ready() -> void:
	pass

# --------------------------------------------------------------------------------------------------

func initialize(_config: ModeConfig) -> void:
	pass

func trigger_game_over(final_score: int = 0, cause: Globals.GameOverCause=Globals.GameOverCause.UNKNOWN) -> void:
	is_game_over = true
	game_over.emit(final_score, cause)
