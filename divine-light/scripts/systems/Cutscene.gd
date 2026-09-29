extends CanvasLayer

# Cutscene player (Milestone 19a), autoloaded as "Cutscene". Runs a scene file
# (format and commands: scripts/cutscene/SceneScript.gd):
#
#   await Cutscene.play("res://data/cutscenes/some.scene")
#
# In-engine scenes use the real map: the player and spawned characters walk,
# turn and emote, the camera pans, and a name-tag dialogue box types out
# lines. Movie mode covers the screen with full-screen pixel shots (pictures,
# pans, captions, a title) for the intro and ending; Start skips a movie.
#
# The tree keeps running during a scene (actors need to animate); Player.gd
# ignores input while is_playing(). Screen fades reuse Transition's overlay.
#
# Debug: F7 plays data/cutscenes/demo.scene, F8 demo_movie.scene (on a map).

signal finished

const TEXT_SPEED := 45.0  # characters per second while typing
const WALK_SPEED := 64.0  # px/s: a deliberate cutscene walk (the player runs at 96)
const LINES_PER_PAGE := 3
const TEXT_WIDTH := 296.0
const NAME_COLOR := Color(0.91, 0.77, 0.35)
const SILHOUETTE := Color(0.08, 0.06, 0.12)

var _playing := false
var _actors: Dictionary = {}       # id -> Node2D (the player or a spawned sprite)
var _spawned: Array = []
var _async: Array = []             # Tweens started by [async] steps
var _movie_active := false
var _skip_movie := false
var _images: Dictionary = {}

# dialogue box
var _box := Panel.new()
var _name_label := Label.new()
var _text_label := Label.new()
var _arrow := ScrollHint.new()
var _blink := 0.0

# movie mode
var _movie := CanvasLayer.new()
var _movie_bg := ColorRect.new()
var _movie_images := Control.new()
var _caption := Label.new()
var _title := Label.new()


func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_dialogue_box()
	_build_movie_layer()


func is_playing() -> bool:
	return _playing


## Plays a scene file to the end. Parse errors are reported (with line
## numbers) and nothing plays.
func play(path: String) -> void:
	await _play_parsed(SceneScript.parse_file(path), path)


## Plays scene commands given as text instead of a file - for short one-off
## lines a map shows itself, e.g. a sealed door (Milestone 20a).
func play_text(text: String) -> void:
	await _play_parsed(SceneScript.parse(text, "inline"), "inline")


func _play_parsed(parsed: Dictionary, path: String) -> void:
	if _playing:
		push_warning("Cutscene: '%s' requested while another scene is playing" % path)
		return
	if not parsed["errors"].is_empty():
		for e: String in parsed["errors"]:
			push_error("Cutscene: " + e)
		return
	_playing = true
	_actors = {}
	var player := get_tree().get_first_node_in_group("player")
	if player != null:
		_actors["player"] = player
	for step: Dictionary in parsed["steps"]:
		if _skip_movie and step["cmd"] not in ["movie_end", "set", "music", "music_stop"]:
			continue
		if step["cmd"] != "say":
			_box.visible = false
		await _run(step)
	await _sync()
	_box.visible = false
	if _movie_active:
		_end_movie()
	for node: Node in _spawned:
		if is_instance_valid(node):
			node.queue_free()
	_spawned = []
	_actors = {}
	_playing = false
	finished.emit()


## Same as play(), but only the first time: afterwards `flag` is set and the
## scene never plays again (e.g. an area's arrival scene).
func play_once(path: String, flag: String) -> void:
	if GameManager.has_flag(flag):
		return
	GameManager.story_flags[flag] = true
	await play(path)


func _process(delta: float) -> void:
	_blink = fmod(_blink + delta, 0.8)
	_arrow.visible = _box.visible and _arrow.more_below and _blink < 0.5
	if _movie_active and not _skip_movie and Input.is_action_just_pressed("pause"):
		_skip_movie = true
		for t: Tween in _async:
			if t.is_valid():
				t.kill()


func _input(event: InputEvent) -> void:
	if _playing or get_tree().paused or not (event is InputEventKey and event.pressed and not event.echo):
		return
	if get_tree().get_first_node_in_group("player") == null:
		return
	if event.keycode == KEY_F7:
		play("res://data/cutscenes/demo.scene")
	elif event.keycode == KEY_F8:
		play("res://data/cutscenes/demo_movie.scene")


# ------------------------------------------------------------------ steps

