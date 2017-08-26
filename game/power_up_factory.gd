extends Node

func generate_power_up(type):
	var power_up = get_node("power_ups").get_child(type).duplicate()
	for child in get_node("common").get_children():
		power_up.add_child(child.duplicate())
	return power_up
