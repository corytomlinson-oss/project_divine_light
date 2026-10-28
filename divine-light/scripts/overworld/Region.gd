class_name Region
extends Node2D

# An overworld map (Milestone 25a; pulled out of Overworld.gd, which is now
# the Forest Heartlands' data on top of this). Act II adds a region map per
# kingdom (Cory, 2026-10-23), joined by border roads off the map edges.
#
# A region script extends this and overrides the data methods below:
# region_id(), map_rows(), entrances(), borders(), chest_loot(), music(),
# default_arrival(). Painted from the text map every time the scene loads
# (the scene file's own tile data is cleared first).
#
#   .  grass      T  trees (wall)    =  road       ~  water (blocked)
#   *  flowers    b  bridge          t  secret path: looks like trees, but
#                                       you can walk through (23c)
#   c  chest      s  healing spring  (on grass; contents in chest_loot())
#   x  blight     brambles of the Unraveling on grass: block the way until
#                 the region's kingdom is cleansed, then they're gone (25a)
#   ^ < > v       border roads off the map edge to another region (borders())
#   letters       town gates / dungeon arches (entrances())
#
# Corruption (25a): a region whose kingdom isn't cleansed draws grey and
# violet (shaders/corruption.gdshader on the tiles). The first time you're
# back after its boss falls, the color washes back in.
#
# Side quests (Milestone 24) put things on the land while a step needs them:
# a hunt target (walk up to it, or face it and press A, to fight) or
# something to pick up (Quests.HUNTS / FETCHES, by region).
#
# Leaving a town or dungeon sets GameManager.arrival, and the player appears
# just outside that entrance ("from:<region>" for a border road). Returning
# from a battle uses the saved spot.

const TILES := {".": Vector2i(0, 0), "T": Vector2i(1, 0), "=": Vector2i(3, 0), "~": Vector2i(5, 0),
		"*": Vector2i(6, 0), "b": Vector2i(7, 0), "t": Vector2i(1, 0), "c": Vector2i(0, 0), "s": Vector2i(0, 0),
		"x": Vector2i(0, 0), "^": Vector2i(3, 0), "<": Vector2i(3, 0), ">": Vector2i(3, 0), "v": Vector2i(3, 0)}
const GATE := Vector2i(2, 0)
const ARCH := Vector2i(4, 0)
const WATER := Vector2i(5, 0)
const BORDER_CHARS := "^<>v"
const TOWNS := {
	"verdance": {"name": "Verdance", "scene": "res://scenes/town/Verdance.tscn"},
	"edenmere": {"name": "Edenmere", "scene": "res://scenes/town/Edenmere.tscn"},
	"nordveil": {"name": "Nordveil", "scene": "res://scenes/town/Nordveil.tscn"},
	"duskara": {"name": "Duskara", "scene": "res://scenes/town/Duskara.tscn"},
	"selavon": {"name": "Selavon", "scene": "res://scenes/town/Selavon.tscn"},
	"threshold": {"name": "The Threshold", "scene": "res://scenes/town/Threshold.tscn"},
}
const CHEST_SHEET := preload("res://assets/sprites/chests.png")
const SPRING_SHEET := preload("res://assets/sprites/spring.png")
const BLIGHT_SHEET := preload("res://assets/sprites/blight.png")  # 2 frames, a slow pulse
const QUEST_PROPS := preload("res://assets/sprites/quest_props.png")  # silverleaf A/B, cart wreck
const CORRUPTION_SHADER := preload("res://assets/shaders/corruption.gdshader")
const SPRING_TEXT := "narrate Clear water wells up, glowing faintly. The party drinks and feels whole again."
const SPENT_TEXT := "narrate The spring lies still and dark. Its power is spent."
const BLIGHT_TEXT := "narrate Thorny violet brambles choke the way. They pulse faintly, like something breathing. Not while the Unraveling holds this land."

@onready var _tile_map: TileMapLayer = $TileMapLayer
@onready var _player: Node2D = $TileMapLayer/Player

