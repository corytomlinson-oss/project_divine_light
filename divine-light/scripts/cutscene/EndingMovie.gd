class_name EndingMovie
extends ActOneFinale

# The ending movie (Milestone 28d), on the finale's machinery: the Maw's void
# collapsing, each freed kingdom at dawn, Verdance thriving, the four heroes
# together, Frank walking into the light, "Divine Light", a short credits
# roll, "The End". ~60s on the intro theme. Start / F3 skip.

const SHOT := 6.0


static func play_ending(from: Node) -> void:
	var movie := EndingMovie.new()
	from.get_tree().root.add_child(movie)
	Cutscene.hold()
	await movie._run()
	Cutscene.release()
	movie.queue_free()


func _run() -> void:
	await get_tree().process_frame
	Music.play("intro")
	_start_ms = Time.get_ticks_msec()
	Transition.fade_in(0.6)
	# 1. the void collapses into light
	_stage.add_child(_sky(Color(0.04, 0.0, 0.08), Color(0.3, 0.1, 0.45)))
	_title.position = Vector2(0, 70)
	_show(_caption, "The Architect is gone. The Unraveling unravels.")
	for i in 5:
		await _at(0.8 + i * 0.7)
		_fx.burst(_local(Vector2(60 + i * 50, 70 + (i % 2) * 20)), BattleFx.PALETTES["holy"], 24.0, 0.6)
	await _at(4.6)
	_white(1.0, 1.2)
	# 2-4. the kingdoms at peace
	var kingdoms := ["nordveil", "duskara", "selavon"]
	var lines := ["Nordveil's fires burn warm through the long northern nights.",
			"Duskara's oasis brims, and the caravans come home.",
			"Selavon's harbor is full of sails again."]
	for k in 3:
		await _at(SHOT * (k + 1))
		if _skipped:
			break
		_clear()
		var sky: Array = KingdomVictory.SKIES[kingdoms[k]]
		_stage.add_child(_sky(sky[0], sky[1]))
		var polys: Array = silhouettes(k)
		for i in polys.size():
			var p := Polygon2D.new()
			p.polygon = PackedVector2Array(polys[i])
			p.color = KingdomVictory.LANDS[kingdoms[k]].darkened(0.18 * (polys.size() - 1 - i) / maxf(1.0, polys.size() - 1))
			_stage.add_child(p)
		_black.color.a = 1.0
		_tween().tween_property(_black, "color:a", 0.0, 0.8)
		_show(_caption, lines[k])
	# 5. Verdance and the four
	await _at(SHOT * 4)
	if not _skipped:
		_clear()
		_image("res://assets/ui/battle_bg_forest.png")
		_black.color.a = 1.0
		_tween().tween_property(_black, "color:a", 0.0, 0.8)
		var order := ["Vael", "Ryn", "Lyra", "Silas"]
		for i in 4:
			var s := _hero(order[i], Vector2(-24 - (3 - i) * 30, 112))
			_walk(s, 100.0 + i * 40.0, 1.4 + (3 - i) * 0.1, "down")
		_show(_caption, "And in Verdance, four pure souls finally rest.")
	# 6. Frank walks into the light
	await _at(SHOT * 5 + 1.0)
	if not _skipped:
		var frank := _hero("frank", Vector2(240, 112))
		frank.flip_h = false
		_walk(frank, 330.0, 3.0, "right")
		_tween().tween_property(frank, "modulate", Color(3, 3, 3, 0), 3.0)
		_show(_caption, "%s walks on into the light, whistling an old merchant's tune." % GameManager.FRANK_TRUE_NAME)
	# 7. the title, the credits, The End
	await _at(SHOT * 6 + 1.5)
	if not _skipped:
		_clear()
		_image("res://assets/movie/intro_title.png")
		_white(0.9, 0.8)
		_show(_title, "Divine Light")
	var credits := ["A game by Cory Tomlinson", "Story, design and direction: Cory Tomlinson",
			"Built with Claude", "Thank you for playing."]
	for i in credits.size():
		await _at(SHOT * 7 + 1.5 + i * 3.0)
		if _skipped:
			break
		_show(_caption, credits[i])
	await _at(SHOT * 7 + 1.5 + credits.size() * 3.0)
	if not _skipped:
		_show(_caption, "")
		_show(_title, "The End")
	await _at(SHOT * 7 + 4.5 + credits.size() * 3.0)
	await Transition.fade_out(0.4 if _skipped else 1.5)
	Music.stop(0.5 if _skipped else 1.5)
	_black.color.a = 1.0
