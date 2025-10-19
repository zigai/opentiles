class_name DelayedTilePlacer
extends TilePlacer

# --------------------------------------------------------------------------------------------------

func place_tiles(field: Node, index: int) -> void:
	if not field:
		return
	if field.has_method("set_tile_white"):
		field.set_tile_white(index)
	if field.has_method("has_black_tiles") and field.has_black_tiles():
		return
	
	var spawn_count = 4
	
	if "config" in field and field.config:
		if "BLACK_TILE_COUNT" in field.config:
			spawn_count = field.config.BLACK_TILE_COUNT
	
	for _i in range(spawn_count):
		if field.has_method("pick_random_white_tile"):
			var idx = field.pick_random_white_tile()
			if idx >= 0 and field.has_method("set_tile_black"):
				field.set_tile_black(idx)


func get_name() -> String:
	return "Delayed"

func get_description() -> String:
	return "Wait for all the black tiles to be cleared before placing new ones"
