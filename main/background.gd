extends Container

onready var top = get_node("background_top")
onready var bottom = get_node("background_bottom")
onready var tween = get_node("tween")

func tint_background(color):
	print(top.get("modulate"))
	print(Color(color))
	tween.interpolate_property(top, "modulate", top.get("modulate"), Color(color), 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(bottom, "modulate", bottom.get("modulate"), Color(color), 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
