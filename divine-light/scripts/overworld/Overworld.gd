extends Node2D

# The Forest Heartlands - Act I's overworld (Milestone 20a; made about three
# times bigger in 23c), painted from the text map below every time the scene
# loads (the scene file's own tile data is cleared first). Edit MAP to change
# the land.
#
#   .  grass      T  trees (wall)    =  road       ~  water (blocked)
#   *  flowers    b  bridge          t  secret path: looks like trees, but
#                                       you can walk through (23c)
#   c  chest      s  healing spring  (on grass; contents in CHEST_LOOT)
#   V  Verdance        E  Edenmere   (town gates)
#   C  The Cathedral   M  The Monastery   O  The Observatory
#   G  The Underground Guild                        (dungeon arches)
#
# Three hidden clearings sit in the forest, each holding a chest with an
# accessory you can't get anywhere else (one has a spring too). They show on
# screen through the trees; the way in starts by a patch of flowers.
#
# Side quests (Milestone 24) put things on the land while a step needs them:
# a hunt target (walk up to it, or face it and press A, to fight) or
# something to pick up (Quests.HUNTS / FETCHES). Dungeon doors also check the
# quest seal (Quests.is_unsealed) after the party-member gate.
#
# Leaving a town or dungeon sets GameManager.arrival, and the player appears
# just outside that entrance. Returning from a battle uses the saved spot.

const MAP := [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT~~TTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT.~~.TTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTT....TTTTTTTTTTTTTTTTTT.~~.TTTTTTTTTTTT....*.TTTTTTTTTT",
	"TTTTTTTTTT.........TTTTTTTTTTTTT.~~.TTTTTTTTTTT........TTTTTTTTT",
	"TTTTTTTTTT...........TTTTTTTTTTT.~~.TTTTTTTTT..........TTTTTTTTT",
	"TTTTTTTTT............*.TTTTTTTTT.~~.TTT...TTT............TTTTTTT",
	"TTTTTTTT......C.........TTTTTTTT.~~TTT...c.TTT....M........TTTTT",
	"TTTTTTT.......=.*.......TTTTTTTT.~~TTT......TT....=.........TTTT",
	"TTTTTTTT......=.........TTTTTTTT.~~TTT.....TTT....=.........TTTT",
	"TTTTTTTTT.....=.T.....TTTTTTTTTT*~~.TTT...TTT.....=........TTTTT",
	"TTTTTTTTTTT...=TTTTTTTTTTTTTTTTT.~~.TTTTtTTTTTTTTT=TTT...TTTTTTT",
	"TTTT..TTTTTTTT=TTT..TTTTTTTTTTTTT.~~.TTTtTTTTTTTTT=TTTTTTTTTTTTT",
	"TT..c..TTTTTTT===........TTTTTTTT.~~.TTTtTTTTTTTTT=TTTTTTTTTTTTT",
	"TT.....TTTTTTTTT=......c...TTTTTT.~~.TTTtTTT=======TTTTTTTTTTTTT",
	"TT...s.TTTTTTTTT=T..*.......TTTTT.~~.TTTtttt=TTTTTTTTTTTTTTTTTTT",
	"TTTT..TTTTTTTTTT=T.........TTTTTT.~~.TTTTTTT=.TTTTTTTTTTTTTTTTTT",
	"TTTTTtTTTTTTTTTT=T.....TTTTTTTTTT.~~.TTTTTT.=.*TTTTTTT....TTTTTT",
	"TTTTTtttTTTTTTTT=TT.......TTTTTTT.~~.TTTTT..=..TTTTTT.........TT",
	"TTTTTTTtTTTTTT..=.......*.TTTTTTT.~~.TTT....=..TTTTT...........T",
	"TTTTTTTtTTTT....=..........TTTTTT.~~.TTT....=....TT............T",
	"TTTTTTTt*.......=..........TTTTTT.~~.TT.....=....*.............T",
	"TTTTTT***.......=...*.....TTTTTTT.~~.TT.....=...c.............TT",
	"TTTT..***.......=.........TTTTTTTT.~~.T.....=...........==O...TT",
	"TTTT............=.........TTTTTTT.~~.T*.....=...........=..*.TTT",
	"TTTT.*..........V=================bb=====================....TTT",
	"TTTT.........*..=.*...*...TTTTTTT.~~.TT....TT.................TT",
	"TTTT...c........=...*.....TTTTTTT.~~.TTTTTTTTTTT...........*..TT",
	"TTTTTT..........=.........TTTTTTT.~~.TTTTTTTTTTTTT.....*.....c.T",
	"TTTTTTTTT.......=.........TTTTTTT.~~.TTTTTTTTTTTTTT............T",
	"TTTTTTTTTTTTT...=..*......TTTTTTT.~~*TTTTTTTTTTTTTTTT.........TT",
	"TTTTT....TTTT...==================bb======TTTTTTT..TTTTTTT..*TTT",
	"TTTT......T..*.T.*.....TTTT=TTTTT.~~....T=TTTTTT....TTTTTTTTTTTT",
	"TTT.............TTTTTTTTTTT=TTTTTT.~~....=TTTTTT.....TTTTTTTTTTT",
	"TT....~~~~.......TTTTTTTTTT=TTTTTT.~~....=.TTTT...........TTTTTT",
	"TT...~~~~~~~~....TTTTTT..*.=TTTTTT.~~....=.TTT.............TTTTT",
	"TT...~~~~~~~~..*TTTTTT....*=....TT.~~....==========E.......TTTTT",
	"TTT..~~~~~~~....TTTTTT.....=.......~~.TTTTTT.............*..TTTT",
	"TTTT..~~~~~....TTTTTTT....*=........~~.TTTTT................TTTT",
	"TTTTc.........TTTT.TTTT....G........~~.TTTTT..c.............TTTT",
	"TTTT*.......TTTT.c...TTT**.....c....~~.TTTTTT....*..........TTTT",
	"TTTT....TTTTTTTT...*.ttt**..........~~.TTTTTTT......TT.....TTTTT",
	"TTTTT.TTTTTTTTTT.....TTT**...TTTTTT.~~.TTTTTTTT..*.TTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTT...TTTTTTT.~~.TTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT~~TTTTTTTTTTTTTTTTTTTTTTTTTT",
]
const TILES := {".": Vector2i(0, 0), "T": Vector2i(1, 0), "=": Vector2i(3, 0), "~": Vector2i(5, 0),
		"*": Vector2i(6, 0), "b": Vector2i(7, 0), "t": Vector2i(1, 0), "c": Vector2i(0, 0), "s": Vector2i(0, 0)}
