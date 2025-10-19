class_name GridModeController
extends BaseGameMode

signal score_changed(value: int)
signal multiplier_changed(value: int)
signal timer_changed(value: float)
signal lives_changed(value: int)

var state: GridRunState
var config: GridModeConfig

var tile_field: GridTileField
var tile_placer: TilePlacer
var penalty: Penalty
var objective: Objective

var countdown_label: Label
var countdown_timer: Timer
var countdown_time_left: int = Globals.GAME_START_COUNTDOWN_TIME
var is_countdown_active: bool = false
var lives: int = 3

# --------------------------------------------------------------------------------------------------

func initialize(mode_config: ModeConfig) -> void:
	if not (mode_config is GridModeConfig):
		push_error("GridModeController: Expected GridModeConfig")
		return
	config = mode_config
	state = GridRunState.new()
	state.config = config
	_setup_tile_field()
	_setup_tile_placer()
	_setup_penalty()
	_setup_objective()
	_create_countdown_display()
	_start_countdown()
	score_changed.emit(0)
	multiplier_changed.emit(1)
	if objective and objective.has_method("get_time_left"):
		timer_changed.emit(objective.get_time_left())


func trigger_game_over(final_score: int = 0, cause: Globals.GameOverCause=Globals.GameOverCause.UNKNOWN) -> void:
	is_game_over = true
	if objective and config.OBJECTIVE_TYPE == Globals.ObjectiveType.TIMER:
		if objective.has_method("stop"):
			objective.stop()
	super.trigger_game_over(state.score, cause)

# --------------------------------------------------------------------------------------------------

func _setup_tile_field() -> void:
	tile_field = GridTileField.new()
	add_child(tile_field)
	tile_field.initialize(config)
	tile_field.black_tile_pressed.connect(_on_black_tile_pressed)
	tile_field.white_tile_pressed.connect(_on_white_tile_pressed)


func _setup_tile_placer() -> void:
	match config.TILE_PLACER_TYPE:
		Globals.TilePlacerType.INSTANT:
			tile_placer = InstantTilePlacer.new()
		Globals.TilePlacerType.DELAYED:
			tile_placer = DelayedTilePlacer.new()
	if tile_placer == null:
		push_error("GridModeController: Missing tile placer")


func _setup_penalty() -> void:
	match config.PENALTY_TYPE:
		Globals.PenaltyType.INSTANT_DEATH:
			penalty = InstantDeathPenalty.new()


func _setup_objective() -> void:
	match config.OBJECTIVE_TYPE:
		Globals.ObjectiveType.TIMER:
			objective = TimeLimit.new(Globals.DEFAULT_TIME_LIMIT)
			add_child(objective)
			objective.timer_finished.connect(_on_timer_finished)
			objective.timer_updated.connect(_on_timer_updated)


func _create_countdown_display() -> void:
	var canvas_layer: CanvasLayer = CanvasLayer.new()
	get_tree().current_scene.add_child(canvas_layer)
	countdown_label = Label.new()
	countdown_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	var label_settings: LabelSettings = LabelSettings.new()
	label_settings.font_color = Globals.GAME_START_COUNTDOWN_COLOR
	label_settings.font_size = Globals.GAME_START_COUNTDOWN_FONT_SIZE
	countdown_label.label_settings = label_settings
	countdown_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	countdown_label.hide()
	canvas_layer.add_child(countdown_label)


func _start_countdown() -> void:
	is_countdown_active = true
	countdown_time_left = Globals.GAME_START_COUNTDOWN_TIME
	countdown_label.text = str(countdown_time_left)
	countdown_label.show()

	countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0
	countdown_timer.timeout.connect(_on_countdown_tick)
	add_child(countdown_timer)
	countdown_timer.start()


func _on_countdown_tick() -> void:
	countdown_time_left -= 1
	if countdown_time_left > 0:
		countdown_label.text = str(countdown_time_left)
	else:
		countdown_label.hide()
		countdown_timer.queue_free()
		is_countdown_active = false
		if objective:
			objective.start()


func _on_black_tile_pressed(index: int) -> void:
	if not _can_accept_input():
		return
	state.record_black_tile_press()
	if tile_placer:
		tile_placer.place_tiles(tile_field, index)
		
	tile_field.show_feedback(index, Globals.TILE_COLOR_CORRECT, Globals.TILE_COLOR_WHITE)
	score_changed.emit(state.score)
	multiplier_changed.emit(state.multiplier)


func _on_white_tile_pressed(index: int) -> void:
	if not _can_accept_input():
		return
	tile_field.show_feedback(index, Globals.TILE_COLOR_WRONG, Globals.TILE_COLOR_WHITE)
	if penalty:
		penalty.apply_penalty(self)


func _can_accept_input() -> bool:
	return not is_game_over and not is_countdown_active


func _on_timer_updated(time_left: float) -> void:
	timer_changed.emit(time_left)


func _on_timer_finished() -> void:
	trigger_game_over(state.score, Globals.GameOverCause.TIME_OUT)
