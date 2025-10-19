extends Node


class CategoryDescriptor:
	extends RefCounted
	var key: String
	var title: String
	var description: String
	var icon: Texture2D = null

	func _init(key: String, title: String, description: String, icon: Texture2D = null) -> void:
		self.key = key
		self.title = title
		self.description = description
		self.icon = icon


class SettingField:
	extends RefCounted
	var key: String
	var type: String # should be "int" / "float" / "bool" / "enum"
	var label: String
	var default
	var min: float = 0.0
	var max: float = 0.0
	var step: float = 1.0
	var options: Array = []

	func _init(
		key: String,
		type: String,
		label: String,
		default_value=null,
		min: float = 0.0,
		max: float = 0.0,
		step: float = 1.0,
		options: Array = [] #
	) -> void:
		self.key = key
		self.type = type
		self.label = label
		self.default = default_value
		self.min = min
		self.max = max
		self.step = step
		self.options = options


class ModeDescriptor:
	extends RefCounted
	var id: String
	var title: String
	var description: String
	var category_key: String
	var config_type: String # "grid" | "classic"
	var implemented: bool
	var default_config: ModeConfig
	var settings_schema: Array[SettingField]
	var icon: Texture2D = null

	func _init(
		id: String,
		title: String,
		description: String,
		category_key: String,
		config_type: String,
		implemented: bool,
		default_config: ModeConfig,
		settings_schema: Array[SettingField]=[],
		icon: Texture2D = null
	) -> void:
		self.id = id
		self.title = title
		self.description = description
		self.category_key = category_key
		self.config_type = config_type
		self.implemented = implemented
		self.default_config = default_config
		self.settings_schema = settings_schema
		self.icon = icon


var _categories: Array[CategoryDescriptor] = []
var _modes_by_category: Dictionary = {}
var _modes_by_id: Dictionary = {}


func _ready() -> void:
	_build_registry()

# --------------------------------------------------------------------------------------------------

func list_categories() -> Array[CategoryDescriptor]:
	var result: Array[CategoryDescriptor] = []
	result.assign(_categories)
	return result


func list_modes(category_key: String) -> Array[ModeDescriptor]:
	var result: Array[ModeDescriptor] = []
	if _modes_by_category.has(category_key):
		var src: Array = _modes_by_category[category_key]
		result.assign(src)
	return result


func get_mode(id: String) -> ModeDescriptor:
	if _modes_by_id.has(id):
		return _modes_by_id[id] as ModeDescriptor
	return null

# --------------------------------------------------------------------------------------------------