const GATE := Vector2i(2, 0)
const ARCH := Vector2i(4, 0)
const WATER := Vector2i(5, 0)
const ENTRANCES := {
	"V": "verdance", "E": "edenmere",
	"C": "cathedral", "M": "monastery", "O": "observatory", "G": "guild",
}
const TOWNS := {
	"verdance": {"name": "Verdance", "scene": "res://scenes/town/Verdance.tscn"},
	"edenmere": {"name": "Edenmere", "scene": "res://scenes/town/Edenmere.tscn"},
}
# What each chest holds (23c), hand-picked: supplies along the way, and an
# accessory found nowhere else in each hidden clearing.
const CHEST_LOOT := {
	Vector2i(7, 26): {"item": "Potion", "count": 3},
	Vector2i(23, 13): {"gold": 80},
	Vector2i(48, 21): {"item": "Ether", "count": 2},
	Vector2i(61, 27): {"item": "Antidote", "count": 3},
	Vector2i(46, 38): {"gold": 120},
	Vector2i(31, 39): {"item": "Elixir", "count": 1},
	Vector2i(4, 38): {"item": "Traveler's Ring", "count": 1},
	Vector2i(4, 12): {"item": "Heartwood Charm", "count": 1},    # clearing by the Cathedral
	Vector2i(41, 6): {"item": "Moonstone Pendant", "count": 1},  # clearing by the Monastery
	Vector2i(17, 39): {"item": "Fox-Eye Ring", "count": 1},      # clearing by the Guild
}
const CHEST_SHEET := preload("res://assets/sprites/chests.png")
const SPRING_SHEET := preload("res://assets/sprites/spring.png")
const SPRING_TEXT := "narrate Clear water wells up, glowing faintly. The party drinks and feels whole again."
const SPENT_TEXT := "narrate The spring lies still and dark. Its power is spent."
const QUEST_PROPS := preload("res://assets/sprites/quest_props.png")  # silverleaf A/B, cart wreck

@onready var _tile_map: TileMapLayer = $TileMapLayer
@onready var _player: Node2D = $TileMapLayer/Player

var _entrances: Dictionary = {}  # cell -> entrance id
var _secrets: Dictionary = {}    # cell -> true
var _chests: Dictionary = {}     # cell -> Sprite2D
var _springs: Dictionary = {}    # cell -> Sprite2D
var _spots: Dictionary = {}      # cell -> {kind, id, sprite}: quest hunts and pickups (24)
var _props: Dictionary = {}      # cell -> Sprite2D: quest scenery (the wrecked cart)
var _settled := false            # on_player_moved() ignores the arrival itself


