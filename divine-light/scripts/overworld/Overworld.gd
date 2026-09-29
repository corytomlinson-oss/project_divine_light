extends Node2D

# The Forest Heartlands - Act I's overworld (Milestone 20a), painted from the
# text map below every time the scene loads (the scene file's own tile data is
# cleared first). Edit MAP to change the land.
#
#   .  grass      T  trees (wall)    =  road       ~  water (blocked)
#   *  flowers    V  Verdance        E  Edenmere   (town gates)
#   C  The Cathedral   M  The Monastery   O  The Observatory
#   G  The Underground Guild                        (dungeon arches)
#
# Leaving a town or dungeon sets GameManager.arrival, and the player appears
# just outside that entrance. Returning from a battle uses the saved spot.

const MAP := [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTT..TTTTTTT",
	"TTTTTT...C....TTTTTTTTT....M....TTTT",
	"TTTTT....=.....TTTTTTT...*.=.....TTT",
	"TTTT.....=.....TTTTTTT.....=.....TTT",
	"TTTTT*...=.....TTTTTTT.....=.....TTT",
	"TTTTTT...=...TTTTTTTTTT....=....TTTT",
	"TTTTTTT.T=.TTTTTTTTTTTTTTTT=TTTTTTTT",
	"TTTTT....=.*.TTTT.TTTTTTTTT=T.TTTTTT",
	"TTTT.....=..............TT.=.....TTT",
	"TTT......=..............T..=...*..TT",
	"TTT......=........==============..TT",
	"TTT......V=========............=O..T",
	"TTT...............=...TTT.........TT",
	"TTT~~~~~........TT=TTTTTT.........TT",
	"TTT~~~~~......TTTT===========...TTTT",
	"TTT~~~~~.....TTTTT=TTTTTTTTT=TTTTTTT",
	"TTTTTTTTTTTTT.....=...TTTTTT=TTTTTTT",
	"TTTTTTTTTTTT......=.*...T...=...TTTT",
	"TTTTTTTTTTT.......=.........===..TTT",
	"TTTTTTTTTTT.......=...........=E.TTT",
	"TTTTTTTTTTTTT.....G..TTT.........TTT",
	"TTTTTTTTTTTTTTTTT.TTTTTTT.......TTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
]
const TILES := {".": Vector2i(0, 0), "T": Vector2i(1, 0), "=": Vector2i(3, 0), "~": Vector2i(5, 0), "*": Vector2i(6, 0)}
const GATE := Vector2i(2, 0)
const ARCH := Vector2i(4, 0)
const WATER := Vector2i(5, 0)
const ENTRANCES := {
	"V": "verdance", "E": "edenmere",
	"C": "cathedral", "M": "monastery", "O": "observatory", "G": "guild",
}
const TOWNS := {
	"verdance": {"name": "Verdance", "scene": "res://scenes/town/Verdance.tscn"},
	"edenmere": {"name": "Edenmere", "scene": ""},
}

@onready var _tile_map: TileMapLayer = $TileMapLayer
@onready var _player: Node2D = $TileMapLayer/Player

var _entrances: Dictionary = {}  # cell -> entrance id


func _ready() -> void:
	GameManager.current_location = "overworld"
	GameManager.current_scene_path = "res://scenes/overworld/Overworld.tscn"
	Music.play("overworld")
	_tile_map.y_sort_enabled = true  # characters lower on screen draw in front
	_paint()
	if GameManager.has_pending_spawn:
		_player.snap_to(GameManager.pending_spawn_position)
		GameManager.has_pending_spawn = false
	else:
		var id := GameManager.arrival if GameManager.arrival != "" else "verdance"
		_player.snap_to(_tile_map.map_to_local(_outside(id)))
	GameManager.arrival = ""


func _paint() -> void:
	_tile_map.clear()
	for y in MAP.size():
		var row: String = MAP[y]
		for x in row.length():
			var ch := row[x]
			var cell := Vector2i(x, y)
			if ENTRANCES.has(ch):
				var id: String = ENTRANCES[ch]
				_entrances[cell] = id
				_tile_map.set_cell(cell, 0, GATE if TOWNS.has(id) else ARCH)
			else:
				_tile_map.set_cell(cell, 0, TILES.get(ch, TILES["T"]))


## The walkable tile just outside an entrance (south first, then the rest).
func _outside(id: String) -> Vector2i:
	for cell: Vector2i in _entrances:
		if _entrances[cell] != id:
			continue
		for d: Vector2i in [Vector2i.DOWN, Vector2i.UP, Vector2i.RIGHT, Vector2i.LEFT]:
			var n := cell + d
			if _tile_map.get_cell_atlas_coords(n) in [TILES["."], TILES["="], TILES["*"]]:
				return n
	return Vector2i(9, 13)


func is_door(cell: Vector2i) -> bool:
	return _entrances.has(cell)


func is_blocked(cell: Vector2i) -> bool:
	return _tile_map.get_cell_atlas_coords(cell) == WATER


func get_door_destination(cell: Vector2i) -> Dictionary:
	var id: String = _entrances.get(cell, "")
	if id == "":
		return {}
	if TOWNS.has(id):
		var town: Dictionary = TOWNS[id]
		if town["scene"] == "":
			return {"blocked": "The road to %s is still overgrown. (Coming in a later update.)" % town["name"]}
		return {"scene": town["scene"]}
	var dungeon: Dictionary = ActOne.DUNGEONS[id]
	if not ActOne.can_enter(id):
		return {"blocked": dungeon["gate_text"]}
	if dungeon["scene"] == "":
		return {"blocked": "%s lies ahead, but the way isn't open yet. (Coming in a later update.)" % dungeon["name"]}
	return {"scene": dungeon["scene"]}
