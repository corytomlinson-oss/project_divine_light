extends CharacterBody2D

const TILE_SIZE: int = 16
const MOVE_SPEED: float = 96.0
const WALL_ATLAS_COORDS := Vector2i(1, 0)
const DOOR_ATLAS_COORDS := Vector2i(2, 0)
const BOSS_ATLAS_COORDS := Vector2i(4, 0)

var _moving: bool = false
var _target: Vector2
var _steps_to_encounter: int = 0
@onready var _tile_map: TileMapLayer = get_parent()


func _ready() -> void:
	_target = position
	_reset_encounter_counter()


## Milestone 15's equip screen entry point. Lives here (not Overworld.gd or
## Dungeon.gd) since Player.gd is already shared between every map scene, so
## this works from both Overworld and dungeons for free. Not the full "B =
## main menu" shell the design doc's controller mapping describes - there's
## no Formation/Inventory/Party status screen to put alongside it yet, so
## this is a single-purpose key straight to the one screen that exists.
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		GameManager.pending_spawn_position = position
		GameManager.has_pending_spawn = true
		get_tree().change_scene_to_file("res://scenes/equip/Equip.tscn")


func _process(delta: float) -> void:
	if _moving:
		position = position.move_toward(_target, MOVE_SPEED * delta)
		if position.is_equal_approx(_target):
			position = _target
			_moving = false
			_on_tile_entered()
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

	var next_target: Vector2 = position + dir * TILE_SIZE
	if not _is_walkable(next_target):
		return

	_target = next_target
	_moving = true


func _is_walkable(world_pos: Vector2) -> bool:
	var cell: Vector2i = _tile_map.local_to_map(world_pos)
	return _tile_map.get_cell_atlas_coords(cell) != WALL_ATLAS_COORDS


func _on_tile_entered() -> void:
	var cell: Vector2i = _tile_map.local_to_map(position)
	var coords: Vector2i = _tile_map.get_cell_atlas_coords(cell)
	if coords == DOOR_ATLAS_COORDS:
		_use_door(cell)
		return
	if coords == BOSS_ATLAS_COORDS:
		_trigger_boss_battle()
		return
	_check_encounter()


func _use_door(cell: Vector2i) -> void:
	var map_root: Node = _tile_map.get_parent()
	if not map_root.has_method("get_door_destination"):
		return
	var dest: Dictionary = map_root.get_door_destination(cell)
	if not dest.is_empty():
		get_tree().change_scene_to_file(dest["scene"])


func _check_encounter() -> void:
	_steps_to_encounter -= 1
	if _steps_to_encounter <= 0:
		_reset_encounter_counter()
		GameManager.pending_spawn_position = position
		GameManager.has_pending_spawn = true
		get_tree().change_scene_to_file("res://scenes/battle/Battle.tscn")


## Fixed, visible encounter (Milestone 14) - unlike _check_encounter()'s random
## step-triggered roll, walking onto a boss tile always starts a fight.
func _trigger_boss_battle() -> void:
	GameManager.pending_spawn_position = position
	GameManager.has_pending_spawn = true
	GameManager.pending_boss_battle = true
	get_tree().change_scene_to_file("res://scenes/battle/Battle.tscn")


func _reset_encounter_counter() -> void:
	_steps_to_encounter = randi_range(10, 20)


## Directly repositions the player, bypassing the tile-to-tile tween. For a
## map's own controller script to call right after generating/loading its
## layout (Dungeon.gd uses this for the procedurally-chosen spawn point) -
## distinct from GameManager's pending-spawn mechanism, which is specifically
## for "restore where I was before a battle interrupted me."
func snap_to(world_pos: Vector2) -> void:
	position = world_pos
	_target = world_pos
	_moving = false
