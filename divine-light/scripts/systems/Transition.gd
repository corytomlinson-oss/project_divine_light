extends CanvasLayer

# Screen transitions (Milestone 17d), autoloaded as "Transition". Every scene
# change goes through here instead of calling change_scene_to_file directly:
#
#   Transition.change_scene(path)  - quick fade through black (doors, menus,
#                                    leaving a battle)
#   Transition.to_battle()         - FF-style battle start: two flashes, then
#                                    the frozen screen breaks into a mosaic and
#                                    goes dark, with the "encounter" sound
#
# The tree is paused for the length of a transition, so the player can't take
# another step (and trigger a second door or encounter) while the screen is
# fading. This layer runs regardless (process mode Always).

## Emitted once the new scene has faded in and the tree is running again.
signal finished

const FADE_OUT := 0.18
const FADE_IN := 0.22
const BATTLE_SCENE := "res://scenes/battle/Battle.tscn"
const MOSAIC_SHADER := preload("res://assets/shaders/mosaic.gdshader")

var _busy := false
var _black := ColorRect.new()
var _capture := TextureRect.new()


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	for c: Control in [_capture, _black]:
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.size = Vector2(320, 180)
		add_child(c)
	_black.color = Color(0, 0, 0, 0)
	_capture.visible = false
	var mat := ShaderMaterial.new()
	mat.shader = MOSAIC_SHADER
	_capture.material = mat


func is_busy() -> bool:
	return _busy


func change_scene(path: String) -> void:
	if _busy:
		return
	_busy = true
	get_tree().paused = true
	var t := create_tween()
	t.tween_property(_black, "color:a", 1.0, FADE_OUT)
	await t.finished
	await _swap_and_fade_in(path)


func to_battle() -> void:
	if _busy:
		return
	_busy = true
	get_tree().paused = true
	Sfx.play("encounter")
	Music.stop(0.3)
	_capture.texture = ImageTexture.create_from_image(get_viewport().get_texture().get_image())
	_capture.material.set_shader_parameter("block_size", 1.0)
	_capture.modulate = Color.WHITE
	_capture.visible = true
	var t := create_tween()
	# Two quick flashes...
	for i in 2:
		t.tween_property(_capture, "modulate", Color(2.2, 2.2, 2.2), 0.05)
		t.tween_property(_capture, "modulate", Color.WHITE, 0.07)
	# ...then the scene breaks apart into blocks and goes dark.
	t.tween_method(_set_block, 1.0, 24.0, 0.42)
	t.parallel().tween_property(_capture, "modulate", Color.BLACK, 0.42)
	await t.finished
	_black.color.a = 1.0
	_capture.visible = false
	await _swap_and_fade_in(BATTLE_SCENE)


func _set_block(value: float) -> void:
	_capture.material.set_shader_parameter("block_size", roundf(value))


func _swap_and_fade_in(path: String) -> void:
	get_tree().change_scene_to_file(path)
	# The new scene is in place (and its _ready has run) after this frame.
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().paused = false
	var t := create_tween()
	t.tween_property(_black, "color:a", 0.0, FADE_IN)
	await t.finished
	_busy = false
	finished.emit()
