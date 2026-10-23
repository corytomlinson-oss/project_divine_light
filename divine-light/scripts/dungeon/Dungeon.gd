extends Node2D

# A generated Act I dungeon (Milestone 13b's generator; story variants from
# Milestone 20a). The same layout plays one of two ways:
#
#   escape - the player's own starting dungeon: they wake in a cell in the
#            deepest room, free Frank from the captive room partway out, and
#            must beat the escape warden guarding the only exit.
#   rescue - someone else's dungeon: the captive is held in the deepest room,
#            guarded by the dungeon's boss; beat it, reach them, they join.
#
# Location ids: "<dungeon>_escape" for the escape variant (its own encounter
# table, boss and seed), "<dungeon>" for the rescue. Story beats are cutscene
# files in data/cutscenes/.
#
# Act II dungeons (Milestone 25a; entries with "floors") have several floors
# joined by stairs, one per zone in the design doc. Each floor is its own
# layout from the dungeon's seed (+ floor * FLOOR_SEED_STEP) and its own
# location id ("<dungeon>" for the first, "<dungeon>_f<n>" after), so the map,
# chests and "quiet" state are per floor. Stairs down sit where Act I puts
# the boss; a floor can have a guard standing on its stairs (a visible
# single-enemy fight, no escape); the last floor has the boss, and beating it
# cleanses the dungeon's kingdom (Kingdoms.cleanse) and sends you outside,
# where the region's color washes back. GameManager.dungeon_floor says which
# floor you're on (saved).

const FLOOR_COORDS := Vector2i(0, 0)
const WALL_COORDS := Vector2i(1, 0)
const DOOR_COORDS := Vector2i(2, 0)
const CAPTIVE_COORDS := Vector2i(3, 0)
const BOSS_COORDS := Vector2i(4, 0)
const OVERWORLD_SCENE_PATH := "res://scenes/overworld/Overworld.tscn"
const ACT_ONE_END_SCENE := "res://data/cutscenes/act_one_end.scene"
# Treasure (Milestones 23a/23b). chests.png frames: wooden closed/open,
# gilded closed/open, mimic (closed), locked (closed); spring.png: two shimmer
# frames and a spent one.
const CHEST_SHEET := preload("res://assets/sprites/chests.png")
const SPRING_SHEET := preload("res://assets/sprites/spring.png")
const CLOSED_FRAME := {"plain": 0, "gilded": 2, "mimic": 4, "locked": 5}
const SEALED_TEXT := "narrate A seal of corruption binds this chest shut. It should break once the warden falls."
const LOCKED_TEXT := "narrate It's locked tight. Someone with nimble fingers might be able to pick it."
const PICKED_TEXT := "narrate Silas kneels at the lock. A few twists of a pin... click."
const MIMIC_TEXT := "narrate The lid creaks open... and the chest bares its teeth!"
const SPRING_TEXT := "narrate Clear water wells up, glowing faintly. The party drinks and feels whole again."
const SPENT_TEXT := "narrate The spring lies still and dark. Its power is spent."
const QUIET_TEXT := "narrate The halls have fallen quiet. Nothing stirs here anymore."
const STAIRS_SHEET := preload("res://assets/sprites/stairs.png")  # down, up
const FLOOR_SEED_STEP := 1000003
const STAIRS_MARKER := Color(0.6, 0.8, 1.0)

