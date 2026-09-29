class_name BattleFx
extends Node2D

# Milestone 18's combat effects, built entirely in code (no art files). Each
# effect is a short-lived Shape node that redraws itself from a 0..1 progress
# value a tween drives, then frees itself. Everything is drawn with whole-pixel
# rects so it stays crisp at 320x180.
#
# Battle.gd plays a skill in two parts, from a recipe (FxRecipes.gd):
#   await cast(recipe, caster, targets)  - wind-up / travel, before any damage
#   impact(recipe, targets)              - fire-and-forget, the moment damage
#                                          lands (hurt flash + numbers follow)
#
# This node sits above the fighters and below the windows. Its own origin is
# the screen's, so sprite positions work as-is.

const PALETTES := {
	"physical": [Color(0.8, 0.82, 0.9), Color(1, 1, 1)],
	"enemy": [Color(0.85, 0.2, 0.25), Color(1.0, 0.7, 0.6)],
	"holy": [Color(1.0, 0.85, 0.4), Color(1.0, 1.0, 0.88)],
	"shield": [Color(0.55, 0.75, 1.0), Color(0.9, 0.97, 1.0)],
	"buff": [Color(1.0, 0.75, 0.3), Color(1.0, 0.95, 0.7)],
	"taunt": [Color(1.0, 0.4, 0.25), Color(1.0, 0.8, 0.5)],
	"ki": [Color(0.5, 0.8, 1.0), Color(1, 1, 1)],
	"heal": [Color(0.4, 1.0, 0.5), Color(0.88, 1.0, 0.88)],
	"mana": [Color(0.45, 0.6, 1.0), Color(0.85, 0.9, 1.0)],
	"fire": [Color(1.0, 0.45, 0.12), Color(1.0, 0.85, 0.3)],
	"ice": [Color(0.5, 0.88, 1.0), Color(0.95, 1.0, 1.0)],
	"lightning": [Color(1.0, 0.92, 0.3), Color(1, 1, 1)],
	"earth": [Color(0.6, 0.44, 0.26), Color(0.86, 0.72, 0.46)],
	"arcane": [Color(0.55, 0.45, 1.0), Color(0.88, 0.85, 1.0)],
	"shadow": [Color(0.6, 0.3, 0.9), Color(0.88, 0.72, 1.0)],
	"poison": [Color(0.45, 0.85, 0.28), Color(0.78, 1.0, 0.5)],
	"debuff": [Color(0.6, 0.35, 0.85), Color(0.85, 0.7, 1.0)],
}
const BATTLEFIELD := Rect2(0, 0, 320, 112)

## Nodes that shake with the battlefield (background art, enemy/party areas).
var shake_nodes: Array = []
var _rng := RandomNumberGenerator.new()


class Shape extends Node2D:
	var draw_fn: Callable
	var progress := 0.0:
		set(value):
			progress = value
			queue_redraw()

	func _draw() -> void:
		draw_fn.call(self, progress)


func _ready() -> void:
	_rng.seed = 1818  # effects never touch the global RNG combat rolls use


# ------------------------------------------------------------------ recipes

func cast(recipe: Dictionary, caster: CanvasItem, targets: Array) -> void:
	var pal: Array = palette(recipe)
	match recipe.get("cast", "none"):
		"lunge":
			await _wait(0.12)
		"charge":
			await charge(anchor(caster), pal)
		"projectile":
			var last: Signal
			for t: CanvasItem in targets:
				last = projectile(anchor(caster), anchor(t), pal)
			if not targets.is_empty():
				await last


func impact(recipe: Dictionary, targets: Array) -> void:
	var pal: Array = palette(recipe)
	match recipe.get("screen", ""):
		"flash":
			flash(pal[1])
		"shake":
			shake()
		"quake":
			flash(pal[0], 0.35)
			shake(4.0, 0.45)
	# "impact" is one effect name, or a list of them layered together (18c).
	var kinds = recipe.get("impact", "")
	if kinds is String:
		kinds = [kinds]
	for t: CanvasItem in targets:
		for kind: String in kinds:
			_impact_one(kind, recipe, pal, anchor(t))