var _entrances: Dictionary = {}  # cell -> entrance id
var _borders: Dictionary = {}    # cell -> region id the road leads to
var _secrets: Dictionary = {}    # cell -> true
var _chests: Dictionary = {}     # cell -> Sprite2D
var _springs: Dictionary = {}    # cell -> Sprite2D
var _blight: Dictionary = {}     # cell -> Sprite2D (only while corrupted)
var _spots: Dictionary = {}      # cell -> {kind, id, sprite}: quest hunts and pickups (24)
var _props: Dictionary = {}      # cell -> Sprite2D: quest scenery (the wrecked cart)
var _settled := false            # on_player_moved() ignores the arrival itself
var _corruption: ShaderMaterial


# ---------------------------------------------------------------- region data (override)

## The location id ("overworld" for the Forest Heartlands, "tundra", ...).
func region_id() -> String:
	return "overworld"


func map_rows() -> Array:
	return []


## Entrance letter -> town or dungeon id.
func entrances() -> Dictionary:
	return {}


## Border letter (^ < > v) -> the region id that road leads to.
func borders() -> Dictionary:
	return {}


## Chest cell -> reward (Loot.give format).
func chest_loot() -> Dictionary:
	return {}


func music() -> String:
	return "overworld"


## Where you appear with no arrival set (a fresh load, an old save): an
## entrance id or "from:<region>".
func default_arrival() -> String:
	return ""


# ---------------------------------------------------------------- setup

func _ready() -> void:
	GameManager.current_location = region_id()
	GameManager.current_scene_path = scene_file_path
	Music.play(music(), "overworld")
	_tile_map.y_sort_enabled = true  # characters lower on screen draw in front
	_paint()
	var rows := map_rows()
	# The camera stops at the map's edges instead of showing the void past them
	# (the scene places the TileMapLayer off the origin, hence the offset).
	var cam: Camera2D = _player.get_node("Camera2D")
	var origin := Vector2i(_tile_map.global_position)
	cam.limit_left = origin.x
	cam.limit_top = origin.y
	cam.limit_right = origin.x + String(rows[0]).length() * 16
	cam.limit_bottom = origin.y + rows.size() * 16
	# A saved spot that isn't open ground anymore (a save from before the map
	# changed) puts you at the default arrival instead.
	var saved_cell := _tile_map.local_to_map(GameManager.pending_spawn_position)
	if GameManager.has_pending_spawn and _walkable(saved_cell):
		_player.snap_to(GameManager.pending_spawn_position)
	else:
		var id := GameManager.arrival if GameManager.arrival != "" else default_arrival()
		_player.snap_to(_tile_map.map_to_local(_outside(id)))
	GameManager.has_pending_spawn = false
	GameManager.arrival = ""
	var wave := _setup_corruption()
	var hunt_lines := _settle_hunt()  # before the spots, so a beaten target is gone
	_add_quest_spots()
	on_player_moved(_tile_map.local_to_map(_player.position))
	_settled = true
	if wave:
		await _cleansing_wave()
	if not hunt_lines.is_empty():
		if Transition.is_busy():
			await Transition.finished
		await Cutscene.play_text("\n".join(hunt_lines))


func _paint() -> void:
	_tile_map.clear()
	var doors := entrances()
	var roads := borders()
	var rows := map_rows()
	var corrupted := _is_corrupted()
	for y in rows.size():
		var row: String = rows[y]
		for x in row.length():
			var ch := row[x]
			var cell := Vector2i(x, y)
			if doors.has(ch):
				var id: String = doors[ch]
				_entrances[cell] = id
				_tile_map.set_cell(cell, 0, GATE if TOWNS.has(id) else ARCH)
				continue
			_tile_map.set_cell(cell, 0, TILES.get(ch, TILES["T"]))
			if ch in BORDER_CHARS and roads.has(ch):
				_borders[cell] = roads[ch]
				continue
			match ch:
				"t":
					_secrets[cell] = true
				"c":
					_chests[cell] = _add_sprite(CHEST_SHEET, 6, cell)
				"s":
					_springs[cell] = _add_sprite(SPRING_SHEET, 3, cell)
				"x":
					if corrupted:
						_blight[cell] = _add_sprite(BLIGHT_SHEET, 2, cell)
	_show_treasure()
	var shimmer := Timer.new()
	shimmer.wait_time = 0.45
	shimmer.autostart = true
	shimmer.timeout.connect(_show_treasure)
	add_child(shimmer)


