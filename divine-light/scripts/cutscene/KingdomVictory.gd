class_name KingdomVictory
extends ActOneFinale

# The short movie card after a kingdom is freed (Milestone 25b; Cory: an
# in-town scene, then "a short animated card, like the Act I finale"). Built
# on the finale's machinery (layers, BattleFx at 2x, walking heroes, F3 /
# Start to skip): the kingdom's skyline at dawn, restored, the sun climbing,
# the four heroes walking in with their flourishes, the kingdom's name, and a
# look ahead at what's left. ~14 seconds on the "finale" theme's opening.

const SKIES := {
	"nordveil": [Color(0.22, 0.32, 0.58), Color(1.0, 0.78, 0.62)],
	"duskara": [Color(0.3, 0.4, 0.7), Color(1.0, 0.86, 0.6)],
	"selavon": [Color(0.2, 0.4, 0.62), Color(0.84, 0.92, 0.95)],
}
const LANDS := {
	"nordveil": Color(0.84, 0.9, 0.98),
	"duskara": Color(0.86, 0.66, 0.42),
	"selavon": Color(0.32, 0.5, 0.56),
}

var _freed := "nordveil"


static func play_for(from: Node, kingdom: String) -> void:
	var movie := KingdomVictory.new()
	movie._freed = kingdom
	from.get_tree().root.add_child(movie)
	Cutscene.hold()
	await movie._run()
	Cutscene.release()
	movie.queue_free()


func _run() -> void:
	await get_tree().process_frame
	# The town faded to black through Transition (layer 100, above this one):
	# lift it, or the whole card plays under black (2026-10-28, Cory: "just
	# black", music and sounds only). ActOneFinale and EndingMovie do the same.
	Transition.fade_in(0.4)
	Music.play("finale")
	_start_ms = Time.get_ticks_msec()
	var k: int = Kingdoms.ORDER.find(_freed)
	var info: Dictionary = Kingdoms.KINGDOMS[_freed]
	var sky: Array = SKIES.get(_freed, SKIES["nordveil"])
	_stage.add_child(_sky(sky[0], sky[1]))
	var sun := Polygon2D.new()
	var pts: Array = []
	for a in 32:
		pts.append(Vector2.from_angle(TAU * a / 32.0) * 18.0)
	sun.polygon = PackedVector2Array(pts)
	sun.color = Color(1.0, 0.95, 0.75)
	sun.position = Vector2(236, 132)
	_stage.add_child(sun)
	_tween().tween_property(sun, "position:y", 62.0, 6 * BAR).set_ease(Tween.EASE_OUT)
	var land := Node2D.new()
	_stage.add_child(land)
	var polys: Array = silhouettes(maxi(0, k))
	for i in polys.size():
		var p := Polygon2D.new()
		p.polygon = PackedVector2Array(polys[i])
		# far layers a shade darker than the ground in front, for depth
		p.color = LANDS.get(_freed, Color.WHITE).darkened(0.18 * (polys.size() - 1 - i) / maxf(1.0, polys.size() - 1))
		land.add_child(p)
	_black.color.a = 1.0
	_tween().tween_property(_black, "color:a", 0.0, 0.8)
	Sfx.play("level_up")
	_title.position = Vector2(0, 34)
	_show(_title, "%s is free!" % info["name"])

	await _at(2 * BAR)
	if not _skipped:
		var order := ["Vael", "Ryn", "Lyra", "Silas"]
		for i in 4:
			var s := _hero(order[i], Vector2(-24 - (3 - i) * 30, 150))
			_walk(s, 100.0 + i * 40.0, 1.2 + (3 - i) * 0.1, "down")
		_show(_caption, info["cleansed_text"])
	await _at(4 * BAR)
	if not _skipped:
		var looks := [["pillar", "holy"], ["burst", "ki"], ["bolt", "lightning"], ["slash", "shadow"]]
		for i in 4:
			var at := _local(Vector2(100.0 + i * 40.0, 82))
			var pal: Array = BattleFx.PALETTES[looks[i][1]]
			match looks[i][0]:
				"pillar": _fx.pillar(at, pal, true, 0.6)
				"burst": _fx.burst(at, pal, 16.0, 0.4)
				"bolt": _fx.bolt(at, pal, 0.4)
				"slash": _fx.slash(at, pal, 2, 0.22)
			Sfx.play(["holy", "hit", "thunder", "attack"][i])
			await get_tree().create_timer(0.22).timeout
		_white(0.6, 0.4)
		for i in 6:
			_fx.sparkles(_local(Vector2(40 + i * 48, 100)), BattleFx.PALETTES["holy"], true, 1.2)
	await _at(6 * BAR)
	if not _skipped:
		var left := Kingdoms.ORDER.filter(func(id: String) -> bool: return not Kingdoms.is_cleansed(id))
		var names: Array = left.map(func(id: String) -> String: return Kingdoms.KINGDOMS[id]["name"])
		if names.is_empty():
			_show(_caption, "Every kingdom is free. Only the Blighted Maw remains.")
		else:
			_show(_caption, "%s still %s in Vorath's grip." % [" and ".join(names), "lies" if names.size() == 1 else "lie"])
	# The last kingdom freed (25d): the end of Act II's kingdoms.
	if Kingdoms.all_cleansed() and not _skipped:
		await _at(8 * BAR)
		GameManager.story_flags["act_two_complete"] = true
		_show(_caption, "")
		_title.position = Vector2(0, 70)
		_white(0.8, 0.6)
		Sfx.play("level_up")
		_show(_title, "Act II - The Purge")
		await _at(10 * BAR)
		_show(_title, "Act III - The Source")
		_show(_caption, "The road south of the Guild leads to the Blighted Reach." if Kingdoms.is_built("maw") else "Coming in a later update.")
		await _at(13 * BAR)
	elif Kingdoms.all_cleansed():
		GameManager.story_flags["act_two_complete"] = true
	await _at(8 * BAR)
	await Transition.fade_out(0.3 if _skipped else 0.8)
	Music.stop(0.4 if _skipped else 1.0)
	_black.color.a = 1.0
