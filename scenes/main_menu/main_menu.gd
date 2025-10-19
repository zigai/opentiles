extends Control

const ButtonStyler := preload("res://src/ui/styling/button_styler.gd")

@onready var grid_button: Button = %GridButton
@onready var classic_button: Button = %ClassicButton
@onready var category_description_label: Label = %CategoryDescription
@onready var mode_buttons_container: VBoxContainer = %ModeButtons
@onready var mode_description_label: Label = %ModeDescription
@onready var feedback_label: Label = %FeedbackLabel
@onready var settings_button: TextureButton = %SettingsButton
@onready var quit_button: TextureButton = %QuitButton
@onready var category_buttons_container: HBoxContainer = $Layout/CategoryButtons
@onready var layout_container: VBoxContainer = $Layout
@onready var footer_container: HBoxContainer = $Layout/Footer
@onready var title_label: Label = $Layout/Title
@onready var subtitle_label: Label = $Layout/Subtitle
@onready var category_label: Label = $Layout/CategoryLabel


func _ready() -> void:
	feedback_label.text = ""
	_apply_layout_spacing()
	_apply_text_styling()
	_style_all_buttons()
	_configure_icon_buttons()
	_configure_category_buttons()
	_clear_mode_buttons()
	_set_active_category("grid")

# --------------------------------------------------------------------------------------------------

func start_game_with_config(config: ModeConfig) -> void:
	var game_scene: Node = load("res://scenes/game/game.tscn").instantiate()
	get_tree().root.add_child(game_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = game_scene
	if game_scene.has_method("start_with_config"):
		game_scene.call_deferred("start_with_config", config)

# --------------------------------------------------------------------------------------------------

func _configure_category_buttons() -> void:
	grid_button.pressed.connect(func() -> void: _set_active_category("grid"))
	classic_button.pressed.connect(func() -> void: _set_active_category("classic"))


func _set_active_category(category_key: String) -> void:
	var category = _get_category_by_key(category_key)
	if category == null:
		return
	category_description_label.text = category.description
	mode_description_label.text = "Select a mode to view details."
	feedback_label.text = ""
	var modes: Array = ModeRegistry.list_modes(category_key)
	_populate_mode_buttons(modes)


func _populate_mode_buttons(modes: Array) -> void:
	_clear_mode_buttons()

	for descriptor in modes:
		var button := Button.new()
		button.text = descriptor.title
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, ButtonStyler.MIN_HEIGHT)
		button.disabled = not descriptor.implemented
		button.pressed.connect(func() -> void: _on_mode_selected(descriptor))
		ButtonStyler.apply_primary_style(button)
		ButtonStyler.attach_interactions(button)
		mode_buttons_container.add_child(button)

	if mode_buttons_container.get_child_count() == 0:
		var placeholder := Label.new()
		placeholder.text = "No modes available yet."
		placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		mode_buttons_container.add_child(placeholder)


func _style_all_buttons() -> void:
	var buttons := [grid_button, classic_button]
	for button in buttons:
		if button is Button:
			ButtonStyler.apply_primary_style(button)
			ButtonStyler.attach_interactions(button)


func _configure_icon_buttons() -> void:
	var edge_margin := Vector2(32, 32)
	_setup_icon_button(settings_button, Vector2(128, 128), edge_margin, Callable(self, "_on_settings_button_pressed"))
	_setup_icon_button(quit_button, Vector2(28, 28), edge_margin, Callable(self, "_on_quit_button_pressed"))


