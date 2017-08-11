extends Area2D

export(int, 1, 100) var strength
onready var lifetime = get_node("lifetime")

var speed = 1000
var velocity = Vector2()

func setup(direction, position, initial_velocity):
	set_rot(direction)
	set_pos(position)
	velocity = initial_velocity + Vector2(0, -speed).rotated(direction)

func start():
	lifetime.connect("timeout", self, "destroy")
	self.connect("body_enter", self, "on_body_enter")
	set_fixed_process(true)

func _fixed_process(delta):
	set_pos(get_pos() + velocity * delta)

func on_body_enter(body):
	if body.has_method("get_shot"):
		body.get_shot(strength, velocity.normalized(), get_global_pos())
		destroy()

func destroy():
	self.queue_free()
