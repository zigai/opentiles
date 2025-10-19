class_name GridTileField
extends TileField

signal black_tile_pressed(index: int)
signal white_tile_pressed(index: int)

var config: GridModeConfig
var black_indices: Array[int] = []
var available_indices: Array[int] = []

var _safe_area: Rect2 = Rect2()
var _grid_start: Vector2 = Vector2.ZERO
var _background_panel: Panel
var _grid_gap_rect: ColorRect

# --------------------------------------------------------------------------------------------------

func initialize(mode_config: GridModeConfig) -> void:
	config = mode_config
	if config == null:
		push_error("GridTileField: Config is null")
		return
	_build_layout()
	tile_pressed.connect(_handle_tile_pressed)


func show_feedback(index: int, color: Color, post_color: Color = Globals.TILE_COLOR_WHITE) -> void:
	play_feedback(index, color, Globals.TILE_CLICK_INDICATOR_TIME, post_color)


func replace_black_tile(index: int) -> void:
	_set_tile_white(index)
	var new_index: int = _pick_random_white_tile()
	if new_index >= 0:
		_set_tile_black(new_index)


func pick_random_white_tile() -> int:
	return _pick_random_white_tile()


func set_tile_black(index: int) -> void:
	_set_tile_black(index)


func set_tile_white(index: int) -> void:
	_set_tile_white(index)


func is_tile_black(index: int) -> bool:
	return index in black_indices


func has_black_tiles() -> bool:
	return not black_indices.is_empty()

# --------------------------------------------------------------------------------------------------

func _build_layout() -> void:
	_clear_state()
	_available_indices_setup()
	_cache_safe_area()
	var tile_side: float = _calculate_tile_size()
	if tile_side <= 0.0:
		return
	var tile_count: int = config.GRID_SIZE * config.GRID_SIZE
	var indices: Array[int] = []
	for n in range(tile_count):
		indices.append(n)
	var grid_span: float = (tile_side * config.GRID_SIZE) + (Globals.TILE_SPACING * (config.GRID_SIZE - 1))
	var grid_rect: Rect2 = Rect2(_grid_start, Vector2(grid_span, grid_span))
	_update_background_panel(grid_rect)
	build(Vector2(tile_side, tile_side), indices)
	_set_initial_black_tiles()


func _available_indices_setup() -> void:
	available_indices.clear()
	var total: int = config.GRID_SIZE * config.GRID_SIZE
	for i in range(total):
		available_indices.append(i)


func _clear_state() -> void:
	black_indices.clear()
	available_indices.clear()
	clear_field()


func _cache_safe_area() -> void:
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	var horizontal_margin: float = viewport_rect.size.x * Globals.GRID_HORIZONTAL_MARGIN_RATIO
	var top_margin: float = viewport_rect.size.y * Globals.GRID_TOP_MARGIN_RATIO
	var bottom_margin: float = viewport_rect.size.y * Globals.GRID_BOTTOM_MARGIN_RATIO

	var width: float = viewport_rect.size.x - (horizontal_margin * 2.0)
	var height: float = viewport_rect.size.y - (top_margin + bottom_margin)

	_safe_area = Rect2(
		Vector2(horizontal_margin, top_margin),
		Vector2(max(width, 0.0), max(height, 0.0))
	)


func _calculate_tile_size() -> float:
	var grid_span: float = min(_safe_area.size.x, _safe_area.size.y)
	var total_spacing: float = Globals.TILE_SPACING * (config.GRID_SIZE - 1)

	var denominator: int = config.GRID_SIZE
	if denominator <= 0:
		push_error("GridTileField: Invalid grid size")
		return -1.0

	var size: float = (grid_span - total_spacing) / denominator
	if size <= 0.0:
		push_error("GridTileField: Calculated tile size is non-positive")
		return -1.0

	var grid_width: float = (size * config.GRID_SIZE) + (Globals.TILE_SPACING * (config.GRID_SIZE - 1))
	_grid_start = _safe_area.position + (_safe_area.size - Vector2(grid_width, grid_width)) * 0.5
	return size


func _setup_tile_position(tile: Area2D, index: int) -> void:
	var row: int = index / config.GRID_SIZE
	var col: int = index % config.GRID_SIZE
	var offset: Vector2 = Vector2(col, row) * (tile_size.x + Globals.TILE_SPACING)
	tile.position = _grid_start + offset + tile_size * 0.5


func _set_initial_black_tiles() -> void:
	for _i in range(config.BLACK_TILE_COUNT):
		var index: int = _pick_random_white_tile()
		if index >= 0:
			_set_tile_black(index)


func _pick_random_white_tile() -> int:
	if available_indices.is_empty():
		return -1
		
	var random_index: int = randi() % available_indices.size()
	var index: int = available_indices[random_index]
	available_indices.remove_at(random_index)
	return index


func _set_tile_black(index: int) -> void:
	if index in black_indices:
		return

	black_indices.append(index)
	if index in available_indices:
		available_indices.erase(index)
	set_tile_color(index, Globals.TILE_COLOR_BLACK)


func _set_tile_white(index: int) -> void:
	if index in black_indices:
		black_indices.erase(index)
	if index not in available_indices:
		available_indices.append(index)
	set_tile_color(index, Globals.TILE_COLOR_WHITE)


func _handle_tile_pressed(index: int) -> void:
	if index in black_indices:
		black_tile_pressed.emit(index)
	else:
		white_tile_pressed.emit(index)


func _update_background_panel(grid_rect: Rect2) -> void:
	var padding: float = 24.0
	var panel_rect: Rect2 = Rect2(
		grid_rect.position - Vector2(padding, padding),
		grid_rect.size + Vector2(padding * 2.0, padding * 2.0)
	)
	if _background_panel == null or not is_instance_valid(_background_panel):
		_background_panel = Panel.new()
		_background_panel.name = "GridBackdrop"
		_background_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_background_panel.z_index = -10
		
		var stylebox: StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = Color(0.980392, 0.988235, 1.0, 1.0)
		stylebox.border_color = Color(0.780392, 0.823529, 0.917647, 1.0)
		stylebox.border_width_top = 8
		stylebox.border_width_bottom = 8
		stylebox.border_width_left = 8
		stylebox.border_width_right = 8
		stylebox.corner_radius_top_left = 20
		stylebox.corner_radius_top_right = 20
		stylebox.corner_radius_bottom_left = 20
		stylebox.corner_radius_bottom_right = 20
		
		_background_panel.add_theme_stylebox_override("panel", stylebox)
		add_child(_background_panel)
		move_child(_background_panel, 0)
	
	if _background_panel:
		_background_panel.position = panel_rect.position
		_background_panel.set_size(panel_rect.size)

	if _grid_gap_rect == null or not is_instance_valid(_grid_gap_rect):
		_grid_gap_rect = ColorRect.new()
		_grid_gap_rect.name = "GridGap"
		_grid_gap_rect.color = Color(0, 0, 0, 1)
		_grid_gap_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_grid_gap_rect.z_index = -5
		add_child(_grid_gap_rect)
		move_child(_grid_gap_rect, 1)

	var gap: float = Globals.TILE_SPACING
	_grid_gap_rect.position = grid_rect.position - Vector2(gap, gap)
	_grid_gap_rect.size = grid_rect.size + Vector2(gap * 2.0, gap * 2.0)