func _run(step: Dictionary) -> void:
	match step["cmd"]:
		"say":
			await _say(step["name"], step["text"])
		"wait":
			await _wait(step["seconds"])
		"sync":
			await _sync()
		"spawn":
			_spawn(step["id"], step["sprite"], _resolve(step), step["facing"])
		"despawn":
			var actor: Node2D = _actors.get(step["id"])
			if actor != null and actor in _spawned:
				actor.queue_free()
				_actors.erase(step["id"])
		"move":
			await _maybe_wait(_walk(step["id"], [[step["dir"], step["tiles"]]]), step["async"])
		"move_to":
			var actor := _actor(step["id"])
			if actor != null:
				var here := _tile_of(actor)
				var d: Vector2i = _resolve(step) - here
				var legs: Array = []
				if d.x != 0:
					legs.append(["right" if d.x > 0 else "left", absi(d.x)])
				if d.y != 0:
					legs.append(["down" if d.y > 0 else "up", absi(d.y)])
				await _maybe_wait(_walk(step["id"], legs), step["async"])
		"face":
			var actor := _actor(step["id"])
			if actor != null:
				_animate(actor, step["dir"], false)
		"emote":
			var actor := _actor(step["id"])
			if actor != null:
				var bubble := EmoteBubble.new()
				bubble.kind = step["kind"]
				bubble.position = Vector2(0, -26)
				actor.add_child(bubble)
				await _maybe_wait(bubble.done, step["async"])
		"camera_to":
			await _maybe_wait(_camera_to(_world_of(_resolve(step)), step["over"]), step["async"])
		"camera_reset":
			await _maybe_wait(_camera_to(null, step["over"]), step["async"])
		"fade_out":
			await Transition.fade_out(step["seconds"])
		"fade_in":
			await Transition.fade_in(step["seconds"])
		"music":
			Music.play(step["track"])
		"music_stop":
			Music.stop(step["seconds"])
		"sound":
			Sfx.play(step["name"])
		"set":
			GameManager.story_flags[step["flag"]] = true
		"movie_start":
			_movie_active = true
			_skip_movie = false
			_movie.visible = true
		"movie_end":
			_end_movie()
		"image":
			_show_image(step["id"], step["path"], step["at"])
		"pan":
			var img: Control = _images.get(step["id"])
			if img != null:
				var t := create_tween()
				t.tween_property(img, "position", Vector2(step["to"]), step["over"]).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				await _maybe_wait(t, step["async"])
		"remove":
			var img: Control = _images.get(step["id"])
			if img != null:
				img.queue_free()
				_images.erase(step["id"])
		"caption":
			await _show_text(_caption, step["text"])
		"title":
			await _show_text(_title, step["text"])


## Waits for a Tween (or a Signal) unless the step is [async], in which case
## a Tween is tracked for "sync".
func _maybe_wait(what: Variant, is_async: bool) -> void:
	if what is Tween:
		if is_async:
			_async.append(what)
		else:
			await _finish(what)
	elif what is Signal and not is_async:
		await what


## Waits for a tween to end - or to be killed by a movie skip (a killed tween
## never emits finished, so this polls instead of awaiting the signal).
func _finish(t: Tween) -> void:
	while t != null and t.is_valid() and t.is_running() and not _skip_movie:
		await get_tree().process_frame


func _sync() -> void:
	for t: Tween in _async:
		await _finish(t)
	_async = []


func _wait(seconds: float) -> void:
	var left := seconds
	while left > 0.0 and not _skip_movie:
		await get_tree().process_frame
		left -= get_process_delta_time()


# ------------------------------------------------------------------ dialogue

func _build_dialogue_box() -> void:
	_box.position = Vector2(4, 124)
	_box.size = Vector2(312, 52)
	_box.visible = false
	add_child(_box)
	_name_label.position = Vector2(8, 4)
	_name_label.size = Vector2(TEXT_WIDTH, 10)
	_name_label.add_theme_color_override("font_color", NAME_COLOR)
	_box.add_child(_name_label)
	_text_label.position = Vector2(8, 14)
	_text_label.size = Vector2(TEXT_WIDTH, 30)
	_box.add_child(_text_label)
	_arrow.more_below = false
	_arrow.height = 0.0
	_arrow.position = Vector2(299, 45)
	_box.add_child(_arrow)


## Types a line into the box, page by page (3 lines each); A finishes the page
## early, then turns it.
func _say(speaker: String, text: String) -> void:
	_box.visible = true
	_name_label.text = speaker
	var named := speaker != ""
	_text_label.position.y = 14.0 if named else 9.0
	var pages := _paginate(text)
	for page: String in pages:
		_text_label.text = page
		_text_label.visible_characters = 0
		_arrow.more_below = false
		var shown := 0.0
		while _text_label.visible_characters < page.length():
			await get_tree().process_frame
			if Input.is_action_just_pressed("confirm"):
				_text_label.visible_characters = page.length()
				await get_tree().process_frame  # don't let this press also turn the page
				break
			shown += TEXT_SPEED * get_process_delta_time()
			_text_label.visible_characters = mini(page.length(), int(shown))
		_arrow.more_below = true
		while not Input.is_action_just_pressed("confirm"):
			await get_tree().process_frame
		Sfx.play("menu_move")
		await get_tree().process_frame
	_arrow.more_below = false


