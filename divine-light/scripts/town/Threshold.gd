extends Town

# The Threshold - the last safe haven before the Blighted Maw (Act III,
# Milestone 28a; README "Town Roster"): the inn is free, the shrine has
# unlimited uses, the shops carry the best stock in Valdris (Starforged), and
# Frank keeps his stall here. Refugees from all three freed kingdoms. The
# keeper of the Threshold gives the three portal-key quests; the last one
# goes through Frank. Never corrupted. Tiles: the town atlas.

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
const ARRIVAL_SCENE := "res://data/cutscenes/threshold_arrival.scene"

const ITEM_STOCK: Array = [
	{"item": "Potion", "price": 15},
	{"item": "Antidote", "price": 10},
	{"item": "Ether", "price": 50},
	{"item": "Elixir", "price": 120},
	{"item": "Hi-Potion", "price": 90},
	{"item": "Hi-Ether", "price": 240},
]
const ARMORY_STOCK: Array = [
	{"item": "Starforged Sword", "price": 2200},
	{"item": "Starforged Claws", "price": 2200},
	{"item": "Starforged Staff", "price": 2200},
	{"item": "Starforged Daggers", "price": 2200},
	{"item": "Starforged Plate", "price": 1700},
	{"item": "Starforged Gi", "price": 1600},
	{"item": "Starforged Robe", "price": 1600},
	{"item": "Starforged Leathers", "price": 1600},
	{"item": "Star Charm", "price": 1800},
	# The Act III set gloves (28b; the rest wait in the Maw)
	{"item": "Divine Champion Gauntlets", "price": 2400},
	{"item": "Rising Force Fists", "price": 2400},
	{"item": "Cosmic Conduit Gloves", "price": 2400},
	{"item": "Death's Hand Wraps", "price": 2400},
]

const PEOPLE: Array = [
	{"id": "keeper", "sprite": "elder", "at": Vector2i(15, 9), "facing": "down"},
	{"id": "innkeeper", "sprite": "innkeeper_b", "at": Vector2i(13, 4), "facing": "down"},
	{"id": "shopkeeper", "sprite": "shopkeeper", "at": Vector2i(4, 4), "facing": "down"},
	{"id": "smith", "sprite": "smith", "at": Vector2i(24, 4), "facing": "down"},
	{"id": "northerner", "sprite": "guard_b", "at": Vector2i(19, 7), "facing": "down"},
	{"id": "nomad", "sprite": "traveler", "at": Vector2i(7, 9), "facing": "right"},
	{"id": "sailor", "sprite": "worker", "at": Vector2i(21, 11), "facing": "left"},
	{"id": "child", "sprite": "child_b", "at": Vector2i(25, 15), "facing": "left"},
]
const TALK := {
	"keeper": [
		"say Keeper: Every age, someone keeps the Threshold. In this one, it's me. Rest here - nothing from the Maw crosses this line.",
	],
	"innkeeper": ["say Innkeeper: No charge. Not here, not for you. Everyone in Valdris owes you a bed."],
	"shopkeeper": ["say Shopkeeper: Merchants from all three kingdoms send their best stock here. Take what you need."],
	"smith": ["say Smith: Starforged steel. Smelted from a fallen star, they say. It's the last forge before the dark."],
	"northerner": ["say Northerner: I walked all the way from Nordveil. I wanted to see the people who broke the Sovereign before they went down there."],
	"nomad": ["say Nomad: The ruined shrine west of the road... something guards it. Something old. Be careful."],
	"sailor": ["say Sailor: Selavon sent me with supplies. The harbor's never been busier, thanks to you."],
	"child": ["say Child: Mama says the grey fog is the end of the world. But you're going in anyway?"],
}


func _ready() -> void:
	GameManager.current_location = "threshold"
	GameManager.current_scene_path = "res://scenes/town/Threshold.tscn"
	Music.play("town", "overworld")
	_tile_map.y_sort_enabled = true
	_paint(MAP)
	for p: Dictionary in PEOPLE:
		_add_npc(p["id"], p["sprite"], p["at"], p["facing"])
	_add_npc("frank", "frank", FRANK_SPOT, "down")
	_place_player(ENTRY_CELL)
	_arrival()


## The first time here: Frank is waiting (threshold_arrival.scene).
func _arrival() -> void:
	if GameManager.has_flag("threshold_arrived"):
		return
	GameManager.story_flags["threshold_arrived"] = true
	if Transition.is_busy():
		await Transition.finished
	await Cutscene.play(ARRIVAL_SCENE)
	_refresh_quest_marks()


func get_door_destination(cell: Vector2i) -> Dictionary:
	if cell == GATE_CELL:
		GameManager.arrival = "threshold"
		return {"scene": "res://scenes/overworld/Reach.tscn"}
	return {}


func interact(cell: Vector2i, facing: String) -> void:
	if _npcs.has(cell):
		var id: String = _npcs[cell]
		if id == "frank" and await _quest_talk("frank", facing):
			return  # the portal key's binding goes through Frank (28a)
		if id == "frank":
			await _frank()
		else:
			await _talk(id, facing)
	elif cell == INN_DOOR:
		await _free_inn()
	elif cell == SHOP_DOOR:
		await ShopMenu.open(self, ITEM_STOCK)
	elif cell == ARMORY_DOOR:
		await Cutscene.play_text("say Smith: The last forge before the dark. Choose well.")
		await ShopMenu.open(self, ARMORY_STOCK)
	elif cell == SHRINE:
		await _shrine()
	elif _tile_map.get_cell_atlas_coords(cell).x == HOUSE_DOOR:
		await Cutscene.play_text("narrate Refugees from three kingdoms share this house. Someone is telling the story of the Frozen Sovereign. They have the details wrong.")


func _talk(id: String, facing: String) -> void:
	if await _quest_talk(id, facing):
		return
	await _talk_lines(id, facing, TALK.get(id, []))


## The doc: "inn is free".
func _free_inn() -> void:
	var pick := await Cutscene.ask("Rest for the night? (It's free.)", ["Stay", "Not now"], "Innkeeper")
	if pick != 0:
		return
	await Transition.fade_out(0.6)
	Sfx.play("heal")
	_restore_party()
	await get_tree().create_timer(0.8).timeout
	await Transition.fade_in(0.6)
	await Cutscene.play_text("say Innkeeper: Morning. Whatever's down there - you're as ready as anyone's ever been.")
	await offer_save()


## The doc: "shrine has unlimited uses" (and it's a save point).
func _shrine() -> void:
	Sfx.play("heal")
	_restore_party()
	await Cutscene.play_text("narrate The Threshold's light washes over the party. It never dims.")
	await offer_save()