# Per-dungeon generation templates (13b) and story scenes (20a).
const DUNGEONS := {
	"cathedral": {
		"template": {"min_rooms": 5, "max_rooms": 8, "room_min_size": Vector2i(10, 7), "room_max_size": Vector2i(15, 10), "side_rooms": 2},
		"scene": "res://scenes/dungeon/CathedralDungeon.tscn",
		"music": "dungeon",
		"wake_scene": "res://data/cutscenes/cathedral_wake.scene",
		"frank_scene": "res://data/cutscenes/cathedral_frank.scene",
		"escaped_scene": "res://data/cutscenes/cathedral_escaped.scene",
		"rescue_scene": "res://data/cutscenes/cathedral_rescue.scene",
	},
	"monastery": {
		"template": {"min_rooms": 5, "max_rooms": 8, "room_min_size": Vector2i(10, 7), "room_max_size": Vector2i(15, 10), "side_rooms": 2},
		"scene": "res://scenes/dungeon/MonasteryDungeon.tscn",
		"music": "monastery",
		"wake_scene": "res://data/cutscenes/monastery_wake.scene",
		"frank_scene": "res://data/cutscenes/monastery_frank.scene",
		"escaped_scene": "res://data/cutscenes/monastery_escaped.scene",
		"rescue_scene": "res://data/cutscenes/monastery_rescue.scene",
	},
	"observatory": {
		"template": {"min_rooms": 5, "max_rooms": 8, "room_min_size": Vector2i(10, 7), "room_max_size": Vector2i(15, 10), "side_rooms": 2},
		"scene": "res://scenes/dungeon/ObservatoryDungeon.tscn",
		"music": "observatory",
		"wake_scene": "res://data/cutscenes/observatory_wake.scene",
		"frank_scene": "res://data/cutscenes/observatory_frank.scene",
		"escaped_scene": "res://data/cutscenes/observatory_escaped.scene",
		"rescue_scene": "res://data/cutscenes/observatory_rescue.scene",
	},
	"guild": {
		"template": {"min_rooms": 5, "max_rooms": 8, "room_min_size": Vector2i(10, 7), "room_max_size": Vector2i(15, 10), "side_rooms": 2},
		"scene": "res://scenes/dungeon/GuildDungeon.tscn",
		"music": "guild",
		"wake_scene": "res://data/cutscenes/guild_wake.scene",
		"frank_scene": "res://data/cutscenes/guild_frank.scene",
		"escaped_scene": "res://data/cutscenes/guild_escaped.scene",
		"rescue_scene": "res://data/cutscenes/guild_rescue.scene",
	},
	# Act II (25a: a stand-in to prove the floors work; 25b builds the real
	# Frozen Citadel on top - its template, guard, boss and look).
	"frozen_citadel": {
		"template": {"min_rooms": 5, "max_rooms": 7, "room_min_size": Vector2i(10, 7), "room_max_size": Vector2i(15, 10), "side_rooms": 1},
		"scene": "res://scenes/dungeon/FrozenCitadel.tscn",
		"music": "dungeon",
		"floors": 4,
		"kingdom": "nordveil",
		"boss": "frozen_sovereign",
		"guards": {2: EnemyData.FROST_WARDEN},
		"set_floor": 2,
		"region_scene": "res://scenes/overworld/Tundra.tscn",
	},
}

const TAG_TO_COORDS := {
	DungeonGenerator.FLOOR: FLOOR_COORDS,
	DungeonGenerator.WALL: WALL_COORDS,
	DungeonGenerator.DOOR: DOOR_COORDS,
	DungeonGenerator.CAPTIVE_MARKER: CAPTIVE_COORDS,
	DungeonGenerator.BOSS_TRIGGER: BOSS_COORDS,
}

## Which ActOne dungeon this scene is.
@export var dungeon_id := "cathedral"

@onready var _tile_map: TileMapLayer = $TileMapLayer
@onready var _player: Node2D = $TileMapLayer/Player

var _escape := false
var _data: Dictionary
var _exit_cell: Vector2i
var _captive_cell: Vector2i
var _room_rects: Array = []  # Rect2i per room, for the auto-map
var _chests: Dictionary = {}  # cell -> {cell, kind, reward, sprite}
var _springs: Dictionary = {}  # cell -> Sprite2D
# Act II floors (25a)
var _floors := 1
var _floor := 0
var _stairs_up := Vector2i(-9999, -9999)
var _stairs_down := Vector2i(-9999, -9999)
var _guard: Sprite2D = null
var _settled := false