func _impact_one(kind: String, recipe: Dictionary, pal: Array, at: Vector2) -> void:
	match kind:
		"slash": slash(at, pal, recipe.get("count", 1))
		"burst": burst(at, pal, recipe.get("size", 12.0))
		"bolt": bolt(at, pal)
		"pillar": pillar(at, pal)
		"rising": pillar(at, pal, true)
		"sweep": sweep(at, pal)
		"sparkles": sparkles(at, pal)
		"sinking": sparkles(at, pal, false)
		"ring": ring(at, pal)
		"cloud": cloud(at, pal)
		"stars": stars(at, pal)
		"crystals": crystals(at, pal)


func palette(recipe: Dictionary) -> Array:
	return PALETTES.get(recipe.get("palette", "physical"), PALETTES["physical"])


## Center of a fighter: sprites are centered; placeholder blocks are ColorRects.
static func anchor(ci: CanvasItem) -> Vector2:
	if ci is Control:
		var c := ci as Control
		return c.position + c.size / 2.0
	return (ci as Node2D).position


# ------------------------------------------------------------------ effects

func _spawn(at: Vector2, duration: float, fn: Callable) -> Signal:
	var s := Shape.new()
	s.position = at.round()
	s.draw_fn = fn
	add_child(s)
	var t := create_tween()
	t.tween_property(s, "progress", 1.0, duration)
	t.tween_callback(s.queue_free)
	return t.finished


func _wait(seconds: float) -> Signal:
	return create_tween().tween_interval(seconds).finished


static func _px(n: CanvasItem, x: float, y: float, w: float, h: float, c: Color) -> void:
	n.draw_rect(Rect2(roundf(x), roundf(y), w, h), c)


## Ring of pixels expanding out of the target, sparks flying past it, and a
## bright core for the first moment.
func burst(at: Vector2, pal: Array, radius := 12.0, duration := 0.32) -> Signal:
	return _spawn(at, duration, func(n: CanvasItem, p: float) -> void:
		var fade := 1.0 - p
		if p < 0.3:
			var core := 3.0 + 3.0 * (1.0 - p / 0.3)
			_px(n, -core, -core, core * 2, core * 2, Color(pal[1], 1.0 - p / 0.3))
		var r := radius * sqrt(p)
		for i in 12:
			var d := Vector2.from_angle(TAU * i / 12.0) * r
			_px(n, d.x - 1, d.y - 1, 2, 2, Color(pal[0], fade))
		for i in 8:
			var d := Vector2.from_angle(TAU * (i + 0.5) / 8.0) * radius * 1.6 * p
			_px(n, d.x, d.y, 1, 1, Color(pal[1], fade)))


## Diagonal streaks across the target, one after another for multi-hits,
## alternating direction.
func slash(at: Vector2, pal: Array, count := 1, duration := 0.22) -> Signal:
	return _spawn(at, duration * (1.0 + 0.5 * (count - 1)), func(n: CanvasItem, p: float) -> void:
		for k in count:
			var start := float(k) / (count + 1.0)
			var local := clampf((p - start) / (1.0 - start) * (count + 1.0) / 2.0, 0.0, 1.0) if count > 1 else p
			if local <= 0.0 or local >= 1.0:
				continue
			var dir := 1.0 if k % 2 == 0 else -1.0
			var grow := minf(1.0, local * 2.0)
			var fade := 1.0 if local < 0.5 else 1.0 - (local - 0.5) * 2.0
			for i in int(20 * grow):
				var x := (10.0 - i) * dir + (k * 3 - count)
				var y := -10.0 + i
				_px(n, x, y, 2, 2, Color(pal[1], fade))
				_px(n, x + dir, y + 1, 1, 1, Color(pal[0], fade)))


## Low horizontal cut along the target's feet (sweeping kick, blade arc).
func sweep(at: Vector2, pal: Array, duration := 0.28) -> Signal:
	return _spawn(at + Vector2(0, 10), duration, func(n: CanvasItem, p: float) -> void:
		var fade := 1.0 - maxf(0.0, p - 0.4) / 0.6
		var w := 28.0 * minf(1.0, p * 2.5)
		_px(n, -14, -1, w, 2, Color(pal[1], fade))
		_px(n, -14, 1, w * 0.8, 1, Color(pal[0], fade)))


## Glowing orb flying from caster to target with a short fading trail.
func projectile(from: Vector2, to: Vector2, pal: Array, duration := 0.26) -> Signal:
	var travel := to - from
	return _spawn(from, duration, func(n: CanvasItem, p: float) -> void:
		for k in range(4, 0, -1):
			var tp := maxf(0.0, p - k * 0.06)
			var d := travel * tp
			_px(n, d.x - 1, d.y - 1, 3, 3, Color(pal[0], 0.9 - k * 0.2))
		var h := travel * p
		_px(n, h.x - 3, h.y - 2, 6, 4, Color(pal[0], 0.6))
		_px(n, h.x - 2, h.y - 3, 4, 6, Color(pal[0], 0.6))
		_px(n, h.x - 2, h.y - 2, 4, 4, pal[0])
		_px(n, h.x - 1, h.y - 1, 2, 2, pal[1]))


