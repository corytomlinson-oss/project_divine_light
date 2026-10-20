class_name MapScreen
extends CanvasLayer

# The map: Y (or M) on any map, or Map in the pause menu. Draws the map the
# player is standing on, one small square per tile in that tile's average
# color. The map's own script can add to it:
#   map_fog() -> true       only cells in GameManager.explored are drawn
#   map_fit_explored() -> true  fit the view to the explored cells, not the
#                           whole map (dungeons)
#   map_markers() -> Array  {cell, color, label?, legend?}: labels are written
#                           next to the marker, legends listed along the bottom
#   map_note() -> String    a short line in the top-right corner (a dungeon's
#                           chest count)
# Pauses the tree while open and puts it back the way it was on close, so it
# works over the pause menu too.

signal closed

const MAP_AREA := Rect2(10, 22, 300, 136)
const MAX_SCALE := 8
const MAX_SCALE_FOG := 4
const BLINK := 0.3
const OUTLINE := Color(0.05, 0.04, 0.08)
const GREY := Color(0.63, 0.61, 0.72)

var _player: Node2D
var _tile_map: TileMapLayer
var _map_root: Node
var _was_paused := false
var _opened_frame := 0
var _cells: Dictionary = {}  # cell -> color
var _markers: Array = []
var _bounds := Rect2i()
var _scale := 1.0
var _origin := Vector2.ZERO
var _blink := 0.0
var _canvas: Control
var _you: Control  # the blinking player dot, drawn over the labels


static func open(player: Node2D) -> MapScreen:
	var screen := MapScreen.new()
	screen._player = player
	player.get_tree().current_scene.add_child(screen)
	return screen


func _ready() -> void:
	layer = 20  # above the pause menu (10), below the save screen (25)
	process_mode = Node.PROCESS_MODE_ALWAYS
	_was_paused = get_tree().paused
	get_tree().paused = true
	_opened_frame = Engine.get_process_frames()
	_tile_map = _player.get_parent()
	_map_root = _tile_map.get_parent()
	_collect()

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.size = Vector2(320, 180)
	add_child(dim)
	var window := Panel.new()
	window.position = Vector2(4, 4)
	window.size = Vector2(312, 172)
	add_child(window)
	var title := Label.new()
	title.text = GameManager.location_name(GameManager.current_location)
	title.position = Vector2(4, 6)
	title.size = Vector2(312, 10)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.91, 0.77, 0.35))
	add_child(title)
	if _map_root.has_method("map_note"):
		var note := Label.new()
		note.text = _map_root.map_note()
		note.position = Vector2(4, 6)
		note.size = Vector2(304, 10)
		note.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		note.modulate = GREY
		add_child(note)

	_canvas = Control.new()
	_canvas.draw.connect(_draw_map)
	add_child(_canvas)
	_add_labels()
	_add_legend()
	_you = Control.new()
	_you.draw.connect(_draw_player)
	add_child(_you)


## Reads the tile map once: which cells to draw and in what color.
func _collect() -> void:
	var fog: bool = _map_root.has_method("map_fog") and _map_root.map_fog()
	var averages := {}
	var seen: Dictionary = GameManager.explored.get(GameManager.current_location, {})
	for cell in _tile_map.get_used_cells():
		if fog and not seen.has(cell):
			continue
		var key := [_tile_map.get_cell_source_id(cell), _tile_map.get_cell_atlas_coords(cell)]
		if not averages.has(key):
			averages[key] = _average_color(key[0], key[1])
		_cells[cell] = averages[key]
	if _map_root.has_method("map_markers"):
		_markers = _map_root.map_markers()

	# A dungeon map is fitted to what's explored, so the first room is big and
	# the map zooms out as you uncover more; others fit the whole map, which
	# keeps the overworld steady as its fog lifts.
	_bounds = _tile_map.get_used_rect()
	var max_scale := MAX_SCALE
	var fit_explored: bool = _map_root.has_method("map_fit_explored") and _map_root.map_fit_explored()
	if fog and fit_explored and not _cells.is_empty():
		_bounds = Rect2i(_cells.keys()[0], Vector2i.ONE)
		for cell in _cells:
			_bounds = _bounds.expand(cell)
		_bounds.size += Vector2i.ONE  # expand() leaves out the far edge's cell
		max_scale = MAX_SCALE_FOG
	var fit := minf(MAP_AREA.size.x / _bounds.size.x, MAP_AREA.size.y / _bounds.size.y)
	_scale = minf(floorf(fit), max_scale) if fit >= 1.0 else fit
	var size := Vector2(_bounds.size) * _scale
	_origin = (MAP_AREA.position + (MAP_AREA.size - size) / 2).floor()