func _ready() -> void:
	_data = DUNGEONS[dungeon_id]
	_escape = ActOne.is_start_dungeon(dungeon_id)
	_floors = int(_data.get("floors", 1))
	_floor = clampi(GameManager.dungeon_floor, 0, _floors - 1) if _floors > 1 else 0
	GameManager.current_location = dungeon_id + ("_escape" if _escape else "") + ("_f%d" % _floor if _floor > 0 else "")
	# The boss a fight on this floor would be (Act II names it; Act I goes by
	# location in Battle).
	GameManager.pending_boss_id = _data.get("boss", "") if _is_last_floor() else ""
	GameManager.current_scene_path = _data["scene"]
	# Town shrines work once per dungeon visit (20d; Nordveil's too, 25b).
	for shrine_flag in ["edenmere_shrine_used", "nordveil_shrine_used"]:
		GameManager.story_flags.erase(shrine_flag)
	Music.play(_data.get("music", "dungeon"), "dungeon")  # each dungeon's own theme (Milestone 21)
	# Characters lower on screen draw in front (a captive standing just above
	# the player, cutscene actors walking past each other).
	_tile_map.y_sort_enabled = true
	_add_backdrop()
	_generate_and_build()
	_settle_mimic()
	_settled = true
	if _floors > 1:
		_play_act_two_story()
	else:
		_play_arrival_story()
	# Not while an escape is about to whisk you outside (its scene plays first).
	if not (_escape and _boss_defeated() and not ActOne.is_cleared(dungeon_id)) and not _kingdom_freed_now():
		_announce_if_quiet()


func _boss_defeated() -> bool:
	return GameManager.defeated_bosses.get(GameManager.current_location, false)


func _is_last_floor() -> bool:
	return _floor == _floors - 1


func _generate_and_build() -> void:
	var seed_value: int = GameManager.get_dungeon_seed(GameManager.current_location)
	if _floors > 1:
		seed_value = GameManager.get_dungeon_seed(dungeon_id) + _floor * FLOOR_SEED_STEP
	var layout: Dictionary = DungeonGenerator.generate(_data["template"], seed_value)
	var tiles: Dictionary = layout["tiles"]
	var deep_door: Vector2i = layout["exit_cell"]
	var spawn: Vector2i = layout["player_spawn"]
	var boss_cell: Vector2i = layout["boss_trigger_cell"]
	_room_rects = layout["room_rects"]

	# Both variants: the deep room's door is gone (that room is a cell), so the
	# entrance is the only way in or out.
	tiles[deep_door] = DungeonGenerator.FLOOR
	_exit_cell = layout["entrance_cell"]
	if _floors > 1:
		spawn = _build_floor(layout, tiles)
		_captive_cell = Vector2i(-9999, -9999)
	elif _escape:
		# The player's cell is deep inside; the warden waits by the exit.
		tiles[boss_cell] = DungeonGenerator.FLOOR
		tiles[spawn] = DungeonGenerator.BOSS_TRIGGER
		var swap := spawn
		spawn = boss_cell
		boss_cell = swap
		_captive_cell = layout["captive_cell"]  # Frank's cell, partway out
		if GameManager.has_flag("met_frank"):
			tiles[_captive_cell] = DungeonGenerator.FLOOR
	else:
		# The captive is held in the deepest room, behind the boss.
		tiles[layout["captive_cell"]] = DungeonGenerator.FLOOR
		_captive_cell = deep_door
		tiles[_captive_cell] = DungeonGenerator.CAPTIVE_MARKER
		if ActOne.is_cleared(dungeon_id):
			tiles[_captive_cell] = DungeonGenerator.FLOOR
	if _boss_defeated() and tiles.get(boss_cell, "") == DungeonGenerator.BOSS_TRIGGER:
		tiles[boss_cell] = DungeonGenerator.FLOOR

	for cell in tiles.keys():
		_tile_map.set_cell(cell, 0, TAG_TO_COORDS[tiles[cell]])
	if _floors > 1:
		_place_stairs()
	else:
		_place_captive()
	_place_treasure(layout, seed_value)

	# A saved spot that isn't floor anymore (a save from before the rooms got
	# bigger lands somewhere else in the new layout) falls back to the entrance.
	var saved_cell: Vector2i = _tile_map.local_to_map(GameManager.pending_spawn_position)
	if GameManager.has_pending_spawn and tiles.get(saved_cell, "") == DungeonGenerator.FLOOR \
			and not is_blocked(saved_cell):
		_player.snap_to(GameManager.pending_spawn_position)
	else:
		_player.snap_to(_tile_map.map_to_local(spawn))
	GameManager.has_pending_spawn = false
	on_player_moved(_tile_map.local_to_map(_player.position))