func _build_registry() -> void:
	_categories.clear()
	_modes_by_category.clear()
	_modes_by_id.clear()

	# Categories
	var category_grid = CategoryDescriptor.new(
		"grid",
		"Grid",
		"Grid-based modes on a static board."
	)
	var category_classic = CategoryDescriptor.new(
		"classic",
		"Classic",
		"Classic modes with moving tiles."
	)
	_categories.append(category_grid)
	_categories.append(category_classic)

	var config_frenzy = GridModeConfig.new()
	config_frenzy.GAME_MODE = Globals.GameMode.FRENZY
	config_frenzy.PENALTY_TYPE = Globals.PenaltyType.INSTANT_DEATH
	config_frenzy.OBJECTIVE_TYPE = Globals.ObjectiveType.TIMER
	config_frenzy.TILE_PLACER_TYPE = Globals.TilePlacerType.INSTANT
	config_frenzy.GRID_SIZE = 4
	config_frenzy.BLACK_TILE_COUNT = 4
	config_frenzy.TIME_LIMIT = Globals.DEFAULT_TIME_LIMIT

	var frenzy_schema: Array[SettingField] = [
		SettingField.new("GRID_SIZE", "int", "Grid Size", 4, 2, 12, 1),
		SettingField.new("BLACK_TILE_COUNT", "int", "Black Tiles", 4, 1, 12, 1),
		SettingField.new("TIME_LIMIT", "float", "Time Limit (s)", Globals.DEFAULT_TIME_LIMIT, 1.0, 600.0, 0.5),
		SettingField.new("TILE_PLACER_TYPE", "enum", "Tile Placer", Globals.TilePlacerType.INSTANT, 0.0, 0.0, 1.0, [
			{"value": Globals.TilePlacerType.INSTANT, "label": "Instant"},
			{"value": Globals.TilePlacerType.DELAYED, "label": "Delayed"},
		]),
	]

	var mode_frenzy = ModeDescriptor.new(
		"frenzy",
		"Frenzy",
		"Tap black tiles quickly before time runs out.",
		category_grid.key,
		"grid",
		true,
		config_frenzy,
		frenzy_schema
	)

	var config_keyboard = GridModeConfig.new()
	config_keyboard.GAME_MODE = Globals.GameMode.KEYBOARD
	config_keyboard.GRID_SIZE = 5
	config_keyboard.BLACK_TILE_COUNT = 5
	config_keyboard.TIME_LIMIT = 60.0

	var mode_keyboard = ModeDescriptor.new(
		"keyboard",
		"Keyboard",
		"Use keyboard keys mapped to tiles.",
		category_grid.key,
		"grid",
		false,
		config_keyboard,
		[
			SettingField.new("GRID_SIZE", "int", "Grid Size", 5, 2, 12, 1),
			SettingField.new("TIME_LIMIT", "float", "Time Limit (s)", 60.0, 5.0, 600.0, 0.5),
		]
	)

	var config_numpad = GridModeConfig.new()
	config_numpad.GAME_MODE = Globals.GameMode.NUMPAD
	config_numpad.GRID_SIZE = 3
	config_numpad.BLACK_TILE_COUNT = 3
	config_numpad.TIME_LIMIT = 45.0

	var mode_numpad = ModeDescriptor.new(
		"numpad",
		"Numpad",
		"Play with numpad layout on a compact grid.",
		category_grid.key,
		"grid",
		false,
		config_numpad,
		[
			SettingField.new("GRID_SIZE", "int", "Grid Size", 3, 2, 6, 1),
			SettingField.new("TIME_LIMIT", "float", "Time Limit (s)", 45.0, 5.0, 600.0, 0.5),
		]
	)

	var config_classic = ClassicModeConfig.new()
	config_classic.GAME_MODE = Globals.GameMode.MOVING_BASIC
	config_classic.LANE_COUNT = 4
	config_classic.SCROLL_SPEED = 300.0
	config_classic.SPAWN_RATE = 1.0
	config_classic.PLACER_TYPE = Globals.MovingPlacerType.SIMPLE
	config_classic.SCORE_TYPE = Globals.MovingScoreType.TIME

	var mode_moving_basic = ModeDescriptor.new(
		"classic",
		"Classic (Basic)",
		"Tap moving tiles before they pass the bottom.",
		category_classic.key,
		"classic",
		false,
		config_classic,
		[
			SettingField.new("LANE_COUNT", "int", "Lanes", 4, 1, 10, 1),
			SettingField.new("SCROLL_SPEED", "float", "Scroll Speed", 300.0, 50.0, 2000.0, 10.0),
			SettingField.new("SPAWN_RATE", "float", "Spawn Every (s)", 1.0, 0.1, 5.0, 0.1),
			SettingField.new("PLACER_TYPE", "enum", "Placer", Globals.MovingPlacerType.SIMPLE, 0.0, 0.0, 1.0, [
				{"value": Globals.MovingPlacerType.SIMPLE, "label": "Simple"},
				{"value": Globals.MovingPlacerType.PATTERNED, "label": "Patterned"},
			]),
			SettingField.new("SCORE_TYPE", "enum", "Score Type", Globals.MovingScoreType.TIME, 0.0, 0.0, 1.0, [
				{"value": Globals.MovingScoreType.TIME, "label": "Time"},
				{"value": Globals.MovingScoreType.POINTS, "label": "Points"},
			]),
		]
	)

	_register_mode(mode_frenzy)
	_register_mode(mode_keyboard)
	_register_mode(mode_numpad)
	_register_mode(mode_moving_basic)


func _register_mode(descriptor: ModeDescriptor) -> void:
	var list_for_cat: Array[ModeDescriptor] = []
	if _modes_by_category.has(descriptor.category_key):
		var existing: Array = _modes_by_category[descriptor.category_key]
		list_for_cat.assign(existing)
	list_for_cat.append(descriptor)
	_modes_by_category[descriptor.category_key] = list_for_cat
	_modes_by_id[descriptor.id] = descriptor