func _ready() -> void:
	GameManager.current_location = "overworld"
	GameManager.current_scene_path = "res://scenes/overworld/Overworld.tscn"
	Music.play("overworld")
	_tile_map.y_sort_enabled = true  # characters lower on screen draw in front
	_paint()
	# The camera stops at the map's edges instead of showing the void past them
	# (the scene places the TileMapLayer off the origin, hence the offset).
	var cam: Camera2D = _player.get_node("Camera2D")
	var origin := Vector2i(_tile_map.global_position)
	cam.limit_left = origin.x
	cam.limit_top = origin.y
	cam.limit_right = origin.x + MAP[0].length() * 16
	cam.limit_bottom = origin.y + MAP.size() * 16
	# A saved spot that isn't open ground anymore (a save from before the map
	# grew) puts you outside Verdance instead.
	var saved_cell := _tile_map.local_to_map(GameManager.pending_spawn_position)
	if GameManager.has_pending_spawn and _walkable(saved_cell):
		_player.snap_to(GameManager.pending_spawn_position)
	else:
		var id := GameManager.arrival if GameManager.arrival != "" else "verdance"
		_player.snap_to(_tile_map.map_to_local(_outside(id)))
	GameManager.has_pending_spawn = false
	GameManager.arrival = ""
	var hunt_lines := _settle_hunt()  # before the spots, so a beaten target is gone
	_add_quest_spots()
	on_player_moved(_tile_map.local_to_map(_player.position))
	_settled = true
	if not hunt_lines.is_empty():
		if Transition.is_busy():
			await Transition.finished
		await Cutscene.play_text("\n".join(hunt_lines))


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
				continue
			_tile_map.set_cell(cell, 0, TILES.get(ch, TILES["T"]))
			match ch:
				"t":
					_secrets[cell] = true
				"c":
					_chests[cell] = _add_sprite(CHEST_SHEET, 6, cell)
				"s":
					_springs[cell] = _add_sprite(SPRING_SHEET, 3, cell)
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


## The walkable tile just outside an entrance (south first, then the rest).
func _outside(id: String) -> Vector2i:
	for cell: Vector2i in _entrances:
		if _entrances[cell] != id:
			continue
		for d: Vector2i in [Vector2i.DOWN, Vector2i.UP, Vector2i.RIGHT, Vector2i.LEFT]:
			if _walkable(cell + d):
				return cell + d
	return Vector2i(16, 25)


func _walkable(cell: Vector2i) -> bool:
	var coords := _tile_map.get_cell_atlas_coords(cell)
	if coords == Vector2i(-1, -1) or _entrances.has(cell):
		return false
	return is_secret_path(cell) or (coords != TILES["T"] and not is_blocked(cell))


func is_door(cell: Vector2i) -> bool:
	return _entrances.has(cell)


func is_blocked(cell: Vector2i) -> bool:
	return _tile_map.get_cell_atlas_coords(cell) == WATER or _chests.has(cell) or _springs.has(cell) \
			or _spots.has(cell) or _props.has(cell)


## Trees you can walk through (Player.gd asks before treating trees as walls).
func is_secret_path(cell: Vector2i) -> bool:
	return _secrets.has(cell)


## A on the tile you're facing: open a chest, drink from the spring.
func interact(cell: Vector2i, _facing: String) -> void:
	if _spots.has(cell):
		await _use_spot(cell)
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
		await Cutscene.play_text("narrate " + Loot.give(CHEST_LOOT.get(cell, {"item": "Potion", "count": 1})))


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
	if not Quests.is_unsealed(id):
		return {"blocked": Quests.SEAL_TEXT[id]}
	if dungeon["scene"] == "":
		return {"blocked": "%s lies ahead, but the way isn't open yet. (Coming in a later update.)" % dungeon["name"]}
	# The first time the quest key opens it, say so on the way in.
	if Quests.has_key(id) and not GameManager.has_flag("unsealed_" + id):
		GameManager.story_flags["unsealed_" + id] = true
		return {"scene": dungeon["scene"], "say": "narrate " + Quests.OPEN_TEXT[id]}
	return {"scene": dungeon["scene"]}


## The overworld is big now (23c), so fights come a little less often here
## than in dungeons: walking between places shouldn't be a slog.
func encounter_steps() -> Vector2i:
	return Vector2i(14, 26)


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


## Every town (gold) and dungeon (red, grey once cleared) you've seen, with
## its name; unopened chests and the spring once seen.
func map_markers() -> Array:
	var markers: Array = []
	for cell in _entrances:
		if not GameManager.is_explored(GameManager.current_location, cell):
			continue
		var id: String = _entrances[cell]
		var color := Color(0.95, 0.78, 0.3)
		if ActOne.DUNGEONS.has(id):
			color = Color(0.6, 0.6, 0.66) if ActOne.is_cleared(id) else Color(0.95, 0.25, 0.25)
		markers.append({"cell": cell, "color": color, "label": GameManager.location_name(id)})
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
	for spot: Dictionary in Quests.active_spots():
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
	# The smith's cart lies where it went off the road once you've heard of it.
	if Quests.is_started("lost_cart"):
		var wreck := Sprite2D.new()
		wreck.texture = QUEST_PROPS
		wreck.hframes = 3
		wreck.frame = 2
		var cell: Vector2i = Quests.HUNTS["wreck_ghoul"]["prop"]
		wreck.position = _tile_map.map_to_local(cell)
		_tile_map.add_child(wreck)
		_props[cell] = wreck
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
