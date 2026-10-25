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

# Every set now swaps in a whole form (FORMS below), so no recolors are left;
# material_for() stays for any future set without art (it returns null).
const LOOKS := {}


# Every set swaps in a whole new form (Cory, 2026-10-25: the Act III sets
# "completely change the characters", then "different models for each of the
# sets... a gradual increase"). set id -> hero; the sheet is
# <hero>_<set id>_walk.png, 24x32 frames in the base sheets' layout
# (assets/sprites/source/build_set_forms.py).
const FORMS := {
	"holy_guardian": "vael", "sacred_aegis": "vael", "divine_champion": "vael",
	"iron_monk": "ryn", "storm_dragon": "ryn", "rising_force": "ryn",
	"arcane_scholar": "lyra", "elemental_weave": "lyra", "cosmic_conduit": "lyra",
	"shadow_walker": "silas", "venom_weave": "silas", "deaths_hand": "silas",
}
const FORM_W := 24
static var _form_cache := {}


## The complete set this hero wears, or "".
static func active_set(member: Combatant) -> String:
	if member == null:
		return ""
	for set_id: String in Equipment.SET_BONUSES:
		if Equipment.wears_full_set(member, set_id):  # the look follows what's worn, not mastery
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
	var set_id := active_set(member)
	var hero: String = FORMS.get(set_id, "")
	if hero == "":
		return null
	return load("res://assets/sprites/%s_%s_walk.png" % [hero, set_id])


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
