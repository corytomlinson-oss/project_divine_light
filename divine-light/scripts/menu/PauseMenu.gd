class_name PauseMenu
extends CanvasLayer

# Milestone 17c's pause / main menu: B (cancel) or Start on the overworld or in
# a dungeon (Player.gd). Pauses the tree while open; this layer runs anyway
# (process_mode Always in the scene). Left: a party summary, FF-style. Right:
# commands - Equip (the Milestone 15 screen, which reopens this menu when it
# closes) and Close. The natural home for Formation, Items and Save later.

const CLASS_TITLES := {
	"Vael": "Templar",
	"Ryn": "Martial Artist",
	"Lyra": "Invoker",
	"Silas": "Assassin",
}
const GREY := Color(0.63, 0.61, 0.72)
const BAR_TRACK := Color(0.16, 0.15, 0.22)
const HP_GREEN := Color(0.3, 0.9, 0.3)
const MP_BLUE := Color(0.43, 0.55, 1.0)
const ROW_H := 42.0

var _index := 0
var _player: Node2D = null
var _opened_frame := 0
var _cursor := MenuCursor.new()

@onready var _options: Array = $CommandWindow/Options.get_children()
@onready var _party_window: Panel = $PartyWindow


## Opens the menu over the current map and pauses the game. `player` is where
## the map resumes from if a screen like Equip is opened from the menu.
static func open(player: Node2D, start_index: int = 0) -> void:
	var menu: PauseMenu = load("res://scenes/menu/PauseMenu.tscn").instantiate()
	menu._player = player
	menu._index = start_index
	player.get_tree().current_scene.add_child(menu)
	player.get_tree().paused = true


func _ready() -> void:
	_opened_frame = Engine.get_process_frames()
	add_child(_cursor)
	for i in GameManager.party.size():
		_add_party_row(GameManager.party[i], 5.0 + i * ROW_H)
	_cursor.target = _options[_index]
	# Gold under the commands (Milestone 20a).
	var gold_box := Panel.new()
	gold_box.position = Vector2(244, 34)
	gold_box.size = Vector2(72, 18)
	add_child(gold_box)
	var gold := Label.new()
	gold.text = "%d gold" % GameManager.gold
	gold.position = Vector2(8, 4)
	gold.size = Vector2(56, 10)
	gold.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	gold.add_theme_color_override("font_color", Color(0.91, 0.77, 0.35))
	gold_box.add_child(gold)


func _process(_delta: float) -> void:
	# The press that opened the menu is still "just pressed" this frame.
	if Engine.get_process_frames() == _opened_frame:
		return
	if UiInput.nav(&"down") or UiInput.nav(&"up"):
		Sfx.play("menu_move")
		var step := 1 if UiInput.nav(&"down") else -1
		_index = posmod(_index + step, _options.size())
		_cursor.target = _options[_index]
	elif Input.is_action_just_pressed("confirm"):
		Sfx.play("menu_confirm")
		match _options[_index].name:
			"Equip": _open_equip()
			"Close": _close()
	elif Input.is_action_just_pressed("cancel") or Input.is_action_just_pressed("pause"):
		Sfx.play("menu_cancel")
		_close()


func _close() -> void:
	get_tree().paused = false
	queue_free()


func _open_equip() -> void:
	GameManager.pending_spawn_position = _player.position
	GameManager.has_pending_spawn = true
	GameManager.reopen_pause_menu = true
	Transition.change_scene("res://scenes/equip/Equip.tscn")


## One member: their standing sprite, name / class / level on the first line,
## HP and MP (or Qi) numbers with bars under them.
func _add_party_row(member: Combatant, y: float) -> void:
	var sheet_path := "res://assets/sprites/%s_walk.png" % member.char_class.to_lower()
	if ResourceLoader.exists(sheet_path):
		var frame := AtlasTexture.new()
		frame.atlas = load(sheet_path)
		frame.region = Rect2(0, 0, 16, 32)  # idle, facing down
		var portrait := TextureRect.new()
		portrait.texture = frame
		portrait.position = Vector2(8, y)
		if member.is_ko:
			portrait.modulate = Color(0.45, 0.4, 0.55)
		_party_window.add_child(portrait)

	_label(member.display_name, Vector2(30, y), 44)
	_label(CLASS_TITLES.get(member.char_class, ""), Vector2(74, y), 90).modulate = GREY
	_label("Lv %d" % member.level, Vector2(170, y), 54, HORIZONTAL_ALIGNMENT_RIGHT)

	_label("HP", Vector2(30, y + 11), 20).modulate = GREY
	_label("%d/%d" % [member.hp, member.max_hp], Vector2(50, y + 11), 70, HORIZONTAL_ALIGNMENT_RIGHT)
	_bar(Vector2(30, y + 22), 90, float(member.hp) / member.max_hp, HP_GREEN)

	if member.max_qi > 0:
		_label("Qi", Vector2(130, y + 11), 20).modulate = GREY
		var pips := QiPips.new()
		pips.max_qi = member.max_qi
		pips.qi = member.qi
		pips.position = Vector2(182, y + 13)
		_party_window.add_child(pips)
	elif member.max_mp > 0:
		_label("MP", Vector2(130, y + 11), 20).modulate = GREY
		_label("%d/%d" % [member.mp, member.max_mp], Vector2(150, y + 11), 74, HORIZONTAL_ALIGNMENT_RIGHT)
		_bar(Vector2(130, y + 22), 94, float(member.mp) / member.max_mp, MP_BLUE)


func _label(text: String, pos: Vector2, width: float, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.size = Vector2(width, 10)
	label.horizontal_alignment = align
	_party_window.add_child(label)
	return label


func _bar(pos: Vector2, width: float, pct: float, color: Color) -> void:
	var track := ColorRect.new()
	track.position = pos
	track.size = Vector2(width, 3)
	track.color = BAR_TRACK
	_party_window.add_child(track)
	var fill := ColorRect.new()
	fill.position = pos
	fill.size = Vector2(width * clampf(pct, 0.0, 1.0), 3)
	fill.color = color
	_party_window.add_child(fill)
