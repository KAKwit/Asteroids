extends Panel

signal ship_chosen

export(int, "light", "medium", "heavy") var player_type
onready var select_button = get_node("select_button")

func _ready():
	select_button.connect("pressed", self, "select_button_pressed")
	if globals.CURRENT_PLAYER_TYPE == player_type:
		select_button.grab_focus()

func select_button_pressed():
	globals.CURRENT_PLAYER_TYPE = player_type
	emit_signal("ship_chosen")
