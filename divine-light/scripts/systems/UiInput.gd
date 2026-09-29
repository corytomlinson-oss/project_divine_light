extends Node

# Menu navigation with hold-to-repeat (Milestone 17c). Every menu used to read
# is_action_just_pressed, so a long list meant one press per row. Menus call
# UiInput.nav(&"down") instead: true on the press, then again every REPEAT
# seconds once the direction has been held for FIRST_DELAY.
#
# This autoload sits before the current scene in the tree, so its _process
# runs first each frame and the flags are ready when menus read them. It
# keeps running while the tree is paused (the pause menu needs it).

const DIRECTIONS: Array[StringName] = [&"up", &"down", &"left", &"right"]
const FIRST_DELAY := 0.3
const REPEAT := 0.08

var _held := {}
var _fired := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	for action in DIRECTIONS:
		_fired[action] = false
		if Input.is_action_just_pressed(action):
			_held[action] = 0.0
			_fired[action] = true
		elif Input.is_action_pressed(action):
			var before: float = _held.get(action, 0.0)
			var after := before + delta
			_held[action] = after
			if after >= FIRST_DELAY:
				var ticks_before := floori((before - FIRST_DELAY) / REPEAT) if before >= FIRST_DELAY else -1
				_fired[action] = floori((after - FIRST_DELAY) / REPEAT) > ticks_before
		else:
			_held[action] = 0.0


## True on the frame a direction is pressed, and on each repeat while held.
func nav(action: StringName) -> bool:
	return _fired.get(action, false)
