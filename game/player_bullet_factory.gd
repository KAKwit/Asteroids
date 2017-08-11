extends Node

func generate_bullet(index):
	var bullet = get_node("bullets").get_child(index).duplicate()
	for child in get_node("common").get_children():
		bullet.add_child(child.duplicate())
	return bullet