## Word-wraps with the real font into pages of LINES_PER_PAGE lines, so each
## page types out from its own start.
func _paginate(text: String) -> Array:
	var font: Font = _text_label.get_theme_font("font")
	var size: int = _text_label.get_theme_font_size("font_size")
	var lines: Array = []
	for paragraph in text.split("\\n"):
		var line := ""
		for word in paragraph.split(" ", false):
			var trial := word if line == "" else line + " " + word
			if font.get_string_size(trial, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > TEXT_WIDTH and line != "":
				lines.append(line)
				line = word
			else:
				line = trial
		lines.append(line)
	var pages: Array = []
	for i in range(0, lines.size(), LINES_PER_PAGE):
		pages.append("\n".join(lines.slice(i, i + LINES_PER_PAGE)))
	return pages


# ------------------------------------------------------------------ actors

func _actor(id: String) -> Node2D:
	var actor: Node2D = _actors.get(id)
	if actor == null or not is_instance_valid(actor):
		push_warning("Cutscene: no character '%s' on the map" % id)
		return null
	return actor


func _map() -> Node:
	var player: Node = _actors.get("player")
	return player.get_parent() if player != null else get_tree().current_scene


## A step's tile, turning ~x,y (relative to the player) into a map tile.
func _resolve(step: Dictionary) -> Vector2i:
	var tile: Vector2i = step["tile"]
	var player: Node2D = _actors.get("player")
	if step.get("rel", false) and player != null:
		return _tile_of(player) + tile
	return tile


func _world_of(tile: Vector2i) -> Vector2:
	var map := _map()
	if map is TileMapLayer:
		return (map as TileMapLayer).map_to_local(tile)
	return Vector2(tile) * 16.0 + Vector2(8, 8)


func _tile_of(actor: Node2D) -> Vector2i:
	var map := _map()
	if map is TileMapLayer:
		return (map as TileMapLayer).local_to_map(actor.position)
	return Vector2i((actor.position / 16.0).floor())


## Characters come from their walk sheet (assets/sprites/<sprite>_frames.tres).
## A sprite with no art yet (e.g. Frank) appears as a dark silhouette of Vael's
## shape, so scenes can be written before the art exists.
func _spawn(id: String, sprite_name: String, tile: Vector2i, facing: String) -> void:
	var path := "res://assets/sprites/%s_frames.tres" % sprite_name
	var sprite := AnimatedSprite2D.new()
	if ResourceLoader.exists(path):
		sprite.sprite_frames = load(path)
	else:
		sprite.sprite_frames = load("res://assets/sprites/vael_frames.tres")
		# self_modulate: only the sprite goes dark, not its emote bubbles.
		sprite.self_modulate = SILHOUETTE
	sprite.position = _world_of(tile)
	_map().add_child(sprite)
	_actors[id] = sprite
	_spawned.append(sprite)
	_animate(sprite, facing, false)


## Plays walk_/idle_ + down/up/side (left = side mirrored), the same animation
## names every walk sheet has. For the player it also updates Player._facing
## so they keep facing that way after the scene.
func _animate(actor: Node2D, dir: String, walking: bool) -> void:
	var sprite: AnimatedSprite2D = actor as AnimatedSprite2D
	if sprite == null:
		sprite = actor.get_node_or_null("AnimatedSprite2D")
	if sprite == null:
		return
	var sheet := "side" if dir == "left" or dir == "right" else dir
	var anim := ("walk_" if walking else "idle_") + sheet
	sprite.flip_h = dir == "left"
	if sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)
	if "_facing" in actor:
		actor.set("_facing", dir)


## One tween walking an actor through legs [[dir, tiles], ...].
func _walk(id: String, legs: Array) -> Tween:
	var actor := _actor(id)
	if actor == null or legs.is_empty():
		return null
	var t := create_tween()
	var pos := actor.position
	for leg: Array in legs:
		var dir: String = leg[0]
		var tiles: int = leg[1]
		var step: Vector2 = {"up": Vector2.UP, "down": Vector2.DOWN, "left": Vector2.LEFT, "right": Vector2.RIGHT}[dir]
		var to := pos + step * 16.0 * tiles
		t.tween_callback(_animate.bind(actor, dir, true))
		t.tween_property(actor, "position", to, pos.distance_to(to) / WALK_SPEED)
		pos = to
	var last_dir: String = legs[legs.size() - 1][0]
	t.tween_callback(_animate.bind(actor, last_dir, false))
	# Keep the Player's own grid target in step, so it doesn't snap back.
	if "_target" in actor:
		t.tween_callback(func() -> void: actor.set("_target", actor.position))
	return t


