extends Node2D

# The title screen (Milestone 19b) - the game's main scene now. New Game plays
# the intro movie, then starts on the overworld. Continue loads save slot 1
# (the F5 debug save until Milestone 22 builds real save slots); it's greyed
# out when there's no save.

const FIRST_SCENE := "res://scenes/overworld/Overworld.tscn"
const INTRO := "res://data/cutscenes/intro.scene"

var _index := 0
var _busy := false
var _can_continue := false
var _cursor := MenuCursor.new()

@onready var _options: Array = $Menu/Options.get_children()


func _ready() -> void:
	add_child(_cursor)
	Music.play("intro")
	_can_continue = GameManager.save_exists(1)
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
	GameManager.story_flags["intro_seen"] = true
	Transition.change_scene(FIRST_SCENE)


func _continue() -> void:
	_busy = true
	Sfx.play("menu_confirm")
	Music.stop(0.6)
	GameManager.load_game(1)
	# The save doesn't record where the party was yet (Milestone 22), so this
	# lands on the map GameManager points at - the overworld for now.
	Transition.change_scene(GameManager.current_scene_path)
