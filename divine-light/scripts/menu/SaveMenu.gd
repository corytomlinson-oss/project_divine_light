class_name SaveMenu
extends CanvasLayer

# The save / load screen (Milestone 22a). Each slot shows the party (their
# standing sprites, names and levels), where the save was made, play time and
# gold - the design doc's slot card. Save mode lists the 3 manual slots and
# asks before overwriting one; load mode adds the Autosave above them.
#
#   var slot := await SaveMenu.open(self, "save")   # -1 if cancelled
#   var slot := await SaveMenu.open(self, "load")

signal closed(slot: int)

const ROW_H := 39.0
const GREY := Color(0.63, 0.61, 0.72)
const GOLD := Color(0.91, 0.77, 0.35)

var _mode := "save"
var _slots: Array = []
var _index := 0
var _confirming := false
var _done := false
var _rows: Array = []        # the first label of each row (cursor target)
var _header := Label.new()
var _cursor := MenuCursor.new()
var _opened_frame := 0


## Opens over the current scene, pausing it, and returns the chosen slot (or
## -1). In save mode the save has already been made when this returns.
static func open(from: Node, mode: String) -> int:
	var menu := SaveMenu.new()
	menu._mode = mode
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
	var tree := from.get_tree()
	var was_paused := tree.paused
	tree.current_scene.add_child(menu)
	tree.paused = true
	var slot: int = await menu.closed
	tree.paused = was_paused
	return slot


func _ready() -> void:
	layer = 25
	_opened_frame = Engine.get_process_frames()
	_slots = [1, 2, 3] if _mode == "save" else [GameManager.AUTOSAVE_SLOT, 1, 2, 3]
	var dim := ColorRect.new()
	dim.size = Vector2(320, 180)
	dim.color = Color(0.03, 0.02, 0.06, 0.97)
	add_child(dim)
	var top := Panel.new()
	top.position = Vector2(4, 4)
	top.size = Vector2(312, 18)
	add_child(top)
	_header.position = Vector2(8, 4)
	_header.size = Vector2(296, 10)
	top.add_child(_header)
	for i in _slots.size():
		_add_row(_slots[i], 24.0 + i * ROW_H)
	add_child(_cursor)
	# Loading starts on the most recent save; saving on the first slot.
	if _mode == "load":
		_index = _newest_index()
	_set_header()
	_cursor.target = _rows[_index]


func _add_row(slot: int, y: float) -> void:
	var panel := Panel.new()
	panel.position = Vector2(4, y)
	panel.size = Vector2(312, ROW_H - 2)
	add_child(panel)
	var title := "Autosave" if slot == GameManager.AUTOSAVE_SLOT else "Slot %d" % slot
	var info := GameManager.slot_summary(slot)
	var name_label := _label(panel, "  " + title, Vector2(4, 3), 70)
	_rows.append(name_label)
	if info.is_empty():
		_label(panel, "- Empty -", Vector2(84, 13), 200).modulate = GREY
		return
	_label(panel, info["location"], Vector2(150, 3), 156, HORIZONTAL_ALIGNMENT_RIGHT).modulate = GOLD
	var names: Array = []
	for i in info["party"].size():
		var m: Dictionary = info["party"][i]
		var frame := AtlasTexture.new()
		var sheet := "res://assets/sprites/%s_walk.png" % String(m["class"]).to_lower()
		if ResourceLoader.exists(sheet):
			frame.atlas = load(sheet)
			frame.region = Rect2(0, 0, 16, 16)  # head and shoulders
			var face := TextureRect.new()
			face.texture = frame
			face.position = Vector2(10 + i * 17, 14)
			panel.add_child(face)
		names.append("%s %d" % [m["class"], m["level"]])
	_label(panel, "  ".join(names), Vector2(84, 14), 222)
	_label(panel, "Time %s    Gold %d" % [_clock(info["play_time"]), info["gold"]], Vector2(84, 24), 222).modulate = GREY


func _process(_delta: float) -> void:
	if _done or Engine.get_process_frames() == _opened_frame:
		return
	if _confirming:
		if Input.is_action_just_pressed("confirm"):
			_save(_slots[_index])
		elif Input.is_action_just_pressed("cancel"):
			Sfx.play("menu_cancel")
			_confirming = false
			_set_header()
		return
	if UiInput.nav(&"down") or UiInput.nav(&"up"):
		Sfx.play("menu_move")
		_index = posmod(_index + (1 if UiInput.nav(&"down") else -1), _slots.size())
		_cursor.target = _rows[_index]
	elif Input.is_action_just_pressed("confirm"):
		var slot: int = _slots[_index]
		if _mode == "load":
			if GameManager.save_exists(slot):
				Sfx.play("menu_confirm")
				_finish(slot)
			else:
				Sfx.play("menu_cancel")
		elif GameManager.save_exists(slot):
			Sfx.play("menu_move")
			_confirming = true
			_header.text = "Overwrite Slot %d?   A: Yes   B: No" % slot
		else:
			_save(slot)
	elif Input.is_action_just_pressed("cancel"):
		Sfx.play("menu_cancel")
		_finish(-1)


func _save(slot: int) -> void:
	_done = true
	_confirming = false
	if GameManager.save_game(slot):
		Sfx.play("item")
		_header.text = "Saved to Slot %d." % slot
	else:
		Sfx.play("menu_cancel")
		_header.text = "Couldn't save!"
	await get_tree().create_timer(0.7, true).timeout
	_finish(slot)


func _finish(slot: int) -> void:
	_done = true
	closed.emit(slot)
	queue_free()


func _set_header() -> void:
	_header.text = "Save - choose a slot" if _mode == "save" else "Load - choose a save"


## The row of the most recently written save (load mode).
func _newest_index() -> int:
	var best := 0
	var best_time := -1
	for i in _slots.size():
		var path: String = GameManager._slot_path(_slots[i])
		if FileAccess.file_exists(path):
			var t := FileAccess.get_modified_time(path)
			if t > best_time:
				best_time = t
				best = i
	return best


static func _clock(seconds: float) -> String:
	var minutes := int(seconds) / 60
	return "%d:%02d" % [minutes / 60, minutes % 60]


func _label(parent: Control, text: String, pos: Vector2, width: float, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.size = Vector2(width, 10)
	label.horizontal_alignment = align
	parent.add_child(label)
	return label