func _add_sprite(sheet: Texture2D, frames: int, cell: Vector2i) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = sheet
	sprite.hframes = frames
	sprite.position = _tile_map.map_to_local(cell)
	_tile_map.add_child(sprite)
	return sprite


func _opened(cell: Vector2i) -> bool:
	return GameManager.is_chest_opened(GameManager.current_location, cell)


func _show_treasure() -> void:
	for cell: Vector2i in _chests:
		_chests[cell].frame = 1 if _opened(cell) else 0
	var tick := int(Time.get_ticks_msec() / 450) % 2
	for cell: Vector2i in _springs:
		_springs[cell].frame = 2 if _opened(cell) else tick
	for cell: Vector2i in _spots:
		var sprite: Sprite2D = _spots[cell]["sprite"]
		sprite.frame = tick if _spots[cell]["kind"] == "fetch" else 1 - tick
	var slow := int(Time.get_ticks_msec() / 900) % 2
	for cell: Vector2i in _blight:
		if is_instance_valid(_blight[cell]):
			_blight[cell].frame = slow


## The walkable tile just outside an entrance or border road (south first,
## then the rest; for a border, the step back onto the map).
func _outside(id: String) -> Vector2i:
	var cells: Array = []
	if id.begins_with("from:"):
		var from := id.trim_prefix("from:")
		for cell: Vector2i in _borders:
			if _borders[cell] == from:
				cells.append(cell)
	else:
		for cell: Vector2i in _entrances:
			if _entrances[cell] == id:
				cells.append(cell)
	for cell: Vector2i in cells:
		for d: Vector2i in [Vector2i.DOWN, Vector2i.UP, Vector2i.RIGHT, Vector2i.LEFT]:
			if _walkable(cell + d):
				return cell + d
	# Nothing matched: the default arrival, or failing that the map's middle.
	if id != default_arrival() and default_arrival() != "":
		return _outside(default_arrival())
	var rows := map_rows()
	return Vector2i(String(rows[0]).length() / 2, rows.size() / 2)


func _walkable(cell: Vector2i) -> bool:
	var coords := _tile_map.get_cell_atlas_coords(cell)
	if coords == Vector2i(-1, -1) or _entrances.has(cell) or _borders.has(cell):
		return false
	return is_secret_path(cell) or (coords != TILES["T"] and not is_blocked(cell))


func is_door(cell: Vector2i) -> bool:
	return _entrances.has(cell) or _borders.has(cell)


func is_blocked(cell: Vector2i) -> bool:
	return _tile_map.get_cell_atlas_coords(cell) == WATER or _chests.has(cell) or _springs.has(cell) \
			or _spots.has(cell) or _props.has(cell) or _blight.has(cell)


## Trees you can walk through (Player.gd asks before treating trees as walls).
func is_secret_path(cell: Vector2i) -> bool:
	return _secrets.has(cell)


## A on the tile you're facing: open a chest, drink from the spring.
func interact(cell: Vector2i, _facing: String) -> void:
	if _spots.has(cell):
		await _use_spot(cell)
	elif _blight.has(cell):
		await Cutscene.play_text(BLIGHT_TEXT)
	elif _springs.has(cell):
		if _opened(cell):
			await Cutscene.play_text(SPENT_TEXT)
			return
		GameManager.mark_chest_opened(GameManager.current_location, cell)
		for m: Combatant in GameManager.party:
			if not m.is_ko:  # like an inn: no revival (Frank and items only)
				m.hp = m.max_hp
				m.mp = m.max_mp
		Sfx.play("heal")
		_show_treasure()
		await Cutscene.play_text(SPRING_TEXT)
	elif _chests.has(cell) and not _opened(cell):
		GameManager.mark_chest_opened(GameManager.current_location, cell)
		_show_treasure()
		Sfx.play("chest")
		await Cutscene.play_text("narrate " + Loot.give(chest_loot().get(cell, {"item": "Potion", "count": 1})))


