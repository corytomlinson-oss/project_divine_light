extends Town

# Verdance - Act I's starting village (Milestone 20a), in its first state from
# the design doc: "small, quiet, fearful - people sense something is wrong".
# Painted from the text map below. Face someone and press A to talk; the inn's
# door rents a bed; Frank's stall by the pond (once he's arrived) sells
# supplies and revives fallen allies. Tile letters and the shared town
# behavior (inn, Frank, talking) are in Town.gd.

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
const GATE_CELL := Vector2i(13, 17)
const ENTRY_CELL := Vector2i(13, 16)
const INN_DOOR := Vector2i(13, 4)
const STALL: Array = [Vector2i(15, 12), Vector2i(16, 12)]
const FRANK_SPOT := Vector2i(15, 13)
const INN_PRICE := 10

# Villagers, with their own walk sheets since Milestone 21
# (assets/sprites/source/build_townsfolk.py).
const VILLAGERS: Array = [
	{"id": "elder", "sprite": "elder", "at": Vector2i(9, 10), "facing": "down"},
	{"id": "farmer", "sprite": "worker", "at": Vector2i(21, 10), "facing": "down"},
	{"id": "child", "sprite": "child", "at": Vector2i(3, 7), "facing": "right"},
	{"id": "guard", "sprite": "guard", "at": Vector2i(12, 16), "facing": "up"},
	{"id": "innkeeper", "sprite": "merchant", "at": Vector2i(12, 5), "facing": "down"},
]
# What they say (scene commands). "<id>_after" is used once the Cathedral is
# cleared, when there is one.
const TALK := {
	"elder": [
		"say Elder: The Cathedral bells stopped ringing a week ago. Then the lights up on the hill turned violet.",
		"say Elder: We keep our doors barred now, and our children close.",
	],
	"elder_after": [
		"say Elder: You got away from them? Then there's still some hope left in this world.",
	],
	"farmer": [
		"say Farmer: My east field went grey overnight. Nothing grows in it now - not even the weeds.",
	],
	"child": [
		"say Child: Mama says not to go past the fence after dark. Something walks out there.",
		"say Child: But I know a secret! Where flowers grow thick against the trees, you can squeeze right through to hidden places.",
	],
	"guard": [
		"say Guard: The north road climbs to the Cathedral. East, past the crossing, is the Monastery.",
		"say Guard: Folk say the monks still keep a light burning up there. But nobody who's gone up has come back down.",
	],
	"innkeeper": [
		"say Innkeeper: The inn's door is right behind me. A bed's ten gold a night - best rest you'll find in Verdance.",
	],
}

func _ready() -> void:
	GameManager.current_location = "verdance"
	GameManager.current_scene_path = "res://scenes/town/Verdance.tscn"
	Music.play("town", "overworld")
	_tile_map.y_sort_enabled = true
	_paint(MAP)
	for v: Dictionary in VILLAGERS:
		_add_npc(v["id"], v["sprite"], v["at"], v["facing"])
	if GameManager.has_flag("verdance_frank"):
		_add_npc("frank", "frank", FRANK_SPOT, "down")
	_place_player(ENTRY_CELL)
	_arrival_story()


## The first time the player reaches Verdance after escaping the Cathedral,
## Frank walks them in and sets up his stall.
func _arrival_story() -> void:
	var start := ActOne.start_dungeon(GameManager.starting_class) if GameManager.starting_class != "" else "cathedral"
	if not ActOne.is_cleared(start) or GameManager.has_flag("verdance_frank"):
		return
	if Transition.is_busy():
		await Transition.finished
	await Cutscene.play("res://data/cutscenes/verdance_arrival.scene")
	_add_npc("frank", "frank", FRANK_SPOT, "down")


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
		await _inn(INN_PRICE)
	elif cell in STALL:
		if GameManager.has_flag("verdance_frank"):
			await _frank()
		else:
			await Cutscene.play_text("narrate An empty market stall. The awning flaps in the wind.")
	elif _tile_map.get_cell_atlas_coords(cell).x == HOUSE_DOOR:
		await Cutscene.play_text("narrate The door is barred from inside. Nobody answers.")


func _talk(id: String, facing: String) -> void:
	if await _quest_talk(id, facing):
		return
	var lines: Array = TALK.get(id, [])
	if GameManager.has_flag("verdance_frank") and TALK.has(id + "_after"):
		lines = TALK[id + "_after"]
	await _talk_lines(id, facing, lines)
