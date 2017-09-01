extends KinematicBody2D

signal explode

const weight = .25
export(int, 1, 300) var strength

var type
var player
var player_pos
var initial_strength
var velocity = Vector2()
var is_exploding = false
var direction = 1
var first_time = true
var reference_bullet

onready var puff = get_node("puff")
onready var tween = get_node("tween")
onready var sample_player = get_node("sample_player")
onready var bullet_container = get_node("bullet_container")

func setup(type, player):
	self.type = type
	self.player = weakref(player)
	self.velocity = Vector2(rand_range(150, 200), 0).rotated(rand_range(0, 2 * PI))
	self.initial_strength = strength
	add_to_group("enemies")

func start():
	change_direction()
	shoot()
	set_fixed_process(true)
	first_time = false
	sample_player.play("enemy")

func _fixed_process(delta):
	if is_exploding:
		emit_signal("explode", get_pos(), initial_strength)
		queue_free()
	else:
		# Rotate to face the player
		if player.get_ref():
			player_pos = player.get_ref().get_pos()
		rotate(get_angle_to(player_pos) * delta * 2.0)
		velocity = velocity.clamped(200)
		velocity = velocity.rotated(0.5 * direction * delta)
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
	strength = strength - bullet_strength
	if strength <= 0:
		is_exploding = true
	else:
		emit_puff(position)
		sample_player.play("enemy_hit" + String(randi() % 3 + 1))
		tween.interpolate_property(get_node("Sprite"), "modulate", Color("#ff4040"), Color("#ffffff"), 2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()

func change_direction():
	# Randomly change direction now and then
	if !first_time:
		direction = direction * -1
	tween.interpolate_callback(self, rand_range(3, 10), "change_direction")
	tween.start()

func shoot():
	# Shooting one, two, or three bullets depending on type
	if !player.get_ref():
		return
	if type == globals.ENEMY_TYPE.easy:
		if !first_time:
			make_bullet(get_rot())
		tween.interpolate_callback(self, rand_range(1, 3), "shoot")
	if type == globals.ENEMY_TYPE.medium:
		if !first_time:
			for i in [-0.05, 0.05]:
				make_bullet(get_rot() + i)
		tween.interpolate_callback(self, rand_range(2, 4), "shoot")
	if type == globals.ENEMY_TYPE.hard:
		if !first_time:
			for i in [-0.1, 0, 0.1]:
				make_bullet(get_rot() + i)
		tween.interpolate_callback(self, rand_range(2, 4), "shoot")
	tween.start()

func make_bullet(rotation):
	var bullet = reference_bullet.duplicate()
	sample_player.play("enemy_shoot")
	bullet.setup(rotation, get_node("muzzle").get_global_pos(), velocity)
	bullet_container.add_child(bullet)
	bullet.start()
