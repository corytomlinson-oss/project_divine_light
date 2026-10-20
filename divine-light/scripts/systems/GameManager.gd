extends Node

signal party_loaded

const SAVE_DIR: String = "user://saves/"
const SAVE_SLOTS: int = 3
# Slot 0 is the autosave (Milestone 22a): its own file, so it never overwrites
# one of the three manual slots.
const AUTOSAVE_SLOT: int = 0
# The suspend save (Milestone 22b): written when the app closes or goes to the
# background, offered as Resume on the title, deleted once used (or when a new
# game starts or another save is loaded) - single use, as the design doc says.
const SUSPEND_PATH: String = SAVE_DIR + "suspend.json"

# Everyone who exists in the story (Milestone 20a), by class name, and the
# party: who's actually with you, in the order they joined. A new game starts
# with only the chosen character; the others join when rescued (recruit()).
const CLASSES: Array = ["Vael", "Ryn", "Lyra", "Silas"]
var roster: Dictionary = {}
var party: Array = []
var starting_class: String = ""
var gold: int = 0
# Which overworld entrance to appear at next (Milestone 20a): set when leaving
# a town or dungeon, e.g. "cathedral", "verdance".
var arrival: String = ""
var inventory: Dictionary = {}
var current_location: String = "overworld"
var current_scene_path: String = "res://scenes/overworld/Overworld.tscn"
var pending_spawn_position: Vector2 = Vector2.ZERO
var has_pending_spawn: bool = false
var dungeon_seeds: Dictionary = {}
var pending_boss_battle: bool = false
var defeated_bosses: Dictionary = {}
# The auto-map: the cells of each dungeon the player has seen, keyed by
# location like dungeon_seeds (location -> {Vector2i: true}). Saved as flat
# [x0, y0, x1, y1, ...] lists.
var explored: Dictionary = {}
# Treasure chests already opened (Milestone 23a), same shape and save format
# as `explored`: location -> {Vector2i: true}.
var opened_chests: Dictionary = {}
# A mimic fight in progress (23b): {location, cell} of the chest that bit, so
# the dungeon can settle it on the way back (won: it's opened; fled: it waits).
var pending_mimic: Dictionary = {}
# Whether the last battle ended in victory (set by Battle.gd).
var last_battle_won: bool = false
# Set by the pause menu before it opens another screen (Equip), so the map
# reopens the menu when that screen returns to it.
var reopen_pause_menu: bool = false
# Story flags set by cutscenes ("set met_frank"), saved with the game, so a
# scene can check whether something already happened (Milestone 19a).
var story_flags: Dictionary = {}
# Act I side quests (Milestone 24, see Quests.gd): quest id -> stage, and the
# key items they hand out (name -> true). Both saved.
var quests: Dictionary = {}
var key_items: Dictionary = {}
# A quest hunt in progress: the HUNTS id, so the overworld can settle it on
# the way back (won: the step's done; fled: it's still out there).
var pending_hunt: String = ""
# Development/testing: when set (a list of enemy dicts, EnemyData format), the
# next battle fights exactly this group - bosses too, via "is_boss" and
# "phase_hp_thresholds" - then it's cleared (Milestone 20a).
var debug_encounter: Array = []
# Milestone 22a: play time (seconds, counted only while a game is running and
# not paused), and an autosave requested from somewhere that can't save yet -
# e.g. a boss win in the battle scene - which the next map performs once the
# player is standing in it (autosave_if_pending(), called by Player).
var play_time: float = 0.0
var in_game: bool = false
var autosave_pending: bool = false
# The game as it was when the current battle began, plus the enemies it began
# with (22b): suspending mid-fight saves this, so resuming restarts that fight.
# Cleared when the battle ends.
var battle_snapshot: Dictionary = {}


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
	discard_suspend()
	play_time = 0.0
	in_game = true
	autosave_pending = false
	_build_roster()
	party = [roster[cls]]
	starting_class = cls
	inventory = {"Potion": 3, "Antidote": 1}
	story_flags = {}
	quests = {}
	key_items = {}
	pending_hunt = ""
	dungeon_seeds = {}
	defeated_bosses = {}
	explored = {}
	opened_chests = {}
	pending_mimic = {}
	gold = 0
	arrival = ""
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


func _process(delta: float) -> void:
	# This autoload pauses with the tree, so menus that pause the game (and
	# the title screen, where in_game is false) don't count.
	if in_game:
		play_time += delta


