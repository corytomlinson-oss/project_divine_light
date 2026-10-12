extends Town

# Edenmere - Act I's second town (Milestone 20d), the design doc's "mid-Act I
# waypoint between dungeons" in the south-east of the Forest Heartlands.
# Bigger and busier than Verdance, built around a cobbled square, with the
# town layout the design doc gives every town: an inn, an item shop, an
# armory (Act I's second tier of gear), and a shrine that restores the party
# for free once per dungeon visit. Frank wanders the square once he's set up
# shop in Verdance. Tile letters are in Town.gd.

const MAP := [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"T..^^^^^...^^^^^^^...^^^^^.T",
	"T..^^^^^...^^^^^^^...^^^^^.T",
	"T..#PD##...###D#I#...##DW#.T",
	"T....=........=........=...T",
	"T*...=........=........=..*T",
	"T....ccccccccccccccccccc...T",
	"T....ccccccccccccccccccc...T",
	"T....cccccccccSccccccccc...T",
	"T....ccccccccccccccccccc...T",
	"T....ccccccccccccccccccc...T",
	"T.............=............T",
	"T..^^^^^......=....^^^^^...T",
	"T..^^^^^......=....^^^^^...T",
	"T..##D##......=....##D##.*.T",
	"T.*...........=..........*.T",
	"TT............=...........TT",
	"TTTTTTTTTTTTTTXTTTTTTTTTTTTT",
]
const GATE_CELL := Vector2i(14, 17)
const ENTRY_CELL := Vector2i(14, 16)
const SHOP_DOOR := Vector2i(5, 3)
const INN_DOOR := Vector2i(14, 3)
const ARMORY_DOOR := Vector2i(23, 3)
const SHRINE := Vector2i(14, 8)
const FRANK_SPOT := Vector2i(9, 10)
const INN_PRICE := 15
# Cleared whenever a dungeon loads (Dungeon.gd), so the shrine works once per
# dungeon visit, as the design doc has it.
const SHRINE_FLAG := "edenmere_shrine_used"

const ITEM_STOCK: Array = [
	{"item": "Potion", "price": 20},
	{"item": "Antidote", "price": 15},
	{"item": "Ether", "price": 60},
	{"item": "Elixir", "price": 150},
]
# Act I's second tier: a step up from Frank's iron gear (Equipment.DEFS).
const ARMORY_STOCK: Array = [
	{"item": "Steel Sword", "price": 320},
	{"item": "Steel Claws", "price": 320},
	{"item": "Oak Staff", "price": 320},
	{"item": "Steel Daggers", "price": 320},
	{"item": "Monk Wraps", "price": 150},
	{"item": "Scholar's Robe", "price": 150},
	{"item": "Amber Charm", "price": 200},
]