## An Act II floor (25a): stairs up where the entrance door would be (past
## the first floor), stairs down where Act I puts the boss (before the last),
## no captive. Returns where to stand on arriving.
func _build_floor(layout: Dictionary, tiles: Dictionary) -> Vector2i:
	var boss_cell: Vector2i = layout["boss_trigger_cell"]
	tiles[layout["captive_cell"]] = DungeonGenerator.FLOOR
	if _floor > 0:
		_stairs_up = _exit_cell
		tiles[_exit_cell] = DungeonGenerator.FLOOR
	if not _is_last_floor():
		_stairs_down = boss_cell
		tiles[boss_cell] = DungeonGenerator.FLOOR
	elif _boss_defeated():
		tiles[boss_cell] = DungeonGenerator.FLOOR
	# Came up from below: beside the stairs down. Otherwise by the entrance.
	if GameManager.arrival == "stairs_up" and not _is_last_floor():
		GameManager.arrival = ""
		for d: Vector2i in [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
			if tiles.get(boss_cell + d, "") == DungeonGenerator.FLOOR:
				return boss_cell + d
	GameManager.arrival = ""
	return layout["player_spawn"]


func _place_stairs() -> void:
	if _floor > 0:
		_add_sprite(STAIRS_SHEET, 2, _stairs_up).frame = 1
	if not _is_last_floor():
		_add_sprite(STAIRS_SHEET, 2, _stairs_down).frame = 0
		var guard: Dictionary = _data.get("guards", {}).get(_floor, {})
		if not guard.is_empty() and not _boss_defeated():
			_guard = _guard_sprite(guard)


## A floor's guard stands on its stairs down (its battle sprite, or a stand-in).
func _guard_sprite(guard: Dictionary) -> Sprite2D:
	var sprite_name: String = String(guard["name"]).to_lower().replace(" ", "_")
	var path := "res://assets/sprites/enemies/%s.png" % sprite_name
	if not ResourceLoader.exists(path):
		path = "res://assets/sprites/enemies/%s.png" % EnemyData.STAND_INS.get(guard["name"], {}).get("sprite", "hollow_warden")
	var sprite := Sprite2D.new()
	sprite.texture = load(path)
	sprite.hframes = 2
	sprite.offset.y = 8 - sprite.texture.get_height() / 2.0
	sprite.position = _tile_map.map_to_local(_stairs_down)
	sprite.modulate = guard.get("tint", Color.WHITE)
	_tile_map.add_child(sprite)
	var bob := Timer.new()
	bob.wait_time = 0.5
	bob.autostart = true
	bob.timeout.connect(func() -> void:
		if is_instance_valid(sprite):
			sprite.frame = 1 - sprite.frame)
	add_child(bob)
	return sprite


func _guard_fight() -> void:
	var guard: Dictionary = _data["guards"][_floor].duplicate()
	guard["is_boss"] = true  # no running; beating it marks this floor's boss down
	Sfx.play("menu_cancel")
	await Cutscene.play_text(String(guard.get("tell", "narrate The guardian of the stairs moves to bar your way!")))
	_player.start_battle_against([guard])


## Darkness behind the map, so the space outside the walls reads as solid
## black rather than the engine's grey clear color.
func _add_backdrop() -> void:
	var layer := CanvasLayer.new()
	layer.layer = -1
	var dark := ColorRect.new()
	dark.color = Color(0.03, 0.02, 0.05)
	dark.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dark)
	add_child(layer)


