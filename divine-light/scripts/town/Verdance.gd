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
# Envoys from the freed kingdoms (29; README "Verdance - Unique Progression":
# after Act II it's the hub, with representatives from the liberated
# kingdoms). Each arrives once their kingdom is free; Selavon's is the
# archivist, who sends you after the merchant of every age.
const ENVOYS: Array = [
	{"id": "nordveil_envoy", "sprite": "guard_b", "at": Vector2i(6, 10), "facing": "right", "kingdom": "nordveil"},
	{"id": "duskara_envoy", "sprite": "traveler", "at": Vector2i(25, 10), "facing": "left", "kingdom": "duskara"},
	{"id": "archivist", "sprite": "mayor", "at": Vector2i(20, 16), "facing": "left", "kingdom": "selavon"},
]
# What they say (scene commands). "<id>_after" is used once the Cathedral is
# cleared, when there is one; "<id>_hub" once Act II is over (29), and
# "<id>_end" after the ending.
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
	# The hub (29)
	"elder_hub": ["say Elder: Envoys from three kingdoms, in Verdance! I never thought I'd see the day. They all ask where you grew up."],
	"farmer_hub": ["say Farmer: The east field's green again, and I've buyers from Duskara for every bushel. Strange times. Good times."],
	"child_hub": ["say Child: The man from Nordveil showed me how to throw a snowball. With mud. It still counts!"],
	"guard_hub": ["say Guard: South of the Guild, the road runs into the Reach now. Everyone says that's where it ends. Come back to us, all right?"],
	"innkeeper_hub": ["say Innkeeper: Every bed's full of travelers from the kingdoms. Yours is always kept free, though."],
	"nordveil_envoy_hub": ["say Nordveil Envoy: The captain sent me to keep the road to the north open. Nordveil hasn't forgotten who broke the Sovereign."],
	"duskara_envoy_hub": ["say Duskara Envoy: Water from the Sanctum spring - the first barrels, for the village that raised Valdris's heroes. Drink, it's sweet."],
	"archivist_hub": ["say Archivist: The flood took half of Selavon's archive. I'm rebuilding it here, where it's safe. And where the stories are being made."],
	"elder_end": ["say Elder: The light's back in the sky, and the whole world knows Verdance's name. Thank you. All of you."],
	"farmer_end": ["say Farmer: Look at it! Not a grey leaf from here to the hills."],
	"child_end": ["say Child: When I grow up I'm going to be a hero too. Or a merchant with a really big hat."],
	"guard_end": ["say Guard: Nothing to guard against anymore. I'm keeping the spear, though. For the stories."],
	"innkeeper_end": ["say Innkeeper: Stay as long as you like. It's on the house - forever, I think."],
	"nordveil_envoy_end": ["say Nordveil Envoy: Spring came to the tundra this year. Real spring. The old ones are weeping in the streets."],
	"duskara_envoy_end": ["say Duskara Envoy: Duskara is building a statue of the four of you. The sculptor wants to know which one of you is the handsome one."],
	"archivist_end": ["say Archivist: I'm writing the last chapter of this age's chronicle. I've left a page for the merchant. I think he'd want one."],
}

func _ready() -> void:
	GameManager.current_location = "verdance"
	GameManager.current_scene_path = "res://scenes/town/Verdance.tscn"
	Music.play("town", "overworld")
	_tile_map.y_sort_enabled = true
	_paint(MAP)
	for v: Dictionary in VILLAGERS:
		_add_npc(v["id"], v["sprite"], v["at"], v["facing"])
	for e: Dictionary in ENVOYS:
		if Kingdoms.is_cleansed(e["kingdom"]):
			_add_npc(e["id"], e["sprite"], e["at"], e["facing"])
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
		if GameManager.has_flag("act_two_complete"):
			await Cutscene.play_text("narrate A family from the kingdoms has moved in. They wave through the window and hold up a loaf of fresh bread.")
		else:
			await Cutscene.play_text("narrate The door is barred from inside. Nobody answers.")


func _talk(id: String, facing: String) -> void:
	if await _quest_talk(id, facing):
		return
	var lines: Array = TALK.get(id, [])
	if GameManager.has_flag("verdance_frank") and TALK.has(id + "_after"):
		lines = TALK[id + "_after"]
	if GameManager.has_flag("game_complete") and TALK.has(id + "_end"):
		lines = TALK[id + "_end"]
	elif GameManager.has_flag("act_two_complete") and TALK.has(id + "_hub"):
		lines = TALK[id + "_hub"]
	await _talk_lines(id, facing, lines)
