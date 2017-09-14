extends Node

signal quit_game # Quit before the game is over
signal exit_game # Exit after game over

var player
var countdown = 3
var game_over = false
var ready_to_quit = false
var player_explosions = 3
var enemies_spawned = 0

var player_factory = preload("res://game/player_factory.tscn").instance()
var asteroid_factory = preload("res://game/asteroid_factory.tscn").instance()
var enemy_factory = preload("res://game/enemy_factory.tscn").instance()
var power_up_factory = preload("res://game/power_up_factory.tscn").instance()

onready var power_up_container = get_node("power_up_container")
onready var asteroid_container = get_node("asteroid_container")
onready var enemy_container = get_node("enemy_container")
onready var player_container = get_node("player_container")
onready var bullets_container = get_node("bullets_container")
onready var explosions_container = get_node("explosions_container")
onready var spawn_locations = get_node("spawn_locations")
onready var countdown_timer = get_node("countdown_timer")
onready var countdown_display = get_node("countdown_display")
onready var stage_display = get_node("hud/stage_display")
onready var health_display = get_node("hud/health_display")
onready var score_display = get_node("hud/score_display")
onready var safe_zone = get_node("safe_zone")
onready var tween = get_node("tween")
onready var pause_panel = get_node("pause_panel")
onready var screen_size = Vector2(Globals.get("display/width"), Globals.get("display/height"))

# Load the player and start the countdown
func setup():
	set_process_unhandled_input(true)
	load_player(globals.CURRENT_PLAYER_TYPE)
	safe_zone.set_pos(screen_size / 2)
	countdown_timer.connect("timeout", self, "countdown_timeout")
	pause_panel.connect("quit_to_menu", self, "exit_game")
	player.start()

func start():
	tween.interpolate_callback(self, 0.5, "start_stage")
	tween.start()