## Saves to `slot` (1-3, or AUTOSAVE_SLOT). Records where the party is - the
## current map, and the player's position on it - so loading puts you back
## there (Milestone 22a). Never called from a battle; autosaves after a boss
## wait for the map (autosave_pending).
func save_game(slot: int) -> bool:
	if slot < 0 or slot > SAVE_SLOTS:
		return false
	return _write(_slot_path(slot), _save_data())


func _write(path: String, data: Dictionary) -> bool:
	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	return true


## Everything a save holds, as of now.
func _save_data() -> Dictionary:
	var data := {
		"party": party.map(func(c: Combatant) -> Dictionary: return c.to_save_dict()),
		"roster": _roster_save(),
		"party_order": party.map(func(c: Combatant) -> String: return c.char_class),
		"starting_class": starting_class,
		"gold": gold,
		"inventory": inventory.duplicate(),
		"dungeon_seeds": dungeon_seeds.duplicate(),
		"defeated_bosses": defeated_bosses.duplicate(),
		"explored": _cells_save(explored),
		"opened_chests": _cells_save(opened_chests),
		"story_flags": story_flags.duplicate(),
		"quests": quests.duplicate(),
		"key_items": key_items.keys(),
		"scene": current_scene_path,
		"location": location_name(current_location),
		"location_id": current_location,
		"play_time": play_time,
		"saved_at": int(Time.get_unix_time_from_system()),
	}
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		data["position"] = [player.position.x, player.position.y]
	elif has_pending_spawn:
		# In a battle: where the party stood on the map when it began.
		data["position"] = [pending_spawn_position.x, pending_spawn_position.y]
	return data


func autosave() -> void:
	save_game(AUTOSAVE_SLOT)


## Performs an autosave someone asked for earlier (autosave_pending), now
## that a map is loaded and the player is placed in it.
func autosave_if_pending() -> void:
	if autosave_pending and in_game:
		autosave_pending = false
		autosave()


## A place's name for the save screen.
static func location_name(location: String) -> String:
	var id := location.trim_suffix("_escape")
	if ActOne.DUNGEONS.has(id):
		return ActOne.DUNGEONS[id]["name"]
	match id:
		"overworld": return "Forest Heartlands"
		"verdance": return "Verdance"
		"edenmere": return "Edenmere"
	return id.capitalize()


## What the save screen shows for a slot: the party (class + level, in
## order), location, play time and gold. {} when the slot is empty.
func slot_summary(slot: int) -> Dictionary:
	var path := _slot_path(slot)
	if not FileAccess.file_exists(path):
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	var levels := {}
	var roster_data: Dictionary = parsed.get("roster", {})
	for data: Dictionary in parsed.get("party", []):
		levels[String(data.get("char_class", ""))] = int(data.get("level", 1))
	var order: Array = parsed.get("party_order", levels.keys())
	var members: Array = []
	for cls in order:
		var lv: int = levels.get(cls, int(roster_data.get(cls, {}).get("level", 1)))
		members.append({"class": String(cls), "level": lv})
	return {
		"party": members,
		"location": String(parsed.get("location", "Forest Heartlands")),
		"play_time": float(parsed.get("play_time", 0.0)),
		"gold": int(parsed.get("gold", 0)),
	}


func any_save_exists() -> bool:
	for slot in range(0, SAVE_SLOTS + 1):
		if save_exists(slot):
			return true
	return false


func load_game(slot: int) -> bool:
	var path := _slot_path(slot)
	if not FileAccess.file_exists(path):
		return false
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	discard_suspend()  # loading another save abandons a suspended game
	_apply(parsed)
	return true


