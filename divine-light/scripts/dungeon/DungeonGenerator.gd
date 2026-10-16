class_name DungeonGenerator
extends RefCounted

# Milestone 13b procedural generator. Three layers, per the design decision
# in CLAUDE.md ("Dungeon generation - decided"): a hand-authored per-dungeon
# template (passed in) drives a procedural room GRAPH (a tree, so every room
# is reachable by construction), which then drives a procedural TILE LAYOUT
# (rooms centered in a slot grid, connected by carved corridors, walled in
# automatically). Pure logic, no scene/node dependencies, so it can be
# tested headlessly without instantiating anything.

const SLOT_SIZE := 19
const SIDE_MIN := Vector2i(8, 6)
const SIDE_MAX := Vector2i(10, 8)

const FLOOR := "floor"
const WALL := "wall"
const DOOR := "door"
const CAPTIVE_MARKER := "captive"
const BOSS_TRIGGER := "boss_trigger"

const DIRECTIONS: Array = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]


## template keys: min_rooms, max_rooms, room_min_size (Vector2i), room_max_size (Vector2i),
## side_rooms (dead ends added off the main rooms, Milestone 23b)
## Returns: {tiles: Dictionary[Vector2i, String], entrance_cell, exit_cell,
##           captive_cell, boss_trigger_cell, player_spawn, room_count}
static func generate(template: Dictionary, seed_value: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value

	var min_rooms: int = template.get("min_rooms", 5)
	var max_rooms: int = template.get("max_rooms", 8)
	var room_min: Vector2i = template.get("room_min_size", Vector2i(10, 7))
	var room_max: Vector2i = template.get("room_max_size", Vector2i(15, 10))
	var room_count: int = rng.randi_range(min_rooms, max_rooms)

	var graph: Dictionary = _build_room_graph(room_count, rng)
	var anchors: Dictionary = _pick_anchors(graph, rng)
	# Side rooms come after the anchors, from their own RNG stream, and get
	# their sizes after every main room: a layout's main rooms are the same
	# with or without them.
	var side_rng := RandomNumberGenerator.new()
	side_rng.seed = seed_value + 104729
	_add_side_rooms(graph, anchors, int(template.get("side_rooms", 0)), side_rng)
	var layout: Dictionary = _build_tile_layout(graph, anchors, room_min, room_max, rng)

	return layout


# Builds a tree where every edge connects cardinally-adjacent slots on an
# unbounded grid, guaranteeing (a) every room is reachable from the root and
# (b) every parent-child pair is exactly one grid step apart, so corridors
# never need to route around a third room in between.
static func _build_room_graph(room_count: int, rng: RandomNumberGenerator) -> Dictionary:
	var slot_of: Dictionary = {0: Vector2i.ZERO}
	var node_at_slot: Dictionary = {Vector2i.ZERO: 0}
	var parent_of: Dictionary = {}
	var children_of: Dictionary = {0: []}
	var depth_of: Dictionary = {0: 0}

	for i in range(1, room_count):
		var candidates: Array = []
		for node_id in slot_of.keys():
			if _free_directions(slot_of[node_id], node_at_slot).size() > 0:
				candidates.append(node_id)
		if candidates.is_empty():
			break  # graceful degradation: fewer rooms than requested
		var parent_id: int = candidates[rng.randi_range(0, candidates.size() - 1)]
		var free_dirs: Array = _free_directions(slot_of[parent_id], node_at_slot)
		var chosen_dir: Vector2i = free_dirs[rng.randi_range(0, free_dirs.size() - 1)]
		var new_slot: Vector2i = slot_of[parent_id] + chosen_dir

		slot_of[i] = new_slot
		node_at_slot[new_slot] = i
		parent_of[i] = parent_id
		children_of[i] = []
		children_of[parent_id].append(i)
		depth_of[i] = depth_of[parent_id] + 1

	return {
		"slot_of": slot_of,
		"parent_of": parent_of,
		"children_of": children_of,
		"depth_of": depth_of,
	}


## Dead-end rooms (23b) hung off main rooms other than the boss's, in free
## grid slots: off the path to anything, so only explorers find them. They're
## smaller (SIDE_MIN..SIDE_MAX) and hold the dungeon's best treasure.
static func _add_side_rooms(graph: Dictionary, anchors: Dictionary, count: int, rng: RandomNumberGenerator) -> void:
	var slot_of: Dictionary = graph["slot_of"]
	var node_at_slot := {}
	for node_id in slot_of:
		node_at_slot[slot_of[node_id]] = node_id
	graph["side"] = {}
	for n in count:
		var parents: Array = []
		for node_id in slot_of.keys():
			if node_id != anchors["boss_id"] and not graph["side"].has(node_id) \
					and not _free_directions(slot_of[node_id], node_at_slot).is_empty():
				parents.append(node_id)
		if parents.is_empty():
			return
		var parent_id: int = parents[rng.randi_range(0, parents.size() - 1)]
		var free_dirs: Array = _free_directions(slot_of[parent_id], node_at_slot)
		var new_slot: Vector2i = slot_of[parent_id] + free_dirs[rng.randi_range(0, free_dirs.size() - 1)]
		var id: int = slot_of.size()
		slot_of[id] = new_slot
		node_at_slot[new_slot] = id
		graph["parent_of"][id] = parent_id
		graph["children_of"][id] = []
		graph["children_of"][parent_id].append(id)
		graph["depth_of"][id] = graph["depth_of"][parent_id] + 1
		graph["side"][id] = true


static func _free_directions(slot_pos: Vector2i, node_at_slot: Dictionary) -> Array:
	var free: Array = []
	for d in DIRECTIONS:
		if not node_at_slot.has(slot_pos + d):
			free.append(d)
	return free


# entrance = root. boss = deepest node (ties broken by whichever is found
# first while scanning). captive = the midpoint of the entrance->boss path
# when that path has an intermediate room, otherwise any other spare room -
# guaranteed to exist since templates require min_rooms >= 5.
static func _pick_anchors(graph: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var depth_of: Dictionary = graph["depth_of"]
	var parent_of: Dictionary = graph["parent_of"]
	var slot_of: Dictionary = graph["slot_of"]

	var boss_id := 0
	var max_depth := 0
	for node_id in depth_of.keys():
		if depth_of[node_id] > max_depth:
			max_depth = depth_of[node_id]
			boss_id = node_id

	var path_to_boss: Array = [boss_id]
	var walk: int = boss_id
	while parent_of.has(walk):
		walk = parent_of[walk]
		path_to_boss.push_front(walk)

	var captive_id: int
	if path_to_boss.size() >= 3:
		captive_id = path_to_boss[path_to_boss.size() / 2]
	else:
		var spare: Array = []
		for node_id in slot_of.keys():
			if node_id != 0 and node_id != boss_id:
				spare.append(node_id)
		captive_id = spare[rng.randi_range(0, spare.size() - 1)] if not spare.is_empty() else boss_id

	return {"entrance_id": 0, "boss_id": boss_id, "captive_id": captive_id}


static func _build_tile_layout(graph: Dictionary, anchors: Dictionary, room_min: Vector2i,
		room_max: Vector2i, rng: RandomNumberGenerator) -> Dictionary:
	var slot_of: Dictionary = graph["slot_of"]
	var parent_of: Dictionary = graph["parent_of"]

	var tiles: Dictionary = {}
	var room_rects: Dictionary = {}
	var room_centers: Dictionary = {}
	var room_depths: Array = []
	var room_kinds: Array = []
	var side: Dictionary = graph.get("side", {})

	for node_id in slot_of.keys():
		var is_side := side.has(node_id)
		var w: int = rng.randi_range(SIDE_MIN.x if is_side else room_min.x, SIDE_MAX.x if is_side else room_max.x)
		var h: int = rng.randi_range(SIDE_MIN.y if is_side else room_min.y, SIDE_MAX.y if is_side else room_max.y)
		var slot_origin: Vector2i = slot_of[node_id] * SLOT_SIZE
		var room_origin: Vector2i = slot_origin + Vector2i((SLOT_SIZE - w) / 2, (SLOT_SIZE - h) / 2)
		var rect := Rect2i(room_origin, Vector2i(w, h))
		room_rects[node_id] = rect
		room_centers[node_id] = rect.position + rect.size / 2
		room_depths.append(graph["depth_of"][node_id])
		room_kinds.append("side" if is_side else "main")
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			for y in range(rect.position.y, rect.position.y + rect.size.y):
				tiles[Vector2i(x, y)] = FLOOR

	for node_id in parent_of.keys():
		_carve_corridor(tiles, room_centers[parent_of[node_id]], room_centers[node_id])

	_add_wall_shell(tiles)

	var entrance_cell: Vector2i = room_centers[anchors["entrance_id"]]
	var exit_cell: Vector2i = room_centers[anchors["boss_id"]]
	var captive_cell: Vector2i = room_centers[anchors["captive_id"]]
	tiles[entrance_cell] = DOOR
	tiles[exit_cell] = DOOR
	tiles[captive_cell] = CAPTIVE_MARKER

	var player_spawn: Vector2i = _offset_within_room(entrance_cell, room_rects[anchors["entrance_id"]], tiles)

	# Boss trigger sits one tile off the boss room's door/center, same offset
	# pattern as the player spawn - a fixed, visible encounter (per the
	# Milestone 14 design) rather than the random step-counter standard
	# enemies use. Painted here as its own tag so Dungeon.gd can turn it back
	# into plain floor once GameManager records the boss as defeated.
	var boss_trigger_cell: Vector2i = _offset_within_room(exit_cell, room_rects[anchors["boss_id"]], tiles)
	tiles[boss_trigger_cell] = BOSS_TRIGGER

	return {
		"tiles": tiles,
		"entrance_cell": entrance_cell,
		"exit_cell": exit_cell,
		"captive_cell": captive_cell,
		"boss_trigger_cell": boss_trigger_cell,
		"player_spawn": player_spawn,
		"room_count": slot_of.size(),
		"room_rects": room_rects.values(),
		"room_depths": room_depths,  # parallel to room_rects; 0 = entrance room
		"room_kinds": room_kinds,    # parallel to room_rects: "main" / "side"
	}


## Treasure (Milestones 23a/23b), from its own RNG stream so adding it
## didn't change any existing layout. Chests sit one tile in from a room's
## corners: corridors run along room centers and rooms are at least 8x6, so a
## chest there never blocks a path.
##   main rooms: `set_items` in gilded chests (one per room where possible,
##               never the entrance room), then 2-4 plain chests; with
##               `allow_mimic`, sometimes one of those is a mimic
##   side rooms: the first may be a healing spring (its center); otherwise
##               a vault of two rich chests, each maybe locked (Silas picks)
## Returns {chests: [{cell, kind, reward}], springs: [cell]}; kind is plain,
## gilded, locked or mimic (reward: see Loot.give()).
static func place_treasure(layout: Dictionary, set_items: Array, seed_value: int, allow_mimic := false) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + 7919
	var rects: Array = layout["room_rects"]
	var depths: Array = layout["room_depths"]
	var kinds: Array = layout.get("room_kinds", [])
	var reserved := [layout["entrance_cell"], layout["exit_cell"], layout["captive_cell"],
			layout["boss_trigger_cell"], layout["player_spawn"]]
	var free_corners: Array = []  # per room, shuffled
	for rect: Rect2i in rects:
		var corners: Array = []
		for x in [rect.position.x + 1, rect.end.x - 2]:
			for y in [rect.position.y + 1, rect.end.y - 2]:
				var cell := Vector2i(x, y)
				if layout["tiles"].get(cell, "") == FLOOR and not reserved.has(cell):
					corners.append(cell)
		_shuffle(corners, rng)
		free_corners.append(corners)
	var main_rooms: Array = []
	var side_rooms: Array = []
	for i in rects.size():
		if i < kinds.size() and kinds[i] == "side":
			side_rooms.append(i)
		else:
			main_rooms.append(i)

	var chests: Array = []
	var inner: Array = main_rooms.filter(func(i: int) -> bool: return depths[i] > 0)
	_shuffle(inner, rng)
	for n in set_items.size():
		var room: int = _room_with_space(inner, n, free_corners)
		if room != -1:
			chests.append({"cell": free_corners[room].pop_back(), "kind": "gilded", "reward": {"item": set_items[n], "count": 1}})

	var plain: Array = []
	for n in rng.randi_range(2, 4):
		_shuffle(main_rooms, rng)
		var room: int = _room_with_space(main_rooms, 0, free_corners)
		if room != -1:
			var chest := {"cell": free_corners[room].pop_back(), "kind": "plain", "reward": Loot.roll(rng)}
			chests.append(chest)
			plain.append(chest)
	if allow_mimic and not plain.is_empty() and rng.randf() < 0.6:
		var mimic: Dictionary = plain[rng.randi_range(0, plain.size() - 1)]
		mimic["kind"] = "mimic"
		mimic["reward"] = Loot.roll(rng, Loot.RICH_TABLE)

	var springs: Array = []
	for k in side_rooms.size():
		var room: int = side_rooms[k]
		if k == 0 and rng.randf() < 0.6:
			var rect: Rect2i = rects[room]
			springs.append(rect.position + rect.size / 2)
			continue
		for n in mini(2, free_corners[room].size()):
			chests.append({"cell": free_corners[room].pop_back(), "kind": "locked" if rng.randf() < 0.5 else "plain",
					"reward": Loot.roll(rng, Loot.RICH_TABLE)})
	return {"chests": chests, "springs": springs}


## The first room from `order` (starting at `start`, wrapping) with a corner left.
static func _room_with_space(order: Array, start: int, free_corners: Array) -> int:
	for k in order.size():
		var room: int = order[(start + k) % order.size()]
		if not free_corners[room].is_empty():
			return room
	return -1


## Fisher-Yates with the dungeon's own RNG (Array.shuffle() uses the global one).
static func _shuffle(arr: Array, rng: RandomNumberGenerator) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


# Finds a tile just off a room's center (its door), always inside the room
# and never on a wall - used for both the player's dungeon-entry spawn point
# and the boss encounter trigger, which both need to sit just inside a door
# rather than directly on top of it.
static func _offset_within_room(center: Vector2i, rect: Rect2i, tiles: Dictionary) -> Vector2i:
	var offset_dir := Vector2i(0, 1) if rect.size.y > 1 else Vector2i(1, 0)
	var offset_cell: Vector2i = center + offset_dir
	if not tiles.has(offset_cell) or tiles[offset_cell] == WALL:
		return center
	return offset_cell


static func _carve_corridor(tiles: Dictionary, from: Vector2i, to: Vector2i) -> void:
	var x := from.x
	var y := from.y
	while x != to.x:
		tiles[Vector2i(x, y)] = FLOOR
		x += 1 if to.x > x else -1
	while y != to.y:
		tiles[Vector2i(x, y)] = FLOOR
		y += 1 if to.y > y else -1
	tiles[Vector2i(x, y)] = FLOOR


# Any cell touching a floor cell (8-directionally) that isn't itself floor
# becomes a wall - this is what seals the generated shape without having to
# track wall placement per room/corridor individually.
static func _add_wall_shell(tiles: Dictionary) -> void:
	var wall_cells: Dictionary = {}
	for cell in tiles.keys():
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				var n: Vector2i = cell + Vector2i(dx, dy)
				if not tiles.has(n):
					wall_cells[n] = true
	for cell in wall_cells.keys():
		tiles[cell] = WALL