## Wind-up on the caster: sparks drawn inward to a point.
func charge(at: Vector2, pal: Array, duration := 0.3) -> Signal:
	return _spawn(at, duration, func(n: CanvasItem, p: float) -> void:
		var r := 16.0 * (1.0 - p)
		for i in 8:
			var d := Vector2.from_angle(TAU * i / 8.0 + p * 2.0) * r
			_px(n, d.x, d.y, 1, 1, Color(pal[1], 0.4 + 0.6 * p))
		if p > 0.6:
			_px(n, -1, -1, 2, 2, Color(pal[1], (p - 0.6) / 0.4)))


## Jagged bolt from the top of the screen down to the target, flickering.
func bolt(at: Vector2, pal: Array, duration := 0.32) -> Signal:
	var points: Array = []
	var x := 0.0
	var y := -at.y
	while y < 0.0:
		points.append(Vector2(x, y))
		y += _rng.randf_range(6.0, 12.0)
		x = clampf(x + _rng.randf_range(-6.0, 6.0), -8.0, 8.0)
	points.append(Vector2.ZERO)
	burst(at, pal, 10.0, 0.3)
	return _spawn(at, duration, func(n: CanvasItem, p: float) -> void:
		if p > 0.7 or int(p * 14.0) % 3 == 2:
			return
		for i in points.size() - 1:
			var a: Vector2 = points[i]
			var b: Vector2 = points[i + 1]
			var steps := int(a.distance_to(b))
			for s in steps:
				var q := a.lerp(b, float(s) / steps)
				_px(n, q.x - 1, q.y, 3, 1, pal[0])
				_px(n, q.x, q.y, 1, 1, pal[1]))


## Column of light: from the sky down onto the target, or (rising) from the
## target's feet up into the sky.
func pillar(at: Vector2, pal: Array, rising := false, duration := 0.45) -> Signal:
	return _spawn(at, duration, func(n: CanvasItem, p: float) -> void:
		var grow := minf(1.0, p * 3.0)
		var fade := 1.0 if p < 0.55 else 1.0 - (p - 0.55) / 0.45
		var top: float
		var bottom: float
		if rising:
			bottom = 16.0
			top = bottom - (bottom + at.y) * grow
		else:
			top = -at.y
			bottom = top + (at.y + 16.0) * grow
		_px(n, -6, top, 12, bottom - top, Color(pal[0], 0.45 * fade))
		_px(n, -3, top, 6, bottom - top, Color(pal[0], 0.8 * fade))
		_px(n, -1, top, 2, bottom - top, Color(pal[1], fade))
		if grow >= 1.0:
			var r := 10.0 * (p - 0.33) / 0.67
			for i in 10:
				var d := Vector2.from_angle(TAU * i / 10.0) * Vector2(r * 1.4, r * 0.5)
				_px(n, d.x, (bottom - 2.0 if not rising else 14.0) + d.y, 1, 1, Color(pal[1], fade)))


## Twinkling motes around an ally, drifting up (heals, buffs) or down (debuffs).
func sparkles(at: Vector2, pal: Array, rising := true, duration := 0.6) -> Signal:
	var motes: Array = []
	for i in 16:
		motes.append(Vector3(_rng.randf_range(-10.0, 10.0), _rng.randf_range(-6.0, 14.0), _rng.randf_range(0.0, 0.35)))
	return _spawn(at, duration, func(n: CanvasItem, p: float) -> void:
		for m: Vector3 in motes:
			var local := (p - m.z) / 0.65
			if local <= 0.0 or local >= 1.0:
				continue
			var dy := -18.0 * local if rising else 18.0 * local - 12.0
			var c: Color = pal[1] if int(local * 8.0) % 2 == 0 else pal[0]
			c.a = 1.0 - local
			# plus-shaped sparkle; every third one is bigger
			var arm := 2.0 if int(m.x * 7.0) % 3 == 0 else 1.0
			_px(n, m.x - arm, m.y + dy, arm * 2 + 1, 1, c)
			_px(n, m.x, m.y + dy - arm, 1, arm * 2 + 1, c))


