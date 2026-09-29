class_name ScrollHint
extends Control

# Small up/down arrows on a menu window's right edge (Milestone 17b), shown
# when a list has more options above or below the visible page - e.g. "Run",
# the 6th battle command in a 5-row window. Place it at the window's top
# right; the down arrow draws `height` pixels below the up arrow.

const COLOR := Color(0.91, 0.77, 0.35)

var more_above := false:
	set(value):
		more_above = value
		queue_redraw()
var more_below := false:
	set(value):
		more_below = value
		queue_redraw()
var height := 54.0:
	set(value):
		height = value
		queue_redraw()


func _draw() -> void:
	# 5x3 triangles, pointing up / down.
	if more_above:
		draw_rect(Rect2(2, 0, 1, 1), COLOR)
		draw_rect(Rect2(1, 1, 3, 1), COLOR)
		draw_rect(Rect2(0, 2, 5, 1), COLOR)
	if more_below:
		draw_rect(Rect2(0, height, 5, 1), COLOR)
		draw_rect(Rect2(1, height + 1, 3, 1), COLOR)
		draw_rect(Rect2(2, height + 2, 1, 1), COLOR)
