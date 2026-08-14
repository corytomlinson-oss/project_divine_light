extends Node2D

const ROOM_WIDTH := 9
const ROOM_HEIGHT := 7
const ENTRANCE_CELL := Vector2i(4, 6)
const EXIT_CELL := Vector2i(4, 0)
const FLOOR_COORDS := Vector2i(0, 0)
const WALL_COORDS := Vector2i(1, 0)
const DOOR_COORDS := Vector2i(2, 0)
const OVERWORLD_SCENE_PATH := "res://scenes/overworld/Overworld.tscn"

@onready var _tile_map: TileMapLayer = $TileMapLayer


func _ready() -> void:
	GameManager.current_location = "cathedral"
	GameManager.current_scene_path = "res://scenes/dungeon/CathedralDungeon.tscn"
	_build_test_layout()


# Temporary hand-placed test room for Milestone 13a, used to validate dungeon
# tech (wall collision, doors, encounters) against a fully known layout.
# Replaced by Milestone 13b's template -> room graph -> tile layout generator.
func _build_test_layout() -> void:
	for x in ROOM_WIDTH:
		for y in ROOM_HEIGHT:
			var cell := Vector2i(x, y)
			var is_border: bool = x == 0 or y == 0 or x == ROOM_WIDTH - 1 or y == ROOM_HEIGHT - 1
			if cell == ENTRANCE_CELL or cell == EXIT_CELL:
				_tile_map.set_cell(cell, 0, DOOR_COORDS)
			elif is_border:
				_tile_map.set_cell(cell, 0, WALL_COORDS)
			else:
				_tile_map.set_cell(cell, 0, FLOOR_COORDS)


func get_door_destination(cell: Vector2i) -> Dictionary:
	if cell == ENTRANCE_CELL or cell == EXIT_CELL:
		return {"scene": OVERWORLD_SCENE_PATH}
	return {}
