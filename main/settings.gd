extends Container

signal back
signal bgm_set
signal bgm_volume_changed

onready var back_button = get_node("back_button")
onready var checkbox_fullscreen = get_node("column_b/checkbox_fullscreen")
onready var option_bgm = get_node("column_b/option_bgm")
onready var slider_bgm_volume = get_node("column_b/slider_bgm_volume")

func _ready():
	back_button.grab_focus()
	back_button.connect("pressed", self, "go_back")
	checkbox_fullscreen.set("is_pressed", OS.is_window_fullscreen())
	checkbox_fullscreen.connect("toggled", self, "toggle_fullscreen")
	option_bgm.connect("item_selected", self, "set_bgm_mode")
	option_bgm.add_item("MENUS ONLY", globals.BGM_MODE.menus_only)
	option_bgm.add_item("ALWAYS", globals.BGM_MODE.always)
	option_bgm.add_item("NEVER", globals.BGM_MODE.never)
	option_bgm.select(globals.CURRENT_BGM_MODE)
	slider_bgm_volume.set_value(globals.BGM_VOLUME)
	slider_bgm_volume.connect("value_changed", self, "bgm_volume_changed")

func toggle_fullscreen(pressed):
	OS.set_window_fullscreen(pressed)

func set_bgm_mode(index):
	globals.CURRENT_BGM_MODE = option_bgm.get_item_ID(index)
	emit_signal("bgm_set")

func bgm_volume_changed(new_value):
	globals.BGM_VOLUME = new_value
	emit_signal("bgm_volume_changed")

func go_back():
	globals.menu_select(self, "back")
