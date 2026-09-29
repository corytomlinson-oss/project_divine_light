extends Node2D

# Verdance - Act I's starting village (Milestone 20a), in its first state from
# the design doc: "small, quiet, fearful - people sense something is wrong".
# Painted from the text map below. Face someone and press A to talk; the inn's
# door rents a bed; Frank's stall by the pond (once he's arrived) sells
# supplies and revives fallen allies.
#
#   .  grass     T  trees      X  gate out     =  road      *  flowers
#   #  wall      ^  roof       D  door         I  inn sign  ~  pond
#   f  fence     A  Frank's stall (awning)

const MAP := [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TT........................TT",
	"T.^^^^^...^^^^^^^...^^^^^..T",
	"T.^^^^^...^^^^^^^...^^^^^..T",
	"T.##D##...###D#I#...##D##..T",
	"T...=........=........=....T",
	"T*..=........=........=...*T",
	"T...=....*...=...*....=....T",
	"T...=..T.....=.....T..=....T",
	"T...====================...T",
	"T............=.............T",
	"T..^^^^^.~~..=....fff.ffff.T",
	"T..^^^^^~~~..=.AA.f******f.T",
	"T..##D##~~...=....f******f.T",
	"T....=.......=....f******f.T",
	"T.*..=======.=..*.ffffffff.T",
	"TT...........=............TT",
	"TTTTTTTTTTTTTXTTTTTTTTTTTTTT",
]
const TILES := {
	".": 0, "T": 1, "X": 2, "=": 3, "#": 4, "^": 5, "D": 6, "~": 7,
	"f": 8, "*": 9, "A": 10, "I": 11,
}
const BLOCKED_TILES: Array = [4, 5, 6, 7, 8, 10, 11]  # atlas columns you can't walk on
const HOUSE_DOOR := 6
const GATE_CELL := Vector2i(13, 17)
const ENTRY_CELL := Vector2i(13, 16)
const INN_DOOR := Vector2i(13, 4)
const STALL: Array = [Vector2i(15, 12), Vector2i(16, 12)]
const FRANK_SPOT := Vector2i(15, 13)
const INN_PRICE := 10
const REVIVE_PRICE := 50

# Frank's Act I stock (design doc: "fixed consumables and standard equipment").
const FRANK_STOCK: Array = [
	{"item": "Potion", "price": 20},
	{"item": "Antidote", "price": 15},
	{"item": "Ether", "price": 60},
	{"item": "Elixir", "price": 150},
	{"item": "Iron Sword", "price": 120},
	{"item": "Iron Claws", "price": 120},
	{"item": "Apprentice Staff", "price": 120},
	{"item": "Twin Daggers", "price": 120},
	{"item": "Leather Hood", "price": 80},
	{"item": "Traveler's Ring", "price": 150},
]

# Villagers. They borrow Ryn's and Lyra's walk sheets, tinted, until the Act I
# art pass (Milestone 21) gives Verdance its own people. (Not Vael's: Vael is
# the leader you see on the map when you start as Vael.)
const VILLAGERS: Array = [
	{"id": "elder", "sprite": "lyra", "tint": Color(0.72, 0.7, 0.78), "at": Vector2i(9, 10), "facing": "down"},
	{"id": "farmer", "sprite": "ryn", "tint": Color(0.86, 0.72, 0.52), "at": Vector2i(21, 10), "facing": "down"},
	{"id": "child", "sprite": "ryn", "tint": Color(1.0, 0.86, 0.86), "at": Vector2i(3, 7), "facing": "right"},
	{"id": "guard", "sprite": "ryn", "tint": Color(0.66, 0.72, 0.9), "at": Vector2i(12, 16), "facing": "up"},
	{"id": "innkeeper", "sprite": "lyra", "tint": Color(0.92, 0.78, 0.6), "at": Vector2i(12, 5), "facing": "down"},
]
# What they say (scene commands). "<id>_after" is used once the Cathedral is
# cleared, when there is one.
const TALK := {
	"elder": [
		"say Elder: The Cathedral bells stopped ringing a week ago. Then the lights up on the hill turned violet.",
		"say Elder: We keep our doors barred now, and our children close.",
	],
	"elder_after": [
		"say Elder: You came down from the Cathedral? Then there's still some hope left in this world.",
	],
	"farmer": [
		"say Farmer: My east field went grey overnight. Nothing grows in it now - not even the weeds.",
	],
	"child": [
		"say Child: Mama says not to go past the fence after dark. Something walks out there.",
	],
	"guard": [
		"say Guard: The north road climbs to the Cathedral. East, past the crossing, is the Monastery.",
		"say Guard: Folk say the monks still keep a light burning up there. But nobody who's gone up has come back down.",
	],
	"innkeeper": [
		"say Innkeeper: The inn's door is right behind me. A bed's ten gold a night - best rest you'll find in Verdance.",
	],
}

@onready var _tile_map: TileMapLayer = $TileMapLayer
@onready var _player: Node2D = $TileMapLayer/Player

var _npcs: Dictionary = {}  # cell -> actor id


