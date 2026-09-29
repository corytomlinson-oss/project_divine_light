extends CharacterBody2D

const TILE_SIZE: int = 16
const MOVE_SPEED: float = 96.0
const WALL_ATLAS_COORDS := Vector2i(1, 0)
const DOOR_ATLAS_COORDS := Vector2i(2, 0)
const BOSS_ATLAS_COORDS := Vector2i(4, 0)
const CAPTIVE_ATLAS_COORDS := Vector2i(3, 0)

var _moving: bool = false
var _target: Vector2
var _steps_to_encounter: int = 0
## "down" / "up" / "left" / "right". Left has no art of its own - it plays the
## "side" animations (drawn facing right) with flip_h.
var _facing: String = "down"
@onready var _tile_map: TileMapLayer = get_parent()
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	add_to_group("player")  # how cutscenes find the player (Milestone 19a)
	_target = position
	# On the map you see the party's leader - whoever you started as
	# (Milestone 20a; Player.tscn's default is Vael's walk sheet).
	if not GameManager.party.is_empty():
		var path := "res://assets/sprites/%s_frames.tres" % GameManager.party[0].char_class.to_lower()
		if ResourceLoader.exists(path):
			_sprite.sprite_frames = load(path)
	_reset_encounter_counter()
	if GameManager.reopen_pause_menu:
		GameManager.reopen_pause_menu = false
		_reopen_pause_menu()


func _process(delta: float) -> void:
	if _moving:
		position = position.move_toward(_target, MOVE_SPEED * delta)
		if position.is_equal_approx(_target):
			position = _target
			_moving = false
			_on_tile_entered()
	elif Cutscene.is_playing():
		pass  # a cutscene is moving the player; no input until it ends
	elif Input.is_action_just_pressed("cancel") or Input.is_action_just_pressed("pause"):
		# B or Start opens the pause menu (Milestone 17c). Lives here, not in
		# Overworld.gd/Dungeon.gd, since Player.gd is shared by every map.
		_open_pause_menu()
	elif Input.is_action_just_pressed("confirm"):
		_interact()
	else:
		_handle_input()


## A talks to whatever is on the tile you're facing (Milestone 20a): the map
## decides what that means (a villager, the innkeeper, Frank's stall).
func _interact() -> void:
	var dirs := {"up": Vector2i.UP, "down": Vector2i.DOWN, "left": Vector2i.LEFT, "right": Vector2i.RIGHT}
	var front: Vector2i = _tile_map.local_to_map(position) + dirs[_facing]
	var map_root: Node = _tile_map.get_parent()
	if map_root.has_method("interact"):
		map_root.interact(front, _facing)


## Back from a screen the pause menu opened (Equip): show the menu again once
## the fade-in is done - the transition unpauses the tree when it finishes,
## which would otherwise leave the menu open over a running map.
func _reopen_pause_menu() -> void:
	if Transition.is_busy():
		await Transition.finished
	else:
		await get_tree().process_frame  # let the map controller place the player
	PauseMenu.open(self)


func _open_pause_menu() -> void:
	_play_anim("idle")
	Sfx.play("menu_confirm")
	PauseMenu.open(self)


func _handle_input() -> void:
	var dir := Vector2.ZERO

	if Input.is_action_pressed("right"):
		dir = Vector2.RIGHT
	elif Input.is_action_pressed("left"):
		dir = Vector2.LEFT
	elif Input.is_action_pressed("down"):
		dir = Vector2.DOWN
	elif Input.is_action_pressed("up"):
		dir = Vector2.UP

	if dir == Vector2.ZERO:
		_play_anim("idle")
		return

	_face(dir)
	var next_target: Vector2 = position + dir * TILE_SIZE
	if not _is_walkable(next_target):
		# Turn to face the wall but stay standing, like classic tile RPGs.
		_play_anim("idle")
		return

	_target = next_target
	_moving = true
	_play_anim("walk")


func _face(dir: Vector2) -> void:
	if dir == Vector2.RIGHT:
		_facing = "right"
	elif dir == Vector2.LEFT:
		_facing = "left"
	elif dir == Vector2.DOWN:
		_facing = "down"
	else:
		_facing = "up"


## Only called from _handle_input(), never on tile arrival - holding a
## direction goes arrive -> _handle_input() -> walk again on the next frame,
## and play() with the already-playing animation continues it rather than
## restarting, so the walk cycle runs smoothly across tiles instead of
## flashing the idle frame at every tile boundary.
func _play_anim(kind: String) -> void:
	var sheet_dir: String = "side" if _facing == "left" or _facing == "right" else _facing
	_sprite.flip_h = _facing == "left"
	_sprite.play(kind + "_" + sheet_dir)


func _is_walkable(world_pos: Vector2) -> bool:
	var cell: Vector2i = _tile_map.local_to_map(world_pos)
	if _tile_map.get_cell_atlas_coords(cell) == WALL_ATLAS_COORDS:
		return false
	# Maps can block more: water, buildings, people standing there (20a).
	var map_root: Node = _tile_map.get_parent()
	return not (map_root.has_method("is_blocked") and map_root.is_blocked(cell))


func _on_tile_entered() -> void:
	var cell: Vector2i = _tile_map.local_to_map(position)
	var coords: Vector2i = _tile_map.get_cell_atlas_coords(cell)
	var map_root: Node = _tile_map.get_parent()
	# The gate tile is always a door; maps can declare others (the overworld's
	# stone arches into dungeons).
	if coords == DOOR_ATLAS_COORDS or (map_root.has_method("is_door") and map_root.is_door(cell)):
		_use_door(cell)
		return
	if coords == BOSS_ATLAS_COORDS:
		_trigger_boss_battle()
		return
	if coords == CAPTIVE_ATLAS_COORDS and map_root.has_method("on_captive_tile"):
		# A captive's rune (Milestone 20a): the dungeon decides what happens.
		map_root.on_captive_tile(cell)
		return
	_check_encounter()


func _use_door(cell: Vector2i) -> void:
	var map_root: Node = _tile_map.get_parent()
	if not map_root.has_method("get_door_destination"):
		return
	var dest: Dictionary = map_root.get_door_destination(cell)
	if dest.get("boss", false):
		# A door guarded by a boss (an escape warden): walking up to it starts
		# the fight.
		_trigger_boss_battle()
	elif dest.has("blocked"):
		# A gated or unfinished door (Milestone 20a): say why, stay put.
		Cutscene.play_text("narrate " + String(dest["blocked"]))
	elif not dest.is_empty():
		Transition.change_scene(dest["scene"])


func _check_encounter() -> void:
	_steps_to_encounter -= 1
	if _steps_to_encounter <= 0:
		_reset_encounter_counter()
		GameManager.pending_spawn_position = position
		GameManager.has_pending_spawn = true
		Transition.to_battle()


## Fixed, visible encounter (Milestone 14) - unlike _check_encounter()'s random
## step-triggered roll, walking onto a boss tile always starts a fight.
func _trigger_boss_battle() -> void:
	GameManager.pending_spawn_position = position
	GameManager.has_pending_spawn = true
	GameManager.pending_boss_battle = true
	Transition.to_battle()


## For map scripts that start the boss fight themselves (a captive's jailer).
func start_boss_battle() -> void:
	_trigger_boss_battle()


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