# Townsfolk borrow the heroes' walk sheets, tinted, until Milestone 21.
const PEOPLE: Array = [
	{"id": "shopkeeper", "sprite": "lyra", "tint": Color(0.95, 0.8, 0.7), "at": Vector2i(4, 4), "facing": "down"},
	{"id": "innkeeper", "sprite": "ryn", "tint": Color(0.9, 0.78, 0.6), "at": Vector2i(13, 4), "facing": "down"},
	{"id": "smith", "sprite": "ryn", "tint": Color(0.7, 0.62, 0.58), "at": Vector2i(24, 4), "facing": "down"},
	{"id": "priestess", "sprite": "lyra", "tint": Color(1.0, 0.96, 0.85), "at": Vector2i(15, 8), "facing": "left"},
	{"id": "mayor", "sprite": "silas", "tint": Color(0.85, 0.8, 0.9), "at": Vector2i(19, 7), "facing": "down"},
	{"id": "traveler", "sprite": "silas", "tint": Color(0.75, 0.9, 0.75), "at": Vector2i(7, 9), "facing": "right"},
	{"id": "child", "sprite": "lyra", "tint": Color(1.0, 0.85, 0.9), "at": Vector2i(25, 15), "facing": "left"},
	{"id": "guard", "sprite": "ryn", "tint": Color(0.66, 0.72, 0.9), "at": Vector2i(13, 16), "facing": "up"},
]
# What they say (scene commands). "<id>_late" is used once two or more of Act
# I's dungeons are cleared, when there is one.
const TALK := {
	"shopkeeper": ["say Shopkeeper: Potions, antidotes, the good stuff. My door's right beside me."],
	"innkeeper": ["say Innkeeper: Fifteen gold a bed. Edenmere prices - the roads bring trade, and trade brings coin."],
	"smith": [
		"say Smith: Steel, finally. The last ore cart made it through before the roads went bad.",
		"say Smith: The armory door's next to me. I'll fit anything to anyone - if you've the coin.",
	],
	"priestess": [
		"say Priestess: The shrine's light hasn't dimmed, even now. Rest in it once each time you return from the dark places.",
	],
	"mayor": [
		"say Mayor: Edenmere still stands because the four roads still meet here. Merchants, pilgrims, runaways... we take them all.",
		"say Mayor: But the carts come fewer every week, and the ones that do come back talk about violet lights in the old places.",
	],
	"mayor_late": [
		"say Mayor: Word travels fast here. They say someone's been breaking open the old places and bringing people back out.",
		"say Mayor: Whoever you are - Edenmere's doors are open to you.",
	],
	"traveler": [
		"say Traveler: I came up from the ravine road. The Guild's tunnels used to be full of thieves. Now they're full of something worse.",
		"say Traveler: And the Observatory out east - the dome glows at night, but no one's charted a star there in months.",
	],
	"traveler_late": [
		"say Traveler: I hear the Monastery's gong has gone quiet. Can't tell if that's good news or bad.",
	],
	"child": ["say Child: Mama says the shrine light keeps the bad things away. I touch it every morning. Just in case."],
	"guard": [
		"say Guard: Welcome to Edenmere. The road north leads back to the crossing - the Monastery and the Observatory lie that way.",
		"say Guard: West past the ravine is the Guild. Keep your purse close if you go.",
	],
}

var _dungeons_cleared := 0


func _ready() -> void:
	GameManager.current_location = "edenmere"
	GameManager.current_scene_path = "res://scenes/town/Edenmere.tscn"
	Music.play("overworld")
	_tile_map.y_sort_enabled = true
	_paint(MAP)
	for p: Dictionary in PEOPLE:
		_add_npc(p["id"], p["sprite"], p["at"], p["facing"], p["tint"])
	if GameManager.has_flag("verdance_frank"):
		_add_npc("frank", "frank", FRANK_SPOT, "down")
	for id: String in ActOne.DUNGEONS:
		if ActOne.is_cleared(id):
			_dungeons_cleared += 1
	_place_player(ENTRY_CELL)


func get_door_destination(cell: Vector2i) -> Dictionary:
	if cell == GATE_CELL:
		GameManager.arrival = "edenmere"
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
	elif cell == SHOP_DOOR:
		await Cutscene.play_text("say Shopkeeper: Come in, come in! Take what you need.")
		await ShopMenu.open(self, ITEM_STOCK)
	elif cell == ARMORY_DOOR:
		await Cutscene.play_text("say Smith: Have a look. Good steel, fairly priced.")
		await ShopMenu.open(self, ARMORY_STOCK)
	elif cell == SHRINE:
		await _shrine()
	elif _tile_map.get_cell_atlas_coords(cell).x == HOUSE_DOOR:
		await Cutscene.play_text("narrate Voices murmur inside, then fall quiet. Nobody comes to the door.")


func _talk(id: String, facing: String) -> void:
	var lines: Array = TALK.get(id, [])
	if _dungeons_cleared >= 2 and TALK.has(id + "_late"):
		lines = TALK[id + "_late"]
	await _talk_lines(id, facing, lines)


## Free HP/MP for everyone standing, once per dungeon visit (design doc).
func _shrine() -> void:
	if GameManager.has_flag(SHRINE_FLAG):
		await Cutscene.play_text("narrate The shrine's light is steady and warm, but it has given what it can for now. Return after your next journey.")
		return
	GameManager.story_flags[SHRINE_FLAG] = true
	Sfx.play("heal")
	_restore_party()
	await Cutscene.play_text("narrate A gentle light washes over the party. Wounds close; weariness fades.")
