extends Container

signal start_game
signal highscores
signal game_settings
signal about_game
signal quit_game

var tips = [
	"Tip: Stay near the 'safe' zone at the start of stages (the green circled area in the centre of the screen)",
	"Tip: It is possible to reverse thrust a little (go backwards)",
	"Tip: Try the different ship types to find which best suits your play style",
	"Tip: Power-ups can really turn the tide, but going for them can be risky!",
	"Tip: You can change the starting stage in settings if you want to keep trying later stages without starting again from the beginning",
	"Tip: Being near the edge of the screen or wrapping can be risky - try to anticipate what is on the other side"
]

onready var button_start = get_node("button_start")
onready var button_highscores = get_node("button_highscores")
onready var button_settings = get_node("button_settings")
onready var button_about = get_node("button_about")
onready var button_quit = get_node("button_quit")
onready var animation = get_node("animation")
onready var label_tips = get_node("label_tips")
onready var tween = get_node("tween")

func _ready():
	label_tips.set_text("")
	button_start.grab_focus()
	button_start.connect("pressed", self, "button_pressed", ["start_game"])
	button_highscores.connect("pressed", self, "button_pressed", ["highscores"])
	button_settings.connect("pressed", self, "button_pressed", ["game_settings"])
	button_about.connect("pressed", self, "button_pressed", ["about_game"])
	button_quit.connect("pressed", self, "button_pressed", ["quit_game"])
	animation.play("menu")
	# Start showing tips after some time
	change_tip()
	tween.start()

func button_pressed(event):
	globals.menu_select(self, event)

func change_tip():
	globals.current_tip += 1
	globals.current_tip = globals.current_tip if globals.current_tip < tips.size() else 0
	tween.interpolate_property(label_tips, "visibility/opacity", 1, 0, 5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_callback(self, 5, "show_tip")
	tween.start()

func show_tip():
	label_tips.set_text(tips[globals.current_tip])
	tween.interpolate_property(label_tips, "visibility/opacity", 0, 1, 5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 5)
	tween.interpolate_callback(self, 30, "change_tip")
	tween.start()
