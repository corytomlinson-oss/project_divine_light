extends Town

# Duskara - the Desert kingdom's capital (Milestone 25c), "gateway to the
# Sunken Sanctum". Two states (Town.cleansed()), each with its own map:
#
#   before - the Burning Tyrant's heatwave: haze and blowing sand over the
#            screen, the south-west house buried in a dune, the oasis dry,
#            people indoors, the inn expensive, potions and antidotes only,
#            the armory shut, the shrine choked with sand. The water-keeper
#            points you at the Sanctum.
#   after  - the heat breaks, the dune is cleared, the oasis brims with
#            water, the townsfolk come out, Frank sets up, the armory opens
#            (Act II's second tier, Sunsteel, and two set accessories), the
#            item shop restocks, the inn is cheaper, the shrine works again.
#
# Tiles: duskara_tiles.png (the town atlas sun-baked; letters in Town.gd).

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
	"T...............=............T",
	"T..TTTTT........=............T",
	"T.TTTTTTT.......=............T",
	"T..TTTTT........=............T",
	"T...TT..........=............T",
	"T.*.............=............T",
	"T...............=............T",
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
	"T..^^^^^........=....~~~~~...T",
	"T..^^^^^........=...~~~~~~~..T",
	"T..##D##........=...*~~~~~*..T",
	"T....=..........=....*~~~*...T",
	"T.*..=======....=............T",
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
const SHRINE_FLAG := "duskara_shrine_used"  # cleared whenever a dungeon loads

const STOCK_BEFORE: Array = [
	{"item": "Potion", "price": 30},
	{"item": "Antidote", "price": 20},
]
const STOCK_AFTER: Array = [
	{"item": "Potion", "price": 20},
	{"item": "Antidote", "price": 15},
	{"item": "Ether", "price": 60},
	{"item": "Elixir", "price": 150},
	{"item": "Phoenix Feather", "price": 150},
	{"item": "Hi-Potion", "price": 120},
	{"item": "Hi-Ether", "price": 300},
]
const ARMORY_STOCK: Array = [
	{"item": "Sunsteel Sword", "price": 1100},
	{"item": "Sunsteel Claws", "price": 1100},
	{"item": "Sunsteel Staff", "price": 1100},
	{"item": "Sunsteel Daggers", "price": 1100},
	{"item": "Desert Mail", "price": 800},
	{"item": "Sandwalker Gi", "price": 750},
	{"item": "Mirage Robe", "price": 750},
	{"item": "Dune Leathers", "price": 750},
	{"item": "Oasis Charm", "price": 900},
	# The other two Act II set accessories (25c; Nordveil sold the first two)
	{"item": "Prism Focus", "price": 1200},
	{"item": "Viper Fang Charm", "price": 1200},
]

const ROBE := Color(1.08, 0.98, 0.86)  # sun-bleached clothes
const PEOPLE_BEFORE: Array = [
	{"id": "keeper", "sprite": "elder", "at": Vector2i(16, 10), "facing": "down"},
	{"id": "innkeeper", "sprite": "innkeeper_b", "at": Vector2i(14, 4), "facing": "down"},
	{"id": "shopkeeper", "sprite": "shopkeeper", "at": Vector2i(4, 4), "facing": "down"},
	{"id": "nomad", "sprite": "traveler", "at": Vector2i(8, 11), "facing": "right"},
	{"id": "guard", "sprite": "guard_b", "at": Vector2i(15, 17), "facing": "up"},
]
const PEOPLE_AFTER: Array = [
	{"id": "smith", "sprite": "smith", "at": Vector2i(25, 4), "facing": "down"},
	{"id": "priestess", "sprite": "priestess", "at": Vector2i(17, 9), "facing": "left"},
	{"id": "child", "sprite": "child_b", "at": Vector2i(24, 15), "facing": "left"},
	{"id": "weaver", "sprite": "worker", "at": Vector2i(9, 16), "facing": "up"},
]

const TALK_BEFORE := {
	"keeper": [
		"say Water-Keeper: Strangers, in this heat? Drink, if you can find anything to drink. The oasis dried to cracked mud a month ago.",
		"say Water-Keeper: The Burning Tyrant has taken the Sunken Sanctum, south-west in the dunes. Whatever he does down there, the whole desert bakes for it.",
		"say Water-Keeper: Our grandfathers sealed its deep halls with old levers and stone doors. If you go in, look for them.",
	],
	"innkeeper": ["say Innkeeper: Forty gold. Water costs more than the bed, I'm afraid."],
	"shopkeeper": ["say Shopkeeper: Potions and antidotes. The caravans stopped coming when the sand started burning."],
	"nomad": [
		"say Nomad: The vipers out there bite and the venom stays. Carry antidotes, or carry someone who can cure it.",
		"say Nomad: And the golems - stone and sand. Earth magic just sinks into them. Try something else.",
	],
	"guard": ["say Guard: The south-west house? Buried to the roof in one night. The family got out through the window."],
}
const TALK_AFTER := {
	"keeper": [
		"say Water-Keeper: Do you hear that? Water, bubbling up through the sand. The oasis lives!",
		"say Water-Keeper: Duskara will not forget this. Our gates, our wells and our tables are yours.",
	],
	"innkeeper": ["say Innkeeper: Twenty gold, and the water's free again. Rest well!"],
	"shopkeeper": ["say Shopkeeper: The caravans are back! Everything's in stock - the good potions too."],
	"nomad": ["say Nomad: The wind smells of water again. I might finally settle down."],
	"guard": ["say Guard: We dug the house out together, the whole street. Took all day. Nobody minded."],
	"smith": ["say Smith: Sunsteel! Forged in the heat the Tyrant left behind. Fitting, isn't it?"],
	"priestess": ["say Priestess: The shrine is clean again. Rest in it once each time you return from the dark places."],
	"child": ["say Child: I can swim! Well, I can splash. The oasis is so cold!"],
	"weaver": ["say Weaver: My looms were buried in sand for weeks. Look - not a single thread lost."],
}


