class_name WeatherFx
extends Node2D

# Weather drawn as whole pixels over a 320x180 screen (from the Act I finale's
# kingdom teasers; a class of its own since 25b, when Nordveil's blizzard
# needed it too). Put it in a CanvasLayer to cover the screen.
#
#   snow      gentle flakes drifting down
#   blizzard  thick, fast snow driven sideways, with a pale haze
#   sand      grains blowing across
#   rain      slanting streaks

var kind := "snow"
var _motes: Array = []
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 2410
	var count: int = {"rain": 90, "blizzard": 160}.get(kind, 70)
	for i in count:
		_motes.append(Vector3(_rng.randf_range(0, 320), _rng.randf_range(0, 180), _rng.randf_range(0.5, 1.0)))


func _process(delta: float) -> void:
	for i in _motes.size():
		var m: Vector3 = _motes[i]
		match kind:
			"snow":
				m.y += 22.0 * m.z * delta
				m.x += sin(m.y / 14.0 + i) * 8.0 * delta - 6.0 * delta
			"blizzard":
				m.y += 70.0 * m.z * delta
				m.x -= (110.0 + 40.0 * sin(m.y / 20.0 + i)) * m.z * delta
			"sand":
				m.x -= 120.0 * m.z * delta
				m.y += sin(m.x / 20.0 + i) * 6.0 * delta
			_:
				m.x -= 60.0 * delta
				m.y += 220.0 * m.z * delta
		if m.y > 182:
			m.y -= 184
		if m.x < -4:
			m.x += 326
		_motes[i] = m
	queue_redraw()


func _draw() -> void:
	if kind == "blizzard":
		draw_rect(Rect2(0, 0, 320, 180), Color(0.85, 0.9, 1.0, 0.16))
	for m: Vector3 in _motes:
		var p := Vector2(roundf(m.x), roundf(m.y))
		match kind:
			"snow":
				draw_rect(Rect2(p, Vector2.ONE * (2 if m.z > 0.85 else 1)), Color(1, 1, 1, 0.5 + 0.5 * m.z))
			"blizzard":
				draw_rect(Rect2(p, Vector2(3 if m.z > 0.8 else 2, 1)), Color(1, 1, 1, 0.45 + 0.5 * m.z))
			"sand":
				draw_rect(Rect2(p, Vector2(3 if m.z > 0.8 else 2, 1)), Color(1.0, 0.8, 0.5, 0.35 + 0.4 * m.z))
			_:
				for s in 4:
					draw_rect(Rect2(p + Vector2(s, -s * 3), Vector2.ONE), Color(0.7, 0.85, 0.95, 0.5 * m.z))
