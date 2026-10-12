extends Node2D

# The title screen (Milestone 19b) - the game's main scene now. New Game plays
# the intro movie, then the class select (20a). Continue opens the load
# screen (22a: the 3 slots and the autosave); it's greyed out when there's no
# save at all.

const CLASS_SELECT := "res://scenes/title/ClassSelect.tscn"
const INTRO := "res://data/cutscenes/intro.scene"

var _index := 0
var _busy := false
var _can_continue := false
var _cursor := MenuCursor.new()

@onready var _options: Array = $Menu/Options.get_children()


func _ready() -> void:
	add_child(_cursor)
	Music.play("intro")
	GameManager.in_game = false  # the play-time clock stops on the title
	_can_continue = GameManager.any_save_exists()
	if not _can_continue:
		_options[1].modulate = Color(0.5, 0.5, 0.58)
	_cursor.target = _options[_index]


func _process(_delta: float) -> void:
	if _busy or Transition.is_busy():
		return
	if UiInput.nav(&"down") or UiInput.nav(&"up"):
		Sfx.play("menu_move")
		_index = 1 - _index
		_cursor.target = _options[_index]
	elif Input.is_action_just_pressed("confirm"):
		if _index == 0:
			_new_game()
		elif _can_continue:
			_continue()
		else:
			Sfx.play("menu_cancel")


func _new_game() -> void:
	_busy = true
	Sfx.play("menu_confirm")
	Music.stop(0.8)
	await Transition.fade_out(0.8)
	_cursor.target = null
	await Cutscene.play(INTRO)
	Transition.change_scene(CLASS_SELECT)


func _continue() -> void:
	_busy = true
	Sfx.play("menu_confirm")
	var slot := await SaveMenu.open(self, "load")
	if slot < 0 or not GameManager.load_game(slot):
		_busy = false
		return
	Music.stop(0.6)
	# The save remembers the map and the spot on it (22a).
	Transition.change_scene(GameManager.current_scene_path)