func _ready() -> void:
	kingdom_id = "duskara"
	GameManager.current_location = "duskara"
	GameManager.current_scene_path = "res://scenes/town/Duskara.tscn"
	Music.play("town" if cleansed() else "desert", "town")  # the region theme until freed (27)
	_tile_map.y_sort_enabled = true
	_paint(MAP_AFTER if cleansed() else MAP_BEFORE)
	for p: Dictionary in PEOPLE_BEFORE:
		_add_npc(p["id"], p["sprite"], p["at"], p["facing"], ROBE)
	if cleansed():
		for p: Dictionary in PEOPLE_AFTER:
			_add_npc(p["id"], p["sprite"], p["at"], p["facing"], ROBE)
		_add_npc("frank", "frank", FRANK_SPOT, "down")
	else:
		_add_heatwave()
		var sand := DryShrine.new()
		sand.position = _tile_map.map_to_local(SHRINE)
		_tile_map.add_child(sand)
	_place_player(ENTRY_CELL)


## The heatwave: a warm haze and blowing sand over the town.
func _add_heatwave() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 4
	var haze := ColorRect.new()
	haze.size = Vector2(320, 180)
	haze.color = Color(1.0, 0.55, 0.2, 0.1)
	haze.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(haze)
	var sand := WeatherFx.new()
	sand.kind = "sand"
	layer.add_child(sand)
	add_child(layer)


## Sand heaped over the shrine's flame (the town tile is drawn lit).
class DryShrine extends Node2D:
	func _draw() -> void:
		draw_rect(Rect2(-3, -8, 6, 7), Color(0.8, 0.64, 0.4))
		draw_rect(Rect2(-2, -4, 4, 2), Color(0.66, 0.5, 0.3))


func get_door_destination(cell: Vector2i) -> Dictionary:
	if cell == GATE_CELL:
		GameManager.arrival = "duskara"
		return {"scene": "res://scenes/overworld/Desert.tscn"}
	return {}


func interact(cell: Vector2i, facing: String) -> void:
	if _npcs.has(cell):
		var id: String = _npcs[cell]
		if id == "frank":
			await _frank()
		else:
			await _talk(id, facing)
	elif cell == INN_DOOR:
		await _inn(20 if cleansed() else 40)
	elif cell == SHOP_DOOR:
		await Cutscene.play_text("say Shopkeeper: %s" % ("Come in, out of the sun!" if cleansed() else "What little I have, I'll sell - for a price."))
		await ShopMenu.open(self, STOCK_AFTER if cleansed() else STOCK_BEFORE)
	elif cell == ARMORY_DOOR:
		if cleansed():
			await Cutscene.play_text("say Smith: Sunsteel, every piece. Have a look.")
			await ShopMenu.open(self, ARMORY_STOCK)
		else:
			await Cutscene.play_text("narrate The armory's door is shut and sand drifts against it. A sign reads: Forge too hot to work. Closed.")
	elif cell == SHRINE:
		await _shrine()
	elif _tile_map.get_cell_atlas_coords(cell).x == HOUSE_DOOR:
		if cleansed():
			await Cutscene.play_text("narrate Laughter and the clink of cups come through the door.")
		else:
			await Cutscene.play_text("narrate Behind the shuttered door, someone is rationing water in whispers. Nobody answers.")


func _talk(id: String, facing: String) -> void:
	if await _quest_talk(id, facing):
		return
	var lines: Array = (TALK_AFTER if cleansed() else TALK_BEFORE).get(id, [])
	await _talk_lines(id, facing, lines)


func _shrine() -> void:
	if not cleansed():
		await Cutscene.play_text("narrate The shrine's bowl is choked with hot sand. Nothing stirs in it.")
	elif GameManager.has_flag(SHRINE_FLAG):
		await Cutscene.play_text("narrate The shrine's flame burns steady and cool, but it has given what it can for now. Return after your next journey.")
	else:
		GameManager.story_flags[SHRINE_FLAG] = true
		Sfx.play("heal")
		_restore_party()
		await Cutscene.play_text("narrate A cool light washes over the party. Wounds close; the heat leaves them.")
	await offer_save()