func _ready() -> void:
	GameManager.current_location = "verdance"
	GameManager.current_scene_path = "res://scenes/town/Verdance.tscn"
	Music.play("overworld")
	_tile_map.y_sort_enabled = true
	_paint()
	for v: Dictionary in VILLAGERS:
		_add_npc(v["id"], v["sprite"], v["at"], v["facing"], v["tint"])
	if GameManager.has_flag("verdance_frank"):
		_add_npc("frank", "frank", FRANK_SPOT, "down")
	if GameManager.has_pending_spawn:
		_player.snap_to(GameManager.pending_spawn_position)
		GameManager.has_pending_spawn = false
	else:
		_player.snap_to(_tile_map.map_to_local(ENTRY_CELL))
	_arrival_story()


func _paint() -> void:
	_tile_map.clear()
	for y in MAP.size():
		var row: String = MAP[y]
		for x in row.length():
			_tile_map.set_cell(Vector2i(x, y), 0, Vector2i(TILES.get(row[x], 1), 0))


func _add_npc(id: String, sprite_name: String, cell: Vector2i, facing: String, tint := Color.WHITE) -> void:
	var npc := Cutscene.make_character(sprite_name)
	if tint != Color.WHITE:
		npc.self_modulate = tint
	npc.position = _tile_map.map_to_local(cell)
	npc.set_meta("actor_id", id)
	npc.add_to_group("npc")
	_tile_map.add_child(npc)
	var sheet := "side" if facing == "left" or facing == "right" else facing
	npc.flip_h = facing == "left"
	npc.play("idle_" + sheet)
	_npcs[cell] = id


## The first time the player reaches Verdance after escaping the Cathedral,
## Frank walks them in and sets up his stall.
func _arrival_story() -> void:
	if not ActOne.is_cleared("cathedral") or GameManager.has_flag("verdance_frank"):
		return
	if Transition.is_busy():
		await Transition.finished
	await Cutscene.play("res://data/cutscenes/verdance_arrival.scene")
	_add_npc("frank", "frank", FRANK_SPOT, "down")


func is_blocked(cell: Vector2i) -> bool:
	return _tile_map.get_cell_atlas_coords(cell).x in BLOCKED_TILES or _npcs.has(cell)


func get_door_destination(cell: Vector2i) -> Dictionary:
	if cell == GATE_CELL:
		GameManager.arrival = "verdance"
		return {"scene": "res://scenes/overworld/Overworld.tscn"}
	return {}


## Player.gd calls this when A is pressed facing `cell`.
func interact(cell: Vector2i, facing: String) -> void:
	if _npcs.has(cell):
		var id: String = _npcs[cell]
		if id == "frank":
			await _frank()
		else:
			await _talk(id, facing)
	elif cell == INN_DOOR:
		await _inn()
	elif cell in STALL:
		if GameManager.has_flag("verdance_frank"):
			await _frank()
		else:
			await Cutscene.play_text("narrate An empty market stall. The awning flaps in the wind.")
	elif _tile_map.get_cell_atlas_coords(cell).x == HOUSE_DOOR:
		await Cutscene.play_text("narrate The door is barred from inside. Nobody answers.")


func _talk(id: String, facing: String) -> void:
	var opposite := {"up": "down", "down": "up", "left": "right", "right": "left"}
	var lines: Array = TALK.get(id, [])
	if ActOne.is_cleared("cathedral") and TALK.has(id + "_after"):
		lines = TALK[id + "_after"]
	var script := "face %s %s\n%s" % [id, opposite[facing], "\n".join(lines)]
	await Cutscene.play_text(script)


func _inn() -> void:
	var pick := await Cutscene.ask("Rest for the night? A bed is %d gold. (You have %d.)" % [INN_PRICE, GameManager.gold], ["Stay", "Not now"], "Innkeeper")
	if pick != 0:
		return
	if GameManager.gold < INN_PRICE:
		await Cutscene.play_text("say Innkeeper: Ten gold, I'm afraid. Come back when you have it.")
		return
	GameManager.gold -= INN_PRICE
	await Transition.fade_out(0.6)
	Sfx.play("heal")
	# The design doc keeps revival to Frank and items, so the inn only restores
	# those still standing.
	for m: Combatant in GameManager.party:
		if not m.is_ko:
			m.hp = m.max_hp
			m.mp = m.max_mp
	await get_tree().create_timer(0.8).timeout
	await Transition.fade_in(0.6)
	await Cutscene.play_text("say Innkeeper: Morning already. Sleep well? You look like you needed it.")


func _frank() -> void:
	var fallen := GameManager.party.filter(func(m: Combatant) -> bool: return m.is_ko)
	var options: Array = ["Buy"]
	if not fallen.is_empty():
		options.append("Revive (%dg each)" % REVIVE_PRICE)
	options.append("Leave")
	var pick := await Cutscene.ask("What'll it be? Supplies, gear - I've a bit of everything. (You have %d gold.)" % GameManager.gold, options, "Frank")
	if options[pick] == "Buy":
		await ShopMenu.open(self, FRANK_STOCK)
	elif options[pick].begins_with("Revive"):
		var revived := 0
		for m: Combatant in fallen:
			if GameManager.gold < REVIVE_PRICE:
				break
			GameManager.gold -= REVIVE_PRICE
			m.is_ko = false
			m.hp = m.max_hp / 2
			revived += 1
		if revived == 0:
			await Cutscene.play_text("say Frank: That's %d gold a head, friend. Even miracles have a price." % REVIVE_PRICE)
		else:
			Sfx.play("level_up")
			await Cutscene.play_text("say Frank: There - back on your feet. Don't make a habit of it.")
