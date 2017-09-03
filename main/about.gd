extends Container

signal back

onready var rich_text = get_node("rich_text")
onready var back_button = get_node("back_button")

func _ready():
	back_button.grab_focus()
	rich_text.connect("meta_clicked", self, "open_url")
	back_button.connect("pressed", self, "go_back")
	globals.escape_button(back_button)

func open_url(url):
	OS.shell_open(url)

func go_back():
	globals.menu_select(self, "back")
