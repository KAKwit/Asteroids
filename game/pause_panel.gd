extends Panel

signal quit_to_menu
onready var quit_to_menu = get_node("quit_to_menu")
onready var continue_game = get_node("continue_game")

func _ready():
	quit_to_menu.connect("pressed", self, "quit_to_menu")
	continue_game.connect("pressed", self, "unpause")

func show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	continue_game.grab_focus()
	self.set_hidden(false)
	set_process_input(true)
	get_tree().set_pause(true)

func _input(event):
	get_tree().set_input_as_handled()
	if event.is_action_pressed("ui_cancel"):
		unpause()

func quit_to_menu():
	unpause()
	emit_signal("quit_to_menu")

func unpause():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().set_pause(false)
	self.set_hidden(true)
	set_process_input(false)
