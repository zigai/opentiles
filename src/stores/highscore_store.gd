class_name HighscoreStoreManager
extends Node


const CONFIG_PATH := "user://scores.cfg"
const SECTION := "scores"
const DEFAULT_PLAYER_NAME := "Player"
const UNKNOWN_TIMESTAMP := "Unknown"
const MAX_ENTRIES := 10

var config: ConfigFile
var settings_data: ConfigFile
var scores_by_key: Dictionary = {}

func _ready() -> void:
	config = ConfigFile.new()
	load_scores()

	settings_data = ConfigFile.new()
	settings_data.load("user://settings.cfg")

# --------------------------------------------------------------------------------------------------

func load_scores() -> void:
	var err := config.load(CONFIG_PATH)
	if err != OK and err != ERR_FILE_NOT_FOUND:
		push_warning("HighscoreStore: Failed to load scores, error: %d" % err)
		scores_by_key.clear()
		return

	scores_by_key.clear()
	var migrated := false
	if config.has_section(SECTION):
		var keys: PackedStringArray = config.get_section_keys(SECTION)
		for mode_key in keys:
			var normalized := _normalize_player_scores(config.get_value(SECTION, mode_key))
			scores_by_key[mode_key] = normalized
			if _serialize_player_scores(normalized) != config.get_value(SECTION, mode_key):
				migrated = true
	if migrated:
		_save_scores_to_disk()

func save_scores() -> void:
	_save_scores_to_disk()

func get_best(key: String, player_name: String = "") -> int:
	var pname := _resolve_player_name(player_name)
	var entries: Array[HighscoreEntry] = get_top_scores(key, pname)
	if entries.is_empty():
		return 0
	
	return entries[0].score

func submit(key: String, score: int, player_name: String = "") -> HighscoreSubmitResult:
	var pname := _resolve_player_name(player_name)
	var player_scores: Dictionary = {}
	
	if scores_by_key.has(key):
		player_scores = scores_by_key[key]
	var entries: Array[HighscoreEntry] = []
	
	if player_scores.has(pname):
		entries = player_scores[pname] as Array[HighscoreEntry]
	
	var had_entries := not entries.is_empty()
	var previous_best: int = entries[0].score if had_entries else 0
	var new_entry: HighscoreEntry = _create_entry(score, pname)
	
	entries.append(new_entry)
	entries = _cap_entries(entries)
	
	var result := HighscoreSubmitResult.new()
	result.is_listed = entries.has(new_entry)
	
	if result.is_listed:
		result.rank = entries.find(new_entry) + 1
		result.is_new_high_score = (not had_entries) or new_entry.score > previous_best +
		
	player_scores[pname] = entries
	scores_by_key[key] = player_scores
	_save_scores_to_disk()
	return result

func clear(key: String) -> void:
	if not scores_by_key.has(key):
		return

	scores_by_key.erase(key)
	_save_scores_to_disk()

func clear_player(key: String, player_name: String) -> void:
	if not scores_by_key.has(key):
		return

	var player_scores: Dictionary = scores_by_key[key]
	if not player_scores.has(player_name):
		return

	player_scores.erase(player_name)
	if player_scores.is_empty():
		scores_by_key.erase(key)
	else:
		scores_by_key[key] = player_scores
	_save_scores_to_disk()

func get_top_scores(key: String, player_name: String = "") -> Array[HighscoreEntry]:
	var pname := _resolve_player_name(player_name)
	if not scores_by_key.has(key):
		return []

	var player_scores: Dictionary = scores_by_key[key]
	if not player_scores.has(pname):
		return []

	return player_scores[pname] as Array[HighscoreEntry]

func get_score_data(key: String, player_name: String = "") -> Dictionary:
	var pname := _resolve_player_name(player_name)
	var entries: Array[HighscoreEntry] = get_top_scores(key, pname)
	
	if entries.is_empty():
		return {}
	
	var best: HighscoreEntry = entries[0]
	
	return {
		"player_name": pname,
		"score": best.score,
		"timestamp": best.timestamp,
		"history": _entries_to_variant(entries)
	}

func get_all_player_scores(key: String) -> Dictionary:
	if not scores_by_key.has(key):
		return {}
	return scores_by_key[key]