## Pans the player's camera to a world position, or back onto the player (null).
func _camera_to(world: Variant, over: float) -> Tween:
	var player: Node2D = _actors.get("player")
	var cam: Camera2D = player.get_node_or_null("Camera2D") if player != null else null
	if cam == null:
		return null
	var local := Vector2.ZERO if world == null else (world as Vector2) - player.position
	var t := create_tween()
	t.tween_property(cam, "position", local, maxf(over, 0.01)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return t


# ------------------------------------------------------------------ movie mode

func _build_movie_layer() -> void:
	_movie.layer = 60
	_movie.visible = false
	add_child(_movie)
	_movie_bg.color = Color.BLACK
	_movie_bg.size = Vector2(320, 180)
	_movie.add_child(_movie_bg)
	_movie_images.size = Vector2(320, 180)
	_movie_images.clip_contents = true
	_movie.add_child(_movie_images)
	for label: Label in [_caption, _title]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_shadow_color", Color.BLACK)
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
		label.modulate.a = 0.0
		_movie.add_child(label)
	_caption.position = Vector2(12, 150)
	_caption.size = Vector2(296, 20)
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# The title is drawn at 2x - a whole-number scale, so still pixel-crisp.
	_title.scale = Vector2(2, 2)
	_title.size = Vector2(160, 10)
	_title.position = Vector2(0, 80)
	_title.add_theme_color_override("font_color", NAME_COLOR)


func _show_image(id: String, path: String, at: Vector2i) -> void:
	if not ResourceLoader.exists(path):
		push_warning("Cutscene: no image '%s'" % path)
		return
	if _images.has(id):
		_images[id].queue_free()
	var img := TextureRect.new()
	img.texture = load(path)
	img.position = Vector2(at)
	_movie_images.add_child(img)
	_images[id] = img


## Fades a caption/title out (if showing), swaps the text, fades it in.
## Empty text just fades it out.
func _show_text(label: Label, text: String) -> void:
	if label.modulate.a > 0.0:
		var out := create_tween()
		out.tween_property(label, "modulate:a", 0.0, 0.3)
		await _finish(out)
	label.text = text
	if text != "":
		var t := create_tween()
		t.tween_property(label, "modulate:a", 1.0, 0.6)
		await _finish(t)


func _end_movie() -> void:
	_movie_active = false
	_skip_movie = false
	_movie.visible = false
	for img: Node in _movie_images.get_children():
		img.queue_free()
	_images = {}
	for label: Label in [_caption, _title]:
		label.modulate.a = 0.0
		label.text = ""


# ------------------------------------------------------------------ emotes

## Speech bubble over a character's head with a tiny pixel symbol. Pops in,
## holds, and frees itself; `done` fires when it's gone.
class EmoteBubble extends Node2D:
	signal done

	const GLYPHS := {
		"!": ["..#..", "..#..", "..#..", ".....", "..#.."],
		"?": [".###.", "....#", "..##.", ".....", "..#.."],
		"...": [".....", ".....", ".....", ".....", "#.#.#"],
		"note": ["..##.", "..#.#", "..#..", "###..", "##..."],
		"heart": [".#.#.", "#####", "#####", ".###.", "..#.."],
	}
	const COLORS := {"!": Color(0.9, 0.2, 0.2), "?": Color(0.2, 0.35, 0.9), "...": Color(0.2, 0.2, 0.25), "note": Color(0.2, 0.5, 0.3), "heart": Color(0.9, 0.25, 0.45)}

	var kind := "!"

	func _ready() -> void:
		z_index = 20
		var t := create_tween()
		position.y -= 3.0
		t.tween_property(self, "position:y", position.y + 3.0, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_interval(0.8)
		t.tween_callback(func() -> void:
			done.emit()
			queue_free())

	func _draw() -> void:
		# 11x9 white bubble with a dark outline and a little tail.
		draw_rect(Rect2(-6, -10, 13, 11), Color(0.08, 0.06, 0.12))
		draw_rect(Rect2(-5, -9, 11, 9), Color.WHITE)
		draw_rect(Rect2(-1, 1, 3, 1), Color(0.08, 0.06, 0.12))
		draw_rect(Rect2(0, 1, 1, 1), Color.WHITE)
		draw_rect(Rect2(0, 2, 1, 1), Color(0.08, 0.06, 0.12))
		var rows: Array = GLYPHS[kind]
		for y in rows.size():
			var row: String = rows[y]
			for x in row.length():
				if row[x] == "#":
					draw_rect(Rect2(-2 + x, -7 + y, 1, 1), COLORS[kind])