func get_door_destination(cell: Vector2i) -> Dictionary:
	if _borders.has(cell):
		return _border_destination(_borders[cell])
	var id: String = _entrances.get(cell, "")
	if id == "":
		return {}
	if TOWNS.has(id):
		var town: Dictionary = TOWNS[id]
		if town["scene"] == "":
			return {"blocked": "The road to %s is still impassable. (Coming in a later update.)" % town["name"]}
		return {"scene": town["scene"]}
	if ActOne.DUNGEONS.has(id):
		return _act_one_dungeon(id)
	return _kingdom_dungeon(id)


## A border road: into a kingdom's region once its road is open (back toward
## the forest is always open).
func _border_destination(to_region: String) -> Dictionary:
	var info: Dictionary = Kingdoms.REGIONS.get(to_region, {})
	var kingdom: String = info.get("kingdom", "")
	if kingdom != "" and kingdom != Kingdoms.for_region(region_id()) and not Kingdoms.is_open(kingdom):
		return {"blocked": Kingdoms.road_text(kingdom)}
	if String(info.get("scene", "")) == "":
		return {"blocked": "The road runs on, but there's nothing beyond it yet. (Coming in a later update.)"}
	GameManager.arrival = "from:" + region_id()
	return {"scene": info["scene"]}


func _act_one_dungeon(id: String) -> Dictionary:
	var dungeon: Dictionary = ActOne.DUNGEONS[id]
	if not ActOne.can_enter(id):
		return {"blocked": dungeon["gate_text"]}
	if not Quests.is_unsealed(id):
		return {"blocked": Quests.SEAL_TEXT[id]}
	if dungeon["scene"] == "":
		return {"blocked": "%s lies ahead, but the way isn't open yet. (Coming in a later update.)" % dungeon["name"]}
	# The first time the quest key opens it, say so on the way in.
	if Quests.has_key(id) and not GameManager.has_flag("unsealed_" + id):
		GameManager.story_flags["unsealed_" + id] = true
		return {"scene": dungeon["scene"], "say": "narrate " + Quests.OPEN_TEXT[id]}
	return {"scene": dungeon["scene"]}


## An Act II dungeon (25a): enters on its first floor.
func _kingdom_dungeon(id: String) -> Dictionary:
	var scene: String = Kingdoms.DUNGEON_SCENES.get(id, "")
	if not Quests.is_unsealed(id):  # its required quest (26)
		return {"blocked": Quests.SEAL_TEXT[id]}
	if scene == "":
		return {"blocked": "%s looms ahead, but the way isn't open yet. (Coming in a later update.)" % Kingdoms.location_name(id)}
	GameManager.dungeon_floor = 0
	if Quests.has_key(id) and not GameManager.has_flag("unsealed_" + id):
		GameManager.story_flags["unsealed_" + id] = true
		return {"scene": scene, "say": "narrate " + Quests.OPEN_TEXT[id]}
	return {"scene": scene}


## The overworld is big (23c), so fights come a little less often here than
## in dungeons: walking between places shouldn't be a slog.
func encounter_steps() -> Vector2i:
	return Vector2i(14, 26)


# ---------------------------------------------------------------- corruption (25a)

func _is_corrupted() -> bool:
	var kingdom := Kingdoms.for_region(region_id())
	return kingdom != "" and (not Kingdoms.is_cleansed(kingdom) or GameManager.has_flag("cleanse_wave_" + kingdom))


## Grey and violet over the tiles while the kingdom is in the Unraveling's
## grip. Returns true if the cleansing wave should play now.
func _setup_corruption() -> bool:
	if not _is_corrupted():
		return false
	_corruption = ShaderMaterial.new()
	_corruption.shader = CORRUPTION_SHADER
	_corruption.set_shader_parameter("amount", 1.0)
	_tile_map.material = _corruption
	return GameManager.has_flag("cleanse_wave_" + Kingdoms.for_region(region_id()))


