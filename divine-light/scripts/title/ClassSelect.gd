extends Node2D

# Choosing the starting character (Milestone 20a), shown after the intro on
# New Game. The pick decides where the player wakes up captive and the order
# of Act I's dungeons (ActOne.ROUTES). Characters whose starting dungeon isn't
# built yet are shown but locked (ActOne.PLAYABLE_STARTS).

const BLURBS := {
	"Vael": "Templar. A holy knight who shields allies, draws enemy attacks and smites the corrupted with holy light.",
	"Ryn": "Martial Artist. Builds Qi with every strike, then spends it to heal, to hit harder, or to stun.",
	"Lyra": "Invoker. Shifts between fire, ice, lightning and earth stances to strike each enemy where it's weak.",
	"Silas": "Assassin. The fastest of the four: poisons, bleeds and shadow strikes that wear down any foe.",
}
const TITLES := {"Vael": "Templar", "Ryn": "Martial Artist", "Lyra": "Invoker", "Silas": "Assassin"}
const LOCKED_TEXT := "Their story opens in a later update. For now, Vael awakens first."

var _index := 0
var _busy := false
var _names: Array = []
var _portraits: Array = []
var _cursor := MenuCursor.new()

@onready var _info: Label = $Info/Text


func _ready() -> void:
	Music.play("intro")
	for i in GameManager.CLASSES.size():
		var cls: String = GameManager.CLASSES[i]
		var x := 22.0 + i * 76.0
		var frame := AtlasTexture.new()
		frame.atlas = load("res://assets/sprites/%s_walk.png" % cls.to_lower())
		frame.region = Rect2(0, 0, 16, 32)  # idle, facing down
		var portrait := TextureRect.new()
		portrait.texture = frame
		portrait.scale = Vector2(2, 2)
		portrait.position = Vector2(x + 10, 36)
		add_child(portrait)
		_portraits.append(portrait)
		var center := x + 26.0  # under the 2x portrait
		# The name keeps the two-space indent so the glove fits in front of it;
		# the indent is left out of the centering so the name itself is centered.
		var name_label := _label("  " + cls, center, 104, Color.WHITE, 10.0)
		_names.append(name_label)
		_label(TITLES[cls], center, 115, Color(0.63, 0.61, 0.72))
		if cls not in ActOne.PLAYABLE_STARTS:
			portrait.modulate = Color(0.35, 0.33, 0.45)
			name_label.modulate = Color(0.5, 0.5, 0.58)
	add_child(_cursor)
	_select(0)


## A label sized to its text and centered on `center_x` (minus `indent`
## pixels of leading space, which hang off to the left).
func _label(text: String, center_x: float, y: float, color: Color, indent := 0.0) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	var font: Font = label.get_theme_font("font")
	var w: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, label.get_theme_font_size("font_size")).x
	label.size = Vector2(w, 10)
	label.position = Vector2(roundf(center_x - (w - indent) / 2.0 - indent), y)
	add_child(label)
	return label


func _select(i: int) -> void:
	_index = i
	var cls: String = GameManager.CLASSES[i]
	_cursor.target = _names[i]
	_info.text = BLURBS[cls] if cls in ActOne.PLAYABLE_STARTS else BLURBS[cls] + " " + LOCKED_TEXT


func _process(_delta: float) -> void:
	if _busy or Transition.is_busy():
		return
	if UiInput.nav(&"right") or UiInput.nav(&"left"):
		Sfx.play("menu_move")
		var step := 1 if UiInput.nav(&"right") else -1
		_select(posmod(_index + step, GameManager.CLASSES.size()))
	elif Input.is_action_just_pressed("confirm"):
		var cls: String = GameManager.CLASSES[_index]
		if cls not in ActOne.PLAYABLE_STARTS:
			Sfx.play("menu_cancel")
			return
		_busy = true
		Sfx.play("menu_confirm")
		Music.stop(0.8)
		GameManager.start_new_game(cls)
		Transition.change_scene(ActOne.DUNGEONS[ActOne.start_dungeon(cls)]["scene"])
