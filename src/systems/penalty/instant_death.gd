class_name InstantDeathPenalty
extends Penalty


func apply_penalty(gamemode: BaseGameMode) -> void:
	gamemode.trigger_game_over(0, Globals.GameOverCause.WRONG_TILE)

func get_name() -> String:
	return "Instant Death"

func get_description() -> String:
	return ""