func _apply(parsed: Dictionary) -> void:
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
	gold = int(parsed.get("gold", 0))
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
	explored = _cells_load(parsed.get("explored", {}))
	opened_chests = _cells_load(parsed.get("opened_chests", {}))
	var save_story_flags: Dictionary = parsed.get("story_flags", {})
	story_flags.clear()
	for flag in save_story_flags:
		story_flags[flag] = bool(save_story_flags[flag])
	var save_quests: Dictionary = parsed.get("quests", {})
	quests.clear()
	for id in save_quests:
		quests[id] = int(save_quests[id])
	key_items.clear()
	for item_name in parsed.get("key_items", []):
		key_items[String(item_name)] = true
	pending_hunt = ""
	# Where the save was made (Milestone 22a); older saves land on the overworld.
	current_scene_path = String(parsed.get("scene", "res://scenes/overworld/Overworld.tscn"))
	var pos: Array = parsed.get("position", [])
	has_pending_spawn = pos.size() == 2
	if has_pending_spawn:
		pending_spawn_position = Vector2(float(pos[0]), float(pos[1]))
	current_location = String(parsed.get("location_id", current_location))
	play_time = float(parsed.get("play_time", 0.0))
	in_game = true
	autosave_pending = false
	battle_snapshot = {}
	arrival = ""
	party_loaded.emit()


# ---------------------------------------------------------------- suspend (22b)

## Closing the window / the app, the Home button (the app going to the
## background) and Android's back-out all write the suspend save first. When
## a backgrounded app comes back, the game is still running, so the suspend
## is dropped again (it'll be rewritten next time).
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_GO_BACK_REQUEST:
			suspend()
		NOTIFICATION_APPLICATION_RESUMED:
			discard_suspend()


## Saves the game exactly where it is - mid-dungeon, mid-town, or (as the
## state when the fight began, plus its enemies) mid-battle. Nothing to do on
## the title or class select.
func suspend() -> void:
	if not in_game:
		return
	var in_battle := get_tree().current_scene != null and get_tree().current_scene.name == "Battle"
	var data: Dictionary = battle_snapshot if in_battle and not battle_snapshot.is_empty() else _save_data()
	_write(SUSPEND_PATH, data)


## Called by Battle as a fight begins: remembers the game as it is now and the
## enemies it's facing, for a suspend during the fight.
func begin_battle(encounter: Array) -> void:
	battle_snapshot = _save_data()
	battle_snapshot["battle"] = encounter


func has_suspend() -> bool:
	return FileAccess.file_exists(SUSPEND_PATH)


func discard_suspend() -> void:
	if FileAccess.file_exists(SUSPEND_PATH):
		DirAccess.remove_absolute(SUSPEND_PATH)


## Loads the suspend save and deletes it. Returns the scene to go to: the map,
## or the battle scene when it was made mid-fight (that fight restarts).
func resume() -> String:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(SUSPEND_PATH))
	discard_suspend()
	if typeof(parsed) != TYPE_DICTIONARY:
		return ""
	_apply(parsed)
	if parsed.has("battle"):
		debug_encounter = parsed["battle"]
		return "res://scenes/battle/Battle.tscn"
	return current_scene_path


## Lazily rolls a seed the first time a dungeon is entered, then reuses it
## forever after (persisted below) so backtracking always finds the same
## generated layout. Uses the global RNG for this one-time pick only - the
## generator itself must never touch it, or regeneration would desync from
## whatever else has consumed global randomness in between.
## Auto-map: records cells of `location` as seen.
func mark_explored(location: String, cells: Array) -> void:
	if not explored.has(location):
		explored[location] = {}
	var seen: Dictionary = explored[location]
	for cell in cells:
		seen[cell] = true


func is_explored(location: String, cell: Vector2i) -> bool:
	return explored.has(location) and explored[location].has(cell)


func is_chest_opened(location: String, cell: Vector2i) -> bool:
	return opened_chests.has(location) and opened_chests[location].has(cell)


func mark_chest_opened(location: String, cell: Vector2i) -> void:
	if not opened_chests.has(location):
		opened_chests[location] = {}
	opened_chests[location][cell] = true


## location -> {Vector2i: true} as location -> flat [x0, y0, x1, y1, ...].
func _cells_save(by_location: Dictionary) -> Dictionary:
	var data := {}
	for location in by_location:
		var flat: Array = []
		for cell in by_location[location]:
			flat.append(cell.x)
			flat.append(cell.y)
		data[location] = flat
	return data


func _cells_load(data: Dictionary) -> Dictionary:
	var by_location := {}
	for location in data:
		var flat: Array = data[location]
		var cells := {}
		for i in range(0, flat.size() - 1, 2):
			cells[Vector2i(int(flat[i]), int(flat[i + 1]))] = true
		by_location[location] = cells
	return by_location


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
	if slot == AUTOSAVE_SLOT:
		return SAVE_DIR + "autosave.json"
	return SAVE_DIR + "slot_%d.json" % slot
