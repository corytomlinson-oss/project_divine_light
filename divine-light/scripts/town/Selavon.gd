extends Town

# Selavon - the Coastal kingdom's capital (Milestone 25d), "gateway to the
# Drowned Fortress"; the doc's "most reward-rich post-cleanse town".
#
#   before - the Drowned Admiral's storm: rain and lightning over the town,
#            the harbor quarter flooded, people indoors, the inn expensive,
#            potions only, armory shut, shrine drowned. The harbormaster
#            points at the fortress.
#   after  - the skies clear, the harbor drains, the boats are back, Frank
#            sets up, the armory opens (Act II's third tier, Stormsilver),
#            the shop restocks, and the harbormaster rewards the party once.
#
# Tiles: selavon_tiles.png (the town atlas by the sea; letters in Town.gd).

const MAP_BEFORE := [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"T..^^^^^...^^^^^^^^...^^^^^..T",
	"T..^^^^^...^^^^^^^^...^^^^^..T",
	"T..#PD##...####D#I#...##DW#..T",
	"T....=.........=.........=...T",
	"T*...=.........=.........=..*T",
	"T....ccccccccccccccccccccc...T",
	"T....ccccccccccccccccccccc...T",
	"T....cccccccccccSccccccccc...T",
	"T....ccccccccccccccccccccc...T",
	"T....ccccccccccccccccccccc...T",
	"T...............=.~~~~~~~~~~~T",
	"T..^^^^^........=.~~~~~~~~~~~T",
	"T..^^^^^........=.~~~~~~~~~~~T",
	"T..##D##........=.~~~~~~~~~~~T",
	"T....=..........=.~~~~~~~~~~~T",
	"T.*..=======....=.~~~~~~~~~~~T",
	"T...............=.~~~~~~~~~~~T",
	"TT..............=...........TT",
	"TTTTTTTTTTTTTTTTXTTTTTTTTTTTTT",
]
const MAP_AFTER := [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"T..^^^^^...^^^^^^^^...^^^^^..T",
	"T..^^^^^...^^^^^^^^...^^^^^..T",
	"T..#PD##...####D#I#...##DW#..T",
	"T....=.........=.........=...T",
	"T*...=.........=.........=..*T",
	"T....ccccccccccccccccccccc...T",
	"T....ccccccccccccccccccccc...T",
	"T....cccccccccccSccccccccc...T",
	"T....ccccccccccccccccccccc...T",
	"T....ccccccccccccccccccccc...T",
	"T...............=............T",
	"T..^^^^^........=....~~~~~~~~T",
	"T..^^^^^........=....~~~~~~~~T",
	"T..##D##........=....=====~~~T",
	"T....=..........=........~~~~T",
	"T.*..=======....=....~~~~~~~~T",
	"T...............=............T",
	"TT..............=...........TT",
	"TTTTTTTTTTTTTTTTXTTTTTTTTTTTTT",
]
const GATE_CELL := Vector2i(16, 19)
const ENTRY_CELL := Vector2i(16, 18)
const SHOP_DOOR := Vector2i(5, 3)
const INN_DOOR := Vector2i(15, 3)
const ARMORY_DOOR := Vector2i(24, 3)
const SHRINE := Vector2i(16, 8)
const FRANK_SPOT := Vector2i(21, 10)
const SHRINE_FLAG := "selavon_shrine_used"
const GIFT_FLAG := "selavon_gift"

const STOCK_BEFORE: Array = [
	{"item": "Potion", "price": 30},
	{"item": "Antidote", "price": 20},
]
const STOCK_AFTER: Array = [
	{"item": "Potion", "price": 18},
	{"item": "Antidote", "price": 12},
	{"item": "Ether", "price": 55},
	{"item": "Elixir", "price": 130},
	{"item": "Phoenix Feather", "price": 130},
	{"item": "Hi-Potion", "price": 100},
	{"item": "Hi-Ether", "price": 260},
]
const ARMORY_STOCK: Array = [
	{"item": "Stormsilver Sword", "price": 1600},
	{"item": "Stormsilver Claws", "price": 1600},
	{"item": "Stormsilver Staff", "price": 1600},
	{"item": "Stormsilver Daggers", "price": 1600},
	{"item": "Tideguard Plate", "price": 1200},
	{"item": "Seafoam Gi", "price": 1100},
	{"item": "Tidecaller Robe", "price": 1100},
	{"item": "Reefrunner Leathers", "price": 1100},
	{"item": "Tide Charm", "price": 1300},
]

