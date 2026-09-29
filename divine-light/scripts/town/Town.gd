class_name Town
extends Node2D

# What every town shares (Milestone 20d; pulled out of Verdance.gd when
# Edenmere arrived): painting the map from text, townsfolk you face and talk
# to, the inn, and Frank's stall. A town script extends this, gives its MAP to
# _paint(), adds its people with _add_npc(), and handles its own doors in
# interact().
#
# Town atlas (town_tiles.png, built by build_act1_tiles.py):
#   .  grass     T  trees      X  gate out     =  road      *  flowers
#   #  wall      ^  roof       D  door         I  inn sign  ~  pond
#   f  fence     A  Frank's stall (awning)     c  cobbles   S  shrine
#   P  item-shop sign          W  armory sign

const TOWN_TILES := {
	".": 0, "T": 1, "X": 2, "=": 3, "#": 4, "^": 5, "D": 6, "~": 7,
	"f": 8, "*": 9, "A": 10, "I": 11, "c": 12, "S": 13, "P": 14, "W": 15,
}
const BLOCKED_TILES: Array = [4, 5, 6, 7, 8, 10, 11, 13, 14, 15]  # atlas columns you can't walk on
const HOUSE_DOOR := 6
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

const OPPOSITE := {"up": "down", "down": "up", "left": "right", "right": "left"}

@onready var _tile_map: TileMapLayer = $TileMapLayer
@onready var _player: Node2D = $TileMapLayer/Player

var _npcs: Dictionary = {}  # cell -> actor id


func _paint(map: Array) -> void:
	_tile_map.clear()
	for y in map.size():
		var row: String = map[y]
		for x in row.length():
			_tile_map.set_cell(Vector2i(x, y), 0, Vector2i(TOWN_TILES.get(row[x], 1), 0))


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


## Puts the player at the entry cell, or back where they were before a battle.
func _place_player(entry: Vector2i) -> void:
	if GameManager.has_pending_spawn:
		_player.snap_to(GameManager.pending_spawn_position)
		GameManager.has_pending_spawn = false
	else:
		_player.snap_to(_tile_map.map_to_local(entry))


func is_blocked(cell: Vector2i) -> bool:
	return _tile_map.get_cell_atlas_coords(cell).x in BLOCKED_TILES or _npcs.has(cell)


## The person turns to face the player, then says their lines (scene commands).
func _talk_lines(id: String, facing: String, lines: Array) -> void:
	await Cutscene.play_text("face %s %s\n%s" % [id, OPPOSITE[facing], "\n".join(lines)])


func _inn(price: int) -> void:
	var pick := await Cutscene.ask("Rest for the night? A bed is %d gold. (You have %d.)" % [price, GameManager.gold], ["Stay", "Not now"], "Innkeeper")
	if pick != 0:
		return
	if GameManager.gold < price:
		await Cutscene.play_text("say Innkeeper: %d gold, I'm afraid. Come back when you have it." % price)
		return
	GameManager.gold -= price
	await Transition.fade_out(0.6)
	Sfx.play("heal")
	# The design doc keeps revival to Frank and items, so the inn only restores
	# those still standing.
	_restore_party()
	await get_tree().create_timer(0.8).timeout
	await Transition.fade_in(0.6)
	await Cutscene.play_text("say Innkeeper: Morning already. Sleep well? You look like you needed it.")


## Full HP and MP for everyone still standing (the fallen stay fallen).
func _restore_party() -> void:
	for m: Combatant in GameManager.party:
		if not m.is_ko:
			m.hp = m.max_hp
			m.mp = m.max_mp


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