## The captive stands just behind their rune: Frank in the escape variant (until
## freed), the dungeon's captive in the rescue (until rescued).
func _place_captive() -> void:
	var who := ""
	if _escape and not GameManager.has_flag("met_frank"):
		who = "frank"
	elif not _escape and not ActOne.is_cleared(dungeon_id):
		who = String(ActOne.DUNGEONS[dungeon_id]["captive"]).to_lower()
	if who == "":
		return
	var npc := Cutscene.make_character(who)
	npc.position = _tile_map.map_to_local(_captive_cell + Vector2i(0, -1))
	npc.set_meta("actor_id", who)
	npc.add_to_group("npc")
	_tile_map.add_child(npc)


# ---------------------------------------------------------------- treasure

## The dungeon's treasure (23a/23b): its captive's armor set in gilded chests,
## plain chests (one may be a mimic), and in the side rooms a healing spring
## or a vault of rich chests, some locked. All of it comes from the seed.
func _place_treasure(layout: Dictionary, seed_value: int) -> void:
	var set_items: Array = Loot.DUNGEON_SETS.get(dungeon_id, [])
	if _floors > 1 and _floor != int(_data.get("set_floor", _floors - 1)):
		set_items = []  # Act II: the armor set waits on its own floor
	# Mimics only where there's a party to fight them (not the solo escape).
	var treasure := DungeonGenerator.place_treasure(layout, set_items, seed_value, not _escape)
	for chest: Dictionary in treasure["chests"]:
		chest["sprite"] = _add_sprite(CHEST_SHEET, 6, chest["cell"])
		_chests[chest["cell"]] = chest
		_show_chest(chest)
	for cell: Vector2i in treasure["springs"]:
		_springs[cell] = _add_sprite(SPRING_SHEET, 3, cell)
	_show_springs()
	if not _springs.is_empty():
		var shimmer := Timer.new()
		shimmer.wait_time = 0.45
		shimmer.autostart = true
		shimmer.timeout.connect(_show_springs)
		add_child(shimmer)


func _add_sprite(sheet: Texture2D, frames: int, cell: Vector2i) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = sheet
	sprite.hframes = frames
	sprite.position = _tile_map.map_to_local(cell)
	_tile_map.add_child(sprite)
	return sprite


func _opened(cell: Vector2i) -> bool:
	return GameManager.is_chest_opened(GameManager.current_location, cell)


func _show_chest(chest: Dictionary) -> void:
	if _opened(chest["cell"]):
		chest["sprite"].frame = 3 if chest["kind"] == "gilded" else 1
	else:
		chest["sprite"].frame = CLOSED_FRAME[chest["kind"]]


func _show_springs() -> void:
	var tick := int(Time.get_ticks_msec() / 450) % 2
	for cell: Vector2i in _springs:
		_springs[cell].frame = 2 if _opened(cell) else tick


## In your own starting dungeon the set pieces are sealed until the warden
## falls - the full set would make that solo fight a walkover. Come back for
## them after the escape.
func _sealed(chest: Dictionary) -> bool:
	return chest["kind"] == "gilded" and _escape and not _boss_defeated()


func is_blocked(cell: Vector2i) -> bool:
	return _chests.has(cell) or _springs.has(cell) or (_guard != null and cell == _stairs_down)


## Stairs are doors (Player.gd asks): up always, down once its guard is gone.
func is_door(cell: Vector2i) -> bool:
	return cell == _stairs_up or (cell == _stairs_down and _guard == null)


