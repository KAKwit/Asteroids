extends Container

signal back

onready var label_details = get_node("panel/label_details")
onready var line_edit = get_node("panel/line_edit")
onready var okay_button = get_node("okay_button")

func _ready():
	line_edit.grab_focus()
	line_edit.connect("text_changed", self, "text_changed")
	line_edit.connect("text_entered", self, "text_entered")
	okay_button.connect("pressed", self, "go_back")
	# Set the detail line
	var position = globals.is_highscore(globals.SCORE)
	label_details.set_text("You made it to position #%s with a score of %s" % [position, globals.SCORE])

func text_changed(text):
	okay_button.set("disabled", text.length() == 0)

func text_entered(text):
	if text.length() > 0:
		go_back()

func go_back():
	globals.add_highscore(line_edit.get_text(), globals.ACTUAL_STAGE, globals.CURRENT_PLAYER_TYPE, globals.SCORE)
	globals.save_highscores()
	globals.menu_select(self, "back")