# Called at the start of each stage
func start_stage():
	# Don't do anything if the game is over
	if game_over:
		return
	if countdown == 3:
		stage_display.get_node("label").set("text", "STAGE: %s" % globals.ACTUAL_STAGE)
		globals.show_planet(globals.STAGE_SETTINGS[globals.CURRENT_STAGE].planet)
		globals.tint_background(globals.STAGE_SETTINGS[globals.CURRENT_STAGE].background_tint)
	if countdown > 0:
		# We count down 3 seconds before asteroids appear to give time to breathe
		set_fixed_process(false)
		get_node("sample_player").play("start")
		if countdown == 3:
			tween.interpolate_property(safe_zone, "visibility/opacity", 0, 0.2, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.interpolate_property(safe_zone, "transform/rot", 40, 20, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.interpolate_property(safe_zone, "visibility/opacity", 0.2, 0, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 2)
			tween.interpolate_property(safe_zone, "transform/rot", 20, 0, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 2)
			tween.start()
		countdown_display.show()
		countdown_display.get_node("label").set("text", "STAGE: %s, GET READY ... %s" % [globals.ACTUAL_STAGE, countdown])
		countdown_timer.start()
	else:
		# Once countdown is finished we can load the asteroids
		set_fixed_process(true)
		get_node("sample_player").play("started")
		countdown_display.get_node("label").set("text", "GO !!!")
		countdown_timer.start()
		load_initial_asteroids()

func countdown_timeout():
	countdown += -1
	# Keep going back to start until countdown is over
	if countdown >= 0:
		start_stage()
	else:
		countdown_timer.stop()
		countdown_display.hide()

func _fixed_process(delta):
	# Clean up any particle emitters in the explosions container which have finished their job
	for exploder in explosions_container.get_children():
		if !exploder.is_emitting():
			exploder.queue_free()
	# If there are no asteroids or enemies left then increase the stage (up to maximum), reset countdown and start again
	if asteroid_container.get_child_count() == 0 && enemy_container.get_child_count() == 0 && countdown != 3:
		countdown = 3
		tween.interpolate_callback(self, 1, "next_stage")

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") && !game_over:
		pause_panel.show()
	# If we're ready to quit then check for any input to exit
	if ready_to_quit:
		if event.type != InputEvent.NONE && event.type != InputEvent.MOUSE_MOTION && event.type != InputEvent.JOYSTICK_MOTION && event.type != InputEvent.SCREEN_DRAG:
			exit_game()

func load_player(player_type):
	player = player_factory.generate_player(player_type)
	player.setup(screen_size / 2, player_type, bullets_container)
	player.connect("explode", self, "player_explode")
	player.connect("updated_health", self, "player_updated_health")
	player_updated_health(true)
	player_container.add_child(player)

# Load the initial asteroids for the stage
func load_initial_asteroids():
	var power_ups_count = globals.STAGE_SETTINGS[globals.CURRENT_STAGE].power_ups
	if globals.STAGE_SETTINGS[globals.CURRENT_STAGE].enemies > 0:
		tween.interpolate_callback(self, rand_range(20, 50), "spawn_enemy", globals.CURRENT_STAGE)
	for i in range(globals.CURRENT_STAGE):
		var has_power_up = (randi() % 2 + 1 == 1 && power_ups_count > 0) || power_ups_count + 1 > globals.CURRENT_STAGE - i
		power_ups_count = power_ups_count - 1 if has_power_up else power_ups_count
		load_asteroid(globals.ASTEROID_TYPE.big, spawn_locations.get_child(i).get_pos(), null, has_power_up)

# Load and start individual asteroids
func load_asteroid(type, position, velocity, has_power_up = false):
	var asteroid = asteroid_factory.generate_asteroid(type)
	asteroid.connect("explode", self, "asteroid_explode")
	asteroid.setup(type, position, velocity, has_power_up)
	asteroid_container.add_child(asteroid)
	asteroid.start()

# Spawn an enemy after a random delay
func spawn_enemy(for_stage):
	if game_over || globals.CURRENT_STAGE != for_stage:
		return
	enemies_spawned += 1
	var enemy = enemy_factory.generate_enemy(globals.STAGE_SETTINGS[globals.CURRENT_STAGE].enemy_type)
	enemy.connect("explode", self, "enemy_explode")
	enemy.setup(globals.STAGE_SETTINGS[globals.CURRENT_STAGE].enemy_type, player, bullets_container)
	enemy_container.add_child(enemy)
	enemy.start()
	# Queue next enemy if applicable
	if enemies_spawned < globals.STAGE_SETTINGS[globals.CURRENT_STAGE].enemies:
		if globals.ACTUAL_STAGE > 8:
			tween.interpolate_callback(self, rand_range(10, 30), "spawn_enemy", globals.CURRENT_STAGE)
		else:
			tween.interpolate_callback(self, rand_range(20, 50), "spawn_enemy", globals.CURRENT_STAGE)

func enemy_explode(position, initial_strength):
	# Update the score
	globals.SCORE += initial_strength
	score_display.get_node("label").set("text", "SCORE: %s" % globals.SCORE)
	# Play explosion noise and then particle explosion
	get_node("sample_player").play("player_explode" + String(randi() % 3 + 1))
	for i in range(3):
		var exploder = get_node("player_explosion%s" % player_explosions).duplicate()
		exploder.set_global_pos(position) if i == 1 else exploder.set_global_pos(position + Vector2(rand_range(-20, 20), rand_range(-20, 20)))
		exploder.set("config/explosiveness", rand_range(0.1, 0.3))
		exploder.set("config/lifetime", 2)
		exploder.set("config/emit_timeout", 2)
		exploder.set_emitting(true)
		explosions_container.add_child(exploder)

# Called when an asteroid has exploded
func asteroid_explode(type, position, velocity, hit_velocity, initial_strength, has_power_up):
	# Update the score
	globals.SCORE += initial_strength
	score_display.get_node("label").set("text", "SCORE: %s" % globals.SCORE)
	# Play explosion noise and then particle explosion
	var new_type = globals.ASTEROID_BREAK_PATTERN[type]
	get_node("sample_player").play("asteroid_explode" + String(randi() % 3 + 1))
	for i in range(max(3 - type, 1)):
		# For attempted added effect, we play multiple explosions for bigger asteroids and we mix up some parameters a bit
		var exploder = get_node("asteroid_explosion").duplicate()
		exploder.set_global_pos(position) if i == 1 else exploder.set_global_pos(position + Vector2(rand_range(-20, 20), rand_range(-20, 20)))
		exploder.set("color/color", Color(globals.STAGE_SETTINGS[globals.CURRENT_STAGE].puff_color))
		exploder.set("config/explosiveness", rand_range(0.1, 0.3))
		exploder.set("config/lifetime", 1 - (type * 0.1))
		exploder.set("config/emit_timeout", 1 - (type * 0.1))
		exploder.set_emitting(true)
		explosions_container.add_child(exploder)
	# Break the asteroid into smaller bits.
	if new_type && !(new_type == globals.ASTEROID_TYPE.tiny && globals.STAGE_SETTINGS[globals.CURRENT_STAGE].has_tiny == false):
		for offset in [-1, 1]:
			var new_pos = position + Vector2(16, 16) * offset
			var new_vel = velocity + hit_velocity.tangent() + Vector2(rand_range(50, 150), rand_range(50, 150)) * offset
			new_vel = new_vel * 2
			load_asteroid(new_type, new_pos, new_vel)
	# Create a power-up
	if has_power_up:
		var power_up_type = randi() % globals.POWER_UP_TYPE.size()
		var power_up = power_up_factory.generate_power_up(power_up_type)
		power_up.setup(power_up_type, position, hit_velocity + Vector2(rand_range(10, 100), rand_range(10, 100)))
		power_up_container.add_child(power_up)
		power_up.connect("power_up_collected", self, "_power_up_collected")
		power_up.connect("power_up_lifetime_timeout", self, "_power_up_lifetime_timeout")
		power_up.start()

func player_updated_health(initial = false):
	if initial:
		health_display.get_node("label").set("text", "SHIELDS: %s" % player.health)
		health_display.get_node("shield_bar").set("range/max", player.initial_health)
		health_display.get_node("shield_bar").set("range/value", player.health)
	else:
		var old_value = health_display.get_node("shield_bar").get_val()
		health_display.get_node("label").set("text", "SHIELDS: %s" % player.health)
		health_display.get_node("shield_bar").set("range/value", player.health) if player.health == old_value + 1 else tween.interpolate_property(health_display.get_node("shield_bar"), "range/value", old_value, player.health, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()

# Called when the player explodes
func player_explode(position):
	game_over = true
	player.queue_free()
	for power_up in power_up_container.get_children():
		power_up.queue_free()
	do_player_explosion(position)

# Do multiple particle explsions when player dies, then end the game after a pause
func do_player_explosion(position):
	# If we haven't finished exploding yet
	if player_explosions > 0:
		get_node("sample_player").play("player_explode%s" % player_explosions)
		var exploder = get_node("player_explosion%s" % player_explosions).duplicate()
		exploder.set_global_pos(position) if player_explosions == 3 else exploder.set_global_pos(position + Vector2(rand_range(-50, 50), rand_range(-50, 50)))
		exploder.set_emitting(true)
		explosions_container.add_child(exploder)
		player_explosions = player_explosions - 1
		tween.interpolate_callback(self, .5, "do_player_explosion", position)
		tween.start()
	else:
		# Show game over message
		countdown_display.show()
		countdown_display.get_node("label").set("text", "GAME OVER!!!")
		tween.interpolate_callback(self, 2, "game_over")
		tween.start()

func _power_up_collected(power_up, type, has_lifetime, countdown_label):
	# Play collection sound and move to top of screen
	get_node("sample_player").play("power_up")
	if has_lifetime:
		# Stack after existing power-ups
		var other_count = 0
		for other in power_up_container.get_children():
			if other != power_up && other.has_been_collected:
				other_count += 1
		tween.interpolate_property(power_up, "transform/pos", power_up.get_global_pos(), Vector2(28, 52 + (other_count * 30)), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(countdown_label, "visibility/visible", false, true, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()
	if type == globals.POWER_UP_TYPE.health:
		player.health = player.initial_health
		player_updated_health()
	if type == globals.POWER_UP_TYPE.multi_shot:
		player.has_multi_shot = true
	if type == globals.POWER_UP_TYPE.rapid_fire:
		player.gun_timer.set_wait_time(player.initial_gun_timer_wait_time / 2)
	if type == globals.POWER_UP_TYPE.invulnerability:
		player.has_invulnerability = true
	if !power_up.has_lifetime:
		power_up.destroy()

func _power_up_lifetime_timeout(power_up, type):
	# Check what power-ups should be left
	var has_multi_shot = false
	var has_rapid_fire = false
	var has_invulnerability = false
	for other in power_up_container.get_children():
		if other != power_up && other.has_been_collected:
			if other.type == globals.POWER_UP_TYPE.multi_shot:
				has_multi_shot = true
			if other.type == globals.POWER_UP_TYPE.rapid_fire:
				has_rapid_fire = true
			if other.type == globals.POWER_UP_TYPE.invulnerability:
				has_invulnerability = true
	# Apply remaining power-ups
	player.has_multi_shot = has_multi_shot
	player.gun_timer.set_wait_time(player.initial_gun_timer_wait_time / 2) if has_rapid_fire else player.gun_timer.set_wait_time(player.initial_gun_timer_wait_time)
	player.has_invulnerability = has_invulnerability
	# Move existing power-ups up when one is removed
	var y = power_up.get_global_pos().y
	for other in power_up_container.get_children():
		if other != power_up && other.has_been_collected && other.get_global_pos().y > y:
			tween.interpolate_property(other, "transform/pos", other.get_global_pos(), other.get_global_pos() + Vector2(0, -30), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	power_up.destroy()

func next_stage():
	enemies_spawned = 0
	globals.CURRENT_STAGE = clamp(globals.CURRENT_STAGE + 1, 1, 8)
	globals.ACTUAL_STAGE += 1
	start_stage()

func game_over():
	ready_to_quit = true
	countdown_display.get_node("label").set("text", "GAME OVER!!!\n\n(press any key)")
	tween.interpolate_property(countdown_display.get_node("label"), "visibility/opacity", 0.5, 1, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(countdown_display.get_node("label"), "visibility/opacity", 1, 0.5, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1.5)
	tween.start()

func exit_game():
	globals.play_pressed()
	get_tree().set_input_as_handled()
	emit_signal("exit_game")
