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

# The currently selected player type
var CURRENT_PLAYER_TYPE = PLAYER_TYPE.medium

# Background music modes - menus only, always, or never
enum BGM_MODE { menus_only = 0, always = 1, never = 3 }

# Current background music mode
var CURRENT_BGM_MODE = BGM_MODE.menus_only

# Background music volume
var BGM_VOLUME = 0.75

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

# Wrap (teleport) the specified node when it moves off the screen.
# The sprite's origin will be at the center, so we need to wait until the current position plus or minus half the width or
# height of the sprite is outside of the screen's bounds before teleporting it to the opposite side.  Otherwise it
# would jump while still visible.
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
