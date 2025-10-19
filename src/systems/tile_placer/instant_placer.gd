class_name InstantTilePlacer
extends TilePlacer

# --------------------------------------------------------------------------------------------------

func place_tiles(field: Node, index: int) -> void:
	if not field or not field.has_method("pick_random_white_tile"):
		return
	var new_black_tile = field.pick_random_white_tile()
	if field.has_method("set_tile_white"):
		field.set_tile_white(index)
	if field.has_method("set_tile_black") and new_black_tile >= 0:
		field.set_tile_black(new_black_tile)

func get_name() -> String:
	return "Instant"

func get_description() -> String:
	return "Instantly places a black tile when a white tile is clicked."
