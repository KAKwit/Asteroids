extends Area2D

# FOR DEBUG
var invincible = false

signal explode
signal updated_health

# Rotation speed in radians per second.  Rotation is applied to the sprite to make it point in the right direction, and
# then also to rotate the vector of the thrust so that the sprite starts to accelerate towards the direction it is facing.
export(float, 1.0, 5.0, 0.5) var rotation_speed

# Slowdown over time
export(float, 0.0, 5.0, 0.25) var friction

# Thrusts are basically an acceleration rate in pixels per second
export(int, 100, 1000, 100) var forward_thrust
export(int, 100, 200, 5) var reverse_thrust

# Maximum velocity is a hard limit on the number of pixels you can travel per second.  It's used to clamp changes to the
# positional vector.
export(int, 100, 1000, 100) var max_velocity

# Health or shields
export(int, 50, 500, 5) var health setget set_health

onready var gun_timer = get_node("gun_timer")
onready var shield_regenerator = get_node("shield_regenerator")
onready var damage_sprites = get_node("damage_sprites")
onready var bullet_factory = preload("player_bullet_factory.tscn").instance()
onready var tween = get_node("tween")

var rotation = 0
var position = Vector2()
var velocity = Vector2()
var acceleration = Vector2()
var has_multi_shot = false
var has_invulnerability = false setget set_invulnerability
var initial_health = -1
var initial_gun_timer_wait_time
var bullet_index
var bullets_container

func setup(position, bullet_index, bullets_container):
	self.initial_health = health
	self.position = position
	self.bullet_index = bullet_index
	self.bullets_container = bullets_container
	self.connect("body_enter", self, "on_body_enter")
	set_pos(position)

func start():
	initial_gun_timer_wait_time = gun_timer.get_wait_time()
	shield_regenerator.connect("timeout", self, "regenerate_shield")
	set_fixed_process(true)

func stop():
	rotation = 0
	position = Vector2()
	velocity = Vector2()
	acceleration = Vector2()
	set_fixed_process(false)

func _fixed_process(delta):
	position = get_pos()

	# Rotation (rotate by rotation_speed)
	if Input.is_action_pressed("player_left"):
		rotation += rotation_speed * delta
	if Input.is_action_pressed("player_right"):
		rotation -= rotation_speed * delta

	# Thrust (forward or reverse depending on input)
	acceleration = Vector2(0, -forward_thrust).rotated(rotation) if Input.is_action_pressed("player_up") else Vector2()
	acceleration += Vector2(0, reverse_thrust).rotated(rotation) if Input.is_action_pressed("player_down") else Vector2()
	get_node("thrust_particles").set_emitting(Input.is_action_pressed("player_up"))

	# Velocity (apply thrust minus friction and clamp to max velocities)
	acceleration += velocity * -friction
	velocity += acceleration * delta
	velocity.y = clamp(velocity.y, -max_velocity, max_velocity)
	position += velocity * delta

	# Apply movement
	set_pos(position)
	set_rot(rotation)

	# Perform screen wrapping
	globals.screen_wrap(self)

	# Shooting / firing
	if Input.is_action_pressed("player_fire") && gun_timer.get_time_left() == 0:
		shoot()

func regenerate_shield():
	set_health(min(health + 1, initial_health))
	emit_signal("updated_health")

func shoot():
	gun_timer.start()
	if has_multi_shot:
		for i in [-0.1, 0, 0.1]:
			make_bullet(rotation + i)
	else:
		make_bullet(rotation)

func make_bullet(rotation):
	var bullet = bullet_factory.generate_bullet(bullet_index)
	get_node("sample_player").play("player_shoot" + String(bullet_index + 1))
	bullet.setup(rotation, get_node("muzzle").get_global_pos(), velocity)
	bullets_container.add_child(bullet)
	bullet.start()

func on_body_enter(body):
	if body.has_method("get_shot"):
		do_damage(body.strength)
		body.get_shot(100, velocity.normalized(), get_global_pos())

func get_shot(bullet_strength, hit_velocity, position):
	get_node("sample_player").play("player_hit" + String(randi() % 3 + 1))
	do_damage(bullet_strength)

func do_damage(strength):
	if has_invulnerability || invincible:
		return
	set_health(max(health - strength, 0))
	emit_signal("updated_health")
	if health < initial_health / 2:
		# Show shield and glow red when health less than 50%
		tween.interpolate_property(get_node("Sprite"), "modulate", Color("#ff0000"), Color("#ffffff"), 3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.interpolate_property(get_node("shield"), "modulate", Color("#ff0000"), Color("#ffffff"), 3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.interpolate_property(get_node("shield"), "visibility/opacity", 1, 0, 3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	else:
		# Just show shield
		tween.interpolate_property(get_node("shield"), "visibility/opacity", 1, 0, 3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	if health <= 0:
		destroy()

func set_invulnerability(new_value):
	if new_value && !has_invulnerability:
		tween.interpolate_property(get_node("invulnerable"), "visibility/opacity", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()
	if !new_value && has_invulnerability:
		tween.interpolate_property(get_node("invulnerable"), "visibility/opacity", 1, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()
	has_invulnerability = new_value

func destroy():
	emit_signal("explode", position)

func set_health(new_value):
	health = new_value
	if initial_health > 0:
		damage_sprites.get_node("damage1").show() if health < initial_health else damage_sprites.get_node("damage1").hide()
		damage_sprites.get_node("damage2").show() if health < initial_health * 0.66 else damage_sprites.get_node("damage2").hide()
		damage_sprites.get_node("damage3").show() if health < initial_health * 0.33 else damage_sprites.get_node("damage3").hide()