func _setup_icon_button(button: TextureButton, target_size: Vector2, edge_margin: Vector2, callback: Callable) -> void:
	if button == null or not is_instance_valid(button):
		return
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.self_modulate = ButtonStyler.BASE_COLOR
	button.scale = Vector2.ONE
	button.custom_minimum_size = target_size
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	_apply_icon_button_offsets(button, target_size, edge_margin)
	button.size = target_size
	if not button.pressed.is_connected(callback):
		button.pressed.connect(callback)
	if button.has_meta("icon_interactions_attached"):
		return
	var base_color := ButtonStyler.BASE_COLOR
	var hover_color := base_color.lightened(ButtonStyler.HOVER_LIGHTEN)
	var pressed_color := base_color.lightened(ButtonStyler.PRESS_LIGHTEN)
	button.mouse_entered.connect(func() -> void: button.self_modulate=hover_color)
	button.mouse_exited.connect(func() -> void: button.self_modulate=base_color)
	if button.has_signal("button_down"):
		button.button_down.connect(func() -> void: button.self_modulate=pressed_color)
	if button.has_signal("button_up"):
		button.button_up.connect(func() -> void: button.self_modulate=hover_color)
	button.set_meta("icon_interactions_attached", true)


func _apply_icon_button_offsets(button: TextureButton, target_size: Vector2, margin: Vector2) -> void:
	var margin_x := margin.x
	var margin_y := margin.y

	if is_equal_approx(button.anchor_left, 1.0):
		button.offset_left = - margin_x - target_size.x
	else:
		button.offset_left = margin_x
	
	if is_equal_approx(button.anchor_right, 1.0):
		button.offset_right = - margin_x
	else:
		button.offset_right = margin_x + target_size.x
	
	if is_equal_approx(button.anchor_top, 1.0):
		button.offset_top = - margin_y - target_size.y
	else:
		button.offset_top = margin_y
	
	if is_equal_approx(button.anchor_bottom, 1.0):
		button.offset_bottom = - margin_y
	else:
		button.offset_bottom = margin_y + target_size.y


func _apply_layout_spacing() -> void:
	if is_instance_valid(layout_container):
		layout_container.add_theme_constant_override("separation", 40)
	if is_instance_valid(category_buttons_container):
		category_buttons_container.add_theme_constant_override("separation", 36)
	if is_instance_valid(mode_buttons_container):
		mode_buttons_container.add_theme_constant_override("separation", 26)
	if is_instance_valid(footer_container):
		footer_container.add_theme_constant_override("separation", 36)


func _apply_text_styling() -> void:
	title_label.add_theme_color_override("font_color", Color(0.08, 0.12, 0.18))
	subtitle_label.add_theme_font_size_override("font_size", 44)
	category_label.add_theme_font_size_override("font_size", 40)
	category_description_label.add_theme_font_size_override("font_size", 32)
	mode_description_label.add_theme_font_size_override("font_size", 32)
	var secondary_color := Color(0.2, 0.24, 0.3)
	
	var secondary_labels := [subtitle_label, category_label, category_description_label, mode_description_label]
	for label in secondary_labels:
		if label is Label:
			label.add_theme_color_override("font_color", secondary_color)
	
	category_description_label.add_theme_color_override("font_color", Color(0.16, 0.2, 0.28))
	mode_description_label.add_theme_color_override("font_color", Color(0.16, 0.2, 0.28))


func _clear_mode_buttons() -> void:
	for child in mode_buttons_container.get_children():
		child.queue_free()


func _on_mode_selected(descriptor: Variant) -> void:
	mode_description_label.text = descriptor.description
	feedback_label.text = ""
	if descriptor.implemented:
		_start_mode(descriptor.id)
	else:
		_show_unavailable("Not yet implemented")


func _start_mode(mode_id: String) -> void:
	var descriptor = ModeRegistry.get_mode(mode_id)
	if descriptor == null:
		_show_unavailable("Mode not found")
		return
	var config := _copy_config(descriptor.default_config)
	feedback_label.text = "Loading %s..." % descriptor.title
	start_game_with_config(config)


func _show_unavailable(message: String) -> void:
	feedback_label.text = message


func _on_settings_button_pressed() -> void:
	feedback_label.text = "Not yet implemented"


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _get_category_by_key(category_key: String) -> Variant:
	for c in ModeRegistry.list_categories():
		if c.key == category_key:
			return c
	return null


func _copy_config(src: ModeConfig) -> ModeConfig:
	if src == null:
		return null
	return src.copy()
