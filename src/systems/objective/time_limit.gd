class_name TimeLimit
extends Objective

signal timer_finished
signal timer_updated(time_left: float)

var timer: Timer
var duration: float
var time_left: float
var is_started: bool = false

# --------------------------------------------------------------------------------------------------

func _init(timer_duration: float = 30.0) -> void:
	duration = timer_duration
	time_left = duration


func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)


func _process(_delta: float) -> void:
	if timer and not timer.is_stopped() and is_started:
		time_left = timer.time_left
		timer_updated.emit(time_left)

# --------------------------------------------------------------------------------------------------

func start() -> void:
	time_left = duration
	is_started = true
	timer.start()


func stop() -> void:
	if timer and not timer.is_stopped():
		timer.stop()
	is_started = false


func get_time_left() -> float:
	if is_started and timer and not timer.is_stopped():
		return timer.time_left
	return duration


func get_time_left_formatted() -> String:
	return "%.1f" % time_left

# --------------------------------------------------------------------------------------------------

func _on_timer_timeout() -> void:
	timer_finished.emit()
