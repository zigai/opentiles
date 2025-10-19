class_name GameOverOverlay
extends Control

@onready var reason_label: Label = get_node_or_null("Panel/Margin/Layout/GameOverLabel")
@onready var score_label: Label = get_node_or_null("Panel/Margin/Layout/ScoreLabel")
@onready var run_info_label: Label = get_node_or_null("Panel/Margin/Layout/RunInfoLabel")

var _default_reason_text: String = ""

func _ready() -> void:
	if reason_label:
		_default_reason_text = reason_label.text
	if run_info_label:
		run_info_label.hide()

# --------------------------------------------------------------------------------------------------

func show_game_over_ui(final_score: int, reason: String, run_info: String = "") -> void:
	if reason_label:
		if reason.is_empty():
			reason_label.text = _default_reason_text
		else:
			reason_label.text = reason
	
	if score_label:
		score_label.text = "Score: " + str(final_score)
	
	if run_info_label:
		if run_info.is_empty():
			run_info_label.text = ""
			run_info_label.hide()
		else:
			run_info_label.text = run_info
			run_info_label.show()
	
	show()

func hide_game_over() -> void:
	hide()
