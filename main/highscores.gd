extends Container

signal back
onready var back_button = get_node("back_button")

func _ready():
	back_button.grab_focus()
	back_button.connect("pressed", self, "go_back")
	globals.escape_button(back_button)
	globals.load_highscores()
	show_highscores()

func go_back():
	globals.menu_select(self, "back")

func show_highscores():
	var panel = get_node("highscores_panel")
	for i in range(globals.HIGHSCORES.size()):
		var scorebox = panel.get_child(i)
		scorebox.get_node("name").set_text(globals.HIGHSCORES[i].name)
		scorebox.get_node("score").set_text(String(globals.HIGHSCORES[i].score))
		if globals.HIGHSCORES[i].score == 0:
			scorebox.get_node("position").set("custom_colors/font_color", Color("111111"))
			scorebox.get_node("name").set("custom_colors/font_color", Color("111111"))
			scorebox.get_node("score").set("custom_colors/font_color", Color("111111"))