const OILSKIN := Color(0.88, 0.95, 1.0)
const PEOPLE_BEFORE: Array = [
	{"id": "harbormaster", "sprite": "mayor", "at": Vector2i(16, 10), "facing": "down"},
	{"id": "innkeeper", "sprite": "innkeeper_b", "at": Vector2i(14, 4), "facing": "down"},
	{"id": "shopkeeper", "sprite": "shopkeeper", "at": Vector2i(4, 4), "facing": "down"},
	{"id": "fisher", "sprite": "worker", "at": Vector2i(8, 11), "facing": "right"},
	{"id": "guard", "sprite": "guard_b", "at": Vector2i(15, 17), "facing": "up"},
]
const PEOPLE_AFTER: Array = [
	{"id": "smith", "sprite": "smith", "at": Vector2i(25, 4), "facing": "down"},
	{"id": "priestess", "sprite": "priestess", "at": Vector2i(17, 9), "facing": "left"},
	{"id": "child", "sprite": "child_b", "at": Vector2i(19, 15), "facing": "right"},
	{"id": "sailor", "sprite": "traveler", "at": Vector2i(20, 17), "facing": "up"},
]

const TALK_BEFORE := {
	"harbormaster": [
		"say Harbormaster: Mind the water - the harbor quarter's under it. The Drowned Admiral sank our fleet and called this storm down on us.",
		"say Harbormaster: He holds the old sea fortress on the island south of the coast road. A pier runs out to it, if the waves let you cross.",
		"say Harbormaster: Its lower halls flood. You'll wade, and wading's slow - anything that finds you in the water will be quicker than you.",
	],
	"innkeeper": ["say Innkeeper: Forty gold, and I'm sorry about the leaks."],
	"shopkeeper": ["say Shopkeeper: Potions and antidotes. No ship's made port in a month."],
	"fisher": [
		"say Fisher: Lightning rods on the fortress walls. Stand near one when the storm lets go and you'll know it.",
		"say Fisher: Count your steps out there. It strikes in a rhythm, like a heartbeat.",
	],
	"guard": ["say Guard: The surge took the harbor quarter in one night. We pulled people off the rooftops."],
}
const TALK_AFTER := {
	"harbormaster": [
		"say Harbormaster: Look at it - flat calm, blue to the horizon. The boats are already going out.",
	],
	"innkeeper": ["say Innkeeper: Eighteen gold - no, take the room free tonight. You've earned it."],
	"shopkeeper": ["say Shopkeeper: Three ships in this morning! The good potions, and cheap - Selavon's open for trade."],
	"fisher": ["say Fisher: The fish are back. The whole bay's boiling with them."],
	"guard": ["say Guard: The harbor drained like someone pulled a plug. We're already rebuilding the docks."],
	"smith": ["say Smith: Stormsilver! Forged from the Admiral's own sunken cannons. Finest steel in Valdris."],
	"priestess": ["say Priestess: The shrine stands clear of the sea again. Rest in it once each time you return from the dark places."],
	"child": ["say Child: I found a real pirate coin on the beach! Well, I think it's a pirate coin."],
	"sailor": ["say Sailor: First clear sky in a month. I'd forgotten what the stars look like over water."],
}


func _ready() -> void:
	kingdom_id = "selavon"
	GameManager.current_location = "selavon"
	GameManager.current_scene_path = "res://scenes/town/Selavon.tscn"
	Music.play("town" if cleansed() else "coast", "town")  # the region theme until freed (27)
	_tile_map.y_sort_enabled = true
	_paint(MAP_AFTER if cleansed() else MAP_BEFORE)
	for p: Dictionary in PEOPLE_BEFORE:
		_add_npc(p["id"], p["sprite"], p["at"], p["facing"], OILSKIN)
	if cleansed():
		for p: Dictionary in PEOPLE_AFTER:
			_add_npc(p["id"], p["sprite"], p["at"], p["facing"], OILSKIN)
		_add_npc("frank", "frank", FRANK_SPOT, "down")
	else:
		_add_storm()
	_place_player(ENTRY_CELL)


