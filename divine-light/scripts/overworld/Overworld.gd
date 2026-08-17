extends Node2D

const CATHEDRAL_DOOR_CELL := Vector2i(8, 5)
const CATHEDRAL_SCENE_PATH := "res://scenes/dungeon/CathedralDungeon.tscn"

# The Milestone 1 hand-painted floor patch turns out to be a clean rectangle
# (confirmed by inspecting the actual tile_map_data). It had zero wall tiles
# anywhere - a gap flagged back in Milestone 13a - since there was no reason
# to paint walls before the wall tile had real art. Now that it does
# (Milestone 16), it's worth finally closing that gap.
const FLOOR_MIN := Vector2i(-4, -9)
const FLOOR_MAX := Vector2i(8, 10)
const WALL_COORDS := Vector2i(1, 0)

# The player's spawn cell (10,5) sits outside the floor rectangle in empty
# space - also flagged back in 13a as "harmless since empty cells are
# walkable, but worth knowing if that ever changes." It just changed: a full
# wall border would trap the player outside it. These cells stay open as the
# entry point from spawn into the floor area, instead of moving spawn.
# Deliberately excludes row 5 (the door's own row) - an earlier version only
# opened row 5 and funneled the player straight onto the door tile the
# instant they walked in, making the grass interior itself unreachable.
# A single-row gap one row off fixed that but turned out hard to actually
# find with no diagonal movement (found via playtesting) - a few rows wide
# is far more forgiving to walk into by eye.
const ENTRY_GAP_ROWS: Array = [2, 3, 4, 6, 7, 8]
const ENTRY_GAP_X := 9

@onready var _tile_map: TileMapLayer = $TileMapLayer
@onready var _player: Node2D = $TileMapLayer/Player


func _ready() -> void:
	GameManager.current_location = "overworld"
	GameManager.current_scene_path = "res://scenes/overworld/Overworld.tscn"
	_paint_wall_border()
	_tile_map.set_cell(CATHEDRAL_DOOR_CELL, 0, Vector2i(2, 0))
	if GameManager.has_pending_spawn:
		_player.snap_to(GameManager.pending_spawn_position)
		GameManager.has_pending_spawn = false


func _paint_wall_border() -> void:
	var min_x: int = FLOOR_MIN.x - 1
	var max_x: int = FLOOR_MAX.x + 1
	var min_y: int = FLOOR_MIN.y - 1
	var max_y: int = FLOOR_MAX.y + 1
	for x in range(min_x, max_x + 1):
		_paint_wall(Vector2i(x, min_y))
		_paint_wall(Vector2i(x, max_y))
	for y in range(min_y, max_y + 1):
		_paint_wall(Vector2i(min_x, y))
		_paint_wall(Vector2i(max_x, y))


func _paint_wall(cell: Vector2i) -> void:
	if cell.x == ENTRY_GAP_X and ENTRY_GAP_ROWS.has(cell.y):
		return
	_tile_map.set_cell(cell, 0, WALL_COORDS)


func get_door_destination(cell: Vector2i) -> Dictionary:
	if cell == CATHEDRAL_DOOR_CELL:
		return {"scene": CATHEDRAL_SCENE_PATH}
	return {}