func _average_color(source_id: int, coords: Vector2i) -> Color:
	var source := _tile_map.tile_set.get_source(source_id) as TileSetAtlasSource
	if source == null:
		return GREY
	var image := source.texture.get_image()
	if image.is_compressed():
		image.decompress()
	var region := source.get_tile_texture_region(coords)
	var total := Color(0, 0, 0, 0)
	var count := 0
	for x in range(region.position.x, region.end.x):
		for y in range(region.position.y, region.end.y):
			var c := image.get_pixel(x, y)
			if c.a > 0.5:
				total += c
				count += 1
	if count == 0:
		return GREY
	var avg := total / count
	avg.a = 1.0
	return avg


func _to_screen(cell: Vector2i) -> Vector2:
	return _origin + Vector2(cell - _bounds.position) * _scale


func _draw_map() -> void:
	var px := Vector2(_scale, _scale)
	for cell in _cells:
		_canvas.draw_rect(Rect2(_to_screen(cell), px), _cells[cell])
	var dot := maxf(_scale, 3.0)
	for marker in _markers:
		_dot(_canvas, marker["cell"], dot, marker["color"])


func _draw_player() -> void:
	if fmod(_blink, BLINK * 2) < BLINK:
		_dot(_you, _tile_map.local_to_map(_player.position), maxf(_scale, 3.0), Color.WHITE)


## A square of `size` centered on the cell, with a dark 1px outline.
func _dot(on: Control, cell: Vector2i, size: float, color: Color) -> void:
	var center := _to_screen(cell) + Vector2(_scale, _scale) / 2
	var rect := Rect2((center - Vector2(size, size) / 2).floor(), Vector2(size, size))
	on.draw_rect(rect.grow(1), OUTLINE)
	on.draw_rect(rect, color)


## Marker names on the map, beside or above / below the marker - wherever
## the name fits on screen without covering another one.
func _add_labels() -> void:
	var taken: Array = []
	var font := ThemeDB.fallback_font
	var theme_font: Font = null
	var probe := Label.new()
	add_child(probe)
	theme_font = probe.get_theme_font("font")
	var font_size := probe.get_theme_font_size("font_size")
	probe.queue_free()
	if theme_font != null:
		font = theme_font
	var area := Rect2(8, 18, 304, 154)
	for marker in _markers:
		if not marker.has("label"):
			continue
		var text: String = String(marker["label"]).trim_prefix("The ")
		var w := ceilf(font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x) + 1
		var at := (_to_screen(marker["cell"]) + Vector2(_scale, _scale) / 2).floor()
		var spots := [
			Rect2(at.x + 4, at.y - 6, w, 10),          # right
			Rect2(at.x - 4 - w, at.y - 6, w, 10),      # left
			Rect2(at.x - w / 2, at.y - 15, w, 10),     # above
			Rect2(at.x - w / 2, at.y + 3, w, 10),      # below
		]
		var pick: Rect2 = spots[0]
		for spot: Rect2 in spots:
			if area.encloses(spot) and not taken.any(func(r: Rect2) -> bool: return r.intersects(spot)):
				pick = spot
				break
		taken.append(pick)
		var label := Label.new()
		label.text = text
		label.position = pick.position.floor()
		label.size = pick.size
		label.add_theme_color_override("font_shadow_color", OUTLINE)
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
		add_child(label)


## Legend entries (dungeon markers), one each, along the bottom.
func _add_legend() -> void:
	var done := {}
	var x := 12.0
	for marker in _markers:
		if not marker.has("legend") or done.has(marker["legend"]):
			continue
		done[marker["legend"]] = true
		var swatch := ColorRect.new()
		swatch.color = marker["color"]
		swatch.position = Vector2(x, 164)
		swatch.size = Vector2(4, 4)
		add_child(swatch)
		var label := Label.new()
		label.text = marker["legend"]
		label.position = Vector2(x + 7, 160)
		label.size = Vector2(50, 10)
		label.modulate = GREY
		add_child(label)
		x += 56.0


func _process(delta: float) -> void:
	_blink += delta
	_you.queue_redraw()
	# The press that opened the map is still "just pressed" this frame.
	if Engine.get_process_frames() == _opened_frame:
		return
	for action in [&"cancel", &"confirm", &"pause", &"map"]:
		if Input.is_action_just_pressed(action):
			Sfx.play("menu_cancel")
			# At the end of the frame: un-pausing now would let the player read
			# this same B press and open the pause menu.
			get_tree().set_deferred("paused", _was_paused)
			closed.emit()
			queue_free()
			return