## A on the tile you're facing: open a chest, drink from a spring.
func interact(cell: Vector2i, _facing: String) -> void:
	if _guard != null and cell == _stairs_down:
		await _guard_fight()
		return
	if _springs.has(cell):
		await _drink(cell)
		return
	if not _chests.has(cell) or _opened(cell):
		return
	var chest: Dictionary = _chests[cell]
	if _sealed(chest):
		await Cutscene.play_text(SEALED_TEXT)
		return
	match chest["kind"]:
		"locked":
			if not GameManager.has_member("Silas"):
				await Cutscene.play_text(LOCKED_TEXT)
				return
			await Cutscene.play_text(PICKED_TEXT)
		"mimic":
			Sfx.play("menu_cancel")
			await Cutscene.play_text(MIMIC_TEXT)
			GameManager.pending_mimic = {"location": GameManager.current_location, "cell": cell}
			_player.start_battle_against([EnemyData.MIMIC])
			return
	_open(chest)
	await Cutscene.play_text("narrate " + Loot.give(chest["reward"]))
	await _announce_if_quiet()


func _open(chest: Dictionary) -> void:
	GameManager.mark_chest_opened(GameManager.current_location, chest["cell"])
	_show_chest(chest)
	Sfx.play("chest")


## Back from a mimic fight: beaten, it's just a chest with its hoard inside;
## fled from, it's still sitting there waiting.
func _settle_mimic() -> void:
	var pending := GameManager.pending_mimic
	GameManager.pending_mimic = {}
	if pending.get("location", "") != GameManager.current_location or not _chests.has(pending.get("cell")):
		return
	if not GameManager.last_battle_won:
		return
	var chest: Dictionary = _chests[pending["cell"]]
	_open(chest)
	await _after_transition()
	await Cutscene.play_text("narrate The mimic's jaws fall slack. Inside, its hoard: " + Loot.give(chest["reward"]).trim_prefix("Found "))
	await _announce_if_quiet()


# ------------------------------------------------------------ safety (Cory, 2026-10-16)

## Boss beaten and every chest open (locked ones and the mimic included; the
## spring can be saved for later): no more random fights here.
func is_safe() -> bool:
	return _dungeon_done() and _chests.keys().all(func(cell: Vector2i) -> bool: return _opened(cell))


## Act I: this dungeon's boss is down. Act II (every floor alike): its kingdom
## is free - a floor's guard alone doesn't count.
func _dungeon_done() -> bool:
	if _floors > 1:
		return Kingdoms.is_cleansed(_data.get("kingdom", ""))
	return _boss_defeated()


## With the boss beaten, fights come a fifth as often (every 50-100 steps
## instead of 10-20).
func encounter_steps() -> Vector2i:
	return Vector2i(50, 100) if _dungeon_done() else Vector2i(10, 20)


## Once per dungeon, the moment it becomes safe.
func _announce_if_quiet() -> void:
	var flag := "quiet_" + GameManager.current_location
	if not is_safe() or GameManager.has_flag(flag):
		return
	GameManager.story_flags[flag] = true
	await _after_transition()
	while Cutscene.is_playing():
		await get_tree().process_frame
	await Cutscene.play_text(QUIET_TEXT)


## A healing spring (23b): restores everyone still standing, once - like an
## inn, it doesn't revive (the design doc keeps that to Frank and items).
func _drink(cell: Vector2i) -> void:
	if _opened(cell):
		await Cutscene.play_text(SPENT_TEXT)
		return
	GameManager.mark_chest_opened(GameManager.current_location, cell)
	for m: Combatant in GameManager.party:
		if not m.is_ko:
			m.hp = m.max_hp
			m.mp = m.max_mp
	Sfx.play("heal")
	_show_springs()
	await Cutscene.play_text(SPRING_TEXT)