## The Admiral's storm: rain, and now and then lightning whiting out the sky.
func _add_storm() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 4
	var gloom := ColorRect.new()
	gloom.size = Vector2(320, 180)
	gloom.color = Color(0.1, 0.14, 0.24, 0.22)
	gloom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(gloom)
	var rain := WeatherFx.new()
	rain.kind = "rain"
	layer.add_child(rain)
	var flash := ColorRect.new()
	flash.size = Vector2(320, 180)
	flash.color = Color(1, 1, 1, 0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(flash)
	add_child(layer)
	var timer := Timer.new()
	timer.wait_time = 4.5
	timer.autostart = true
	timer.timeout.connect(func() -> void:
		flash.color.a = 0.55
		create_tween().tween_property(flash, "color:a", 0.0, 0.35)
		Sfx.play("thunder"))
	add_child(timer)


func get_door_destination(cell: Vector2i) -> Dictionary:
	if cell == GATE_CELL:
		GameManager.arrival = "selavon"
		return {"scene": "res://scenes/overworld/Coast.tscn"}
	return {}


func interact(cell: Vector2i, facing: String) -> void:
	if _npcs.has(cell):
		var id: String = _npcs[cell]
		if id == "frank":
			await _frank()
		elif id == "harbormaster" and cleansed() and not GameManager.has_flag(GIFT_FLAG):
			await _gift(facing)
		else:
			await _talk(id, facing)
	elif cell == INN_DOOR:
		await _inn(18 if cleansed() else 40)
	elif cell == SHOP_DOOR:
		await Cutscene.play_text("say Shopkeeper: %s" % ("Fresh off the ships - come in!" if cleansed() else "Not much left, I'm afraid."))
		await ShopMenu.open(self, STOCK_AFTER if cleansed() else STOCK_BEFORE)
	elif cell == ARMORY_DOOR:
		if cleansed():
			await Cutscene.play_text("say Smith: Stormsilver, every piece. Take your time.")
			await ShopMenu.open(self, ARMORY_STOCK)
		else:
			await Cutscene.play_text("narrate The armory is shuttered against the storm. Water sloshes under the door.")
	elif cell == SHRINE:
		await _shrine()
	elif _tile_map.get_cell_atlas_coords(cell).x == HOUSE_DOOR:
		if cleansed():
			await Cutscene.play_text("narrate Someone inside is singing an old sea shanty, badly.")
		else:
			await Cutscene.play_text("narrate Buckets clank inside as someone bails water. Nobody answers.")


## Selavon's thanks, once (the doc's "most reward-rich" town).
func _gift(facing: String) -> void:
	GameManager.story_flags[GIFT_FLAG] = true
	GameManager.gold += 2000
	GameManager.inventory["Elixir"] = mini(99, int(GameManager.inventory.get("Elixir", 0)) + 3)
	Sfx.play("level_up")
	await _talk_lines("harbormaster", facing, [
		"say Harbormaster: Before you go - the merchants pooled this together. Don't you dare refuse it.",
		"narrate Received 2000 gold and 3 Elixirs.",
	])


func _talk(id: String, facing: String) -> void:
	if await _quest_talk(id, facing):
		return
	var lines: Array = (TALK_AFTER if cleansed() else TALK_BEFORE).get(id, [])
	await _talk_lines(id, facing, lines)


func _shrine() -> void:
	if not cleansed():
		await Cutscene.play_text("narrate Seawater fills the shrine's bowl to the brim. Its flame is drowned.")
	elif GameManager.has_flag(SHRINE_FLAG):
		await Cutscene.play_text("narrate The shrine's flame burns steady, but it has given what it can for now. Return after your next journey.")
	else:
		GameManager.story_flags[SHRINE_FLAG] = true
		Sfx.play("heal")
		_restore_party()
		await Cutscene.play_text("narrate A calm light washes over the party, like still water. Wounds close.")
	await offer_save()
