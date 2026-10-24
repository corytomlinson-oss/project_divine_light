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
	{"item": "Phoenix Feather", "price": 150},
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

# Act II towns (25a) belong to a kingdom: until it's cleansed they draw grey
# and violet (the region shader) and use their "before" state - each town
# checks cleansed() for its people, shops and lines. "" = never corrupted.
var kingdom_id := ""

var _npcs: Dictionary = {}  # cell -> actor id
var _npc_nodes: Dictionary = {}  # actor id -> character node
var _quest_marks: Dictionary = {}  # actor id -> QuestMark over their head


# After the ending (29): Frank is a faint echo of light, still minding the stall.
const FRANK_ECHO := Color(1.0, 0.95, 0.7, 0.45)
var _frank_echo_seen := false

func _paint(map: Array) -> void:
	_tile_map.clear()
	for y in map.size():
		var row: String = map[y]
		for x in row.length():
			_tile_map.set_cell(Vector2i(x, y), 0, Vector2i(TOWN_TILES.get(row[x], 1), 0))


func _add_npc(id: String, sprite_name: String, cell: Vector2i, facing: String, tint := Color.WHITE) -> void:
	if id == "frank" and GameManager.has_flag("game_complete"):
		tint = FRANK_ECHO  # he faded into the light at the end (28d); an echo keeps the stall
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
	_npc_nodes[id] = npc


## Puts the player at the entry cell, or back where they were before a battle.
## (Every town calls this last in _ready, once its people are placed - so the
## quest marks go up here too.)
func _place_player(entry: Vector2i) -> void:
	_refresh_quest_marks()
	_apply_kingdom_state()
	_play_victory()
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


## Free of the Unraveling (always true for Verdance and Edenmere).
func cleansed() -> bool:
	return kingdom_id == "" or Kingdoms.is_cleansed(kingdom_id)


## The first visit after this town's kingdom is freed (25b): its victory
## scene (data/cutscenes/<kingdom>_victory.scene), then KingdomVictory's
## movie card.
func _play_victory() -> void:
	if kingdom_id == "" or not GameManager.has_flag("victory_pending_" + kingdom_id):
		return
	GameManager.story_flags.erase("victory_pending_" + kingdom_id)
	if Transition.is_busy():
		await Transition.finished
	await Cutscene.play("res://data/cutscenes/%s_victory.scene" % kingdom_id)
	await Transition.fade_out(0.5)
	await KingdomVictory.play_for(self, kingdom_id)
	Music.play("town", "overworld")
	await Transition.fade_in(0.6)


func _apply_kingdom_state() -> void:
	if cleansed():
		return
	var mat := ShaderMaterial.new()
	mat.shader = Region.CORRUPTION_SHADER
	mat.set_shader_parameter("amount", 1.0)
	_tile_map.material = mat


## Side quests (Milestone 24) come first: if this person has quest business,
## they say that instead of their usual lines. Returns whether they did.
func _quest_talk(id: String, facing: String) -> bool:
	var lines := Quests.talk(GameManager.current_location + "/" + id)
	if lines.is_empty():
		return false
	await _talk_lines(id, facing, lines)
	_refresh_quest_marks()
	return true


## A "!" over everyone with a new quest for you, a "?" over anyone a quest is
## waiting on (Quests.mark_for); none over anyone else.
func _refresh_quest_marks() -> void:
	for id: String in _npc_nodes:
		var kind := Quests.mark_for(GameManager.current_location + "/" + id)
		var mark: QuestMark = _quest_marks.get(id)
		if kind == "":
			if mark != null:
				mark.queue_free()
				_quest_marks.erase(id)
		elif mark == null:
			mark = QuestMark.new()
			mark.kind = kind
			_npc_nodes[id].add_child(mark)
			_quest_marks[id] = mark
		else:
			mark.kind = kind
			mark.queue_redraw()


## A gold "!" or "?" bobbing over a villager's head (outlined, so it reads on
## any ground). Sits above where cutscene emote bubbles appear.
class QuestMark extends Node2D:
	const GLYPHS := {
		"!": ["###", "###", "###", "###", ".#.", "...", "###", "###"],
		"?": [".####.", "##..##", "....##", "...##.", "..##..", "......", "..##..", "..##.."],
	}
	const FILL := Color(1.0, 0.84, 0.3)
	const OUTLINE := Color(0.1, 0.07, 0.12)
	var kind := "!"
	var _t := 0.0

	func _ready() -> void:
		z_index = 20

	func _process(delta: float) -> void:
		_t += delta
		position = Vector2(0, -36 + roundf(sin(_t * 4.0) * 1.5))

	func _draw() -> void:
		var rows: Array = GLYPHS[kind]
		var x0 := -int(rows[0].length() / 2.0 + 0.5)
		for pass_i in 2:  # outline first, then the fill on top
			for y in rows.size():
				var row: String = rows[y]
				for x in row.length():
					if row[x] != "#":
						continue
					var at := Vector2(x0 + x, y)
					if pass_i == 0:
						draw_rect(Rect2(at - Vector2.ONE, Vector2(3, 3)), OUTLINE)
					else:
						draw_rect(Rect2(at, Vector2.ONE), FILL)


## For MapScreen: the people with something for you on a quest.
func map_markers() -> Array:
	var markers: Array = []
	for cell: Vector2i in _npcs:
		if Quests.has_business(GameManager.current_location + "/" + String(_npcs[cell])):
			markers.append({"cell": cell, "color": Quests.QUEST_COLOR, "legend": "Quest"})
	return markers


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
	await offer_save()


## Inns and shrines are save points (Milestone 22a).
func offer_save() -> void:
	var pick := await Cutscene.ask("Save your progress?", ["Save", "Not now"])
	if pick == 0:
		await SaveMenu.open(self, "save")


## Full HP and MP for everyone still standing (the fallen stay fallen).
func _restore_party() -> void:
	for m: Combatant in GameManager.party:
		if not m.is_ko:
			m.hp = m.max_hp
			m.mp = m.max_mp


func _frank() -> void:
	if GameManager.has_flag("game_complete") and not _frank_echo_seen:
		_frank_echo_seen = true
		await Cutscene.play_text("narrate Frank's outline shimmers in the light, faint as a memory. Somehow, the stall is still open.")
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