## Called by Player.gd on stepping onto the captive rune.
func on_captive_tile(_cell: Vector2i) -> void:
	if _escape:
		if not GameManager.has_flag("met_frank"):
			await Cutscene.play(_data["frank_scene"])
			_tile_map.set_cell(_captive_cell, 0, FLOOR_COORDS)
		return
	if ActOne.is_cleared(dungeon_id):
		return
	if not _boss_defeated():
		# Reaching the captive means facing their jailer first.
		_player.start_boss_battle()
		return
	await Cutscene.play(_data["rescue_scene"])
	_tile_map.set_cell(_captive_cell, 0, FLOOR_COORDS)
	GameManager.autosave()  # a rescue (22a)
	# The fourth hero rescued: Act I ends here (20d). Afterwards the party is
	# back outside, free to roam until Act II exists.
	if ActOne.all_cleared() and not GameManager.has_flag("act_one_complete"):
		GameManager.story_flags["act_one_complete"] = true
		await Cutscene.play(ACT_ONE_END_SCENE)
		await ActOneFinale.play(self)  # the bosses fall, then Act II's title
		GameManager.arrival = dungeon_id
		GameManager.autosave_pending = true  # saved on arrival outside (22a)
		Transition.change_scene(OVERWORLD_SCENE_PATH)


## Act II (25a): back from beating the last floor's boss, the kingdom is free.
## A line, an autosave, and out to the region, where the color washes back.
func _play_act_two_story() -> void:
	if not _kingdom_freed_now():
		return
	var kingdom: String = _data["kingdom"]
	Kingdoms.cleanse(kingdom)
	await _after_transition()
	var boss_name: String = EnemyData.BOSSES.get(_data.get("boss", ""), {}).get("name", "The boss")
	await Cutscene.play_text("narrate %s crumbles, and the Unraveling's hold on %s shatters with it." % [boss_name, Kingdoms.KINGDOMS[kingdom]["name"]])
	GameManager.arrival = dungeon_id
	GameManager.dungeon_floor = 0
	GameManager.autosave_pending = true  # saved on arrival outside (22a)
	Transition.change_scene(_data.get("region_scene", OVERWORLD_SCENE_PATH))


## The last floor's boss is down but its kingdom isn't marked free yet.
func _kingdom_freed_now() -> bool:
	return _floors > 1 and _is_last_floor() and _boss_defeated() and _data.has("kingdom") \
			and not Kingdoms.is_cleansed(_data["kingdom"])


## Story beats when the map loads: waking up (escape, first time), and the
## escape itself once the warden is beaten.
func _play_arrival_story() -> void:
	if not _escape:
		return
	if not GameManager.has_flag(dungeon_id + "_woke"):
		GameManager.story_flags[dungeon_id + "_woke"] = true
		await _after_transition()
		await Cutscene.play(_data["wake_scene"])
	elif _boss_defeated() and not ActOne.is_cleared(dungeon_id):
		await _after_transition()
		# Cleared before the scene, so {next} in it names the *next* dungeon.
		GameManager.story_flags["cleared_" + dungeon_id] = true
		await Cutscene.play(_data["escaped_scene"])
		GameManager.arrival = dungeon_id
		GameManager.autosave_pending = true  # saved on arrival outside (22a)
		Transition.change_scene(OVERWORLD_SCENE_PATH)


func _after_transition() -> void:
	if Transition.is_busy():
		await Transition.finished


# ---------------------------------------------------------------- auto-map

## Called by Player.gd on every tile: stepping into a room reveals all of it
## (walls included); in a corridor you see two tiles around you.
func on_player_moved(cell: Vector2i) -> void:
	var seen: Array = []
	for rect: Rect2i in _room_rects:
		if rect.has_point(cell):
			var walls := rect.grow(1)
			for x in range(walls.position.x, walls.end.x):
				for y in range(walls.position.y, walls.end.y):
					seen.append(Vector2i(x, y))
			seen.append_array(_corridor_stubs(rect))
	for dx in range(-2, 3):
		for dy in range(-2, 3):
			seen.append(cell + Vector2i(dx, dy))
	GameManager.mark_explored(GameManager.current_location, seen)
	# Walking up to a floor's guard starts the fight (not on arrival, so
	# coming back from a lost or fled fight doesn't throw you straight back in).
	if _settled and _guard != null and (cell - _stairs_down).length_squared() == 1:
		_guard_fight()


## A room's exits on the map (Cory, 2026-10-20: rooms were easy to miss when
## their doorway was a 1px notch): the first CORRIDOR_STUB tiles of every
## corridor leading out, with their walls, so unexplored ways out show as
## passages running off into the dark.
const CORRIDOR_STUB := 4

