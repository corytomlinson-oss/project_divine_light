class_name QuestLog
extends CanvasLayer

# The quest log (Milestone 24): Quests in the pause menu. Active quests with
# what to do next, then the finished ones on a line, then key items. Code-
# built like MapScreen; pauses while open and puts things back on close.

signal closed

const GOLD := Color(0.91, 0.77, 0.35)
const GREY := Color(0.63, 0.61, 0.72)
const WIDTH := 292.0

var _was_paused := false
var _opened_frame := 0
# Scrolling (playtest pass, 2026-10-24): by Act III the log outgrows its
# window, so the list sits in a clipped box and Up/Down move it a line at a time.
const VIEW_H := 148.0
const LINE := 10.0
var _list: VBoxContainer
var _scroll := 0.0
var _hint := ScrollHint.new()


static func open(from: Node) -> QuestLog:
	var screen := QuestLog.new()
	from.get_tree().current_scene.add_child(screen)
	return screen


func _ready() -> void:
	layer = 20  # same as the map: above the pause menu
	process_mode = Node.PROCESS_MODE_ALWAYS
	_was_paused = get_tree().paused
	get_tree().paused = true
	_opened_frame = Engine.get_process_frames()

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.size = Vector2(320, 180)
	add_child(dim)
	var window := Panel.new()
	window.position = Vector2(4, 4)
	window.size = Vector2(312, 172)
	add_child(window)
	var title := _label("Quests", GOLD)
	title.position = Vector2(4, 6)
	title.size = Vector2(312, 10)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)

	var clip := Control.new()
	clip.position = Vector2(14, 20)
	clip.size = Vector2(WIDTH, VIEW_H)
	clip.clip_contents = true
	add_child(clip)
	var list := VBoxContainer.new()
	list.size = Vector2(WIDTH, VIEW_H)
	list.add_theme_constant_override("separation", 3)
	clip.add_child(list)
	_list = list
	_hint.position = Vector2(306, 20)
	_hint.height = VIEW_H - 3
	add_child(_hint)

	var entries := Quests.log_entries()
	var done: Array = []
	for e: Dictionary in entries:
		if e["done"]:
			done.append(e["name"])
			continue
		list.add_child(_label(e["name"], GOLD))
		list.add_child(_wrapped("  " + e["text"], Color.WHITE))
	if entries.filter(func(e: Dictionary) -> bool: return not e["done"]).is_empty():
		list.add_child(_wrapped("No quest in hand. Townsfolk with a gold ! over their heads may need a hand.", GREY))
	if not done.is_empty():
		list.add_child(_wrapped("Done: " + ", ".join(done), GREY))
	if not GameManager.key_items.is_empty():
		list.add_child(_wrapped("Key items: " + ", ".join(GameManager.key_items.keys()), GOLD))


func _label(text: String, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	return label


func _wrapped(text: String, color: Color) -> Label:
	var label := _label(text, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = WIDTH
	return label


func _max_scroll() -> float:
	return maxf(0.0, _list.get_combined_minimum_size().y - VIEW_H)


func _process(_delta: float) -> void:
	_hint.more_above = _scroll > 0.0
	_hint.more_below = _scroll < _max_scroll()
	# The press that opened the log is still "just pressed" this frame.
	if Engine.get_process_frames() == _opened_frame:
		return
	var step := 0.0
	if UiInput.nav(&"down"):
		step = LINE
	elif UiInput.nav(&"up"):
		step = -LINE
	if step != 0.0:
		_scroll = clampf(_scroll + step, 0.0, _max_scroll())
		_list.position.y = -_scroll
	for action in [&"cancel", &"confirm", &"pause"]:
		if Input.is_action_just_pressed(action):
			Sfx.play("menu_cancel")
			# Deferred, like MapScreen: un-pausing now would let the pause menu
			# read this same press.
			get_tree().set_deferred("paused", _was_paused)
			closed.emit()
			queue_free()
			return
