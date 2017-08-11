extends Node

onready var animation = get_node("animation")
onready var asteroid_container = get_node("asteroid_container")
var asteroid_factory = preload("res://game/asteroid_factory.tscn").instance()

# This is basically just some hacked up code to create asteroids to float around on the title screen.

func show():
	animation.play("in")
	var asteroid = asteroid_factory.generate_asteroid(0)
	asteroid.setup(0, Vector2(500, 200), Vector2(rand_range(10, 50), 0).rotated(rand_range(0, 2 * PI)))
	asteroid.get_node("Sprite").set("modulate", "#ff999999")
	asteroid_container.add_child(asteroid)
	asteroid.start()
	asteroid = asteroid_factory.generate_asteroid(1)
	asteroid.setup(0, Vector2(600, 400), Vector2(rand_range(10, 50), 0).rotated(rand_range(0, 2 * PI)))
	asteroid.get_node("Sprite").set("modulate", "#ff999999")
	asteroid_container.add_child(asteroid)
	asteroid.start()
	asteroid = asteroid_factory.generate_asteroid(0)
	asteroid.setup(0, Vector2(800, 400), Vector2(rand_range(10, 50), 0).rotated(rand_range(0, 2 * PI)))
	asteroid.get_node("Sprite").set("modulate", "#ff999999")
	asteroid_container.add_child(asteroid)
	asteroid.start()
	asteroid = asteroid_factory.generate_asteroid(0)
	asteroid.setup(0, Vector2(1100, 650), Vector2(rand_range(10, 50), 0).rotated(rand_range(0, 2 * PI)))
	asteroid.get_node("Sprite").set("modulate", "#ff999999")
	asteroid_container.add_child(asteroid)
	asteroid.start()
	asteroid = asteroid_factory.generate_asteroid(1)
	asteroid.setup(0, Vector2(950, 250), Vector2(rand_range(10, 50), 0).rotated(rand_range(0, 2 * PI)))
	asteroid.get_node("Sprite").set("modulate", "#ff999999")
	asteroid_container.add_child(asteroid)
	asteroid.start()
	asteroid = asteroid_factory.generate_asteroid(1)
	asteroid.setup(0, Vector2(900, 500), Vector2(rand_range(10, 50), 0).rotated(rand_range(0, 2 * PI)))
	asteroid.get_node("Sprite").set("modulate", "#ff999999")
	asteroid_container.add_child(asteroid)
	asteroid.start()

func hide():
	animation.play_backwards("in")
	for asteroid in asteroid_container.get_children():
		asteroid.queue_free()
