class_name StatusIcons
extends Node2D

# Milestone 18d's status markers: a row of tiny hand-placed 5x5 pixel icons
# for whatever is currently affecting one fighter (poison, burn, bleed, stun,
# buffs, debuffs...). Reads the Combatant's fields every frame and redraws only
# when the set changes, so no battle code has to notify it.
#
# Enemies get one above their sprite (centered = true, a child of the sprite so
# it shakes and fades with it). Party members get one in their party-window row
# instead - the top party slot sits under the message banner.

const ICONS := {
	"poison": ["..#..", ".###.", "#####", "#####", ".###."],
	"burn": ["..#..", ".##..", ".###.", "#####", ".###."],
	"bleed": ["..#..", ".###.", "#####", "#####", ".###."],
	"stun": ["..#..", "#####", ".###.", ".#.#.", "#...#"],
	"atk_up": ["..#..", ".###.", "#####", "..#..", "..#.."],
	"def_up": ["..#..", ".###.", "#####", "..#..", "..#.."],
	"def_down": ["..#..", "..#..", "#####", ".###.", "..#.."],
	"agi_down": ["..#..", "..#..", "#####", ".###.", "..#.."],
	"sanctuary": ["#####", "#####", "#####", ".###.", "..#.."],
	"taunt": ["..#..", "..#..", "..#..", ".....", "..#.."],
	"evade": [".....", ".#...", "#.#.#", "...#.", "....."],
	"blind": ["#...#", ".#.#.", "..#..", ".#.#.", "#...#"],
}
const COLORS := {
	"poison": Color(0.45, 0.9, 0.3),
	"burn": Color(1.0, 0.55, 0.15),
	"bleed": Color(0.9, 0.2, 0.25),
	"stun": Color(1.0, 0.9, 0.3),
	"atk_up": Color(1.0, 0.75, 0.3),
	"def_up": Color(0.55, 0.75, 1.0),
	"def_down": Color(0.7, 0.4, 0.95),
	"agi_down": Color(0.5, 0.88, 1.0),
	"sanctuary": Color(1.0, 1.0, 0.85),
	"taunt": Color(1.0, 0.35, 0.25),
	"evade": Color(0.75, 0.75, 0.85),
	"blind": Color(0.7, 0.7, 0.75),
}
const BACKING := Color(0.05, 0.04, 0.1, 0.75)

var combatant: Combatant
var centered := false
var _shown: Array = []


func _process(_delta: float) -> void:
	var now: Array = [] if combatant == null or combatant.is_ko else statuses(combatant)
	if now != _shown:
		_shown = now
		queue_redraw()


## The icons that apply to `c` right now, in a fixed order.
static func statuses(c: Combatant) -> Array:
	var out: Array = []
	if c.poison_rounds > 0: out.append("poison")
	if c.burn_rounds > 0: out.append("burn")
	if c.bleed_rounds > 0: out.append("bleed")
	if c.is_stunned: out.append("stun")
	if c.atk_buff > 0 and c.atk_buff_rounds > 0: out.append("atk_up")
	if c.def_buff > 0 and c.def_buff_rounds > 0: out.append("def_up")
	if c.def_buff < 0 and c.def_buff_rounds > 0: out.append("def_down")
	if c.agi_debuff > 0 and c.agi_debuff_rounds > 0: out.append("agi_down")
	if c.sanctuary: out.append("sanctuary")
	if c.taunt_rounds > 0: out.append("taunt")
	if c.evasion_rounds > 0: out.append("evade")
	if c.accuracy_debuff_rounds > 0: out.append("blind")
	return out


func _draw() -> void:
	var width := _shown.size() * 6 - 1
	var x0 := -floori(width / 2.0) if centered else 0
	for i in _shown.size():
		var icon: String = _shown[i]
		var x := x0 + i * 6
		draw_rect(Rect2(x - 1, -1, 7, 7), BACKING)
		var rows: Array = ICONS[icon]
		for y in rows.size():
			var row: String = rows[y]
			for px in row.length():
				if row[px] == "#":
					draw_rect(Rect2(x + px, y, 1, 1), COLORS[icon])
