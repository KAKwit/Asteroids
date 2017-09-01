extends KinematicBody2D

signal explode

export(float, 0, 1, 0.05) var weight
export(int, 1, 100) var strength

var type
var initial_strength
var velocity = Vector2()
var rotation_speed = 0.0
var is_exploding = false
var hit_velocity = Vector2()
var has_power_up = false

onready var puff = get_node("puff")
onready var tween = get_node("tween")

func setup(type, position, velocity, has_power_up = false):
	self.type = type
	self.velocity = Vector2(rand_range(40, 120), 0).rotated(rand_range(0, 2 * PI)) if velocity == null else velocity
	self.has_power_up = has_power_up
	self.rotation_speed = rand_range(-1.5, 1.5)
	self.initial_strength = strength
	set_pos(position)
	if type == globals.ASTEROID_TYPE.big:
		get_node("Sprite").set("visibility/opacity", 0)

func start():
	# Ease the big asteroids in so it isn't as jarring
	if type == globals.ASTEROID_TYPE.big:
		tween.interpolate_property(get_node("Sprite"), "visibility/opacity", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
	set_fixed_process(true)

func _fixed_process(delta):
	if is_exploding:
		emit_signal("explode", type, get_pos(), velocity, hit_velocity, initial_strength, has_power_up)
		queue_free()
	else:
		velocity = velocity.clamped(200)
		set_rot(get_rot() + rotation_speed * delta)
		var remainder = move(velocity * delta)
		if is_colliding():
			emit_puff(get_collision_pos())
			get_collider().adjust_velocity(velocity * (1 - get_collider().weight))
			var normal = get_collision_normal()
			remainder = normal.reflect(remainder)
			velocity = normal.reflect(velocity)
			velocity = velocity * (1 - weight)
			move(remainder)
		globals.screen_wrap(self)

func adjust_velocity(amount):
	velocity += amount

func emit_puff(position):
	puff.set_global_pos(position)
	puff.set_emitting(true)

func get_shot(bullet_strength, hit_velocity, position):
	# We should not remove the static body outside of a fixed process - weird stuff happens.
	self.hit_velocity = hit_velocity
	strength = strength - bullet_strength
	if strength <= 0:
		is_exploding = true
	else:
		emit_puff(position)
		get_node("sample_player").play("asteroid_hit" + String(randi() % 3 + 1))
