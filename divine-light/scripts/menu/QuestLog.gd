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

	var list := VBoxContainer.new()
	list.position = Vector2(14, 20)
	list.size = Vector2(WIDTH, 148)
	list.add_theme_constant_override("separation", 3)
	add_child(list)

	var entries := Quests.log_entries()
	var done: Array = []
	for e: Dictionary in entries:
		if e["done"]:
			done.append(e["name"])
			continue
		list.add_child(_label(e["name"], GOLD))
		list.add_child(_wrapped("  " + e["text"], Color.WHITE))
	if entries.filter(func(e: Dictionary) -> bool: return not e["done"]).is_empty():
		list.add_child(_wrapped("No quest in hand. Folk in Verdance and Edenmere may need a hand - talk to them.", GREY))
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


func _process(_delta: float) -> void:
	# The press that opened the log is still "just pressed" this frame.
	if Engine.get_process_frames() == _opened_frame:
		return
	for action in [&"cancel", &"confirm", &"pause"]:
		if Input.is_action_just_pressed(action):
			Sfx.play("menu_cancel")
			# Deferred, like MapScreen: un-pausing now would let the pause menu
			# read this same press.
			get_tree().set_deferred("paused", _was_paused)
			closed.emit()
			queue_free()
			return
