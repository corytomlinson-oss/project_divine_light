extends CharacterBody2D

const TILE_SIZE: int = 16
const MOVE_SPEED: float = 96.0

var _moving: bool = false
var _target: Vector2
var _steps_to_encounter: int = 0


func _ready() -> void:
	_target = position
	_reset_encounter_counter()


func _process(delta: float) -> void:
	if _moving:
		position = position.move_toward(_target, MOVE_SPEED * delta)
		if position.is_equal_approx(_target):
			position = _target
			_moving = false
			_check_encounter()
	else:
		_handle_input()


func _handle_input() -> void:
	var dir := Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		dir = Vector2.RIGHT
	elif Input.is_action_pressed("ui_left"):
		dir = Vector2.LEFT
	elif Input.is_action_pressed("ui_down"):
		dir = Vector2.DOWN
	elif Input.is_action_pressed("ui_up"):
		dir = Vector2.UP

	if dir == Vector2.ZERO:
		return

	_target = position + dir * TILE_SIZE
	_moving = true


func _check_encounter() -> void:
	_steps_to_encounter -= 1
	if _steps_to_encounter <= 0:
		_reset_encounter_counter()
		get_tree().change_scene_to_file("res://scenes/battle/Battle.tscn")


func _reset_encounter_counter() -> void:
	_steps_to_encounter = randi_range(10, 20)
