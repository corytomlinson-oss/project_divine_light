extends Node2D

const FLOOR_COORDS := Vector2i(0, 0)
const WALL_COORDS := Vector2i(1, 0)
const DOOR_COORDS := Vector2i(2, 0)
const CAPTIVE_COORDS := Vector2i(3, 0)
const BOSS_COORDS := Vector2i(4, 0)
const OVERWORLD_SCENE_PATH := "res://scenes/overworld/Overworld.tscn"

# Milestone 13b template for The Cathedral. Once a second dungeon exists this
# needs to become per-scene data (a dictionary keyed by location, or an
# @export on this scene) rather than a single hardcoded const - not built
# that way yet since there's only one dungeon to drive it.
const CATHEDRAL_TEMPLATE := {
	"min_rooms": 5,
	"max_rooms": 8,
	"room_min_size": Vector2i(4, 4),
	"room_max_size": Vector2i(7, 6),
}

const TAG_TO_COORDS := {
	DungeonGenerator.FLOOR: FLOOR_COORDS,
	DungeonGenerator.WALL: WALL_COORDS,
	DungeonGenerator.DOOR: DOOR_COORDS,
	DungeonGenerator.CAPTIVE_MARKER: CAPTIVE_COORDS,
	DungeonGenerator.BOSS_TRIGGER: BOSS_COORDS,
}

@onready var _tile_map: TileMapLayer = $TileMapLayer
@onready var _player: Node2D = $TileMapLayer/Player

var _entrance_cell: Vector2i
var _exit_cell: Vector2i
var _boss_trigger_cell: Vector2i


func _ready() -> void:
	GameManager.current_location = "cathedral"
	GameManager.current_scene_path = "res://scenes/dungeon/CathedralDungeon.tscn"
	_generate_and_build()


func _generate_and_build() -> void:
	var seed_value: int = GameManager.get_dungeon_seed(GameManager.current_location)
	var layout: Dictionary = DungeonGenerator.generate(CATHEDRAL_TEMPLATE, seed_value)
	var boss_defeated: bool = GameManager.defeated_bosses.get(GameManager.current_location, false)

	for cell in layout["tiles"].keys():
		var tag: String = layout["tiles"][cell]
		# A defeated boss's trigger tile reverts to plain floor - the fight
		# doesn't come back once won.
		if tag == DungeonGenerator.BOSS_TRIGGER and boss_defeated:
			tag = DungeonGenerator.FLOOR
		_tile_map.set_cell(cell, 0, TAG_TO_COORDS[tag])

	_entrance_cell = layout["entrance_cell"]
	_exit_cell = layout["exit_cell"]
	_boss_trigger_cell = layout["boss_trigger_cell"]

	if GameManager.has_pending_spawn:
		_player.snap_to(GameManager.pending_spawn_position)
		GameManager.has_pending_spawn = false
	else:
		_player.snap_to(_tile_map.map_to_local(layout["player_spawn"]))


func get_door_destination(cell: Vector2i) -> Dictionary:
	if cell == _entrance_cell or cell == _exit_cell:
		return {"scene": OVERWORLD_SCENE_PATH}
	return {}
