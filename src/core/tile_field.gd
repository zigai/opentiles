class_name TileField
extends Node2D

signal tile_pressed(index: int)
signal tile_feedback_finished(index: int)

var tile_size: Vector2 = Vector2.ZERO
var tiles: Array[Area2D] = []
var _tile_lookup: Dictionary = {}

# --------------------------------------------------------------------------------------------------

func build(tile_dimensions: Vector2, tile_indices: Array[int]) -> void:
	_clear_tiles()
	tile_size = tile_dimensions

	for index in tile_indices:
		var tile: Area2D = _create_tile(index)
		_setup_tile_position(tile, index)
		tiles.append(tile)
		_tile_lookup[index] = tile
		add_child(tile)


func set_tile_color(index: int, color: Color) -> void:
	var tile: Area2D = _get_tile(index)
	if tile == null:
		return
	var sprite: ColorRect = tile.get_node("Surface") as ColorRect
	if sprite:
		sprite.color = color


func play_feedback(index: int, highlight_color: Color, duration: float = Globals.TILE_CLICK_INDICATOR_TIME, post_color: Variant = null) -> void:
	var tile: Area2D = _get_tile(index)
	if tile == null:
		return
	var sprite: ColorRect = tile.get_node("Surface") as ColorRect
	if sprite == null:
		return
	var original_color: Color = sprite.color
	sprite.color = highlight_color
	var timer: Timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(func():
		if post_color != null:
			sprite.color = post_color
		else:
			sprite.color = original_color
		tile_feedback_finished.emit(index)
		timer.queue_free()
	)
	add_child(timer)
	timer.start()


func clear_field() -> void:
	_clear_tiles()

# --------------------------------------------------------------------------------------------------

func _create_tile(index: int) -> Area2D:
	var area: Area2D = Area2D.new()
	area.name = "Tile_%d" % index
	var sprite: ColorRect = ColorRect.new()
	sprite.name = "Surface"
	sprite.color = Globals.TILE_COLOR_WHITE
	sprite.size = tile_size
	sprite.position = - tile_size * 0.5
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	area.add_child(sprite)

	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = tile_size
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.shape = shape
	area.add_child(collision)
	area.input_pickable = true

	area.input_event.connect(_on_tile_input.bind(index))
	return area


func _setup_tile_position(_tile: Area2D, _index: int) -> void:
	pass


func _clear_tiles() -> void:
	for tile in tiles:
		if is_instance_valid(tile):
			tile.queue_free()
	tiles.clear()
	_tile_lookup.clear()


func _on_tile_input(_viewport: Node, event: InputEvent, _shape_idx: int, index: int) -> void:
	var pressed: bool = false
	if event is InputEventMouseButton:
		pressed = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		pressed = event.pressed
	if not pressed:
		return
	tile_pressed.emit(index)


func _get_tile(index: int) -> Area2D:
	if not _tile_lookup.has(index):
		return null
	return _tile_lookup[index]