## The kingdom's boss has fallen: color washes back across the land, the
## brambles wither, and a line marks the moment. Plays once.
func _cleansing_wave() -> void:
	var kingdom := Kingdoms.for_region(region_id())
	GameManager.story_flags.erase("cleanse_wave_" + kingdom)
	Cutscene.hold()
	if Transition.is_busy():
		await Transition.finished
	await get_tree().create_timer(0.4).timeout
	Sfx.play("holy")
	var t := create_tween()
	t.tween_property(_corruption, "shader_parameter/amount", 0.0, 2.4).set_ease(Tween.EASE_IN_OUT)
	for cell: Vector2i in _blight:
		var sprite: Sprite2D = _blight[cell]
		var fade := create_tween()
		fade.tween_interval(randf_range(0.2, 1.6))
		fade.tween_property(sprite, "modulate", Color(2, 2, 2, 0), 0.6)
		fade.tween_callback(sprite.queue_free)
	_blight.clear()
	await t.finished
	_tile_map.material = null
	Cutscene.release()
	await Cutscene.play_text("narrate " + Kingdoms.KINGDOMS[kingdom]["cleansed_text"])
	# The kingdom celebrates (25b): on to its town, which plays the victory
	# scene and the movie card (Town._play_victory).
	var town: String = Kingdoms.KINGDOMS[kingdom]["town"]
	if String(TOWNS.get(town, {}).get("scene", "")) != "":
		GameManager.story_flags["victory_pending_" + kingdom] = true
		Transition.change_scene(TOWNS[town]["scene"])


# ---------------------------------------------------------------- map

## Fog of war (Player.gd calls this every tile): you've seen what's been on
## screen around you - 10 tiles either side, 6 up and down.
func on_player_moved(cell: Vector2i) -> void:
	var seen: Array = []
	for dx in range(-10, 11):
		for dy in range(-6, 7):
			seen.append(cell + Vector2i(dx, dy))
	GameManager.mark_explored(GameManager.current_location, seen)
	# Walking up beside a hunt target starts the fight (not on arrival, so
	# fleeing back to the map doesn't throw you straight back in).
	if _settled:
		for d: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			if _spots.has(cell + d) and _spots[cell + d]["kind"] == "hunt":
				_use_spot(cell + d)
				return


func map_fog() -> bool:
	return true


## The map screen drains its colors too while the land is corrupted.
func map_corrupted() -> bool:
	return _tile_map.material != null


## Every town (gold) and dungeon (red, grey once cleared) you've seen, with
## its name; border roads (with where they go); unopened chests and springs
## once seen; quest goals always.
func map_markers() -> Array:
	var markers: Array = []
	for cell in _entrances:
		if not GameManager.is_explored(GameManager.current_location, cell):
			continue
		var id: String = _entrances[cell]
		var color := Color(0.95, 0.78, 0.3)
		if ActOne.DUNGEONS.has(id):
			color = Color(0.6, 0.6, 0.66) if ActOne.is_cleared(id) else Color(0.95, 0.25, 0.25)
		elif Kingdoms.DUNGEON_NAMES.has(id):
			color = Color(0.6, 0.6, 0.66) if Kingdoms.is_cleansed(Kingdoms.for_dungeon(id)) else Color(0.95, 0.25, 0.25)
		markers.append({"cell": cell, "color": color, "label": GameManager.location_name(id)})
	var labelled := {}
	for cell: Vector2i in _borders:
		if not GameManager.is_explored(GameManager.current_location, cell):
			continue
		var to: String = _borders[cell]
		var marker := {"cell": cell, "color": Color(0.85, 0.85, 0.9)}
		if not labelled.has(to):
			marker["label"] = Kingdoms.location_name(to)
			labelled[to] = true
		markers.append(marker)
	for cell: Vector2i in _chests:
		if GameManager.is_explored(GameManager.current_location, cell) and not _opened(cell):
			markers.append({"cell": cell, "color": Color(0.8, 0.55, 0.3), "legend": "Chest"})
	for cell: Vector2i in _springs:
		if GameManager.is_explored(GameManager.current_location, cell) and not _opened(cell):
			markers.append({"cell": cell, "color": Color(0.45, 0.95, 0.55), "legend": "Spring"})
	# Quest goals (24), seen or not: where to hunt or gather, and any town
	# with someone to talk to (drawn over that town's own dot).
	for cell: Vector2i in _spots:
		markers.append({"cell": cell, "color": Quests.QUEST_COLOR, "legend": "Quest"})
	for cell: Vector2i in _entrances:
		if TOWNS.has(_entrances[cell]) and Quests.town_has_business(_entrances[cell]):
			markers.append({"cell": cell, "color": Quests.QUEST_COLOR, "legend": "Quest"})
	return markers


