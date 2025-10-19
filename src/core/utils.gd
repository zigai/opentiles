extends Node


func find_label_in_scene(label_name: String, scene) -> Label:
	if scene:
		return scene.find_child(label_name, true, false) as Label
	return null
