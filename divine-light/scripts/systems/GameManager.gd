extends Node

signal party_loaded

const SAVE_DIR: String = "user://saves/"
const SAVE_SLOTS: int = 3

# Everyone who exists in the story (Milestone 20a), by class name, and the
# party: who's actually with you, in the order they joined. A new game starts
# with only the chosen character; the others join when rescued (recruit()).
const CLASSES: Array = ["Vael", "Ryn", "Lyra", "Silas"]
var roster: Dictionary = {}
var party: Array = []
var starting_class: String = ""
var inventory: Dictionary = {}
var current_location: String = "overworld"
var current_scene_path: String = "res://scenes/overworld/Overworld.tscn"
var pending_spawn_position: Vector2 = Vector2.ZERO
var has_pending_spawn: bool = false
var dungeon_seeds: Dictionary = {}
var pending_boss_battle: bool = false
var defeated_bosses: Dictionary = {}
# Set by the pause menu before it opens another screen (Equip), so the map
# reopens the menu when that screen returns to it.
var reopen_pause_menu: bool = false
# Story flags set by cutscenes ("set met_frank"), saved with the game, so a
# scene can check whether something already happened (Milestone 19a).
var story_flags: Dictionary = {}


func _ready() -> void:
	# Launching straight into a map (F6 in the editor) skips the title screen,
	# so the game starts with everyone and the Milestone 15 test gear - handy
	# for development. A real New Game goes through start_new_game() instead.
	if party.is_empty():
		_build_roster()
		for cls: String in CLASSES:
			party.append(roster[cls])
	if inventory.is_empty():
		inventory = {
			"Potion": 10,
			"Elixir": 3,
			"Ether": 5,
			"Antidote": 5,
			# Milestone 15 starter gear - placeholder test items, not real loot.
			# The full Holy Guardian Set is included so the one wired-up set
			# bonus (Vael's "buff skills last 1 extra round") is immediately
			# testable without a shop/loot system, which doesn't exist yet.
			"Iron Sword": 1,
			"Guardian Plate": 1,
			"Guardian Helm": 1,
			"Guardian Gauntlets": 1,
			"Guardian Emblem": 1,
			"Iron Claws": 1,
			"Monk Wraps": 1,
			"Apprentice Staff": 1,
			"Scholar's Robe": 1,
			"Twin Daggers": 1,
			"Leather Hood": 1,
			"Traveler's Ring": 1,
		}


func _build_roster() -> void:
	roster = {
		"Vael": Combatant.new("Vael",  150, 10, 12,  6, false, 30, "Vael",  8, 8),
		"Ryn": Combatant.new("Ryn",   100, 14,  8, 10, false,  0, "Ryn",   3, 5),
		"Lyra": Combatant.new("Lyra",   70,  5,  4,  8, false, 50, "Lyra", 15, 8),
		"Silas": Combatant.new("Silas",  90, 12,  7, 14, false, 30, "Silas",  4, 5),
	}
	roster["Vael"].row = "front"
	roster["Ryn"].row = "front"
	roster["Lyra"].row = "back"
	roster["Silas"].row = "back"


## A fresh game as `cls`: alone, level 1, a few potions, no gear, nothing done.
func start_new_game(cls: String) -> void:
	_build_roster()
	party = [roster[cls]]
	starting_class = cls
	inventory = {"Potion": 3, "Antidote": 1}
	story_flags = {}
	dungeon_seeds = {}
	defeated_bosses = {}
	has_pending_spawn = false
	pending_boss_battle = false


## A rescued character joins the party. They catch up to the party's average
## level first, so they're useful straight away rather than a level-1 burden.
func recruit(cls: String) -> void:
	var member: Combatant = roster[cls]
	if member in party:
		return
	var total := 0
	for m: Combatant in party:
		total += m.level
	var target := roundi(float(total) / maxi(1, party.size()))
	while member.level < target:
		member.level_up()
	member.hp = member.max_hp
	member.mp = member.max_mp
	party.append(member)
	story_flags["recruited_" + cls.to_lower()] = true


func has_member(cls: String) -> bool:
	return party.any(func(m: Combatant) -> bool: return m.char_class == cls)


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_F5:
		save_game(1)
		print("Saved to slot 1.")
	elif event.keycode == KEY_F6:
		if load_game(1):
			print("Loaded slot 1.")
		else:
			print("No save found in slot 1.")


func save_game(slot: int) -> bool:
	if slot < 1 or slot > SAVE_SLOTS:
		return false
	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")
	var file := FileAccess.open(_slot_path(slot), FileAccess.WRITE)
	if file == null:
		return false
	var data := {
		"party": party.map(func(c: Combatant) -> Dictionary: return c.to_save_dict()),
		"roster": _roster_save(),
		"party_order": party.map(func(c: Combatant) -> String: return c.char_class),
		"starting_class": starting_class,
		"inventory": inventory.duplicate(),
		"dungeon_seeds": dungeon_seeds.duplicate(),
		"defeated_bosses": defeated_bosses.duplicate(),
		"story_flags": story_flags.duplicate(),
	}
	file.store_string(JSON.stringify(data))
	return true


func load_game(slot: int) -> bool:
	var path := _slot_path(slot)
	if not FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	_build_roster()
	# Saves from before 20a have only "party" (always all four); newer ones
	# also have the full roster and who's in the party, in order.
	var saved_roster: Dictionary = parsed.get("roster", {})
	for data: Dictionary in parsed.get("party", []):
		var cls := String(data.get("char_class", ""))
		if roster.has(cls) and not saved_roster.has(cls):
			saved_roster[cls] = data
	for cls: String in saved_roster:
		if roster.has(cls):
			roster[cls].load_save_dict(saved_roster[cls])
	var order: Array = parsed.get("party_order", saved_roster.keys())
	party = []
	for cls in order:
		if roster.has(cls):
			party.append(roster[cls])
	starting_class = String(parsed.get("starting_class", ""))
	var save_inventory: Dictionary = parsed.get("inventory", {})
	inventory.clear()
	for item_name in save_inventory:
		inventory[item_name] = int(save_inventory[item_name])
	var save_dungeon_seeds: Dictionary = parsed.get("dungeon_seeds", {})
	dungeon_seeds.clear()
	for location in save_dungeon_seeds:
		dungeon_seeds[location] = int(save_dungeon_seeds[location])
	var save_defeated_bosses: Dictionary = parsed.get("defeated_bosses", {})
	defeated_bosses.clear()
	for location in save_defeated_bosses:
		defeated_bosses[location] = bool(save_defeated_bosses[location])
	var save_story_flags: Dictionary = parsed.get("story_flags", {})
	story_flags.clear()
	for flag in save_story_flags:
		story_flags[flag] = bool(save_story_flags[flag])
	party_loaded.emit()
	return true


## Lazily rolls a seed the first time a dungeon is entered, then reuses it
## forever after (persisted below) so backtracking always finds the same
## generated layout. Uses the global RNG for this one-time pick only - the
## generator itself must never touch it, or regeneration would desync from
## whatever else has consumed global randomness in between.
func get_dungeon_seed(location: String) -> int:
	if not dungeon_seeds.has(location):
		dungeon_seeds[location] = randi()
	return dungeon_seeds[location]


func _roster_save() -> Dictionary:
	var out := {}
	for cls: String in roster:
		out[cls] = roster[cls].to_save_dict()
	return out


func has_flag(flag: String) -> bool:
	return story_flags.get(flag, false)


func save_exists(slot: int) -> bool:
	return FileAccess.file_exists(_slot_path(slot))


func _slot_path(slot: int) -> String:
	return SAVE_DIR + "slot_%d.json" % slot
