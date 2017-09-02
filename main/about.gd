extends Container

signal back
onready var back_button = get_node("back_button")

func _ready():
	back_button.grab_focus()
	back_button.connect("pressed", self, "go_back")
	globals.escape_button(back_button)

func go_back():
	globals.menu_select(self, "back")
