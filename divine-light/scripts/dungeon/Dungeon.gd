extends Node2D

# A generated Act I dungeon (Milestone 13b's generator; story variants from
# Milestone 20a). The same layout plays one of two ways:
#
#   escape - the player's own starting dungeon: they wake in a cell in the
#            deepest room, free Frank from the captive room partway out, and
#            must beat the escape warden guarding the only exit.
#   rescue - someone else's dungeon: the captive is held in the deepest room,
#            guarded by the dungeon's boss; beat it, reach them, they join.
#
# Location ids: "<dungeon>_escape" for the escape variant (its own encounter
# table, boss and seed), "<dungeon>" for the rescue. Story beats are cutscene
# files in data/cutscenes/.

const FLOOR_COORDS := Vector2i(0, 0)
const WALL_COORDS := Vector2i(1, 0)
const DOOR_COORDS := Vector2i(2, 0)
const CAPTIVE_COORDS := Vector2i(3, 0)
const BOSS_COORDS := Vector2i(4, 0)
const OVERWORLD_SCENE_PATH := "res://scenes/overworld/Overworld.tscn"

# Per-dungeon generation templates (13b) and story scenes (20a).
const DUNGEONS := {
	"cathedral": {
		"template": {"min_rooms": 5, "max_rooms": 8, "room_min_size": Vector2i(4, 4), "room_max_size": Vector2i(7, 6)},
		"scene": "res://scenes/dungeon/CathedralDungeon.tscn",
		"wake_scene": "res://data/cutscenes/cathedral_wake.scene",
		"frank_scene": "res://data/cutscenes/cathedral_frank.scene",
		"escaped_scene": "res://data/cutscenes/cathedral_escaped.scene",
		"rescue_scene": "res://data/cutscenes/cathedral_rescue.scene",
	},
}

const TAG_TO_COORDS := {
	DungeonGenerator.FLOOR: FLOOR_COORDS,
	DungeonGenerator.WALL: WALL_COORDS,
	DungeonGenerator.DOOR: DOOR_COORDS,
	DungeonGenerator.CAPTIVE_MARKER: CAPTIVE_COORDS,
	DungeonGenerator.BOSS_TRIGGER: BOSS_COORDS,
}

## Which ActOne dungeon this scene is.
@export var dungeon_id := "cathedral"

@onready var _tile_map: TileMapLayer = $TileMapLayer
@onready var _player: Node2D = $TileMapLayer/Player

var _escape := false
var _data: Dictionary
var _exit_cell: Vector2i
var _captive_cell: Vector2i


func _ready() -> void:
	_data = DUNGEONS[dungeon_id]
	_escape = ActOne.is_start_dungeon(dungeon_id)
	GameManager.current_location = dungeon_id + ("_escape" if _escape else "")
	GameManager.current_scene_path = _data["scene"]
	Music.play("dungeon")
	# Characters lower on screen draw in front (a captive standing just above
	# the player, cutscene actors walking past each other).
	_tile_map.y_sort_enabled = true
	_generate_and_build()
	_play_arrival_story()


func _boss_defeated() -> bool:
	return GameManager.defeated_bosses.get(GameManager.current_location, false)


