class_name ActOneFinale
extends CanvasLayer

# The Act I finale movie (Cory, 2026-10-20: "see each of the dungeon bosses
# slain with some cool effects to get pumped up for Act II", and "more
# animation, not just pictures"). Plays after the Act I ending scene, in
# place of its old title card. Code-driven rather than a .scene script: the
# heroes walk, the bosses breathe and wind up, strikes use Milestone 18's
# BattleFx at 2x, bosses dissolve into light, freed captives step out of it.
#
#   pickup      "Act I - The Gathering"
#   4 shots     the bosses of this game's route, in order: the escape warden
#               of your starting dungeon, then the three rescue bosses. The
#               newest party member lands each blow; each captive joins.
#   together    all four on the forest, each class's flourish
#   kingdoms    Nordveil, Duskara, Selavon: animated teasers (snow, sand, rain)
#   Vorath      a hard cut, red flashes on the beat
#   title       "Act II - The Purge"
#
# Timed to the "finale" track (build_music.py FINALE: 140 BPM, 37 bars): every
# shot starts on a bar (_at() waits on the clock since the music started).
# Start or F3 skips. F9 previews it on any map (Cutscene.gd).

const BAR := 60.0 / 140.0 * 4.0
const T_SHOTS := 2 * BAR
const SHOT_LEN := 5 * BAR
const T_TOGETHER := 22 * BAR
const T_KINGDOMS := 25 * BAR
const KINGDOM_LEN := 2 * BAR
const T_VORATH := 31 * BAR
const T_TITLE := 33 * BAR
const T_END := 37 * BAR

const GROUND := 112.0  # feet line for actors (drawn at 2x)
const BOSS_X := 92.0
const SLOT_X := 196.0  # first party slot; the rest step 30px right
const GOLD := Color(0.91, 0.77, 0.35)
const GREY := Color(0.75, 0.73, 0.84)

const BACKGROUNDS := {
	"cathedral": "res://assets/ui/battle_bg_cathedral.png",
	"monastery": "res://assets/ui/battle_bg_monastery.png",
	"observatory": "res://assets/ui/battle_bg_observatory.png",
	"guild": "res://assets/ui/battle_bg_guild.png",
}
# Dungeon -> [escape warden, rescue boss] (Battle.LOCATION_BOSSES' ids).
const BOSSES := {
	"cathedral": ["hollow_warden", "fallen_guardian"],
	"monastery": ["sparring_master", "corrupted_grandmaster"],
	"observatory": ["void_sentinel", "void_archmage"],
	"guild": ["corrupted_enforcer", "shadow_lord"],
}

var _start_ms := 0
var _skipped := false
var _f3_held := true  # a key already down when the movie starts isn't a press
var _stage: Node2D        # everything in a shot; cleared between shots, shaken on hits
var _fx: BattleFx         # Milestone 18's effects, drawn at 2x
var _black: ColorRect     # this layer's own cut-to-black
var _flash: ColorRect
var _card_top: Label
var _card_sub: Label
var _caption: Label
var _title: Label


## Plays the whole movie; returns when it's over (screen left black).
static func play(from: Node) -> void:
	var movie := ActOneFinale.new()
	from.get_tree().root.add_child(movie)
	Cutscene.hold()  # the map underneath stays still
	await movie._run()
	Cutscene.release()
	movie.queue_free()


func _ready() -> void:
	layer = 61  # over Cutscene's movie layer (60), under Transition (100)
	process_mode = Node.PROCESS_MODE_ALWAYS
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.size = Vector2(320, 180)
	add_child(bg)
	_stage = Node2D.new()
	add_child(_stage)
	_fx = BattleFx.new()
	_fx.scale = Vector2(2, 2)
	add_child(_fx)
	_fx.shake_nodes = [_stage]
	_flash = ColorRect.new()
	_flash.size = Vector2(320, 180)
	_flash.color = Color(1, 1, 1, 0)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash)
	_black = ColorRect.new()  # under the text, so a title can show over black
	_black.size = Vector2(320, 180)
	_black.color = Color.BLACK
	add_child(_black)
	_card_top = _label(GOLD)
	_card_top.scale = Vector2(2, 2)
	_card_sub = _label(GREY)
	_caption = _label(Color.WHITE)
	_caption.position = Vector2(12, 150)
	_caption.size = Vector2(296, 20)
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title = _label(GOLD)
	_title.scale = Vector2(2, 2)
	_title.size = Vector2(160, 10)
	_title.position = Vector2(0, 70)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _label(color: Color) -> Label:
	var label := Label.new()
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.05, 0.04, 0.08))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.modulate.a = 0.0
	add_child(label)
	return label


