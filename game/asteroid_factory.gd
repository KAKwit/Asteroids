extends Node

func generate_asteroid(type):
	var type_node = get_node("asteroids").get_child(type)
	var asteroid = type_node.get_child(randi() % type_node.get_child_count()).duplicate()
	for child in get_node("common").get_children():
		asteroid.add_child(child.duplicate())
	asteroid.get_node("Sprite").set("modulate", Color(globals.STAGE_SETTINGS[globals.CURRENT_STAGE].modulate_color))
	asteroid.get_node("puff").set("color/color", Color(globals.STAGE_SETTINGS[globals.CURRENT_STAGE].puff_color))
	return asteroid