## Shimmering oval around an ally (shields, Sanctuary).
func ring(at: Vector2, pal: Array, duration := 0.55) -> Signal:
	return _spawn(at, duration, func(n: CanvasItem, p: float) -> void:
		var oval := 1.3 - 0.3 * minf(1.0, p * 3.0)
		var fade := 1.0 if p < 0.6 else 1.0 - (p - 0.6) / 0.4
		for i in 24:
			if (i + int(p * 20.0)) % 4 == 0:
				continue
			var d := Vector2.from_angle(TAU * i / 24.0) * Vector2(11.0, 17.0) * oval
			_px(n, d.x, d.y, 1, 1, Color(pal[1] if i % 2 == 0 else pal[0], fade)))


## Blobs of gas puffing outward and up (poison, smoke).
func cloud(at: Vector2, pal: Array, duration := 0.65) -> Signal:
	var puffs: Array = []
	for i in 7:
		puffs.append(Vector2.from_angle(TAU * i / 7.0 + _rng.randf_range(-0.3, 0.3)) * _rng.randf_range(6.0, 12.0))
	return _spawn(at, duration, func(n: CanvasItem, p: float) -> void:
		var fade := 1.0 - p
		for i in puffs.size():
			var d: Vector2 = puffs[i] * (0.4 + p) + Vector2(0, -6.0 * p)
			var size := 3.0 + (i % 3)
			_px(n, d.x - size / 2.0, d.y - size / 2.0, size, size, Color(pal[0], 0.8 * fade))
			_px(n, d.x - 1, d.y - 1, 1, 1, Color(pal[1], fade)))


## Jagged spikes shooting up around the target's feet, then shattering away
## (ice for Blizzard/Glacier; with the earth palette, Quake's rock spikes).
func crystals(at: Vector2, pal: Array, duration := 0.6) -> Signal:
	var spikes := [Vector2(-10, 7), Vector2(-5, 12), Vector2(0, 17), Vector2(5, 11), Vector2(10, 8)]
	return _spawn(at + Vector2(0, 16), duration, func(n: CanvasItem, p: float) -> void:
		var grow := minf(1.0, p * 4.0)
		var fade := 1.0 if p < 0.6 else 1.0 - (p - 0.6) / 0.4
		var drop := 0.0 if p < 0.6 else (p - 0.6) * 10.0
		for sp: Vector2 in spikes:
			var h := sp.y * grow
			for row in int(h):
				var w := 3.0 if row < h * 0.5 else (2.0 if row < h * 0.8 else 1.0)
				var y := -row + drop
				_px(n, sp.x - floorf(w / 2.0), y, w, 1, Color(pal[0], fade))
				if row % 3 == 1:
					_px(n, sp.x, y, 1, 1, Color(pal[1], fade)))


## Little stars circling the target's head (stuns).
func stars(at: Vector2, pal: Array, duration := 0.7) -> Signal:
	return _spawn(at + Vector2(0, -18), duration, func(n: CanvasItem, p: float) -> void:
		var fade := 1.0 if p < 0.7 else 1.0 - (p - 0.7) / 0.3
		for i in 3:
			var d := Vector2.from_angle(TAU * i / 3.0 + p * TAU * 1.5) * Vector2(8.0, 3.0)
			_px(n, d.x - 1, d.y, 3, 1, Color(pal[1], fade))
			_px(n, d.x, d.y - 1, 1, 3, Color(pal[1], fade)))


## Brief tint over the whole battlefield (AoE spells, big hits).
func flash(color: Color, peak := 0.45, duration := 0.25) -> Signal:
	return _spawn(Vector2.ZERO, duration, func(n: CanvasItem, p: float) -> void:
		n.draw_rect(BATTLEFIELD, Color(color, peak * (1.0 - p))))


## Shakes the battlefield (not the windows) side to side, then settles.
func shake(amount := 3.0, duration := 0.3) -> void:
	var steps := 6
	for node: CanvasItem in shake_nodes:
		if not is_instance_valid(node):
			continue
		var home: Vector2 = node.position
		var t := create_tween()
		for i in steps:
			var falloff := 1.0 - float(i) / steps
			var dx := roundf(amount * falloff) * (1.0 if i % 2 == 0 else -1.0)
			t.tween_property(node, "position", home + Vector2(dx, 0), duration / steps)
		t.tween_property(node, "position", home, 0.03)
