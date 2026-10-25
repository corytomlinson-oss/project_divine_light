class_name SetLooks
extends RefCounted

# Armor sets change how a hero looks (Cory, 2026-10-23: "option 1"): wearing
# a complete set recolors that hero's sprite everywhere it appears - on the
# map, in battle, in cutscenes and the pause menu. Done with a palette swap
# (assets/shaders/palette_swap.gdshader) on the hand-placed walk sheets,
# whose colors are exact (build_<name>_walk.py's PAL).
#
# LOOKS: set id -> [[source color, new color], ...] (RGB 0-255, up to 8).

const SHADER := preload("res://assets/shaders/palette_swap.gdshader")

const LOOKS := {
	# Vael: tabard T/t, steel D/S, shield P/B/b
	"holy_guardian": [[[236, 228, 208], [244, 222, 150]], [[184, 172, 146], [196, 166, 92]]],
	"sacred_aegis": [
		[[138, 147, 168], [184, 194, 214]], [[72, 80, 104], [112, 122, 150]],
		[[96, 132, 204], [255, 248, 222]], [[52, 84, 156], [236, 222, 180]], [[30, 46, 100], [184, 160, 104]],
		[[236, 228, 208], [156, 196, 240]], [[184, 172, 146], [100, 138, 196]],
	],
	# Ryn: gi O/o, headband R/r, wraps T
	"iron_monk": [[[236, 150, 52], [156, 156, 168]], [[184, 100, 36], [100, 100, 114]], [[196, 48, 48], [128, 28, 36]]],
	"storm_dragon": [
		[[236, 150, 52], [76, 118, 210]], [[184, 100, 36], [42, 72, 146]],
		[[196, 48, 48], [232, 184, 48]], [[128, 28, 36], [168, 116, 28]], [[236, 228, 208], [248, 248, 252]],
	],
	# Lyra: robe C/c
	"arcane_scholar": [[[40, 138, 138], [116, 74, 176]], [[24, 88, 96], [72, 42, 120]]],
	"elemental_weave": [[[40, 138, 138], [190, 56, 64]], [[24, 88, 96], [122, 32, 46]]],
	# Silas: hood H/h/j, scarf M/m
	"shadow_walker": [
		[[58, 52, 72], [36, 32, 46]], [[88, 80, 106], [60, 54, 76]], [[34, 30, 44], [20, 18, 28]],
		[[52, 104, 72], [112, 62, 152]], [[32, 68, 48], [72, 38, 102]],
	],
	"venom_weave": [
		[[58, 52, 72], [46, 64, 54]], [[88, 80, 106], [72, 96, 80]], [[34, 30, 44], [26, 38, 32]],
		[[52, 104, 72], [124, 204, 64]], [[32, 68, 48], [72, 132, 38]],
	],
}


# Act III's sets don't recolor: they swap in a whole new form (Cory,
# 2026-10-25: "completely change the characters... ready to kick ass").
# set id -> hero; the sheet is <hero>_ascended_walk.png, 24x32 frames in the
# base sheets' layout (assets/sprites/source/build_act3_forms.py).
const FORMS := {
	"divine_champion": "vael",
	"rising_force": "ryn",
	"cosmic_conduit": "lyra",
	"deaths_hand": "silas",
}
const FORM_W := 24
static var _form_cache := {}


## The complete set this hero wears, or "".
static func active_set(member: Combatant) -> String:
	if member == null:
		return ""
	for set_id: String in Equipment.SET_BONUSES:
		if Equipment.has_set_bonus(member, set_id):
			return set_id
	return ""


## A material recoloring this hero for their set, or null (no set, no look).
static func material_for(member: Combatant) -> ShaderMaterial:
	var pairs: Array = LOOKS.get(active_set(member), [])
	if pairs.is_empty():
		return null
	var src := PackedVector3Array()
	var dst := PackedVector3Array()
	for pair: Array in pairs:
		src.append(Vector3(pair[0][0], pair[0][1], pair[0][2]) / 255.0)
		dst.append(Vector3(pair[1][0], pair[1][1], pair[1][2]) / 255.0)
	while src.size() < 8:
		src.append(Vector3(-1, -1, -1))
		dst.append(Vector3.ZERO)
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	mat.set_shader_parameter("count", pairs.size())
	mat.set_shader_parameter("src", src)
	mat.set_shader_parameter("dst", dst)
	return mat


## The roster member a sprite name stands for ("vael" -> Vael), if any.
static func member_for(sprite_name: String) -> Combatant:
	return GameManager.roster.get(sprite_name.capitalize(), null)


## The hero's Act III form sheet if they wear its full set, else null.
static func form_texture(member: Combatant) -> Texture2D:
	var hero: String = FORMS.get(active_set(member), "")
	if hero == "":
		return null
	return load("res://assets/sprites/%s_ascended_walk.png" % hero)


## The frames to show for this hero: `base` (their walk frames), or the same
## animations cut from their Act III form sheet when they wear its full set.
static func frames_for(member: Combatant, base: SpriteFrames) -> SpriteFrames:
	var tex := form_texture(member)
	if tex == null or base == null:
		return base
	var key := tex.resource_path
	if _form_cache.has(key):
		return _form_cache[key]
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for anim: StringName in base.get_animation_names():
		frames.add_animation(anim)
		frames.set_animation_speed(anim, base.get_animation_speed(anim))
		frames.set_animation_loop(anim, base.get_animation_loop(anim))
		for i in base.get_frame_count(anim):
			var src := base.get_frame_texture(anim, i) as AtlasTexture
			var cut := AtlasTexture.new()
			cut.atlas = tex
			# the same cell of the 3x3 grid, 24px wide instead of 16
			cut.region = Rect2(src.region.position.x / 16.0 * FORM_W, src.region.position.y, FORM_W, src.region.size.y)
			frames.add_frame(anim, cut, base.get_frame_duration(anim, i))
	_form_cache[key] = frames
	return frames
