extends Node

func generate_enemy(index):
	var enemy = get_node("enemies").get_child(index).duplicate()
	for child in get_node("common").get_children():
		enemy.add_child(child.duplicate())
	var spawn_locations = get_node("spawn_locations")
	var spawn_point = spawn_locations.get_child(randi() % spawn_locations.get_child_count())
	enemy.set_pos(spawn_point.get_pos())
	enemy.reference_bullet = enemy.get_node("reference_bullet").duplicate()
	enemy.remove_child(enemy.get_node("reference_bullet"))
	return enemy
