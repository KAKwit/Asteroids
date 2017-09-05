extends Container

signal back
signal reset_highscores

onready var back_button = get_node("back_button")
onready var reset_highscores = get_node("reset_highscores")
onready var tween = get_node("tween")

func _ready():
	back_button.grab_focus()
	back_button.connect("pressed", self, "go_back")
	reset_highscores.connect("pressed", self, "reset_highscores")
	globals.escape_button(back_button)
	show_highscores()

func go_back():
	globals.menu_select(self, "back")

func show_highscores():
	for i in range(globals.HIGHSCORES.size()):
		var scorebox = get_node("highscores_panel").get_child(i)
		# Set the values for the score
		scorebox.get_node("name").set_text(globals.HIGHSCORES[i].name)
		scorebox.get_node("score").set_text(String(globals.HIGHSCORES[i].score))
		tween.interpolate_property(scorebox, "visibility/opacity", 0, 1, (i + 1) * 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func reset_highscores():
	globals.HIGHSCORES = []
	for i in range(10):
		globals.HIGHSCORES.append({ name = "---", score = 0 })
	globals.save_highscores()
	globals.play_pressed()
	globals.menu_select(self, "reset_highscores")
