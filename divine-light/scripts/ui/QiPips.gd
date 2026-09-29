class_name QiPips
extends Control

# Ryn's Qi meter as drawn pixel pips (Milestone 17a). m5x7 has no ● / ○
# glyphs, and the system-font fallback drew them huge enough to push the
# battle header down over the action menu. Filled pips = Qi available,
# rings = empty.

const PIP := 5  # each pip is a 5x5 pixel circle
const GAP := 2
const FILL := Color(1.0, 0.85, 0.3)
const EMPTY := Color(0.55, 0.55, 0.65)

var qi := 0:
	set(value):
		qi = value
		queue_redraw()
var max_qi := 6:
	set(value):
		max_qi = value
		queue_redraw()


func _draw() -> void:
	for i in max_qi:
		var x := float(i * (PIP + GAP))
		if i < qi:
			draw_rect(Rect2(x + 1, 0, 3, 5), FILL)
			draw_rect(Rect2(x, 1, 5, 3), FILL)
		else:
			draw_rect(Rect2(x + 1, 0, 3, 1), EMPTY)
			draw_rect(Rect2(x + 1, 4, 3, 1), EMPTY)
			draw_rect(Rect2(x, 1, 1, 3), EMPTY)
			draw_rect(Rect2(x + 4, 1, 1, 3), EMPTY)