func _corridor_stubs(rect: Rect2i) -> Array:
	var cells: Array = []
	var walls := rect.grow(1)
	var frontier: Array = []
	for x in range(walls.position.x, walls.end.x):
		for y in range(walls.position.y, walls.end.y):
			var cell := Vector2i(x, y)
			if not rect.has_point(cell) and _tile_map.get_cell_atlas_coords(cell) == FLOOR_COORDS:
				frontier.append(cell)  # a doorway in the room's wall
	var visited := {}
	for step in CORRIDOR_STUB:
		var next: Array = []
		for cell: Vector2i in frontier:
			if visited.has(cell):
				continue
			visited[cell] = true
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					cells.append(cell + Vector2i(dx, dy))
			for d: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var n := cell + d
				if not walls.has_point(n) and _tile_map.get_cell_atlas_coords(n) == FLOOR_COORDS:
					next.append(n)
		frontier = next
	return cells


## For MapScreen's corner: how many chests are open here (the spring doesn't
## count, like the quiet rule), so you can tell a room was missed.
func map_note() -> String:
	var opened := _chests.keys().filter(func(c: Vector2i) -> bool: return _opened(c)).size()
	return "Chests %d/%d" % [opened, _chests.size()]


## For MapScreen: only explored cells are drawn, plus the exit, captive and
## boss once you've seen them.
func map_fog() -> bool:
	return true


## A dungeon's size is a secret until explored: the map zooms to fit what
## you've seen rather than the whole layout.
func map_fit_explored() -> bool:
	return true


func map_markers() -> Array:
	var kinds := {
		DOOR_COORDS: {"color": Color(0.95, 0.78, 0.3), "legend": "Exit"},
		CAPTIVE_COORDS: {"color": Color(0.7, 0.45, 1.0), "legend": "Captive"},
		BOSS_COORDS: {"color": Color(0.95, 0.25, 0.25), "legend": "Boss"},
	}
	var markers: Array = []
	for cell in GameManager.explored.get(GameManager.current_location, {}):
		var coords := _tile_map.get_cell_atlas_coords(cell)
		if cell == _stairs_up or cell == _stairs_down:
			if _guard != null and cell == _stairs_down:
				markers.append({"cell": cell, "color": Color(0.95, 0.25, 0.25), "legend": "Guard"})
			else:
				markers.append({"cell": cell, "color": STAIRS_MARKER, "legend": "Stairs"})
		elif _chests.has(cell):
			if not _opened(cell):
				var gilded: bool = _chests[cell]["kind"] == "gilded"
				markers.append({"cell": cell, "color": Color(0.35, 0.9, 0.95) if gilded else Color(0.8, 0.55, 0.3),
						"legend": "Set piece" if gilded else "Chest"})
		elif _springs.has(cell):
			if not _opened(cell):
				markers.append({"cell": cell, "color": Color(0.45, 0.95, 0.55), "legend": "Spring"})
		elif kinds.has(coords):
			var marker: Dictionary = kinds[coords].duplicate()
			marker["cell"] = cell
			markers.append(marker)
	return markers


func get_door_destination(cell: Vector2i) -> Dictionary:
	# Act II stairs (25a): the same scene, one floor up or down.
	if cell == _stairs_up or cell == _stairs_down:
		var down := cell == _stairs_down
		GameManager.dungeon_floor = _floor + (1 if down else -1)
		GameManager.arrival = "stairs_down" if down else "stairs_up"
		Sfx.play("menu_confirm")
		return {"scene": _data["scene"]}
	if cell != _exit_cell:
		return {}
	if _escape and not _boss_defeated():
		# The warden bars the only way out: walking up to the door starts it.
		return {"boss": true}
	GameManager.arrival = dungeon_id
	GameManager.dungeon_floor = 0
	return {"scene": _data.get("region_scene", OVERWORLD_SCENE_PATH)}
