extends Node

func generate_asteroid(type):
	var type_node = get_node("asteroids").get_child(type)
	var asteroid = type_node.get_child(randi() % type_node.get_child_count()).duplicate()
	for child in get_node("common").get_children():
		asteroid.add_child(child.duplicate())
	return asteroid