func _process(_delta: float) -> void:
	# Start or F3 (like the intro) skips. F3 only counts as a fresh press, so
	# holding it from a battle's instant win doesn't skip by accident.
	var f3 := Input.is_key_pressed(KEY_F3)
	var f3_pressed := f3 and not _f3_held
	_f3_held = f3
	if not _skipped and (Input.is_action_just_pressed("pause") or f3_pressed):
		_skipped = true


# ------------------------------------------------------------------ timing

func _elapsed() -> float:
	return (Time.get_ticks_msec() - _start_ms) / 1000.0


## Waits until `t` seconds after the music started (at once if skipped).
func _at(t: float) -> void:
	while not _skipped and _elapsed() < t:
		await get_tree().process_frame


func _tween() -> Tween:
	return create_tween()


# ------------------------------------------------------------------ the movie

func _run() -> void:
	var cls := GameManager.starting_class if GameManager.starting_class != "" else "Vael"
	var route: Array = ActOne.ROUTES[cls]
	var heroes: Array = route.map(func(d: String) -> String: return ActOne.DUNGEONS[d]["captive"])
	await get_tree().process_frame
	Music.play("finale")
	_start_ms = Time.get_ticks_msec()
	Transition.fade_in(0.4)

	# pickup
	_show(_title, "Act I - The Gathering")
	await _at(T_SHOTS - 0.5)
	_show(_title, "")
	for i in 4:
		await _boss_shot(i, route, heroes)
	await _together(heroes)
	for k in 3:
		await _kingdom(k)
	await _vorath()
	await _title_card()

	await Transition.fade_out(0.3 if _skipped else 1.2)
	Music.stop(0.6 if _skipped else 1.5)


func _clear() -> void:
	for child in _stage.get_children():
		child.queue_free()
	_stage.position = Vector2.ZERO
	for label in [_card_top, _card_sub, _caption, _title]:
		label.modulate.a = 0.0


func _cut_in(seconds := 0.25) -> void:
	_black.color.a = 1.0
	_tween().tween_property(_black, "color:a", 0.0, seconds)


func _cut_out(seconds := 0.35) -> void:
	_tween().tween_property(_black, "color:a", 1.0, seconds)


func _white(peak := 0.8, seconds := 0.3, color := Color.WHITE) -> void:
	_flash.color = Color(color, peak)
	_tween().tween_property(_flash, "color:a", 0.0, seconds)


func _show(label: Label, text: String) -> void:
	if text == "":
		_tween().tween_property(label, "modulate:a", 0.0, 0.25)
		return
	label.text = text
	label.modulate.a = 0.0
	_tween().tween_property(label, "modulate:a", 1.0, 0.35)


## Effects take screen coordinates; BattleFx draws at 2x, so halve them.
func _local(at: Vector2) -> Vector2:
	return at / 2.0


# ------------------------------------------------------------------ actors

func _image(path: String) -> TextureRect:
	var img := TextureRect.new()
	img.texture = load(path)
	_stage.add_child(img)
	return img


func _hero(cls: String, at: Vector2) -> AnimatedSprite2D:
	var s := AnimatedSprite2D.new()
	s.sprite_frames = load("res://assets/sprites/%s_frames.tres" % cls.to_lower())
	s.material = SetLooks.material_for(SetLooks.member_for(cls.to_lower()))
	s.scale = Vector2(2, 2)
	s.position = at + Vector2(0, -32)  # 16x32 frames at 2x, feet on `at`
	s.play("idle_side")
	_stage.add_child(s)
	return s


## Walks a hero to x (side walk, facing the way they go), then idles facing `face`.
func _walk(s: AnimatedSprite2D, to_x: float, seconds: float, face := "left") -> void:
	s.flip_h = to_x < s.position.x
	s.play("walk_side")
	var t := _tween()
	t.tween_property(s, "position:x", to_x, seconds)
	t.tween_callback(func() -> void:
		if is_instance_valid(s):
			s.flip_h = face == "left"
			s.play("idle_side" if face != "down" else "idle_down"))


