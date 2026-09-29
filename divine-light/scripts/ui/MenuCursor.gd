class_name MenuCursor
extends Sprite2D

# Milestone 17a's pointing-glove cursor (assets/ui/cursor.png, drawn by
# assets/ui/source/build_cursor.py). Replaces the typed "> " every menu used
# to prepend: menus now give every option the same two-space indent (10px in
# m5x7, room for the 8px glove plus a gap) and just set `target` to the
# selected label. The cursor re-reads the label's position every frame, so
# container relayout and list scrolling need no extra hooks.
#
# Since 17b it can also point at a sprite (a battle enemy, FF-style): it sits
# just left of the sprite's left edge, a little above its middle.

const TEXTURE := preload("res://assets/ui/cursor.png")
const BOB_PERIOD := 0.5  # seconds for one out-and-back nudge

## A label (Control) or a centered sprite (Node2D) to point at, or null to hide the cursor.
var target: CanvasItem = null

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
	if target is Control:
		# x 0 leaves a 2px gap before the text; y +1 lines the 7px glove up
		# with m5x7's capitals (1px below the label top).
		global_position = (target as Control).global_position + Vector2(nudge, 1.0)
	else:
		var sprite := target as Node2D
		global_position = sprite.global_position + Vector2(-_half_width(sprite) - 10.0 + nudge, -4.0)


func _half_width(sprite: Node2D) -> float:
	if sprite is AnimatedSprite2D:
		var anim := sprite as AnimatedSprite2D
		var tex: Texture2D = anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)
		if tex != null:
			return tex.get_width() / 2.0
	return 8.0
