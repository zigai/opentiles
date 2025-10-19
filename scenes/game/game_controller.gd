extends Node2D

const ButtonStyler := preload("res://src/ui/styling/button_styler.gd")

var _config: ModeConfig
var _mode: Node2D
var _overlay: GameOverOverlay

@onready var label_score: Label = $"HUD/Root/Layout/StatsCard/Margin/StatsGrid/ScoreStat/Value"
@onready var label_multiplier: Label = $"HUD/Root/Layout/StatsCard/Margin/StatsGrid/MultiplierStat/Value"
@onready var label_timer: Label = $"HUD/Root/Layout/StatsCard/Margin/StatsGrid/TimeStat/Value"
@onready var label_best: Label = $"HUD/Root/Layout/StatsCard/Margin/StatsGrid/BestStat/Value"

# --------------------------------------------------------------------------------------------------

func start_with_config(config: ModeConfig) -> void:
	_config = config
	_reset_hud()
	_instantiate_mode()
	_connect_mode_signals()
	if _mode and _mode.has_method("initialize"):
		_mode.call_deferred("initialize", _config)

# --------------------------------------------------------------------------------------------------

func _reset_hud() -> void:
	if label_score:
		label_score.text = "0"
	if label_multiplier:
		label_multiplier.text = "x1"
	if label_timer:
		label_timer.text = _get_initial_time_display()
	_update_best_score()

func _get_initial_time_display() -> String:
	var initial_time: float = _get_initial_time_limit()
	if initial_time > 0.0:
		return _format_time(initial_time)
	return "--:--"

func _get_initial_time_limit() -> float:
	if _config is GridModeConfig:
		var grid_config: GridModeConfig = _config
		if grid_config.TIME_LIMIT > 0.0:
			return grid_config.TIME_LIMIT
	return Globals.DEFAULT_TIME_LIMIT

func _update_best_score() -> void:
	if label_best == null or _config == null:
		return
	label_best.text = "0"
	if not has_node("/root/HighscoreStore"):
		return
	var store := get_node("/root/HighscoreStore") as HighscoreStoreManager
	if store == null:
		return
	var best_score: int = store.get_best(_config.get_key())
	label_best.text = str(best_score)

func _instantiate_mode() -> void:
	if _mode:
		_mode.queue_free()
	_mode = GameModeFactory.new().create(_config)
	add_child(_mode)

func _connect_mode_signals() -> void:
	_mode.game_over.connect(_on_game_over)
	if _mode.has_signal("score_changed"):
		_mode.score_changed.connect(_on_score_changed)
	if _mode.has_signal("multiplier_changed"):
		_mode.multiplier_changed.connect(_on_multiplier_changed)
	if _mode.has_signal("timer_changed"):
		_mode.timer_changed.connect(_on_timer_changed)
	if _mode.has_signal("lives_changed"):
		_mode.lives_changed.connect(_on_lives_changed)

func _on_score_changed(value: int) -> void:
	if label_score:
		label_score.text = str(value)

func _on_multiplier_changed(value: int) -> void:
	if label_multiplier:
		label_multiplier.text = "x%d" % value

func _on_timer_changed(value: float) -> void:
	if label_timer:
		label_timer.text = _format_time(value)

func _format_time(value: float) -> String:
	var safe_time: float = max(value, 0.0)
	var total_seconds: int = int(ceil(safe_time))
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]

func _on_lives_changed(value: int) -> void:
	pass

func _on_game_over(final_score: int, cause: Globals.GameOverCause) -> void:
	_ensure_overlay()
	if _overlay:
		var reason := _get_game_over_reason(cause)
		var run_info := ""
		# Submit high score if an autoload exists
		if has_node("/root/HighscoreStore"):
			var hs = get_node("/root/HighscoreStore")
			if hs and hs.has_method("submit"):
				var submit_result: HighscoreSubmitResult = hs.submit(_config.get_key(), final_score)
				run_info = _build_run_info_message(submit_result)
		_overlay.call_deferred("show_game_over_ui", final_score, reason, run_info)
	_update_best_score()

func _ensure_overlay() -> void:
	if _overlay and is_instance_valid(_overlay):
		_connect_overlay_buttons()
		_overlay.show()
		return
	var overlay_scene: PackedScene = load("res://scenes/game/game_over_overlay.tscn")
	var overlay_instance: Node = overlay_scene.instantiate()
	if overlay_instance is GameOverOverlay:
		_overlay = overlay_instance as GameOverOverlay
	else:
		push_error("GameController: GameOverOverlay scene missing script")
		return
	_overlay.hide()

	var hud_layer: Node = get_node_or_null("HUD")
	if hud_layer:
		hud_layer.add_child(_overlay)
	else:
		get_tree().root.add_child(_overlay)
	_connect_overlay_buttons()


func _connect_overlay_buttons() -> void:
	if _overlay == null:
		return
	var buttons_container: Node = _overlay.get_node_or_null("Panel/Margin/Layout/Buttons")
	if buttons_container == null:
		return
	var play_again_button: Button = buttons_container.get_node_or_null("PlayAgainButton") as Button
	var main_menu_button: Button = buttons_container.get_node_or_null("MainMenuButton") as Button
	if play_again_button and not play_again_button.pressed.is_connected(_on_play_again_pressed):
		play_again_button.pressed.connect(_on_play_again_pressed)
	if main_menu_button and not main_menu_button.pressed.is_connected(_on_main_menu_pressed):
		main_menu_button.pressed.connect(_on_main_menu_pressed)
	# Apply primary styling to match main menu
	if play_again_button:
		ButtonStyler.apply_primary_style(play_again_button)
		ButtonStyler.attach_interactions(play_again_button)
	if main_menu_button:
		ButtonStyler.apply_primary_style(main_menu_button)
		ButtonStyler.attach_interactions(main_menu_button)

func _on_play_again_pressed() -> void:
	if _overlay:
		_overlay.hide()
	start_with_config(_config)

func _on_main_menu_pressed() -> void:
	if _overlay:
		_overlay.hide()
	var main_menu_scene = load("res://scenes/main_menu/main_menu.tscn")
	get_tree().change_scene_to_packed(main_menu_scene)

func _get_game_over_reason(cause: Globals.GameOverCause) -> String:
	match cause:
		Globals.GameOverCause.WRONG_TILE:
			return "You tapped a white tile!"
		Globals.GameOverCause.LIVES_DEPLETED:
			return "All lives lost!"
		_:
			return ""

func _build_run_info_message(result: HighscoreSubmitResult) -> String:
	if result == null:
		return ""
	var messages: Array[String] = []
	if result.is_new_high_score:
		messages.append("New high score!")
	elif result.is_listed and result.rank > 0:
		messages.append("Ranked #%d." % result.rank)
	return " ".join(messages)
