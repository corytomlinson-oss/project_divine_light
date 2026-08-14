extends Node2D

const CATHEDRAL_DOOR_CELL := Vector2i(8, 5)
const CATHEDRAL_SCENE_PATH := "res://scenes/dungeon/CathedralDungeon.tscn"

@onready var _tile_map: TileMapLayer = $TileMapLayer


func _ready() -> void:
	GameManager.current_location = "overworld"
	GameManager.current_scene_path = "res://scenes/overworld/Overworld.tscn"
	_tile_map.set_cell(CATHEDRAL_DOOR_CELL, 0, Vector2i(2, 0))


func get_door_destination(cell: Vector2i) -> Dictionary:
	if cell == CATHEDRAL_DOOR_CELL:
		return {"scene": CATHEDRAL_SCENE_PATH}
	return {}
