extends Node

func generate_player(index):
	var player = get_node("players").get_child(index).duplicate()
	for child in get_node("common").get_children():
		player.add_child(child.duplicate())
	return player