func _boss(id: String) -> AnimatedSprite2D:
	var tex: Texture2D = load("res://assets/sprites/enemies/%s.png" % id)
	var w := tex.get_width() / 2
	var frames := SpriteFrames.new()
	frames.set_animation_speed(&"default", 2.0)
	for f in 2:
		var atlas := AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(f * w, 0, w, tex.get_height())
		frames.add_frame(&"default", atlas)
	var s := AnimatedSprite2D.new()
	s.sprite_frames = frames
	s.scale = Vector2(2, 2)
	s.position = Vector2(BOSS_X, GROUND - tex.get_height())
	s.play()
	_stage.add_child(s)
	return s


## Center of a 2x sprite, for effects.
func _center(s: AnimatedSprite2D) -> Vector2:
	return s.position


# ------------------------------------------------------------------ boss shots

func _boss_shot(i: int, route: Array, heroes: Array) -> void:
	var t0 := T_SHOTS + i * SHOT_LEN
	await _at(t0)
	if _skipped:
		return
	_clear()
	var dungeon: String = route[i]
	var escape := i == 0
	var bg := _image(BACKGROUNDS[dungeon])
	_tween().tween_property(bg, "position:x", -6.0, SHOT_LEN)  # slow drift
	var boss_id: String = BOSSES[dungeon][0 if escape else 1]
	var boss := _boss(boss_id)
	# Who's in the party for this fight: alone for the first two, then each
	# rescued hero joins. The newest one lands the blow.
	var party: Array = heroes.slice(0, maxi(1, i))
	var actors: Dictionary = {}
	for k in party.size():
		var s := _hero(party[k], Vector2(340 + k * 30, GROUND))
		_walk(s, SLOT_X + k * 30, 1.3 + k * 0.15)
		actors[party[k]] = s
	_cut_in()
	_card_top.position = Vector2(-80, 10)
	_card_sub.position = Vector2(-80, 32)
	_show(_card_top, ActOne.DUNGEONS[dungeon]["name"])
	_show(_card_sub, EnemyData.BOSSES[boss_id]["name"])
	_tween().tween_property(_card_top, "position:x", 10.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween().tween_property(_card_sub, "position:x", 12.0, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# The boss winds up: a red pulse and sparks drawn in.
	await _at(t0 + 1.9)
	if _skipped:
		return
	Sfx.play("spell")
	_fx.charge(_local(_center(boss)), BattleFx.PALETTES["enemy"], 0.5)
	var pulse := _tween()
	pulse.tween_property(boss, "modulate", Color(1.6, 0.6, 0.6), 0.25)
	pulse.tween_property(boss, "modulate", Color.WHITE, 0.25)
	pulse.tween_property(boss, "position:x", BOSS_X + 6, 0.15)
	pulse.tween_property(boss, "position:x", BOSS_X, 0.15)

	# The blow.
	await _at(t0 + 2.9)
	if _skipped:
		return
	var striker: String = party[-1]
	_show(_card_top, "")
	_show(_card_sub, "")
	await _strike(striker, actors[striker], boss)

	# Down it goes: flash white, shake, then dissolve into rising light.
	await _at(t0 + 4.4)
	if _skipped:
		return
	_dissolve(boss)

	await _at(t0 + 5.3)
	if _skipped:
		return
	if escape:
		_show(_caption, "%s breaks free." % striker)
	else:
		var captive: String = heroes[i]
		_show(_caption, "%s is free!" % captive)
		var freed := _hero(captive, Vector2(BOSS_X, GROUND))
		freed.flip_h = false
		freed.modulate = Color(3, 3, 3, 0)
		var appear := _tween()
		appear.tween_property(freed, "modulate", Color(2, 2, 2, 1), 0.35)
		appear.tween_property(freed, "modulate", Color.WHITE, 0.4)
		_fx.sparkles(_local(Vector2(BOSS_X, GROUND - 32)), BattleFx.PALETTES["holy"], true, 1.0)
		Sfx.play("heal")
		await _at(t0 + 6.3)
		_walk(freed, SLOT_X + party.size() * 30, 1.0)
	await _at(t0 + SHOT_LEN - 0.4)
	_cut_out(0.35)


## The hero dashes in and hits with their class's look (Milestone 18's
## palettes), then hops back to their slot.
func _strike(cls: String, hero: AnimatedSprite2D, boss: AnimatedSprite2D) -> void:
	var home := hero.position.x
	var target := _local(_center(boss))
	hero.flip_h = true
	hero.play("walk_side")
	var dash := _tween()
	dash.tween_property(hero, "position:x", BOSS_X + 64, 0.18).set_ease(Tween.EASE_IN)
	await dash.finished
	match cls:
		"Vael":  # a column of holy light crashing down
			Sfx.play("holy")
			_fx.pillar(target, BattleFx.PALETTES["holy"], false, 0.7)
			_white(0.6, 0.35, Color(1.0, 0.9, 0.5))
			await get_tree().create_timer(0.25).timeout
			_fx.burst(target, BattleFx.PALETTES["holy"], 22.0, 0.45)
		"Ryn":  # a flurry: three blows, each a shockwave
			for k in 3:
				Sfx.play("hit")
				_fx.burst(target + Vector2(-6 + k * 6, -6 + (k % 2) * 10), BattleFx.PALETTES["ki"], 16.0, 0.3)
				_fx.shake(3.0, 0.15)
				_white(0.35, 0.12)
				await get_tree().create_timer(0.16).timeout
			_fx.ring(target, BattleFx.PALETTES["ki"], 0.5)
		"Lyra":  # lightning from a clear sky
			_fx.charge(_local(hero.position), BattleFx.PALETTES["arcane"], 0.25)
			await get_tree().create_timer(0.2).timeout
			Sfx.play("thunder")
			_fx.bolt(target, BattleFx.PALETTES["lightning"], 0.5)
			_white(0.85, 0.3)
			_fx.ring(target, BattleFx.PALETTES["arcane"], 0.6)
		"Silas":  # shadow cuts
			Sfx.play("attack")
			_fx.slash(target, BattleFx.PALETTES["shadow"], 3, 0.24)
			await get_tree().create_timer(0.22).timeout
			Sfx.play("attack")
			_fx.burst(target, BattleFx.PALETTES["shadow"], 18.0, 0.35)
			_white(0.4, 0.15, Color(0.7, 0.4, 1.0))
	# The boss reels.
	_fx.shake(5.0, 0.35)
	var reel := _tween()
	reel.tween_property(boss, "modulate", Color(3, 3, 3), 0.06)
	reel.tween_property(boss, "modulate", Color.WHITE, 0.12)
	reel.tween_property(boss, "modulate", Color(3, 3, 3), 0.06)
	reel.tween_property(boss, "modulate", Color.WHITE, 0.12)
	await get_tree().create_timer(0.3).timeout
	if is_instance_valid(hero):
		hero.flip_h = false
		var back := _tween()
		back.tween_property(hero, "position:x", home, 0.25)
		back.tween_callback(func() -> void:
			if is_instance_valid(hero):
				hero.flip_h = true
				hero.play("idle_side"))


## The corruption burns off: violet, then white, squashing down into motes
## of light that rise away.
func _dissolve(boss: AnimatedSprite2D) -> void:
	Sfx.play("victory")
	boss.stop()
	var c := _center(boss)
	for k in 4:
		_fx.sparkles(_local(c + Vector2(-24 + k * 16, 10 - (k % 2) * 20)), BattleFx.PALETTES["holy"], true, 1.2)
	_fx.pillar(_local(c), BattleFx.PALETTES["holy"], true, 1.0)
	var t := _tween()
	t.tween_property(boss, "modulate", Color(1.4, 0.6, 2.0), 0.2)
	t.tween_property(boss, "modulate", Color(3, 3, 3), 0.2)
	t.tween_property(boss, "modulate:a", 0.0, 0.7)
	var squash := _tween()
	squash.tween_interval(0.4)
	squash.tween_property(boss, "scale", Vector2(2.6, 0.4), 0.6)


# ------------------------------------------------------------------ together

func _together(heroes: Array) -> void:
	await _at(T_TOGETHER)
	if _skipped:
		return
	_clear()
	var bg := _image("res://assets/ui/battle_bg_forest.png")
	_tween().tween_property(bg, "position:x", -8.0, 3 * BAR)
	var order := ["Vael", "Ryn", "Lyra", "Silas"]  # the classic line-up, whoever started
	var xs := [100.0, 140.0, 180.0, 220.0]
	var actors: Array = []
	for k in 4:
		var s := _hero(order[k], Vector2(-20 - (3 - k) * 30, GROUND))
		_walk(s, xs[k], 1.2 + (3 - k) * 0.1, "down")
		actors.append(s)
	_cut_in(0.2)
	_show(_caption, "Four pure souls, together at last.")
	await _at(T_TOGETHER + 1.8)
	if _skipped:
		return
	var looks := [["pillar", "holy"], ["burst", "ki"], ["bolt", "lightning"], ["slash", "shadow"]]
	for k in 4:
		var at := _local(Vector2(xs[k], GROUND - 76))
		var pal: Array = BattleFx.PALETTES[looks[k][1]]
		match looks[k][0]:
			"pillar": _fx.pillar(at, pal, true, 0.6)
			"burst": _fx.burst(at, pal, 16.0, 0.4)
			"bolt": _fx.bolt(at, pal, 0.4)
			"slash": _fx.slash(at, pal, 2, 0.22)
		Sfx.play(["holy", "hit", "thunder", "attack"][k])
		await get_tree().create_timer(0.22).timeout
	_white(0.7, 0.4)
	for s: AnimatedSprite2D in actors:
		_fx.sparkles(_local(s.position), BattleFx.PALETTES["holy"], true, 0.9)
	await _at(T_KINGDOMS - 0.3)
	_cut_out(0.25)


# ------------------------------------------------------------------ kingdoms

const KINGDOMS := [
	{"name": "Nordveil", "sub": "The Frozen Citadel", "weather": "snow",
		"sky": [Color(0.1, 0.13, 0.26), Color(0.55, 0.7, 0.86)], "land": Color(0.09, 0.12, 0.2)},
	{"name": "Duskara", "sub": "The Sunken Sanctum", "weather": "sand",
		"sky": [Color(0.24, 0.09, 0.07), Color(0.93, 0.58, 0.28)], "land": Color(0.2, 0.09, 0.05)},
	{"name": "Selavon", "sub": "The Drowned Fortress", "weather": "rain",
		"sky": [Color(0.05, 0.1, 0.13), Color(0.22, 0.38, 0.44)], "land": Color(0.04, 0.08, 0.1)},
]


func _kingdom(k: int) -> void:
	var t0 := T_KINGDOMS + k * KINGDOM_LEN
	await _at(t0)
	if _skipped:
		return
	_clear()
	var info: Dictionary = KINGDOMS[k]
	_stage.add_child(_sky(info["sky"][0], info["sky"][1]))
	var land := Node2D.new()
	_stage.add_child(land)
	for poly in silhouettes(k):
		var p := Polygon2D.new()
		p.polygon = PackedVector2Array(poly)
		p.color = info["land"]
		land.add_child(p)
	if k == 1:  # Duskara's low sun with a glow, behind the dunes
		for ring in [[40.0, Color(1.0, 0.85, 0.55, 0.25)], [30.0, Color(1.0, 0.9, 0.65, 0.4)], [22.0, Color(1.0, 0.97, 0.82, 1.0)]]:
			var sun := Polygon2D.new()
			var pts: Array = []
			for a in 32:
				pts.append(Vector2(236, 108) + Vector2.from_angle(TAU * a / 32.0) * float(ring[0]))
			sun.polygon = PackedVector2Array(pts)
			sun.color = ring[1]
			_stage.add_child(sun)
			_stage.move_child(sun, _stage.get_child_count() - 2)  # just under the land
	land.position.x = 8.0
	_tween().tween_property(land, "position:x", -8.0, KINGDOM_LEN)  # slow push across
	var weather := WeatherFx.new()
	weather.kind = info["weather"]
	_stage.add_child(weather)
	_white(0.9, 0.35)
	_black.color.a = 0.0
	Sfx.play("thunder" if k == 2 else "encounter")
	_title.position = Vector2(0, 46)
	_show(_title, info["name"])
	_show(_caption, info["sub"])
	if k == 2:  # lightning over the drowned fortress
		await _at(t0 + 1.4)
		_white(0.6, 0.2)


func _sky(top: Color, bottom: Color) -> TextureRect:
	var g := Gradient.new()
	g.set_color(0, top)
	g.set_color(1, bottom)
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(0, 1)
	tex.width = 320
	tex.height = 180
	var rect := TextureRect.new()
	rect.texture = tex
	return rect


## Each kingdom's skyline (polygons in screen pixels), a little wider than the
## screen so the slow push never shows an edge.
static func silhouettes(k: int) -> Array:
	match k:
		0:  # mountains, and the citadel's spires between them
			return [
				[Vector2(-20, 180), Vector2(-20, 120), Vector2(30, 82), Vector2(64, 108), Vector2(104, 62),
					Vector2(132, 96), Vector2(196, 96), Vector2(226, 66), Vector2(262, 104), Vector2(300, 78),
					Vector2(340, 112), Vector2(340, 180)],
				[Vector2(136, 132), Vector2(136, 84), Vector2(142, 60), Vector2(148, 84), Vector2(154, 84),
					Vector2(160, 40), Vector2(166, 84), Vector2(172, 84), Vector2(178, 60), Vector2(184, 84),
					Vector2(184, 132)],
				[Vector2(-20, 180), Vector2(-20, 132), Vector2(340, 128), Vector2(340, 180)],
			]
		1:  # dunes, and a stepped sanctum half-buried in them
			var dunes: Array = [Vector2(-20, 180)]
			for x in range(-20, 341, 10):
				dunes.append(Vector2(x, 124 + 8 * sin(x / 34.0) + 4 * sin(x / 13.0)))
			dunes.append(Vector2(340, 180))
			return [
				[Vector2(112, 130), Vector2(112, 112), Vector2(124, 112), Vector2(124, 100), Vector2(136, 100),
					Vector2(136, 88), Vector2(148, 88), Vector2(148, 74), Vector2(172, 74), Vector2(172, 88),
					Vector2(184, 88), Vector2(184, 100), Vector2(196, 100), Vector2(196, 112), Vector2(208, 112),
					Vector2(208, 130)],
				dunes,
			]
		_:  # a fortress sinking into a dark sea
			var sea: Array = [Vector2(-20, 180)]
			for x in range(-20, 341, 8):
				sea.append(Vector2(x, 122 + 2 * sin(x / 9.0)))
			sea.append(Vector2(340, 180))
			return [
				[Vector2(120, 126), Vector2(120, 80), Vector2(116, 80), Vector2(116, 70), Vector2(128, 70),
					Vector2(128, 92), Vector2(150, 92), Vector2(150, 58), Vector2(146, 58), Vector2(146, 48),
					Vector2(162, 48), Vector2(162, 58), Vector2(158, 58), Vector2(158, 92), Vector2(184, 92),
					Vector2(184, 74), Vector2(180, 74), Vector2(180, 66), Vector2(194, 66), Vector2(194, 126)],
				sea,
			]



# ------------------------------------------------------------------ Vorath

func _vorath() -> void:
	await _at(T_VORATH)
	if _skipped:
		return
	_clear()
	var img := _image("res://assets/movie/intro_vorath.png")
	img.position.y = -120
	_tween().tween_property(img, "position:y", -104.0, 2 * BAR)  # a slow sink toward him
	_white(1.0, 0.5, Color(0.9, 0.1, 0.15))
	Sfx.play("thunder")
	_fx.shake(6.0, 0.5)
	_title.position = Vector2(0, 120)
	_show(_caption, "And beyond them all, the Architect waits.")
	# Red pulses on the stabs of the music (beats 1 and 3 of each bar).
	for beat in [2, 4, 6]:
		await _at(T_VORATH + beat * BAR / 4.0)
		if _skipped:
			return
		_white(0.45, 0.25, Color(0.9, 0.1, 0.15))
		_fx.shake(3.0, 0.2)
	await _at(T_TITLE - 0.25)
	_cut_out(0.2)


# ------------------------------------------------------------------ title

func _title_card() -> void:
	await _at(T_TITLE)
	if _skipped:
		return
	_clear()
	_image("res://assets/movie/intro_title.png")
	_black.color.a = 0.0
	_white(1.0, 0.8)
	Sfx.play("level_up")
	_title.position = Vector2(0, 70)
	_show(_title, "Act II - The Purge")
	_fx.sparkles(_local(Vector2(110, 80)), BattleFx.PALETTES["holy"], true, 1.4)
	_fx.sparkles(_local(Vector2(210, 80)), BattleFx.PALETTES["holy"], true, 1.4)
	await _at(T_TITLE + 2 * BAR)
	# Act II begins with Nordveil (25b); the old card said it was coming later.
	_show(_caption, "The mountain pass to Nordveil lies north." if Kingdoms.is_built("nordveil") else "Coming in a later update.")
	await _at(T_END)
