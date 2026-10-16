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
const ACT_ONE_END_SCENE := "res://data/cutscenes/act_one_end.scene"

# Per-dungeon generation templates (13b) and story scenes (20a).
const DUNGEONS := {
	"cathedral": {
		"template": {"min_rooms": 5, "max_rooms": 8, "room_min_size": Vector2i(10, 7), "room_max_size": Vector2i(15, 10)},
		"scene": "res://scenes/dungeon/CathedralDungeon.tscn",
		"music": "dungeon",
		"wake_scene": "res://data/cutscenes/cathedral_wake.scene",
		"frank_scene": "res://data/cutscenes/cathedral_frank.scene",
		"escaped_scene": "res://data/cutscenes/cathedral_escaped.scene",
		"rescue_scene": "res://data/cutscenes/cathedral_rescue.scene",
	},
	"monastery": {
		"template": {"min_rooms": 5, "max_rooms": 8, "room_min_size": Vector2i(10, 7), "room_max_size": Vector2i(15, 10)},
		"scene": "res://scenes/dungeon/MonasteryDungeon.tscn",
		"music": "monastery",
		"wake_scene": "res://data/cutscenes/monastery_wake.scene",
		"frank_scene": "res://data/cutscenes/monastery_frank.scene",
		"escaped_scene": "res://data/cutscenes/monastery_escaped.scene",
		"rescue_scene": "res://data/cutscenes/monastery_rescue.scene",
	},
	"observatory": {
		"template": {"min_rooms": 5, "max_rooms": 8, "room_min_size": Vector2i(10, 7), "room_max_size": Vector2i(15, 10)},
		"scene": "res://scenes/dungeon/ObservatoryDungeon.tscn",
		"music": "observatory",
		"wake_scene": "res://data/cutscenes/observatory_wake.scene",
		"frank_scene": "res://data/cutscenes/observatory_frank.scene",
		"escaped_scene": "res://data/cutscenes/observatory_escaped.scene",
		"rescue_scene": "res://data/cutscenes/observatory_rescue.scene",
	},
	"guild": {
		"template": {"min_rooms": 5, "max_rooms": 8, "room_min_size": Vector2i(10, 7), "room_max_size": Vector2i(15, 10)},
		"scene": "res://scenes/dungeon/GuildDungeon.tscn",
		"music": "guild",
		"wake_scene": "res://data/cutscenes/guild_wake.scene",
		"frank_scene": "res://data/cutscenes/guild_frank.scene",
		"escaped_scene": "res://data/cutscenes/guild_escaped.scene",
		"rescue_scene": "res://data/cutscenes/guild_rescue.scene",
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
var _room_rects: Array = []  # Rect2i per room, for the auto-map


func _ready() -> void:
	_data = DUNGEONS[dungeon_id]
	_escape = ActOne.is_start_dungeon(dungeon_id)
	GameManager.current_location = dungeon_id + ("_escape" if _escape else "")
	GameManager.current_scene_path = _data["scene"]
	GameManager.story_flags.erase("edenmere_shrine_used")  # once per dungeon visit (20d)
	Music.play(_data.get("music", "dungeon"), "dungeon")  # each dungeon's own theme (Milestone 21)
	# Characters lower on screen draw in front (a captive standing just above
	# the player, cutscene actors walking past each other).
	_tile_map.y_sort_enabled = true
	_add_backdrop()
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
	_room_rects = layout["room_rects"]

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

	# A saved spot that isn't floor anymore (a save from before the rooms got
	# bigger lands somewhere else in the new layout) falls back to the entrance.
	var saved_cell: Vector2i = _tile_map.local_to_map(GameManager.pending_spawn_position)
	if GameManager.has_pending_spawn and tiles.get(saved_cell, "") == DungeonGenerator.FLOOR:
		_player.snap_to(GameManager.pending_spawn_position)
	else:
		_player.snap_to(_tile_map.map_to_local(spawn))
	GameManager.has_pending_spawn = false
	on_player_moved(_tile_map.local_to_map(_player.position))


## Darkness behind the map, so the space outside the walls reads as solid
## black rather than the engine's grey clear color.
func _add_backdrop() -> void:
	var layer := CanvasLayer.new()
	layer.layer = -1
	var dark := ColorRect.new()
	dark.color = Color(0.03, 0.02, 0.05)
	dark.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dark)
	add_child(layer)


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
	GameManager.autosave()  # a rescue (22a)
	# The fourth hero rescued: Act I ends here (20d). Afterwards the party is
	# back outside, free to roam until Act II exists.
	if ActOne.all_cleared() and not GameManager.has_flag("act_one_complete"):
		GameManager.story_flags["act_one_complete"] = true
		await Cutscene.play(ACT_ONE_END_SCENE)
		GameManager.arrival = dungeon_id
		GameManager.autosave_pending = true  # saved on arrival outside (22a)
		Transition.change_scene(OVERWORLD_SCENE_PATH)


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
		# Cleared before the scene, so {next} in it names the *next* dungeon.
		GameManager.story_flags["cleared_" + dungeon_id] = true
		await Cutscene.play(_data["escaped_scene"])
		GameManager.arrival = dungeon_id
		GameManager.autosave_pending = true  # saved on arrival outside (22a)
		Transition.change_scene(OVERWORLD_SCENE_PATH)


func _after_transition() -> void:
	if Transition.is_busy():
		await Transition.finished


# ---------------------------------------------------------------- auto-map

## Called by Player.gd on every tile: stepping into a room reveals all of it
## (walls included); in a corridor you see two tiles around you.
func on_player_moved(cell: Vector2i) -> void:
	var seen: Array = []
	for rect: Rect2i in _room_rects:
		if rect.has_point(cell):
			var walls := rect.grow(1)
			for x in range(walls.position.x, walls.end.x):
				for y in range(walls.position.y, walls.end.y):
					seen.append(Vector2i(x, y))
	for dx in range(-2, 3):
		for dy in range(-2, 3):
			seen.append(cell + Vector2i(dx, dy))
	GameManager.mark_explored(GameManager.current_location, seen)


## For MapScreen: only explored cells are drawn, plus the exit, captive and
## boss once you've seen them.
func map_fog() -> bool:
	return true


## A dungeon's size is a secret until explored: the map zooms to fit what
## you've seen rather than the whole layout.
func map_fit_explored() -> bool:
	return true


func map_markers() -> Array:
	var kinds := {
		DOOR_COORDS: {"color": Color(0.95, 0.78, 0.3), "legend": "Exit"},
		CAPTIVE_COORDS: {"color": Color(0.7, 0.45, 1.0), "legend": "Captive"},
		BOSS_COORDS: {"color": Color(0.95, 0.25, 0.25), "legend": "Boss"},
	}
	var markers: Array = []
	for cell in GameManager.explored.get(GameManager.current_location, {}):
		var coords := _tile_map.get_cell_atlas_coords(cell)
		if kinds.has(coords):
			var marker: Dictionary = kinds[coords].duplicate()
			marker["cell"] = cell
			markers.append(marker)
	return markers


func get_door_destination(cell: Vector2i) -> Dictionary:
	if cell != _exit_cell:
		return {}
	if _escape and not _boss_defeated():
		# The warden bars the only way out: walking up to the door starts it.
		return {"boss": true}
	GameManager.arrival = dungeon_id
	return {"scene": OVERWORLD_SCENE_PATH}
