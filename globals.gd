extends Node

# Globals - set to autoload as a singleton in project settings.

# Player type - light, medium, heavy
enum PLAYER_TYPE { light = 0, medium = 1, heavy = 2 }

# Asteroid type - big, medium, small, tiny
enum ASTEROID_TYPE { big = 0, medium = 1, small = 2, tiny = 3 }

# Pattern for breaking up asteroids when they are destroyed
var ASTEROID_BREAK_PATTERN = {
	ASTEROID_TYPE.big: ASTEROID_TYPE.medium,
	ASTEROID_TYPE.medium: ASTEROID_TYPE.small,
	ASTEROID_TYPE.small: ASTEROID_TYPE.tiny,
	ASTEROID_TYPE.tiny: null
}

# Enemy types - easy, medium, hard
enum ENEMY_TYPE { easy = 0, medium = 1, hard = 2 }

# Power-up types - health, multi_shot, rapid_fire, invulnerability
enum POWER_UP_TYPE { health = 0, multi_shot = 1, rapid_fire = 2, invulnerability = 3 }

# Power-up settings
var POWER_UPS = {
	POWER_UP_TYPE.health: { timeout = 0 },
	POWER_UP_TYPE.multi_shot: { timeout = 30 },
	POWER_UP_TYPE.rapid_fire: { timeout = 30 },
	POWER_UP_TYPE.invulnerability: { timeout = 30 }
}

# Settings for each stage
var STAGE_SETTINGS = {
	1: {
		planet = 1,
		has_tiny = false,
		enemy_type = ENEMY_TYPE.easy,
		enemies = 0,
		power_ups = 0,
		puff_color = "80795636",
		modulate_color = "ffffff"
	},
	2: {
		planet = 1,
		has_tiny = false,
		enemy_type = ENEMY_TYPE.easy,
		enemies = 0,
		power_ups = 0,
		puff_color = "80795636",
		modulate_color = "ffffff"
	},
	3: {
		planet = 2,
		has_tiny = true,
		enemy_type = ENEMY_TYPE.easy,
		enemies = 1,
		power_ups = 1,
		puff_color = "808c9db1",
		modulate_color = "709cd0"
	},
	4: {
		planet = 2,
		has_tiny = true,
		enemy_type = ENEMY_TYPE.easy,
		enemies = 2,
		power_ups = 2,
		puff_color = "808c9db1",
		modulate_color = "709cd0"
	},
	5: {
		planet = 3,
		has_tiny = true,
		enemy_type = ENEMY_TYPE.medium,
		enemies = 1,
		power_ups = 3,
		puff_color = "8079917d",
		modulate_color = "89b48e"
	},
	6: {
		planet = 3,
		has_tiny = true,
		enemy_type = ENEMY_TYPE.medium,
		enemies = 2,
		power_ups = 4,
		puff_color = "8079917d",
		modulate_color = "89b48e"
	},
	7: {
		planet = 4,
		has_tiny = true,
		enemy_type = ENEMY_TYPE.hard,
		enemies = 2,
		power_ups = 5,
		puff_color = "80ec6474",
		modulate_color = "f5a2a6"
	},
	8: {
		planet = 4,
		has_tiny = true,
		enemy_type = ENEMY_TYPE.hard,
		enemies = 3,
		power_ups = 6,
		puff_color = "80ec6474",
		modulate_color = "f5a2a6"
	}
}

# The currently selected player type
var CURRENT_PLAYER_TYPE = PLAYER_TYPE.medium

# Whether or not we should be in full screen
var FULL_SCREEN = false

# Starting stage preference
var STARTING_STAGE = 1

# The current stage
var CURRENT_STAGE = STARTING_STAGE

# Background music modes - menus only, always, or never
enum BGM_MODE { menus_only = 0, always = 1, never = 2 }

# Current background music mode
var CURRENT_BGM_MODE = BGM_MODE.menus_only

# Background music volume
var BGM_VOLUME = 0.75

# Path for storing settings
var settings_file_path = "user://asteroids_settings.bin"

# Save settings
func save_settings():
	# Put settings into JSON object
	var settings = {
		full_screen = FULL_SCREEN,
		player_type = CURRENT_PLAYER_TYPE,
		starting_stage = STARTING_STAGE,
		bgm_mode = CURRENT_BGM_MODE,
		bgm_volume = BGM_VOLUME
	}
	# Save settings to file
	var file = File.new()
	file.open(settings_file_path, File.WRITE)
	file.store_line(settings.to_json())
	file.close()

# Load settings
func load_settings():
	# Read settings file into JSON object
	# To see location: print(OS.get_data_dir())
	var settings = {}
	var file = File.new()
	if file.file_exists(settings_file_path):
		file.open(settings_file_path, File.READ)
		settings.parse_json(file.get_line())
		# Put settings back to globals
		FULL_SCREEN = bool(settings.full_screen)
		CURRENT_PLAYER_TYPE = int(settings.player_type)
		STARTING_STAGE = int(settings.starting_stage)
		CURRENT_BGM_MODE = int(settings.bgm_mode)
		BGM_VOLUME = float(settings.bgm_volume)

# Array of the top 10 scores with names
var HIGHSCORES = []

# Path for storing highscores
var highscores_file_path = "user://asteroids_highscores.bin"

func load_highscores():
	# Initialise with empty set of 10
	HIGHSCORES = []
	for i in range(10):
		HIGHSCORES.append({ name = "---", score = 0 })

# Common handler for menu selection in scenes
func menu_select(node, event):
	var animation = node.get_node("animation")
	animation.connect("finished", self, "emit_menu_select", [node, event], CONNECT_ONESHOT)
	animation.play_backwards("menu")
	play_pressed()

# Emit signal after menu animation is finished
func emit_menu_select(node, event):
	node.emit_signal(event)

# Play the general selection sound from any place this is required
func play_pressed():
	get_node("/root/main/sample_player").play("pressed")

# Show the specified planet
func show_planet(number):
	get_node("/root/main/planets_container/planets").show_planet(number)

# Wrap (teleport) the specified node when it moves off the screen.
func screen_wrap(node):
	var screen_size = Vector2(Globals.get("display/width"), Globals.get("display/height"))
	var halfSpriteSize = node.get_node("Sprite").get_texture().get_size() * 0.5
	var originalPosition = node.get_pos()
	var position = originalPosition
	position.x = 0 - halfSpriteSize.width if position.x > screen_size.width + halfSpriteSize.width else position.x
	position.x = screen_size.width + halfSpriteSize.width if position.x < 0 - halfSpriteSize.width else position.x
	position.y = 0 - halfSpriteSize.height if position.y > screen_size.height + halfSpriteSize.height else position.y
	position.y = screen_size.height + halfSpriteSize.height if position.y < 0 - halfSpriteSize.height else position.y
	if position != originalPosition:
		node.set_pos(position)

# Sets up a button to use escape as a shortcut
func escape_button(button):
	var hotkey = InputEvent()
	hotkey.type = InputEvent.KEY
	hotkey.scancode = KEY_ESCAPE
	var shortcut = ShortCut.new()
	shortcut.set_shortcut(hotkey)
	button.set_shortcut(shortcut)
