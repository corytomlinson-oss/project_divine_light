class_name DungeonGenerator
extends RefCounted

# Milestone 13b procedural generator. Three layers, per the design decision
# in CLAUDE.md ("Dungeon generation - decided"): a hand-authored per-dungeon
# template (passed in) drives a procedural room GRAPH (a tree, so every room
# is reachable by construction), which then drives a procedural TILE LAYOUT
# (rooms centered in a slot grid, connected by carved corridors, walled in
# automatically). Pure logic, no scene/node dependencies, so it can be
# tested headlessly without instantiating anything.

const SLOT_SIZE := 10

const FLOOR := "floor"
const WALL := "wall"
const DOOR := "door"
const CAPTIVE_MARKER := "captive"

const DIRECTIONS: Array = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]


## template keys: min_rooms, max_rooms, room_min_size (Vector2i), room_max_size (Vector2i)
## Returns: {tiles: Dictionary[Vector2i, String], entrance_cell, exit_cell,
##           captive_cell, player_spawn, room_count}
static func generate(template: Dictionary, seed_value: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value

	var min_rooms: int = template.get("min_rooms", 5)
	var max_rooms: int = template.get("max_rooms", 8)
	var room_min: Vector2i = template.get("room_min_size", Vector2i(4, 4))
	var room_max: Vector2i = template.get("room_max_size", Vector2i(7, 6))
	var room_count: int = rng.randi_range(min_rooms, max_rooms)

	var graph: Dictionary = _build_room_graph(room_count, rng)
	var anchors: Dictionary = _pick_anchors(graph, rng)
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

	for node_id in slot_of.keys():
		var w: int = rng.randi_range(room_min.x, room_max.x)
		var h: int = rng.randi_range(room_min.y, room_max.y)
		var slot_origin: Vector2i = slot_of[node_id] * SLOT_SIZE
		var room_origin: Vector2i = slot_origin + Vector2i((SLOT_SIZE - w) / 2, (SLOT_SIZE - h) / 2)
		var rect := Rect2i(room_origin, Vector2i(w, h))
		room_rects[node_id] = rect
		room_centers[node_id] = rect.position + rect.size / 2
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

	var entrance_rect: Rect2i = room_rects[anchors["entrance_id"]]
	var spawn_dir := Vector2i(0, 1) if entrance_rect.size.y > 1 else Vector2i(1, 0)
	var player_spawn: Vector2i = entrance_cell + spawn_dir
	if not tiles.has(player_spawn) or tiles[player_spawn] == WALL:
		player_spawn = entrance_cell

	return {
		"tiles": tiles,
		"entrance_cell": entrance_cell,
		"exit_cell": exit_cell,
		"captive_cell": captive_cell,
		"player_spawn": player_spawn,
		"room_count": slot_of.size(),
	}


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
