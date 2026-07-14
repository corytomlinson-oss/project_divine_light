extends CharacterBody2D

const TILE_SIZE: int = 16
const MOVE_SPEED: float = 96.0  # pixels per second — 6 tiles/sec

var _moving: bool = false
var _target: Vector2


func _ready() -> void:
	_target = position
	print("Player script loaded at position: ", position)


func _process(delta: float) -> void:
	if _moving:
		position = position.move_toward(_target, MOVE_SPEED * delta)
		if position.is_equal_approx(_target):
			position = _target
			_moving = false
	else:
		_handle_input()


func _handle_input() -> void:
	var dir := Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		print("RIGHT")
		dir = Vector2.RIGHT
	elif Input.is_action_pressed("ui_left"):
		print("LEFT")
		dir = Vector2.LEFT
	elif Input.is_action_pressed("ui_down"):
		print("DOWN")
		dir = Vector2.DOWN
	elif Input.is_action_pressed("ui_up"):
		print("UP")
		dir = Vector2.UP

	if dir == Vector2.ZERO:
		return

	# Collision check temporarily disabled — add back once tileset is set up
	_target = position + dir * TILE_SIZE
	_moving = true
