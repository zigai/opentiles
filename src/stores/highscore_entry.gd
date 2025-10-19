class_name HighscoreEntry
extends RefCounted

var score: int = 0
var player_name: String = ""
var timestamp: String = ""

# --------------------------------------------------------------------------------------------------

static func create(score: int, player_name: String, timestamp: String) -> HighscoreEntry:
	var entry := HighscoreEntry.new()
	entry.score = score
	entry.player_name = player_name
	entry.timestamp = timestamp
	return entry

static func from_variant(value: Variant, default_player_name: String, default_timestamp: String) -> HighscoreEntry:
	if value is HighscoreEntry:
		return value
	var entry := HighscoreEntry.new()
	if value is Dictionary:
		entry.score = int(value.get("score", 0))
		entry.player_name = String(value.get("player_name", default_player_name))
		entry.timestamp = String(value.get("timestamp", default_timestamp))
	elif value is int:
		entry.score = value
		entry.player_name = default_player_name
		entry.timestamp = default_timestamp
	else:
		entry.score = 0
		entry.player_name = default_player_name
		entry.timestamp = default_timestamp
		
	return entry

func to_dict() -> Dictionary:
	return {
		"score": score,
		"player_name": player_name,
		"timestamp": timestamp
	}
