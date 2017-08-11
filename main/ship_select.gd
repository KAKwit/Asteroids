extends Container

signal ship_chosen
signal back

func _ready():
	get_node("panel_light").connect("ship_chosen", self, "ship_chosen")
	get_node("panel_medium").connect("ship_chosen", self, "ship_chosen")
	get_node("panel_heavy").connect("ship_chosen", self, "ship_chosen")
	get_node("back_button").connect("pressed", self, "go_back")

func ship_chosen():
	globals.menu_select(self, "ship_chosen")

func go_back():
	globals.menu_select(self, "back")
