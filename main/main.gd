extends Node

var current_scene
onready var scene_container = get_node("scene_container")

func _ready():
	# Load previously saved settings
	globals.load_settings()
	globals.load_highscores()
	OS.set_window_fullscreen(globals.FULL_SCREEN)
	# Once off randomize so it is properly seeded
	randomize()
	# Splash screen is shown first, then main screen
	load_background()
	var tween = get_node("tween")
	tween.interpolate_property(get_node("splash_container"), "visibility/opacity", 0, 1, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(get_node("splash_container"), "visibility/opacity", 1, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 2)
	tween.interpolate_callback(self, 3, "start")
	tween.start()

func start():
	# Load up the common elements and menu
	load_planets()
	load_title()
	load_menu()
	bgm_set()
	bgm_volume_changed()

# Load and add the background scene
func load_background():
	get_node("background_container").add_child(preload("res://main/background.tscn").instance())

# Load and add the planets scene
func load_planets():
	get_node("planets_container").add_child(preload("res://main/planets.tscn").instance())

# Load and add the title scene
func load_title():
	var title = preload("res://main/title.tscn").instance()
	get_node("title_container").add_child(title)
	title.show()

# Load the menu scene into the main scene container and hook-up signals
func load_menu():
	unload_current_scene()
	globals.show_planet(1)
	current_scene = preload("res://main/menu.tscn").instance()
	current_scene.connect("start_game", self, "ship_select", [], CONNECT_ONESHOT)
	current_scene.connect("highscores", self, "highscores", [], CONNECT_ONESHOT)
	current_scene.connect("game_settings", self, "game_settings", [], CONNECT_ONESHOT)
	current_scene.connect("about_game", self, "about_game", [], CONNECT_ONESHOT)
	current_scene.connect("quit_game", self, "quit_game", [], CONNECT_ONESHOT)
	scene_container.add_child(current_scene)

# Load the ship selection scene into the main scene container and hook-up signals
func ship_select():
	unload_current_scene()
	current_scene = preload("res://main/ship_select.tscn").instance()
	current_scene.connect("ship_chosen", self, "start_game", [], CONNECT_ONESHOT)
	current_scene.connect("back", self, "load_menu", [], CONNECT_ONESHOT)
	scene_container.add_child(current_scene)

# Load the game scene into the main scene container and start
func start_game():
	unload_current_scene()
	globals.SCORE = 0
	globals.CURRENT_STAGE = globals.STARTING_STAGE
	get_node("title_container").get_child(0).hide()
	current_scene = preload("res://game/game.tscn").instance()
	current_scene.connect("exit_game", self, "exit_game", [], CONNECT_ONESHOT)
	scene_container.add_child(current_scene)
	current_scene.setup()
	current_scene.start()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if globals.CURRENT_BGM_MODE == globals.BGM_MODE.menus_only:
		get_node("background_music").stop()

# Exit a game which is playing
func exit_game():
	if globals.CURRENT_BGM_MODE == globals.BGM_MODE.menus_only:
		get_node("background_music").play()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_node("title_container").get_child(0).show()
	# If you got a highscore then load entry scene, otherwise load menu
	highscore_entry() if globals.is_highscore(globals.SCORE) > 0 else load_menu()

# Load the highscore entry scene into the main container
func highscore_entry():
	unload_current_scene()
	current_scene = preload("res://main/highscore_entry.tscn").instance()
	current_scene.connect("back", self, "highscores", [], CONNECT_ONESHOT)
	scene_container.add_child(current_scene)

# Load the highscores scene into the main container
func highscores():
	unload_current_scene()
	current_scene = preload("res://main/highscores.tscn").instance()
	current_scene.connect("back", self, "load_menu", [], CONNECT_ONESHOT)
	scene_container.add_child(current_scene)

# Load the settings scene into the main container
func game_settings():
	unload_current_scene()
	current_scene = preload("res://main/settings.tscn").instance()
	current_scene.connect("back", self, "load_menu", [], CONNECT_ONESHOT)
	current_scene.connect("bgm_set", self, "bgm_set")
	current_scene.connect("bgm_volume_changed", self, "bgm_volume_changed")
	current_scene.connect("reset_highscores", self, "highscores")
	scene_container.add_child(current_scene)

func bgm_set():
	if globals.CURRENT_BGM_MODE == globals.BGM_MODE.never:
		get_node("background_music").stop()
	elif !get_node("background_music").is_playing():
		get_node("background_music").play()

func bgm_volume_changed():
	get_node("background_music").set_volume(globals.BGM_VOLUME)

# Load the about game scene into the main container
func about_game():
	unload_current_scene()
	current_scene = preload("res://main/about.tscn").instance()
	current_scene.connect("back", self, "load_menu", [], CONNECT_ONESHOT)
	scene_container.add_child(current_scene)

# Quit the game
func quit_game():
	get_tree().quit()

# Unload and free the current scene
func unload_current_scene():
	if current_scene != null:
		current_scene.queue_free()
