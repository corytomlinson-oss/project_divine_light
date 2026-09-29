class_name MenuCursor
extends Sprite2D

# Milestone 17a's pointing-glove cursor (assets/ui/cursor.png, drawn by
# assets/ui/source/build_cursor.py). Replaces the typed "> " every menu used
# to prepend: menus now give every option the same two-space indent (10px in
# m5x7, room for the 8px glove plus a gap) and just set `target` to the
# selected label. The cursor re-reads the label's position every frame, so
# container relayout and list scrolling need no extra hooks.

const TEXTURE := preload("res://assets/ui/cursor.png")
const BOB_PERIOD := 0.5  # seconds for one out-and-back nudge

## The label to point at, or null to hide the cursor.
var target: Control = null

var _t := 0.0


func _init() -> void:
	texture = TEXTURE
	centered = false
	z_index = 10


func _process(delta: float) -> void:
	visible = target != null and is_instance_valid(target) and target.is_visible_in_tree()
	if not visible:
		return
	_t = fmod(_t + delta, BOB_PERIOD)
	var nudge := -1.0 if _t >= BOB_PERIOD / 2.0 else 0.0
	# x 0 leaves a 2px gap before the text; y +1 lines the 7px glove up with
	# m5x7's capitals (1px below the label top).
	global_position = target.global_position + Vector2(nudge, 1.0)