func _generate_and_build() -> void:
	var seed_value: int = GameManager.get_dungeon_seed(GameManager.current_location)
	var layout: Dictionary = DungeonGenerator.generate(_data["template"], seed_value)
	var tiles: Dictionary = layout["tiles"]
	var deep_door: Vector2i = layout["exit_cell"]
	var spawn: Vector2i = layout["player_spawn"]
	var boss_cell: Vector2i = layout["boss_trigger_cell"]

	# Both variants: the deep room's door is gone (that room is a cell), so the
	# entrance is the only way in or out.
	tiles[deep_door] = DungeonGenerator.FLOOR
	_exit_cell = layout["entrance_cell"]
	if _escape:
		# The player's cell is deep inside; the warden waits by the exit.
		tiles[boss_cell] = DungeonGenerator.FLOOR
		tiles[spawn] = DungeonGenerator.BOSS_TRIGGER
		var swap := spawn
		spawn = boss_cell
		boss_cell = swap
		_captive_cell = layout["captive_cell"]  # Frank's cell, partway out
		if GameManager.has_flag("met_frank"):
			tiles[_captive_cell] = DungeonGenerator.FLOOR
	else:
		# The captive is held in the deepest room, behind the boss.
		tiles[layout["captive_cell"]] = DungeonGenerator.FLOOR
		_captive_cell = deep_door
		tiles[_captive_cell] = DungeonGenerator.CAPTIVE_MARKER
		if ActOne.is_cleared(dungeon_id):
			tiles[_captive_cell] = DungeonGenerator.FLOOR
	if _boss_defeated() and tiles.get(boss_cell, "") == DungeonGenerator.BOSS_TRIGGER:
		tiles[boss_cell] = DungeonGenerator.FLOOR

	for cell in tiles.keys():
		_tile_map.set_cell(cell, 0, TAG_TO_COORDS[tiles[cell]])
	_place_captive()

	if GameManager.has_pending_spawn:
		_player.snap_to(GameManager.pending_spawn_position)
		GameManager.has_pending_spawn = false
	else:
		_player.snap_to(_tile_map.map_to_local(spawn))


## The captive stands just behind their rune: Frank in the escape variant (until
## freed), the dungeon's captive in the rescue (until rescued).
func _place_captive() -> void:
	var who := ""
	if _escape and not GameManager.has_flag("met_frank"):
		who = "frank"
	elif not _escape and not ActOne.is_cleared(dungeon_id):
		who = String(ActOne.DUNGEONS[dungeon_id]["captive"]).to_lower()
	if who == "":
		return
	var npc := Cutscene.make_character(who)
	npc.position = _tile_map.map_to_local(_captive_cell + Vector2i(0, -1))
	npc.set_meta("actor_id", who)
	npc.add_to_group("npc")
	_tile_map.add_child(npc)


## Called by Player.gd on stepping onto the captive rune.
func on_captive_tile(_cell: Vector2i) -> void:
	if _escape:
		if not GameManager.has_flag("met_frank"):
			await Cutscene.play(_data["frank_scene"])
			_tile_map.set_cell(_captive_cell, 0, FLOOR_COORDS)
		return
	if ActOne.is_cleared(dungeon_id):
		return
	if not _boss_defeated():
		# Reaching the captive means facing their jailer first.
		_player.start_boss_battle()
		return
	await Cutscene.play(_data["rescue_scene"])
	_tile_map.set_cell(_captive_cell, 0, FLOOR_COORDS)


## Story beats when the map loads: waking up (escape, first time), and the
## escape itself once the warden is beaten.
func _play_arrival_story() -> void:
	if not _escape:
		return
	if not GameManager.has_flag(dungeon_id + "_woke"):
		GameManager.story_flags[dungeon_id + "_woke"] = true
		await _after_transition()
		await Cutscene.play(_data["wake_scene"])
	elif _boss_defeated() and not ActOne.is_cleared(dungeon_id):
		await _after_transition()
		await Cutscene.play(_data["escaped_scene"])
		GameManager.story_flags["cleared_" + dungeon_id] = true
		GameManager.arrival = dungeon_id
		Transition.change_scene(OVERWORLD_SCENE_PATH)


func _after_transition() -> void:
	if Transition.is_busy():
		await Transition.finished


func get_door_destination(cell: Vector2i) -> Dictionary:
	if cell != _exit_cell:
		return {}
	if _escape and not _boss_defeated():
		# The warden bars the only way out: walking up to the door starts it.
		return {"boss": true}
	GameManager.arrival = dungeon_id
	return {"scene": OVERWORLD_SCENE_PATH}