# ---------------------------------------------------------------- quests (24)

## Back from a quest hunt: if it was won, that step is done. Returns the lines
## to play once the screen is back (what happened, then any reward).
func _settle_hunt() -> Array:
	var hunt := GameManager.pending_hunt
	GameManager.pending_hunt = ""
	if hunt == "" or not GameManager.last_battle_won:
		return []
	var lines: Array = [Quests.HUNTS[hunt]["won"]]
	lines.append_array(Quests.complete_spot("hunt", hunt))
	return lines


func _add_quest_spots() -> void:
	for spot: Dictionary in Quests.active_spots(region_id()):
		var cell: Vector2i = spot["cell"]
		var sprite := Sprite2D.new()
		if spot["kind"] == "hunt":
			var enemy_name: String = Quests.HUNTS[spot["id"]]["enemy"]["name"]
			sprite.texture = load("res://assets/sprites/enemies/%s.png" % enemy_name.to_lower().replace(" ", "_"))
			sprite.hframes = 2
			sprite.offset.y = 8 - sprite.texture.get_height() / 2.0  # feet on the tile's bottom edge
			sprite.flip_h = true  # battle sprites face right; face the road
		else:
			sprite.texture = QUEST_PROPS
			sprite.hframes = 3
		sprite.position = _tile_map.map_to_local(cell)
		_tile_map.add_child(sprite)
		_spots[cell] = {"kind": spot["kind"], "id": spot["id"], "sprite": sprite}
	# Scenery that belongs to a hunt (the smith's wrecked cart) shows while
	# that fight is still to come; once it's won the crate is taken and the
	# wreck cleared (2026-10-28, Cory: it stayed, so the quest looked unfinished).
	for hunt: String in Quests.HUNTS:
		var h: Dictionary = Quests.HUNTS[hunt]
		if h.has("prop") and h.get("region", "overworld") == region_id() and Quests.hunt_pending(hunt):
			var wreck := Sprite2D.new()
			wreck.texture = QUEST_PROPS
			wreck.hframes = 3
			wreck.frame = 2
			wreck.position = _tile_map.map_to_local(h["prop"])
			_tile_map.add_child(wreck)
			_props[h["prop"]] = wreck
	_show_treasure()


## A hunt target: its line, then the fight. Something to pick up: take it.
func _use_spot(cell: Vector2i) -> void:
	var spot: Dictionary = _spots[cell]
	if spot["kind"] == "hunt":
		var hunt: Dictionary = Quests.HUNTS[spot["id"]]
		Sfx.play("menu_cancel")
		await Cutscene.play_text(hunt["tell"])
		GameManager.pending_hunt = spot["id"]
		_player.start_battle_against([Quests.hunt_enemy(spot["id"])])
		return
	_spots.erase(cell)
	spot["sprite"].queue_free()
	Sfx.play("chest")
	var lines: Array = [Quests.FETCHES[spot["id"]]["text"]]
	lines.append_array(Quests.complete_spot("fetch", spot["id"]))
	await Cutscene.play_text("\n".join(lines))
