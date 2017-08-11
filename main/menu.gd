extends Container

signal start_game
signal game_settings
signal about_game
signal quit_game

onready var button_start = get_node("button_start")
onready var button_settings = get_node("button_settings")
onready var button_about = get_node("button_about")
onready var button_quit = get_node("button_quit")
onready var animation = get_node("animation")

func _ready():
	button_start.grab_focus()
	button_start.connect("pressed", self, "button_pressed", ["start_game"])
	button_settings.connect("pressed", self, "button_pressed", ["game_settings"])
	button_about.connect("pressed", self, "button_pressed", ["about_game"])
	button_quit.connect("pressed", self, "button_pressed", ["quit_game"])
	animation.play("menu")

func button_pressed(event):
	globals.menu_select(self, event)

