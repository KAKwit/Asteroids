extends Container

var current_planet = 0
onready var tween = get_node("tween")

func _ready():
	for number in range(4):
		get_node("planet_%s" % (number + 1)).set("visibility/opacity", 0)

func show_planet(number):
	if current_planet != number:
		if current_planet != 0:
			tween.interpolate_property(get_node("planet_%s" % current_planet), "visibility/opacity", 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(get_node("planet_%s" % number), "visibility/opacity", 0, 1, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.5)
		tween.start()
	current_planet = number
