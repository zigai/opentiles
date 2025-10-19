extends RefCounted
class_name ButtonStyler

const MIN_HEIGHT := 120.0
const CORNER_RADIUS := 20
const HORIZONTAL_PADDING := 44.0
const VERTICAL_PADDING := 28.0
const BASE_COLOR := Color(0.07, 0.07, 0.09)
const SHADOW_COLOR := Color(0, 0, 0, 0.36)
const HOVER_LIGHTEN := 0.04
const PRESS_LIGHTEN := 0.015
const DISABLED_DARKEN := 0.2
const FONT_SIZE := 32
const HOVER_SCALE := Vector2(1.06, 1.06)
const PRESSED_SCALE := Vector2(0.98, 0.98)

const _INTERACTION_META := "ui_interactions_attached"
const _RESIZE_HOOK_META := "ui_resize_hook_attached"

# --------------------------------------------------------------------------------------------------

static func apply_primary_style(button: Button) -> void:
	if button == null or not is_instance_valid(button):
		return
	button.custom_minimum_size.y = max(button.custom_minimum_size.y, MIN_HEIGHT)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.scale = Vector2.ONE
	button.add_theme_font_size_override("font_size", FONT_SIZE)
	button.add_theme_color_override("font_color", Color(0.92, 0.94, 0.96))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
	button.add_theme_color_override("font_disabled_color", Color(0.6, 0.62, 0.64))
	button.add_theme_stylebox_override("normal", _create_stylebox(BASE_COLOR, SHADOW_COLOR, 4.0, Vector2(0, 3)))
	button.add_theme_stylebox_override("hover", _create_stylebox(BASE_COLOR.lightened(HOVER_LIGHTEN), SHADOW_COLOR, 12.0, Vector2(0, 6)))
	button.add_theme_stylebox_override("pressed", _create_stylebox(BASE_COLOR.lightened(PRESS_LIGHTEN), SHADOW_COLOR, 3.0, Vector2(0, 2)))
	button.add_theme_stylebox_override("focus", _create_stylebox(BASE_COLOR.lightened(HOVER_LIGHTEN * 0.8), SHADOW_COLOR, 10.0, Vector2(0, 5)))
	button.add_theme_stylebox_override("disabled", _create_stylebox(BASE_COLOR.darkened(DISABLED_DARKEN), SHADOW_COLOR, 0.0, Vector2.ZERO))
	update_pivot(button)


static func attach_interactions(button: Button) -> void:
	if button == null or not is_instance_valid(button):
		return
	if button.has_meta(_INTERACTION_META):
		return
	button.mouse_entered.connect(func() -> void: _handle_hover_enter(button))
	button.mouse_exited.connect(func() -> void: _handle_hover_exit(button))
	if button.has_signal("button_down"):
		button.button_down.connect(func() -> void: _handle_button_down(button))
	if button.has_signal("button_up"):
		button.button_up.connect(func() -> void: _handle_button_up(button))
	if not button.has_meta(_RESIZE_HOOK_META):
		button.resized.connect(func() -> void: update_pivot(button))
		button.set_meta(_RESIZE_HOOK_META, true)
	button.set_meta(_INTERACTION_META, true)


static func update_pivot(button: Button) -> void:
	if button == null or not is_instance_valid(button):
		return
	button.pivot_offset = button.size * 0.5


# --------------------------------------------------------------------------------------------------

static func _create_stylebox(bg_color: Color, shadow_color: Color, shadow_size: float, shadow_offset: Vector2) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg_color
	box.corner_radius_bottom_left = CORNER_RADIUS
	box.corner_radius_bottom_right = CORNER_RADIUS
	box.corner_radius_top_left = CORNER_RADIUS
	box.corner_radius_top_right = CORNER_RADIUS
	box.shadow_color = shadow_color
	box.shadow_size = shadow_size
	box.shadow_offset = shadow_offset
	box.set_content_margin(SIDE_LEFT, HORIZONTAL_PADDING)
	box.set_content_margin(SIDE_RIGHT, HORIZONTAL_PADDING)
	box.set_content_margin(SIDE_TOP, VERTICAL_PADDING)
	box.set_content_margin(SIDE_BOTTOM, VERTICAL_PADDING)
	box.border_width_bottom = 1
	box.border_width_left = 1
	box.border_width_right = 1
	box.border_width_top = 1
	box.border_color = bg_color.lightened(0.1)
	box.draw_center = true
	return box


static func _handle_hover_enter(button: Button) -> void:
	if button == null or not is_instance_valid(button):
		return
	button.scale = HOVER_SCALE


static func _handle_hover_exit(button: Button) -> void:
	if button == null or not is_instance_valid(button):
		return
	button.scale = Vector2.ONE


static func _handle_button_down(button: Button) -> void:
	if button == null or not is_instance_valid(button):
		return
	button.scale = PRESSED_SCALE


static func _handle_button_up(button: Button) -> void:
	if button == null or not is_instance_valid(button):
		return
	button.scale = HOVER_SCALE