func get_all_scores() -> Dictionary:
	var serialized: Dictionary = {}
	for mode_key in scores_by_key.keys():
		serialized[mode_key] = _serialize_player_scores(scores_by_key[mode_key])
	return serialized

# --------------------------------------------------------------------------------------------------

func _save_scores_to_disk() -> void:
	config.erase_section(SECTION)
	for mode_key in scores_by_key.keys():
		config.set_value(SECTION, mode_key, _serialize_player_scores(scores_by_key[mode_key]))
	var err := config.save(CONFIG_PATH)
	if err != OK:
		push_error("HighscoreStore: Failed to save scores, error: %d" % err)

func _create_entry(score: int, player_name: String) -> HighscoreEntry:
	return HighscoreEntry.create(score, player_name, Time.get_datetime_string_from_system())

func _normalize_player_scores(raw_data: Variant) -> Dictionary:
	var player_scores: Dictionary = {}
	if raw_data is Dictionary:
		for key in raw_data.keys():
			var pname := String(key)
			var entries: Array[HighscoreEntry] = _parse_entry_list(raw_data[key], pname)
			if not entries.is_empty():
				player_scores[pname] = entries
	elif raw_data is Array:
		var entries: Array[HighscoreEntry] = _parse_entry_list(raw_data, DEFAULT_PLAYER_NAME)
		for entry in entries:
			var pname := entry.player_name if entry.player_name != "" else DEFAULT_PLAYER_NAME
			var list: Array[HighscoreEntry] = []
			
			if player_scores.has(pname):
				list = player_scores[pname] as Array[HighscoreEntry]
			
			list.append(entry)
			list = _cap_entries(list)
			player_scores[pname] = list
	else:
		var entry := HighscoreEntry.from_variant(raw_data, DEFAULT_PLAYER_NAME, UNKNOWN_TIMESTAMP)
		var single_list: Array[HighscoreEntry] = []
		single_list.append(entry)
		player_scores[entry.player_name] = _cap_entries(single_list)
	return player_scores

func _parse_entry_list(raw_entries: Variant, fallback_player_name: String) -> Array[HighscoreEntry]:
	var entries: Array[HighscoreEntry] = []
	if raw_entries is Array:
		for item in raw_entries:
			entries.append(HighscoreEntry.from_variant(item, fallback_player_name, UNKNOWN_TIMESTAMP))
	else:
		entries.append(HighscoreEntry.from_variant(raw_entries, fallback_player_name, UNKNOWN_TIMESTAMP))
	
	for entry in entries:
		if entry.player_name.is_empty():
			entry.player_name = fallback_player_name
	return _cap_entries(entries)

func _entries_to_variant(entries: Array[HighscoreEntry]) -> Array[Dictionary]:
	var serialized: Array[Dictionary] = []
	serialized.resize(entries.size())
	
	for i in range(entries.size()):
		serialized[i] = entries[i].to_dict()
	
	return serialized

func _serialize_player_scores(player_scores: Dictionary) -> Dictionary:
	var serialized: Dictionary = {}
	
	for key in player_scores.keys():
		var pname := String(key)
		serialized[pname] = _entries_to_variant(player_scores[pname] as Array[HighscoreEntry])
	
	return serialized

func _cap_entries(entries: Array[HighscoreEntry]) -> Array[HighscoreEntry]:
	_sort_entries(entries)
	if entries.size() > MAX_ENTRIES:
		entries.resize(MAX_ENTRIES)
	return entries

func _sort_entries(entries: Array[HighscoreEntry]) -> void:
	entries.sort_custom(Callable(self, "_compare_entries"))

func _compare_entries(a: HighscoreEntry, b: HighscoreEntry) -> bool:
	if a.score == b.score:
		return a.timestamp > b.timestamp
	return a.score > b.score

func _resolve_player_name(player_name: String) -> String:
	if player_name.is_empty():
		return _get_player_name()
	return player_name

func _get_player_name() -> String:
	if settings_data.has_section_key("general", "player_name"):
		return settings_data.get_value("general", "player_name", DEFAULT_PLAYER_NAME)
	return DEFAULT_PLAYER_NAME
