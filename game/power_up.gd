extends Area2D

signal collected
signal lifetime_timeout

var type
var velocity
var has_been_collected = false
var has_lifetime = false

onready var lifetime_timer = get_node("lifetime_timer")
onready var collection_timer = get_node("collection_timer")
onready var countdown_label = get_node("countdown_label")
onready var tween = get_node("tween")

func setup(type, position, velocity):
	self.type = type
	self.velocity = velocity
	set_global_pos(position)
	has_lifetime = globals.POWER_UPS[type].timeout > 0

func start():
	self.connect("area_enter", self, "_on_area_enter")
	collection_timer.connect("timeout", self, "_collection_timer_timeout")
	lifetime_timer.connect("timeout", self, "_lifetime_timer_timeout")
	set_process(true)
	set_fixed_process(true)

func destroy():
	queue_free()

func _process(delta):
	if has_been_collected:
		var label
		if globals.POWER_UPS[type].type == "multi_shot":
			label = "Multi-shot"
		if globals.POWER_UPS[type].type == "rapid_fire":
			label = "Rapid fire"
		if globals.POWER_UPS[type].type == "shield":
			label = "Invulnerability"
		countdown_label.set("text", "%s: %s" % [label, int(lifetime_timer.get_time_left()) + 1])
	elif int(collection_timer.get_time_left()) < 10:
		countdown_label.set("text", "%s" % (int(collection_timer.get_time_left()) + 1))

func _fixed_process(delta):
	set_pos(get_pos() + velocity * delta)
	globals.screen_wrap(self)

func _on_area_enter(area):
	# Only do anything if collected by player
	if !area.is_in_group("player"):
		return
	# Stop processing, kill collection timer and collider
	has_been_collected = true
	set_fixed_process(false)
	get_node("CollisionShape2D").queue_free()
	collection_timer.queue_free()
	# Let the game know that the power-up has been collected
	if area.is_in_group("player"):
		emit_signal("collected", self, globals.POWER_UPS[type].type)
	# If this power-up type has a lifetime rather than an immediate effect then start timeout
	if has_lifetime:
		lifetime_timer.set_wait_time(globals.POWER_UPS[type].timeout)
		lifetime_timer.start()
		tween.interpolate_property(self, "transform/pos", get_global_pos(), Vector2(28, 52), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(countdown_label, "visibility/visible", false, true, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()

func _collection_timer_timeout():
	destroy()

func _lifetime_timer_timeout():
	emit_signal("lifetime_timeout", self, globals.POWER_UPS[type].type)
