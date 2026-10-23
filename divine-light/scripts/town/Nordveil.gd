extends Town

# Nordveil - the Tundra kingdom's capital (Milestone 25b), the design doc's
# "gateway to the Frozen Citadel". Two states (Town.cleansed()):
#
#   before - the Frozen Sovereign's blizzard never stops: snow driving across
#            the screen, most people shut indoors, the inn expensive, only
#            potions and antidotes for sale, the armory boarded up, the
#            shrine's flame dead. The captain points you at the Citadel.
#   after  - the sky clears, every window glows, the townsfolk come back out,
#            Frank sets up in the square, the armory opens (Act II's first
#            tier), the item shop restocks (Hi-Potions, Hi-Ethers), the inn
#            is cheaper and the shrine works again (once per dungeon trip).
#
# Tiles: nordveil_tiles.png (the town atlas wintered over; letters in Town.gd).

const MAP := [
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
	"T..^^^^^........=.....^^^^^..T",
	"T..^^^^^..~~~...=.....^^^^^..T",
	"T..##D##.~~~~~..=.....##D##..T",
	"T....=....~~~...=.......=..*.T",
	"T.*..=======....=..=======...T",
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
const SHRINE_FLAG := "nordveil_shrine_used"  # cleared whenever a dungeon loads
# Windows on the house fronts that light up once the cold breaks.
const WINDOWS: Array = [Vector2i(3, 3), Vector2i(7, 3), Vector2i(12, 3), Vector2i(14, 3), Vector2i(23, 3),
		Vector2i(3, 14), Vector2i(7, 14), Vector2i(22, 14), Vector2i(26, 14)]

const STOCK_BEFORE: Array = [
	{"item": "Potion", "price": 30},
	{"item": "Antidote", "price": 20},
]
const STOCK_AFTER: Array = [
	{"item": "Potion", "price": 20},
	{"item": "Antidote", "price": 15},
	{"item": "Ether", "price": 60},
	{"item": "Elixir", "price": 150},
	{"item": "Hi-Potion", "price": 120},
	{"item": "Hi-Ether", "price": 300},
]
const ARMORY_STOCK: Array = [
	{"item": "Frostforged Sword", "price": 700},
	{"item": "Frostforged Claws", "price": 700},
	{"item": "Frostforged Staff", "price": 700},
	{"item": "Frostforged Daggers", "price": 700},
	{"item": "Knight's Mail", "price": 500},
	{"item": "Furred Gi", "price": 450},
	{"item": "Frostweave Robe", "price": 450},
	{"item": "Snowfox Leathers", "price": 450},
	{"item": "Hearthstone Charm", "price": 600},
]

# People (sprite ids from build_townsfolk.py, tinted for winter coats).
const COAT := Color(0.85, 0.9, 1.05)
const PEOPLE_BEFORE: Array = [
	{"id": "captain", "sprite": "guard_b", "at": Vector2i(16, 10), "facing": "down"},
	{"id": "innkeeper", "sprite": "innkeeper_b", "at": Vector2i(14, 4), "facing": "down"},
	{"id": "shopkeeper", "sprite": "shopkeeper", "at": Vector2i(4, 4), "facing": "down"},
	{"id": "elder", "sprite": "elder", "at": Vector2i(15, 8), "facing": "right"},
	{"id": "huntress", "sprite": "traveler", "at": Vector2i(8, 11), "facing": "right"},
]
const PEOPLE_AFTER: Array = [
	{"id": "smith", "sprite": "smith", "at": Vector2i(25, 4), "facing": "down"},
	{"id": "priestess", "sprite": "priestess", "at": Vector2i(17, 9), "facing": "left"},
	{"id": "child", "sprite": "child_b", "at": Vector2i(26, 16), "facing": "left"},
	{"id": "woodcutter", "sprite": "worker", "at": Vector2i(11, 16), "facing": "up"},
]

const TALK_BEFORE := {
	"captain": [
		"say Captain: Travelers? Through the pass, in this? Then you're either mad or the help we've been praying for.",
		"say Captain: The Frozen Sovereign sits in the Citadel up the mountain road. Since he came, the blizzard hasn't stopped. Not for a single day.",
		"say Captain: My scouts never came back. If you mean to try, the road north from the crossroads climbs straight to its gates.",
	],
	"innkeeper": ["say Innkeeper: Forty gold a night. I'm sorry. Firewood costs more than gold now."],
	"shopkeeper": ["say Shopkeeper: Potions and antidotes, that's all that's left. The supply sleds stopped coming weeks ago."],
	"elder": [
		"say Elder: The shrine's flame went out the night the Sovereign came. We've tried to relight it. It won't take.",
		"say Elder: As long as he sits on that throne, I think nothing warm will last in Nordveil.",
	],
	"huntress": [
		"say Huntress: Thorny violet brambles grow wherever his cold settles. Nothing cuts them. Nothing burns them.",
		"say Huntress: There's a valley west of the river I used to hunt. The brambles have it sealed up tight now.",
	],
}
const TALK_AFTER := {
	"captain": [
		"say Captain: Look at that sky. I'd forgotten it could be blue.",
		"say Captain: Whatever you need, Nordveil's gates are yours. The other kingdoms will want to hear what you did here.",
	],
	"innkeeper": ["say Innkeeper: Twenty gold, and the fire's on the house. Stay as long as you like!"],
	"shopkeeper": ["say Shopkeeper: The sleds are running again! I've got the good stock in - come and see."],
	"elder": ["say Elder: The flame caught on the first try. I wept like a child. Go and rest in its light."],
	"huntress": ["say Huntress: The brambles crumbled to dust. The west valley's open again - there's a spring up there worth the walk."],
	"smith": ["say Smith: Forge is hot again! Frostforged steel - the best you'll find north of the forest."],
	"priestess": ["say Priestess: The shrine is whole again. Rest in it once each time you return from the dark places."],
	"child": ["say Child: I made a snowman! A real one, not a scary ice one."],
	"woodcutter": ["say Woodcutter: Felt the cold break right through my boots. Now I can split this wood before it freezes to the axe."],
}


func _ready() -> void:
	kingdom_id = "nordveil"
	GameManager.current_location = "nordveil"
	GameManager.current_scene_path = "res://scenes/town/Nordveil.tscn"
	Music.play("town" if cleansed() else "nordveil_cold", "town")
	_tile_map.y_sort_enabled = true
	_paint(MAP)
	for p: Dictionary in PEOPLE_BEFORE:
		_add_npc(p["id"], p["sprite"], p["at"], p["facing"], COAT)
	if cleansed():
		for p: Dictionary in PEOPLE_AFTER:
			_add_npc(p["id"], p["sprite"], p["at"], p["facing"], COAT)
		_add_npc("frank", "frank", FRANK_SPOT, "down")
		_light_windows()
	else:
		_add_blizzard()
		var ash := ShrineAsh.new()  # the shrine's flame is out until the cold breaks
		ash.position = _tile_map.map_to_local(SHRINE)
		_tile_map.add_child(ash)
	_place_player(ENTRY_CELL)


func _add_blizzard() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 4  # over the map, under menus and dialogue
	var snow := WeatherFx.new()
	snow.kind = "blizzard"
	layer.add_child(snow)
	add_child(layer)


## A warm glow in each window, flickering a little like firelight.
func _light_windows() -> void:
	for cell: Vector2i in WINDOWS:
		var glow := WindowGlow.new()
		glow.position = _tile_map.map_to_local(cell)
		_tile_map.add_child(glow)


## Cold ash and ice over the shrine's flame (the town tile is drawn lit).
class ShrineAsh extends Node2D:
	func _draw() -> void:
		draw_rect(Rect2(-3, -8, 6, 7), Color(0.42, 0.44, 0.52))
		draw_rect(Rect2(-2, -4, 4, 2), Color(0.3, 0.32, 0.4))
		draw_rect(Rect2(-1, -7, 1, 1), Color(0.8, 0.88, 1.0))


class WindowGlow extends Node2D:
	var _t := randf() * 10.0

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		var flicker := 0.75 + 0.25 * sin(_t * 7.0) * sin(_t * 3.1)
		draw_rect(Rect2(-3, -4, 6, 5), Color(0.1, 0.06, 0.04))
		draw_rect(Rect2(-2, -3, 4, 3), Color(1.0, 0.72 * flicker + 0.1, 0.3, 1.0))


func get_door_destination(cell: Vector2i) -> Dictionary:
	if cell == GATE_CELL:
		GameManager.arrival = "nordveil"
		return {"scene": "res://scenes/overworld/Tundra.tscn"}
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
		await _inn(20 if cleansed() else 40)
	elif cell == SHOP_DOOR:
		await Cutscene.play_text("say Shopkeeper: %s" % ("Come in, come in!" if cleansed() else "What little I have is yours - for a price."))
		await ShopMenu.open(self, STOCK_AFTER if cleansed() else STOCK_BEFORE)
	elif cell == ARMORY_DOOR:
		if cleansed():
			await Cutscene.play_text("say Smith: Have a look. Frostforged, every piece.")
			await ShopMenu.open(self, ARMORY_STOCK)
		else:
			await Cutscene.play_text("narrate The armory is boarded up. A note on the door reads: No fuel for the forge. Gone to the Captain.")
	elif cell == SHRINE:
		await _shrine()
	elif _tile_map.get_cell_atlas_coords(cell).x == HOUSE_DOOR:
		if cleansed():
			await Cutscene.play_text("narrate Warm light spills from the window. Someone inside is laughing.")
		else:
			await Cutscene.play_text("narrate Through the frosted window, a family huddles around a dying fire. Nobody answers.")


func _talk(id: String, facing: String) -> void:
	if await _quest_talk(id, facing):
		return
	var lines: Array = (TALK_AFTER if cleansed() else TALK_BEFORE).get(id, [])
	await _talk_lines(id, facing, lines)


## Dead until the Sovereign falls; then free HP/MP once per dungeon trip,
## like Edenmere's (and a save point either way).
func _shrine() -> void:
	if not cleansed():
		await Cutscene.play_text("narrate The shrine's bowl holds only cold ash and a crust of ice.")
	elif GameManager.has_flag(SHRINE_FLAG):
		await Cutscene.play_text("narrate The shrine's flame burns steady and warm, but it has given what it can for now. Return after your next journey.")
	else:
		GameManager.story_flags[SHRINE_FLAG] = true
		Sfx.play("heal")
		_restore_party()
		await Cutscene.play_text("narrate Warmth washes over the party. Wounds close; the cold leaves their bones.")
	await offer_save()
